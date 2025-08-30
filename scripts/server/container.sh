#!/bin/bash

# Yu Minecraft Server 容器管理腳本
# 作者: Yu-codes
# 用於管理 Docker 容器的生命週期

set -e

# 配置
PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CONTAINER_NAME="yu-minecraft-server"

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 檢查 Docker 環境
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker 未安裝${NC}"
        echo "請先安裝 Docker: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    if ! docker compose version &> /dev/null; then
        echo -e "${RED}❌ Docker Compose 未安裝或版本過舊${NC}"
        echo "請安裝 Docker Compose V2"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        echo -e "${RED}❌ Docker 服務未運行${NC}"
        echo "請啟動 Docker 服務"
        exit 1
    fi
}

# 獲取容器狀態
get_container_status() {
    if docker ps -a --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
        if docker ps --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
            echo "running"
        else
            echo "stopped"
        fi
    else
        echo "not_exists"
    fi
}

# 顯示容器詳細信息
show_container_info() {
    local status=$(get_container_status)
    
    echo -e "${CYAN}🐳 容器狀態報告${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    case $status in
        "running")
            echo -e "${GREEN}✅ 容器正在運行${NC}"
            echo ""
            echo "📊 容器詳細信息:"
            docker ps --filter "name=${CONTAINER_NAME}" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.Image}}"
            
            echo ""
            echo "💾 資源使用情況:"
            docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}" ${CONTAINER_NAME}
            
            echo ""
            echo "🌐 網路端口:"
            docker port ${CONTAINER_NAME} 2>/dev/null || echo "無端口映射信息"
            ;;
        "stopped")
            echo -e "${YELLOW}⏸️ 容器已停止${NC}"
            echo ""
            echo "📊 容器信息:"
            docker ps -a --filter "name=${CONTAINER_NAME}" --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"
            ;;
        "not_exists")
            echo -e "${RED}❌ 容器不存在${NC}"
            ;;
    esac
}

# 創建新容器
create_container() {
    echo -e "${BLUE}🔨 創建新容器...${NC}"
    
    cd "$PROJECT_ROOT/docker"
    
    # 檢查配置文件
    if [ ! -f "docker-compose.yml" ]; then
        echo -e "${RED}❌ docker-compose.yml 不存在${NC}"
        exit 1
    fi
    
    # 確保必要目錄存在
    mkdir -p "$PROJECT_ROOT"/{worlds,config,logs}
    
    # 建構並啟動
    echo "📦 建構 Docker 映像..."
    docker compose build minecraft
    
    echo "🚀 啟動容器..."
    docker compose up -d minecraft
    
    # 等待啟動
    echo "⏳ 等待容器啟動..."
    sleep 10
    
    if [ "$(get_container_status)" = "running" ]; then
        echo -e "${GREEN}✅ 容器創建並啟動成功${NC}"
    else
        echo -e "${RED}❌ 容器創建失敗${NC}"
        echo "查看錯誤日誌:"
        docker compose logs minecraft --tail 20
        exit 1
    fi
}

# 重建容器
rebuild_container() {
    echo -e "${YELLOW}🔄 重建容器...${NC}"
    
    cd "$PROJECT_ROOT/docker"
    
    # 停止並移除現有容器
    echo "🛑 停止現有容器..."
    docker compose down
    
    # 移除映像（可選）
    read -p "是否要重建 Docker 映像? (Y/n): " rebuild_image
    if [[ ! "$rebuild_image" =~ ^[Nn]$ ]]; then
        echo "🗑️ 移除舊映像..."
        docker compose down --rmi local 2>/dev/null || true
    fi
    
    # 創建新容器
    create_container
}

# 啟動容器
start_container() {
    local status=$(get_container_status)
    
    case $status in
        "running")
            echo -e "${GREEN}✅ 容器已在運行${NC}"
            ;;
        "stopped")
            echo -e "${BLUE}🚀 啟動容器...${NC}"
            cd "$PROJECT_ROOT/docker"
            docker compose start minecraft
            
            sleep 5
            if [ "$(get_container_status)" = "running" ]; then
                echo -e "${GREEN}✅ 容器啟動成功${NC}"
            else
                echo -e "${RED}❌ 容器啟動失敗${NC}"
                docker compose logs minecraft --tail 10
            fi
            ;;
        "not_exists")
            echo -e "${YELLOW}⚠️ 容器不存在，創建新容器...${NC}"
            create_container
            ;;
    esac
}

# 停止容器
stop_container() {
    local status=$(get_container_status)
    
    if [ "$status" = "running" ]; then
        echo -e "${YELLOW}🛑 停止容器...${NC}"
        cd "$PROJECT_ROOT/docker"
        docker compose stop minecraft
        echo -e "${GREEN}✅ 容器已停止${NC}"
    elif [ "$status" = "stopped" ]; then
        echo -e "${BLUE}ℹ️ 容器已經停止${NC}"
    else
        echo -e "${RED}❌ 容器不存在${NC}"
    fi
}

# 重啟容器
restart_container() {
    local status=$(get_container_status)
    
    if [ "$status" != "not_exists" ]; then
        echo -e "${BLUE}🔄 重啟容器...${NC}"
        cd "$PROJECT_ROOT/docker"
        docker compose restart minecraft
        
        sleep 5
        if [ "$(get_container_status)" = "running" ]; then
            echo -e "${GREEN}✅ 容器重啟成功${NC}"
        else
            echo -e "${RED}❌ 容器重啟失敗${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️ 容器不存在，創建新容器...${NC}"
        create_container
    fi
}

# 移除容器
remove_container() {
    echo -e "${RED}⚠️ 即將移除容器${NC}"
    echo "這將停止並刪除容器，但不會刪除世界數據"
    read -p "確定要移除容器嗎? (y/N): " confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        cd "$PROJECT_ROOT/docker"
        docker compose down
        echo -e "${GREEN}✅ 容器已移除${NC}"
    else
        echo -e "${BLUE}ℹ️ 操作已取消${NC}"
    fi
}

# 查看容器日誌
show_logs() {
    local status=$(get_container_status)
    
    if [ "$status" != "not_exists" ]; then
        echo -e "${BLUE}📜 容器日誌 (最近 50 行):${NC}"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        cd "$PROJECT_ROOT/docker"
        docker compose logs minecraft --tail 50
    else
        echo -e "${RED}❌ 容器不存在${NC}"
    fi
}

# 進入容器 shell
enter_container() {
    local status=$(get_container_status)
    
    if [ "$status" = "running" ]; then
        echo -e "${BLUE}🔍 進入容器 shell...${NC}"
        docker exec -it ${CONTAINER_NAME} /bin/bash
    else
        echo -e "${RED}❌ 容器未運行${NC}"
    fi
}

# 顯示幫助
show_help() {
    echo -e "${CYAN}🐳 Yu Minecraft 容器管理工具${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "用法: $0 [命令]"
    echo ""
    echo "可用命令:"
    echo "  status    - 顯示容器狀態"
    echo "  create    - 創建新容器"
    echo "  start     - 啟動容器"
    echo "  stop      - 停止容器"
    echo "  restart   - 重啟容器"
    echo "  rebuild   - 重建容器"
    echo "  remove    - 移除容器"
    echo "  logs      - 查看容器日誌"
    echo "  shell     - 進入容器 shell"
    echo "  help      - 顯示此幫助信息"
}

# 主程式
check_docker

case "${1:-status}" in
    "status"|"info")
        show_container_info
        ;;
    "create"|"new")
        create_container
        ;;
    "start"|"up")
        start_container
        ;;
    "stop"|"down")
        stop_container
        ;;
    "restart"|"reboot")
        restart_container
        ;;
    "rebuild"|"recreate")
        rebuild_container
        ;;
    "remove"|"rm"|"delete")
        remove_container
        ;;
    "logs"|"log")
        show_logs
        ;;
    "shell"|"bash"|"exec")
        enter_container
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        echo -e "${RED}❌ 未知命令: $1${NC}"
        echo "使用 '$0 help' 查看可用命令"
        exit 1
        ;;
esac
