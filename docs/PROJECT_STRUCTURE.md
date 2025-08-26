# Yu Minecraft Server 專案結構說明 (v1.21.8)

本專案現已完全支援 Minecraft 1.21.8 版本，包含所有新特性和最佳化設定。

## 📁 完整專案結構

```
yu-minecraft/
├── 📄 README.md                    # 專案說明文件
├── 📄 LICENSE                      # 授權條款
├── 📄 .env                         # 環境配置檔案
├── 📄 .gitignore                   # Git忽略檔案
├── 🚀 deploy.sh                    # 快速部署腳本
├── 🎛️ manage.sh                     # 整合管理介面
│
├── 🐳 docker/                      # Docker配置
│   ├── 📄 Dockerfile               # Docker映像檔配置
│   └── 📄 docker-compose.yml       # 容器編排配置
│
├── ⚙️ config/                      # 伺服器配置
│   ├── 📄 server.properties        # 伺服器主配置
│   ├── 📄 whitelist.json          # 白名單設定
│   ├── 📄 ops.json                # 管理員設定
│   ├── 📄 plugins.json            # 外掛配置
│   ├── 📄 spigot.yml              # Spigot配置 (由最佳化腳本生成)
│   └── 📄 bukkit.yml              # Bukkit配置 (由最佳化腳本生成)
│
├── 🔧 scripts/                     # 管理腳本
│   ├── 🚀 start.sh                 # 啟動腳本
│   ├── 🛑 stop.sh                  # 停止腳本
│   ├── 💾 backup.sh                # 備份腳本
│   ├── 📊 monitor.sh               # 系統監控腳本
│   ├── ⚡ performance.sh           # 效能監控腳本
│   ├── 🔌 plugins.sh               # 外掛管理腳本
│   ├── ⚙️ optimize.sh              # 效能最佳化腳本
│   └── 🔥 warmup.sh                # 預熱腳本 (由最佳化腳本生成)
│
├── 🌐 web/                         # Web管理介面
│   ├── 📄 index.html               # 主頁面
│   └── 📁 assets/                  # 靜態資源
│
├── 🔌 plugins/                     # 伺服器外掛
│   └── (外掛JAR檔案)
│
├── 🌍 worlds/                      # 遊戲世界資料
│   └── (世界檔案)
│
├── 📜 logs/                        # 記錄檔案
│   ├── 📁 performance/             # 效能記錄
│   │   ├── 📄 tps.log
│   │   ├── 📄 memory.log
│   │   └── 📄 players.log
│   ├── 📄 optimization.log         # 最佳化記錄
│   └── 📄 optimization_report_*.txt # 最佳化報告
│
├── 💾 backups/                     # 備份檔案
│   ├── 📁 plugins/                 # 外掛備份
│   └── 📄 minecraft_backup_*.tar.gz # 世界備份
│
└── 📊 exports/                     # 匯出資料
    └── 📄 performance_*.csv        # 效能資料匯出
```

## 🎯 核心功能模組

### 1. 🚀 部署模組
- **deploy.sh**: 一鍵部署腳本
- **docker/**: Docker容器化配置
- **start.sh/stop.sh**: 基本啟停控制

### 2. 📊 監控模組
- **monitor.sh**: 系統資源監控
- **performance.sh**: 伺服器效能監控
- **Web面板**: 即時狀態顯示

### 3. 🔌 外掛模組
- **plugins.sh**: 外掛管理腳本
- **plugins.json**: 外掛配置檔案
- **自動依賴檢查**: 確保外掛相容性

### 4. ⚡ 最佳化模組
- **optimize.sh**: 自動效能調優
- **JVM參數調整**: 記憶體和垃圾回收最佳化
- **伺服器配置最佳化**: Spigot/Bukkit參數調整

### 5. 💾 備份模組
- **backup.sh**: 自動化備份
- **版本控制**: 保留多個備份版本
- **增量備份**: 節省存儲空間

### 6. 🎛️ 管理模組
- **manage.sh**: 整合管理介面
- **Web控制台**: 網頁版管理介面
- **腳本自動化**: 一鍵操作所有功能

## 🔄 工作流程

### 首次部署
```bash
1. ./deploy.sh                  # 快速部署
2. ./scripts/plugins.sh init    # 初始化外掛系統
3. ./scripts/optimize.sh all    # 執行效能最佳化
```

### 日常管理
```bash
1. ./manage.sh                  # 開啟管理介面
2. 選擇所需功能進行操作
```

### 效能監控
```bash
1. ./scripts/monitor.sh continuous    # 連續監控
2. ./scripts/performance.sh report   # 檢視效能報告
```

### 外掛管理
```bash
1. ./scripts/plugins.sh recommended  # 查看推薦外掛
2. ./scripts/plugins.sh essentials   # 安裝基本套件
```

## 📈 進階功能

### 自動化任務
- 定期備份
- 效能監控
- 資源清理
- 外掛更新檢查

### 集成監控
- 系統資源監控
- 遊戲效能監控
- 玩家活動追蹤
- 錯誤日誌分析

### 最佳化引擎
- JVM參數自動調整
- 遊戲配置最佳化
- 資料庫效能調優
- 網路參數優化

### 擴展性設計
- 模組化架構
- 外掛熱插拔
- 配置熱更新
- API接口預留

這個專案結構提供了完整的Minecraft私服管理解決方案，從基礎的啟停控制到高級的效能最佳化，滿足各種使用需求。
