#!/bin/bash

# serveo.net 設置腳本 - 另一個免費的隧道服務
# 使用 SSH 隧道，完全免費

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🌐 Minecraft 伺服器 Serveo 設置助手${NC}"
echo "=========================================="
echo -e "${BLUE}✨ 使用 SSH 隧道，完全免費！${NC}"
echo

# 檢查 SSH 是否可用
if ! command -v ssh &> /dev/null; then
    echo -e "${RED}❌ 未找到 SSH，請安裝 OpenSSH${NC}"
    exit 1
fi

# 檢查 Minecraft 伺服器是否運行
echo -e "${YELLOW}🎮 檢查 Minecraft 伺服器狀態...${NC}"

if ! docker compose -f docker/docker-compose.yml ps | grep -q "minecraft.*Up"; then
    echo -e "${YELLOW}⚠️  Minecraft 伺服器尚未啟動${NC}"
    read -p "是否現在啟動伺服器？ (y/n): " start_server
    
    if [[ $start_server =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}🚀 啟動 Minecraft 伺服器...${NC}"
        docker compose -f docker/docker-compose.yml up -d
        echo "等待伺服器啟動..."
        sleep 10
    else
        echo -e "${YELLOW}⚠️  請先啟動伺服器再執行此腳本${NC}"
        exit 1
    fi
fi

# 檢查本地端口是否可用
echo -e "${YELLOW}🔍 檢查本地端口 25565...${NC}"
if ! nc -z localhost 25565 2>/dev/null; then
    echo -e "${RED}❌ 無法連線到 localhost:25565${NC}"
    echo "請確認 Minecraft 伺服器正在運行"
    exit 1
fi

echo -e "${GREEN}✅ Minecraft 伺服器運行正常${NC}"

# 生成隨機子域名
SUBDOMAIN="minecraft-$(date +%s | tail -c 6)"

# 啟動 Serveo 隧道
echo
echo -e "${GREEN}🌍 啟動 Serveo 隧道...${NC}"
echo
echo -e "${BLUE}📋 使用說明：${NC}"
echo "- Serveo 使用 SSH 隧道技術"
echo "- 完全免費，不需要註冊"
echo "- 提供隨機或自訂子域名"
echo
echo -e "${YELLOW}💡 特色：${NC}"
echo "- 不需要安裝額外軟體"
echo "- 基於標準 SSH 協議"
echo "- 支援 TCP 和 HTTP 隧道"
echo
read -p "按 Enter 開始建立隧道..."

echo
echo -e "${GREEN}🚀 正在建立隧道到 localhost:25565...${NC}"
echo
echo "正在連線到 serveo.net..."
echo "如果詢問是否繼續連線，請輸入 'yes'"
echo
echo "隧道建立後，你會看到類似這樣的資訊："
echo "Forwarding TCP connections from serveo.net:12345"
echo
echo "將 'serveo.net:12345' 這個地址給朋友連線！"
echo
echo -e "${YELLOW}⚠️  按 Ctrl+C 停止隧道${NC}"
echo

# 啟動 SSH 隧道到 serveo.net
ssh -o StrictHostKeyChecking=no -R 0:localhost:25565 serveo.net
