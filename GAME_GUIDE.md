# 🎮 Yu Minecraft Server 遊戲指南

歡迎來到 Yu Minecraft 私服！本指南將帶您了解如何開始遊戲、安裝外掛，並享受最佳的遊戲體驗。

## 📋 目錄

- [🚀 快速開始](#-快速開始)
- [🎯 連接到服務器](#-連接到服務器)
- [🔧 伺服器配置](#-伺服器配置)
- [🔌 外掛管理](#-外掛管理)
- [👥 玩家管理](#-玩家管理)
- [🎨 自訂遊戲體驗](#-自訂遊戲體驗)
- [⚡ 效能最佳化](#-效能最佳化)
- [📊 監控和維護](#-監控和維護)
- [🛠️ 故障排除](#️-故障排除)

## 🚀 快速開始

### 第一步：部署伺服器

```bash
# 1. 部署伺服器
./deploy.sh

# 2. 等待服務啟動完成
# 你會看到 "🎉 部署完成!" 的訊息

# 3. 檢查服務狀態
./scripts/monitor.sh once
```

### 第二步：配置基本設置

```bash
# 複製配置範例
cp .env.example .env
cp config/ops.json.example config/ops.json
cp config/whitelist.json.example config/whitelist.json

# 編輯環境配置
nano .env
```

基本的 `.env` 配置：

```bash
# 伺服器基本設置
MEMORY=2G
RCON_PASSWORD=your-secure-password-here
SERVER_NAME=Yu Minecraft Server

# 伺服器屬性
MAX_PLAYERS=20
DIFFICULTY=normal
GAMEMODE=survival
ENABLE_WHITELIST=true
```

## 🎯 連接到服務器

### Minecraft 客戶端設置

1. **開啟 Minecraft**
2. **選擇多人遊戲**
3. **新增伺服器**：
   - 伺服器名稱：`Yu Minecraft Server`
   - 伺服器位址：`localhost:25565`（本地）或 `您的IP:25565`（遠程）
4. **加入遊戲**

### 支援的 Minecraft 版本

- **推薦版本**：1.20.1+
- **支援範圍**：1.18.x - 1.20.x
- **伺服器核心**：Spigot/Bukkit

### 網路設置

如果需要讓其他玩家連接：

```bash
# 檢查防火牆設置（Linux）
sudo ufw allow 25565/tcp

# 檢查路由器設置
# 需要開放 25565 端口到您的伺服器IP
```

## 🔧 伺服器配置

### 基本伺服器設置

編輯 `config/server.properties`：

```properties
# 基本設置
server-name=Yu Minecraft Server
motd=歡迎來到 Yu Minecraft 私服！
max-players=20
difficulty=normal

# 遊戲規則
spawn-protection=16
allow-flight=false
enable-command-block=true
gamemode=survival

# 效能設置
view-distance=8
simulation-distance=6
max-tick-time=60000
```

### 世界設置

```bash
# 創建新世界
# 編輯 server.properties
level-name=world
level-type=minecraft:normal
level-seed=

# 自訂世界生成
level-type=minecraft:amplified  # 放大世界
level-type=minecraft:flat       # 超平坦世界
```

## 🔌 外掛管理

### 推薦基礎外掛套件

```bash
# 安裝基本外掛套件
./scripts/plugins.sh essentials

# 檢視推薦外掛列表
./scripts/plugins.sh recommended
```

### 必備外掛介紹

#### 1. **EssentialsX** - 基礎指令套件

- **功能**：基本指令、經濟系統、傳送、家園設置
- **指令**：

  ```bash
  /home set [名稱]     # 設置家園
  /home [名稱]         # 傳送到家園
  /spawn              # 傳送到出生點
  /tpa [玩家]         # 請求傳送
  ```

#### 2. **WorldEdit** - 世界編輯工具

- **功能**：大規模建築編輯、地形修改
- **指令**：

  ```bash
  //wand              # 獲取編輯工具
  //set [方塊]        # 填充選定區域
  //copy              # 複製選定區域
  //paste             # 貼上複製的內容
  ```

#### 3. **WorldGuard** - 區域保護

- **功能**：保護重要建築、設置區域權限
- **指令**：

  ```bash
  /rg define [區域名] # 定義保護區域
  /rg addmember [區域] [玩家] # 添加成員
  /rg flag [區域] [標誌] [值] # 設置區域標誌
  ```

#### 4. **LuckPerms** - 權限管理

- **功能**：玩家權限、群組管理
- **指令**：

  ```bash
  /lp user [玩家] permission set [權限] # 設置權限
  /lp creategroup [群組名] # 創建群組
  /lp user [玩家] parent add [群組] # 加入群組
  ```

### 安裝自訂外掛

```bash
# 下載外掛
./scripts/plugins.sh download PluginName

# 手動安裝外掛
# 1. 下載 .jar 檔案到 plugins/ 目錄
# 2. 重啟伺服器
./scripts/stop.sh
./scripts/start.sh

# 檢查外掛狀態
./scripts/plugins.sh list
```

### 外掛配置範例

創建 `plugins/EssentialsX/config.yml`：

```yaml
# EssentialsX 配置範例
economy-enabled: true
starting-balance: 1000
currency-symbol: '$'

spawn:
  newbies: true
  respawn: true

teleport:
  delay: 3
  cooldown: 60

homes:
  max: 5
  update-bed: true
```

## 👥 玩家管理

### 管理員設置

編輯 `config/ops.json`：

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

### 白名單管理

```bash
# 啟用白名單模式
# 在 server.properties 中設置
white-list=true

# 編輯 config/whitelist.json
[
  {
    "uuid": "player-uuid",
    "name": "player-username"
  }
]

# 遊戲中管理白名單
/whitelist add [玩家名]
/whitelist remove [玩家名]
/whitelist list
```

### 玩家權限等級

- **等級 1**：一般玩家
- **等級 2**：建築師（可使用部分管理指令）
- **等級 3**：版主（可管理玩家、區域）
- **等級 4**：管理員（完全權限）

## 🎨 自訂遊戲體驗

### 遊戲模式設置

```bash
# 生存模式服務器
gamemode=survival
difficulty=normal
enable-pvp=true

# 創造模式服務器
gamemode=creative
difficulty=peaceful
enable-pvp=false

# 冒險模式服務器
gamemode=adventure
difficulty=hard
enable-pvp=true
```

### 自訂遊戲規則

在遊戲中輸入：
```
/gamerule keepInventory true          # 死亡不掉落物品
/gamerule doDaylightCycle false       # 停止日夜循環
/gamerule doWeatherCycle false        # 停止天氣變化
/gamerule mobGriefing false           # 怪物不破壞方塊
/gamerule doFireTick false            # 火不會蔓延
```

### 資源包和數據包

```bash
# 伺服器資源包設置（在 server.properties）
resource-pack=https://your-resource-pack-url.zip
resource-pack-sha1=
require-resource-pack=false

# 數據包安裝
# 將數據包放入 worlds/world/datapacks/ 目錄
# 重新載入數據包
/reload
```

## ⚡ 效能最佳化

### 自動效能最佳化

```bash
# 執行完整效能最佳化
./scripts/optimize.sh all

# 檢查系統效能
./scripts/optimize.sh check

# 生成效能報告
./scripts/optimize.sh report
```

### 手動效能調優

#### 視距設置
```properties
# server.properties
view-distance=8          # 8個區塊（推薦）
simulation-distance=6    # 6個區塊（推薦）
```

#### 實體限制
```yaml
# spigot.yml
spawn-limits:
  monsters: 50
  animals: 8
  water-animals: 3
  ambient: 1

entity-activation-range:
  animals: 24
  monsters: 24
  misc: 8
```

#### JVM 參數調優
```bash
# 根據可用記憶體調整（在 docker/Dockerfile）
# 2GB 記憶體
JAVA_OPTS="-Xms1G -Xmx1536M -XX:+UseG1GC"

# 4GB 記憶體
JAVA_OPTS="-Xms2G -Xmx3G -XX:+UseG1GC"

# 8GB 記憶體
JAVA_OPTS="-Xms4G -Xmx6G -XX:+UseG1GC"
```

## 📊 監控和維護

### 即時監控

```bash
# 啟動即時監控
./scripts/monitor.sh continuous

# 查看效能統計
./scripts/performance.sh report

# 檢查伺服器狀態
./scripts/monitor.sh once
```

### Web 管理介面

開啟瀏覽器訪問：`http://localhost:8080`

功能包括：
- 即時服務器狀態
- 玩家列表
- 效能監控
- 指令控制台
- 系統資源使用

### 自動備份

```bash
# 手動備份
./scripts/backup.sh

# 設置自動備份（crontab）
crontab -e

# 添加以下行：每天凌晨2點備份
0 2 * * * cd /path/to/yu-minecraft && ./scripts/backup.sh
```

### 定期維護

建議的維護計劃：

#### 每日
- 檢查服務器狀態
- 查看玩家活動記錄
- 清理臨時檔案

#### 每週
- 執行完整備份
- 檢查外掛更新
- 清理舊日誌檔案

#### 每月
- 效能最佳化檢查
- 系統安全更新
- 世界檔案整理

## 🛠️ 故障排除

### 常見問題解決

#### 1. 服務器無法啟動

```bash
# 檢查錯誤日誌
docker logs yu-minecraft-server

# 檢查配置檔案
./scripts/optimize.sh check

# 重建容器
cd docker && docker compose down && docker compose build --no-cache && docker compose up -d
```

#### 2. 玩家無法連接

```bash
# 檢查網路連接
telnet localhost 25565

# 檢查防火牆設置
sudo ufw status

# 檢查白名單設置
cat config/whitelist.json
```

#### 3. 效能問題

```bash
# 檢查資源使用
docker stats yu-minecraft-server

# 執行效能最佳化
./scripts/optimize.sh all

# 檢查TPS（每秒刻度）
# 在遊戲中輸入：/tps
```

#### 4. 外掛衝突

```bash
# 檢查外掛相容性
./scripts/plugins.sh check

# 逐個禁用外掛測試
# 移動外掛檔案到 plugins/disabled/ 目錄
mkdir plugins/disabled
mv plugins/問題外掛.jar plugins/disabled/

# 重啟服務器
./scripts/stop.sh && ./scripts/start.sh
```

### 緊急恢復程序

如果伺服器出現嚴重問題：

```bash
# 1. 停止服務器
./scripts/stop.sh

# 2. 備份當前狀態
cp -r worlds worlds.backup
cp -r plugins plugins.backup

# 3. 恢復到最近的備份
# 列出可用備份
ls -la backups/

# 恢復備份（請替換為實際的備份檔案名）
tar -xzf backups/minecraft_backup_YYYYMMDD_HHMMSS.tar.gz

# 4. 重啟服務器
./scripts/start.sh
```

## 📚 額外資源

### 有用的連結

- **Spigot 官方文檔**：https://www.spigotmc.org/wiki/
- **Bukkit 外掛列表**：https://dev.bukkit.org/bukkit-plugins
- **Minecraft Wiki**：https://minecraft.wiki/
- **PaperMC 文檔**：https://docs.papermc.io/

### 社群支援

- **Spigot 論壇**：https://www.spigotmc.org/
- **Reddit Minecraft 服務器**：r/admincraft
- **Discord 社群**：搜尋 "Minecraft Server Admin"

### 進階配置

如需進階功能，請查看：
- `config/` 目錄中的配置檔案
- `scripts/` 目錄中的管理腳本
- `PROJECT_STRUCTURE.md` 了解專案結構

---

🎮 **祝您遊戲愉快！**

如有任何問題，請參考故障排除章節或查看項目的 GitHub 討論區。
