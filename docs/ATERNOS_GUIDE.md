# Aternos 免費 Minecraft 伺服器部署指南

## 目錄
- [什麼是 Aternos](#什麼是-aternos)
- [註冊與基本設置](#註冊與基本設置)
- [伺服器配置](#伺服器配置)
- [從本地專案手動轉移到 Aternos](#從本地專案手動轉移到-aternos)
- [從 Aternos 手動轉移回本地](#從-aternos-手動轉移回本地)
- [邀請朋友連線到伺服器](#邀請朋友連線到伺服器)
- [管理與維護](#管理與維護)
- [常見問題與解決方案](#常見問題與解決方案)

## 什麼是 Aternos

Aternos 是一個免費的 Minecraft 伺服器託管平台，提供：

- 完全免費的伺服器託管
- 支援多種 Minecraft 版本
- 外掛支援（Bukkit/Spigot/Paper）
- 自動備份功能
- 簡單的 Web 管理介面
- 無需信用卡註冊

**優點：**
- 完全免費
- 易於使用
- 支援外掛
- 自動管理

**限制：**
- 伺服器會在無人時自動停止
- 啟動佇列（高峰時段可能需要等待）
- 有限的效能資源
- 不支援某些進階外掛

## 註冊與基本設置

### 1. 註冊帳戶

1. 造訪 [aternos.org](https://aternos.org)
2. 點擊 "Register" 註冊=
3. 填寫使用者名稱、電子郵件和密碼
4. 驗證電子郵件地址
5. 登入您的帳戶

### 2. 建立伺服器

1. 登入後點擊 "Create Server"
2. 選擇伺服器名稱（建議使用與本專案相同的名稱）
3. 選擇 Minecraft 版本（推薦使用與本專案相同的版本）
4. 選擇伺服器類型：
   - **Vanilla**: 原版 Minecraft
   - **Bukkit**: 支援外掛（推薦）
   - **Spigot**: 最佳化版 Bukkit（推薦）
   - **Paper**: 高效能 Spigot 分支（推薦）
   - **Forge**: 模組支援

### 3. 基本配置

伺服器建立後：
1. 進入伺服器控制面板
2. 配置基本設定：
   - 遊戲模式（生存/創造/冒險/觀察）
   - 難度設定
   - 世界設定
   - 玩家限制

## 伺服器配置

### 1. 伺服器屬性設定

在 Aternos 控制面板中配置以下重要設定：

```properties
# 基本設定
server-name=YuMinecraft
gamemode=survival
difficulty=normal
max-players=20
online-mode=true
enable-whitelist=false

# 世界設定
level-name=world
generate-structures=true
spawn-animals=true
spawn-monsters=true

# 效能設定
view-distance=10
simulation-distance=10
```

### 2. 外掛配置

如果選擇支援外掛的伺服器類型（Bukkit/Spigot/Paper）：

1. 在控制面板中選擇 "Plugins"
2. 搜尋並安裝推薦外掛：
   - **EssentialsX**: 基礎指令與功能
   - **Vault**: 經濟系統支援
   - **WorldGuard**: 區域保護
   - **LuckPerms**: 權限管理

### 3. 白名單設定

1. 在控制面板選擇 "Whitelist"
2. 新增允許加入的玩家使用者名稱
3. 啟用白名單模式以增強安全性

## 從本地專案手動轉移到 Aternos

### 1. 需要轉移的檔案清單

#### 核心遊戲檔案

- **worlds/** - 遊戲世界檔案
  - `level.dat` - 世界基本資訊（出生點、遊戲規則等）
  - `level.dat_old` - 世界資訊備份
  - `session.lock` - 防止多重存取的鎖定檔
  - `region/` - 世界區塊資料
  - `playerdata/` - 玩家資料（庫存、位置、經驗等）
  - `advancements/` - 玩家成就進度
  - `stats/` - 玩家統計資料
  - `DIM-1/`, `DIM1/` - 地獄與終界維度

#### 配置檔案

- **config/server.properties** - 伺服器主要設定
  - 遊戲模式、難度、玩家上限
  - 世界生成設定、視距
  - PvP、白名單等遊戲規則
- **config/whitelist.json** - 白名單玩家清單
- **config/ops.json** - 管理員權限清單
- **config/bukkit.yml** - Bukkit 核心設定
- **config/spigot.yml** - Spigot 效能最佳化設定

#### 外掛相關檔案

- **plugins/*.jar** - 外掛檔案
  - `EssentialsX.jar` - 基礎指令與功能
  - `Vault.jar` - 經濟系統支援
- **config/plugins.json** - 外掛安裝記錄
- **config/plugins_database.json** - 外掛資料庫

### 2. 手動轉移步驟

#### 步驟 1: 準備本地檔案

1. **建立轉移目錄**：

   ```bash
   mkdir -p temp/aternos-migration
   ```

2. **壓縮世界檔案**：

   ```bash
   cd worlds
   tar -czf ../temp/aternos-migration/world.tar.gz *
   cd ..
   ```

3. **複製重要配置檔案**：

   ```bash
   cp config/server.properties temp/aternos-migration/
   cp config/whitelist.json temp/aternos-migration/ 2>/dev/null || echo "whitelist.json 不存在"
   cp config/ops.json temp/aternos-migration/ 2>/dev/null || echo "ops.json 不存在"
   ```

4. **記錄外掛清單**：

   ```bash
   ls plugins/*.jar > temp/aternos-migration/plugins_list.txt 2>/dev/null || echo "沒有外掛檔案"
   ```

#### 步驟 2: 上傳世界檔案到 Aternos

1. **在 Aternos 控制面板**：
   - 選擇 "Worlds" 頁面
   - 點擊 "Upload World"
   - 上傳 `temp/aternos-migration/world.tar.gz`
   - 等待上傳完成並解壓

2. **設定為活躍世界**：
   - 在世界清單中選擇剛上傳的世界
   - 點擊 "Activate" 設定為當前使用的世界

#### 步驟 3: 手動配置伺服器設定

根據 `temp/aternos-migration/server.properties` 的內容，在 Aternos 控制面板中手動配置：

1. **基本設定**：
   - 遊戲模式 (gamemode)
   - 難度 (difficulty)
   - 最大玩家數 (max-players)
   - 正版驗證 (online-mode)

2. **世界設定**：
   - 世界名稱 (level-name)
   - 生成結構 (generate-structures)
   - 生物生成設定

3. **效能設定**：
   - 視距 (view-distance)
   - 模擬距離 (simulation-distance)

#### 步驟 4: 設定玩家管理

1. **設定白名單**：
   - 在 Aternos 控制面板選擇 "Players" > "Whitelist"
   - 根據 `whitelist.json` 逐一新增玩家
   - 如需要，啟用白名單模式

2. **設定管理員**：
   - 在 "Players" > "Operators" 頁面
   - 根據 `ops.json` 新增管理員帳戶
   - 設定適當的權限等級

#### 步驟 5: 安裝外掛

根據 `plugins_list.txt` 的內容安裝外掛：

1. **在 Aternos 控制面板**：
   - 選擇 "Plugins" 頁面
   - 搜尋所需的外掛名稱
   - 點擊 "Install" 安裝外掛

2. **常用外掛安裝**：
   - EssentialsX：基礎指令與功能
   - Vault：經濟系統支援
   - WorldGuard：區域保護
   - LuckPerms：權限管理

#### 步驟 6: 測試伺服器

1. **啟動伺服器**：
   - 在 Aternos 控制面板點擊 "Start"
   - 等待伺服器啟動完成

2. **連線測試**：
   - 使用 Minecraft 客戶端
   - 連線到 Aternos 提供的伺服器地址
   - 檢查世界是否正確載入

3. **功能驗證**：
   - 測試外掛功能是否正常
   - 確認玩家權限設定
   - 檢查世界資料完整性

## 從 Aternos 手動轉移回本地

### 1. 需要下載的檔案清單

#### 從 Aternos 下載的檔案及其功能

- **世界檔案 (world.zip)**
  - 包含完整的遊戲世界資料
  - 玩家建築、地形、生物等所有遊戲內容
  - 玩家個人資料（庫存、位置、經驗）

- **伺服器設定記錄**
  - 遊戲模式、難度設定
  - 玩家上限、PvP 設定
  - 世界生成規則

- **玩家管理資料**
  - 白名單清單
  - 管理員清單
  - 封禁清單

- **外掛資料記錄**
  - 已安裝的外掛清單
  - 外掛配置檔案
  - 外掛資料庫

### 2. 手動轉移步驟

#### 步驟 1: 從 Aternos 下載檔案

1. **下載世界檔案**：
   - 在 Aternos 控制面板選擇 "Worlds"
   - 點擊 "Download" 下載當前世界
   - 檔案通常為 `world.zip` 格式

2. **記錄重要設定**：
   - 截圖或記錄 "Settings" 頁面的所有設定
   - 記錄 "Players" > "Whitelist" 中的玩家清單
   - 記錄 "Players" > "Operators" 中的管理員清單
   - 記錄 "Plugins" 頁面中已安裝的外掛清單

#### 步驟 2: 準備本地環境

```bash
# 檢查專案結構
ls -la

# 確認必要目錄存在
mkdir -p worlds config plugins backups
```

#### 步驟 3: 備份現有資料

```bash
# 備份當前世界（如果存在）
if [ -d "worlds" ]; then
    mv worlds worlds_backup_$(date +%Y%m%d_%H%M%S)
    echo "已備份現有世界"
fi

# 備份當前配置
cp config/server.properties config/server.properties.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || echo "無現有配置檔"
```

#### 步驟 4: 恢復世界檔案

```bash
# 建立新的世界目錄
mkdir -p worlds

# 解壓 Aternos 下載的世界檔案
cd worlds
unzip ../downloaded_world.zip  # 或 tar -xzf ../downloaded_world.tar.gz
cd ..

# 檢查世界檔案完整性
ls -la worlds/
echo "確認包含 level.dat 和 region 目錄"
```

#### 步驟 5: 手動更新配置檔案

根據 Aternos 的設定手動編輯本地配置：

```bash
# 編輯伺服器配置
nano config/server.properties
```

重要設定項目：

- `server-name=你的伺服器名稱`
- `gamemode=遊戲模式`
- `difficulty=難度`
- `max-players=玩家上限`
- `online-mode=是否驗證正版`
- `enable-whitelist=是否啟用白名單`

#### 步驟 6: 恢復外掛

```bash
# 手動下載並安裝外掛到 plugins 目錄
# 根據 Aternos 上的外掛清單安裝相同外掛

# 使用專案的外掛管理腳本（如果需要）
./scripts/plugins.sh install EssentialsX
./scripts/plugins.sh install Vault
```

#### 步驟 7: 恢復玩家管理設定

手動編輯白名單和管理員設定：

```bash
# 編輯白名單
nano config/whitelist.json

# 編輯管理員清單  
nano config/ops.json
```

#### 步驟 8: 啟動本地伺服器

```bash
# 啟動伺服器
./scripts/start.sh

# 或使用 Docker
docker-compose up -d
```

### 3. 驗證轉移結果

#### 檢查清單

1. **世界資料**：
   - 玩家建築是否完整
   - 玩家庫存和位置是否正確
   - 遊戲進度和成就是否保留

2. **伺服器設定**：
   - 遊戲模式和難度是否正確
   - 白名單和管理員權限是否生效
   - PvP 和其他遊戲規則是否符合預期

3. **外掛功能**：
   - 所有外掛是否正常載入
   - 外掛指令是否可用
   - 外掛資料是否保留

#### 測試步驟

```bash
# 檢查伺服器日誌
tail -f logs/latest.log

# 測試玩家連線
# 使用 Minecraft 客戶端連接 localhost:25565

# 檢查外掛狀態
# 在遊戲中執行 /plugins 指令
```

## 邀請朋友連線到伺服器

### 1. Aternos 伺服器連線

#### 取得伺服器地址

1. **在 Aternos 控制面板**：
   - 確保伺服器已啟動
   - 在主頁面可以看到伺服器地址
   - 格式通常為：`你的伺服器名稱.aternos.me`

2. **分享連線資訊**：
   - 伺服器地址：`你的伺服器名稱.aternos.me`
   - 連接埠：`25565`（預設）
   - 版本：確保朋友使用相同的 Minecraft 版本

#### 連線步驟（給朋友的說明）

1. **開啟 Minecraft**
2. **選擇 "多人遊戲"**
3. **點擊 "新增伺服器"**
4. **填入連線資訊**：
   - 伺服器名稱：自訂名稱
   - 伺服器地址：`你的伺服器名稱.aternos.me`
5. **點擊 "完成" 並連線**

### 2. 本地伺服器連線

#### 區域網路連線

如果朋友在同一個網路環境：

1. **取得本機 IP**：
   ```bash
   # macOS/Linux
   ifconfig | grep "inet " | grep -v 127.0.0.1
   
   # 或使用
   ipconfig getifaddr en0
   ```

2. **分享連線資訊**：
   - 伺服器地址：`你的內網IP`（例如：192.168.1.100）
   - 連接埠：`25565`

#### 網際網路連線

如果朋友不在同一網路，需要設定端口轉發或使用隧道工具：

1. **使用 ngrok**（推薦）：
   ```bash
   # 安裝並設定 ngrok
   ./scripts/remote-connect-ngrok.sh
   
   # 取得公開地址
   # 例如：abc123.ngrok.io
   ```

2. **使用路由器端口轉發**：
   - 登入路由器管理介面
   - 設定端口轉發：內部 IP:25565 → 外部 25565
   - 分享公網 IP 給朋友

3. **使用其他隧道服務**：
   ```bash
   # Playit.gg
   ./scripts/remote-connect-playit.sh
   
   # Serveo
   ./scripts/remote-connect-serveo.sh
   ```

### 3. 伺服器管理與安全

#### 白名單設定

建議啟用白名單增強安全性：

**Aternos**：
1. 控制面板 > Players > Whitelist
2. 新增朋友的遊戲 ID
3. 啟用白名單模式

**本地伺服器**：
```bash
# 編輯白名單檔案
nano config/whitelist.json

# 或使用遊戲內指令
/whitelist add 玩家名稱
/whitelist on
```

#### 管理員權限

設定信任的朋友為管理員：

**Aternos**：
1. 控制面板 > Players > Operators
2. 新增管理員帳戶

**本地伺服器**：
```bash
# 使用遊戲內指令
/op 玩家名稱
```

#### 連線通知

使用專案的通知功能自動分享連線資訊：

```bash
# 設定自動通知
./scripts/notify.sh setup

# 啟動伺服器時自動發送連線資訊
./scripts/start.sh
```

支援的通知方式：
- Discord Webhook
- Telegram Bot
- LINE Notify
- 電子郵件

### 4. 連線問題排除

#### 常見問題

1. **無法連線到 Aternos 伺服器**：
   - 確認伺服器已啟動
   - 檢查 Minecraft 版本是否相符
   - 確認網路連線正常

2. **本地伺服器連線失敗**：
   - 檢查防火牆設定
   - 確認端口 25565 未被占用
   - 驗證 IP 地址正確性

3. **白名單問題**：
   - 確認玩家名稱拼寫正確
   - 檢查白名單是否已啟用
   - 重新啟動伺服器

4. **版本不相容**：
   - 確保所有玩家使用相同版本
   - 檢查外掛相容性
   - 查看伺服器錯誤日誌

#### 測試連線

```bash
# 檢查端口是否開放
telnet 你的伺服器地址 25565

# 檢查伺服器狀態
./scripts/monitor.sh

# 查看連線日誌
tail -f logs/latest.log | grep "joined\|left"
```

## 管理與維護

### 1. 日常管理

- **啟動伺服器**: 在 Aternos 控制面板點擊 "Start"
- **停止伺服器**: 伺服器會在無人時自動停止
- **查看日誌**: 在控制面板查看伺服器日誌
- **管理玩家**: 使用白名單和封禁功能

### 2. 備份策略

1. **定期下載世界檔案**
2. **保存重要配置**
3. **記錄外掛清單和版本**

### 3. 效能最佳化

由於 Aternos 的資源限制，建議：

- 限制同時線上玩家數量
- 使用輕量級外掛
- 定期清理不需要的世界區域
- 最佳化伺服器設定

## 常見問題與解決方案

### Q: 伺服器啟動佇列太長怎麼辦？

A: 
- 在非高峰時段啟動伺服器
- 考慮升級到 Aternos+ 以獲得優先權
- 使用備用的免費託管服務

### Q: 外掛無法正常運作？

A: 
- 確認外掛版本與伺服器版本相容
- 檢查外掛相依性
- 查看伺服器日誌尋找錯誤資訊

### Q: 世界檔案上傳失敗？

A: 
- 確保檔案大小在限制範圍內
- 檢查檔案格式（應為 .zip 或 .tar.gz）
- 嘗試分批上傳大型世界

### Q: 如何保持伺服器線上？

A: 
- Aternos 會在無人時自動停止伺服器
- 可以讓朋友定期加入保持活躍
- 考慮使用其他付費託管服務

### Q: 如何備份進度？

A: 
- 定期下載世界檔案
- 使用本地備份腳本
- 保存重要的建築和物品

## 相關連結

- [Aternos 官網](https://aternos.org)
- [Aternos 幫助中心](https://support.aternos.org)
- [本專案其他部署方案](./README.md)
- [外掛管理指南](./PLUGIN_MANAGER_GUIDE.md)
- [遠端連線指南](./REMOTE_CONNECTION_GUIDE.md)

## 總結

Aternos 是一個優秀的免費 Minecraft 伺服器託管選擇，特別適合：

- 個人或小團隊使用
- 臨時測試和實驗
- 學習伺服器管理
- 預算有限的專案

透過本指南的詳細說明，您可以：

1. **輕鬆註冊並設置 Aternos 伺服器**
2. **手動轉移本地世界和配置到 Aternos**
3. **從 Aternos 下載並恢復到本地環境**
4. **靈活地在兩個平台之間切換**
5. **邀請朋友加入您的伺服器**

### 轉移要點總結

**本地到 Aternos**：

- 壓縮並上傳世界檔案
- 手動配置伺服器設定
- 安裝相同的外掛
- 設定白名單和管理員

**Aternos 到本地**：

- 下載世界檔案並解壓到 `worlds/` 目錄
- 根據 Aternos 設定更新 `config/server.properties`
- 重新安裝外掛到 `plugins/` 目錄
- 恢復玩家管理設定

**連線分享**：

- Aternos：直接分享 `你的伺服器名稱.aternos.me` 地址
- 本地：使用 ngrok 或端口轉發分享公網地址
- 安全性：設定白名單和管理員權限

結合本專案的管理腳本和配置，您可以在本地開發和 Aternos 託管之間實現靈活的部署策略，滿足不同階段的需求。無論是與朋友一起遊戲，還是進行伺服器測試，都能輕鬆切換平台並保持遊戲進度的完整性。
