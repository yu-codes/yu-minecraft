#!/bin/bash

# Yu Minecraft Server 外掛管理腳本
# 作者: Yu-codes
# 支援世界特定外掛管理

set -e

# 配置路徑
PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
GLOBAL_PLUGINS_DIR="$PROJECT_ROOT/plugins"
WORLDS_DIR="$PROJECT_ROOT/worlds"
BACKUP_DIR="$PROJECT_ROOT/backups/plugins"

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 獲取當前世界
get_current_world() {
    if [ -L "$WORLDS_DIR/current" ]; then
        basename "$(readlink "$WORLDS_DIR/current")"
    else
        echo ""
    fi
}

# 獲取當前世界外掛目錄
get_world_plugins_dir() {
    local world_name=$(get_current_world)
    if [ -z "$world_name" ]; then
        echo "$GLOBAL_PLUGINS_DIR"  # 如果沒有選擇世界，使用全域目錄
    else
        echo "$WORLDS_DIR/$world_name/plugins"
    fi
}

# 確保外掛目錄存在
ensure_plugins_dir() {
    local plugins_dir=$(get_world_plugins_dir)
    mkdir -p "$plugins_dir"
    mkdir -p "$GLOBAL_PLUGINS_DIR"
    mkdir -p "$BACKUP_DIR"
}

# 列出已安裝外掛
list_plugins() {
    local world_name=$(get_current_world)
    local plugins_dir=$(get_world_plugins_dir)
    
    echo -e "${CYAN}📦 Yu Minecraft 外掛管理系統${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [ -n "$world_name" ]; then
        echo -e "${BLUE}🌍 當前世界: $world_name${NC}"
        echo -e "${BLUE}📂 外掛目錄: $plugins_dir${NC}"
    else
        echo -e "${YELLOW}⚠️ 未選擇世界，顯示全域外掛${NC}"
        echo -e "${BLUE}📂 外掛目錄: $plugins_dir${NC}"
    fi
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [ ! -d "$plugins_dir" ]; then
        echo -e "${RED}❌ 外掛目錄不存在${NC}"
        return 1
    fi
    
    local plugin_count=0
    echo -e "${GREEN}📋 已安裝的外掛:${NC}"
    
    for plugin in "$plugins_dir"/*.jar; do
        if [ -f "$plugin" ]; then
            local plugin_name=$(basename "$plugin" .jar)
            local plugin_size=$(du -h "$plugin" | cut -f1)
            local plugin_date=$(date -r "$plugin" "+%Y-%m-%d %H:%M")
            echo "  • $plugin_name ($plugin_size) - $plugin_date"
            ((plugin_count++))
        fi
    done
    
    if [ $plugin_count -eq 0 ]; then
        echo -e "${YELLOW}  目前沒有安裝任何外掛${NC}"
    else
        echo -e "${GREEN}  總計: $plugin_count 個外掛${NC}"
    fi
}

# 瀏覽可用外掛
browse_plugins() {
    echo -e "${CYAN}🔍 可用外掛列表${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    echo -e "${GREEN}📦 推薦外掛:${NC}"
    echo ""
    echo "1. EssentialsX - 基礎伺服器指令套件"
    echo "   • 功能: 傳送、家、經濟等基本指令"
    echo "   • 網址: https://github.com/EssentialsX/Essentials"
    echo ""
    echo "2. Vault - 經濟系統API"
    echo "   • 功能: 為其他外掛提供經濟系統支援"
    echo "   • 網址: https://github.com/MilkBowl/Vault"
    echo ""
    echo "3. LuckPerms - 權限管理系統"
    echo "   • 功能: 完整的權限和群組管理"
    echo "   • 網址: https://luckperms.net"
    echo ""
    echo "4. ProtocolLib - 協議庫"
    echo "   • 功能: 為其他外掛提供網路協議支援"
    echo "   • 網址: https://github.com/dmulloy2/ProtocolLib"
    echo ""
    echo "5. ChestShop - 商店系統"
    echo "   • 功能: 玩家可建立箱子商店"
    echo "   • 網址: https://github.com/ChestShop-authors/ChestShop-3"
    echo ""
    echo -e "${YELLOW}💡 提示: 手動下載 .jar 檔案並放入外掛目錄${NC}"
}

# 安裝外掛 (從全域或網路)
install_plugin() {
    local plugin_name="$1"
    local world_name=$(get_current_world)
    local plugins_dir=$(get_world_plugins_dir)
    
    ensure_plugins_dir
    
    if [ -z "$plugin_name" ]; then
        echo -e "${RED}❌ 請指定外掛名稱${NC}"
        echo "用法: $0 install <外掛名稱>"
        return 1
    fi
    
    echo -e "${BLUE}🔧 安裝外掛: $plugin_name${NC}"
    if [ -n "$world_name" ]; then
        echo -e "${BLUE}🌍 目標世界: $world_name${NC}"
    else
        echo -e "${BLUE}🌐 安裝到: 全域外掛目錄${NC}"
    fi
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # 檢查是否已安裝
    if [ -f "$plugins_dir/${plugin_name}.jar" ]; then
        echo -e "${YELLOW}⚠️ 外掛 '$plugin_name' 已經安裝${NC}"
        read -p "是否要重新安裝? (y/N): " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}ℹ️ 取消安裝${NC}"
            return 0
        fi
    fi
    
    # 嘗試從全域外掛複製
    if [ -f "$GLOBAL_PLUGINS_DIR/${plugin_name}.jar" ] && [ "$plugins_dir" != "$GLOBAL_PLUGINS_DIR" ]; then
        echo -e "${BLUE}📋 從全域外掛複製...${NC}"
        cp "$GLOBAL_PLUGINS_DIR/${plugin_name}.jar" "$plugins_dir/"
        echo -e "${GREEN}✅ 外掛安裝成功${NC}"
        return 0
    fi
    
    # 下載外掛的 URL 映射
    declare -A plugin_urls=(
        ["EssentialsX"]="https://github.com/EssentialsX/Essentials/releases/latest/download/EssentialsX.jar"
        ["Vault"]="https://github.com/MilkBowl/Vault/releases/latest/download/Vault.jar"
        ["LuckPerms"]="https://download.luckperms.net/1515/bukkit/loader/LuckPerms-Bukkit-5.4.102.jar"
        ["ProtocolLib"]="https://github.com/dmulloy2/ProtocolLib/releases/latest/download/ProtocolLib.jar"
    )
    
    local plugin_url="${plugin_urls[$plugin_name]}"
    
    if [ -n "$plugin_url" ]; then
        echo -e "${BLUE}🌐 下載外掛: $plugin_name${NC}"
        echo -e "${BLUE}📥 來源: $plugin_url${NC}"
        
        if command -v curl &> /dev/null; then
            curl -L -o "$plugins_dir/${plugin_name}.jar" "$plugin_url"
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✅ 外掛下載並安裝成功${NC}"
            else
                echo -e "${RED}❌ 下載失敗${NC}"
                return 1
            fi
        else
            echo -e "${RED}❌ 需要 curl 來下載外掛${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}⚠️ 未知外掛: $plugin_name${NC}"
        echo -e "${BLUE}💡 請手動下載 .jar 檔案並放入: $plugins_dir/${NC}"
        echo -e "${BLUE}💡 或使用 'browse' 命令查看可用外掛${NC}"
        return 1
    fi
}

# 移除外掛
remove_plugin() {
    local plugin_name="$1"
    local world_name=$(get_current_world)
    local plugins_dir=$(get_world_plugins_dir)
    
    if [ -z "$plugin_name" ]; then
        echo -e "${RED}❌ 請指定外掛名稱${NC}"
        echo "用法: $0 remove <外掛名稱>"
        return 1
    fi
    
    # 尋找外掛檔案
    local plugin_file=""
    if [ -f "$plugins_dir/${plugin_name}.jar" ]; then
        plugin_file="$plugins_dir/${plugin_name}.jar"
    elif [ -f "$plugins_dir/$plugin_name" ]; then
        plugin_file="$plugins_dir/$plugin_name"
    else
        # 模糊搜尋
        for plugin in "$plugins_dir"/*.jar; do
            if [[ "$(basename "$plugin")" == *"$plugin_name"* ]]; then
                plugin_file="$plugin"
                break
            fi
        done
    fi
    
    if [ -z "$plugin_file" ] || [ ! -f "$plugin_file" ]; then
        echo -e "${RED}❌ 找不到外掛: $plugin_name${NC}"
        return 1
    fi
    
    local plugin_filename=$(basename "$plugin_file")
    echo -e "${YELLOW}⚠️ 即將移除外掛: $plugin_filename${NC}"
    if [ -n "$world_name" ]; then
        echo -e "${BLUE}🌍 從世界: $world_name${NC}"
    fi
    
    # 備份外掛
    backup_plugin "$plugin_file"
    
    # 確認移除
    read -p "確定要移除嗎? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        rm "$plugin_file"
        echo -e "${GREEN}✅ 外掛移除成功: $plugin_filename${NC}"
    else
        echo -e "${BLUE}ℹ️ 取消移除${NC}"
    fi
}

# 備份單個外掛
backup_plugin() {
    local plugin_file="$1"
    local world_name=$(get_current_world)
    
    if [ ! -f "$plugin_file" ]; then
        return 1
    fi
    
    local plugin_name=$(basename "$plugin_file" .jar)
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local backup_filename="${plugin_name}_${timestamp}.jar"
    
    # 根據當前世界決定備份位置
    local backup_location
    if [ -n "$world_name" ]; then
        backup_location="$WORLDS_DIR/$world_name/backups/plugins"
        mkdir -p "$backup_location"
    else
        backup_location="$BACKUP_DIR"
        mkdir -p "$backup_location"
    fi
    
    cp "$plugin_file" "$backup_location/$backup_filename"
    echo -e "${GREEN}💾 外掛已備份到: $backup_location/$backup_filename${NC}"
}

# 備份所有外掛
backup_all_plugins() {
    local world_name=$(get_current_world)
    local plugins_dir=$(get_world_plugins_dir)
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    
    if [ ! -d "$plugins_dir" ]; then
        echo -e "${RED}❌ 外掛目錄不存在${NC}"
        return 1
    fi
    
    # 根據當前世界決定備份位置和檔名
    local backup_location
    local backup_filename
    if [ -n "$world_name" ]; then
        backup_location="$WORLDS_DIR/$world_name/backups"
        backup_filename="plugins_${timestamp}.tar.gz"
    else
        backup_location="$BACKUP_DIR"
        backup_filename="global_plugins_${timestamp}.tar.gz"
    fi
    
    mkdir -p "$backup_location"
    
    echo -e "${BLUE}💾 備份所有外掛...${NC}"
    
    cd "$(dirname "$plugins_dir")"
    tar -czf "$backup_location/$backup_filename" "$(basename "$plugins_dir")"
    
    local backup_size=$(du -h "$backup_location/$backup_filename" | cut -f1)
    
    echo -e "${GREEN}✅ 外掛備份完成${NC}"
    echo -e "${BLUE}📂 備份檔案: $backup_location/$backup_filename${NC}"
    echo -e "${BLUE}📊 備份大小: $backup_size${NC}"
}

# 檢查外掛相依性
check_dependencies() {
    local plugins_dir=$(get_world_plugins_dir)
    
    echo -e "${CYAN}🔍 檢查外掛相依性${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [ ! -d "$plugins_dir" ]; then
        echo -e "${RED}❌ 外掛目錄不存在${NC}"
        return 1
    fi
    
    local has_vault=false
    local has_protocollib=false
    local has_essentials=false
    
    # 檢查已安裝的核心外掛
    for plugin in "$plugins_dir"/*.jar; do
        if [ -f "$plugin" ]; then
            local plugin_name=$(basename "$plugin" .jar)
            case "$plugin_name" in
                *"Vault"*) has_vault=true ;;
                *"ProtocolLib"*) has_protocollib=true ;;
                *"Essentials"*) has_essentials=true ;;
            esac
        fi
    done
    
    echo -e "${GREEN}📋 核心外掛檢查:${NC}"
    echo "  • Vault (經濟API): $([ "$has_vault" = true ] && echo -e "${GREEN}✅ 已安裝${NC}" || echo -e "${YELLOW}⚠️ 未安裝${NC}")"
    echo "  • ProtocolLib (協議庫): $([ "$has_protocollib" = true ] && echo -e "${GREEN}✅ 已安裝${NC}" || echo -e "${YELLOW}⚠️ 未安裝${NC}")"
    echo "  • EssentialsX (基礎指令): $([ "$has_essentials" = true ] && echo -e "${GREEN}✅ 已安裝${NC}" || echo -e "${YELLOW}⚠️ 未安裝${NC}")"
    
    echo ""
    echo -e "${BLUE}💡 建議安裝順序:${NC}"
    echo "  1. Vault (為其他外掛提供經濟API)"
    echo "  2. ProtocolLib (為其他外掛提供協議支援)"
    echo "  3. EssentialsX (基礎伺服器功能)"
    echo "  4. 其他功能性外掛"
}

# 安裝基本外掛套件
install_essentials() {
    echo -e "${BLUE}📦 安裝基本外掛套件${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local essentials=("Vault" "EssentialsX" "ProtocolLib")
    
    for plugin in "${essentials[@]}"; do
        echo -e "${YELLOW}正在安裝: $plugin${NC}"
        install_plugin "$plugin"
        echo ""
    done
    
    echo -e "${GREEN}✅ 基本外掛套件安裝完成${NC}"
}

# 顯示幫助
show_help() {
    echo -e "${CYAN}📦 Yu Minecraft 外掛管理系統${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "用法: $0 [命令] [參數]"
    echo ""
    echo "可用命令:"
    echo "  list                  - 列出已安裝外掛"
    echo "  browse               - 瀏覽可用外掛"
    echo "  install <外掛名稱>   - 安裝外掛"
    echo "  remove <外掛名稱>    - 移除外掛"
    echo "  backup               - 備份所有外掛"
    echo "  check                - 檢查外掛相依性"
    echo "  essentials           - 安裝基本外掛套件"
    echo "  help                 - 顯示此幫助信息"
    echo ""
    echo "支援的外掛:"
    echo "  • EssentialsX - 基礎伺服器指令套件"
    echo "  • Vault - 經濟系統API"
    echo "  • LuckPerms - 權限管理系統"
    echo "  • ProtocolLib - 協議庫"
    echo "  • ChestShop - 商店系統"
    echo ""
    echo "注意:"
    echo "  • 如果選擇了世界，外掛會安裝到該世界"
    echo "  • 如果未選擇世界，外掛會安裝到全域目錄"
    echo "  • 移除外掛前會自動備份"
}

# 主程式
case "${1:-list}" in
    "list"|"ls")
        list_plugins
        ;;
    "browse"|"available")
        browse_plugins
        ;;
    "install"|"add")
        install_plugin "$2"
        ;;
    "remove"|"rm"|"delete")
        remove_plugin "$2"
        ;;
    "backup"|"bak")
        backup_all_plugins
        ;;
    "check"|"deps")
        check_dependencies
        ;;
    "essentials"|"basic")
        install_essentials
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        echo -e "${RED}❌ 未知命令: $1${NC}"
        echo "使用 '$0 help' 查看可用命令"
        exit 1
        ;;
esac
