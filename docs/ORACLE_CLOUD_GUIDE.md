# Oracle Cloud Minecraft 伺服器部署指南

## 📋 概述

Oracle Cloud Infrastructure (OCI) 提供永久免費的雲端服務，非常適合部署 Minecraft 伺服器。這個方案可以讓你的伺服器 24/7 運行，無需保持電腦開機。

## 🎯 Oracle Cloud 優勢

### ✅ 優點
- **永久免費**：無需信用卡付費（僅驗證用）
- **高效能**：ARM 處理器，最多 4 核心 + 24GB RAM
- **24/7 運行**：不需要保持家用電腦開機
- **固定 IP**：不會像 ngrok 一樣頻繁變更
- **無流量限制**：每月 10TB 免費流量
- **多實例**：最多可建立 4 個免費實例
- **企業級**：Oracle 企業級基礎設施

### ❌ 缺點
- **設定複雜**：需要一些技術知識
- **註冊門檻**：需要信用卡驗證（不會扣款）
- **區域限制**：某些區域可能額度已滿
- **管理複雜**：需要學習雲端管理

## 🚀 快速開始

### 自動化部署
```bash
# 執行自動化部署腳本
./scripts/remote-connect-oracle.sh
```

### 手動部署步驟

#### 1. 建立 Oracle Cloud 帳號
1. 訪問 [Oracle Cloud](https://cloud.oracle.com/zh_TW/)
2. 點擊「開始免費使用」
3. 填寫個人資料（需要真實姓名）
4. 驗證信用卡（僅驗證，不會扣款）
5. 完成電話驗證
6. 獲得 $300 試用額度 + 永久免費服務

#### 2. 建立運算實例

##### 基本設定
- **映像**: Ubuntu 22.04 LTS
- **形狀**: VM.Standard.A1.Flex (ARM)
- **CPU**: 4 核心
- **記憶體**: 24GB
- **儲存**: 100GB (免費額度內)

##### 網路設定
- **指派公用 IP**: 是
- **SSH 金鑰**: 上傳你的公鑰或產生新的

#### 3. 設定防火牆規則

```bash
# 開放 Minecraft 埠
# 在 OCI 控制台 → 網路 → 虛擬雲端網路 → 安全清單
# 新增輸入規則：
# - 來源: 0.0.0.0/0
# - IP 協定: TCP
# - 目的地埠範圍: 25565
```

#### 4. 連線到實例

```bash
# 使用 SSH 連線
ssh -i ~/.ssh/your-key ubuntu@YOUR_INSTANCE_IP

# 或使用 Oracle 提供的瀏覽器終端
```

#### 5. 安裝 Docker

```bash
# 更新系統
sudo apt update && sudo apt upgrade -y

# 安裝 Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker ubuntu

# 安裝 Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 重新登入以套用 Docker 群組
exit
ssh -i ~/.ssh/your-key ubuntu@YOUR_INSTANCE_IP
```

#### 6. 部署 Minecraft 伺服器

```bash
# 建立專案目錄
mkdir -p ~/minecraft-server
cd ~/minecraft-server

# 建立 docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  minecraft:
    image: itzg/minecraft-server:latest
    container_name: minecraft-server
    restart: unless-stopped
    ports:
      - "25565:25565"
    environment:
      EULA: "TRUE"
      TYPE: "PAPER"
      VERSION: "1.21"
      MEMORY: "20G"
      MAX_PLAYERS: "20"
      DIFFICULTY: "normal"
      WHITELIST: "false"
      MOTD: "Oracle Cloud Minecraft Server"
      ONLINE_MODE: "true"
      ENABLE_RCON: "true"
      RCON_PASSWORD: "minecraft123"
    volumes:
      - ./data:/data
    healthcheck:
      test: ["CMD", "mc-monitor", "status", "--host", "localhost", "--port", "25565"]
      interval: 30s
      timeout: 10s
      retries: 3

  # 可選：Web 管理介面
  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    restart: unless-stopped
    ports:
      - "9000:9000"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data

volumes:
  portainer_data:
EOF

# 啟動服務
docker-compose up -d
```

## 🛠️ 管理與維護

### 常用指令

```bash
# 查看伺服器狀態
docker ps

# 查看日誌
docker logs minecraft-server

# 重啟伺服器
docker-compose restart minecraft

# 停止伺服器
docker-compose down

# 更新伺服器
docker-compose pull
docker-compose up -d
```

### 自動備份設定

```bash
# 建立備份腳本
cat > backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/home/ubuntu/minecraft-backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# 建立備份
docker-compose down
tar -czf $BACKUP_DIR/minecraft_backup_$DATE.tar.gz data/
docker-compose up -d

# 清理舊備份 (保留最新 7 份)
ls -t $BACKUP_DIR/minecraft_backup_*.tar.gz | tail -n +8 | xargs -r rm

echo "備份完成: minecraft_backup_$DATE.tar.gz"
EOF

chmod +x backup.sh

# 設定每日自動備份 (凌晨 2 點)
(crontab -l 2>/dev/null; echo "0 2 * * * /home/ubuntu/minecraft-server/backup.sh") | crontab -
```

### 監控系統資源

```bash
# 即時監控
htop

# 硬碟使用量
df -h

# 記憶體使用量
free -h

# Docker 容器資源使用
docker stats
```

## 🔧 進階設定

### 效能優化

```yaml
# 在 docker-compose.yml 中調整 JVM 參數
environment:
  MEMORY: "20G"
  JVM_OPTS: "-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1"
```

### 網域名稱設定

```bash
# 1. 購買網域名稱
# 2. 設定 A 記錄指向你的 Oracle Cloud IP
# 3. 等待 DNS 傳播 (通常 1-24 小時)

# 測試網域解析
nslookup your-domain.com
```

### SSL 憑證 (HTTPS)

```bash
# 安裝 Certbot
sudo apt install certbot

# 取得 SSL 憑證
sudo certbot certonly --standalone -d your-domain.com

# 設定自動更新
echo "0 12 * * * /usr/bin/certbot renew --quiet" | sudo crontab -
```

### 自動更新設定

```bash
# 建立更新腳本
cat > update.sh << 'EOF'
#!/bin/bash
cd ~/minecraft-server

# 備份
./backup.sh

# 更新映像
docker-compose pull

# 重新部署
docker-compose up -d

echo "更新完成"
EOF

chmod +x update.sh

# 設定每週自動更新 (週日凌晨 3 點)
(crontab -l 2>/dev/null; echo "0 3 * * 0 /home/ubuntu/minecraft-server/update.sh") | crontab -
```

## 📊 成本分析

### 免費額度
- **運算**: VM.Standard.A1.Flex - 4 OCPU + 24GB RAM (永久免費)
- **儲存**: 100GB 區塊儲存 (永久免費)
- **流量**: 10TB 輸出流量/月 (永久免費)
- **IP**: 2 個公用 IP (永久免費)

### 超出免費額度的費用
- **額外儲存**: $0.0255/GB/月
- **額外流量**: $0.0085/GB
- **額外運算**: 依實例類型計費

### 成本控制
1. 設定預算警告
2. 監控使用量
3. 定期檢查計費報告
4. 使用資源標籤管理

## 🔍 故障排除

### 常見問題

#### 無法連線到實例
```bash
# 檢查安全群組規則
# 確認 22 (SSH) 和 25565 (Minecraft) 埠已開放

# 檢查實例狀態
oci compute instance get --instance-id YOUR_INSTANCE_ID

# 檢查防火牆 (Ubuntu)
sudo ufw status
sudo ufw allow 25565
```

#### 記憶體不足
```bash
# 檢查記憶體使用
free -h

# 調整 JVM 記憶體設定
# 在 docker-compose.yml 中減少 MEMORY 值
MEMORY: "16G"  # 從 20G 調整到 16G
```

#### 磁碟空間不足
```bash
# 檢查磁碟使用
df -h

# 清理 Docker
docker system prune -a

# 清理舊備份
find ~/minecraft-backups -name "*.tar.gz" -mtime +7 -delete
```

#### 伺服器無法啟動
```bash
# 查看詳細日誌
docker logs minecraft-server

# 檢查設定檔
docker exec -it minecraft-server cat /data/server.properties

# 重新建立容器
docker-compose down
docker-compose up -d
```

## 📞 支援資源

### 官方文件
- [Oracle Cloud 文件](https://docs.oracle.com/zh-tw/iaas/)
- [Minecraft Docker 映像](https://github.com/itzg/docker-minecraft-server)
- [Docker Compose 文件](https://docs.docker.com/compose/)

### 社群支援
- [Oracle Cloud 社群](https://community.oracle.com/)
- [Minecraft Server Discord](https://discord.gg/minecraft)
- [Reddit r/admincraft](https://reddit.com/r/admincraft)

### 緊急聯絡
- Oracle Cloud 技術支援 (付費用戶)
- 社群論壇求助
- GitHub Issues 報告

## 🎯 最佳實踐

1. **定期備份**：每日自動備份世界檔案
2. **監控資源**：定期檢查 CPU、記憶體、磁碟使用量
3. **更新維護**：定期更新系統和 Minecraft 版本
4. **安全設定**：使用強密碼、SSH 金鑰認證
5. **成本控制**：監控雲端使用量，避免超出免費額度
6. **文件記錄**：記錄所有設定和變更

---

*此指南提供完整的 Oracle Cloud Minecraft 伺服器部署流程，適合有一定技術基礎的用戶使用。*
