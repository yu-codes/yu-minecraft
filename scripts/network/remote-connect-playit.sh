#!/bin/bash

# playit.gg 設置腳本 - 完全免費的 ngrok 替代方案
# 不需要信用卡，專為遊戲設計

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🎮 Minecraft 伺服器 playit.gg 設置助手${NC}"
echo "=============================================="
echo -e "${BLUE}✨ 完全免費，不需要信用卡！${NC}"
echo

# 檢查是否已安裝 playit
if ! command -v playit &> /dev/null; then
    echo -e "${YELLOW}⚠️  playit 尚未安裝${NC}"
    echo
    echo "正在下載 playit..."
    
    # 檢測系統架構
    ARCH=$(uname -m)
    OS=$(uname -s)
    
    if [[ "$OS" == "Darwin" ]]; then
        if [[ "$ARCH" == "arm64" ]]; then
            DOWNLOAD_URL="https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-darwin_arm64"
        else
            DOWNLOAD_URL="https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-darwin_amd64"
        fi
    elif [[ "$OS" == "Linux" ]]; then
        if [[ "$ARCH" == "aarch64" ]]; then
            DOWNLOAD_URL="https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux_aarch64"
        else
            DOWNLOAD_URL="https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux_amd64"
        fi
    else
        echo -e "${RED}❌ 不支援的作業系統: $OS${NC}"
        echo "請手動訪問: https://playit.gg/download"
        exit 1
    fi
    
    echo -e "${GREEN}📥 下載 playit 中...${NC}"
    curl -L "$DOWNLOAD_URL" -o /tmp/playit
    chmod +x /tmp/playit
    sudo mv /tmp/playit /usr/local/bin/
    
    echo -e "${GREEN}✅ playit 安裝完成！${NC}"
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

# 啟動 playit 隧道
echo
echo -e "${GREEN}🌍 啟動 playit.gg 隧道...${NC}"
echo
echo -e "${BLUE}📋 使用說明：${NC}"
echo "1. playit 第一次運行會要求你登入或註冊"
echo "2. 訪問顯示的網址完成認證"
echo "3. 認證完成後會自動建立隧道"
echo "4. 複製顯示的伺服器地址給朋友"
echo
echo -e "${YELLOW}💡 優點：${NC}"
echo "- 完全免費，不需要信用卡"
echo "- 專為遊戲設計，低延遲"
echo "- 穩定的連線，不會隨機斷線"
echo "- 支援固定網址（付費版）"
echo
read -p "按 Enter 開始建立隧道..."

echo
echo -e "${GREEN}🚀 正在建立隧道到 localhost:25565...${NC}"
echo
echo "初次使用需要認證，請按照螢幕指示操作"
echo "認證完成後，你會看到類似這樣的資訊："
echo "Tunnel started: minecraft.serveo.net:12345"
echo
echo "將顯示的地址給朋友連線！"
echo
echo -e "${YELLOW}⚠️  按 Ctrl+C 停止隧道${NC}"
echo

# 啟動 playit
playit --tunnel_type minecraft --port 25565
