#!/bin/bash

# Yu Minecraft Server 停止腳本
# 作者: Yu-codes
# 日期: 2023

set -e

# 設定專案根目錄
PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

echo "🛑 停止 Yu Minecraft 伺服器..."

# 切換到專案目錄
cd "$PROJECT_ROOT"

# 檢查docker-compose.yml是否存在
if [ ! -f "docker/docker-compose.yml" ]; then
    echo "❌ 錯誤: docker-compose.yml檔案不存在"
    exit 1
fi

# 檢查容器是否正在執行
if docker compose -f docker/docker-compose.yml ps | grep -q "Up"; then
    echo "📦 正在停止容器..."
    
    # 發送停止指令到Minecraft伺服器
    echo "💾 正在儲存世界資料..."
    docker compose -f docker/docker-compose.yml exec -T minecraft rcon-cli --host localhost --port 25575 --password yu-minecraft-2023 "save-all" || true
    docker compose -f docker/docker-compose.yml exec -T minecraft rcon-cli --host localhost --port 25575 --password yu-minecraft-2023 "stop" || true
    
    # 等待優雅關閉
    echo "⏳ 等待伺服器優雅關閉..."
    sleep 10
    
    # 停止所有容器
    docker compose -f docker/docker-compose.yml down
    
    echo "✅ Yu Minecraft 伺服器已成功停止!"
else
    echo "ℹ️  伺服器未在執行"
fi

echo ""
echo "🔄 使用以下指令重新啟動伺服器:"
echo "   ./scripts/start.sh"
