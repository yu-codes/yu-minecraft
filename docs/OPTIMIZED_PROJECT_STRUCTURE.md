# Yu Minecraft Server 最佳化目錄結構說明 (v1.21.8)

本專案採用最佳化的目錄結構，明確區分**可遷移**和**平台特定**的檔案，支援在 Aternos 和自架伺服器之間靈活轉移。

## 📁 最佳化目錄結構

```text
yu-minecraft/
├── 📄 README.md                    # 專案說明文件
├── 📄 LICENSE                      # 授權條款
├── 📄 manage.sh                    # 整合管理介面
├── 📄 connection_info.txt          # 連線資訊記錄
│
├── 🔄 shared/                      # 跨平台共享資料 (可遷移)
│   ├── 🌍 game-data/               # 遊戲世界資料
│   │   ├── level.dat               # 世界基本資訊
│   │   ├── level.dat_old           # 世界資訊備份
│   │   ├── session.lock            # 存取鎖定檔
│   │   ├── region/                 # 世界區塊資料
│   │   ├── playerdata/             # 玩家資料 (庫存、位置、經驗)
│   │   ├── advancements/           # 玩家成就進度
│   │   ├── stats/                  # 玩家統計資料
│   │   ├── DIM-1/                  # 地獄維度
│   │   ├── DIM1/                   # 終界維度
│   │   ├── entities/               # 實體資料
│   │   ├── poi/                    # 興趣點資料
│   │   └── data/                   # 其他遊戲資料
│   │
│   ├── ⚙️ server-configs/          # 伺服器配置 (標準化)
│   │   ├── server.properties       # 主要伺服器設定
│   │   ├── spigot.yml              # Spigot 最佳化設定
│   │   ├── bukkit.yml              # Bukkit 核心設定
│   │   └── performance.yml         # 效能調校設定
│   │
│   └── 👥 player-management/       # 玩家管理資料
│       ├── whitelist.json          # 白名單玩家清單
│       ├── ops.json                # 管理員權限清單
│       └── banned-players.json     # 封禁玩家清單
│
├── 🏗️ platform-specific/           # 平台特定配置 (不可遷移)
│   ├── 🖥️ self-hosted/            # 自架伺服器專用
│   │   ├── server.properties       # 自架優化配置
│   │   ├── docker-compose.yml      # Docker 編排配置
│   │   ├── jvm-args.txt           # JVM 參數設定
│   │   └── network-config.yml      # 網路配置
│   │
│   └── ☁️ aternos/                # Aternos 平台專用
│       ├── upload-checklist.md     # 上傳檢查清單
│       ├── config-mapping.json     # 配置對應表
│       └── limitations.md          # 平台限制說明
│
├── 🚀 migration-tools/             # 遷移工具
│   ├── export-to-aternos.sh       # 匯出到 Aternos
│   ├── import-from-aternos.sh     # 從 Aternos 匯入
│   └── sync-shared-data.sh        # 同步共享資料
│
├── 🐳 docker/                      # Docker 配置 (自架專用)
│   ├── Dockerfile                  # Docker 映像檔配置
│   ├── docker-compose.yml          # 容器編排配置
│   └── docker-compose.yml.backup.* # 配置備份
│
├── ⚙️ config/                      # 當前使用配置 (符號連結或複本)
│   ├── server.properties           # → shared/server-configs/
│   ├── whitelist.json              # → shared/player-management/
│   ├── ops.json                    # → shared/player-management/
│   ├── spigot.yml                  # 自動生成
│   ├── bukkit.yml                  # 自動生成
│   ├── plugins.json                # 外掛配置記錄
│   ├── plugins_database.json       # 外掛資料庫
│   └── installed_plugins.json      # 已安裝外掛清單
│
├── 🔧 scripts/                     # 管理腳本 (自架專用)
│   ├── 🚀 start.sh                 # 啟動腳本
│   ├── 🛑 stop.sh                  # 停止腳本
│   ├── 💾 backup.sh                # 備份腳本
│   ├── 📊 monitor.sh               # 系統監控腳本
│   ├── ⚡ performance.sh           # 效能監控腳本
│   ├── 🔌 plugins.sh               # 外掛管理腳本
│   ├── ⚙️ optimize.sh              # 效能最佳化腳本
│   ├── 🔥 warmup.sh                # 預熱腳本
│   ├── 🔔 notify.sh                # 通知服務腳本
│   └── 🌐 remote-connect-*.sh      # 遠端連線腳本
│
├── 🌐 web/                         # Web 管理介面 (自架專用)
│   ├── index.html                  # 主頁面
│   ├── api.php                     # API 介面
│   ├── simple-api.py               # Python API
│   └── __pycache__/                # Python 快取
│
├── 🔌 plugins/                     # 伺服器外掛 (自架專用)
│   ├── EssentialsX.jar             # 基礎功能外掛
│   ├── Vault.jar                   # 經濟系統支援
│   └── (其他外掛 JAR 檔案)
│
├── 🌍 worlds/                      # 當前世界資料 (符號連結)
│   └── → shared/game-data/         # 指向共享遊戲資料
│
├── 📜 logs/                        # 記錄檔案 (自架專用)
│   ├── latest.log                  # 最新伺服器日誌
│   ├── optimization.log            # 最佳化記錄
│   ├── optimization_report_*.txt   # 最佳化報告
│   ├── import_report_*.txt         # 匯入報告
│   ├── 📁 performance/             # 效能記錄
│   │   ├── tps.log                 # TPS 記錄
│   │   ├── memory.log              # 記憶體使用記錄
│   │   └── players.log             # 玩家活動記錄
│   └── 📁 ngrok/                   # Ngrok 連線記錄
│       ├── monitor.out             # 監控輸出
│       ├── monitor.pid             # 程序 ID
│       └── traffic_*.log           # 流量記錄
│
├── 💾 backups/                     # 備份檔案
│   ├── minecraft_backup_*.tar.gz   # 完整備份
│   └── 📁 plugins/                 # 外掛備份
│
├── 🗂️ temp/                        # 臨時檔案
│   ├── 📁 aternos-export/          # Aternos 匯出暫存
│   ├── 📁 aternos-import/          # Aternos 匯入暫存
│   └── 📁 plugins/                 # 外掛下載暫存
│
├── ☁️ cloud-migration/             # 雲端遷移資源
│   ├── README.md                   # 雲端遷移說明
│   └── 📁 aternos/                 # Aternos 特定資源
│       ├── 📁 migration-profiles/  # 遷移配置檔
│       └── 📁 templates/           # 設定範本
│
└── 📚 docs/                        # 文件資料
    ├── README.md                   # 文件索引
    ├── PROJECT_STRUCTURE.md        # 專案結構說明 (本檔案)
    ├── ATERNOS_GUIDE.md            # Aternos 遷移指南
    ├── PLUGIN_MANAGER_GUIDE.md     # 外掛管理指南
    ├── REMOTE_CONNECTION_GUIDE.md  # 遠端連線指南
    └── (其他說明文件)
```

## 🎯 目錄分類說明

### 📂 可遷移檔案 (Portable Files) - `shared/`

這些檔案包含遊戲核心資料，可以在不同平台間轉移：

#### 🌍 `shared/game-data/` - 遊戲世界資料

- **內容**: 完整的 Minecraft 世界檔案
- **包含**: 地形、建築、玩家資料、成就、統計等
- **遷移**: 可直接壓縮上傳到 Aternos 或其他平台
- **重要性**: ⭐⭐⭐⭐⭐ (最重要的遊戲資料)

#### ⚙️ `shared/server-configs/` - 標準伺服器配置

- **內容**: 跨平台相容的伺服器設定
- **包含**: 遊戲模式、難度、玩家上限等基本設定
- **遷移**: 需要根據平台特性調整部分參數
- **重要性**: ⭐⭐⭐⭐ (影響遊戲體驗)

#### 👥 `shared/player-management/` - 玩家管理資料

- **內容**: 玩家權限和管理設定
- **包含**: 白名單、管理員清單、封禁清單
- **遷移**: 可直接遷移，但需手動在目標平台設定
- **重要性**: ⭐⭐⭐ (安全性相關)

### 📂 不可遷移檔案 (Platform-Specific Files)

這些檔案針對特定平台最佳化，無法直接遷移：

#### 🖥️ `platform-specific/self-hosted/` - 自架伺服器專用

- **Docker 配置**: 容器化部署設定
- **JVM 參數**: 記憶體和效能調校
- **網路配置**: 端口轉發和防火牆設定
- **監控腳本**: 自動化管理和監控

#### ☁️ `platform-specific/aternos/` - Aternos 平台專用

- **上傳指南**: 檔案上傳和設定步驟
- **限制說明**: 平台限制和解決方案
- **配置對應**: 設定參數轉換對照

#### 🔧 `scripts/` - 自架專用管理腳本

- **自動化工具**: 啟動、停止、備份、監控
- **外掛管理**: 安裝、更新、配置外掛
- **效能最佳化**: 自動調校和監控

#### 🐳 `docker/` - 容器化配置

- **Docker 映像**: 自訂 Minecraft 伺服器映像
- **編排配置**: 多容器服務管理
- **持久化儲存**: 資料卷和備份策略

## 🔄 遷移工作流程

### 📤 從自架伺服器到 Aternos

```bash
# 1. 匯出資料
./migration-tools/export-to-aternos.sh

# 2. 檢查匯出檔案
ls temp/aternos-export/

# 3. 依照指南上傳到 Aternos
cat temp/aternos-export/ATERNOS_MIGRATION_GUIDE.txt
```

**匯出內容**:

- ✅ 完整世界資料 (`world_*.tar.gz`)
- ✅ 伺服器配置檔 (`server.properties`)
- ✅ 玩家管理檔 (`whitelist.json`, `ops.json`)
- ✅ 外掛清單 (`plugins_list.txt`)
- ✅ 遷移指南 (`ATERNOS_MIGRATION_GUIDE.txt`)

### 📥 從 Aternos 到自架伺服器

```bash
# 1. 下載 Aternos 資料到 temp/aternos-import/

# 2. 執行匯入
./migration-tools/import-from-aternos.sh

# 3. 啟動伺服器測試
./scripts/start.sh
```

**匯入內容**:

- ✅ 自動解壓世界檔案到 `shared/game-data/`
- ✅ 互動式配置伺服器設定
- ✅ 恢復玩家管理設定
- ✅ 提示安裝相同外掛
- ✅ 生成匯入報告

### 🔄 同步共享資料

```bash
# 同步所有平台配置
./migration-tools/sync-shared-data.sh all both

# 僅同步自架配置到共享目錄
./migration-tools/sync-shared-data.sh self-hosted to-shared

# 僅從共享目錄套用到 Aternos 配置
./migration-tools/sync-shared-data.sh aternos from-shared
```

## 🛡️ 資料安全與備份策略

### 📊 備份優先級

| 優先級 | 目錄 | 內容 | 備份頻率 | 備份方式 |
|--------|------|------|----------|----------|
| 🔴 極高 | `shared/game-data/` | 世界檔案 | 每日 | 完整備份 + 增量 |
| 🟡 高 | `shared/player-management/` | 玩家資料 | 每週 | 完整備份 |
| 🟢 中 | `shared/server-configs/` | 伺服器配置 | 變更時 | 版本控制 |
| 🔵 低 | `platform-specific/` | 平台配置 | 月度 | 快照備份 |

### 🔄 自動備份腳本

```bash
# 設定自動備份
./scripts/backup.sh setup

# 手動執行完整備份
./scripts/backup.sh full

# 僅備份共享資料
./scripts/backup.sh shared-only
```

## 🎮 使用場景範例

### 場景 1: 日常自架伺服器使用

```bash
# 啟動伺服器
./scripts/start.sh

# 監控效能
./scripts/monitor.sh

# 安裝外掛
./scripts/plugins.sh install EssentialsX

# 每日備份
./scripts/backup.sh daily
```

### 場景 2: 臨時轉移到 Aternos

```bash
# 匯出到 Aternos
./migration-tools/export-to-aternos.sh

# 上傳到 Aternos (手動)
# 依照 temp/aternos-export/ATERNOS_MIGRATION_GUIDE.txt

# 停止本地伺服器
./scripts/stop.sh
```

### 場景 3: 從 Aternos 恢復

```bash
# 下載 Aternos 資料 (手動)
# 放入 temp/aternos-import/

# 匯入資料
./migration-tools/import-from-aternos.sh

# 啟動本地伺服器
./scripts/start.sh

# 驗證功能
./scripts/plugins.sh status
```

### 場景 4: 定期同步配置

```bash
# 每週同步共享配置
./migration-tools/sync-shared-data.sh all both

# 備份重要資料
./scripts/backup.sh shared-only

# 效能最佳化
./scripts/optimize.sh all
```

## 🔧 進階配置

### 符號連結設定

為了保持向後相容性，建議建立符號連結：

```bash
# 連結世界目錄
ln -sf shared/game-data worlds

# 連結配置檔案
ln -sf shared/server-configs/server.properties config/server.properties
ln -sf shared/player-management/whitelist.json config/whitelist.json
ln -sf shared/player-management/ops.json config/ops.json
```

### 環境變數配置

在 `.env` 檔案中設定：

```env
# 平台配置
MINECRAFT_PLATFORM=self-hosted  # or aternos
SHARED_DATA_PATH=./shared
PLATFORM_CONFIG_PATH=./platform-specific/self-hosted

# 備份配置
BACKUP_SHARED_ONLY=false
BACKUP_FREQUENCY=daily
BACKUP_RETENTION_DAYS=30

# 同步配置
AUTO_SYNC_SHARED=true
SYNC_ON_START=true
SYNC_ON_STOP=true
```

## 📋 檢查清單

### 🔄 遷移前檢查

- [ ] 執行完整備份
- [ ] 驗證世界檔案完整性
- [ ] 記錄當前外掛清單
- [ ] 確認玩家資料保存
- [ ] 測試配置檔案語法

### ✅ 遷移後驗證

- [ ] 世界正確載入
- [ ] 玩家資料完整
- [ ] 管理員權限正常
- [ ] 外掛功能運作
- [ ] 網路連線正常

### 🛠️ 故障排除

- [ ] 檢查錯誤日誌
- [ ] 驗證檔案權限
- [ ] 確認網路設定
- [ ] 測試外掛相容性
- [ ] 聯繫技術支援

## 🔗 相關資源

- [Aternos 遷移詳細指南](./ATERNOS_GUIDE.md)
- [外掛管理指南](./PLUGIN_MANAGER_GUIDE.md)
- [遠端連線設定](./REMOTE_CONNECTION_GUIDE.md)
- [效能最佳化指南](./OPTIMIZATION_GUIDE.md)

---

這個最佳化的目錄結構讓您能夠：

1. **輕鬆遷移** - 明確區分可遷移和平台特定檔案
2. **保持同步** - 共享資料目錄確保一致性
3. **自動化管理** - 專用工具腳本簡化操作
4. **安全備份** - 分層備份策略保護重要資料
5. **靈活部署** - 支援多種部署方案和平台

無論您選擇自架伺服器還是 Aternos 託管，都能享受流暢的 Minecraft 體驗！
