#!/bin/bash

# ngrok 自動監控和日誌記錄腳本
# 在背景運行，自動記錄流量和連線狀況

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 設定檔案
LOG_DIR="logs/ngrok"
LOG_FILE="$LOG_DIR/traffic_$(date +%Y%m%d).log"
PID_FILE="$LOG_DIR/monitor.pid"
ALERT_THRESHOLD=50  # 每小時連線數警報閾值

# 建立日誌目錄
mkdir -p "$LOG_DIR"

# 日誌函數
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    echo -e "${BLUE}[$timestamp]${NC} $message"
}

# 檢查 ngrok 是否運行
check_ngrok() {
    if pgrep -f "ngrok tcp" > /dev/null; then
        return 0
    else
        return 1
    fi
}

# 取得 ngrok API 資料
get_ngrok_data() {
    local api_port=${1:-4040}
    curl -s "http://localhost:$api_port/api/tunnels" 2>/dev/null || echo "{}"
}

# 監控函數
monitor_traffic() {
    log_message "INFO" "開始監控 ngrok 流量"
    
    local check_interval=30  # 30 秒檢查一次
    local hour_start=$(date +%s)
    local hour_connections=0
    
    while true; do
        if check_ngrok; then
            local current_time=$(date +%s)
            local api_data=$(get_ngrok_data)
            
            # 每小時重置計數器
            if [ $((current_time - hour_start)) -ge 3600 ]; then
                if [ $hour_connections -gt 0 ]; then
                    log_message "STATS" "小時統計: $hour_connections 個連線"
                fi
                hour_start=$current_time
                hour_connections=0
            fi
            
            # 解析資料（如果有 jq）
            if command -v jq >/dev/null 2>&1 && [ "$api_data" != "{}" ]; then
                local tunnel_count=$(echo "$api_data" | jq '.tunnels | length')
                local tcp_tunnels=$(echo "$api_data" | jq '.tunnels[] | select(.proto == "tcp")')
                
                if [ "$tunnel_count" -gt 0 ]; then
                    echo "$tcp_tunnels" | jq -r 'select(.proto == "tcp") | 
                        .public_url + " -> " + .config.addr + 
                        " (connections: " + (.metrics.conns.count // 0 | tostring) + ")"' | \
                    while read line; do
                        log_message "TUNNEL" "$line"
                        
                        # 提取連線數
                        local conns=$(echo "$line" | grep -o 'connections: [0-9]*' | grep -o '[0-9]*')
                        if [ -n "$conns" ] && [ "$conns" -gt 0 ]; then
                            hour_connections=$((hour_connections + conns))
                            
                            # 檢查警報閾值
                            if [ "$hour_connections" -gt "$ALERT_THRESHOLD" ]; then
                                log_message "ALERT" "小時連線數過高: $hour_connections (閾值: $ALERT_THRESHOLD)"
                            fi
                        fi
                    done
                fi
            else
                log_message "INFO" "ngrok 隧道運行中 (API 資料不可用)"
            fi
        else
            log_message "WARN" "ngrok 隧道未運行"
            sleep 60  # ngrok 未運行時延長檢查間隔
            continue
        fi
        
        sleep $check_interval
    done
}

# 生成每日報告
generate_daily_report() {
    local date_str=${1:-$(date +%Y%m%d)}
    local report_file="$LOG_DIR/daily_report_$date_str.txt"
    local log_file="$LOG_DIR/traffic_$date_str.log"
    
    if [ ! -f "$log_file" ]; then
        echo "日誌檔案不存在: $log_file"
        return 1
    fi
    
    {
        echo "=== ngrok 每日流量報告 - $date_str ==="
        echo "生成時間: $(date)"
        echo
        
        echo "=== 統計摘要 ==="
        local total_connections=$(grep "connections:" "$log_file" | grep -o 'connections: [0-9]*' | grep -o '[0-9]*' | awk '{sum+=$1} END {print sum+0}')
        local tunnel_count=$(grep "\[TUNNEL\]" "$log_file" | wc -l)
        local alert_count=$(grep "\[ALERT\]" "$log_file" | wc -l)
        local uptime_entries=$(grep "\[INFO\].*運行中" "$log_file" | wc -l)
        
        echo "總連線數: $total_connections"
        echo "隧道記錄數: $tunnel_count"
        echo "警報次數: $alert_count"
        echo "運行時間記錄: $uptime_entries"
        echo
        
        echo "=== 警報記錄 ==="
        grep "\[ALERT\]" "$log_file" | head -10 || echo "無警報記錄"
        echo
        
        echo "=== 小時統計 ==="
        grep "\[STATS\]" "$log_file" || echo "無小時統計"
        echo
        
        echo "=== 錯誤記錄 ==="
        grep "\[WARN\]\|\[ERROR\]" "$log_file" | head -5 || echo "無錯誤記錄"
        
    } > "$report_file"
    
    echo "每日報告已生成: $report_file"
}

# 清理舊日誌
cleanup_logs() {
    local days=${1:-7}  # 預設保留 7 天
    find "$LOG_DIR" -name "traffic_*.log" -mtime +$days -delete 2>/dev/null || true
    find "$LOG_DIR" -name "daily_report_*.txt" -mtime +$days -delete 2>/dev/null || true
    log_message "INFO" "清理 $days 天前的舊日誌"
}

# 停止監控
stop_monitor() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
            rm -f "$PID_FILE"
            echo "監控已停止 (PID: $pid)"
        else
            rm -f "$PID_FILE"
            echo "監控程序已不存在"
        fi
    else
        echo "未找到監控程序"
    fi
}

# 顯示狀態
show_status() {
    echo -e "${BLUE}📊 ngrok 監控狀態${NC}"
    echo "=================="
    
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            echo -e "${GREEN}✅ 監控運行中 (PID: $pid)${NC}"
        else
            echo -e "${RED}❌ 監控程序已停止${NC}"
            rm -f "$PID_FILE"
        fi
    else
        echo -e "${YELLOW}⚠️  監控未運行${NC}"
    fi
    
    echo "日誌目錄: $LOG_DIR"
    echo "當日日誌: $LOG_FILE"
    
    if [ -f "$LOG_FILE" ]; then
        local log_size=$(du -h "$LOG_FILE" | cut -f1)
        local log_lines=$(wc -l < "$LOG_FILE")
        echo "日誌大小: $log_size ($log_lines 行)"
    fi
}

# 顯示最近日誌
show_recent_logs() {
    local lines=${1:-20}
    echo -e "${BLUE}📋 最近 $lines 行日誌${NC}"
    echo "========================="
    
    if [ -f "$LOG_FILE" ]; then
        tail -n "$lines" "$LOG_FILE"
    else
        echo "日誌檔案不存在"
    fi
}

# 主程式
case "${1:-help}" in
    start)
        if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
            echo "監控已在運行中"
            exit 1
        fi
        
        echo "開始背景監控..."
        nohup bash -c "
            echo \$\$ > '$PID_FILE'
            $(declare -f log_message check_ngrok get_ngrok_data monitor_traffic)
            LOG_DIR='$LOG_DIR'
            LOG_FILE='$LOG_FILE'
            ALERT_THRESHOLD=$ALERT_THRESHOLD
            monitor_traffic
        " >> "$LOG_DIR/monitor.out" 2>&1 &
        
        sleep 2
        show_status
        ;;
    stop)
        stop_monitor
        ;;
    status)
        show_status
        ;;
    logs)
        show_recent_logs "${2:-20}"
        ;;
    report)
        generate_daily_report "$2"
        ;;
    cleanup)
        cleanup_logs "${2:-7}"
        ;;
    *)
        echo "用法: $0 {start|stop|status|logs|report|cleanup}"
        echo
        echo "指令說明:"
        echo "  start         - 開始背景監控"
        echo "  stop          - 停止監控"
        echo "  status        - 顯示監控狀態"
        echo "  logs [行數]   - 顯示最近的日誌 (預設 20 行)"
        echo "  report [日期] - 生成每日報告 (格式: YYYYMMDD)"
        echo "  cleanup [天數] - 清理舊日誌 (預設 7 天)"
        echo
        echo "範例:"
        echo "  $0 start                    # 開始監控"
        echo "  $0 logs 50                  # 顯示最近 50 行日誌"
        echo "  $0 report 20241225          # 生成 2024/12/25 的報告"
        echo "  $0 cleanup 3                # 清理 3 天前的日誌"
        ;;
esac
