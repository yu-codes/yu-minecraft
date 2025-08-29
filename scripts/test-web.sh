#!/bin/bash

# Yu Minecraft Web 管理系統測試腳本

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧪 Yu Minecraft Web 管理系統測試${NC}"
echo "================================================"

# 測試 API 連接
echo -e "${YELLOW}🔌 測試 API 連接...${NC}"
API_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5001/api/status)

if [ "$API_RESPONSE" = "200" ]; then
    echo -e "${GREEN}✅ API 服務正常 (HTTP $API_RESPONSE)${NC}"
else
    echo -e "${RED}❌ API 服務異常 (HTTP $API_RESPONSE)${NC}"
fi

# 測試 Web 服務器
echo -e "${YELLOW}🌐 測試 Web 服務器...${NC}"
WEB_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080)

if [ "$WEB_RESPONSE" = "200" ]; then
    echo -e "${GREEN}✅ Web 服務器正常 (HTTP $WEB_RESPONSE)${NC}"
else
    echo -e "${RED}❌ Web 服務器異常 (HTTP $WEB_RESPONSE)${NC}"
fi

# 測試 API 功能
echo -e "${YELLOW}📊 測試 API 功能...${NC}"
STATUS_JSON=$(curl -s http://localhost:5001/api/status)

if echo "$STATUS_JSON" | python3 -m json.tool >/dev/null 2>&1; then
    echo -e "${GREEN}✅ API 回應格式正確${NC}"
    echo "回應內容："
    echo "$STATUS_JSON" | python3 -m json.tool | head -10
else
    echo -e "${RED}❌ API 回應格式錯誤${NC}"
    echo "回應內容: $STATUS_JSON"
fi

# 測試腳本執行
echo -e "${YELLOW}🔧 測試腳本執行功能...${NC}"
EXECUTE_RESPONSE=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d '{"script":"monitor","args":["--help"]}' \
    http://localhost:5001/api/execute)

if echo "$EXECUTE_RESPONSE" | python3 -m json.tool >/dev/null 2>&1; then
    echo -e "${GREEN}✅ 腳本執行功能正常${NC}"
    echo "執行結果："
    echo "$EXECUTE_RESPONSE" | python3 -c "import sys,json; data=json.load(sys.stdin); print('狀態:', data.get('success', 'unknown')); print('輸出:', data.get('output', 'no output')[:100] + '...' if len(data.get('output', '')) > 100 else data.get('output', 'no output'))"
else
    echo -e "${RED}❌ 腳本執行功能異常${NC}"
    echo "回應內容: $EXECUTE_RESPONSE"
fi

echo ""
echo -e "${BLUE}📝 測試完成！${NC}"
echo "================================================"
echo -e "${YELLOW}💡 提示:${NC}"
echo "   - Web 介面: http://localhost:8080"
echo "   - API 端點: http://localhost:5001/api"
echo "   - 停止服務: ./scripts/stop-web-simple.sh"
