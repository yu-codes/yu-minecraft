# ☁️ AWS Minecraft 伺服器部署指南

本指南將詳細說明如何在 Amazon Web Services (AWS) 上部署 Yu Minecraft 私服，實現 24/7 穩定運行。

## 📋 目錄

1. [AWS 帳號準備](#aws-帳號準備)
2. [EC2 實例配置](#ec2-實例配置)
3. [安全群組設置](#安全群組設置)
4. [連接到伺服器](#連接到伺服器)
5. [環境安裝](#環境安裝)
6. [部署 Minecraft 伺服器](#部署-minecraft-伺服器)
7. [網域與 DNS 設置](#網域與-dns-設置)
8. [監控與維護](#監控與維護)
9. [成本優化](#成本優化)
10. [故障排除](#故障排除)

## 🚀 AWS 帳號準備

### 步驟 1：註冊 AWS 帳號

1. **訪問 AWS 官網**：https://aws.amazon.com/
2. **點擊 "建立 AWS 帳戶"**
3. **填寫基本資訊**：
   - 電子郵件地址
   - 密碼
   - AWS 帳戶名稱

4. **驗證聯絡資訊**：
   - 姓名、地址、電話號碼
   - 選擇帳戶類型：個人

5. **信用卡資訊**：
   - 輸入有效的信用卡資訊
   - AWS 會進行小額驗證（通常 $1）

6. **身份驗證**：
   - 電話驗證（自動語音或簡訊）
   - 輸入驗證碼

7. **選擇支援方案**：
   - 選擇 "基本支援 - 免費"

### 步驟 2：啟用免費方案

AWS 免費方案包括：
- **EC2 t2.micro 實例**：每月 750 小時免費（12 個月）
- **EBS 儲存空間**：30GB 免費
- **數據傳輸**：每月 15GB 免費

## 🖥️ EC2 實例配置

### 步驟 1：登入 AWS 管理控制台

1. 前往 https://console.aws.amazon.com/
2. 使用您的 AWS 帳號登入
3. 確認地區選擇（建議選擇最近的地區）：
   - **亞太地區 (東京)** - ap-northeast-1
   - **亞太地區 (新加坡)** - ap-southeast-1

### 步驟 2：啟動 EC2 實例

1. **搜尋服務**：
   - 在控制台頂部搜尋 "EC2"
   - 點擊 "EC2" 服務

2. **啟動實例**：
   - 點擊 "啟動實例" 按鈕
   - 為實例命名：`Yu-Minecraft-Server`

3. **選擇 AMI（Amazon Machine Image）**：
   - 選擇 **Ubuntu Server 22.04 LTS (HVM)**
   - 架構：64-bit (x86)
   - 確認標示 "符合免費方案資格"

4. **選擇實例類型**：
   - 選擇 **t2.micro**（符合免費方案）
   - vCPU：1
   - 記憶體：1 GiB

### 步驟 3：建立金鑰對

1. **金鑰對設置**：
   - 點擊 "建立新的金鑰對"
   - 金鑰對名稱：`minecraft-server-key`
   - 金鑰對類型：RSA
   - 私有金鑰檔案格式：.pem

2. **下載金鑰**：
   - 點擊 "建立金鑰對"
   - **重要**：妥善保存下載的 .pem 檔案

### 步驟 4：網路設置

1. **VPC 設置**：
   - 使用預設 VPC
   - 子網路：選擇任一可用區域

2. **自動指派公用 IPv4 地址**：
   - 選擇 "啟用"

### 步驟 5：儲存配置

1. **根磁碟區設置**：
   - 磁碟區類型：gp3
   - 大小：20 GiB（免費方案上限為 30GB）
   - 加密：保持預設

## 🔒 安全群組設置

### 建立安全群組

1. **安全群組名稱**：`minecraft-security-group`
2. **描述**：Security group for Minecraft server

### 輸入規則設置

添加以下規則：

| 類型 | 協定 | 連接埠範圍 | 來源 | 描述 |
|------|------|------------|------|------|
| SSH | TCP | 22 | 我的 IP | SSH 連接 |
| 自訂 TCP | TCP | 25565 | 0.0.0.0/0 | Minecraft 伺服器 |
| HTTP | TCP | 80 | 0.0.0.0/0 | Web 管理介面 |
| HTTPS | TCP | 443 | 0.0.0.0/0 | 安全 Web 訪問 |
| 自訂 TCP | TCP | 8080 | 我的 IP | 管理面板 |

### 詳細規則說明

```bash
# SSH 訪問 (僅限您的 IP)
Type: SSH
Protocol: TCP
Port Range: 22
Source: My IP (自動偵測)

# Minecraft 遊戲連接 (所有 IP)
Type: Custom TCP Rule
Protocol: TCP
Port Range: 25565
Source: 0.0.0.0/0

# Web 管理介面
Type: HTTP
Protocol: TCP
Port Range: 80
Source: 0.0.0.0/0

# 安全 Web 訪問
Type: HTTPS
Protocol: TCP
Port Range: 443
Source: 0.0.0.0/0

# 管理控制台 (僅限您的 IP)
Type: Custom TCP Rule
Protocol: TCP
Port Range: 8080
Source: My IP
```

## 🔗 連接到伺服器

### Windows 用戶（使用 PowerShell）

1. **準備金鑰檔案**：
   ```powershell
   # 移動金鑰檔案到適當位置
   Move-Item "Downloads\minecraft-server-key.pem" "C:\Users\$env:USERNAME\.ssh\"
   
   # 設置檔案權限
   icacls "C:\Users\$env:USERNAME\.ssh\minecraft-server-key.pem" /inheritance:r
   icacls "C:\Users\$env:USERNAME\.ssh\minecraft-server-key.pem" /grant:r "$env:USERNAME:(R)"
   ```

2. **連接到 EC2 實例**：
   ```powershell
   # 替換 YOUR_EC2_PUBLIC_IP 為實際的公用 IP
   ssh -i "C:\Users\$env:USERNAME\.ssh\minecraft-server-key.pem" ubuntu@YOUR_EC2_PUBLIC_IP
   ```

### macOS/Linux 用戶

```bash
# 設置金鑰檔案權限
chmod 400 ~/Downloads/minecraft-server-key.pem

# 移動到 SSH 目錄
mv ~/Downloads/minecraft-server-key.pem ~/.ssh/

# 連接到伺服器
ssh -i ~/.ssh/minecraft-server-key.pem ubuntu@YOUR_EC2_PUBLIC_IP
```

## 🛠️ 環境安裝

### 步驟 1：系統更新

```bash
# 更新套件列表
sudo apt update

# 升級系統套件
sudo apt upgrade -y

# 安裝基本工具
sudo apt install -y curl wget unzip git htop tree
```

### 步驟 2：安裝 Docker

```bash
# 安裝 Docker 相依性
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# 添加 Docker 官方 GPG 金鑰
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# 添加 Docker 儲存庫
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 更新套件列表
sudo apt update

# 安裝 Docker
sudo apt install -y docker-ce docker-ce-cli containerd.io

# 安裝 Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 將使用者加入 Docker 群組
sudo usermod -aG docker ubuntu

# 重新登入以套用群組變更
exit
```

重新連接到伺服器：
```bash
ssh -i ~/.ssh/minecraft-server-key.pem ubuntu@YOUR_EC2_PUBLIC_IP
```

### 步驟 3：驗證安裝

```bash
# 檢查 Docker 版本
docker --version

# 檢查 Docker Compose 版本
docker-compose --version

# 測試 Docker 運行
docker run hello-world
```

## 🎮 部署 Minecraft 伺服器

### 步驟 1：下載專案

```bash
# 克隆 Yu Minecraft 專案
git clone https://github.com/yu-codes/yu-minecraft.git

# 進入專案目錄
cd yu-minecraft

# 檢查專案結構
tree -L 2
```

### 步驟 2：環境配置

```bash
# 複製環境變數範例
cp .env.example .env

# 編輯環境配置
nano .env
```

**AWS 優化的 `.env` 配置**：
```bash
# 伺服器基本設置
MEMORY=1536M                    # AWS t2.micro 記憶體優化
RCON_PASSWORD=your-secure-password-here
SERVER_NAME=Yu Minecraft Server on AWS

# 伺服器屬性
MAX_PLAYERS=10                  # 降低最大玩家數以節省資源
DIFFICULTY=normal
GAMEMODE=survival
ENABLE_WHITELIST=true

# AWS 特定設置
LOG_LEVEL=WARN                  # 減少日誌輸出
ENABLE_QUERY=true
QUERY_PORT=25565

# 🔔 通知設定（重要！讓朋友自動收到連線資訊）
# 選擇一種或多種通知方式，詳細設定請參考 NOTIFICATION_SETUP_GUIDE.md

# Discord Webhook（推薦）
# DISCORD_WEBHOOK=https://discord.com/api/webhooks/YOUR_WEBHOOK_URL

# Telegram Bot
# TELEGRAM_BOT_TOKEN=YOUR_BOT_TOKEN
# TELEGRAM_CHAT_ID=YOUR_CHAT_ID

# Line Notify
# LINE_NOTIFY_TOKEN=YOUR_LINE_TOKEN

# 自動通知設定
AUTO_NOTIFY_STARTUP=true
AUTO_NOTIFY_SHUTDOWN=true
AUTO_NOTIFY_ERRORS=true

# 效能優化
VIEW_DISTANCE=6                 # 降低視距以節省 CPU
SIMULATION_DISTANCE=4
NETWORK_COMPRESSION_THRESHOLD=256
```

### 步驟 3：設定自動通知（推薦）

為了讓朋友們自動收到伺服器連線資訊，建議設定通知功能：

#### 🎯 快速設定 Discord 通知

1. **在 Discord 伺服器中設定 Webhook**：
   ```
   伺服器設定 → 整合 → Webhooks → 建立 Webhook
   ```

2. **複製 Webhook URL 並加入 .env**：
   ```bash
   nano .env
   # 取消註解並填入你的 Webhook URL
   DISCORD_WEBHOOK=https://discord.com/api/webhooks/YOUR_WEBHOOK_URL
   ```

3. **測試通知功能**：
   ```bash
   # 測試通知設定
   ./scripts/notify.sh -t
   ```

#### 📱 其他通知方式

- **Telegram**: 適合群組通知
- **Line Notify**: 台灣用戶推薦
- **Email**: 傳統方式

**完整通知設定指南**: [NOTIFICATION_SETUP_GUIDE.md](./NOTIFICATION_SETUP_GUIDE.md)

### 步驟 4：配置管理員和白名單

```bash
# 複製管理員配置
cp config/ops.json.example config/ops.json

# 編輯管理員列表
nano config/ops.json
```

在 `config/ops.json` 中添加您的 Minecraft 帳號：
```json
[
  {
    "uuid": "your-minecraft-uuid",
    "name": "your-minecraft-username",
    "level": 4,
    "bypassesPlayerLimit": true
  }
]
```

### 步驟 4：白名單設置

```bash
# 複製白名單配置
cp config/whitelist.json.example config/whitelist.json

# 編輯白名單
nano config/whitelist.json
```

### 步驟 5：部署伺服器

```bash
# 執行快速部署
./deploy.sh

# 查看部署狀態
docker-compose logs -f minecraft
```

等待看到類似以下訊息表示啟動成功：
```
minecraft_1  | [INFO] Done (XX.XXXs)! For help, type "help"
minecraft_1  | [INFO] Timings Reset
```

### 步驟 6：測試連接

1. **取得公用 IP 地址**：
   ```bash
   curl http://checkip.amazonaws.com
   ```

2. **在 Minecraft 客戶端連接**：
   - 伺服器地址：`YOUR_EC2_PUBLIC_IP:25565`

## 🌐 網域與 DNS 設置（可選）

### 使用 Route 53 設置自訂網域

1. **購買網域**：
   - 在 AWS Route 53 購買網域
   - 或使用現有網域並修改 DNS 設定

2. **建立 Hosted Zone**：
   ```bash
   # 記錄您的 EC2 公用 IP
   echo "EC2 Public IP: $(curl -s http://checkip.amazonaws.com)"
   ```

3. **添加 A 記錄**：
   - 名稱：minecraft
   - 類型：A
   - 值：您的 EC2 公用 IP
   - TTL：300

4. **測試 DNS 解析**：
   ```bash
   nslookup minecraft.yourdomain.com
   ```

## 📊 監控與維護

### 設置系統監控

```bash
# 建立監控腳本
cat << 'EOF' > ~/monitor-system.sh
#!/bin/bash
echo "=== System Status at $(date) ==="
echo "CPU Usage:"
top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1

echo "Memory Usage:"
free -m | awk 'NR==2{printf "%.2f%%\n", $3*100/$2}'

echo "Disk Usage:"
df -h | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{print $5 " " $1}'

echo "Docker Containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo "Minecraft Server Status:"
docker-compose -f /home/ubuntu/yu-minecraft/docker/docker-compose.yml ps
EOF

chmod +x ~/monitor-system.sh
```

### 設置自動備份

```bash
# 建立備份腳本
cat << 'EOF' > ~/backup-minecraft.sh
#!/bin/bash
BACKUP_DIR="/home/ubuntu/minecraft-backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

echo "Starting backup at $(date)"
cd /home/ubuntu/yu-minecraft

# 停止伺服器
docker-compose stop minecraft

# 建立備份
tar -czf "$BACKUP_DIR/minecraft_backup_$DATE.tar.gz" worlds/ plugins/ config/

# 重啟伺服器
docker-compose start minecraft

echo "Backup completed: minecraft_backup_$DATE.tar.gz"

# 清理超過 7 天的備份
find $BACKUP_DIR -name "minecraft_backup_*.tar.gz" -mtime +7 -delete
EOF

chmod +x ~/backup-minecraft.sh
```

### 設置定時任務

```bash
# 編輯 crontab
crontab -e

# 添加以下行：
# 每天凌晨 2 點備份
0 2 * * * /home/ubuntu/backup-minecraft.sh >> /home/ubuntu/backup.log 2>&1

# 每小時監控系統
0 * * * * /home/ubuntu/monitor-system.sh >> /home/ubuntu/monitor.log 2>&1
```

## 💰 成本優化

### 使用 Spot 實例（進階用戶）

1. **建立啟動範本**：
   - 包含您的 AMI、安全群組、金鑰對設置

2. **設置 Spot Fleet**：
   - 目標容量：1 個實例
   - 最高出價：$0.01/小時

3. **自動化部署腳本**：
   ```bash
   #!/bin/bash
   # 在新實例啟動時自動部署
   aws s3 sync s3://your-backup-bucket/minecraft-data /home/ubuntu/yu-minecraft/
   cd /home/ubuntu/yu-minecraft
   docker-compose up -d
   ```

### 資源監控和警報

```bash
# 設置 CloudWatch 警報
aws cloudwatch put-metric-alarm \
    --alarm-name "High-CPU-Utilization" \
    --alarm-description "Alert when CPU exceeds 80%" \
    --metric-name CPUUtilization \
    --namespace AWS/EC2 \
    --statistic Average \
    --period 300 \
    --threshold 80 \
    --comparison-operator GreaterThanThreshold \
    --evaluation-periods 2
```

## 🛠️ 故障排除

### 常見問題

#### 1. 無法連接到伺服器

**檢查清單**：
```bash
# 檢查安全群組
aws ec2 describe-security-groups --group-names minecraft-security-group

# 檢查實例狀態
aws ec2 describe-instances --instance-ids YOUR_INSTANCE_ID

# 檢查 Docker 容器
docker ps -a

# 檢查伺服器日誌
docker-compose logs minecraft
```

#### 2. 記憶體不足

**優化方案**：
```bash
# 調整 JVM 記憶體設置
# 編輯 .env 檔案
MEMORY=1024M

# 減少同時在線玩家數
MAX_PLAYERS=5

# 降低視距
VIEW_DISTANCE=4
SIMULATION_DISTANCE=3
```

#### 3. 磁碟空間不足

**清理方案**：
```bash
# 清理 Docker 映像
docker system prune -a

# 清理舊的日誌檔案
find /home/ubuntu/yu-minecraft/logs -name "*.log*" -mtime +7 -delete

# 檢查磁碟使用
df -h
du -sh /home/ubuntu/yu-minecraft/*
```

#### 4. 效能調優

**伺服器最佳化**：
```bash
# 執行內建最佳化
cd /home/ubuntu/yu-minecraft
./scripts/optimize.sh all

# 監控效能
./scripts/monitor.sh continuous
```

## 🔧 進階配置

### SSL 憑證設置（使用 Let's Encrypt）

```bash
# 安裝 Certbot
sudo apt install -y certbot

# 取得 SSL 憑證
sudo certbot certonly --standalone -d minecraft.yourdomain.com

# 設置自動更新
sudo crontab -e
# 添加：0 12 * * * /usr/bin/certbot renew --quiet
```

### 自動擴展儲存空間

```bash
# 建立擴展腳本
cat << 'EOF' > ~/expand-storage.sh
#!/bin/bash
THRESHOLD=80
USAGE=$(df /home | awk 'NR==2 {print $5}' | cut -d'%' -f1)

if [ $USAGE -gt $THRESHOLD ]; then
    echo "Disk usage is ${USAGE}%, expanding EBS volume..."
    # 這裡需要 AWS CLI 命令來擴展 EBS 卷
    aws ec2 modify-volume --volume-id vol-xxxxxxxxx --size 40
fi
EOF
```

### 多區域災難恢復

```bash
# 設置跨區域複製
aws s3 sync /home/ubuntu/minecraft-backups/ s3://minecraft-backup-bucket/
aws s3api put-bucket-replication --bucket minecraft-backup-bucket --replication-configuration file://replication.json
```

## 📱 管理工具

### Web 管理介面設置

```bash
# 啟動 Web 管理介面
cd /home/ubuntu/yu-minecraft
docker-compose up -d web

# 訪問管理介面
echo "管理介面 URL: http://$(curl -s http://checkip.amazonaws.com):8080"
```

### 手機監控應用

推薦使用以下應用監控您的伺服器：
- **AWS Console Mobile App**：監控 AWS 資源
- **Termius**：SSH 客戶端，可從手機連接伺服器
- **MCPE Server Manager**：Minecraft 伺服器管理

## 📋 部署檢核表

在完成部署後，請確認以下項目：

- [ ] EC2 實例正常運行
- [ ] 安全群組正確配置
- [ ] Docker 和 Docker Compose 安裝成功
- [ ] Minecraft 伺服器容器啟動
- [ ] 能夠從客戶端連接到伺服器
- [ ] 管理員權限正確設置
- [ ] 白名單功能運作正常
- [ ] 自動備份腳本配置
- [ ] 監控腳本運作
- [ ] DNS 解析正確（如有配置）

## 🎯 後續步驟

部署完成後，您可以：

1. **邀請朋友加入**：
   - 提供伺服器 IP 位址
   - 將朋友加入白名單

2. **安裝外掛**：
   ```bash
   cd /home/ubuntu/yu-minecraft
   ./scripts/plugins.sh recommended
   ```

3. **效能最佳化**：
   ```bash
   ./scripts/optimize.sh all
   ```

4. **設置更多監控**：
   - CloudWatch 監控
   - 警報通知
   - 效能儀表板

---

## 🎮 恭喜！您的 AWS Minecraft 伺服器已準備就緒！

您現在擁有一個在雲端運行的專業 Minecraft 伺服器，具備：
- ☁️ 24/7 穩定運行
- 🛡️ 企業級安全性
- 📊 完整監控和備份
- 🔧 簡單的管理工具
- 💰 成本優化配置

享受與朋友們的 Minecraft 冒險之旅吧！

如有任何問題，請參考[故障排除](#故障排除)章節或查看專案的 GitHub Issues。
