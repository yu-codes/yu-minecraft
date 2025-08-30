#!/bin/bash

# world-manager.sh
# 管理和選擇 Minecraft 世界

set -e

# 配置顏色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 專案根目錄
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORLDS_DIR="$PROJECT_ROOT/worlds"
CURRENT_WORLD_LINK="$WORLDS_DIR/current"

# 顯示所有可用世界
list_worlds() {
    echo -e "${BLUE}=== 可用的世界 ===${NC}"
    echo
    
    if [ ! -d "$WORLDS_DIR" ]; then
        echo -e "${RED}錯誤: worlds 目錄不存在${NC}"
        return 1
    fi
    
    local count=0
    for world_dir in "$WORLDS_DIR"/*; do
        if [ -d "$world_dir" ] && [ "$(basename "$world_dir")" != "current" ]; then
            local world_name=$(basename "$world_dir")
            local is_current=""
            
            # 檢查是否為當前世界
            if [ -L "$CURRENT_WORLD_LINK" ] && [ "$(readlink "$CURRENT_WORLD_LINK")" = "$world_name" ]; then
                is_current=" ${GREEN}(當前使用)${NC}"
            fi
            
            # 檢查世界檔案完整性
            if [ -f "$world_dir/level.dat" ]; then
                echo -e "  $((++count)). ${YELLOW}$world_name${NC}$is_current"
                
                # 顯示世界資訊
                local size=$(du -sh "$world_dir" 2>/dev/null | cut -f1)
                local players=$(find "$world_dir/playerdata" -name "*.dat" 2>/dev/null | wc -l)
                echo -e "     大小: $size, 玩家數: $players"
            else
                echo -e "  $((++count)). ${RED}$world_name (不完整)${NC}"
            fi
            echo
        fi
    done
    
    if [ $count -eq 0 ]; then
        echo -e "${YELLOW}沒有找到任何世界目錄${NC}"
        echo -e "${BLUE}提示: 您可以：${NC}"
        echo "1. 從 Aternos 下載世界檔案並解壓到 worlds/world-name/"
        echo "2. 創建新世界: ./world-manager.sh create <world-name>"
        return 1
    fi
}

# 選擇世界
select_world() {
    local world_name="$1"
    
    if [ -z "$world_name" ]; then
        echo -e "${BLUE}請選擇要使用的世界：${NC}"
        list_worlds
        echo
        read -p "輸入世界名稱: " world_name
    fi
    
    local world_path="$WORLDS_DIR/$world_name"
    
    if [ ! -d "$world_path" ]; then
        echo -e "${RED}錯誤: 世界 '$world_name' 不存在${NC}"
        return 1
    fi
    
    if [ ! -f "$world_path/level.dat" ]; then
        echo -e "${RED}錯誤: 世界 '$world_name' 不完整 (缺少 level.dat)${NC}"
        return 1
    fi
    
    # 更新符號連結
    rm -f "$CURRENT_WORLD_LINK"
    ln -s "$world_name" "$CURRENT_WORLD_LINK"
    
    echo -e "${GREEN}✓ 已切換到世界: $world_name${NC}"
    echo -e "${BLUE}現在可以啟動伺服器：${NC}"
    echo "  docker-compose up -d"
    echo "  或 ./scripts/start.sh"
}

# 創建新世界
create_world() {
    local world_name="$1"
    
    if [ -z "$world_name" ]; then
        read -p "請輸入新世界名稱: " world_name
    fi
    
    if [ -z "$world_name" ]; then
        echo -e "${RED}錯誤: 世界名稱不能為空${NC}"
        return 1
    fi
    
    local world_path="$WORLDS_DIR/$world_name"
    
    if [ -d "$world_path" ]; then
        echo -e "${RED}錯誤: 世界 '$world_name' 已存在${NC}"
        return 1
    fi
    
    echo -e "${BLUE}創建新世界: $world_name${NC}"
    mkdir -p "$world_path"
    
    # 選擇是否要自動切換到新世界
    read -p "是否切換到新世界? (y/n) [y]: " switch_to_new
    if [[ "$switch_to_new" =~ ^[Nn]$ ]]; then
        echo -e "${YELLOW}世界已創建，但未切換。請手動添加世界檔案到：${NC}"
        echo "  $world_path"
    else
        select_world "$world_name"
    fi
}

# 匯入 Aternos 世界
import_aternos() {
    local zip_file="$1"
    local world_name="$2"
    
    if [ -z "$zip_file" ]; then
        echo -e "${BLUE}匯入 Aternos 世界${NC}"
        echo "請將下載的 .zip 檔案放在專案根目錄或提供完整路徑"
        echo
        read -p "輸入 zip 檔案路徑: " zip_file
    fi
    
    if [ ! -f "$zip_file" ]; then
        echo -e "${RED}錯誤: 檔案 '$zip_file' 不存在${NC}"
        return 1
    fi
    
    if [ -z "$world_name" ]; then
        # 從檔案名稱推斷世界名稱
        world_name=$(basename "$zip_file" .zip)
        read -p "世界名稱 [$world_name]: " custom_name
        if [ -n "$custom_name" ]; then
            world_name="$custom_name"
        fi
    fi
    
    local world_path="$WORLDS_DIR/$world_name"
    
    if [ -d "$world_path" ]; then
        echo -e "${YELLOW}警告: 世界 '$world_name' 已存在${NC}"
        read -p "是否覆蓋? (y/n) [n]: " overwrite
        if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}匯入已取消${NC}"
            return 1
        fi
        rm -rf "$world_path"
    fi
    
    echo -e "${BLUE}解壓世界檔案...${NC}"
    mkdir -p "$world_path"
    
    cd "$world_path"
    unzip -q "$zip_file"
    
    # 檢查解壓結果
    if [ -f "level.dat" ]; then
        echo -e "${GREEN}✓ 世界檔案匯入成功${NC}"
        
        # 詢問是否切換到新世界
        read -p "是否切換到此世界? (y/n) [y]: " switch_to_imported
        if [[ ! "$switch_to_imported" =~ ^[Nn]$ ]]; then
            cd "$PROJECT_ROOT"
            select_world "$world_name"
        fi
    else
        echo -e "${RED}錯誤: 解壓後未找到 level.dat 檔案${NC}"
        echo -e "${YELLOW}請檢查 zip 檔案格式是否正確${NC}"
        rm -rf "$world_path"
        return 1
    fi
    
    cd "$PROJECT_ROOT"
}

# 刪除世界
delete_world() {
    local world_name="$1"
    
    if [ -z "$world_name" ]; then
        echo -e "${BLUE}選擇要刪除的世界：${NC}"
        list_worlds
        echo
        read -p "輸入世界名稱: " world_name
    fi
    
    if [ -z "$world_name" ]; then
        echo -e "${RED}錯誤: 世界名稱不能為空${NC}"
        return 1
    fi
    
    local world_path="$WORLDS_DIR/$world_name"
    
    if [ ! -d "$world_path" ]; then
        echo -e "${RED}錯誤: 世界 '$world_name' 不存在${NC}"
        return 1
    fi
    
    # 檢查是否為當前世界
    if [ -L "$CURRENT_WORLD_LINK" ] && [ "$(readlink "$CURRENT_WORLD_LINK")" = "$world_name" ]; then
        echo -e "${YELLOW}警告: '$world_name' 是當前使用的世界${NC}"
    fi
    
    echo -e "${RED}危險操作: 即將刪除世界 '$world_name'${NC}"
    echo -e "${YELLOW}此操作無法復原！${NC}"
    read -p "確定要刪除嗎? 請輸入 'DELETE' 確認: " confirmation
    
    if [ "$confirmation" = "DELETE" ]; then
        rm -rf "$world_path"
        
        # 如果刪除的是當前世界，清除符號連結
        if [ -L "$CURRENT_WORLD_LINK" ] && [ "$(readlink "$CURRENT_WORLD_LINK")" = "$world_name" ]; then
            rm -f "$CURRENT_WORLD_LINK"
            echo -e "${YELLOW}已清除當前世界連結，請選擇新的世界${NC}"
        fi
        
        echo -e "${GREEN}✓ 世界 '$world_name' 已刪除${NC}"
    else
        echo -e "${YELLOW}刪除已取消${NC}"
    fi
}

# 顯示當前世界狀態
show_status() {
    echo -e "${BLUE}=== 世界狀態 ===${NC}"
    echo
    
    if [ -L "$CURRENT_WORLD_LINK" ]; then
        local current_world=$(readlink "$CURRENT_WORLD_LINK")
        local world_path="$WORLDS_DIR/$current_world"
        
        if [ -d "$world_path" ]; then
            echo -e "${GREEN}當前世界: $current_world${NC}"
            
            # 顯示世界資訊
            local size=$(du -sh "$world_path" 2>/dev/null | cut -f1)
            local players=$(find "$world_path/playerdata" -name "*.dat" 2>/dev/null | wc -l)
            local last_played=$(stat -f %Sm -t "%Y-%m-%d %H:%M" "$world_path/level.dat" 2>/dev/null || echo "未知")
            
            echo "  大小: $size"
            echo "  玩家數: $players"
            echo "  最後遊玩: $last_played"
            echo "  路徑: $world_path"
        else
            echo -e "${RED}錯誤: 當前世界連結已損壞${NC}"
            echo "  連結目標: $current_world (不存在)"
            rm -f "$CURRENT_WORLD_LINK"
        fi
    else
        echo -e "${YELLOW}沒有設定當前世界${NC}"
        echo -e "${BLUE}使用 './world-manager.sh select' 選擇世界${NC}"
    fi
    
    echo
    
    # 顯示 Docker 狀態
    if command -v docker-compose >/dev/null 2>&1; then
        echo -e "${BLUE}Docker 狀態:${NC}"
        if docker-compose ps minecraft 2>/dev/null | grep -q "Up"; then
            echo -e "${GREEN}  ✓ Minecraft 伺服器正在運行${NC}"
        else
            echo -e "${YELLOW}  ○ Minecraft 伺服器已停止${NC}"
        fi
    fi
}

# 顯示使用說明
show_help() {
    cat << EOF
${BLUE}Minecraft 世界管理工具${NC}

用法:
  $0 list                     # 列出所有世界
  $0 select [世界名稱]         # 選擇要使用的世界
  $0 create [世界名稱]         # 創建新世界
  $0 import [zip檔案] [世界名稱] # 匯入 Aternos 世界
  $0 delete [世界名稱]         # 刪除世界
  $0 status                   # 顯示當前狀態
  $0 --help                   # 顯示此說明

範例:
  $0 import world.zip my-world    # 匯入 Aternos 下載的世界
  $0 select my-world              # 切換到指定世界
  $0 create survival-world        # 創建新的生存世界

世界目錄結構:
worlds/
├── current -> default          # 當前使用的世界 (符號連結)
├── default/                    # 預設世界
├── my-aternos-world/          # 從 Aternos 匯入的世界
└── creative-world/            # 其他世界

EOF
}

# 主要執行邏輯
main() {
    local command="${1:-list}"
    
    case "$command" in
        "list" | "ls")
            list_worlds
            ;;
        "select" | "use")
            select_world "$2"
            ;;
        "create" | "new")
            create_world "$2"
            ;;
        "import" | "add")
            import_aternos "$2" "$3"
            ;;
        "delete" | "remove" | "rm")
            delete_world "$2"
            ;;
        "status" | "info")
            show_status
            ;;
        "--help" | "-h" | "help")
            show_help
            ;;
        *)
            echo -e "${RED}無效的命令: $command${NC}"
            show_help
            exit 1
            ;;
    esac
}

# 執行主程序
main "$@"
