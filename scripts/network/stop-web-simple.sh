#!/bin/bash

# Yu Minecraft Web 管理系統停止腳本

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}🛑 正在停止 Yu Minecraft Web 管理系統...${NC}"

# 停止 API 服務
if [ -f /tmp/yu-minecraft-api.pid ]; then
    API_PID=$(cat /tmp/yu-minecraft-api.pid)
    if ps -p $API_PID > /dev/null; then
        kill $API_PID
        echo -e "${GREEN}✅ API 服務已停止 (PID: $API_PID)${NC}"
    else
        echo -e "${YELLOW}⚠️  API 服務已經停止${NC}"
    fi
    rm -f /tmp/yu-minecraft-api.pid
fi

# 停止 Web 服務
if [ -f /tmp/yu-minecraft-web.pid ]; then
    WEB_PID=$(cat /tmp/yu-minecraft-web.pid)
    if ps -p $WEB_PID > /dev/null; then
        kill $WEB_PID
        echo -e "${GREEN}✅ Web 服務已停止 (PID: $WEB_PID)${NC}"
    else
        echo -e "${YELLOW}⚠️  Web 服務已經停止${NC}"
    fi
    rm -f /tmp/yu-minecraft-web.pid
fi

# 清理可能殘留的進程
pkill -f "simple-api.py" 2>/dev/null || true
pkill -f "python3 -m http.server 8080" 2>/dev/null || true

echo -e "${GREEN}🎉 所有服務已停止${NC}"
