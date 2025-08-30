# Yu Minecraft 私服 (v1.21.8)

基於 Docker 的 Minecraft 1.21.8 私服專案，支援雲端和本地部署。

## ✨ 主要特色

- 🎮 **最新版本**：完全支援 Minecraft 1.21.8
- 🐳 **Docker 部署**：跨平台，一鍵啟動
- ☁️ **雲端方案**：支援 Oracle Cloud、AWS 等多種部署方式
- 🔧 **自動化管理**：備份、監控、優化腳本
- 🔌 **外掛整合**：預設推薦外掛配置

## 📋 目錄

- [快速開始](#-快速開始)
- [伺服器管理](#-伺服器管理)
- [Aternos 世界轉移](#-aternos-世界轉移)
- [功能概覽](#-功能概覽)
- [詳細文件](#-詳細文件)

## 🚀 快速開始

### 系統要求

- Docker 20.0+ 和 Docker Compose 2.0+
- 至少 4GB RAM，100GB 磁碟空間
- 雲端帳號（推薦 Oracle Cloud 免費方案）或本地環境

### 一鍵部署

```bash
# 1. 複製專案
git clone https://github.com/yu-codes/yu-minecraft.git
cd yu-minecraft

# 2. 執行部署助手
./scripts/deploy.sh

# 3. 選擇部署方式並等待完成
# 系統會自動配置並顯示連線資訊
```

部署完成後，使用顯示的伺服器地址連接到 Minecraft 即可開始遊戲。

### 管理工具

```bash
# 整合管理腳本
./manage.sh

# Web 管理介面 (Portainer)
# 訪問：http://YOUR_SERVER_IP:9000
```

### 雲端伺服器管理

```bash
# SSH 連線到雲端實例（Oracle Cloud/AWS）
ssh -i ~/.ssh/your-key ubuntu@YOUR_SERVER_IP

# 進入專案目錄
cd ~/minecraft-server

# 查看系統資源
htop              # CPU 和記憶體
df -h             # 磁碟使用
docker stats      # 容器資源
```

### 自動化腳本

```bash
./scripts/backup.sh      # 備份管理
./scripts/performance.sh # 效能監控
./scripts/optimize.sh    # 系統優化
```

## 🔄 Aternos 世界轉移

### 世界管理系統

本專案支援多世界管理，所有世界（本地和 Aternos）都存放在 `worlds/` 目錄下：

```bash
# 查看所有可用世界
./world-manager.sh list

# 查看當前狀態
./world-manager.sh status
```

### 從 Aternos 匯入世界

```bash
# 1. 從 Aternos 下載世界檔案到專案根目錄
# 2. 匯入世界
./world-manager.sh import world.zip my-aternos-world

# 3. 切換到匯入的世界
./world-manager.sh select my-aternos-world

# 4. 啟動伺服器
docker-compose up -d
```

### 切換世界

```bash
# 列出所有世界並選擇
./world-manager.sh select

# 直接切換到指定世界
./world-manager.sh select world-name
```

### 從本地匯出到 Aternos

```bash
# 1. 確保要匯出的世界為當前世界
./world-manager.sh select my-world

# 2. 壓縮當前世界
cd worlds/current
zip -r ../../my-world-export.zip *

# 3. 在 Aternos 控制面板上傳 my-world-export.zip
```

所有世界都使用相同的 Docker 部署方式，透過符號連結切換，簡單高效。

## 📚 詳細文件

### 部署指南

- [Oracle Cloud 部署](./docs/ORACLE_CLOUD_GUIDE.md) - 免費雲端部署詳細教學
- [遠端連線方案](./docs/REMOTE_CONNECTION_GUIDE.md) - 所有部署方案比較
- [AWS 部署指南](./docs/AWS_DEPLOYMENT_GUIDE.md) - AWS EC2 部署教學

### 功能說明

- [遊戲設置指南](./docs/GAME_GUIDE.md) - 遊戲配置和玩家管理
- [外掛管理指南](./docs/PLUGIN_MANAGER_GUIDE.md) - 外掛安裝和管理
- [通知設置指南](./docs/NOTIFICATION_SETUP_GUIDE.md) - 自動通知配置

### 進階功能

- [Ngrok 設置指南](./docs/NGROK_SETUP_GUIDE.md) - 臨時公網連線
- [專案結構說明](./docs/PROJECT_STRUCTURE.md) - 開發和自訂指南
- [版本更新日誌](./docs/VERSION_1.21.8.md) - 1.21.8 新特性

---

## 支援與貢獻

- **問題回報**: [GitHub Issues](https://github.com/yu-codes/yu-minecraft/issues)
- **技術文件**: [docs/](./docs/)
- **討論區**: [GitHub Discussions](https://github.com/yu-codes/yu-minecraft/discussions)

**License**: MIT | **Version**: 1.21.8 | **Author**: [yu-codes](https://github.com/yu-codes)
