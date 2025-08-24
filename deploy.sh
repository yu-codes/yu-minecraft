#!/bin/bash

# Yu Minecraft Server 快速部署腳本
# 作者: Yu-codes
# 日期: 2023

set -e

echo "🚀 Yu Minecraft Server 快速部署"
echo "=================================="

# 檢查系統要求
check_requirements() {
    echo "🔍 檢查系統要求..."
    
    # 檢查Docker
    if ! command -v docker &> /dev/null; then
        echo "❌ Docker未安裝，請先安裝Docker"
        echo "📖 安裝指南: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    # 檢查Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        echo "❌ Docker Compose未安裝，請先安裝Docker Compose"
        echo "📖 安裝指南: https://docs.docker.com/compose/install/"
        exit 1
    fi
    
    # 檢查記憶體
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        MEMORY_GB=$(system_profiler SPHardwareDataType | grep "Memory:" | awk '{print $2}' | sed 's/GB//')
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        MEMORY_GB=$(free -g | awk '/^Mem:/{print $2}')
    else
        MEMORY_GB=4  # 預設值
    fi
    
    if [ "$MEMORY_GB" -lt 4 ]; then
        echo "⚠️  警告: 系統記憶體少於4GB，可能影響伺服器效能"
    fi
    
    echo "✅ 系統要求檢查通過"
}

# 初始化專案
init_project() {
    echo "📁 初始化專案結構..."
    
    # 創建必要的目錄
    mkdir -p worlds plugins config logs backups
    
    # 檢查配置檔案
    if [ ! -f "config/server.properties" ]; then
        echo "❌ 配置檔案缺失，請確保所有配置檔案存在"
        exit 1
    fi
    
    echo "✅ 專案結構初始化完成"
}

# 建構映像檔
build_image() {
    echo "🐳 建構Docker映像檔..."
    cd docker
    docker-compose build --no-cache
    cd ..
    echo "✅ Docker映像檔建構完成"
}

# 啟動服務
start_services() {
    echo "🎮 啟動服務..."
    cd docker
    docker-compose up -d
    cd ..
    
    # 等待服務啟動
    echo "⏳ 等待服務啟動..."
    sleep 15
    
    # 檢查服務狀態
    cd docker
    if docker-compose ps | grep -q "Up"; then
        echo "✅ 服務啟動成功!"
    else
        echo "❌ 服務啟動失敗，查看記錄:"
        docker-compose logs
        exit 1
    fi
    cd ..
}

# 顯示部署資訊
show_info() {
    echo ""
    echo "🎉 部署完成!"
    echo "=================================="
    echo "🌐 伺服器位址: localhost:25565"
    echo "🖥️  Web管理介面: http://localhost:8080"
    echo "🔐 RCON埠: 25575"
    echo "🔑 RCON密碼: yu-minecraft-2023"
    echo ""
    echo "📋 常用指令:"
    echo "   查看記錄: cd docker && docker-compose logs -f minecraft"
    echo "   停止服務: ./scripts/stop.sh"
    echo "   備份世界: ./scripts/backup.sh"
    echo "   重啟服務: ./scripts/stop.sh && ./scripts/start.sh"
    echo ""
    echo "🎮 享受遊戲吧!"
}

# 主流程
main() {
    check_requirements
    init_project
    build_image
    start_services
    show_info
}

# 執行主流程
main
