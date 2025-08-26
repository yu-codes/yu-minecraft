# Yu Minecraft 外掛管理系統使用說明

## 功能說明

這個外掛管理系統提供了完整的Minecraft伺服器外掛管理功能，包括：

### 基本功能
- ✅ 列出已安裝外掛
- ✅ 瀏覽可用外掛
- ✅ 安裝新外掛
- ✅ 移除外掛（含自動備份）
- ✅ 顯示使用說明

## 使用方式

```bash
# 進入專案目錄
cd /Users/yuhan/Side-Project/yu-minecraft

# 1. 列出已安裝外掛
bash scripts/plugins.sh list

# 2. 瀏覽可用外掛
bash scripts/plugins.sh browse

# 3. 安裝外掛
bash scripts/plugins.sh install <外掛名稱>

# 4. 移除外掛
bash scripts/plugins.sh remove <外掛名稱>

# 5. 顯示說明
bash scripts/plugins.sh help
```

## 支援的外掛

| 外掛名稱 | 描述 | 狀態 |
|---------|------|------|
| EssentialsX | 基礎伺服器指令套件 | ✅ 已安裝 |
| Vault | 經濟系統API | ✅ 已安裝 |
| LuckPerms | 權限管理系統 | 📦 可安裝 |
| ProtocolLib | 協議庫 | 📦 可安裝 |
| ChestShop | 商店系統 | 📦 可安裝 |

## 使用範例

### 安裝權限管理外掛
```bash
bash scripts/plugins.sh install LuckPerms
```

### 移除不需要的外掛
```bash
bash scripts/plugins.sh remove Vault
```

### 檢查當前安裝狀態
```bash
bash scripts/plugins.sh list
```

## 安全特性

- **自動備份**: 移除外掛前會自動備份到 `backups/plugins/` 目錄
- **重複安裝保護**: 防止重複安裝相同外掛
- **錯誤檢查**: 完整的錯誤處理和提示訊息

## 檔案結構

```
yu-minecraft/
├── plugins/                 # 外掛目錄
│   ├── EssentialsX.jar     # 已安裝外掛
│   └── Vault.jar           # 已安裝外掛
├── backups/
│   └── plugins/            # 外掛備份目錄
└── scripts/
    └── plugins.sh          # 外掛管理腳本
```

## 故障排除

如果遇到問題，請檢查：

1. **網路連線**: 安裝外掛需要網路下載
2. **權限**: 確保腳本有執行權限 `chmod +x scripts/plugins.sh`
3. **目錄**: 確保在正確的專案目錄中執行
4. **語法**: 使用 `bash -n scripts/plugins.sh` 檢查腳本語法

## 開發資訊

- **版本**: v1.0
- **語言**: Bash
- **相容性**: macOS, Linux
- **依賴**: curl (用於下載外掛)
