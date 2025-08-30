#!/bin/bash

# Yu Minecraft Server 整合管理腳本 v2.0
# 統一世界管理與伺服器控制
# 作者: Yu-codes

set -e

# 配置
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORLDS_DIR="$PROJECT_ROOT/worlds"
SCRIPTS_DIR="$PROJECT_ROOT/scripts"
DOCKER_COMPOSE_FILE="$PROJECT_ROOT/docker/docker-compose.yml"

# 顏色設定
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 顯示標題
show_title() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              Yu Minecraft Server 管理中心 v2.0               ║"
    echo "║                   統一世界管理系統                           ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# 檢查腳本是否存在並執行
run_script() {
    local script_path="$1"
    shift
    
    if [ -f "$script_path" ] && [ -x "$script_path" ]; then
        echo -e "${BLUE}執行: $(basename "$script_path")${NC}"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        "$script_path" "$@"
    else
        echo -e "${RED}錯誤: 腳本 $script_path 不存在或沒有執行權限${NC}"
    fi
}

# 顯示主選單
show_main_menu() {
    echo -e "${BLUE}📋 主選單${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${GREEN}🌍 世界管理${NC}"
    echo "  1) 查看世界列表"
    echo "  2) 選擇/切換世界"  
    echo "  3) 查看當前世界狀態"
    echo "  4) 配置檔案管理"
    echo ""
    echo -e "${GREEN}🚀 伺服器管理${NC}"
    echo "  5) 啟動伺服器"
    echo "  6) 停止伺服器"
    echo "  7) 重啟伺服器"
    echo "  8) 查看伺服器狀態"
    echo "  9) 容器管理"
    echo ""
    echo -e "${YELLOW}📊 監控與效能${NC}"
    echo " 10) 即時監控"
    echo " 11) 效能分析"
    echo " 12) 執行效能最佳化"
    echo ""
    echo -e "${PURPLE}🔌 外掛管理${NC}"
    echo " 13) 外掛管理選單"
    echo ""
    echo -e "${CYAN}💾 備份與維護${NC}"
    echo " 14) 備份當前世界"
    echo " 15) 查看備份列表"
    echo ""
    echo -e "${RED}🌐 網路管理${NC}"
    echo " 16) 啟動Web管理介面"
    echo " 17) 網路連線設定"
    echo ""
    echo " 0) 退出"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# 外掛管理選單
plugin_menu() {
    while true; do
        echo ""
        echo -e "${PURPLE}🔌 外掛管理選單${NC}"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "1) 查看已安裝外掛"
        echo "2) 查看推薦外掛"
        echo "3) 下載外掛"
        echo "4) 移除外掛"
        echo "5) 備份外掛"
        echo "6) 檢查外掛依賴"
        echo "7) 安裝基本外掛套件"
        echo "0) 返回主選單"
        echo ""
        read -p "請選擇操作 [0-7]: " plugin_choice
        
        case $plugin_choice in
            1) run_script "$SCRIPTS_DIR/management/plugins.sh" list ;;
            2) run_script "$SCRIPTS_DIR/management/plugins.sh" recommended ;;
            3) 
                read -p "請輸入外掛名稱: " plugin_name
                run_script "$SCRIPTS_DIR/management/plugins.sh" download "$plugin_name"
                ;;
            4)
                read -p "請輸入要移除的外掛名稱: " plugin_name
                run_script "$SCRIPTS_DIR/management/plugins.sh" remove "$plugin_name"
                ;;
            5) run_script "$SCRIPTS_DIR/management/plugins.sh" backup ;;
            6) run_script "$SCRIPTS_DIR/management/plugins.sh" check ;;
            7) run_script "$SCRIPTS_DIR/management/plugins.sh" essentials ;;
            0) break ;;
            *) echo -e "${RED}❌ 無效選項${NC}" ;;
        esac
        
        echo ""
        read -p "按Enter繼續..."
    done
}

# 網路管理選單
network_menu() {
    while true; do
        echo ""
        echo -e "${RED}🌐 網路管理選單${NC}"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "1) Ngrok 隧道"
        echo "2) 固定IP連線"
        echo "3) Oracle Cloud 連線"
        echo "4) Playit.gg 隧道"
        echo "5) Serveo 隧道"
        echo "6) Tailscale VPN"
        echo "0) 返回主選單"
        echo ""
        read -p "請選擇操作 [0-6]: " network_choice
        
        case $network_choice in
            1) run_script "$SCRIPTS_DIR/network/remote-connect-ngrok.sh" ;;
            2) run_script "$SCRIPTS_DIR/network/remote-connect-fixed-ip.sh" ;;
            3) run_script "$SCRIPTS_DIR/network/remote-connect-oracle.sh" ;;
            4) run_script "$SCRIPTS_DIR/network/remote-connect-playit.sh" ;;
            5) run_script "$SCRIPTS_DIR/network/remote-connect-serveo.sh" ;;
            6) run_script "$SCRIPTS_DIR/network/remote-connect-tailscale.sh" ;;
            0) break ;;
            *) echo -e "${RED}❌ 無效選項${NC}" ;;
        esac
        
        echo ""
        read -p "按Enter繼續..."
    done
}

# 主程式循環
main() {
    while true; do
        show_title
        show_main_menu
        
        read -p "請選擇操作 [0-17]: " choice
        
        echo ""
        
        case $choice in
            # 🌍 世界管理
            1) run_script "$SCRIPTS_DIR/world/list.sh" ;;
            2) run_script "$SCRIPTS_DIR/world/select.sh" ;;
            3) run_script "$SCRIPTS_DIR/world/status.sh" ;;
            4) run_script "$SCRIPTS_DIR/world/config.sh" ;;
            
            # 🚀 伺服器管理
            5) run_script "$SCRIPTS_DIR/server/start.sh" ;;
            6) run_script "$SCRIPTS_DIR/server/stop.sh" ;;
            7) 
                run_script "$SCRIPTS_DIR/server/stop.sh"
                sleep 3
                run_script "$SCRIPTS_DIR/server/start.sh"
                ;;
            8) 
                echo -e "${BLUE}📊 伺服器狀態${NC}"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                cd "$PROJECT_ROOT"
                if command -v docker-compose >/dev/null 2>&1; then
                    docker-compose -f docker/docker-compose.yml ps
                elif command -v docker >/dev/null 2>&1; then
                    docker compose -f docker/docker-compose.yml ps
                else
                    echo -e "${RED}Docker 未安裝${NC}"
                fi
                ;;
            9) run_script "$SCRIPTS_DIR/server/container.sh" ;;
            
            # 📊 監控與效能
            10) 
                echo -e "${YELLOW}📊 啟動即時監控${NC}"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo -e "${BLUE}按 Ctrl+C 或 'q' 停止監控並返回選單${NC}"
                run_script "$SCRIPTS_DIR/monitoring/monitor.sh" continuous
                ;;
            11) 
                echo -e "${YELLOW}📈 效能分析選單${NC}"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "1) 生成效能報告"
                echo "2) 即時效能監控 (可按 q 退出)"
                echo "3) 匯出效能資料"
                echo "0) 返回主選單"
                echo ""
                read -p "請選擇操作 [0-3]: " perf_choice
                
                case $perf_choice in
                    1) run_script "$SCRIPTS_DIR/monitoring/performance.sh" report ;;
                    2) run_script "$SCRIPTS_DIR/monitoring/performance.sh" monitor ;;
                    3) run_script "$SCRIPTS_DIR/monitoring/performance.sh" export ;;
                    0) echo "返回主選單" ;;
                    *) echo -e "${RED}❌ 無效選項${NC}" ;;
                esac
                ;;
            12) 
                echo -e "${YELLOW}⚡ 執行系統最佳化${NC}"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                run_script "$SCRIPTS_DIR/monitoring/optimize.sh" all
                ;;
            
            # 🔌 外掛管理
            13) plugin_menu ;;
            
            # 💾 備份與維護
            14) run_script "$SCRIPTS_DIR/backup/backup.sh" ;;
            15) 
                echo -e "${BLUE}📋 備份列表${NC}"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                ls -la backups/ 2>/dev/null || echo "尚無備份檔案"
                ;;
            
            # 🌐 網路管理
            16) run_script "$SCRIPTS_DIR/network/start-web-simple.sh" ;;
            17) network_menu ;;
            
            0)
                echo -e "${GREEN}👋 感謝使用 Yu Minecraft Server 管理系統！${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ 無效選項，請重新選擇${NC}"
                ;;
        esac
        
        if [ $choice -ne 13 ] && [ $choice -ne 17 ]; then
            echo ""
            read -p "按Enter繼續..."
        fi
    done
}

# 外掛管理選單
plugin_menu() {
    local current_world=""
    if [ -L "$WORLDS_DIR/current" ]; then
        current_world=$(basename "$(readlink "$WORLDS_DIR/current")")
    fi
    
    while true; do
        echo ""
        echo -e "${PURPLE}🔌 外掛管理選單${NC}"
        if [ -n "$current_world" ]; then
            echo -e "${BLUE}當前世界: $current_world (世界特定外掛)${NC}"
        else
            echo -e "${YELLOW}⚠️ 未選擇世界 (全域外掛管理)${NC}"
        fi
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "1) 查看已安裝外掛"
        echo "2) 瀏覽可用外掛"
        echo "3) 安裝外掛"
        echo "4) 移除外掛"
        echo "5) 備份外掛"
        echo "6) 檢查外掛相依性"
        echo "7) 安裝基本外掛套件"
        echo "8) 世界外掛管理 (世界特定功能)"
        echo "0) 返回主選單"
        echo ""
        read -p "請選擇操作 [0-8]: " plugin_choice
        
        case $plugin_choice in
            1) run_script "$SCRIPTS_DIR/plugins/plugins.sh" list ;;
            2) run_script "$SCRIPTS_DIR/plugins/plugins.sh" browse ;;
            3) 
                echo "可用外掛："
                run_script "$SCRIPTS_DIR/plugins/plugins.sh" browse
                echo
                read -p "請輸入要安裝的外掛名稱: " plugin_name
                if [ -n "$plugin_name" ]; then
                    run_script "$SCRIPTS_DIR/plugins/plugins.sh" install "$plugin_name"
                fi
                ;;
            4)
                echo "已安裝外掛："
                run_script "$SCRIPTS_DIR/plugins/plugins.sh" list
                echo
                read -p "請輸入要移除的外掛名稱: " plugin_name
                if [ -n "$plugin_name" ]; then
                    run_script "$SCRIPTS_DIR/plugins/plugins.sh" remove "$plugin_name"
                fi
                ;;
            5) run_script "$SCRIPTS_DIR/plugins/plugins.sh" backup ;;
            6) run_script "$SCRIPTS_DIR/plugins/plugins.sh" check ;;
            7) run_script "$SCRIPTS_DIR/plugins/plugins.sh" essentials ;;
            8) 
                if [ -n "$current_world" ]; then
                    run_script "$SCRIPTS_DIR/world/plugins.sh" list
                else
                    echo -e "${RED}❌ 請先選擇世界${NC}"
                fi
                ;;
            0) break ;;
            *) echo -e "${RED}❌ 無效選項${NC}" ;;
        esac
        
        echo ""
        read -p "按Enter繼續..."
    done
}

# 網路管理選單
network_menu() {
    while true; do
        echo ""
        echo -e "${RED}🌐 網路管理選單${NC}"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "1) Ngrok 隧道"
        echo "2) 固定IP連線"
        echo "3) Oracle Cloud 連線"
        echo "4) Playit.gg 隧道"
        echo "5) Serveo 隧道"
        echo "6) Tailscale VPN"
        echo "0) 返回主選單"
        echo ""
        read -p "請選擇操作 [0-6]: " network_choice
        
        case $network_choice in
            1) run_script "$SCRIPTS_DIR/network/remote-connect-ngrok.sh" ;;
            2) run_script "$SCRIPTS_DIR/network/remote-connect-fixed-ip.sh" ;;
            3) run_script "$SCRIPTS_DIR/network/remote-connect-oracle.sh" ;;
            4) run_script "$SCRIPTS_DIR/network/remote-connect-playit.sh" ;;
            5) run_script "$SCRIPTS_DIR/network/remote-connect-serveo.sh" ;;
            6) run_script "$SCRIPTS_DIR/network/remote-connect-tailscale.sh" ;;
            0) break ;;
            *) echo -e "${RED}❌ 無效選項${NC}" ;;
        esac
        
        echo ""
        read -p "按Enter繼續..."
    done
}

# 檢查是否在正確的目錄
if [ ! -f "README.md" ] || [ ! -d "scripts" ]; then
    echo -e "${RED}❌ 請在專案根目錄執行此腳本${NC}"
    exit 1
fi

# 檢查必要目錄
if [ ! -d "$WORLDS_DIR" ]; then
    echo -e "${YELLOW}⚠️ worlds 目錄不存在，正在建立...${NC}"
    mkdir -p "$WORLDS_DIR/default"
    ln -s default "$WORLDS_DIR/current"
    echo -e "${GREEN}✅ 已建立預設世界目錄${NC}"
fi

# 啟動主程式
main
