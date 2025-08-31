#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Yu Minecraft Server 輕量級 Web API
簡單的 HTTP 服務器，執行現有的腳本
"""

import http.server
import socketserver
import json
import subprocess
import os
import urllib.parse
from pathlib import Path

# 配置
PORT = 5001
PROJECT_ROOT = Path(__file__).parent.parent
SCRIPTS_DIR = PROJECT_ROOT / 'scripts'

# 允許的腳本列表
ALLOWED_SCRIPTS = {
    'monitor': 'monitoring/monitor.sh',
    'backup': 'backup/backup.sh', 
    'start': 'server/start.sh',
    'stop': 'server/stop.sh',
    'performance': 'monitoring/performance.sh',
    'plugins': 'plugins/plugins.sh',
    'optimize': 'monitoring/optimize.sh',
    'player-info': 'monitoring/player-info.sh'
}

class MinecraftAPIHandler(http.server.BaseHTTPRequestHandler):
    def _send_cors_headers(self):
        """發送 CORS 標頭"""
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')

    def _send_json_response(self, data, status_code=200):
        """發送 JSON 響應"""
        self.send_response(status_code)
        self.send_header('Content-Type', 'application/json')
        self._send_cors_headers()
        self.end_headers()
        self.wfile.write(json.dumps(data, ensure_ascii=False).encode('utf-8'))

    def do_OPTIONS(self):
        """處理 OPTIONS 請求"""
        self.send_response(200)
        self._send_cors_headers()
        self.end_headers()

    def do_GET(self):
        """處理 GET 請求"""
        path = urllib.parse.urlparse(self.path).path
        query = urllib.parse.parse_qs(urllib.parse.urlparse(self.path).query)
        
        if path == '/api/status':
            self._handle_status()
        elif path == '/api/logs':
            self._handle_logs()
        elif path.startswith('/api/files/'):
            subpath = path.replace('/api/files/', '')
            self._handle_files(subpath)
        else:
            self._send_json_response({'error': 'Endpoint not found'}, 404)

    def do_POST(self):
        """處理 POST 請求"""
        path = urllib.parse.urlparse(self.path).path
        
        if path == '/api/execute':
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            try:
                data = json.loads(post_data.decode('utf-8'))
                self._handle_execute(data)
            except json.JSONDecodeError:
                self._send_json_response({'error': 'Invalid JSON'}, 400)
        elif path == '/api/kick':
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            try:
                data = json.loads(post_data.decode('utf-8'))
                self._handle_kick_player(data)
            except json.JSONDecodeError:
                self._send_json_response({'error': 'Invalid JSON'}, 400)
        else:
            self._send_json_response({'error': 'Endpoint not found'}, 404)

    def _handle_status(self):
        """處理狀態查詢"""
        try:
            # 檢查 Docker 容器狀態
            docker_running = False
            container_status = 'unknown'
            server_status = 'offline'
            online_players = 0
            max_players = 20
            
            try:
                # 切換到 docker 目錄並檢查容器狀態
                docker_cmd = f'cd "{PROJECT_ROOT}/docker" && docker compose ps 2>/dev/null'
                result = subprocess.run(docker_cmd, shell=True, capture_output=True, text=True)
                
                if result.returncode == 0 and 'Up' in result.stdout:
                    docker_running = True
                    container_status = 'running'
                    server_status = 'online'
                elif result.returncode == 0:
                    container_status = 'stopped'
                    server_status = 'offline'
            except Exception as e:
                print(f"Docker 檢查錯誤: {e}")

            # 獲取玩家信息（從 server.properties 獲取最大玩家數）
            player_list = []
            try:
                server_props_path = PROJECT_ROOT / 'config' / 'server.properties'
                if server_props_path.exists():
                    with open(server_props_path, 'r') as f:
                        for line in f:
                            if line.startswith('max-players='):
                                max_players = int(line.split('=')[1].strip())
                                break
            except Exception as e:
                print(f"讀取 server.properties 錯誤: {e}")

            # 獲取線上玩家詳細信息
            if server_status == 'online':
                try:
                    # 使用專門的玩家資訊腳本
                    player_script = SCRIPTS_DIR / 'monitoring' / 'player-info.sh'
                    if player_script.exists():
                        player_result = subprocess.run([
                            'bash', str(player_script), 'json'
                        ], cwd=PROJECT_ROOT, capture_output=True, text=True, timeout=10)
                        
                        if player_result.returncode == 0:
                            try:
                                import json as json_module
                                player_data = json_module.loads(player_result.stdout)
                                if player_data.get('success'):
                                    online_players = player_data.get('online_count', 0)
                                    player_list = player_data.get('players', [])
                                else:
                                    print(f"玩家腳本執行失敗: {player_data.get('error', '未知錯誤')}")
                            except json_module.JSONDecodeError as e:
                                print(f"解析玩家資料JSON失敗: {e}")
                        else:
                            print(f"玩家資訊腳本執行失敗: {player_result.stderr}")
                    
                    # 如果腳本執行失敗，嘗試備用方法
                    if online_players == 0 and len(player_list) == 0:
                        # 嘗試從當前世界的玩家數據目錄獲取信息
                        playerdata_dir = PROJECT_ROOT / 'worlds' / 'current' / 'playerdata'
                        if playerdata_dir.exists():
                            import os
                            import time
                            from datetime import datetime
                            
                            # 獲取最近活躍的玩家檔案
                            for filename in os.listdir(playerdata_dir):
                                if filename.endswith('.dat'):
                                    filepath = playerdata_dir / filename
                                    try:
                                        # 獲取檔案修改時間
                                        mtime = os.path.getmtime(filepath)
                                        # 如果在最近 10 分鐘內修改過，認為是線上玩家
                                        if time.time() - mtime < 600:  # 10 分鐘
                                            player_uuid = filename.replace('.dat', '')
                                            
                                            # 使用固定的名稱映射作為備用
                                            uuid_to_name = {
                                                '3d2aeac1-4ea1-4d92-b48b-f71704c08622': 'Steve',
                                                '3d2aeac14ea14d92b48bf71704c08622': 'Steve',
                                                '5ee80fec-d63f-41e7-9228-8904ae652583': 'Alex',
                                                '5ee80fecd63f41e792288904ae652583': 'Alex',
                                                '805ff403-650c-46f7-92d7-7c55858d4cf2': 'Herobrine',
                                                '805ff403650c46f792d77c55858d4cf2': 'Herobrine'
                                            }
                                            player_name = uuid_to_name.get(player_uuid.replace('-', ''), f"Player_{player_uuid[:8]}")
                                            
                                            # 計算線上時間
                                            online_time = time.time() - mtime
                                            if online_time < 60:
                                                time_str = f"{int(online_time)}秒"
                                            elif online_time < 3600:
                                                time_str = f"{int(online_time/60)}分鐘"
                                            else:
                                                time_str = f"{int(online_time/3600)}小時{int((online_time%3600)/60)}分鐘"
                                            
                                            player_list.append({
                                                'name': player_name,
                                                'uuid': player_uuid,
                                                'online_time': time_str,
                                                'last_seen': datetime.fromtimestamp(mtime).strftime('%H:%M:%S')
                                            })
                                    except Exception as e:
                                        print(f"處理玩家檔案 {filename} 錯誤: {e}")
                            
                            online_players = len(player_list)
                                        
                except Exception as e:
                    print(f"獲取玩家信息錯誤: {e}")
                    # 如果無法獲取真實數據，提供空列表
                    player_list = []
                    online_players = 0
            else:
                online_players = 0

            # 獲取系統資源資訊
            system_info = {}
            cpu_usage = 0
            memory_usage = 0
            
            try:
                # 獲取 CPU 使用率 (macOS) - 簡化版本
                try:
                    cpu_result = subprocess.run(['iostat', '-c', '1'], capture_output=True, text=True, timeout=2)
                    if cpu_result.returncode == 0:
                        lines = cpu_result.stdout.strip().split('\n')
                        if len(lines) > 2:
                            data_line = lines[-1].strip().split()
                            if len(data_line) >= 3:
                                cpu_usage = float(data_line[2])  # user CPU
                except:
                    cpu_usage = 15.0  # 預設值
                
                # 獲取記憶體使用量 - 簡化版本
                try:
                    memory_result = subprocess.run(['vm_stat'], capture_output=True, text=True, timeout=2)
                    if memory_result.returncode == 0:
                        lines = memory_result.stdout.split('\n')
                        free_pages = 0
                        total_pages = 0
                        
                        for line in lines:
                            if 'Pages free:' in line:
                                free_pages = int(line.split(':')[1].strip().rstrip('.'))
                            elif 'Pages wired down:' in line:
                                wired = int(line.split(':')[1].strip().rstrip('.'))
                                total_pages += wired
                            elif 'Pages active:' in line:
                                active = int(line.split(':')[1].strip().rstrip('.'))
                                total_pages += active
                            elif 'Pages inactive:' in line:
                                inactive = int(line.split(':')[1].strip().rstrip('.'))
                                total_pages += inactive
                        
                        total_pages += free_pages
                        if total_pages > 0:
                            memory_usage = ((total_pages - free_pages) / total_pages) * 100
                except:
                    memory_usage = 45.0  # 預設值
                
                # 獲取磁盤使用量
                try:
                    disk_result = subprocess.run(['df', '-h', '/'], capture_output=True, text=True, timeout=2)
                    if disk_result.returncode == 0:
                        disk_lines = disk_result.stdout.strip().split('\n')
                        if len(disk_lines) >= 2:
                            parts = disk_lines[1].split()
                            if len(parts) >= 5:
                                system_info['disk_total'] = parts[1]
                                system_info['disk_used'] = parts[2]
                                system_info['disk_available'] = parts[3]
                                system_info['disk_usage_percent'] = parts[4]
                except:
                    system_info['disk_usage_percent'] = '25%'  # 預設值
                
                # 獲取系統運行時間
                try:
                    uptime_result = subprocess.run(['uptime'], capture_output=True, text=True, timeout=2)
                    if uptime_result.returncode == 0:
                        system_info['uptime'] = uptime_result.stdout.strip()
                except:
                    system_info['uptime'] = 'N/A'
                    
            except Exception as e:
                print(f"系統資訊獲取錯誤: {e}")
                # 使用預設值
                cpu_usage = 20.0
                memory_usage = 50.0
                system_info['disk_usage_percent'] = '30%'

            response = {
                'success': True,
                'data': {
                    'timestamp': subprocess.run(['date', '+%Y-%m-%d %H:%M:%S'], 
                                              capture_output=True, text=True).stdout.strip(),
                    'server_status': server_status,
                    'docker_running': docker_running,
                    'container_status': container_status,
                    'players': {
                        'online': online_players,
                        'max': max_players,
                        'list': player_list
                    },
                    'system_resources': {
                        'cpu_usage': round(cpu_usage, 1),
                        'memory_usage': round(memory_usage, 1),
                        'disk_info': system_info
                    },
                    'system_info': system_info
                }
            }
            
            self._send_json_response(response)
            
        except Exception as e:
            self._send_json_response({'success': False, 'error': str(e)}, 500)

    def _handle_execute(self, data):
        """處理腳本執行"""
        script_name = data.get('script', '')
        args = data.get('args', [])
        
        if script_name not in ALLOWED_SCRIPTS:
            self._send_json_response({'success': False, 'error': 'Script not allowed'})
            return

        script_file = ALLOWED_SCRIPTS[script_name]
        script_path = SCRIPTS_DIR / script_file
        
        if not script_path.exists():
            self._send_json_response({'success': False, 'error': 'Script not found'})
            return

        try:
            # 構建命令
            cmd = ['bash', str(script_path)] + args
            
            # 執行腳本
            result = subprocess.run(cmd, 
                                  cwd=PROJECT_ROOT,
                                  capture_output=True, 
                                  text=True, 
                                  timeout=300)
            
            response = {
                'success': result.returncode == 0,
                'output': result.stdout,
                'error': result.stderr if result.returncode != 0 else None,
                'returnCode': result.returncode
            }
            
            self._send_json_response(response)
            
        except subprocess.TimeoutExpired:
            self._send_json_response({'success': False, 'error': 'Script execution timeout'})
        except Exception as e:
            self._send_json_response({'success': False, 'error': str(e)})

    def _handle_logs(self):
        """處理日誌查詢"""
        try:
            logs_dir = PROJECT_ROOT / 'logs'
            logs = {}
            
            if logs_dir.exists():
                for log_file in logs_dir.glob('*.log'):
                    try:
                        with open(log_file, 'r', encoding='utf-8') as f:
                            lines = f.readlines()
                            logs[log_file.name] = lines[-50:]  # 最後50行
                    except Exception as e:
                        logs[log_file.name] = [f"讀取錯誤: {e}"]
            
            self._send_json_response({'success': True, 'data': logs})
            
        except Exception as e:
            self._send_json_response({'success': False, 'error': str(e)})

    def _handle_files(self, subpath):
        """處理檔案列表查詢"""
        allowed_paths = ['backups', 'plugins', 'logs']
        
        if subpath not in allowed_paths:
            self._send_json_response({'error': 'Path not allowed'}, 403)
            return

        try:
            full_path = PROJECT_ROOT / subpath
            files = []
            
            if full_path.exists() and full_path.is_dir():
                for item in full_path.iterdir():
                    if item.name.startswith('.'):
                        continue
                        
                    file_info = {
                        'name': item.name,
                        'type': 'directory' if item.is_dir() else 'file'
                    }
                    
                    if item.is_file():
                        file_info['size'] = item.stat().st_size
                        file_info['modified'] = item.stat().st_mtime
                    
                    files.append(file_info)
            
            # 按修改時間排序
            files.sort(key=lambda x: x.get('modified', 0), reverse=True)
            
            self._send_json_response({'success': True, 'data': files})
            
        except Exception as e:
            self._send_json_response({'success': False, 'error': str(e)})

    def _handle_kick_player(self, data):
        """處理踢出玩家請求"""
        try:
            player_name = data.get('player_name', '').strip()
            reason = data.get('reason', 'Kicked by admin').strip()
            
            if not player_name:
                self._send_json_response({'success': False, 'error': '玩家名稱不能為空'})
                return
            
            # 檢查伺服器是否在運行
            docker_cmd = f'cd "{PROJECT_ROOT}/docker" && docker compose ps 2>/dev/null'
            result = subprocess.run(docker_cmd, shell=True, capture_output=True, text=True)
            
            if result.returncode != 0 or 'Up' not in result.stdout:
                self._send_json_response({
                    'success': False, 
                    'error': '伺服器未運行，無法踢出玩家',
                    'details': '請先啟動 Minecraft 伺服器'
                })
                return
            
            # 嘗試多種踢出方法
            kick_methods = [
                # 方法 1: 使用 rcon-cli
                f'cd "{PROJECT_ROOT}/docker" && docker compose exec -T minecraft-server rcon-cli kick "{player_name}" "{reason}"',
                # 方法 2: 使用 mc-send-to-console
                f'cd "{PROJECT_ROOT}/docker" && docker compose exec -T minecraft-server mc-send-to-console "kick {player_name} {reason}"',
                # 方法 3: 直接執行 docker exec
                f'docker exec $(docker ps -q -f name=minecraft-server) rcon-cli kick "{player_name}" "{reason}"',
                # 方法 4: 使用 docker exec 和 mc-send-to-console
                f'docker exec $(docker ps -q -f name=minecraft-server) mc-send-to-console "kick {player_name} {reason}"'
            ]
            
            success = False
            last_error = ""
            for i, cmd in enumerate(kick_methods, 1):
                try:
                    print(f"嘗試踢出方法 {i}: {cmd}")
                    kick_result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=15)
                    
                    if kick_result.returncode == 0:
                        success = True
                        self._send_json_response({
                            'success': True, 
                            'message': f'玩家 {player_name} 已被踢出 (方法 {i})',
                            'output': kick_result.stdout.strip(),
                            'method_used': i
                        })
                        print(f"✅ 玩家 {player_name} 已被踢出，原因: {reason} (使用方法 {i})")
                        break
                    else:
                        last_error = f"方法 {i} 失敗: {kick_result.stderr or kick_result.stdout}"
                        print(f"❌ {last_error}")
                        
                except subprocess.TimeoutExpired:
                    last_error = f"方法 {i} 超時"
                    print(f"❌ {last_error}")
                except Exception as e:
                    last_error = f"方法 {i} 錯誤: {str(e)}"
                    print(f"❌ {last_error}")
            
            if not success:
                # 如果所有方法都失敗，嘗試模擬踢出（僅用於測試）
                self._send_json_response({
                    'success': False, 
                    'error': f'所有踢出方法都失敗',
                    'details': last_error,
                    'simulation': f'模擬踢出玩家 {player_name}，原因: {reason}'
                })
                    
        except Exception as e:
            self._send_json_response({'success': False, 'error': f'踢出玩家時發生錯誤: {str(e)}'})
            print(f"❌ 踢出玩家錯誤: {e}")

    def log_message(self, format, *args):
        """自定義日誌格式"""
        print(f"[{self.log_date_time_string()}] {format % args}")

def main():
    """主函數"""
    try:
        with socketserver.TCPServer(("", PORT), MinecraftAPIHandler) as httpd:
            print(f"🌐 Yu Minecraft Web API 已啟動")
            print(f"📡 API 地址: http://localhost:{PORT}")
            print(f"📁 專案目錄: {PROJECT_ROOT}")
            print(f"📜 腳本目錄: {SCRIPTS_DIR}")
            print(f"🔧 可用腳本: {list(ALLOWED_SCRIPTS.keys())}")
            print("按 Ctrl+C 停止服務")
            httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n👋 服務已停止")
    except Exception as e:
        print(f"❌ 服務啟動失敗: {e}")

if __name__ == "__main__":
    main()
