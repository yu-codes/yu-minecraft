#!/bin/bash

# Yu Minecraft 外掛管理系統 v1.0
echo "=== Yu Minecraft 外掛管理系統 ==="

# 路徑設定
PLUGINS_DIR="/Users/yuhan/Side-Project/yu-minecraft/plugins"
BACKUP_DIR="/Users/yuhan/Side-Project/yu-minecraft/backups/plugins"

# 創建備份目錄
mkdir -p "$BACKUP_DIR"

# 外掛資料庫 - 使用陣列而非關聯陣列
PLUGIN_NAMES=("EssentialsX" "Vault" "LuckPerms" "ProtocolLib" "ChestShop")
PLUGIN_URLS=(
    "https://github.com/EssentialsX/Essentials/releases/download/2.21.0/EssentialsX-2.21.0.jar"
    "https://github.com/milkbowl/Vault/releases/download/1.7.3/Vault.jar"
    "https://download.luckperms.net/1548/bukkit/loader/LuckPerms-Bukkit-5.4.139.jar"
    "https://github.com/dmulloy2/ProtocolLib/releases/download/5.2.0/ProtocolLib.jar"
    "https://github.com/ChestShop-authors/ChestShop-3/releases/download/3.12.2/ChestShop.jar"
)
PLUGIN_DESCS=(
    "基礎伺服器指令套件"
    "經濟系統API"
    "權限管理系統"
    "協議庫"
    "商店系統"
)

# 功能1: 列出已安裝外掛
list_installed() {
    echo "已安裝外掛:"
    echo "----------------"
    
    count=0
    for jar_file in "$PLUGINS_DIR"/*.jar; do
        if [ -f "$jar_file" ]; then
            name=$(basename "$jar_file" .jar)
            size=$(du -h "$jar_file" | cut -f1 2>/dev/null || echo "未知")
            echo "✓ $name ($size)"
            count=$((count + 1))
        fi
    done
    
    echo "----------------"
    echo "總計: $count 個外掛"
}

# 功能2: 瀏覽可用外掛
browse_available() {
    echo "可用外掛:"
    echo "----------------"
    
    for i in "${!PLUGIN_NAMES[@]}"; do
        plugin_name="${PLUGIN_NAMES[$i]}"
        desc="${PLUGIN_DESCS[$i]}"
        
        # 檢查是否已安裝
        if [ -f "$PLUGINS_DIR/${plugin_name}.jar" ]; then
            status="[已安裝]"
        else
            status="[可安裝]"
        fi
        
        echo "• $plugin_name $status"
        echo "  $desc"
        echo ""
    done
}

# 功能3: 安裝外掛
install_plugin() {
    local plugin_name="$1"
    
    if [ -z "$plugin_name" ]; then
        echo "錯誤: 請指定外掛名稱"
        echo "可用外掛: ${PLUGIN_NAMES[*]}"
        return 1
    fi
    
    # 尋找外掛在陣列中的位置
    local plugin_index=-1
    for i in "${!PLUGIN_NAMES[@]}"; do
        if [ "${PLUGIN_NAMES[$i]}" = "$plugin_name" ]; then
            plugin_index=$i
            break
        fi
    done
    
    # 檢查外掛是否存在於資料庫
    if [ $plugin_index -eq -1 ]; then
        echo "錯誤: 找不到外掛 '$plugin_name'"
        echo "可用外掛: ${PLUGIN_NAMES[*]}"
        return 1
    fi
    
    # 檢查是否已安裝
    if [ -f "$PLUGINS_DIR/${plugin_name}.jar" ]; then
        echo "外掛 $plugin_name 已經安裝"
        echo "如需重新安裝，請先移除現有版本"
        return 1
    fi
    
    # 取得下載URL和描述
    local url="${PLUGIN_URLS[$plugin_index]}"
    local desc="${PLUGIN_DESCS[$plugin_index]}"
    
    echo "安裝外掛: $plugin_name"
    echo "描述: $desc"
    echo "正在下載..."
    
    # 下載外掛
    if curl -L -o "$PLUGINS_DIR/${plugin_name}.jar" "$url" 2>/dev/null; then
        if [ -f "$PLUGINS_DIR/${plugin_name}.jar" ]; then
            size=$(du -h "$PLUGINS_DIR/${plugin_name}.jar" | cut -f1)
            echo "✓ $plugin_name 安裝成功 ($size)"
            echo "請重啟伺服器以載入外掛"
        else
            echo "✗ 下載失敗"
            return 1
        fi
    else
        echo "✗ 下載失敗"
        return 1
    fi
}

# 功能4: 移除外掛
remove_plugin() {
    local plugin_name="$1"
    
    if [ -z "$plugin_name" ]; then
        echo "錯誤: 請指定外掛名稱"
        echo "已安裝外掛請執行: $0 list"
        return 1
    fi
    
    local jar_file="$PLUGINS_DIR/${plugin_name}.jar"
    
    # 檢查外掛是否存在
    if [ ! -f "$jar_file" ]; then
        echo "錯誤: 外掛 '$plugin_name' 未安裝"
        return 1
    fi
    
    echo "移除外掛: $plugin_name"
    
    # 備份外掛
    local backup_file="$BACKUP_DIR/${plugin_name}_$(date +%Y%m%d_%H%M%S).jar"
    cp "$jar_file" "$backup_file"
    echo "已備份至: $backup_file"
    
    # 移除外掛
    if rm "$jar_file"; then
        echo "✓ $plugin_name 移除成功"
        echo "請重啟伺服器以完全卸載外掛"
    else
        echo "✗ 移除失敗"
        return 1
    fi
}

# 功能5: 顯示使用說明
show_help() {
    echo "使用方式:"
    echo "  $0 list           - 列出已安裝外掛"
    echo "  $0 browse         - 瀏覽可用外掛"
    echo "  $0 install <名稱> - 安裝外掛"
    echo "  $0 remove <名稱>  - 移除外掛"
    echo "  $0 help           - 顯示此說明"
    echo ""
    echo "範例:"
    echo "  $0 list               # 列出已安裝外掛"
    echo "  $0 browse             # 瀏覽可用外掛"
    echo "  $0 install LuckPerms  # 安裝權限管理外掛"
    echo "  $0 remove Vault       # 移除Vault外掛"
    echo ""
    echo "可用外掛列表:"
    for i in "${!PLUGIN_NAMES[@]}"; do
        echo "  ${PLUGIN_NAMES[$i]} - ${PLUGIN_DESCS[$i]}"
    done
}

# 主程序
case "${1:-list}" in
    "list")
        list_installed
        ;;
    "browse"|"available")
        browse_available
        ;;
    "install")
        install_plugin "$2"
        ;;
    "remove"|"uninstall")
        remove_plugin "$2"
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        echo "未知指令: $1"
        echo ""
        show_help
        ;;
esac
