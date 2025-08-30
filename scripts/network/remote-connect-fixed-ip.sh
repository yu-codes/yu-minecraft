#!/bin/bash

# 固定 IP 連線設置腳本 - 適用於有固定公網 IP 的環境
# 包含防火牆設置和安全配置

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🌐 Minecraft 伺服器固定 IP 設置助手${NC}"
echo "=============================================="
echo -e "${BLUE}✨ 適用於有固定公網 IP 或 VPS 的環境${NC}"
echo

# 檢測當前 IP
echo -e "${YELLOW}🔍 檢測網路環境...${NC}"
PUBLIC_IP=$(curl -s ifconfig.me || echo "無法取得")
PRIVATE_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | head -1 | awk '{print $2}')

echo "公網 IP: $PUBLIC_IP"
echo "內網 IP: $PRIVATE_IP"
echo

# 檢查是否為 VPS/雲端伺服器
if [[ "$PUBLIC_IP" == "$PRIVATE_IP" ]]; then
    ENVIRONMENT="VPS/雲端伺服器"
    SETUP_TYPE="direct"
    echo -e "${GREEN}✅ 檢測到 VPS/雲端伺服器環境${NC}"
else
    ENVIRONMENT="家用網路"
    SETUP_TYPE="port_forward"
    echo -e "${YELLOW}⚠️  檢測到家用網路環境，需要設置端口轉發${NC}"
fi

echo "環境類型: $ENVIRONMENT"
echo

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

# 防火牆設置
echo
echo -e "${YELLOW}🔥 設置防火牆規則...${NC}"

# 檢測作業系統
OS=$(uname -s)
case $OS in
    "Darwin")
        echo "檢測到 macOS 系統"
        echo "正在檢查防火牆狀態..."
        
        # 檢查 macOS 防火牆
        FW_STATUS=$(sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate | grep "enabled" || echo "disabled")
        
        if [[ $FW_STATUS == *"enabled"* ]]; then
            echo "防火牆已啟用，正在添加 Docker 例外..."
            sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /Applications/Docker.app --unblockapp /Applications/Docker.app
            echo -e "${GREEN}✅ Docker 已添加到防火牆例外${NC}"
        else
            echo -e "${GREEN}✅ 防火牆未啟用，無需設置${NC}"
        fi
        ;;
        
    "Linux")
        echo "檢測到 Linux 系統"
        
        # 檢查是否有 ufw
        if command -v ufw &> /dev/null; then
            echo "正在設置 UFW 防火牆..."
            sudo ufw allow 25565/tcp comment "Minecraft Server"
            echo -e "${GREEN}✅ UFW 規則已添加${NC}"
        # 檢查是否有 firewalld
        elif command -v firewall-cmd &> /dev/null; then
            echo "正在設置 firewalld..."
            sudo firewall-cmd --permanent --add-port=25565/tcp
            sudo firewall-cmd --reload
            echo -e "${GREEN}✅ firewalld 規則已添加${NC}"
        # 檢查是否有 iptables
        elif command -v iptables &> /dev/null; then
            echo "正在設置 iptables..."
            sudo iptables -A INPUT -p tcp --dport 25565 -j ACCEPT
            # 嘗試保存規則
            if command -v iptables-save &> /dev/null; then
                sudo iptables-save > /etc/iptables/rules.v4 2>/dev/null || true
            fi
            echo -e "${GREEN}✅ iptables 規則已添加${NC}"
        else
            echo -e "${YELLOW}⚠️  未檢測到防火牆管理工具，請手動開放 25565 端口${NC}"
        fi
        ;;
        
    *)
        echo -e "${YELLOW}⚠️  未知作業系統，請手動設置防火牆${NC}"
        ;;
esac

# 根據環境類型給出不同指導
echo
if [[ $SETUP_TYPE == "direct" ]]; then
    echo -e "${GREEN}🎯 VPS/雲端伺服器設置完成！${NC}"
    echo "=================================="
    echo
    echo -e "${BLUE}📋 連線資訊：${NC}"
    echo "伺服器地址: ${PUBLIC_IP}:25565"
    echo
    echo -e "${YELLOW}💡 給朋友的連線步驟：${NC}"
    echo "1. 開啟 Minecraft 客戶端"
    echo "2. 選擇「多人遊戲」"
    echo "3. 點擊「新增伺服器」"
    echo "4. 輸入伺服器地址: ${PUBLIC_IP}:25565"
    echo "5. 儲存並連線"
    
else
    echo -e "${YELLOW}🏠 家用網路環境設置${NC}"
    echo "============================="
    echo
    echo -e "${BLUE}📋 需要完成的步驟：${NC}"
    echo
    echo "1. **路由器端口轉發設置**："
    echo "   - 登入路由器管理界面（通常是 192.168.1.1 或 192.168.0.1）"
    echo "   - 找到「端口轉發」或「虛擬伺服器」設定"
    echo "   - 添加規則："
    echo "     * 服務名稱：Minecraft Server"
    echo "     * 內部 IP：${PRIVATE_IP}"
    echo "     * 內部端口：25565"
    echo "     * 外部端口：25565"
    echo "     * 協議：TCP"
    echo "   - 儲存並重啟路由器"
    echo
    echo "2. **朋友連線地址**："
    echo "   ${PUBLIC_IP}:25565"
    echo
    echo "3. **測試連線**："
    echo "   可使用線上工具測試端口開放："
    echo "   https://www.yougetsignal.com/tools/open-ports/"
fi

# 安全建議
echo
echo -e "${BLUE}🔒 安全建議：${NC}"
echo "- 設置伺服器白名單：編輯 config/whitelist.json"
echo "- 設置管理員：編輯 config/ops.json"
echo "- 定期備份：./scripts/backup.sh"
echo "- 監控連線：./scripts/monitor.sh"
echo "- 考慮使用防 DDoS 服務（如 Cloudflare）"

# 效能建議
echo
echo -e "${BLUE}⚡ 效能建議：${NC}"
echo "- 監控伺服器資源使用：./scripts/monitor.sh continuous"
echo "- 定期重啟伺服器：每週重啟一次"
echo "- 清理無用的世界檔案"
echo "- 考慮升級伺服器硬體（增加 RAM）"

# 備份建議
echo
echo -e "${BLUE}💾 備份建議：${NC}"
echo "- 每日自動備份：設置 cron job 執行 ./scripts/backup.sh"
echo "- 異地備份：將備份檔案上傳到雲端儲存"
echo "- 測試恢復：定期測試備份檔案的可用性"

echo
echo -e "${GREEN}✅ 固定 IP 設置完成！${NC}"
echo
echo -e "${YELLOW}📱 下一步：${NC}"
echo "1. 如果是家用網路，請完成路由器端口轉發"
echo "2. 測試本地連線：localhost:25565"
echo "3. 測試外網連線：${PUBLIC_IP}:25565"
echo "4. 邀請朋友加入遊戲！"
