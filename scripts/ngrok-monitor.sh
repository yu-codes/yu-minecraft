#!/bin/bash

# ngrok 流量監控腳本
# 提供多種方式監控 ngrok 隧道的流量使用情況

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}📊 ngrok 流量監控助手${NC}"
echo "============================="

# 檢查 ngrok 是否正在運行
check_ngrok_status() {
    if pgrep -f "ngrok tcp" > /dev/null; then
        echo -e "${GREEN}✅ ngrok 隧道正在運行${NC}"
        return 0
    else
        echo -e "${RED}❌ ngrok 隧道未運行${NC}"
        return 1
    fi
}

# 獲取 ngrok API 端口（預設 4040）
get_ngrok_api_port() {
    local port=4040
    # 檢查是否有自訂端口
    if netstat -an | grep -q ":$port.*LISTEN"; then
        echo $port
    else
        # 嘗試其他常用端口
        for p in 4041 4042 4043; do
            if netstat -an | grep -q ":$p.*LISTEN"; then
                echo $p
                return
            fi
        done
        echo "4040"  # 預設值
    fi
}

# 取得隧道資訊
get_tunnel_info() {
    local api_port=$(get_ngrok_api_port)
    local api_url="http://localhost:$api_port/api/tunnels"
    
    echo -e "${YELLOW}🔍 取得隧道資訊...${NC}"
    
    if curl -s "$api_url" >/dev/null 2>&1; then
        local tunnel_data=$(curl -s "$api_url")
        echo "$tunnel_data" | jq -r '.tunnels[] | select(.proto == "tcp") | {name: .name, public_url: .public_url, config: .config}' 2>/dev/null || {
            # 如果沒有 jq，使用基本的文字處理
            echo "$tunnel_data" | grep -o '"public_url":"[^"]*"' | sed 's/"public_url":"//g' | sed 's/"//g'
        }
    else
        echo -e "${RED}❌ 無法連接到 ngrok API (端口: $api_port)${NC}"
        return 1
    fi
}

# 監控隧道狀態
monitor_tunnel_status() {
    local api_port=$(get_ngrok_api_port)
    local api_url="http://localhost:$api_port/api/tunnels"
    
    echo -e "${CYAN}📈 即時隧道狀態監控${NC}"
    echo "按 Ctrl+C 停止監控"
    echo "===================="
    
    while true; do
        clear
        echo -e "${CYAN}📈 ngrok 隧道狀態 - $(date '+%Y-%m-%d %H:%M:%S')${NC}"
        echo "============================================"
        
        if curl -s "$api_url" >/dev/null 2>&1; then
            local tunnel_data=$(curl -s "$api_url")
            
            # 使用 jq 解析（如果可用）
            if command -v jq >/dev/null 2>&1; then
                echo "$tunnel_data" | jq -r '
                    .tunnels[] | select(.proto == "tcp") | 
                    "🌐 隧道名稱: " + .name + 
                    "\n📍 公開網址: " + .public_url + 
                    "\n🔗 本地地址: " + .config.addr + 
                    "\n📊 連線數: " + (.metrics.conns.count // 0 | tostring) + 
                    "\n📈 傳輸量: " + (.metrics.http.count // 0 | tostring) + " requests" +
                    "\n" + ("-" * 40)
                '
            else
                # 基本解析
                echo "$tunnel_data" | grep -o '"public_url":"[^"]*"' | sed 's/"public_url":"//g' | sed 's/"//g' | while read url; do
                    echo -e "${GREEN}📍 公開網址: $url${NC}"
                done
                echo "$tunnel_data" | grep -o '"addr":"[^"]*"' | sed 's/"addr":"//g' | sed 's/"//g' | while read addr; do
                    echo -e "${BLUE}🔗 本地地址: $addr${NC}"
                done
            fi
        else
            echo -e "${RED}❌ 無法連接到 ngrok API${NC}"
        fi
        
        echo
        echo -e "${YELLOW}🔄 刷新中... (每 5 秒更新)${NC}"
        sleep 5
    done
}

# 檢查流量使用情況（透過 ngrok 儀表板）
check_traffic_usage() {
    echo -e "${BLUE}📊 ngrok 流量使用情況${NC}"
    echo "========================="
    
    echo -e "${YELLOW}💡 查看詳細流量資訊的方法：${NC}"
    echo
    echo "1. 本地 Web 界面（推薦）："
    echo "   開啟瀏覽器訪問: http://localhost:$(get_ngrok_api_port)"
    echo "   - 即時連線狀態"
    echo "   - 請求/回應詳情"
    echo "   - 流量統計"
    echo
    echo "2. ngrok 線上儀表板："
    echo "   訪問: https://dashboard.ngrok.com/obs/traffic-inspector"
    echo "   - 歷史流量資料"
    echo "   - 月度使用統計"
    echo "   - 帳戶使用額度"
    echo
    echo "3. API 查詢當前連線："
    
    local api_port=$(get_ngrok_api_port)
    if curl -s "http://localhost:$api_port/api/requests" >/dev/null 2>&1; then
        echo -e "${GREEN}   ✅ API 可用 - 端口 $api_port${NC}"
        
        # 取得最近的請求統計
        local requests_data=$(curl -s "http://localhost:$api_port/api/requests")
        if command -v jq >/dev/null 2>&1; then
            local request_count=$(echo "$requests_data" | jq '.requests | length')
            echo "   📈 API 記錄的請求數: $request_count"
        fi
    else
        echo -e "${RED}   ❌ API 不可用${NC}"
    fi
}

# 設置流量警報
setup_traffic_alert() {
    echo -e "${YELLOW}⚠️  設置流量警報${NC}"
    echo "=================="
    
    read -p "設置每小時連線數警報閾值 (預設: 100): " conn_threshold
    conn_threshold=${conn_threshold:-100}
    
    read -p "監控間隔 (秒，預設: 60): " interval
    interval=${interval:-60}
    
    echo -e "${GREEN}🚨 開始監控流量警報${NC}"
    echo "連線閾值: $conn_threshold/小時"
    echo "監控間隔: $interval 秒"
    echo "按 Ctrl+C 停止監控"
    echo
    
    local start_time=$(date +%s)
    local hour_connections=0
    
    while true; do
        local current_time=$(date +%s)
        local api_port=$(get_ngrok_api_port)
        
        # 每小時重置計數器
        if [ $((current_time - start_time)) -ge 3600 ]; then
            start_time=$current_time
            hour_connections=0
            echo -e "${BLUE}🔄 重置小時計數器${NC}"
        fi
        
        # 檢查當前連線
        if curl -s "http://localhost:$api_port/api/tunnels" >/dev/null 2>&1; then
            local tunnel_data=$(curl -s "http://localhost:$api_port/api/tunnels")
            
            if command -v jq >/dev/null 2>&1; then
                local current_conns=$(echo "$tunnel_data" | jq -r '.tunnels[] | select(.proto == "tcp") | .metrics.conns.count // 0' | head -1)
                current_conns=${current_conns:-0}
                
                if [ "$current_conns" -gt 0 ]; then
                    hour_connections=$((hour_connections + current_conns))
                    echo "$(date '+%H:%M:%S') - 當前連線: $current_conns, 小時累計: $hour_connections"
                    
                    if [ "$hour_connections" -gt "$conn_threshold" ]; then
                        echo -e "${RED}🚨 警報: 小時連線數 ($hour_connections) 超過閾值 ($conn_threshold)!${NC}"
                        # 可以在這裡添加通知邏輯，如發送郵件或 Slack 訊息
                    fi
                fi
            fi
        fi
        
        sleep $interval
    done
}

# 生成流量報告
generate_traffic_report() {
    echo -e "${BLUE}📋 生成流量報告${NC}"
    echo "=================="
    
    local report_file="ngrok_traffic_report_$(date +%Y%m%d_%H%M%S).txt"
    local api_port=$(get_ngrok_api_port)
    
    {
        echo "=== ngrok 流量報告 ==="
        echo "生成時間: $(date)"
        echo "API 端口: $api_port"
        echo
        
        echo "=== 隧道資訊 ==="
        if curl -s "http://localhost:$api_port/api/tunnels" >/dev/null 2>&1; then
            curl -s "http://localhost:$api_port/api/tunnels" | if command -v jq >/dev/null 2>&1; then
                jq -r '.tunnels[] | select(.proto == "tcp") | 
                    "隧道名稱: " + .name + 
                    "\n公開網址: " + .public_url + 
                    "\n本地地址: " + .config.addr + 
                    "\n連線數: " + (.metrics.conns.count // 0 | tostring) + 
                    "\n建立時間: " + .started_at + 
                    "\n" + ("-" * 30)'
            else
                cat
            fi
        else
            echo "無法取得隧道資訊"
        fi
        
        echo
        echo "=== 系統資訊 ==="
        echo "作業系統: $(uname -s)"
        echo "主機名稱: $(hostname)"
        echo "ngrok 程序狀態: $(pgrep -f "ngrok tcp" >/dev/null && echo "運行中" || echo "未運行")"
        
    } > "$report_file"
    
    echo -e "${GREEN}✅ 報告已儲存至: $report_file${NC}"
    
    # 顯示報告內容
    echo -e "${YELLOW}📄 報告內容預覽:${NC}"
    echo "========================"
    cat "$report_file"
}

# 主選單
show_menu() {
    echo
    echo -e "${CYAN}請選擇監控選項:${NC}"
    echo "1. 檢查隧道狀態"
    echo "2. 即時監控隧道"
    echo "3. 查看流量使用指南"
    echo "4. 設置流量警報"
    echo "5. 生成流量報告"
    echo "6. 開啟本地 Web 界面"
    echo "7. 開啟線上儀表板"
    echo "8. 退出"
    echo
}

# 開啟 Web 界面
open_web_interface() {
    local api_port=$(get_ngrok_api_port)
    local url="http://localhost:$api_port"
    
    echo -e "${BLUE}🌐 開啟 ngrok 本地 Web 界面${NC}"
    echo "網址: $url"
    
    # 嘗試開啟瀏覽器
    if command -v open >/dev/null 2>&1; then
        # macOS
        open "$url"
    elif command -v xdg-open >/dev/null 2>&1; then
        # Linux
        xdg-open "$url"
    elif command -v start >/dev/null 2>&1; then
        # Windows
        start "$url"
    else
        echo "請手動在瀏覽器中開啟: $url"
    fi
}

# 開啟線上儀表板
open_online_dashboard() {
    local url="https://dashboard.ngrok.com/obs/traffic-inspector"
    
    echo -e "${BLUE}🌐 開啟 ngrok 線上儀表板${NC}"
    echo "網址: $url"
    
    # 嘗試開啟瀏覽器
    if command -v open >/dev/null 2>&1; then
        open "$url"
    elif command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$url"
    elif command -v start >/dev/null 2>&1; then
        start "$url"
    else
        echo "請手動在瀏覽器中開啟: $url"
    fi
}

# 主程式
main() {
    # 檢查 ngrok 狀態
    if ! check_ngrok_status; then
        echo -e "${YELLOW}💡 提示: 請先啟動 ngrok 隧道${NC}"
        echo "使用: ./scripts/remote-connect-ngrok.sh"
        echo
    fi
    
    while true; do
        show_menu
        read -p "請輸入選項 (1-8): " choice
        
        case $choice in
            1)
                get_tunnel_info
                ;;
            2)
                monitor_tunnel_status
                ;;
            3)
                check_traffic_usage
                ;;
            4)
                setup_traffic_alert
                ;;
            5)
                generate_traffic_report
                ;;
            6)
                open_web_interface
                ;;
            7)
                open_online_dashboard
                ;;
            8)
                echo -e "${GREEN}👋 再見！${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ 無效選項，請重新選擇${NC}"
                ;;
        esac
        
        echo
        read -p "按 Enter 繼續..."
    done
}

# 檢查依賴
echo -e "${YELLOW}🔍 檢查依賴套件...${NC}"

# 檢查 jq (JSON 處理工具)
if ! command -v jq >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  建議安裝 jq 以獲得更好的監控體驗${NC}"
    echo "安裝方法:"
    echo "  macOS: brew install jq"
    echo "  Ubuntu/Debian: sudo apt install jq"
    echo "  不安裝也可以使用基本功能"
    echo
fi

# 開始主程式
main
