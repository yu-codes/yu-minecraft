#!/bin/bash

# 配置檔案管理腳本
# 用於處理全域和世界特定的配置檔案

set -e

# 配置
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WORLDS_DIR="$PROJECT_ROOT/worlds"
CONFIG_DIR="$PROJECT_ROOT/config"
GLOBAL_CONFIG_DIR="$CONFIG_DIR/global"
EXAMPLES_DIR="$CONFIG_DIR/examples"

# 顏色設定
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 獲取當前世界
get_current_world() {
    if [ -L "$WORLDS_DIR/current" ]; then
        readlink "$WORLDS_DIR/current"
    else
        echo ""
    fi
}

# 載入配置檔案 (按優先級)
load_config() {
    local config_name="$1"
    local current_world=$(get_current_world)
    
    if [ -n "$current_world" ] && [ -f "$WORLDS_DIR/$current_world/$config_name" ]; then
        echo "$WORLDS_DIR/$current_world/$config_name"
    elif [ -f "$GLOBAL_CONFIG_DIR/$config_name" ]; then
        echo "$GLOBAL_CONFIG_DIR/$config_name"
    elif [ -f "$EXAMPLES_DIR/${config_name}.example" ]; then
        echo "$EXAMPLES_DIR/${config_name}.example"
    else
        echo ""
    fi
}

# 複製範例配置到世界目錄
copy_config_to_world() {
    local world_name="$1"
    local config_name="$2"
    
    if [ ! -d "$WORLDS_DIR/$world_name" ]; then
        echo -e "${RED}錯誤: 世界 '$world_name' 不存在${NC}"
        return 1
    fi
    
    local source_config=$(load_config "$config_name")
    if [ -z "$source_config" ]; then
        echo -e "${RED}錯誤: 找不到配置檔案 '$config_name'${NC}"
        return 1
    fi
    
    cp "$source_config" "$WORLDS_DIR/$world_name/$config_name"
    echo -e "${GREEN}✅ 已複製 $config_name 到世界 $world_name${NC}"
}

# 顯示配置檔案狀態
show_config_status() {
    local current_world=$(get_current_world)
    
    echo -e "${BLUE}📋 配置檔案狀態${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [ -n "$current_world" ]; then
        echo -e "${GREEN}當前世界: $current_world${NC}"
        echo
        
        # 檢查各種配置檔案
        local configs=("world.env" "server.properties" "ops.json" "whitelist.json")
        
        for config in "${configs[@]}"; do
            local active_config=$(load_config "$config")
            echo -n "📄 $config: "
            
            if [ -f "$WORLDS_DIR/$current_world/$config" ]; then
                echo -e "${GREEN}世界專屬${NC} ($WORLDS_DIR/$current_world/$config)"
            elif [ -f "$GLOBAL_CONFIG_DIR/$config" ]; then
                echo -e "${YELLOW}全域設定${NC} ($GLOBAL_CONFIG_DIR/$config)"
            elif [ -f "$EXAMPLES_DIR/${config}.example" ]; then
                echo -e "${BLUE}範例檔案${NC} ($EXAMPLES_DIR/${config}.example)"
            else
                echo -e "${RED}未找到${NC}"
            fi
        done
    else
        echo -e "${RED}沒有設定當前世界${NC}"
    fi
}

# 創建世界專屬配置
create_world_config() {
    local current_world=$(get_current_world)
    
    if [ -z "$current_world" ]; then
        echo -e "${RED}錯誤: 沒有設定當前世界${NC}"
        return 1
    fi
    
    echo -e "${BLUE}為世界 '$current_world' 創建專屬配置${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # 創建 world.env
    cat > "$WORLDS_DIR/$current_world/world.env" << EOF
# $current_world 世界專屬環境變數
# 這些設定會覆蓋全域設定

# 遊戲模式設定
GAMEMODE=survival
DIFFICULTY=normal
MAX_PLAYERS=20

# 世界特殊設定
PVP=true
ALLOW_NETHER=true
SPAWN_PROTECTION=16

# 伺服器名稱
SERVER_NAME=$current_world Minecraft Server
EOF
    
    echo -e "${GREEN}✅ 已創建 world.env${NC}"
    
    # 詢問是否複製其他配置檔案
    echo
    echo "是否要複製其他配置檔案到這個世界？"
    echo "1) server.properties"
    echo "2) ops.json"  
    echo "3) whitelist.json"
    echo "4) 全部複製"
    echo "0) 跳過"
    
    read -p "請選擇 [0-4]: " choice
    
    case $choice in
        1) copy_config_to_world "$current_world" "server.properties" ;;
        2) copy_config_to_world "$current_world" "ops.json" ;;
        3) copy_config_to_world "$current_world" "whitelist.json" ;;
        4)
            copy_config_to_world "$current_world" "server.properties"
            copy_config_to_world "$current_world" "ops.json"
            copy_config_to_world "$current_world" "whitelist.json"
            ;;
        0) echo "已跳過" ;;
    esac
}

# 主選單
show_menu() {
    echo -e "${BLUE}⚙️ 配置檔案管理${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "1) 查看配置狀態"
    echo "2) 創建世界專屬配置"
    echo "3) 複製配置到當前世界"
    echo "4) 查看配置檔案內容"
    echo "0) 退出"
    echo
}

# 主程序
main() {
    if [ $# -eq 0 ]; then
        while true; do
            show_menu
            read -p "請選擇操作 [0-4]: " choice
            echo
            
            case $choice in
                1) show_config_status ;;
                2) create_world_config ;;
                3)
                    read -p "請輸入配置檔案名稱: " config_name
                    current_world=$(get_current_world)
                    if [ -n "$current_world" ]; then
                        copy_config_to_world "$current_world" "$config_name"
                    else
                        echo -e "${RED}錯誤: 沒有設定當前世界${NC}"
                    fi
                    ;;
                4)
                    read -p "請輸入配置檔案名稱: " config_name
                    config_path=$(load_config "$config_name")
                    if [ -n "$config_path" ]; then
                        echo -e "${BLUE}📄 $config_path${NC}"
                        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                        cat "$config_path"
                    else
                        echo -e "${RED}找不到配置檔案 '$config_name'${NC}"
                    fi
                    ;;
                0) exit 0 ;;
                *) echo -e "${RED}無效選項${NC}" ;;
            esac
            
            echo
            read -p "按Enter繼續..."
            echo
        done
    else
        # 命令行模式
        case "$1" in
            "status") show_config_status ;;
            "create") create_world_config ;;
            "load") load_config "$2" ;;
            *) 
                echo "用法: $0 [status|create|load <config_name>]"
                exit 1
                ;;
        esac
    fi
}

main "$@"
