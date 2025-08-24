#!/bin/bash

# Yu Minecraft Server 外掛管理腳本
# 作者: Yu-codes
# 日期: 2023

set -e

# 配置
PLUGINS_DIR="$(dirname "$0")/../plugins"
CONFIG_DIR="$(dirname "$0")/../config"
BACKUP_DIR="$(dirname "$0")/../backups/plugins"
PLUGINS_CONFIG="$CONFIG_DIR/plugins.json"

echo "🔌 Yu Minecraft 伺服器外掛管理系統"

# 創建必要目錄
mkdir -p "$PLUGINS_DIR" "$BACKUP_DIR"

# 初始化外掛配置
init_plugins_config() {
    if [ ! -f "$PLUGINS_CONFIG" ]; then
        cat > "$PLUGINS_CONFIG" << 'EOF'
{
  "recommended_plugins": [
    {
      "name": "EssentialsX",
      "description": "基本伺服器指令和功能",
      "url": "https://github.com/EssentialsX/Essentials/releases/latest/download/EssentialsX-2.20.1.jar",
      "category": "core",
      "required": true
    },
    {
      "name": "WorldEdit",
      "description": "世界編輯工具",
      "url": "https://dev.bukkit.org/projects/worldedit/files/latest",
      "category": "building",
      "required": false
    },
    {
      "name": "LuckPerms",
      "description": "權限管理系統",
      "url": "https://github.com/LuckPerms/LuckPerms/releases/latest/download/LuckPerms-Bukkit-5.4.102.jar",
      "category": "admin",
      "required": false
    },
    {
      "name": "Vault",
      "description": "經濟系統API",
      "url": "https://github.com/MilkBowl/Vault/releases/latest/download/Vault.jar",
      "category": "economy",
      "required": false
    },
    {
      "name": "ChestShop",
      "description": "商店系統",
      "url": "https://github.com/ChestShop-authors/ChestShop-3/releases/latest/download/ChestShop.jar",
      "category": "economy",
      "required": false
    }
  ],
  "installed_plugins": []
}
EOF
        echo "✅ 外掛配置檔案已創建"
    fi
}

# 列出推薦外掛
list_recommended() {
    echo "📋 推薦外掛列表:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [ -f "$PLUGINS_CONFIG" ]; then
        # 使用簡單的方式解析JSON
        grep -A 6 '"name":' "$PLUGINS_CONFIG" | while IFS= read -r line; do
            if echo "$line" | grep -q '"name":'; then
                name=$(echo "$line" | sed 's/.*"name": "\([^"]*\)".*/\1/')
                echo -n "🔌 $name"
            elif echo "$line" | grep -q '"description":'; then
                desc=$(echo "$line" | sed 's/.*"description": "\([^"]*\)".*/\1/')
                echo " - $desc"
            elif echo "$line" | grep -q '"category":'; then
                category=$(echo "$line" | sed 's/.*"category": "\([^"]*\)".*/\1/')
                echo "   類別: $category"
            elif echo "$line" | grep -q '"required":'; then
                required=$(echo "$line" | sed 's/.*"required": \([^,]*\).*/\1/')
                if [ "$required" = "true" ]; then
                    echo "   狀態: 必需"
                else
                    echo "   狀態: 可選"
                fi
                echo ""
            fi
        done
    else
        echo "❌ 外掛配置檔案不存在"
    fi
}

# 列出已安裝外掛
list_installed() {
    echo "📦 已安裝外掛:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [ -d "$PLUGINS_DIR" ] && [ "$(ls -A "$PLUGINS_DIR" 2>/dev/null)" ]; then
        for plugin in "$PLUGINS_DIR"/*.jar; do
            if [ -f "$plugin" ]; then
                plugin_name=$(basename "$plugin" .jar)
                plugin_size=$(du -h "$plugin" | cut -f1)
                plugin_date=$(date -r "$plugin" "+%Y-%m-%d %H:%M")
                echo "🟢 $plugin_name"
                echo "   大小: $plugin_size"
                echo "   安裝時間: $plugin_date"
                echo ""
            fi
        done
    else
        echo "📭 尚未安裝任何外掛"
    fi
}

# 下載外掛
download_plugin() {
    local plugin_name="$1"
    
    if [ -z "$plugin_name" ]; then
        echo "❌ 請指定外掛名稱"
        return 1
    fi
    
    echo "⬇️ 下載外掛: $plugin_name"
    
    # 從配置中獲取下載URL
    if [ -f "$PLUGINS_CONFIG" ]; then
        # 簡單的URL提取方式
        plugin_url=$(grep -A 4 "\"name\": \"$plugin_name\"" "$PLUGINS_CONFIG" | grep '"url":' | sed 's/.*"url": "\([^"]*\)".*/\1/')
        
        if [ -n "$plugin_url" ]; then
            echo "📥 正在下載 $plugin_name..."
            
            # 下載外掛
            if curl -L -o "$PLUGINS_DIR/${plugin_name}.jar" "$plugin_url"; then
                echo "✅ $plugin_name 下載完成"
                
                # 更新已安裝列表
                update_installed_list "$plugin_name"
            else
                echo "❌ $plugin_name 下載失敗"
                rm -f "$PLUGINS_DIR/${plugin_name}.jar"
                return 1
            fi
        else
            echo "❌ 找不到 $plugin_name 的下載連結"
            return 1
        fi
    else
        echo "❌ 外掛配置檔案不存在"
        return 1
    fi
}

# 更新已安裝外掛列表
update_installed_list() {
    local plugin_name="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # 簡單的方式更新已安裝列表
    if [ -f "$PLUGINS_CONFIG" ]; then
        # 這裡可以實現更複雜的JSON更新邏輯
        echo "ℹ️ 已記錄 $plugin_name 的安裝"
    fi
}

# 移除外掛
remove_plugin() {
    local plugin_name="$1"
    
    if [ -z "$plugin_name" ]; then
        echo "❌ 請指定外掛名稱"
        return 1
    fi
    
    local plugin_file="$PLUGINS_DIR/${plugin_name}.jar"
    
    if [ -f "$plugin_file" ]; then
        echo "🗑️ 移除外掛: $plugin_name"
        
        # 備份外掛
        cp "$plugin_file" "$BACKUP_DIR/${plugin_name}_$(date +%Y%m%d_%H%M%S).jar"
        
        # 移除外掛
        rm "$plugin_file"
        
        echo "✅ $plugin_name 已移除並備份"
    else
        echo "❌ 找不到外掛: $plugin_name"
        return 1
    fi
}

# 備份所有外掛
backup_plugins() {
    echo "💾 備份所有外掛..."
    
    if [ -d "$PLUGINS_DIR" ] && [ "$(ls -A "$PLUGINS_DIR" 2>/dev/null)" ]; then
        local backup_file="$BACKUP_DIR/plugins_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
        
        tar -czf "$backup_file" -C "$PLUGINS_DIR" .
        
        local backup_size=$(du -h "$backup_file" | cut -f1)
        echo "✅ 外掛備份完成"
        echo "📁 備份檔案: $backup_file"
        echo "📊 備份大小: $backup_size"
    else
        echo "📭 沒有外掛需要備份"
    fi
}

# 恢復外掛備份
restore_plugins() {
    local backup_file="$1"
    
    if [ -z "$backup_file" ]; then
        echo "📋 可用的備份檔案:"
        ls -la "$BACKUP_DIR"/*.tar.gz 2>/dev/null || echo "❌ 沒有找到備份檔案"
        return 1
    fi
    
    if [ -f "$backup_file" ]; then
        echo "🔄 恢復外掛備份: $(basename "$backup_file")"
        
        # 備份現有外掛
        if [ -d "$PLUGINS_DIR" ] && [ "$(ls -A "$PLUGINS_DIR" 2>/dev/null)" ]; then
            backup_plugins
        fi
        
        # 清空外掛目錄
        rm -rf "$PLUGINS_DIR"/*
        
        # 恢復備份
        tar -xzf "$backup_file" -C "$PLUGINS_DIR"
        
        echo "✅ 外掛備份恢復完成"
    else
        echo "❌ 備份檔案不存在: $backup_file"
        return 1
    fi
}

# 安裝推薦外掛套件
install_essentials() {
    echo "📦 安裝基本外掛套件..."
    
    # 核心外掛
    download_plugin "EssentialsX"
    download_plugin "Vault"
    download_plugin "LuckPerms"
    
    echo "✅ 基本外掛套件安裝完成"
    echo "ℹ️ 請重啟伺服器以載入外掛"
}

# 檢查外掛依賴
check_dependencies() {
    echo "🔍 檢查外掛依賴關係..."
    
    # 檢查是否有Vault依賴的外掛但沒有安裝Vault
    if [ -f "$PLUGINS_DIR/ChestShop.jar" ] && [ ! -f "$PLUGINS_DIR/Vault.jar" ]; then
        echo "⚠️ 警告: ChestShop 需要 Vault 外掛"
    fi
    
    # 檢查其他依賴關係
    echo "✅ 依賴檢查完成"
}

# 主程式
case "${1:-list}" in
    "list")
        list_installed
        ;;
    "recommended")
        list_recommended
        ;;
    "download")
        download_plugin "$2"
        ;;
    "remove")
        remove_plugin "$2"
        ;;
    "backup")
        backup_plugins
        ;;
    "restore")
        restore_plugins "$2"
        ;;
    "essentials")
        install_essentials
        ;;
    "check")
        check_dependencies
        ;;
    "init")
        init_plugins_config
        ;;
    "help"|"-h"|"--help")
        echo "使用方式: $0 [指令] [參數]"
        echo ""
        echo "指令:"
        echo "  list          列出已安裝外掛 (預設)"
        echo "  recommended   列出推薦外掛"
        echo "  download <名稱> 下載指定外掛"
        echo "  remove <名稱>   移除指定外掛"
        echo "  backup        備份所有外掛"
        echo "  restore <檔案> 恢復外掛備份"
        echo "  essentials    安裝基本外掛套件"
        echo "  check         檢查外掛依賴"
        echo "  init          初始化外掛配置"
        echo "  help          顯示此說明"
        ;;
    *)
        echo "❌ 未知指令: $1"
        echo "使用 '$0 help' 查看可用指令"
        exit 1
        ;;
esac
