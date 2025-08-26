# Yu Minecraft 私服 (v1.21.8)

一個基於Docker的Minecraft私服專案，提供簡單易用的部署和管理方案。現已支援最新的 Minecraft 1.21.8 版本！

## ✨ 新版本特色

- 🆕 **完全支援 Minecraft 1.21.8**
- 🏗️ **新特性整合**：Crafter、Trial Chambers、Wind Charges 等
- ⚡ **效能最佳化**：針對 1.21.8 的專屬調優
- 🔌 **外掛相容性**：與最新外掛完美整合

📋 **詳細版本資訊**: 請參閱 [VERSION_1.21.8.md](./docs/VERSION_1.21.8.md)

## 📋 開發流程

詳細的開發流程和專案結構說明，請參考：[PROJECT_STRUCTURE.md](./docs/PROJECT_STRUCTURE.md)

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

### 遊戲指南

- 完整的遊戲設置和使用指南：[GAME_GUIDE.md](./docs/GAME_GUIDE.md)

### 外掛管理

- 外掛安裝、移除和管理說明：[PLUGIN_MANAGER_GUIDE.md](./docs/PLUGIN_MANAGER_GUIDE.md)

### 遠端連線設定

- **詳細設置指南**: [REMOTE_CONNECTION_GUIDE.md](./docs/REMOTE_CONNECTION_GUIDE.md)

## �📧 聯絡方式

如有問題或建議，請透過GitHub Issues聯絡。

## 📄 授權條款

MIT License
