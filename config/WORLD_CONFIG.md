# 世界配置檔案說明

每個世界目錄可以包含以下配置檔案：

## 世界特定配置檔案
- `world.env` - 該世界的環境變數設定
- `server.properties` - 該世界的伺服器屬性
- `ops.json` - 該世界的管理員列表
- `whitelist.json` - 該世界的白名單
- `banned-players.json` - 該世界的封禁玩家列表
- `banned-ips.json` - 該世界的封禁IP列表

## 設定檔案優先級
1. 世界目錄中的配置檔案 (最高優先級)
2. `config/global/` 中的全域配置檔案
3. `config/examples/` 中的預設範例檔案

## 配置檔案載入機制
當切換世界時，系統會：
1. 檢查世界目錄是否有專屬配置檔案
2. 如果沒有，使用全域配置檔案
3. 如果全域配置也沒有，使用預設範例檔案

## 範例世界配置

在世界目錄中創建 `world.env` 檔案：
```bash
# 該世界的特殊設定
GAMEMODE=creative
DIFFICULTY=peaceful
MAX_PLAYERS=10
SPAWN_PROTECTION=0
```
