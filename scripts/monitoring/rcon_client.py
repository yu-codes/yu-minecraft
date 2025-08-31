#!/usr/bin/env python3
"""
Minecraft RCON 客戶端
用於通過 RCON 協議與 Minecraft 伺服器通信
"""

import socket
import struct
import sys
import time

class MinecraftRCON:
    def __init__(self, host='localhost', port=25575, password='yu-minecraft-2025'):
        self.host = host
        self.port = port
        self.password = password
        self.socket = None
        self.request_id = 0
    
    def connect(self):
        """連接到 RCON 伺服器"""
        try:
            self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.socket.settimeout(10)  # 10秒超時
            self.socket.connect((self.host, self.port))
            
            # 發送認證包
            auth_response = self._send_packet(3, self.password)  # 3 = SERVERDATA_AUTH
            if auth_response is None:
                raise Exception("認證失敗：無響應")
            
            # 檢查認證是否成功
            if auth_response['request_id'] == -1:
                raise Exception("認證失敗：密碼錯誤")
            
            return True
        except Exception as e:
            print(f"RCON 連接失敗: {e}")
            return False
    
    def _send_packet(self, packet_type, data):
        """發送 RCON 數據包"""
        if not self.socket:
            return None
        
        self.request_id += 1
        request_id = self.request_id
        
        # 構建數據包
        payload = data.encode('utf-8') + b'\x00\x00'
        packet_size = 4 + 4 + len(payload)  # request_id + type + payload
        
        packet = struct.pack('<i', packet_size) + \
                struct.pack('<i', request_id) + \
                struct.pack('<i', packet_type) + \
                payload
        
        try:
            self.socket.send(packet)
            return self._receive_packet()
        except Exception as e:
            print(f"發送數據包失敗: {e}")
            return None
    
    def _receive_packet(self):
        """接收 RCON 響應數據包"""
        try:
            # 讀取數據包大小
            size_data = self.socket.recv(4)
            if len(size_data) < 4:
                return None
            
            packet_size = struct.unpack('<i', size_data)[0]
            
            # 讀取完整數據包
            data = b''
            bytes_received = 0
            while bytes_received < packet_size:
                chunk = self.socket.recv(packet_size - bytes_received)
                if not chunk:
                    break
                data += chunk
                bytes_received += len(chunk)
            
            if len(data) < 8:  # 至少需要 request_id + type
                return None
            
            # 解析數據包
            request_id = struct.unpack('<i', data[0:4])[0]
            packet_type = struct.unpack('<i', data[4:8])[0]
            payload = data[8:-2].decode('utf-8', errors='ignore')  # 移除末尾的兩個null字節
            
            return {
                'request_id': request_id,
                'type': packet_type,
                'payload': payload
            }
        except Exception as e:
            print(f"接收數據包失敗: {e}")
            return None
    
    def execute_command(self, command):
        """執行 Minecraft 指令"""
        if not self.socket:
            if not self.connect():
                return None
        
        response = self._send_packet(2, command)  # 2 = SERVERDATA_EXECCOMMAND
        if response:
            return response['payload']
        return None
    
    def close(self):
        """關閉連接"""
        if self.socket:
            self.socket.close()
            self.socket = None

def main():
    if len(sys.argv) < 2:
        print("使用方式: python3 rcon_client.py <指令>")
        print("範例: python3 rcon_client.py 'list'")
        print("範例: python3 rcon_client.py 'kick Steve'")
        sys.exit(1)
    
    command = ' '.join(sys.argv[1:])
    
    # 連接到 RCON
    rcon = MinecraftRCON()
    
    try:
        if not rcon.connect():
            print("無法連接到 Minecraft RCON 伺服器")
            sys.exit(1)
        
        print(f"執行指令: {command}")
        result = rcon.execute_command(command)
        
        if result is not None:
            print("伺服器回應:")
            print(result)
        else:
            print("指令執行失敗")
            sys.exit(1)
    
    finally:
        rcon.close()

if __name__ == '__main__':
    main()
