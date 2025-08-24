#!/bin/bash

# Yu Minecraft Server 備份腳本
# 作者: Yu-codes
# 日期: 2023

set -e

# 配置
BACKUP_DIR="$(dirname "$0")/../backups"
WORLDS_DIR="$(dirname "$0")/../worlds"
CONFIG_DIR="$(dirname "$0")/../config"
PLUGINS_DIR="$(dirname "$0")/../plugins"
DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="minecraft_backup_${DATE}"

echo "💾 開始備份 Yu Minecraft 伺服器..."

# 創建備份目錄
mkdir -p "$BACKUP_DIR"

# 切換到專案目錄
cd "$(dirname "$0")/.."

# 檢查是否有資料需要備份
if [ ! -d "$WORLDS_DIR" ] && [ ! -d "$CONFIG_DIR" ] && [ ! -d "$PLUGINS_DIR" ]; then
    echo "⚠️  警告: 沒有找到需要備份的資料"
    exit 1
fi

# 如果伺服器正在執行，先儲存世界資料
cd docker
if docker-compose ps | grep -q "Up"; then
    echo "💾 伺服器正在執行，儲存目前世界資料..."
    docker-compose exec -T minecraft rcon-cli --host localhost --port 25575 --password yu-minecraft-2023 "save-all" || true
    docker-compose exec -T minecraft rcon-cli --host localhost --port 25575 --password yu-minecraft-2023 "save-off" || true
    
    # 等待儲存完成
    sleep 5
    
    echo "📁 創建備份..."
    # 創建備份壓縮包
    cd ..
    tar -czf "$BACKUP_DIR/$BACKUP_NAME.tar.gz" \
        --exclude="*.log" \
        --exclude="cache" \
        --exclude="crash-reports" \
        worlds/ config/ plugins/ 2>/dev/null || true
    
    # 重新啟用自動儲存
    cd docker
    docker-compose exec -T minecraft rcon-cli --host localhost --port 25575 --password yu-minecraft-2023 "save-on" || true
    
else
    echo "📁 伺服器未執行，直接創建備份..."
    cd ..
    tar -czf "$BACKUP_DIR/$BACKUP_NAME.tar.gz" \
        --exclude="*.log" \
        --exclude="cache" \
        --exclude="crash-reports" \
        worlds/ config/ plugins/ 2>/dev/null || true
fi

# 檢查備份是否成功創建
if [ -f "$BACKUP_DIR/$BACKUP_NAME.tar.gz" ]; then
    BACKUP_SIZE=$(du -h "$BACKUP_DIR/$BACKUP_NAME.tar.gz" | cut -f1)
    echo "✅ 備份創建成功!"
    echo "📁 備份檔案: $BACKUP_DIR/$BACKUP_NAME.tar.gz"
    echo "📊 備份大小: $BACKUP_SIZE"
else
    echo "❌ 備份創建失敗!"
    exit 1
fi

# 清理舊備份 (保留最近7個備份)
echo "🧹 清理舊備份檔案..."
cd "$BACKUP_DIR"
ls -t minecraft_backup_*.tar.gz 2>/dev/null | tail -n +8 | xargs rm -f 2>/dev/null || true

REMAINING_BACKUPS=$(ls minecraft_backup_*.tar.gz 2>/dev/null | wc -l)
echo "📈 目前保留備份數量: $REMAINING_BACKUPS"

echo ""
echo "🔧 備份管理指令:"
echo "   ls -la $BACKUP_DIR/          # 查看所有備份"
echo "   tar -tzf <backup_file>       # 查看備份內容"
echo "   tar -xzf <backup_file>       # 恢復備份"
