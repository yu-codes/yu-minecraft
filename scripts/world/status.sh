#!/bin/bash

# 世界狀態檢查腳本
# 用於查看當前世界狀態和詳細資訊

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

echo -e "${BLUE}🌍 世界狀態${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -L "$WORLDS_DIR/current" ]; then
    current_world=$(readlink "$WORLDS_DIR/current")
    echo -e "${GREEN}當前世界: $current_world${NC}"
    
    world_path="$WORLDS_DIR/$current_world"
    if [ -d "$world_path" ]; then
        echo "世界路徑: $world_path"
        
        # 檢查世界檔案
        if [ -f "$world_path/level.dat" ]; then
            echo -e "${GREEN}✓ level.dat 存在${NC}"
            
            # 獲取世界大小
            world_size=$(du -sh "$world_path" 2>/dev/null | cut -f1)
            echo "世界大小: $world_size"
            
            # 獲取最後修改時間
            last_modified=$(stat -f "%Sm" "$world_path/level.dat" 2>/dev/null || echo "未知")
            echo "最後修改: $last_modified"
        else
            echo -e "${RED}✗ level.dat 不存在${NC}"
        fi
        
        # 檢查重要目錄
        dirs=("region" "data" "playerdata" "DIM-1" "DIM1")
        echo
        echo "目錄檢查："
        for dir in "${dirs[@]}"; do
            if [ -d "$world_path/$dir" ]; then
                file_count=$(find "$world_path/$dir" -type f 2>/dev/null | wc -l | tr -d ' ')
                echo -e "${GREEN}✓ $dir/ ($file_count 個檔案)${NC}"
            else
                echo -e "${YELLOW}- $dir/ 目錄不存在${NC}"
            fi
        done
        
        # 檢查玩家資料
        if [ -d "$world_path/playerdata" ]; then
            player_count=$(find "$world_path/playerdata" -name "*.dat" 2>/dev/null | wc -l | tr -d ' ')
            echo
            echo -e "${BLUE}玩家資料: $player_count 個玩家${NC}"
        fi
        
    else
        echo -e "${RED}錯誤: 世界目錄不存在${NC}"
    fi
else
    echo -e "${RED}沒有設定當前世界${NC}"
fi

echo
echo -e "${BLUE}Docker 掛載狀態:${NC}"
if [ -L "$WORLDS_DIR/current" ]; then
    echo -e "${GREEN}✓ 符號連結正常${NC}"
else
    echo -e "${RED}✗ 符號連結異常${NC}"
fi
