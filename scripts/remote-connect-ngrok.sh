#!/bin/bash

# ngrok 設置腳本 - 用於無法修改路由器設定的情況
# 執行此腳本來快速設置外網連線

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🌐 Minecraft 伺服器 ngrok 設置助手${NC}"
echo "========================================"

# 檢查是否已安裝 ngrok
if ! command -v ngrok &> /dev/null; then
    echo -e "${YELLOW}⚠️  ngrok 尚未安裝${NC}"
    echo
    echo "請選擇安裝方式："
    echo "1. 使用 Homebrew 安裝 (推薦 macOS 用戶)"
    echo "2. 手動下載安裝"
    echo
    read -p "請選擇 (1 或 2): " choice
    
    case $choice in
        1)
            if command -v brew &> /dev/null; then
                echo -e "${GREEN}📦 使用 Homebrew 安裝 ngrok...${NC}"
                brew install ngrok/ngrok/ngrok
            else
                echo -e "${RED}❌ 未找到 Homebrew，請先安裝 Homebrew 或選擇手動安裝${NC}"
                echo "Homebrew 安裝: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
                exit 1
            fi
            ;;
        2)
            echo -e "${YELLOW}📥 請手動下載 ngrok:${NC}"
            echo "1. 訪問: https://ngrok.com/download"
            echo "2. 註冊免費帳號"
            echo "3. 下載適合你系統的版本"
            echo "4. 解壓並移動到 /usr/local/bin/"
            echo
            read -p "完成安裝後按 Enter 繼續..."
            ;;
        *)
            echo -e "${RED}❌ 無效選擇${NC}"
            exit 1
            ;;
    esac
fi

# 檢查 authtoken
echo
echo -e "${YELLOW}🔑 檢查 ngrok 認證設定...${NC}"

# 檢查是否已經設定 authtoken
CONFIG_FILE="$HOME/.config/ngrok/ngrok.yml"
if [[ ! -f "$CONFIG_FILE" ]] || ! grep -q "authtoken:" "$CONFIG_FILE" 2>/dev/null; then
    echo -e "${YELLOW}⚠️  尚未設定 ngrok authtoken${NC}"
    echo
    echo "請完成以下步驟："
    echo "1. 訪問: https://ngrok.com/signup"
    echo "2. 免費註冊帳號（不需要信用卡）"
    echo "3. 登入後到: https://dashboard.ngrok.com/get-started/your-authtoken"
    echo "4. 複製你的 authtoken"
    echo
    read -p "請輸入你的 authtoken: " authtoken
    
    if [ -z "$authtoken" ]; then
        echo -e "${RED}❌ authtoken 不能為空${NC}"
        exit 1
    fi
    
    ngrok config add-authtoken "$authtoken"
    echo -e "${GREEN}✅ authtoken 設定完成${NC}"
else
    echo -e "${GREEN}✅ authtoken 已設定${NC}"
fi

# 檢查 Minecraft 伺服器是否運行
echo
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

# 啟動 ngrok 隧道
echo
echo -e "${GREEN}🌍 啟動 ngrok 隧道...${NC}"
echo
echo "ngrok 將建立一個安全隧道，讓朋友可以從外網連線到你的伺服器"
echo "請保持此終端視窗開啟"
echo
echo -e "${YELLOW}⏰ 免費版 ngrok 限制:${NC}"
echo "- 隧道會在 2 小時後斷線"
echo "- 每次重啟會得到新的網址"
echo "- 如需穩定連線，建議升級到付費版"
echo
read -p "按 Enter 開始建立隧道..."

echo
echo -e "${GREEN}🚀 正在建立隧道到 localhost:25565...${NC}"
echo
echo "隧道建立後，你會看到類似這樣的資訊："
echo "Forwarding: tcp://0.tcp.ngrok.io:12345 -> localhost:25565"
echo
echo "將 '0.tcp.ngrok.io:12345' 這個地址給朋友連線！"
echo
echo "⚠️  按 Ctrl+C 停止隧道"
echo

# 啟動 ngrok
ngrok tcp 25565
