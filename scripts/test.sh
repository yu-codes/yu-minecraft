#!/bin/bash

# 測試伺服器管理系統完整性
# 測試腳本 - Yu Minecraft Server System Test

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS_DIR="$PROJECT_ROOT/scripts"

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧪 Yu Minecraft Server 系統測試${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

test_passed=0
test_failed=0

# 測試函數
run_test() {
    local test_name="$1"
    local test_cmd="$2"
    
    echo -ne "${YELLOW}測試: ${test_name}${NC} ... "
    
    if eval "$test_cmd" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ 通過${NC}"
        ((test_passed++))
    else
        echo -e "${RED}❌ 失敗${NC}"
        ((test_failed++))
    fi
}

echo -e "${BLUE}📁 目錄結構測試${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

run_test "專案根目錄存在" "[ -d '$PROJECT_ROOT' ]"
run_test "scripts 目錄存在" "[ -d '$SCRIPTS_DIR' ]"
run_test "worlds 目錄存在" "[ -d '$PROJECT_ROOT/worlds' ]"
run_test "config 目錄存在" "[ -d '$PROJECT_ROOT/config' ]"
run_test "docker 目錄存在" "[ -d '$PROJECT_ROOT/docker' ]"

echo

echo -e "${BLUE}🗂️ 腳本目錄測試${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

run_test "world 腳本目錄" "[ -d '$SCRIPTS_DIR/world' ]"
run_test "server 腳本目錄" "[ -d '$SCRIPTS_DIR/server' ]"
run_test "plugins 腳本目錄" "[ -d '$SCRIPTS_DIR/plugins' ]"
run_test "monitoring 腳本目錄" "[ -d '$SCRIPTS_DIR/monitoring' ]"
run_test "backup 腳本目錄" "[ -d '$SCRIPTS_DIR/backup' ]"
run_test "network 腳本目錄" "[ -d '$SCRIPTS_DIR/network' ]"

echo

echo -e "${BLUE}📄 核心腳本測試${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

run_test "manage.sh 存在且可執行" "[ -x '$PROJECT_ROOT/manage.sh' ]"
run_test "container.sh 存在且可執行" "[ -x '$SCRIPTS_DIR/server/container.sh' ]"
run_test "start.sh 存在且可執行" "[ -x '$SCRIPTS_DIR/server/start.sh' ]"
run_test "stop.sh 存在且可執行" "[ -x '$SCRIPTS_DIR/server/stop.sh' ]"
run_test "plugins.sh 存在且可執行" "[ -x '$SCRIPTS_DIR/plugins/plugins.sh' ]"

echo

echo -e "${BLUE}🐳 Docker 環境測試${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

run_test "Docker 已安裝" "command -v docker"
run_test "Docker Compose 已安裝" "command -v docker-compose || docker compose version"
run_test "docker-compose.yml 存在" "[ -f '$PROJECT_ROOT/docker/docker-compose.yml' ]"
run_test "Dockerfile 存在" "[ -f '$PROJECT_ROOT/docker/Dockerfile' ]"

echo

echo -e "${BLUE}⚙️ 配置檔案測試${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

run_test "server.properties 存在" "[ -f '$PROJECT_ROOT/config/server.properties' ]"
run_test "spigot.yml 存在" "[ -f '$PROJECT_ROOT/config/spigot.yml' ]"
run_test "bukkit.yml 存在" "[ -f '$PROJECT_ROOT/config/bukkit.yml' ]"

echo

echo -e "${BLUE}🌐 Web API 測試${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

run_test "Web 目錄存在" "[ -d '$PROJECT_ROOT/web' ]"
run_test "simple-api.py 存在" "[ -f '$PROJECT_ROOT/web/simple-api.py' ]"
run_test "index.html 存在" "[ -f '$PROJECT_ROOT/web/index.html' ]"

echo

echo -e "${BLUE}📊 測試結果${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "✅ 通過測試: ${GREEN}$test_passed${NC}"
echo -e "❌ 失敗測試: ${RED}$test_failed${NC}"
echo -e "📈 成功率: $(( test_passed * 100 / (test_passed + test_failed) ))%"

if [ $test_failed -eq 0 ]; then
    echo
    echo -e "${GREEN}🎉 所有測試通過！系統已準備就緒！${NC}"
    exit 0
else
    echo
    echo -e "${RED}⚠️  部分測試失敗，請檢查系統配置${NC}"
    exit 1
fi
