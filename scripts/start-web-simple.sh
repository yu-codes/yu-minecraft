#!/bin/bash

# Yu Minecraft 輕量級 Web 管理系統啟動腳本

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🌐 Yu Minecraft 輕量級 Web 管理系統${NC}"
echo "================================================"

# 檢查 Python
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python3 未安裝${NC}"
    exit 1
fi

# 獲取專案目錄
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
WEB_DIR="$PROJECT_DIR/web"

echo -e "${YELLOW}📁 專案目錄: $PROJECT_DIR${NC}"
echo -e "${YELLOW}🌐 Web 目錄: $WEB_DIR${NC}"

# 啟動 API 服務
echo -e "${YELLOW}🚀 啟動 API 服務...${NC}"
cd "$WEB_DIR"
python3 simple-api.py &
API_PID=$!

# 等待 API 啟動
sleep 3

# 檢查 API 是否啟動成功
if ps -p $API_PID > /dev/null; then
    echo -e "${GREEN}✅ API 服務已啟動 (PID: $API_PID)${NC}"
else
    echo -e "${RED}❌ API 服務啟動失敗${NC}"
    exit 1
fi

# 啟動簡單的 HTTP 服務器來提供靜態檔案
echo -e "${YELLOW}🌐 啟動 Web 服務器...${NC}"
python3 -m http.server 8080 &
WEB_PID=$!

# 等待 Web 服務啟動
sleep 2

# 檢查 Web 服務是否啟動成功
if ps -p $WEB_PID > /dev/null; then
    echo -e "${GREEN}✅ Web 服務器已啟動 (PID: $WEB_PID)${NC}"
else
    echo -e "${RED}❌ Web 服務器啟動失敗${NC}"
    kill $API_PID 2>/dev/null
    exit 1
fi

# 保存 PID 到檔案
echo $API_PID > /tmp/yu-minecraft-api.pid
echo $WEB_PID > /tmp/yu-minecraft-web.pid

echo ""
echo -e "${GREEN}🎉 服務啟動成功！${NC}"
echo "================================================"
echo -e "${BLUE}📱 Web 管理介面:${NC}"
echo "   🏠 本地訪問: http://localhost:8080"
echo "   🌐 區域網路: http://$(hostname -I | awk '{print $1}' 2>/dev/null || echo 'localhost'):8080"
echo ""
echo -e "${BLUE}🔧 API 服務:${NC}"
echo "   📡 API 端點: http://localhost:5001/api"
echo ""
echo -e "${YELLOW}📋 管理指令:${NC}"
echo "   停止服務: $0 stop"
echo "   查看狀態: $0 status"
echo "   查看日誌: tail -f /tmp/yu-minecraft-*.log"
echo ""

# 嘗試自動開啟瀏覽器
if [[ "$1" != "--no-browser" ]]; then
    echo -e "${YELLOW}🌐 正在開啟瀏覽器...${NC}"
    if command -v open &> /dev/null; then
        open http://localhost:8080
    elif command -v xdg-open &> /dev/null; then
        xdg-open http://localhost:8080
    else
        echo "請手動開啟瀏覽器並訪問: http://localhost:8080"
    fi
fi

echo ""
echo -e "${GREEN}💡 提示: 按 Ctrl+C 停止服務${NC}"

# 等待用戶中斷
trap 'echo -e "\n${YELLOW}正在停止服務...${NC}"; kill $API_PID $WEB_PID 2>/dev/null; rm -f /tmp/yu-minecraft-*.pid; echo -e "${GREEN}服務已停止${NC}"; exit 0' INT

# 保持腳本運行
while true; do
    sleep 1
    # 檢查服務是否還在運行
    if ! ps -p $API_PID > /dev/null || ! ps -p $WEB_PID > /dev/null; then
        echo -e "${RED}❌ 某個服務已停止${NC}"
        kill $API_PID $WEB_PID 2>/dev/null
        rm -f /tmp/yu-minecraft-*.pid
        exit 1
    fi
done
