#!/bin/bash

# Yu Minecraft 部署助手 - 統一部署腳本選擇器
# 整合所有部署方案，讓用戶選擇最適合的部署方式

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🎮 Yu Minecraft 伺服器部署助手${NC}"
echo "=================================="
echo

echo -e "${BLUE}📋 請選擇部署方案：${NC}"
echo
echo -e "${GREEN}🥇 推薦方案：${NC}"
echo "1) Oracle Cloud - 永久免費雲端部署（推薦）"
echo "   • 24/7 運行，4核心+24GB RAM"
echo "   • 永久免費，無時間限制"
echo "   • 固定公網IP，企業級穩定性"
echo
echo -e "${YELLOW}🥈 雲端替代方案：${NC}"
echo "2) AWS EC2 - 12個月免費雲端部署"
echo "   • 專業雲端服務，可靠穩定"
echo "   • 12個月免費額度"
echo "   • 豐富的監控和管理工具"
echo
echo -e "${BLUE}🏠 本地/臨時方案：${NC}"
echo "3) Tailscale - 私人網路連線（最安全）"
echo "   • 無需公網IP，完全私密"
echo "   • 簡單設置，朋友間分享"
echo
echo "4) ngrok - 臨時公網連線（測試用）"
echo "   • 快速建立臨時連線"
echo "   • 適合短期測試"
echo
echo "5) Playit.gg - 簡單免費方案"
echo "   • 無需註冊雲端服務"
echo "   • 一鍵設置"
echo
echo "6) 本地部署 - Docker 本地運行"
echo "   • 僅限本地網路"
echo "   • 開發測試使用"
echo
echo -e "${RED}🔧 進階選項：${NC}"
echo "7) 自定義部署 - 手動配置"
echo "8) 查看所有方案比較"
echo "9) 退出"
echo

read -p "請輸入選項 (1-9): " choice

case $choice in
    1)
        echo -e "${GREEN}🚀 啟動 Oracle Cloud 部署...${NC}"
        echo "這是最推薦的部署方案，提供永久免費的高效能雲端服務"
        echo
        if [ -f "./scripts/remote-connect-oracle.sh" ]; then
            ./scripts/remote-connect-oracle.sh
        else
            echo -e "${RED}❌ Oracle Cloud 部署腳本不存在${NC}"
            exit 1
        fi
        ;;
    2)
        echo -e "${YELLOW}🌩️ 啟動 AWS EC2 部署...${NC}"
        echo "AWS 提供 12 個月免費額度，是穩定的雲端選擇"
        echo
        echo -e "${BLUE}📖 請參考 AWS 部署指南：${NC}"
        echo "docs/AWS_DEPLOYMENT_GUIDE.md"
        echo
        echo "或執行現有的 AWS 相關腳本"
        ;;
    3)
        echo -e "${BLUE}🔒 啟動 Tailscale 部署...${NC}"
        echo "建立私人 VPN 網路，最安全的連線方案"
        echo
        if [ -f "./scripts/remote-connect-tailscale.sh" ]; then
            ./scripts/remote-connect-tailscale.sh
        else
            echo -e "${RED}❌ Tailscale 腳本不存在${NC}"
            exit 1
        fi
        ;;
    4)
        echo -e "${YELLOW}🌐 啟動 ngrok 部署...${NC}"
        echo "快速建立臨時公網連線"
        echo
        if [ -f "./scripts/remote-connect-ngrok.sh" ]; then
            ./scripts/remote-connect-ngrok.sh
        else
            echo -e "${RED}❌ ngrok 腳本不存在${NC}"
            exit 1
        fi
        ;;
    5)
        echo -e "${GREEN}🎯 啟動 Playit.gg 部署...${NC}"
        echo "簡單免費的公網連線方案"
        echo
        if [ -f "./scripts/remote-connect-playit.sh" ]; then
            ./scripts/remote-connect-playit.sh
        else
            echo -e "${RED}❌ Playit.gg 腳本不存在${NC}"
            exit 1
        fi
        ;;
    6)
        echo -e "${BLUE}🏠 啟動本地 Docker 部署...${NC}"
        echo "在本地環境運行 Minecraft 伺服器"
        echo
        echo "檢查 Docker 環境..."
        if command -v docker &> /dev/null && command -v docker-compose &> /dev/null; then
            echo "✅ Docker 環境正常"
            echo
            echo "啟動本地伺服器..."
            docker-compose up -d
            echo
            echo -e "${GREEN}✅ 本地伺服器已啟動！${NC}"
            echo "連線地址: localhost:25565"
            echo "管理介面: http://localhost:9000"
        else
            echo -e "${RED}❌ Docker 或 Docker Compose 未安裝${NC}"
            echo "請先安裝 Docker Desktop"
            exit 1
        fi
        ;;
    7)
        echo -e "${CYAN}🔧 自定義部署選項${NC}"
        echo "========================="
        echo
        echo "可用的部署腳本："
        ls -la scripts/remote-connect-*.sh 2>/dev/null | awk '{print $9}' | grep -v "^$"
        echo
        echo "其他部署選項："
        echo "- 固定IP方案: ./scripts/remote-connect-fixed-ip.sh"
        echo "- Serveo方案: ./scripts/remote-connect-serveo.sh"
        echo
        read -p "請輸入要執行的腳本名稱（不含路徑）: " script_name
        if [ -f "./scripts/$script_name" ]; then
            ./scripts/$script_name
        else
            echo -e "${RED}❌ 腳本不存在: $script_name${NC}"
        fi
        ;;
    8)
        echo -e "${CYAN}📊 部署方案比較${NC}"
        echo "===================="
        echo
        echo -e "${GREEN}方案比較表格：${NC}"
        echo "┌─────────────────┬────────┬──────────┬────────┬────────┬────────┐"
        echo "│ 方案            │ 成本   │ 設定難度 │ 穩定性 │ 效能   │ 維護   │"
        echo "├─────────────────┼────────┼──────────┼────────┼────────┼────────┤"
        echo "│ Oracle Cloud    │ ⭐⭐⭐⭐⭐ │ ⭐⭐      │ ⭐⭐⭐⭐⭐ │ ⭐⭐⭐⭐⭐ │ ⭐⭐    │"
        echo "│ AWS EC2         │ ⭐⭐⭐    │ ⭐⭐⭐     │ ⭐⭐⭐⭐⭐ │ ⭐⭐⭐⭐⭐ │ ⭐⭐    │"
        echo "│ Tailscale       │ ⭐⭐⭐⭐   │ ⭐⭐⭐⭐    │ ⭐⭐⭐⭐⭐ │ ⭐⭐⭐⭐   │ ⭐⭐⭐⭐  │"
        echo "│ ngrok           │ ⭐⭐     │ ⭐⭐⭐⭐⭐   │ ⭐⭐     │ ⭐⭐⭐⭐   │ ⭐⭐⭐⭐  │"
        echo "│ Playit.gg       │ ⭐⭐⭐⭐   │ ⭐⭐⭐⭐    │ ⭐⭐⭐    │ ⭐⭐⭐    │ ⭐⭐⭐⭐  │"
        echo "│ 本地部署        │ ⭐⭐⭐⭐⭐ │ ⭐⭐⭐⭐⭐   │ ⭐⭐⭐    │ ⭐⭐⭐⭐⭐ │ ⭐⭐⭐   │"
        echo "└─────────────────┴────────┴──────────┴────────┴────────┴────────┘"
        echo
        echo -e "${BLUE}💡 推薦選擇：${NC}"
        echo "• 長期運行: Oracle Cloud"
        echo "• 新手友善: Tailscale"
        echo "• 臨時測試: ngrok"
        echo "• 本地開發: 本地部署"
        echo
        echo -e "${YELLOW}📖 詳細比較請參考: docs/REMOTE_CONNECTION_GUIDE.md${NC}"
        echo
        read -p "按 Enter 返回主選單..."
        exec $0
        ;;
    9)
        echo -e "${GREEN}👋 感謝使用 Yu Minecraft 部署助手！${NC}"
        echo
        echo "💡 提示："
        echo "- 推薦使用 Oracle Cloud 進行長期部署"
        echo "- 如需協助，請查看 docs/ 目錄下的相關文件"
        echo "- 問題回報: https://github.com/yu-codes/yu-minecraft/issues"
        exit 0
        ;;
    *)
        echo -e "${RED}❌ 無效選擇，請輸入 1-9${NC}"
        exit 1
        ;;
esac

echo
echo -e "${GREEN}🎉 部署完成！${NC}"
echo
echo -e "${BLUE}📋 後續步驟：${NC}"
echo "1. 測試伺服器連線"
echo "2. 設定管理員權限"
echo "3. 安裝必要外掛"
echo "4. 設定自動備份"
echo
echo -e "${YELLOW}📖 更多說明請參考：${NC}"
echo "- 伺服器管理: README.md#伺服器管理"
echo "- 外掛管理: README.md#外掛管理"
echo "- 故障排除: README.md#故障排除"
echo
echo -e "${CYAN}🎮 享受你的 Minecraft 冒險！${NC}"
