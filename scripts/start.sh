#!/bin/bash

# Yu Minecraft Server 啟動腳本
# 作者: Yu-codes
# 日期: 2023

set -e

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
cd "$(dirname "$0")/.."

# 檢查docker-compose.yml是否存在
if [ ! -f "docker/docker-compose.yml" ]; then
    echo "❌ 錯誤: docker-compose.yml檔案不存在"
    exit 1
fi

# 創建必要的目錄
mkdir -p worlds plugins config logs

# 啟動服務
echo "📦 建構並啟動容器..."
cd docker
docker compose up -d --build

# 等待服務啟動
echo "⏳ 等待服務啟動..."
sleep 10

# 檢查服務狀態
if docker compose ps | grep -q "Up"; then
    echo "✅ Yu Minecraft 伺服器啟動成功!"
    echo "🌐 伺服器位址: localhost:25565"
    echo "🖥️  Web管理介面: http://localhost:8080"
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
