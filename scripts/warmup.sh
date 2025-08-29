#!/bin/bash

# Yu Minecraft Server 預熱腳本
# 用於在啟動後進行效能最佳化

echo "🔥 開始伺服器預熱程序..."

# 等待伺服器完全啟動
sleep 30

# 預載入重要區塊
echo "📍 預載入重要區塊..."
docker compose exec -T minecraft rcon-cli --host localhost --port 25575 --password yu-minecraft-2025 "forceload add 0 0" || true
docker compose exec -T minecraft rcon-cli --host localhost --port 25575 --password yu-minecraft-2025 "forceload add -100 -100 100 100" || true

# 執行垃圾回收
echo "🗑️ 執行垃圾回收..."
docker compose exec -T minecraft rcon-cli --host localhost --port 25575 --password yu-minecraft-2025 "forge gc" || true

echo "✅ 伺服器預熱完成"
