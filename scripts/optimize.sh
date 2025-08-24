#!/bin/bash

# Yu Minecraft Server 效能最佳化腳本
# 作者: Yu-codes
# 日期: 2023

set -e

# 配置
CONFIG_DIR="$(dirname "$0")/../config"
OPTIMIZATION_LOG="$(dirname "$0")/../logs/optimization.log"

echo "⚡ Yu Minecraft 伺服器效能最佳化"

# 創建記錄目錄
mkdir -p "$(dirname "$OPTIMIZATION_LOG")"

# 記錄最佳化操作
log_optimization() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $message" >> "$OPTIMIZATION_LOG"
    echo "✅ $message"
}

# 最佳化server.properties
optimize_server_properties() {
    echo "🔧 最佳化伺服器配置..."
    
    local server_props="$CONFIG_DIR/server.properties"
    local backup_props="$CONFIG_DIR/server.properties.backup.$(date +%Y%m%d_%H%M%S)"
    
    if [ -f "$server_props" ]; then
        # 備份原始配置
        cp "$server_props" "$backup_props"
        log_optimization "已備份server.properties到 $backup_props"
        
        # 效能最佳化設定
        sed -i.bak \
            -e 's/^view-distance=.*/view-distance=8/' \
            -e 's/^simulation-distance=.*/simulation-distance=6/' \
            -e 's/^entity-broadcast-range-percentage=.*/entity-broadcast-range-percentage=80/' \
            -e 's/^network-compression-threshold=.*/network-compression-threshold=512/' \
            -e 's/^max-tick-time=.*/max-tick-time=60000/' \
            "$server_props" 2>/dev/null || true
        
        # 新增效能相關設定（如果不存在）
        if ! grep -q "^use-native-transport=" "$server_props"; then
            echo "use-native-transport=true" >> "$server_props"
        fi
        
        if ! grep -q "^sync-chunk-writes=" "$server_props"; then
            echo "sync-chunk-writes=false" >> "$server_props"
        fi
        
        log_optimization "server.properties 已最佳化"
    else
        echo "❌ 找不到server.properties檔案"
        return 1
    fi
}

# 創建最佳化的spigot.yml
create_optimized_spigot_config() {
    echo "🔧 創建最佳化的spigot配置..."
    
    local spigot_config="$CONFIG_DIR/spigot.yml"
    
    cat > "$spigot_config" << 'EOF'
# Spigot Configuration File
# 由Yu Minecraft效能最佳化腳本生成

config-version: 12

settings:
  debug: false
  save-user-cache-on-stop-only: true
  sample-count: 12
  player-shuffle: 0
  user-cache-size: 1000
  int-cache-limit: 1024
  moved-wrongly-threshold: 0.0625
  moved-too-quickly-multiplier: 10.0
  timeout-time: 60
  restart-on-crash: true
  restart-script: ./start.sh
  netty-threads: 4
  attribute:
    maxHealth:
      max: 2048.0
    movementSpeed:
      max: 2048.0
    attackDamage:
      max: 2048.0

messages:
  whitelist: 您不在此伺服器的白名單中！
  unknown-command: 未知指令。輸入 "/help" 查看說明。
  server-full: 伺服器已滿員！
  outdated-client: 過時的客戶端！請使用 {0}
  outdated-server: 過時的伺服器！我正在使用 {0}
  restart: 伺服器正在重啟

commands:
  silent-commandblock-console: false
  log: true
  tab-complete: 0
  send-namespaced: true
  spam-exclusions:
  - /skill

advancements:
  disable-saving: false
  disabled:
  - minecraft:story/disabled

world-settings:
  default:
    verbose: false
    view-distance: default
    simulation-distance: default
    thunder-chance: 100000
    
    mob-spawn-range: 6
    item-despawn-rate: 6000
    merge-radius:
      item: 2.5
      exp: 3.0
    
    growth:
      cactus-modifier: 100
      cane-modifier: 100
      melon-modifier: 100
      mushroom-modifier: 100
      pumpkin-modifier: 100
      sapling-modifier: 100
      beetroot-modifier: 100
      carrot-modifier: 100
      potato-modifier: 100
      wheat-modifier: 100
      netherwart-modifier: 100
      vine-modifier: 100
      cocoa-modifier: 100
      bamboo-modifier: 100
      sweetberry-modifier: 100
      kelp-modifier: 100

    entity-activation-range:
      animals: 24
      monsters: 24
      raiders: 32
      misc: 8
      water: 12
      villagers: 24
      flying-monsters: 24
      
    entity-tracking-range:
      players: 48
      animals: 48
      monsters: 48
      misc: 32
      other: 64

    ticks-per:
      hopper-transfer: 8
      hopper-check: 1

    hopper-amount: 1
    dragon-death-sound-radius: 0
    seed-village: 10387312
    seed-desert: 14357617
    seed-igloo: 14357618
    seed-jungle: 14357619
    seed-swamp: 14357620
    seed-monument: 10387313
    seed-shipwreck: 165745295
    seed-ocean: 14357621
    seed-outpost: 165745296
    seed-endcity: 10387313
    seed-slime: 987234911
    seed-nether: 30084232
    seed-mansion: 10387319
    seed-fossil: 14357921
    seed-portal: 34222645

    hunger:
      jump-walk-exhaustion: 0.05
      jump-sprint-exhaustion: 0.2
      combat-exhaustion: 0.1
      regen-exhaustion: 6.0
      swim-multiplier: 0.01
      sprint-multiplier: 0.1
      other-multiplier: 0.0

    max-tnt-per-tick: 100
    max-tick-time:
      tile: 50
      entity: 50
    
    arrow-despawn-rate: 1200
    trident-despawn-rate: 1200
EOF

    log_optimization "spigot.yml 已創建並最佳化"
}

# 創建最佳化的bukkit.yml
create_optimized_bukkit_config() {
    echo "🔧 創建最佳化的bukkit配置..."
    
    local bukkit_config="$CONFIG_DIR/bukkit.yml"
    
    cat > "$bukkit_config" << 'EOF'
# Bukkit Configuration File
# 由Yu Minecraft效能最佳化腳本生成

settings:
  allow-end: true
  warn-on-overload: true
  permissions-file: permissions.yml
  update-folder: update
  plugin-profiling: false
  connection-throttle: 4000
  query-plugins: true
  deprecated-verbose: default
  shutdown-message: 伺服器正在關閉！
  minimum-api: none
  use-map-color-cache: true

spawn-limits:
  monsters: 50
  animals: 8
  water-animals: 3
  water-ambient: 2
  water-underground-creature: 3
  axolotls: 3
  ambient: 1

chunk-gc:
  period-in-ticks: 400

ticks-per:
  animal-spawns: 400
  monster-spawns: 1
  water-spawns: 1
  water-ambient-spawns: 1
  water-underground-creature-spawns: 1
  axolotl-spawns: 1
  ambient-spawns: 1
  autosave: 6000

aliases: now-in-commands.yml
EOF

    log_optimization "bukkit.yml 已創建並最佳化"
}

# 更新Docker Compose以使用最佳化的JVM參數
optimize_jvm_settings() {
    echo "🔧 最佳化JVM設定..."
    
    local compose_file="$(dirname "$0")/../docker/docker-compose.yml"
    local backup_compose="$compose_file.backup.$(date +%Y%m%d_%H%M%S)"
    
    if [ -f "$compose_file" ]; then
        # 備份原始配置
        cp "$compose_file" "$backup_compose"
        log_optimization "已備份docker-compose.yml到 $backup_compose"
        
        # 檢查記憶體設定
        local memory_setting=$(grep "MEMORY=" "$(dirname "$0")/../.env" | cut -d'=' -f2 || echo "2G")
        
        # 根據記憶體設定調整JVM參數
        local xmx_setting=""
        local xms_setting=""
        
        case "$memory_setting" in
            "1G")
                xmx_setting="768M"
                xms_setting="512M"
                ;;
            "2G")
                xmx_setting="1536M"
                xms_setting="1G"
                ;;
            "4G")
                xmx_setting="3G"
                xms_setting="2G"
                ;;
            "8G")
                xmx_setting="6G"
                xms_setting="4G"
                ;;
            *)
                xmx_setting="1536M"
                xms_setting="1G"
                ;;
        esac
        
        log_optimization "JVM記憶體設定: Xms=$xms_setting, Xmx=$xmx_setting"
        
        # 更新Dockerfile以使用最佳化的JVM參數
        local dockerfile="$(dirname "$0")/../docker/Dockerfile"
        if [ -f "$dockerfile" ]; then
            sed -i.bak \
                "s/ENV JAVA_OPTS=.*/ENV JAVA_OPTS=\"-Xms$xms_setting -Xmx$xmx_setting -XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -XX:MaxGCPauseMillis=100 -XX:+DisableExplicitGC -XX:TargetSurvivorRatio=90 -XX:G1NewSizePercent=50 -XX:G1MaxNewSizePercent=80 -XX:G1MixedGCLiveThresholdPercent=35 -XX:+AlwaysPreTouch -XX:+ParallelRefProcEnabled -Dusing.aikars.flags=https:\/\/mcflags.emc.gs -Daikars.new.flags=true\"/" \
                "$dockerfile"
            
            log_optimization "Dockerfile JVM參數已最佳化"
        fi
    else
        echo "❌ 找不到docker-compose.yml檔案"
        return 1
    fi
}

# 創建最佳化的啟動腳本
create_optimized_startup() {
    echo "🔧 創建最佳化的啟動配置..."
    
    # 創建預熱腳本
    local warmup_script="$(dirname "$0")/warmup.sh"
    
    cat > "$warmup_script" << 'EOF'
#!/bin/bash

# Yu Minecraft Server 預熱腳本
# 用於在啟動後進行效能最佳化

echo "🔥 開始伺服器預熱程序..."

# 等待伺服器完全啟動
sleep 30

# 預載入重要區塊
echo "📍 預載入重要區塊..."
docker-compose exec -T minecraft rcon-cli --host localhost --port 25575 --password yu-minecraft-2025 "forceload add 0 0" || true
docker-compose exec -T minecraft rcon-cli --host localhost --port 25575 --password yu-minecraft-2025 "forceload add -100 -100 100 100" || true

# 執行垃圾回收
echo "🗑️ 執行垃圾回收..."
docker-compose exec -T minecraft rcon-cli --host localhost --port 25575 --password yu-minecraft-2025 "forge gc" || true

echo "✅ 伺服器預熱完成"
EOF

    chmod +x "$warmup_script"
    log_optimization "預熱腳本已創建"
}

# 系統效能檢查
check_system_performance() {
    echo "🔍 檢查系統效能..."
    
    # 檢查可用記憶體
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        local available_memory=$(sysctl -n hw.memsize)
        local available_gb=$((available_memory / 1024 / 1024 / 1024))
    else
        # Linux
        local available_gb=$(free -g | awk '/^Mem:/{print $2}')
    fi
    
    echo "💾 系統記憶體: ${available_gb}GB"
    
    if [ "$available_gb" -lt 4 ]; then
        echo "⚠️ 警告: 系統記憶體不足4GB，建議升級硬體"
    fi
    
    # 檢查CPU核心數
    if [[ "$OSTYPE" == "darwin"* ]]; then
        local cpu_cores=$(sysctl -n hw.ncpu)
    else
        local cpu_cores=$(nproc)
    fi
    
    echo "🖥️ CPU核心數: $cpu_cores"
    
    if [ "$cpu_cores" -lt 2 ]; then
        echo "⚠️ 警告: CPU核心數不足，可能影響效能"
    fi
    
    # 檢查磁碟空間
    local disk_space=$(df / | tail -1 | awk '{print $4}')
    local disk_gb=$((disk_space / 1024 / 1024))
    
    echo "💽 可用磁碟空間: ${disk_gb}GB"
    
    if [ "$disk_gb" -lt 10 ]; then
        echo "⚠️ 警告: 磁碟空間不足10GB"
    fi
    
    log_optimization "系統效能檢查完成 - RAM:${available_gb}GB CPU:${cpu_cores}核心 磁碟:${disk_gb}GB"
}

# 生成效能報告
generate_performance_report() {
    echo "📊 生成效能最佳化報告..."
    
    local report_file="$(dirname "$0")/../logs/optimization_report_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "═══════════════════════════════════════"
        echo "Yu Minecraft Server 效能最佳化報告"
        echo "生成時間: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "═══════════════════════════════════════"
        echo ""
        echo "🔧 已執行的最佳化項目:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        if [ -f "$OPTIMIZATION_LOG" ]; then
            tail -20 "$OPTIMIZATION_LOG"
        fi
        
        echo ""
        echo "💡 建議進一步最佳化項目:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "1. 定期清理世界區塊"
        echo "2. 設定適當的視距範圍"
        echo "3. 限制實體數量"
        echo "4. 使用效能監控外掛"
        echo "5. 定期備份和重啟"
        echo ""
        echo "📈 效能監控指令:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "./scripts/performance.sh        # 效能監控"
        echo "./scripts/monitor.sh continuous # 系統監控"
        echo "docker stats yu-minecraft-server # 容器資源使用"
        echo ""
    } > "$report_file"
    
    echo "✅ 效能報告已生成: $report_file"
}

# 主程式
case "${1:-all}" in
    "all")
        echo "🚀 執行完整效能最佳化..."
        check_system_performance
        optimize_server_properties
        create_optimized_spigot_config
        create_optimized_bukkit_config
        optimize_jvm_settings
        create_optimized_startup
        generate_performance_report
        echo ""
        echo "✅ 效能最佳化完成！"
        echo "🔄 請重新建置並啟動伺服器以套用變更:"
        echo "   ./scripts/stop.sh"
        echo "   cd docker && docker-compose build"
        echo "   cd .. && ./scripts/start.sh"
        ;;
    "server")
        optimize_server_properties
        ;;
    "spigot")
        create_optimized_spigot_config
        ;;
    "bukkit")
        create_optimized_bukkit_config
        ;;
    "jvm")
        optimize_jvm_settings
        ;;
    "check")
        check_system_performance
        ;;
    "report")
        generate_performance_report
        ;;
    "help"|"-h"|"--help")
        echo "使用方式: $0 [指令]"
        echo ""
        echo "指令:"
        echo "  all     執行完整最佳化 (預設)"
        echo "  server  最佳化server.properties"
        echo "  spigot  創建最佳化的spigot.yml"
        echo "  bukkit  創建最佳化的bukkit.yml"
        echo "  jvm     最佳化JVM設定"
        echo "  check   檢查系統效能"
        echo "  report  生成效能報告"
        echo "  help    顯示此說明"
        ;;
    *)
        echo "❌ 未知指令: $1"
        echo "使用 '$0 help' 查看可用指令"
        exit 1
        ;;
esac
