#!/bin/bash

# Yu Minecraft Server 整合管理腳本
# 作者: Yu-codes
# 日期: 2023

set -e

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
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                Yu Minecraft Server 管理中心                  ║"
    echo "║                     整合管理系統 v1.0                        ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# 顯示主選單
show_main_menu() {
    echo -e "${BLUE}📋 主選單${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${GREEN}🚀 伺服器管理${NC}"
    echo "  1) 啟動伺服器"
    echo "  2) 停止伺服器"
    echo "  3) 重啟伺服器"
    echo "  4) 查看伺服器狀態"
    echo ""
    echo -e "${YELLOW}📊 監控與效能${NC}"
    echo "  5) 即時監控"
    echo "  6) 效能分析"
    echo "  7) 執行效能最佳化"
    echo "  8) 查看監控記錄"
    echo ""
    echo -e "${PURPLE}🔌 外掛管理${NC}"
    echo "  9) 查看已安裝外掛"
    echo " 10) 安裝推薦外掛"
    echo " 11) 外掛管理選單"
    echo ""
    echo -e "${CYAN}💾 備份與維護${NC}"
    echo " 12) 備份世界"
    echo " 13) 查看備份列表"
    echo " 14) 系統維護"
    echo ""
    echo -e "${RED}🔧 高級功能${NC}"
    echo " 15) Web管理介面"
    echo " 16) 快速部署"
    echo " 17) 完整系統檢查"
    echo ""
    echo " 0) 退出"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# 伺服器管理功能
server_management() {
    case $1 in
        1)
            echo -e "${GREEN}🚀 啟動伺服器...${NC}"
            ./scripts/start.sh
            ;;
        2)
            echo -e "${YELLOW}🛑 停止伺服器...${NC}"
            ./scripts/stop.sh
            ;;
        3)
            echo -e "${BLUE}🔄 重啟伺服器...${NC}"
            ./scripts/stop.sh
            sleep 5
            ./scripts/start.sh
            ;;
        4)
            echo -e "${CYAN}📊 伺服器狀態${NC}"
            ./scripts/monitor.sh once
            ;;
    esac
}

# 監控與效能功能
monitoring_performance() {
    case $1 in
        5)
            echo -e "${GREEN}🔍 啟動即時監控 (按Ctrl+C停止)${NC}"
            ./scripts/monitor.sh continuous
            ;;
        6)
            echo -e "${BLUE}📈 效能分析${NC}"
            ./scripts/performance.sh report
            ;;
        7)
            echo -e "${YELLOW}⚡ 執行效能最佳化${NC}"
            ./scripts/optimize.sh all
            ;;
        8)
            echo -e "${PURPLE}📜 監控記錄${NC}"
            ./scripts/monitor.sh logs
            ;;
    esac
}

# 外掛管理功能
plugin_management() {
    case $1 in
        9)
            echo -e "${GREEN}🔌 已安裝外掛${NC}"
            ./scripts/plugins.sh list
            ;;
        10)
            echo -e "${BLUE}📦 安裝推薦外掛${NC}"
            ./scripts/plugins.sh essentials
            ;;
        11)
            plugin_menu
            ;;
    esac
}

# 外掛管理子選單
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
            1) ./scripts/plugins.sh list ;;
            2) ./scripts/plugins.sh recommended ;;
            3) 
                read -p "請輸入外掛名稱: " plugin_name
                ./scripts/plugins.sh download "$plugin_name"
                ;;
            4)
                read -p "請輸入要移除的外掛名稱: " plugin_name
                ./scripts/plugins.sh remove "$plugin_name"
                ;;
            5) ./scripts/plugins.sh backup ;;
            6) ./scripts/plugins.sh check ;;
            7) ./scripts/plugins.sh essentials ;;
            0) break ;;
            *) echo -e "${RED}❌ 無效選項${NC}" ;;
        esac
        
        echo ""
        read -p "按Enter繼續..."
    done
}

# 備份與維護功能
backup_maintenance() {
    case $1 in
        12)
            echo -e "${GREEN}💾 備份世界${NC}"
            ./scripts/backup.sh
            ;;
        13)
            echo -e "${BLUE}📋 備份列表${NC}"
            ls -la backups/ 2>/dev/null || echo "尚無備份檔案"
            ;;
        14)
            maintenance_menu
            ;;
    esac
}

# 維護選單
maintenance_menu() {
    while true; do
        echo ""
        echo -e "${CYAN}🔧 系統維護選單${NC}"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "1) 清理記錄檔案"
        echo "2) 清理舊備份"
        echo "3) 重建Docker映像檔"
        echo "4) 清理Docker快取"
        echo "5) 檢查磁碟空間"
        echo "6) 系統資源監控"
        echo "0) 返回主選單"
        echo ""
        read -p "請選擇操作 [0-6]: " maintenance_choice
        
        case $maintenance_choice in
            1)
                echo "🧹 清理記錄檔案..."
                find logs/ -name "*.log" -mtime +7 -delete 2>/dev/null || true
                echo "✅ 記錄檔案清理完成"
                ;;
            2)
                echo "🧹 清理舊備份..."
                find backups/ -name "*.tar.gz" -mtime +30 -delete 2>/dev/null || true
                echo "✅ 舊備份清理完成"
                ;;
            3)
                echo "🐳 重建Docker映像檔..."
                cd docker
                docker-compose build --no-cache
                cd ..
                ;;
            4)
                echo "🧹 清理Docker快取..."
                docker system prune -f
                ;;
            5)
                echo "💽 磁碟空間使用情況:"
                df -h
                ;;
            6)
                ./scripts/monitor.sh once
                ;;
            0) break ;;
            *) echo -e "${RED}❌ 無效選項${NC}" ;;
        esac
        
        echo ""
        read -p "按Enter繼續..."
    done
}

# 高級功能
advanced_features() {
    case $1 in
        15)
            echo -e "${GREEN}🌐 開啟Web管理介面${NC}"
            echo "Web管理介面位址: http://localhost:8080"
            if command -v open &> /dev/null; then
                open http://localhost:8080
            elif command -v xdg-open &> /dev/null; then
                xdg-open http://localhost:8080
            fi
            ;;
        16)
            echo -e "${BLUE}🚀 執行快速部署${NC}"
            ./deploy.sh
            ;;
        17)
            system_check
            ;;
    esac
}

# 完整系統檢查
system_check() {
    echo -e "${YELLOW}🔍 執行完整系統檢查...${NC}"
    echo ""
    
    echo "1. 檢查Docker環境..."
    if command -v docker &> /dev/null; then
        echo -e "   ${GREEN}✅ Docker已安裝${NC}"
        docker --version
    else
        echo -e "   ${RED}❌ Docker未安裝${NC}"
    fi
    
    echo ""
    echo "2. 檢查Docker Compose..."
    if command -v docker-compose &> /dev/null; then
        echo -e "   ${GREEN}✅ Docker Compose已安裝${NC}"
        docker-compose --version
    else
        echo -e "   ${RED}❌ Docker Compose未安裝${NC}"
    fi
    
    echo ""
    echo "3. 檢查檔案結構..."
    required_files=(
        "docker/Dockerfile"
        "docker/docker-compose.yml"
        "config/server.properties"
        "scripts/start.sh"
        "scripts/stop.sh"
        "scripts/backup.sh"
    )
    
    for file in "${required_files[@]}"; do
        if [ -f "$file" ]; then
            echo -e "   ${GREEN}✅ $file${NC}"
        else
            echo -e "   ${RED}❌ $file${NC}"
        fi
    done
    
    echo ""
    echo "4. 檢查伺服器狀態..."
    ./scripts/monitor.sh once
    
    echo ""
    echo "5. 檢查系統資源..."
    ./scripts/optimize.sh check
}

# 主程式循環
main() {
    while true; do
        clear
        show_title
        show_main_menu
        
        read -p "請選擇操作 [0-17]: " choice
        
        echo ""
        
        case $choice in
            1|2|3|4) server_management $choice ;;
            5|6|7|8) monitoring_performance $choice ;;
            9|10|11) plugin_management $choice ;;
            12|13|14) backup_maintenance $choice ;;
            15|16|17) advanced_features $choice ;;
            0)
                echo -e "${GREEN}👋 感謝使用 Yu Minecraft Server 管理系統！${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ 無效選項，請重新選擇${NC}"
                ;;
        esac
        
        if [ $choice -ne 11 ] && [ $choice -ne 14 ]; then
            echo ""
            read -p "按Enter繼續..."
        fi
    done
}

# 檢查是否在正確的目錄
if [ ! -f "README.md" ] || [ ! -d "scripts" ]; then
    echo -e "${RED}❌ 請在專案根目錄執行此腳本${NC}"
    exit 1
fi

# 啟動主程式
main
