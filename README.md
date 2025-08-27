# Yu Minecraft 私服 (v1.21.8)

一個基於Docker的Minecraft私服專案，提供簡單易用的部署和管理方案。現已支援最新的 Minecraft 1.21.8 版本！

## ✨ 新版本特色

- 🆕 **完全支援 Minecraft 1.21.8**
- 🏗️ **新特性整合**：Crafter、Trial Chambers、Wind Charges 等
- ⚡ **效能最佳化**：針對 1.21.8 的專屬調優
- 🔌 **外掛相容性**：與最新外掛完美整合
- ☁️ **雲端部署**：完整的 AWS 部署方案

📋 **詳細版本資訊**: 請參閱 [VERSION_1.21.8.md](./docs/VERSION_1.21.8.md)

## 📋 目錄

- [快速開始](#-快速開始)
- [AWS 雲端部署](#️-aws-雲端部署)
- [伺服器管理](#-伺服器管理)
- [外掛管理](#-外掛管理)
- [遊戲設置](#-遊戲設置)
- [監控與維護](#-監控與維護)
- [專案結構](#-專案結構)
- [進階設置](#-進階設置)
- [故障排除](#-故障排除)
- [文檔索引](#-文檔索引)

## 📋 開發流程

詳細的開發流程和專案結構說明，請參考：[PROJECT_STRUCTURE.md](./docs/PROJECT_STRUCTURE.md)

## 🚀 快速開始

### 系統要求

- AWS 帳號（推薦使用免費方案）
- 本地開發：Docker 20.0+ 和 Docker Compose 2.0+
- 至少 2GB RAM（雲端）或 4GB RAM（本地）
- 10GB 可用磁碟空間

### 本地測試部署

```bash
# 複製專案
git clone https://github.com/yu-codes/yu-minecraft.git
cd yu-minecraft

# 啟動伺服器
docker-compose up -d

# 查看啟動記錄
docker-compose logs -f minecraft
```

### 雲端生產部署

建議使用 AWS 進行生產環境部署：

```bash
# 完整的 AWS 部署指南
📖 詳見：docs/AWS_DEPLOYMENT_GUIDE.md
```

## ☁️ AWS 雲端部署

### 快速部署步驟

1. **AWS 帳號準備**
   ```bash
   # 註冊 AWS 帳號：https://aws.amazon.com/
   # 使用免費方案：t2.micro 實例（12個月免費）
   ```

2. **EC2 實例設置**
   ```bash
   # 選擇 Ubuntu 22.04 LTS
   # 實例類型：t2.micro（免費方案）
   # 儲存空間：20GB gp3
   # 安全群組：開放 22, 25565, 8080 端口
   ```

3. **連接伺服器**
   ```powershell
   # Windows PowerShell
   ssh -i "minecraft-server-key.pem" ubuntu@YOUR_EC2_PUBLIC_IP
   ```

4. **自動化部署**
   ```bash
   # 在 EC2 實例上執行
   curl -fsSL https://raw.githubusercontent.com/yu-codes/yu-minecraft/main/scripts/aws-deploy.sh | bash
   ```

5. **驗證部署與通知設定**
   ```bash
   # 檢查服務狀態
   docker ps
   
   # 查看伺服器記錄
   docker-compose logs minecraft
   
   # 測試通知功能（可選）
   ./scripts/notify.sh -t
   ```

6. **自動通知朋友連線資訊**
   - ✅ 伺服器啟動時自動發送連線地址
   - ✅ 支援 Discord、Telegram、Line Notify
   - ✅ 連線資訊自動保存到 `connection_info.txt`
   - ✅ 一鍵分享功能
   
   # 取得公用 IP
   curl http://checkip.amazonaws.com
   ```

### AWS 部署優勢

- 🌍 **24/7 穩定運行**：專業雲端基礎設施
- 💰 **成本可控**：免費方案可運行 12 個月
- 🔒 **企業級安全**：AWS 安全群組保護
- 📊 **完整監控**：CloudWatch 整合監控
- 🚀 **彈性擴展**：隨時升級實例規格

**📖 完整部署指南**: [AWS_DEPLOYMENT_GUIDE.md](./docs/AWS_DEPLOYMENT_GUIDE.md)

## 🎛️ 伺服器管理

### 基本操作

```bash
# 進入專案目錄
cd yu-minecraft

# 啟動伺服器
./scripts/start.sh

# 停止伺服器
./scripts/stop.sh

# 重啟伺服器
./scripts/stop.sh && ./scripts/start.sh

# 查看伺服器狀態
./scripts/monitor.sh once
```

### 整合管理介面

```bash
# 啟動管理介面
./manage.sh

# 功能選項：
# 1) 啟動/停止伺服器
# 2) 查看系統狀態
# 3) 管理外掛
# 4) 執行備份
# 5) 效能最佳化
```

### Web 管理控制台

```bash
# 啟動 Web 管理介面
docker-compose up -d web

# 訪問控制台
# 本地：http://localhost:8080
# AWS：http://YOUR_EC2_IP:8080
```

### 🔔 自動通知功能

**讓朋友自動收到連線資訊！** 

```bash
# 快速設定通知（以 Discord 為例）
cp .env.example .env
nano .env
# 設定：DISCORD_WEBHOOK=https://discord.com/api/webhooks/YOUR_URL

# 啟動伺服器時自動發送通知
./scripts/start.sh
# ✅ 朋友們會自動收到包含連線地址的訊息

# 手動發送通知
./scripts/notify.sh custom -m "伺服器已更新，快來體驗新功能！"

# 測試通知設定
./scripts/notify.sh -t
```

**支援平台**: Discord、Telegram、Line Notify、Slack、Email

**📖 完整通知設定指南**: [NOTIFICATION_SETUP_GUIDE.md](./docs/NOTIFICATION_SETUP_GUIDE.md)

### 配置文件管理

```bash
# 管理員設置
nano config/ops.json

# 白名單設置
nano config/whitelist.json

# 伺服器設置
nano config/server.properties

# 環境變數
nano .env
```

## 🔌 外掛管理

### 推薦外掛安裝

```bash
# 安裝基礎外掛套件
./scripts/plugins.sh essentials

# 這會安裝：
# - EssentialsX (基礎指令)
# - Vault (經濟系統API)
# - LuckPerms (權限管理)
# - WorldEdit (世界編輯)
# - WorldGuard (區域保護)
```

### 外掛操作

```bash
# 查看已安裝外掛
./scripts/plugins.sh list

# 查看推薦外掛
./scripts/plugins.sh recommended

# 安裝特定外掛
./scripts/plugins.sh install [外掛名稱]

# 移除外掛
./scripts/plugins.sh remove [外掛名稱]

# 備份外掛
./scripts/plugins.sh backup
```

### 常用外掛介紹

| 外掛名稱 | 功能 | 安裝指令 |
|---------|------|----------|
| **EssentialsX** | 基礎指令套件 | `./scripts/plugins.sh install EssentialsX` |
| **LuckPerms** | 權限管理系統 | `./scripts/plugins.sh install LuckPerms` |
| **WorldEdit** | 世界編輯工具 | `./scripts/plugins.sh install WorldEdit` |
| **WorldGuard** | 區域保護 | `./scripts/plugins.sh install WorldGuard` |
| **ChestShop** | 商店系統 | `./scripts/plugins.sh install ChestShop` |
| **Citizens** | NPC 系統 | `./scripts/plugins.sh install Citizens` |

**📖 完整外掛管理指南**: [PLUGIN_MANAGER_GUIDE.md](./docs/PLUGIN_MANAGER_GUIDE.md)

## 🎮 遊戲設置

### 連接到伺服器

1. **取得伺服器地址**：
   ```bash
   # AWS 部署
   curl http://checkip.amazonaws.com
   
   # 本地部署
   echo "localhost:25565"
   ```

2. **Minecraft 客戶端設置**：
   - 開啟 Minecraft Java 版
   - 選擇 "多人遊戲"
   - 新增伺服器：`YOUR_SERVER_IP:25565`

### 基本遊戲配置

```bash
# 設置遊戲模式
gamemode=survival        # 生存模式
difficulty=normal        # 普通難度
max-players=20          # 最大玩家數

# 世界設置
level-name=world        # 世界名稱
spawn-protection=16     # 出生點保護範圍
allow-flight=false      # 是否允許飛行
```

### 玩家管理

```bash
# 添加管理員
# 編輯 config/ops.json
[
  {
    "uuid": "your-minecraft-uuid",
    "name": "your-minecraft-username",
    "level": 4
  }
]

# 白名單管理
# 編輯 config/whitelist.json
[
  {
    "uuid": "player-uuid",
    "name": "player-username"
  }
]
```

### 遊戲中常用指令

```
# 管理員指令
/op [玩家名]              # 給予管理員權限
/whitelist add [玩家名]    # 添加到白名單
/gamemode creative [玩家名] # 設置創造模式
/tp [玩家名] [目標]        # 傳送玩家

# 基礎指令（需要 EssentialsX）
/home set [名稱]          # 設置家園
/spawn                   # 回到出生點
/tpa [玩家名]             # 請求傳送
/money                   # 查看金錢
```

**📖 完整遊戲指南**: [GAME_GUIDE.md](./docs/GAME_GUIDE.md)

## 📊 監控與維護

### 系統監控

```bash
# 即時監控
./scripts/monitor.sh continuous

# 一次性檢查
./scripts/monitor.sh once

# 查看歷史記錄
./scripts/monitor.sh logs
```

### 效能監控

```bash
# 效能分析
./scripts/performance.sh report

# 記錄效能資料
./scripts/performance.sh monitor

# 匯出效能資料
./scripts/performance.sh export
```

### 自動備份

```bash
# 手動備份
./scripts/backup.sh

# 設置自動備份（每日凌晨2點）
crontab -e
# 添加：0 2 * * * /home/ubuntu/yu-minecraft/scripts/backup.sh
```

### 效能最佳化

```bash
# 自動最佳化
./scripts/optimize.sh all

# 檢查系統效能
./scripts/optimize.sh check

# 生成最佳化報告
./scripts/optimize.sh report
```

### AWS 監控

```bash
# CloudWatch 監控設置
aws cloudwatch put-metric-alarm \
    --alarm-name "High-CPU-Utilization" \
    --metric-name CPUUtilization \
    --threshold 80

```

## 🛠️ 故障排除

### 常見問題

| 問題 | 解決方案 |
|------|----------|
| **容器無法啟動** | `docker-compose down && docker-compose up -d` |
| **埠號衝突** | 修改 `docker-compose.yml` 中的埠號設置 |
| **記憶體不足** | 增加 `-Xmx` 參數或升級 EC2 實例 |
| **無法連線** | 檢查 AWS 安全群組設置 |
| **存檔遺失** | 執行 `./scripts/backup.sh restore` |

### 日誌查看

```bash
# 查看伺服器日誌
docker-compose logs minecraft

# 即時日誌
docker-compose logs -f minecraft

# 系統日誌
./scripts/monitor.sh logs

# 錯誤日誌
grep "ERROR" logs/latest.log
```

### 緊急復原

```bash
# 停止所有服務
docker-compose down

# 清理 Docker 資源
docker system prune -a

# 從備份復原
./scripts/backup.sh restore

# 重啟服務
docker-compose up -d
```

### 效能問題診斷

```bash
# 檢查系統資源
./scripts/performance.sh report

# 分析 TPS（每秒嘀答數）
./scripts/optimize.sh tps

# 記憶體使用分析
./scripts/optimize.sh memory
```

## 🤝 貢獻

1. Fork 這個專案
2. 建立功能分支：`git checkout -b feature/新功能`
3. 提交變更：`git commit -m '新增某功能'`
4. 推送到分支：`git push origin feature/新功能`
5. 提交 Pull Request

## 🆘 支援

- **問題回報**: [GitHub Issues](https://github.com/yourusername/yu-minecraft/issues)
- **技術文件**: [專案文件目錄](./docs/)
- **社群討論**: [GitHub Discussions](https://github.com/yourusername/yu-minecraft/discussions)

## 🔄 更新日誌

### v1.21.8 (最新版本)
- ✅ 支援最新 Minecraft 版本
- ✅ AWS EC2 自動部署
- ✅ 整合式 Web 管理介面
- ✅ 自動備份和監控系統
- ✅ 效能最佳化工具

詳細更新內容請參考：[VERSION_1.21.8.md](./docs/VERSION_1.21.8.md)

## 📋 快速檢查清單

### 部署前檢查
- [ ] AWS 帳戶已設置並配置 CLI
- [ ] Docker 和 Docker Compose 已安裝
- [ ] 安全群組已正確配置（25565, 22, 8080 埠）
- [ ] EC2 實例資源符合需求
- [ ] 域名已設置（可選）

### 首次啟動檢查
- [ ] 伺服器成功啟動
- [ ] 能夠透過 IP 連線
- [ ] 管理員權限已設置
- [ ] Web 管理介面可存取
- [ ] 備份系統正常運作

### 日常維護檢查
- [ ] 系統資源使用正常
- [ ] 備份檔案定期產生
- [ ] 外掛功能正常
- [ ] 伺服器效能穩定
- [ ] 安全更新已套用

## 📄 授權條款

本專案使用 MIT 授權條款 - 詳見 [LICENSE](LICENSE) 檔案

---

**🚀 準備好開始你的 Minecraft 冒險了嗎？按照上述步驟，你將擁有一個功能完整、高效能的 Minecraft 伺服器！**

📧 如有問題或建議，歡迎透過 [GitHub Issues](https://github.com/yourusername/yu-minecraft/issues) 聯絡我們。
