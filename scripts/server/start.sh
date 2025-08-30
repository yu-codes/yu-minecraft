#!/bin/bash

# Yu Minecraft Server 啟動腳本
# 作者: Yu-codes
# 日期: 2023

set -e

# 設定腳本目錄和專案根目錄
SCRIPT_DIR="$(dirname "$0")"
PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

echo "🎮 啟動 Yu Minecraft 伺服器..."

# 檢查Docker是否安裝
if ! command -v docker &> /dev/null; then
    echo "❌ 錯誤: Docker未安裝，請先安裝Docker"
    exit 1
fi

# 檢查Docker Compose是否安裝 (V2版本)
if ! docker compose version &> /dev/null; then
    echo "❌ 錯誤: Docker Compose未安裝或版本過舊，請安裝Docker Compose V2"
    exit 1
fi

# 切換到專案目錄
cd "$PROJECT_ROOT"

# 檢查docker-compose.yml是否存在
if [ ! -f "docker/docker-compose.yml" ]; then
    echo "❌ 錯誤: docker-compose.yml檔案不存在"
    exit 1
fi

# 創建必要的目錄
mkdir -p worlds plugins config logs

# 檢查 Docker 容器狀態並決定是否需要重建
check_and_rebuild_container() {
    echo "🔍 檢查容器狀態..."
    
    # 檢查容器是否存在
    if ! docker ps -a --format "table {{.Names}}" | grep -q "yu-minecraft-server"; then
        echo "⚠️ 容器不存在，需要建立新容器"
        return 0  # 需要重建
    fi
    
    # 檢查容器是否運行中
    if docker ps --format "table {{.Names}}" | grep -q "yu-minecraft-server"; then
        echo "✅ 容器已在運行中"
        echo "📊 容器狀態:"
        docker ps --filter "name=yu-minecraft-server" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        
        read -p "是否要重啟容器? (y/N): " restart_confirm
        if [[ "$restart_confirm" =~ ^[Yy]$ ]]; then
            echo "🔄 重啟容器..."
            docker compose restart minecraft
            return 1  # 不需要重建，只是重啟
        else
            echo "ℹ️ 容器繼續運行"
            return 1  # 不需要重建
        fi
    fi
    
    # 容器存在但未運行
    echo "⚠️ 容器存在但未運行，檢查狀態..."
    docker ps -a --filter "name=yu-minecraft-server" --format "table {{.Names}}\t{{.Status}}"
    
    read -p "是否要重建容器? (Y/n): " rebuild_confirm
    if [[ "$rebuild_confirm" =~ ^[Nn]$ ]]; then
        echo "🔄 嘗試啟動現有容器..."
        docker compose start minecraft
        return 1  # 不重建，嘗試啟動
    else
        echo "🔨 將重建容器..."
        return 0  # 需要重建
    fi
}

# 檢查世界符號連結
check_world_symlink() {
    echo "🌍 檢查世界符號連結..."
    
    if [ ! -L "$PROJECT_ROOT/worlds/current" ]; then
        echo "⚠️ 警告: 未設置當前世界符號連結"
        echo "💡 建議先使用世界管理功能選擇一個世界"
        
        # 列出可用世界
        worlds_dir="$PROJECT_ROOT/worlds"
        if [ -d "$worlds_dir" ]; then
            available_worlds=$(find "$worlds_dir" -maxdepth 1 -type d -not -name "current" -exec basename {} \; | grep -v "^worlds$" | head -5)
            if [ -n "$available_worlds" ]; then
                echo "📋 可用世界:"
                echo "$available_worlds" | sed 's/^/   • /'
                echo ""
                read -p "是否繼續啟動? (Y/n): " continue_confirm
                if [[ "$continue_confirm" =~ ^[Nn]$ ]]; then
                    echo "❌ 啟動已取消"
                    exit 1
                fi
            fi
        fi
    else
        current_world=$(basename "$(readlink "$(dirname "$0")/../../worlds/current")")
        echo "✅ 當前世界: $current_world"
    fi
}

# 啟動服務
echo "📦 啟動 Minecraft 伺服器..."

# 檢查世界設置
check_world_symlink

# 檢查並決定是否重建容器
if check_and_rebuild_container; then
    echo "🔨 建構並啟動容器..."
    docker compose -f docker/docker-compose.yml up -d --build
else
    echo "⏳ 等待現有容器穩定..."
fi

# 等待服務啟動
echo "⏳ 等待服務啟動..."
sleep 10

# 檢查服務狀態
if docker compose -f docker/docker-compose.yml ps | grep -q "Up"; then
    echo "✅ Yu Minecraft 伺服器啟動成功!"
    
    # 獲取伺服器 IP 地址
    echo "🔍 正在獲取伺服器 IP 地址..."
    
    # 檢測是否在 AWS EC2 上運行
    if curl -s --max-time 5 http://169.254.169.254/latest/meta-data/instance-id &> /dev/null; then
        # AWS EC2 環境
        PUBLIC_IP=$(curl -s --max-time 10 http://169.254.169.254/latest/meta-data/public-ipv4 || echo "無法獲取")
        INSTANCE_ID=$(curl -s --max-time 10 http://169.254.169.254/latest/meta-data/instance-id || echo "unknown")
        
        echo ""
        echo "🌐 AWS EC2 伺服器連線資訊:"
        echo "   伺服器地址: ${PUBLIC_IP}:25565"
        echo "   Web管理介面: http://${PUBLIC_IP}:8080"
        echo "   實例 ID: ${INSTANCE_ID}"
        
        # 生成連線資訊文件
        cat > ../connection_info.txt << EOF
📅 $(date '+%Y-%m-%d %H:%M:%S')
🎮 Yu Minecraft 伺服器已啟動

🌐 連線資訊:
   伺服器地址: ${PUBLIC_IP}:25565
   Web管理介面: http://${PUBLIC_IP}:8080

📋 其他資訊:
   實例 ID: ${INSTANCE_ID}
   啟動時間: $(date)
   
📖 使用說明:
1. 在 Minecraft 中選擇「多人遊戲」
2. 新增伺服器，輸入地址: ${PUBLIC_IP}:25565
3. 享受遊戲！

❓ 需要幫助? 查看 README.md 或聯絡管理員
EOF
        
        # 通知功能
        echo ""
        echo "📢 通知選項:"
        echo "   📄 連線資訊已保存到: connection_info.txt"
        
        # 如果有設置通知 webhook 或其他通知方式
        if [ ! -z "$DISCORD_WEBHOOK" ]; then
            echo "   📱 正在發送 Discord 通知..."
            curl -X POST "$DISCORD_WEBHOOK" \
                -H "Content-Type: application/json" \
                -d "{\"content\": \"🎮 Minecraft 伺服器已啟動！\\n🌐 連線地址: \`${PUBLIC_IP}:25565\`\\n🖥️ 管理介面: http://${PUBLIC_IP}:8080\"}" \
                2>/dev/null && echo "   ✅ Discord 通知已發送" || echo "   ❌ Discord 通知發送失敗"
        fi
        
        if [ ! -z "$SLACK_WEBHOOK" ]; then
            echo "   📱 正在發送 Slack 通知..."
            curl -X POST "$SLACK_WEBHOOK" \
                -H "Content-Type: application/json" \
                -d "{\"text\": \"🎮 Minecraft 伺服器已啟動！\\n🌐 連線地址: \`${PUBLIC_IP}:25565\`\\n🖥️ 管理介面: http://${PUBLIC_IP}:8080\"}" \
                2>/dev/null && echo "   ✅ Slack 通知已發送" || echo "   ❌ Slack 通知發送失敗"
        fi
        
        if [ ! -z "$TELEGRAM_BOT_TOKEN" ] && [ ! -z "$TELEGRAM_CHAT_ID" ]; then
            echo "   📱 正在發送 Telegram 通知..."
            curl -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
                -d "chat_id=${TELEGRAM_CHAT_ID}" \
                -d "text=🎮 Minecraft 伺服器已啟動！%0A🌐 連線地址: ${PUBLIC_IP}:25565%0A🖥️ 管理介面: http://${PUBLIC_IP}:8080" \
                2>/dev/null && echo "   ✅ Telegram 通知已發送" || echo "   ❌ Telegram 通知發送失敗"
        fi
        
        echo ""
        echo "💡 提示: 複製上方地址分享給朋友們！"
        echo "📋 完整連線資訊已保存到 connection_info.txt 檔案"
        
        # 使用新的通知系統
        if [ -f "$SCRIPT_DIR/notify.sh" ]; then
            echo ""
            echo "📢 正在發送啟動通知..."
            "$SCRIPT_DIR/notify.sh" startup
        fi
        
    else
        # 本地環境或其他雲端環境
        LOCAL_IP=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "localhost")
        
        echo ""
        echo "🏠 本地伺服器連線資訊:"
        echo "   本地地址: localhost:25565"
        echo "   區域網路: ${LOCAL_IP}:25565"
        echo "   Web管理介面: http://localhost:8080"
        
        # 生成本地連線資訊
        cat > ../connection_info.txt << EOF
📅 $(date '+%Y-%m-%d %H:%M:%S')
🎮 Yu Minecraft 伺服器已啟動（本地環境）

🌐 連線資訊:
   本地連線: localhost:25565
   區域網路: ${LOCAL_IP}:25565
   Web管理介面: http://localhost:8080

📖 使用說明:
1. 在 Minecraft 中選擇「多人遊戲」
2. 新增伺服器，輸入地址: localhost:25565（本機）或 ${LOCAL_IP}:25565（區域網路）
3. 享受遊戲！

❓ 需要遠端連線? 請參考 docs/REMOTE_CONNECTION_GUIDE.md
EOF
    fi
    
    echo ""
    echo "📋 使用以下指令查看記錄:"
    echo "   docker compose logs -f minecraft"
    echo ""
    echo "🛑 使用以下指令停止伺服器:"
    echo "   ./scripts/stop.sh"
else
    echo "❌ 伺服器啟動失敗，請檢查記錄:"
    docker compose logs minecraft
    exit 1
fi
