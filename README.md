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

#### 方法一：路由器端口轉發（推薦）

1. **登入路由器管理界面**：
   - 通常是 `192.168.1.1` 或 `192.168.0.1`
   - 使用管理員帳號密碼登入

2. **設定端口轉發**：
   - 找到「端口轉發」或「虛擬伺服器」設定
   - 添加規則：
     - 服務名稱：Minecraft Server
     - 內部 IP：你的電腦內網 IP
     - 內部端口：25565
     - 外部端口：25565
     - 協議：TCP

3. **取得公網 IP**：

   ```bash
   curl ifconfig.me
   ```

4. **朋友連線方式**：
   - 伺服器地址：`你的公網IP:25565`

#### 方法二：使用 ngrok（簡單但有限制）

1. **安裝 ngrok**：

   ```bash
   # 到 https://ngrok.com 註冊並下載
   # 或使用 Homebrew (macOS)
   brew install ngrok/ngrok/ngrok
   ```

2. **設置 ngrok**：

   ```bash
   # 使用你的 authtoken
   ngrok config add-authtoken <your-authtoken>
   ```

3. **啟動隧道**：

   ```bash
   ngrok tcp 25565
   ```

4. **取得連線地址**：
   - ngrok 會顯示類似：`0.tcp.ngrok.io:12345`
   - 這就是朋友的連線地址

#### 方法三：使用 Tailscale（推薦給技術用戶）

1. **安裝 Tailscale**：

   ```bash
   # 到 https://tailscale.com 下載安裝
   ```

2. **設置 Tailscale**：
   - 在所有要連線的裝置上安裝 Tailscale
   - 使用同一個帳號登入

3. **連線方式**：
   - 朋友使用你的 Tailscale IP 連線
   - 例如：`100.x.x.x:25565`

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
