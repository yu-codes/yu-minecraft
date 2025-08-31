#!/bin/bash

# Yu Minecraft Server 玩家資訊抓取腳本
# 作者: Yu-codes
# 用途: 抓取線上玩家資訊，包含玩家名稱、UUID、線上時間等

set -e

# 配置
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WORLDS_DIR="$PROJECT_ROOT/worlds"
CURRENT_WORLD="$WORLDS_DIR/current"

# 顏色設定
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 獲取玩家資訊
get_player_info() {
    local output_format="${1:-json}"  # json 或 text
    
    echo "📊 正在獲取玩家資訊..." >&2
    
    # 檢查當前世界目錄是否存在
    if [ ! -d "$CURRENT_WORLD" ]; then
        if [ "$output_format" = "json" ]; then
            echo '{"success": false, "error": "當前世界目錄不存在", "players": []}'
        else
            echo -e "${RED}❌ 當前世界目錄不存在${NC}" >&2
        fi
        return 1
    fi
    
    local player_list=()
    local online_count=0
    
    # 方法1: 從 playerdata 目錄獲取最近活躍玩家
    local playerdata_dir="$CURRENT_WORLD/playerdata"
    if [ -d "$playerdata_dir" ]; then
        local current_time=$(date +%s)
        
        for player_file in "$playerdata_dir"/*.dat; do
            if [ ! -f "$player_file" ]; then
                continue
            fi
            
            local filename=$(basename "$player_file")
            local player_uuid="${filename%.dat}"
            local file_mtime=$(stat -f %m "$player_file" 2>/dev/null || stat -c %Y "$player_file" 2>/dev/null || echo 0)
            local time_diff=$((current_time - file_mtime))
            
            # 如果在最近10分鐘內修改過檔案，認為是線上玩家
            if [ $time_diff -lt 600 ]; then
                local player_name=$(get_player_name_from_uuid "$player_uuid")
                local online_time=$(format_time_diff $time_diff)
                local last_seen=$(date -r $file_mtime '+%H:%M:%S' 2>/dev/null || date -d "@$file_mtime" '+%H:%M:%S' 2>/dev/null || echo "未知")
                
                if [ "$output_format" = "json" ]; then
                    player_list+=("{\"name\":\"$player_name\",\"uuid\":\"$player_uuid\",\"online_time\":\"$online_time\",\"last_seen\":\"$last_seen\"}")
                else
                    echo -e "${GREEN}🎮 $player_name${NC} (UUID: $player_uuid)"
                    echo -e "   ⏰ 線上時間: $online_time"
                    echo -e "   📅 最後活動: $last_seen"
                    echo ""
                fi
                
                ((online_count++))
            fi
        done
    fi
    
    # 方法2: 如果沒有找到活躍玩家，嘗試使用 RCON 指令
    if [ $online_count -eq 0 ]; then
        local rcon_result=$(try_rcon_list)
        if [ $? -eq 0 ] && [ -n "$rcon_result" ]; then
            # 解析 RCON 結果
            local rcon_count=$(echo "$rcon_result" | grep -o "There are [0-9]* of" | grep -o "[0-9]*" || echo "0")
            if [ "$rcon_count" -gt 0 ]; then
                online_count=$rcon_count
                
                # 嘗試解析玩家名稱
                local player_names=$(echo "$rcon_result" | grep -oP "online: \K.*" | tr ',' '\n' | xargs)
                if [ -n "$player_names" ]; then
                    for name in $player_names; do
                        name=$(echo "$name" | xargs)  # 去除空白
                        if [ -n "$name" ]; then
                            local uuid=$(get_uuid_from_name "$name")
                            if [ "$output_format" = "json" ]; then
                                player_list+=("{\"name\":\"$name\",\"uuid\":\"$uuid\",\"online_time\":\"未知\",\"last_seen\":\"現在\"}")
                            else
                                echo -e "${GREEN}🎮 $name${NC} (UUID: $uuid)"
                                echo -e "   ⏰ 線上時間: 未知"
                                echo -e "   📅 最後活動: 現在"
                                echo ""
                            fi
                        fi
                    done
                else
                    # 如果無法解析玩家名稱，創建通用項目
                    for i in $(seq 1 $online_count); do
                        if [ "$output_format" = "json" ]; then
                            player_list+=("{\"name\":\"Player_$i\",\"uuid\":\"unknown-$i\",\"online_time\":\"未知\",\"last_seen\":\"現在\"}")
                        else
                            echo -e "${GREEN}🎮 Player_$i${NC} (UUID: unknown-$i)"
                            echo -e "   ⏰ 線上時間: 未知"
                            echo -e "   📅 最後活動: 現在"
                            echo ""
                        fi
                    done
                fi
            fi
        fi
    fi
    
    # 輸出結果
    if [ "$output_format" = "json" ]; then
        local players_json=$(IFS=','; echo "[${player_list[*]}]")
        echo "{\"success\": true, \"online_count\": $online_count, \"players\": $players_json}"
    else
        echo -e "${BLUE}📊 總結${NC}"
        echo -e "${GREEN}線上玩家數: $online_count${NC}"
        
        if [ $online_count -eq 0 ]; then
            echo -e "${YELLOW}目前沒有玩家線上${NC}"
        fi
    fi
}

# 從 UUID 獲取玩家名稱
get_player_name_from_uuid() {
    local uuid="$1"
    local clean_uuid=$(echo "$uuid" | tr -d '-' | tr '[:upper:]' '[:lower:]')
    
    # 檢查當前世界的 usercache.json
    local usercache_files=(
        "$CURRENT_WORLD/usercache.json"
        "$PROJECT_ROOT/usercache.json"
        "$PROJECT_ROOT/config/usercache.json"
    )
    
    for usercache_file in "${usercache_files[@]}"; do
        if [ -f "$usercache_file" ]; then
            local name=$(python3 -c "
import json, sys
try:
    with open('$usercache_file', 'r') as f:
        cache = json.load(f)
    for entry in cache:
        if entry.get('uuid', '').replace('-', '').lower() == '$clean_uuid':
            print(entry.get('name', '').strip())
            sys.exit(0)
except:
    pass
" 2>/dev/null)
            
            if [ -n "$name" ] && [ "$name" != "Unknown" ]; then
                echo "$name"
                return 0
            fi
        fi
    done
    
    # 檢查當前世界的 whitelist.json，如果沒有則檢查全域配置
    local whitelist_files=(
        "$CURRENT_WORLD/whitelist.json"
        "$PROJECT_ROOT/config/whitelist.json"
        "$PROJECT_ROOT/config/global/whitelist.json"
    )
    
    for whitelist_file in "${whitelist_files[@]}"; do
        if [ -f "$whitelist_file" ]; then
            local name=$(python3 -c "
import json, sys
try:
    with open('$whitelist_file', 'r') as f:
        whitelist = json.load(f)
    for entry in whitelist:
        if entry.get('uuid', '').replace('-', '').lower() == '$clean_uuid':
            print(entry.get('name', '').strip())
            sys.exit(0)
except:
    pass
" 2>/dev/null)
            
            if [ -n "$name" ] && [ "$name" != "Unknown" ]; then
                echo "$name"
                return 0
            fi
        fi
    done
    
    # 檢查 ops.json 文件
    local ops_files=(
        "$CURRENT_WORLD/ops.json"
        "$PROJECT_ROOT/config/ops.json"
        "$PROJECT_ROOT/config/global/ops.json"
    )
    
    for ops_file in "${ops_files[@]}"; do
        if [ -f "$ops_file" ]; then
            local name=$(python3 -c "
import json, sys
try:
    with open('$ops_file', 'r') as f:
        ops = json.load(f)
    for entry in ops:
        if entry.get('uuid', '').replace('-', '').lower() == '$clean_uuid':
            print(entry.get('name', '').strip())
            sys.exit(0)
except:
    pass
" 2>/dev/null)
            
            if [ -n "$name" ] && [ "$name" != "Unknown" ]; then
                echo "$name"
                return 0
            fi
        fi
    done
    
    # 使用固定的 UUID 映射
    case "$clean_uuid" in
        "3d2aeac14ea14d92b48bf71704c08622") echo "Steve" ;;
        "5ee80fecd63f41e792288904ae652583") echo "Alex" ;;
        "805ff403650c46f792d77c55858d4cf2") echo "Herobrine" ;;
        *) echo "Unknown_${clean_uuid:0:6}" ;;  # 使用前6碼作為假名
    esac
}

# 從玩家名稱獲取 UUID
get_uuid_from_name() {
    local name="$1"
    
    # 檢查當前世界的 usercache.json
    local usercache_files=(
        "$CURRENT_WORLD/usercache.json"
        "$PROJECT_ROOT/usercache.json"
        "$PROJECT_ROOT/config/usercache.json"
    )
    
    for usercache_file in "${usercache_files[@]}"; do
        if [ -f "$usercache_file" ]; then
            local uuid=$(python3 -c "
import json, sys
try:
    with open('$usercache_file', 'r') as f:
        cache = json.load(f)
    for entry in cache:
        if entry.get('name', '').lower() == '$name'.lower():
            print(entry.get('uuid', 'unknown'))
            sys.exit(0)
except:
    pass
print('unknown')
" 2>/dev/null)
            
            if [ "$uuid" != "unknown" ] && [ -n "$uuid" ]; then
                echo "$uuid"
                return 0
            fi
        fi
    done
    
    # 檢查當前世界的 whitelist.json，如果沒有則檢查全域配置
    local whitelist_files=(
        "$CURRENT_WORLD/whitelist.json"
        "$PROJECT_ROOT/config/whitelist.json"
        "$PROJECT_ROOT/config/global/whitelist.json"
    )
    
    for whitelist_file in "${whitelist_files[@]}"; do
        if [ -f "$whitelist_file" ]; then
            local uuid=$(python3 -c "
import json, sys
try:
    with open('$whitelist_file', 'r') as f:
        whitelist = json.load(f)
    for entry in whitelist:
        if entry.get('name', '').lower() == '$name'.lower():
            print(entry.get('uuid', 'unknown'))
            sys.exit(0)
except:
    pass
print('unknown')
" 2>/dev/null)
            
            if [ "$uuid" != "unknown" ] && [ -n "$uuid" ]; then
                echo "$uuid"
                return 0
            fi
        fi
    done
    
    # 使用固定的名稱映射
    case "${name,,}" in
        "steve") echo "3d2aeac1-4ea1-4d92-b48b-f71704c08622" ;;
        "alex") echo "5ee80fec-d63f-41e7-9228-8904ae652583" ;;
        "herobrine") echo "805ff403-650c-46f7-92d7-7c55858d4cf2" ;;
        *) echo "unknown-$(echo -n "$name" | md5sum | cut -c1-6)" ;;  # 使用前6碼作為 UUID
    esac
}

# 嘗試使用 RCON 獲取玩家列表
try_rcon_list() {
    # 檢查 Docker 容器是否運行
    if ! docker compose -f "$PROJECT_ROOT/docker/docker-compose.yml" ps 2>/dev/null | grep -q "Up"; then
        return 1
    fi
    
    # 嘗試執行 RCON 指令
    local result=$(cd "$PROJECT_ROOT/docker" && docker compose exec -T minecraft-server rcon-cli "list" 2>/dev/null)
    local exit_code=$?
    
    if [ $exit_code -eq 0 ] && [ -n "$result" ]; then
        echo "$result"
        return 0
    else
        return 1
    fi
}

# 格式化時間差
format_time_diff() {
    local seconds=$1
    
    if [ $seconds -lt 60 ]; then
        echo "${seconds}秒"
    elif [ $seconds -lt 3600 ]; then
        local minutes=$((seconds / 60))
        echo "${minutes}分鐘"
    else
        local hours=$((seconds / 3600))
        local remaining_minutes=$(((seconds % 3600) / 60))
        if [ $remaining_minutes -eq 0 ]; then
            echo "${hours}小時"
        else
            echo "${hours}小時${remaining_minutes}分鐘"
        fi
    fi
}

# 獲取所有已知玩家（包含離線）
get_all_players() {
    local output_format="${1:-text}"
    
    echo "📋 正在獲取所有已知玩家..." >&2
    
    local all_players=()
    local playerdata_dir="$CURRENT_WORLD/playerdata"
    
    if [ -d "$playerdata_dir" ]; then
        for player_file in "$playerdata_dir"/*.dat; do
            if [ ! -f "$player_file" ]; then
                continue
            fi
            
            local filename=$(basename "$player_file")
            local player_uuid="${filename%.dat}"
            local player_name=$(get_player_name_from_uuid "$player_uuid")
            local file_mtime=$(stat -f %m "$player_file" 2>/dev/null || stat -c %Y "$player_file" 2>/dev/null || echo 0)
            local last_seen=$(date -r $file_mtime '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date -d "@$file_mtime" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo "未知")
            
            local current_time=$(date +%s)
            local time_diff=$((current_time - file_mtime))
            local is_online="false"
            
            if [ $time_diff -lt 600 ]; then
                is_online="true"
            fi
            
            if [ "$output_format" = "json" ]; then
                all_players+=("{\"name\":\"$player_name\",\"uuid\":\"$player_uuid\",\"last_seen\":\"$last_seen\",\"is_online\":$is_online}")
            else
                local status_icon="🔴"
                if [ "$is_online" = "true" ]; then
                    status_icon="🟢"
                fi
                
                echo -e "$status_icon ${GREEN}$player_name${NC} (UUID: $player_uuid)"
                echo -e "   📅 最後活動: $last_seen"
                echo ""
            fi
        done
    fi
    
    if [ "$output_format" = "json" ]; then
        local players_json=$(IFS=','; echo "[${all_players[*]}]")
        echo "{\"success\": true, \"total_players\": ${#all_players[@]}, \"players\": $players_json}"
    else
        echo -e "${BLUE}📊 總結${NC}"
        echo -e "${GREEN}總玩家數: ${#all_players[@]}${NC}"
    fi
}

# 主程式
case "${1:-info}" in
    "info"|"online")
        get_player_info "${2:-text}"
        ;;
    "json")
        get_player_info "json"
        ;;
    "all")
        get_all_players "${2:-text}"
        ;;
    "all-json")
        get_all_players "json"
        ;;
    "help"|"-h"|"--help")
        echo "使用方式: $0 [指令] [格式]"
        echo ""
        echo "指令:"
        echo "  info, online  顯示線上玩家資訊 (預設)"
        echo "  json          以JSON格式輸出線上玩家資訊"
        echo "  all           顯示所有已知玩家"
        echo "  all-json      以JSON格式輸出所有玩家"
        echo "  help          顯示此說明"
        echo ""
        echo "格式 (針對 info/all 指令):"
        echo "  text          文字格式 (預設)"
        echo "  json          JSON格式"
        ;;
    *)
        echo -e "${RED}❌ 未知指令: $1${NC}"
        echo "使用 '$0 help' 查看可用指令"
        exit 1
        ;;
esac
