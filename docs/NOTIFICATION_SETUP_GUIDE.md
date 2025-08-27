# 📱 伺服器通知設定指南

本指南將幫助你設定自動通知功能，讓朋友們在伺服器啟動時自動收到連線資訊。

## 🚀 快速設定

### 1. 複製設定檔

```bash
# 複製範例設定檔
cp .env.example .env
```

### 2. 編輯設定檔

```bash
# 編輯設定檔
nano .env
```

### 3. 選擇通知方式

根據你的需求選擇一種或多種通知方式：

## 🔔 支援的通知方式

### Discord Webhook 

**最推薦** - 設定簡單，功能完整

1. 在 Discord 伺服器中右鍵點擊頻道
2. 選擇「編輯頻道」→「整合」→「Webhooks」
3. 建立新的 Webhook，複製 URL
4. 在 `.env` 中設定：
   ```bash
   DISCORD_WEBHOOK=https://discord.com/api/webhooks/YOUR_WEBHOOK_URL
   ```

### Telegram Bot

**適合群組通知**

1. 與 [@BotFather](https://t.me/BotFather) 對話
2. 執行 `/newbot` 建立新 Bot
3. 獲取 Bot Token
4. 將 Bot 加入群組，獲取 Chat ID
5. 在 `.env` 中設定：
   ```bash
   TELEGRAM_BOT_TOKEN=YOUR_BOT_TOKEN
   TELEGRAM_CHAT_ID=YOUR_CHAT_ID
   ```

**獲取 Chat ID 方法：**
```bash
# 1. 將 Bot 加入群組
# 2. 在群組中發送任意訊息
# 3. 訪問以下 URL（替換 YOUR_BOT_TOKEN）
curl https://api.telegram.org/botYOUR_BOT_TOKEN/getUpdates
```

### Line Notify

**台灣用戶推薦**

1. 訪問 [Line Notify](https://notify-bot.line.me/)
2. 登入並產生個人存取權杖
3. 選擇要接收通知的群組
4. 在 `.env` 中設定：
   ```bash
   LINE_NOTIFY_TOKEN=YOUR_LINE_TOKEN
   ```

### Slack Webhook

**企業用戶適用**

1. 在 Slack 工作區中安裝 Incoming Webhooks 應用
2. 選擇接收通知的頻道
3. 複製 Webhook URL
4. 在 `.env` 中設定：
   ```bash
   SLACK_WEBHOOK=https://hooks.slack.com/services/YOUR_WEBHOOK_URL
   ```

### Email 通知

**傳統方式**

Gmail 設定範例：
1. 啟用 Gmail 兩步驟驗證
2. 產生應用程式密碼
3. 在 `.env` 中設定：
   ```bash
   SMTP_SERVER=smtp.gmail.com
   SMTP_PORT=587
   SMTP_USER=your-email@gmail.com
   SMTP_PASS=your-app-password
   NOTIFY_EMAIL=friend1@example.com,friend2@example.com
   ```

## 🧪 測試通知

設定完成後，測試通知功能：

```bash
# 測試所有設定的通知方式
./scripts/notify.sh -t

# 測試特定訊息
./scripts/notify.sh custom -m "測試訊息"
```

## 📋 通知內容

啟動伺服器時，朋友們會收到包含以下資訊的通知：

```
🎮 Minecraft 伺服器已啟動！
🌐 連線地址: `your-server-ip:25565`
🖥️ 管理介面: http://your-server-ip:8080
⏰ 啟動時間: 14:30:25
```

## 🎛️ 進階設定

### 自動通知開關

在 `.env` 中控制自動通知：

```bash
AUTO_NOTIFY_STARTUP=true    # 啟動時自動通知
AUTO_NOTIFY_SHUTDOWN=true   # 關閉時自動通知  
AUTO_NOTIFY_ERRORS=true     # 錯誤時自動通知
```

### 手動發送通知

```bash
# 伺服器啟動通知
./scripts/notify.sh startup

# 伺服器關閉通知
./scripts/notify.sh shutdown

# 狀態報告
./scripts/notify.sh status

# 自訂訊息
./scripts/notify.sh custom -m "伺服器將於晚上10點維護"
```

### 定時狀態報告

設定 crontab 定時發送狀態報告：

```bash
# 編輯 crontab
crontab -e

# 每天中午12點發送狀態報告
0 12 * * * /path/to/yu-minecraft/scripts/notify.sh status

# 每週日晚上8點發送狀態報告
0 20 * * 0 /path/to/yu-minecraft/scripts/notify.sh status
```

## 🔒 安全性建議

1. **保護 Token 和 Webhook URL**
   - 不要將 `.env` 檔案提交到 Git
   - 定期更換敏感資訊

2. **限制通知內容**
   - 避免在通知中包含敏感資訊
   - 考慮使用私人群組接收通知

3. **監控通知頻率**
   - 避免過於頻繁的通知
   - 設定合理的通知間隔

## ❓ 常見問題

### Q: 為什麼沒有收到通知？

1. 檢查 `.env` 設定是否正確
2. 使用 `./scripts/notify.sh -t` 測試
3. 檢查網路連線
4. 確認 Token 或 Webhook URL 有效

### Q: 如何只啟用特定的通知方式？

只需在 `.env` 中設定你想要的通知方式，其他的留空即可。

### Q: 可以自訂通知訊息格式嗎？

可以編輯 `scripts/notify.sh` 中的 `generate_message` 函數來自訂訊息格式。

### Q: 如何在本地測試時不發送通知？

在本地環境中不設定 `.env` 檔案，或者將通知相關變數留空。

## 📞 需要幫助？

如果在設定過程中遇到問題：

1. 查看 [常見問題](../README.md#故障排除)
2. 提交 [GitHub Issue](https://github.com/yourusername/yu-minecraft/issues)
3. 聯絡管理員

---

**💡 小提示**：建議先使用 Discord 或 Telegram 設定，它們最容易配置且功能完整！
