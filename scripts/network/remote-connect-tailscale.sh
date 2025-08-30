#!/bin/bash

# Tailscale 設置腳本 - 最安全的連線方案
# 建立私有 VPN 網路，所有朋友都能安全連線

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔒 Minecraft 伺服器 Tailscale 設置助手${NC}"
echo "============================================="

# 檢查是否已安裝 Tailscale
if ! command -v tailscale &> /dev/null; then
    echo -e "${YELLOW}⚠️  Tailscale 尚未安裝${NC}"
    echo
    echo "請選擇安裝方式："
    echo "1. 使用 Homebrew 安裝 (推薦 macOS 用戶)"
    echo "2. 手動下載安裝"
    echo
    read -p "請選擇 (1 或 2): " choice
    
    case $choice in
        1)
            if command -v brew &> /dev/null; then
                echo -e "${GREEN}📦 使用 Homebrew 安裝 Tailscale...${NC}"
                brew install tailscale
            else
                echo -e "${RED}❌ 未找到 Homebrew${NC}"
                echo "請先安裝 Homebrew 或選擇手動安裝"
                exit 1
            fi
            ;;
        2)
            echo -e "${YELLOW}📥 手動安裝 Tailscale:${NC}"
            echo "1. 訪問: https://tailscale.com/download"
            echo "2. 下載適合你系統的版本"
            echo "3. 安裝並完成設置"
            echo
            read -p "完成安裝後按 Enter 繼續..."
            ;;
        *)
            echo -e "${RED}❌ 無效選擇${NC}"
            exit 1
            ;;
    esac
fi

# 檢查 Tailscale 狀態
echo
echo -e "${YELLOW}🔍 檢查 Tailscale 狀態...${NC}"

if ! tailscale status &> /dev/null; then
    echo -e "${YELLOW}⚠️  Tailscale 尚未啟動或登入${NC}"
    echo
    echo "請完成以下步驟："
    echo "1. 啟動 Tailscale"
    echo "2. 使用 Google、Microsoft 或 GitHub 帳號登入"
    echo
    read -p "按 Enter 開始登入流程..."
    
    sudo tailscale up
    
    echo -e "${GREEN}✅ Tailscale 設置完成！${NC}"
fi

# 顯示 Tailscale IP
echo
echo -e "${GREEN}🌐 取得你的 Tailscale IP...${NC}"
TAILSCALE_IP=$(tailscale ip -4)

if [ -z "$TAILSCALE_IP" ]; then
    echo -e "${RED}❌ 無法取得 Tailscale IP${NC}"
    echo "請確認 Tailscale 已正確啟動並連線"
    exit 1
fi

echo -e "${GREEN}✅ 你的 Tailscale IP: ${TAILSCALE_IP}${NC}"

# 檢查 Minecraft 伺服器狀態
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
        echo -e "${YELLOW}⚠️  請先啟動伺服器${NC}"
        exit 1
    fi
fi

# 生成邀請指令
echo
echo -e "${GREEN}🎯 連線資訊${NC}"
echo "=================================="
echo
echo -e "${BLUE}📋 給朋友的連線步驟：${NC}"
echo
echo "1. 請朋友安裝 Tailscale:"
echo "   https://tailscale.com/download"
echo
echo "2. 使用相同的帳號登入 Tailscale"
echo "   (Google、Microsoft 或 GitHub)"
echo
echo "3. 啟動 Tailscale 後，使用以下地址連線:"
echo -e "   ${GREEN}${TAILSCALE_IP}:25565${NC}"
echo
echo -e "${YELLOW}💡 優點：${NC}"
echo "- 完全私密和安全"
echo "- 不需要修改路由器設定"
echo "- 連線穩定，不會斷線"
echo "- 支援多個朋友同時連線"
echo
echo -e "${BLUE}📱 管理 Tailscale：${NC}"
echo "- 查看狀態: tailscale status"
echo "- 查看 IP: tailscale ip -4"
echo "- 登出: tailscale logout"
echo
echo -e "${GREEN}✅ 設置完成！${NC}"
