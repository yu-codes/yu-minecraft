#!/bin/bash

# 世界列表顯示腳本
# 用於顯示所有可用的 Minecraft 世界

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

echo -e "${BLUE}🌍 可用世界列表:${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ ! -d "$WORLDS_DIR" ]; then
    echo -e "${RED}錯誤: worlds 目錄不存在${NC}"
    exit 1
fi

current_world=""
if [ -L "$WORLDS_DIR/current" ]; then
    current_world=$(readlink "$WORLDS_DIR/current")
fi

count=0
for world_dir in "$WORLDS_DIR"/*; do
    if [ -d "$world_dir" ] && [ "$(basename "$world_dir")" != "current" ]; then
        world_name=$(basename "$world_dir")
        if [ "$world_name" != "README.md" ]; then
            if [ "$world_name" = "$current_world" ]; then
                echo -e "  ${GREEN}✓ $world_name (當前使用)${NC}"
            else
                echo -e "    $world_name"
            fi
            count=$((count + 1))
        fi
    fi
done

if [ $count -eq 0 ]; then
    echo -e "${YELLOW}沒有找到任何世界${NC}"
fi

echo
echo -e "${BLUE}總共找到 $count 個世界${NC}"
