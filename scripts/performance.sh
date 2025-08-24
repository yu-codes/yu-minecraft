#!/bin/bash

# Yu Minecraft Server 效能監控腳本
# 作者: Yu-codes
# 日期: 2023

set -e

# 配置
PERFORMANCE_LOG_DIR="$(dirname "$0")/../logs/performance"
TPS_LOG="$PERFORMANCE_LOG_DIR/tps.log"
MEMORY_LOG="$PERFORMANCE_LOG_DIR/memory.log"
PLAYER_LOG="$PERFORMANCE_LOG_DIR/players.log"

echo "⚡ Yu Minecraft 伺服器效能監控"

# 創建記錄目錄
mkdir -p "$PERFORMANCE_LOG_DIR"

# 獲取伺服器TPS
get_server_tps() {
    cd "$(dirname "$0")/../docker"
    
    if docker-compose ps | grep -q "Up"; then
        # 使用RCON獲取TPS
        TPS_OUTPUT=$(docker-compose exec -T minecraft rcon-cli --host localhost --port 25575 --password yu-minecraft-2025 "forge tps" 2>/dev/null || echo "N/A")
        echo "$TPS_OUTPUT" | grep -o "[0-9]*\.[0-9]*" | head -1 || echo "20.0"
    else
        echo "0.0"
    fi
}

# 獲取記憶體使用情況
get_memory_usage() {
    cd "$(dirname "$0")/../docker"
    
    if docker-compose ps | grep -q "Up"; then
        # 獲取JVM記憶體使用
        MEMORY_INFO=$(docker-compose exec -T minecraft rcon-cli --host localhost --port 25575 --password yu-minecraft-2025 "memory" 2>/dev/null || echo "Used: 0MB Total: 0MB")
        
        USED_MEMORY=$(echo "$MEMORY_INFO" | grep -o "Used: [0-9]*" | grep -o "[0-9]*" || echo "0")
        TOTAL_MEMORY=$(echo "$MEMORY_INFO" | grep -o "Total: [0-9]*" | grep -o "[0-9]*" || echo "1")
        
        USAGE_PERCENT=$((USED_MEMORY * 100 / TOTAL_MEMORY))
        echo "$USED_MEMORY,$TOTAL_MEMORY,$USAGE_PERCENT"
    else
        echo "0,0,0"
    fi
}

# 獲取玩家連線統計
get_player_stats() {
    cd "$(dirname "$0")/../docker"
    
    if docker-compose ps | grep -q "Up"; then
        # 獲取線上玩家數量
        ONLINE_COUNT=$(docker-compose exec -T minecraft rcon-cli --host localhost --port 25575 --password yu-minecraft-2025 "list" 2>/dev/null | grep -o "There are [0-9]*" | grep -o "[0-9]*" || echo "0")
        
        # 獲取最大玩家數
        MAX_PLAYERS=$(grep "max-players" ../config/server.properties | cut -d'=' -f2 || echo "20")
        
        echo "$ONLINE_COUNT,$MAX_PLAYERS"
    else
        echo "0,20"
    fi
}

# 記錄效能資料
log_performance() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local tps=$(get_server_tps)
    local memory_info=$(get_memory_usage)
    local player_info=$(get_player_stats)
    
    # 記錄TPS
    echo "$timestamp,$tps" >> "$TPS_LOG"
    
    # 記錄記憶體使用
    echo "$timestamp,$memory_info" >> "$MEMORY_LOG"
    
    # 記錄玩家統計
    echo "$timestamp,$player_info" >> "$PLAYER_LOG"
    
    # 輸出到控制台
    IFS=',' read -r used_mem total_mem mem_percent <<< "$memory_info"
    IFS=',' read -r online_players max_players <<< "$player_info"
    
    echo "📊 效能監控 - $timestamp"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⚡ TPS: $tps"
    echo "🧠 記憶體: ${used_mem}MB / ${total_mem}MB (${mem_percent}%)"
    echo "👥 玩家: $online_players / $max_players"
    echo ""
    
    # 效能警告
    check_performance_alerts "$tps" "$mem_percent" "$online_players"
}

# 效能警告檢查
check_performance_alerts() {
    local tps=$1
    local memory_percent=$2
    local online_players=$3
    
    # TPS警告
    if (( $(echo "$tps < 15.0" | bc -l) )); then
        echo "⚠️ 效能警告: TPS過低 ($tps)"
    fi
    
    # 記憶體警告
    if [ "$memory_percent" -gt 90 ]; then
        echo "⚠️ 記憶體警告: 使用率過高 ($memory_percent%)"
    fi
    
    # 玩家負載警告
    if [ "$online_players" -gt 15 ]; then
        echo "ℹ️ 資訊: 高玩家負載 ($online_players 人線上)"
    fi
}

# 生成效能報告
generate_performance_report() {
    echo "📈 效能分析報告"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [ -f "$TPS_LOG" ]; then
        echo "⚡ TPS 統計 (最近24小時):"
        tail -1440 "$TPS_LOG" | awk -F',' '{sum+=$2; count++} END {if(count>0) printf "   平均: %.2f\n", sum/count}'
        tail -1440 "$TPS_LOG" | awk -F',' '{if(NR==1 || $2<min) min=$2} END {printf "   最低: %.2f\n", min}'
        tail -1440 "$TPS_LOG" | awk -F',' '{if(NR==1 || $2>max) max=$2} END {printf "   最高: %.2f\n", max}'
        echo ""
    fi
    
    if [ -f "$MEMORY_LOG" ]; then
        echo "🧠 記憶體使用統計 (最近24小時):"
        tail -1440 "$MEMORY_LOG" | awk -F',' '{sum+=$4; count++} END {if(count>0) printf "   平均使用率: %.1f%%\n", sum/count}'
        tail -1440 "$MEMORY_LOG" | awk -F',' '{if(NR==1 || $4>max) max=$4} END {printf "   最高使用率: %.1f%%\n", max}'
        echo ""
    fi
    
    if [ -f "$PLAYER_LOG" ]; then
        echo "👥 玩家統計 (最近24小時):"
        tail -1440 "$PLAYER_LOG" | awk -F',' '{sum+=$2; count++} END {if(count>0) printf "   平均線上人數: %.1f\n", sum/count}'
        tail -1440 "$PLAYER_LOG" | awk -F',' '{if(NR==1 || $2>max) max=$2} END {printf "   最高線上人數: %d\n", max}'
        echo ""
    fi
}

# 清理舊記錄
cleanup_old_logs() {
    echo "🧹 清理7天前的效能記錄..."
    
    find "$PERFORMANCE_LOG_DIR" -name "*.log" -mtime +7 -delete 2>/dev/null || true
    
    # 保持記錄檔案大小合理
    for log_file in "$TPS_LOG" "$MEMORY_LOG" "$PLAYER_LOG"; do
        if [ -f "$log_file" ] && [ $(wc -l < "$log_file") -gt 10080 ]; then
            tail -5040 "$log_file" > "${log_file}.tmp"
            mv "${log_file}.tmp" "$log_file"
        fi
    done
    
    echo "✅ 記錄清理完成"
}

# 匯出效能資料
export_performance_data() {
    local export_dir="$(dirname "$0")/../exports"
    local export_file="$export_dir/performance_$(date +%Y%m%d_%H%M%S).csv"
    
    mkdir -p "$export_dir"
    
    echo "📊 匯出效能資料到: $export_file"
    
    echo "時間,TPS,已用記憶體(MB),總記憶體(MB),記憶體使用率(%),線上玩家,最大玩家" > "$export_file"
    
    # 合併所有記錄
    if [ -f "$TPS_LOG" ] && [ -f "$MEMORY_LOG" ] && [ -f "$PLAYER_LOG" ]; then
        paste -d',' "$TPS_LOG" "$MEMORY_LOG" "$PLAYER_LOG" | \
        awk -F',' '{print $1","$2","$4","$5","$6","$8","$9}' >> "$export_file"
        
        echo "✅ 資料匯出完成"
    else
        echo "❌ 效能記錄檔案不存在"
    fi
}

# 主程式
case "${1:-log}" in
    "log")
        log_performance
        ;;
    "report")
        generate_performance_report
        ;;
    "cleanup")
        cleanup_old_logs
        ;;
    "export")
        export_performance_data
        ;;
    "help"|"-h"|"--help")
        echo "使用方式: $0 [log|report|cleanup|export|help]"
        echo ""
        echo "選項:"
        echo "  log     記錄目前效能資料 (預設)"
        echo "  report  生成效能分析報告"
        echo "  cleanup 清理舊記錄檔案"
        echo "  export  匯出效能資料為CSV"
        echo "  help    顯示此說明"
        ;;
    *)
        echo "❌ 未知選項: $1"
        echo "使用 '$0 help' 查看可用選項"
        exit 1
        ;;
esac
