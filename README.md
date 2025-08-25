# Yu Minecraft 私服 (v1.21.8)

一個基於Docker的Minecraft私服專案，提供簡單易用的部署和管理方案。現已支援最新的 Minecraft 1.21.8 版本！

## ✨ 新版本特色

- 🆕 **完全支援 Minecraft 1.21.8**
- 🏗️ **新特性整合**：Crafter、Trial Chambers、Wind Charges 等
- ⚡ **效能最佳化**：針對 1.21.8 的專屬調優
- 🔌 **外掛相容性**：與最新外掛完美整合

## 📋 開發流程

### 第一階段：基礎環境建置

1. **Docker環境配置**
   - 建立Dockerfile用於Minecraft伺服器
   - 配置docker-compose.yml用於容器編排
   - 設定資料持久化卷

2. **伺服器配置**
   - 配置server.properties檔案
   - 設定伺服器基本參數（埠號、最大玩家數等）
   - 配置白名單和權限系統

### 第二階段：自動化部署

1. **部署腳本**
   - 建立啟動/停止腳本
   - 設定備份腳本
   - 配置記錄管理

2. **監控系統**
   - 伺服器狀態監控
   - 玩家線上監控
   - 資源使用監控

### 第三階段：管理工具

1. **Web管理介面**
   - 伺服器控制面板
   - 玩家管理
   - 外掛管理

2. **外掛整合**
   - 常用外掛預配置
   - 自訂外掛開發
   - 外掛熱更新

### 第四階段：最佳化和擴展

1. **效能最佳化**
   - JVM參數調優
   - 伺服器效能監控
   - 資源使用最佳化

2. **功能擴展**
   - 多世界支援
   - 經濟系統
   - 社交功能

## 🚀 快速開始

### 系統要求

- Docker 20.0+
- Docker Compose 2.0+
- 至少4GB RAM
- 10GB可用磁碟空間

### 安裝部署

```bash
# 複製專案
git clone https://github.com/yu-codes/yu-minecraft.git
cd yu-minecraft

# 啟動伺服器
docker-compose up -d

# 查看記錄
docker-compose logs -f minecraft
```

## 📁 專案結構

```text
yu-minecraft/
├── docker/
│   ├── Dockerfile
│   └── docker-compose.yml
├── config/
│   ├── server.properties
│   ├── whitelist.json
│   └── ops.json
├── scripts/
│   ├── start.sh
│   ├── stop.sh
│   └── backup.sh
├── web/
│   ├── index.html
│   └── assets/
├── plugins/
└── worlds/
```

## 🔧 配置說明

### 伺服器配置

- **埠號**: 25565 (可在docker-compose.yml中修改)
- **版本**: Minecraft 1.21.8 (正式版)
- **Java**: Java 21 LTS
- **最大玩家數**: 20 (可在server.properties中修改)
- **遊戲模式**: Survival (可配置)
- **難度**: Normal (可配置)

### 預設管理員

初次啟動後，將yourname新增到ops.json中獲得管理員權限。

## 📝 使用說明

### 整合管理介面

```bash
./manage.sh
```

### 伺服器基本操作

#### 啟動伺服器

```bash
./scripts/start.sh
```

#### 停止伺服器

```bash
./scripts/stop.sh
```

#### 備份世界

```bash
./scripts/backup.sh
```

### 監控與效能

#### 即時監控

```bash
# 一次性監控
./scripts/monitor.sh

# 連續監控
./scripts/monitor.sh continuous

# 查看監控記錄
./scripts/monitor.sh logs
```

#### 效能分析

```bash
# 記錄效能資料
./scripts/performance.sh

# 生成效能報告
./scripts/performance.sh report

# 匯出效能資料
./scripts/performance.sh export
```

#### 效能最佳化

```bash
# 完整最佳化
./scripts/optimize.sh

# 系統效能檢查
./scripts/optimize.sh check
```

### 外掛管理

#### 外掛基本操作

```bash
# 查看已安裝外掛
./scripts/plugins.sh

# 查看推薦外掛
./scripts/plugins.sh recommended

# 下載外掛
./scripts/plugins.sh download <外掛名稱>

# 移除外掛
./scripts/plugins.sh remove <外掛名稱>

# 安裝基本外掛套件
./scripts/plugins.sh essentials
```

#### 外掛備份與恢復

```bash
# 備份外掛
./scripts/plugins.sh backup

# 恢復外掛
./scripts/plugins.sh restore <備份檔案>
```

### 查看伺服器狀態

訪問 <http://localhost:8080> 查看Web管理介面

## 🌐 遠端連線設定

### 本地網路連線（區域網）

如果你想讓同一區域網路的朋友連線：

1. **查看你的內網 IP**：

   ```bash
   # macOS/Linux
   ifconfig | grep "inet " | grep -v 127.0.0.1
   
   # Windows
   ipconfig
   ```

2. **朋友連線方式**：
   - 伺服器地址：`你的內網IP:25565`
   - 例如：`192.168.1.100:25565`

### 外網連線設定

#### 方法一：固定 IP 連線（最直接）

適用於有固定公網 IP 或使用 VPS/雲端伺服器的用戶。

```bash
# 自動設置固定 IP 連線（包含防火牆配置）
./scripts/remote-connect-fixed-ip.sh
```

**適用場景**：
- 有固定公網 IP 的家用網路
- VPS/雲端伺服器部署
- 可以控制路由器設定的環境

**優點**：
- 最佳效能和穩定性
- 無第三方服務依賴
- 完全掌控連線品質

---

#### 方法二：使用 ngrok（推薦）

ngrok 是業界標準的隧道服務，穩定可靠。

```bash
# 一鍵設置 ngrok
./scripts/remote-connect-ngrok.sh
```

**📋 詳細設置指南**: 請參考 [`NGROK_SETUP_GUIDE.md`](./NGROK_SETUP_GUIDE.md)

包含完整的註冊、信用卡綁定、authtoken 設置等步驟說明。

**📊 流量監控功能**：

```bash
# 互動式監控（推薦）
./scripts/ngrok-monitor.sh

# 背景自動監控
./scripts/ngrok-auto-monitor.sh start
```

監控功能包括：
- 即時流量統計和連線監控
- 自動警報系統（超出閾值時通知）
- 每日使用報告生成
- 本地 Web 界面快速開啟
- 線上儀表板直接存取

**優點**：
- 業界標準，穩定可靠
- 支援流量監控
- 可升級獲得固定網址
- 安全性高，使用 TLS 加密

**注意**：免費版需要綁定信用卡（不扣款），每月 1GB 免費流量

---

#### 方法三：其他免費選項

如果不想綁定信用卡，可以使用這些完全免費的替代方案：

**選項 A：playit.gg（專為遊戲設計）**

```bash
./scripts/remote-connect-playit.sh
```

**選項 B：Serveo（基於 SSH）**

```bash
./scripts/remote-connect-serveo.sh
```

#### 方法四：使用 Tailscale（最安全）

```bash
# 一鍵設置 Tailscale VPN
./scripts/remote-connect-tailscale.sh
```

這個腳本會自動：
- 檢查並安裝 Tailscale
- 設置 VPN 連線
- 顯示你的私有 IP
- 提供朋友的連線指南

**優點**：完全私密、穩定、不斷線  
**缺點**：所有朋友都需要安裝 Tailscale

### 防火牆設定

確保防火牆允許 25565 端口：

#### macOS

```bash
# 檢查防火牆狀態
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate

# 如果需要，允許 Docker
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /Applications/Docker.app
```

#### Linux (Ubuntu/Debian)

```bash
# 允許 25565 端口
sudo ufw allow 25565/tcp

# 檢查狀態
sudo ufw status
```

#### Windows

```powershell
# 以管理員身份運行 PowerShell
New-NetFirewallRule -DisplayName "Minecraft Server" -Direction Inbound -LocalPort 25565 -Protocol TCP -Action Allow
```

### 安全建議

1. **使用白名單**：

   ```bash
   # 編輯 config/whitelist.json
   # 只允許信任的玩家連線
   ```

2. **設定管理員**：

   ```bash
   # 編輯 config/ops.json
   # 給信任的玩家管理員權限
   ```

3. **定期備份**：

   ```bash
   # 使用備份腳本
   ./scripts/backup.sh
   ```

4. **監控連線**：

   ```bash
   # 監控伺服器狀態
   ./scripts/monitor.sh continuous
   ```

### 常見問題

**Q: 朋友無法連線？**

- 檢查防火牆設定
- 確認端口轉發正確
- 驗證公網 IP 是否正確
- **WiFi 使用者特別注意**：需要額外設定路由器端口轉發

**Q: 我無法修改路由器設定，有其他方式嗎？**

如果你無法訪問路由器設定（學校宿舍、公司網路、租屋等），可以使用以下替代方案：

**方案一：使用 ngrok（最簡單）**

1. **註冊並安裝 ngrok**：
   
   ```bash
   # 註冊：https://ngrok.com/signup（免費）
   # macOS 安裝：
   brew install ngrok/ngrok/ngrok
   
   # 或直接下載：https://ngrok.com/download
   ```

2. **設置驗證**：
   
   ```bash
   # 在 ngrok 網站取得 authtoken 後執行：
   ngrok config add-authtoken <你的authtoken>
   ```

3. **啟動隧道**：
   
   ```bash
   ngrok tcp 25565
   ```

4. **取得連線地址**：
   - ngrok 會顯示類似：`0.tcp.ngrok.io:12345`
   - 將此地址給朋友連線

**方案二：使用 Tailscale VPN（最安全）**

1. **所有人安裝 Tailscale**：
   - 到 https://tailscale.com 下載
   - 用同一個 Google/Microsoft 帳號登入

2. **連線方式**：
   - 朋友使用你的 Tailscale IP 連線
   - 查看 IP：`tailscale ip -4`

**方案三：使用雲端伺服器（適合長期使用）**

1. **申請免費雲端服務**：
   - Oracle Cloud（永久免費）
   - Google Cloud（300美元免費額度）
   - AWS（12個月免費）

2. **部署到雲端**：
   
   ```bash
   # 複製專案到雲端伺服器
   git clone https://github.com/yu-codes/yu-minecraft.git
   cd yu-minecraft
   docker compose -f docker/docker-compose.yml up -d
   ```

**方案四：使用 VS Code Port Forwarding（臨時測試）**

如果你有 GitHub 帳號且使用 VS Code：

1. **安裝 VS Code 和 Remote-Tunnels 擴展**
2. **在終端執行**：
   
   ```bash
   # 啟動端口轉發
   code tunnel --accept-server-license-terms
   ```

3. **朋友通過 vscode.dev 連線**

**Q: 連線很慢？**

- 檢查網路頻寬
- 考慮調整伺服器配置
- 使用就近的 VPS

**Q: 如何限制玩家數量？**

- 編輯 `config/server.properties`
- 修改 `max-players=20`

## 🛠️ 開發計畫

- [x] 專案初始化
- [x] Docker環境配置
- [x] 基礎配置檔案
- [x] 部署腳本
- [x] Web管理介面
- [x] 監控系統
- [x] 外掛整合
- [x] 效能最佳化

## 📧 聯絡方式

如有問題或建議，請透過GitHub Issues聯絡。

## 📄 授權條款

MIT License
