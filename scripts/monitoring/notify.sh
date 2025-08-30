#!/bin/bash

# Yu Minecraft Server 通知腳本
# 用於發送伺服器狀態通知到各種平台

set -e

# 預設配置
SCRIPT_DIR="$(dirname "$0")"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# 載入環境變數（如果存在）
if [ -f "$PROJECT_DIR/.env" ]; then
    source "$PROJECT_DIR/.env"
fi

# 顏色代碼
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 顯示使用說明
show_help() {
    echo "🔔 Yu Minecraft Server 通知工具"
    echo ""
    echo "使用方式:"
    echo "  $0 [選項] [訊息類型]"
    echo ""
    echo "訊息類型:"
    echo "  startup    - 伺服器啟動通知"
    echo "  shutdown   - 伺服器關閉通知"
    echo "  status     - 伺服器狀態通知"
    echo "  custom     - 自訂訊息"
    echo ""
    echo "選項:"
    echo "  -m, --message TEXT    自訂訊息內容"
    echo "  -c, --config          顯示通知設定指南"
    echo "  -t, --test           測試所有已配置的通知管道"
    echo "  -h, --help           顯示此說明"
    echo ""
    echo "範例:"
    echo "  $0 startup                    # 發送啟動通知"
    echo "  $0 custom -m \"伺服器維護中\"    # 發送自訂訊息"
    echo "  $0 -t                         # 測試通知"
}

# 顯示配置指南
show_config() {
    echo "⚙️ 通知設定指南"
    echo ""
    echo "在專案根目錄創建 .env 檔案，新增以下設定："
    echo ""
    echo "# Discord Webhook"
    echo "DISCORD_WEBHOOK=https://discord.com/api/webhooks/YOUR_WEBHOOK_URL"
    echo ""
    echo "# Slack Webhook"
    echo "SLACK_WEBHOOK=https://hooks.slack.com/services/YOUR_WEBHOOK_URL"
    echo ""
    echo "# Telegram Bot"
    echo "TELEGRAM_BOT_TOKEN=YOUR_BOT_TOKEN"
    echo "TELEGRAM_CHAT_ID=YOUR_CHAT_ID"
    echo ""
    echo "# Line Notify"
    echo "LINE_NOTIFY_TOKEN=YOUR_LINE_TOKEN"
    echo ""
    echo "# Email (SMTP)"
    echo "SMTP_SERVER=smtp.gmail.com"
    echo "SMTP_PORT=587"
    echo "SMTP_USER=your-email@gmail.com"
    echo "SMTP_PASS=your-app-password"
    echo "NOTIFY_EMAIL=friend1@example.com,friend2@example.com"
    echo ""
    echo "💡 設定完成後，使用 '$0 -t' 測試通知功能"
}

# 獲取伺服器資訊
get_server_info() {
    if curl -s --max-time 5 http://169.254.169.254/latest/meta-data/instance-id &> /dev/null; then
        # AWS EC2 環境
        PUBLIC_IP=$(curl -s --max-time 10 http://169.254.169.254/latest/meta-data/public-ipv4 || echo "無法獲取")
        INSTANCE_ID=$(curl -s --max-time 10 http://169.254.169.254/latest/meta-data/instance-id || echo "unknown")
        SERVER_TYPE="AWS EC2"
        SERVER_ADDRESS="${PUBLIC_IP}:25565"
        WEB_INTERFACE="http://${PUBLIC_IP}:8080"
    else
        # 本地環境
        LOCAL_IP=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "localhost")
        SERVER_TYPE="本地伺服器"
        SERVER_ADDRESS="localhost:25565"
        WEB_INTERFACE="http://localhost:8080"
        PUBLIC_IP="localhost"
    fi
}

# Discord 通知
send_discord() {
    local message="$1"
    if [ ! -z "$DISCORD_WEBHOOK" ]; then
        echo -e "${BLUE}📱 發送 Discord 通知...${NC}"
        curl -X POST "$DISCORD_WEBHOOK" \
            -H "Content-Type: application/json" \
            -d "{\"content\": \"$message\"}" \
            2>/dev/null && echo -e "${GREEN}✅ Discord 通知已發送${NC}" || echo -e "${RED}❌ Discord 通知發送失敗${NC}"
    fi
}

# Slack 通知
send_slack() {
    local message="$1"
    if [ ! -z "$SLACK_WEBHOOK" ]; then
        echo -e "${BLUE}📱 發送 Slack 通知...${NC}"
        curl -X POST "$SLACK_WEBHOOK" \
            -H "Content-Type: application/json" \
            -d "{\"text\": \"$message\"}" \
            2>/dev/null && echo -e "${GREEN}✅ Slack 通知已發送${NC}" || echo -e "${RED}❌ Slack 通知發送失敗${NC}"
    fi
}

# Telegram 通知
send_telegram() {
    local message="$1"
    if [ ! -z "$TELEGRAM_BOT_TOKEN" ] && [ ! -z "$TELEGRAM_CHAT_ID" ]; then
        echo -e "${BLUE}📱 發送 Telegram 通知...${NC}"
        # URL 編碼訊息
        encoded_message=$(echo "$message" | sed 's/ /%20/g' | sed 's/\n/%0A/g')
        curl -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
            -d "chat_id=${TELEGRAM_CHAT_ID}" \
            -d "text=${encoded_message}" \
            2>/dev/null && echo -e "${GREEN}✅ Telegram 通知已發送${NC}" || echo -e "${RED}❌ Telegram 通知發送失敗${NC}"
    fi
}

# Line 通知
send_line() {
    local message="$1"
    if [ ! -z "$LINE_NOTIFY_TOKEN" ]; then
        echo -e "${BLUE}📱 發送 Line 通知...${NC}"
        curl -X POST "https://notify-api.line.me/api/notify" \
            -H "Authorization: Bearer ${LINE_NOTIFY_TOKEN}" \
            -d "message=${message}" \
            2>/dev/null && echo -e "${GREEN}✅ Line 通知已發送${NC}" || echo -e "${RED}❌ Line 通知發送失敗${NC}"
    fi
}

# Email 通知
send_email() {
    local subject="$1"
    local message="$2"
    if [ ! -z "$SMTP_SERVER" ] && [ ! -z "$NOTIFY_EMAIL" ]; then
        echo -e "${BLUE}📧 發送 Email 通知...${NC}"
        # 這裡需要安裝 mail 命令或使用 python 腳本
        if command -v mail &> /dev/null; then
            echo "$message" | mail -s "$subject" "$NOTIFY_EMAIL"
            echo -e "${GREEN}✅ Email 通知已發送${NC}"
        else
            echo -e "${YELLOW}⚠️ 未安裝 mail 命令，跳過 Email 通知${NC}"
        fi
    fi
}

# 發送所有通知
send_all_notifications() {
    local message="$1"
    local subject="$2"
    
    echo -e "${YELLOW}📢 開始發送通知...${NC}"
    echo ""
    
    send_discord "$message"
    send_slack "$message"
    send_telegram "$message"
    send_line "$message"
    send_email "$subject" "$message"
    
    echo ""
    echo -e "${GREEN}🎉 通知發送完成！${NC}"
}

# 測試通知
test_notifications() {
    get_server_info
    local test_message="🔔 這是一個測試通知！\\n🎮 Yu Minecraft Server\\n🌐 伺服器: ${SERVER_ADDRESS}\\n⏰ 時間: $(date)"
    echo -e "${YELLOW}🧪 正在測試所有通知管道...${NC}"
    send_all_notifications "$test_message" "Yu Minecraft Server - 測試通知"
}

# 生成通知訊息
generate_message() {
    local type="$1"
    local custom_msg="$2"
    
    get_server_info
    
    case $type in
        "startup")
            echo "🎮 Minecraft 伺服器已啟動！\\n🌐 連線地址: \`${SERVER_ADDRESS}\`\\n🖥️ 管理介面: ${WEB_INTERFACE}\\n⏰ 啟動時間: $(date '+%H:%M:%S')"
            ;;
        "shutdown")
            echo "🛑 Minecraft 伺服器已關閉\\n🌐 伺服器: ${SERVER_ADDRESS}\\n⏰ 關閉時間: $(date '+%H:%M:%S')"
            ;;
        "status")
            # 檢查伺服器狀態
            if docker compose -f "$PROJECT_DIR/docker/docker-compose.yml" ps | grep -q "Up"; then
                status="🟢 運行中"
            else
                status="🔴 已停止"
            fi
            echo "📊 伺服器狀態報告\\n🌐 伺服器: ${SERVER_ADDRESS}\\n📈 狀態: ${status}\\n⏰ 檢查時間: $(date '+%H:%M:%S')"
            ;;
        "custom")
            echo "📢 ${custom_msg}\\n🌐 伺服器: ${SERVER_ADDRESS}\\n⏰ 時間: $(date '+%H:%M:%S')"
            ;;
        *)
            echo "❓ 未知的訊息類型: $type"
            return 1
            ;;
    esac
}

# 主要邏輯
CUSTOM_MESSAGE=""
TYPE=""

# 解析參數
while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--message)
            CUSTOM_MESSAGE="$2"
            shift 2
            ;;
        -c|--config)
            show_config
            exit 0
            ;;
        -t|--test)
            test_notifications
            exit 0
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        startup|shutdown|status|custom)
            TYPE="$1"
            shift
            ;;
        *)
            echo "未知選項: $1"
            show_help
            exit 1
            ;;
    esac
done

# 如果沒有指定類型，顯示幫助
if [ -z "$TYPE" ]; then
    show_help
    exit 1
fi

# 如果是自訂訊息但沒有提供內容
if [ "$TYPE" = "custom" ] && [ -z "$CUSTOM_MESSAGE" ]; then
    echo -e "${RED}❌ 錯誤: 自訂訊息需要使用 -m 參數指定內容${NC}"
    exit 1
fi

# 生成並發送通知
MESSAGE=$(generate_message "$TYPE" "$CUSTOM_MESSAGE")
SUBJECT="Yu Minecraft Server - $(echo $TYPE | tr '[:lower:]' '[:upper:]')"

if [ $? -eq 0 ]; then
    send_all_notifications "$MESSAGE" "$SUBJECT"
else
    echo -e "${RED}❌ 訊息生成失敗${NC}"
    exit 1
fi
