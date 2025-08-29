#!/usr/bin/env python3

import requests
import json
import sys

def test_api():
    try:
        print("🔍 測試 API 狀態端點...")
        response = requests.get('http://localhost:5001/api/status', timeout=5)
        
        print(f"HTTP 狀態碼: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print("✅ JSON 解析成功")
            print(f"📊 API 回應數據:")
            print(json.dumps(data, indent=2, ensure_ascii=False))
            
            # 檢查必要欄位
            if 'success' in data and data['success']:
                print("✅ API 成功狀態")
                if 'data' in data:
                    api_data = data['data']
                    print(f"📈 伺服器狀態: {api_data.get('server_status', 'unknown')}")
                    print(f"🐳 Docker 狀態: {api_data.get('docker_running', 'unknown')}")
                    
                    if 'players' in api_data:
                        players = api_data['players']
                        print(f"👥 線上玩家: {players.get('online', 0)}/{players.get('max', 20)}")
                    
                    if 'system_resources' in api_data:
                        resources = api_data['system_resources']
                        print(f"💻 CPU 使用率: {resources.get('cpu_usage', 0)}%")
                        print(f"🧠 記憶體使用率: {resources.get('memory_usage', 0)}%")
                        
                        if 'disk_info' in resources:
                            disk = resources['disk_info']
                            print(f"💾 磁盤使用率: {disk.get('disk_usage_percent', 'N/A')}")
                else:
                    print("⚠️  缺少 data 欄位")
            else:
                print("❌ API 回傳失敗狀態")
        else:
            print(f"❌ HTTP 錯誤: {response.status_code}")
            print(f"回應內容: {response.text[:200]}...")
            
    except requests.exceptions.ConnectionError:
        print("❌ 無法連接到 API 服務")
        print("請確保 Web 管理系統已啟動")
    except requests.exceptions.Timeout:
        print("❌ API 請求超時")
    except json.JSONDecodeError as e:
        print(f"❌ JSON 解析錯誤: {e}")
        print(f"回應內容: {response.text[:200]}...")
    except Exception as e:
        print(f"❌ 未知錯誤: {e}")

if __name__ == "__main__":
    test_api()
