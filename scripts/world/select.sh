#!/bin/bash

# 世界選擇/切換腳本
# 用於選擇和切換 Minecraft 世界

set -e

# 配置
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WORLDS_DIR="$PROJECT_ROOT/worlds"

# 顏色設定
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🌍 選擇世界${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 列出可用世界
worlds=()
for world_dir in "$WORLDS_DIR"/*; do
    if [ -d "$world_dir" ] && [ "$(basename "$world_dir")" != "current" ]; then
        world_name=$(basename "$world_dir")
        if [ "$world_name" != "README.md" ]; then
            worlds+=("$world_name")
        fi
    fi
done

if [ ${#worlds[@]} -eq 0 ]; then
    echo -e "${RED}沒有找到任何世界${NC}"
    exit 1
fi

echo "可用世界："
for i in "${!worlds[@]}"; do
    echo "  $((i+1))) ${worlds[i]}"
done
echo "  0) 取消"
echo

read -p "請選擇要切換的世界 [0-${#worlds[@]}]: " choice

if [ "$choice" = "0" ]; then
    echo "已取消"
    exit 0
fi

if [ "$choice" -ge 1 ] && [ "$choice" -le "${#worlds[@]}" ]; then
    selected_world="${worlds[$((choice-1))]}"
    
    # 檢查世界目錄是否存在
    if [ ! -d "$WORLDS_DIR/$selected_world" ]; then
        echo -e "${RED}錯誤: 世界 '$selected_world' 不存在${NC}"
        exit 1
    fi
    
    # 切換世界
    echo -e "${YELLOW}正在切換到世界: $selected_world${NC}"
    
    # 移除舊的符號連結
    if [ -L "$WORLDS_DIR/current" ]; then
        rm "$WORLDS_DIR/current"
    fi
    
    # 建立新的符號連結
    ln -s "$selected_world" "$WORLDS_DIR/current"
    
    echo -e "${GREEN}✅ 成功切換到世界: $selected_world${NC}"
    echo -e "${BLUE}重啟伺服器以應用變更？ [y/N]${NC}"
    read -p "> " restart_choice
    
    if [ "$restart_choice" = "y" ] || [ "$restart_choice" = "Y" ]; then
        echo -e "${BLUE}🔄 重啟伺服器...${NC}"
        cd "$PROJECT_ROOT"
        docker compose -f docker/docker-compose.yml down
        sleep 3
        docker compose -f docker/docker-compose.yml up -d
        echo -e "${GREEN}✅ 伺服器已重啟${NC}"
    fi
else
    echo -e "${RED}無效選項${NC}"
    exit 1
fi
