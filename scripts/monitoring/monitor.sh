#!/bin/bash

# Yu Minecraft Server 監控腳本
# 作者: Yu-codes
# 日期: 2023

set -e

# 配置
MONITOR_LOG="/tmp/minecraft_monitor.log"
ALERT_THRESHOLD_CPU=80
ALERT_THRESHOLD_MEMORY=85
ALERT_THRESHOLD_DISK=90
CHECK_INTERVAL=30

echo "🔍 啟動 Yu Minecraft 伺服器監控系統..."

# 初始化監控記錄
init_monitor() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] 監控系統啟動" > "$MONITOR_LOG"
}

# 檢查伺服器狀態
check_server_status() {
    cd "$(dirname "$0")/../docker"
    
    if docker compose ps | grep -q "Up"; then
        echo "ONLINE"
    else
        echo "OFFLINE"
    fi
}

# 獲取最大玩家數 (從當前世界配置)
get_max_players() {
    local current_world_dir=""
    local server_properties=""
    
    # 檢查當前世界
    if [ -L "$(dirname "$0")/../../worlds/current" ]; then
        current_world_dir=$(readlink "$(dirname "$0")/../../worlds/current")
        current_world_dir=$(basename "$current_world_dir")
        
        # 嘗試從世界特定配置讀取
        local world_config="$(dirname "$0")/../../worlds/$current_world_dir/server.properties"
        if [ -f "$world_config" ]; then
            server_properties="$world_config"
        fi
    fi
    
    # 如果沒有世界特定配置，使用全域配置
    if [ -z "$server_properties" ] || [ ! -f "$server_properties" ]; then
        server_properties="$(dirname "$0")/../../config/global/server.properties"
    fi
    
    # 最後備用選項
    if [ ! -f "$server_properties" ]; then
        server_properties="$(dirname "$0")/../../config/server.properties"
    fi
    
    # 讀取最大玩家數
    if [ -f "$server_properties" ]; then
        grep "max-players=" "$server_properties" 2>/dev/null | cut -d'=' -f2 | tr -d ' ' || echo "20"
    else
        echo "20"
    fi
}

# 獲取線上玩家數量
get_online_players() {
    cd "$(dirname "$0")/../docker"
    
    if docker compose ps | grep -q "Up"; then
        # 使用RCON獲取線上玩家
        PLAYERS=$(docker compose exec -T minecraft rcon-cli --host localhost --port 25575 --password yu-minecraft-2025 "list" 2>/dev/null | grep -o "There are [0-9]*" | grep -o "[0-9]*" || echo "0")
        echo "${PLAYERS:-0}"
    else
        echo "0"
    fi
}

# 獲取系統資源使用情況
get_system_resources() {
    # CPU使用率
    CPU_USAGE=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//' 2>/dev/null || echo "0")
    
    # 記憶體使用率
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        MEMORY_INFO=$(vm_stat)
        PAGES_FREE=$(echo "$MEMORY_INFO" | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
        PAGES_ACTIVE=$(echo "$MEMORY_INFO" | grep "Pages active" | awk '{print $3}' | sed 's/\.//')
        PAGES_INACTIVE=$(echo "$MEMORY_INFO" | grep "Pages inactive" | awk '{print $3}' | sed 's/\.//')
        PAGES_SPECULATIVE=$(echo "$MEMORY_INFO" | grep "Pages speculative" | awk '{print $3}' | sed 's/\.//')
        PAGES_WIRED=$(echo "$MEMORY_INFO" | grep "Pages wired down" | awk '{print $4}' | sed 's/\.//')
        
        TOTAL_PAGES=$((PAGES_FREE + PAGES_ACTIVE + PAGES_INACTIVE + PAGES_SPECULATIVE + PAGES_WIRED))
        USED_PAGES=$((PAGES_ACTIVE + PAGES_INACTIVE + PAGES_SPECULATIVE + PAGES_WIRED))
        MEMORY_USAGE=$((USED_PAGES * 100 / TOTAL_PAGES))
    else
        # Linux
        MEMORY_USAGE=$(free | grep Mem | awk '{printf("%.0f", $3/$2 * 100.0)}')
    fi
    
    # 磁碟使用率
    DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    
    echo "${CPU_USAGE:-0},${MEMORY_USAGE:-0},${DISK_USAGE:-0}"
}

# 檢查Docker容器健康狀態
check_container_health() {
    cd "$(dirname "$0")/../docker"
    
    if docker compose ps | grep -q "Up"; then
        # 檢查容器記憶體使用
        CONTAINER_MEMORY=$(docker stats --no-stream --format "table {{.MemPerc}}" yu-minecraft-server 2>/dev/null | tail -n 1 | sed 's/%//' || echo "0")
        
        # 檢查容器CPU使用
        CONTAINER_CPU=$(docker stats --no-stream --format "table {{.CPUPerc}}" yu-minecraft-server 2>/dev/null | tail -n 1 | sed 's/%//' || echo "0")
        
        echo "${CONTAINER_CPU:-0},${CONTAINER_MEMORY:-0}"
    else
        echo "0,0"
    fi
}

# 生成監控報告
generate_report() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local server_status=$(check_server_status)
    local online_players=$(get_online_players)
    local max_players=$(get_max_players)
    local system_resources=$(get_system_resources)
    local container_health=$(check_container_health)
    
    # 解析系統資源
    IFS=',' read -r cpu_usage memory_usage disk_usage <<< "$system_resources"
    IFS=',' read -r container_cpu container_memory <<< "$container_health"
    
    # 獲取當前世界信息
    local current_world="未知"
    if [ -L "$(dirname "$0")/../../worlds/current" ]; then
        current_world=$(basename "$(readlink "$(dirname "$0")/../../worlds/current")")
    fi
    
    # 記錄到監控日誌
    echo "[$timestamp] WORLD:$current_world STATUS:$server_status PLAYERS:$online_players/$max_players CPU:$cpu_usage% MEM:$memory_usage% DISK:$disk_usage% CONTAINER_CPU:$container_cpu% CONTAINER_MEM:$container_memory%" >> "$MONITOR_LOG"
    
    # 輸出到控制台
    echo "📊 監控報告 - $timestamp"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🌍 當前世界: $current_world"
    echo "🟢 伺服器狀態: $server_status"
    echo "👥 線上玩家: $online_players / $max_players"
    echo "💻 系統 CPU: $cpu_usage%"
    echo "🧠 系統記憶體: $memory_usage%"
    echo "💾 磁碟使用: $disk_usage%"
    echo "🐳 容器 CPU: $container_cpu%"
    echo "🐳 容器記憶體: $container_memory%"
    echo ""
    
    # 檢查警告閾值
    check_alerts "$cpu_usage" "$memory_usage" "$disk_usage" "$server_status"
}

# 檢查警告
check_alerts() {
    local cpu=$1
    local memory=$2
    local disk=$3
    local status=$4
    
    if [ "$status" = "OFFLINE" ]; then
        echo "🚨 警告: 伺服器離線!"
        log_alert "伺服器離線"
    fi
    
    if [ "${cpu%.*}" -gt "$ALERT_THRESHOLD_CPU" ]; then
        echo "⚠️ 警告: CPU使用率過高 ($cpu%)"
        log_alert "CPU使用率過高: $cpu%"
    fi
    
    if [ "${memory%.*}" -gt "$ALERT_THRESHOLD_MEMORY" ]; then
        echo "⚠️ 警告: 記憶體使用率過高 ($memory%)"
        log_alert "記憶體使用率過高: $memory%"
    fi
    
    if [ "${disk%.*}" -gt "$ALERT_THRESHOLD_DISK" ]; then
        echo "⚠️ 警告: 磁碟使用率過高 ($disk%)"
        log_alert "磁碟使用率過高: $disk%"
    fi
}

# 記錄警告
log_alert() {
    local alert_message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] ALERT: $alert_message" >> "$MONITOR_LOG"
}

# 顯示監控記錄
show_logs() {
    if [ -f "$MONITOR_LOG" ]; then
        echo "📜 最近的監控記錄:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        tail -20 "$MONITOR_LOG"
    else
        echo "📜 尚無監控記錄"
    fi
}

# 連續監控模式
continuous_monitor() {
    echo "🔄 開始連續監控模式 (每 $CHECK_INTERVAL 秒檢查一次)"
    echo "按 Ctrl+C 停止監控"
    
    init_monitor
    
    while true; do
        generate_report
        sleep "$CHECK_INTERVAL"
    done
}

# 踢除玩家
kick_player() {
    local player_name="$1"
    
    if [ -z "$player_name" ]; then
        echo "❌ 錯誤: 請指定要踢除的玩家名稱"
        echo "使用方式: $0 kick <玩家名稱>"
        exit 1
    fi
    
    echo "🚪 正在踢除玩家: $player_name"
    
    cd "$(dirname "$0")/../../docker"
    
    # 檢查伺服器是否在線
    if ! docker compose ps | grep -q "Up"; then
        echo "❌ 錯誤: 伺服器未運行"
        exit 1
    fi
    
    # 執行踢除指令
    echo "📡 發送踢除指令..."
    
    # 使用 Python RCON 客戶端 (絕對路徑)
    local rcon_script="/Users/yuhan/Side-Project/yu-minecraft/scripts/monitoring/rcon_client.py"
    local rcon_result=$(python3 "$rcon_script" "kick $player_name" 2>&1)
    local rcon_exit_code=$?
    
    if [ $rcon_exit_code -eq 0 ]; then
        echo "✅ 成功: 玩家 $player_name 已被踢除"
        echo "📋 伺服器回應: $rcon_result"
        
        # 記錄到監控日誌
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        echo "[$timestamp] ACTION: 玩家 $player_name 被踢除" >> "$MONITOR_LOG"
        
        # 等待一下再檢查玩家是否真的被踢除
        echo "🔍 驗證踢除結果..."
        sleep 2
        local verify_result=$(python3 "$rcon_script" "list" 2>&1)
        if [[ "$verify_result" != *"$player_name"* ]]; then
            echo "✅ 確認: 玩家 $player_name 已不在線上"
        else
            echo "⚠️  警告: 玩家可能仍在線上，請檢查"
        fi
    else
        echo "❌ 錯誤: 踢除玩家失敗"
        echo "📋 錯誤詳情: $rcon_result"
        echo "可能原因:"
        echo "  - 玩家不在線上"
        echo "  - 玩家名稱錯誤"
        echo "  - RCON 連接失敗"
        echo "  - 伺服器未啟用 RCON"
        exit 1
    fi
}

# 封禁玩家
ban_player() {
    local player_name="$1"
    
    if [ -z "$player_name" ]; then
        echo "❌ 錯誤: 請指定要封禁的玩家名稱"
        echo "使用方式: $0 ban <玩家名稱>"
        exit 1
    fi
    
    echo "🚫 正在封禁玩家: $player_name"
    
    cd "$(dirname "$0")/../../docker"
    
    # 檢查伺服器是否在線
    if ! docker compose ps | grep -q "Up"; then
        echo "❌ 錯誤: 伺服器未運行"
        exit 1
    fi
    
    # 執行封禁指令
    echo "📡 發送封禁指令..."
    
    # 使用 Python RCON 客戶端 (絕對路徑)
    local rcon_script="/Users/yuhan/Side-Project/yu-minecraft/scripts/monitoring/rcon_client.py"
    local rcon_result=$(python3 "$rcon_script" "ban $player_name" 2>&1)
    local rcon_exit_code=$?
    
    if [ $rcon_exit_code -eq 0 ]; then
        echo "✅ 成功: 玩家 $player_name 已被封禁"
        echo "📋 伺服器回應: $rcon_result"
        
        # 記錄到監控日誌
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        echo "[$timestamp] ACTION: 玩家 $player_name 被封禁" >> "$MONITOR_LOG"
    else
        echo "❌ 錯誤: 封禁玩家失敗"
        echo "📋 錯誤詳情: $rcon_result"
        exit 1
    fi
}

# 主程式
case "${1:-once}" in
    "once")
        generate_report
        ;;
    "continuous")
        continuous_monitor
        ;;
    "logs")
        show_logs
        ;;
    "kick")
        kick_player "$2"
        ;;
    "ban")
        ban_player "$2"
        ;;
    "help"|"-h"|"--help")
        echo "使用方式: $0 [once|continuous|logs|kick|ban|help]"
        echo ""
        echo "選項:"
        echo "  once           執行一次監控檢查 (預設)"
        echo "  continuous     連續監控模式"
        echo "  logs           顯示監控記錄"
        echo "  kick <玩家>    踢除指定玩家"
        echo "  ban <玩家>     封禁指定玩家"
        echo "  help           顯示此說明"
        ;;
    *)
        echo "❌ 未知選項: $1"
        echo "使用 '$0 help' 查看可用選項"
        exit 1
        ;;
esac
