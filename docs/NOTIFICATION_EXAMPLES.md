# 📱 通知功能展示

這個檔案展示了 Yu Minecraft Server 自動通知功能的實際效果。

## 🚀 當伺服器啟動時

### 終端輸出

```bash
ubuntu@minecraft-server:~/yu-minecraft$ ./scripts/start.sh

🎮 啟動 Yu Minecraft 伺服器...
📦 建構並啟動容器...
⏳ 等待服務啟動...
✅ Yu Minecraft 伺服器啟動成功!

🔍 正在獲取伺服器 IP 地址...

🌐 AWS EC2 伺服器連線資訊:
   伺服器地址: 52.78.123.45:25565
   Web管理介面: http://52.78.123.45:8080
   實例 ID: i-0123456789abcdef0

📢 通知選項:
   📄 連線資訊已保存到: connection_info.txt
   📱 正在發送 Discord 通知...
   ✅ Discord 通知已發送
   📱 正在發送 Telegram 通知...
   ✅ Telegram 通知已發送

💡 提示: 複製上方地址分享給朋友們！
📋 完整連線資訊已保存到 connection_info.txt 檔案

📢 正在發送啟動通知...
🔔 通知功能展示
🌐 伺服器: 52.78.123.45:25565
⏰ 時間: 14:30:25

📋 使用以下指令查看記錄:
   docker compose logs -f minecraft

🛑 使用以下指令停止伺服器:
   ./scripts/stop.sh
```

### 📱 Discord 通知訊息

```
🎮 Minecraft 伺服器已啟動！
🌐 連線地址: `52.78.123.45:25565`
🖥️ 管理介面: http://52.78.123.45:8080
⏰ 啟動時間: 14:30:25
```

### 📱 Telegram 通知訊息

```
🎮 Minecraft 伺服器已啟動！
🌐 連線地址: 52.78.123.45:25565
🖥️ 管理介面: http://52.78.123.45:8080
⏰ 啟動時間: 14:30:25
```

### 📧 Line Notify 通知

```
🎮 Minecraft 伺服器已啟動！
🌐 連線地址: 52.78.123.45:25565
🖥️ 管理介面: http://52.78.123.45:8080
⏰ 啟動時間: 14:30:25
```

## 📄 connection_info.txt 檔案內容

```
📅 2025-08-27 14:30:25
🎮 Yu Minecraft 伺服器已啟動

🌐 連線資訊:
   伺服器地址: 52.78.123.45:25565
   Web管理介面: http://52.78.123.45:8080

📋 其他資訊:
   實例 ID: i-0123456789abcdef0
   啟動時間: Tue Aug 27 14:30:25 UTC 2025
   
📖 使用說明:
1. 在 Minecraft 中選擇「多人遊戲」
2. 新增伺服器，輸入地址: 52.78.123.45:25565
3. 享受遊戲！

❓ 需要幫助? 查看 README.md 或聯絡管理員
```

## 🎛️ 手動通知範例

### 發送自訂訊息

```bash
ubuntu@minecraft-server:~/yu-minecraft$ ./scripts/notify.sh custom -m "伺服器將於晚上 10 點進行維護，預計 30 分鐘"

📢 開始發送通知...

📱 發送 Discord 通知...
✅ Discord 通知已發送
📱 發送 Telegram 通知...
✅ Telegram 通知已發送
📱 發送 Line 通知...
✅ Line 通知已發送

🎉 通知發送完成！
```

**朋友們收到的訊息**:
```
📢 伺服器將於晚上 10 點進行維護，預計 30 分鐘
🌐 伺服器: 52.78.123.45:25565
⏰ 時間: 21:45:12
```

### 狀態報告

```bash
ubuntu@minecraft-server:~/yu-minecraft$ ./scripts/notify.sh status

📢 開始發送通知...

📱 發送 Discord 通知...
✅ Discord 通知已發送

🎉 通知發送完成！
```

**朋友們收到的狀態報告**:
```
📊 伺服器狀態報告
🌐 伺服器: 52.78.123.45:25565
📈 狀態: 🟢 運行中
⏰ 檢查時間: 15:20:45
```

## 🧪 測試通知功能

```bash
ubuntu@minecraft-server:~/yu-minecraft$ ./scripts/notify.sh -t

🧪 正在測試所有通知管道...

📢 開始發送通知...

📱 發送 Discord 通知...
✅ Discord 通知已發送
📱 發送 Telegram 通知...
✅ Telegram 通知已發送
📱 發送 Line 通知...
✅ Line 通知已發送

🎉 通知發送完成！
```

**測試訊息內容**:
```
🔔 這是一個測試通知！
🎮 Yu Minecraft Server
🌐 伺服器: 52.78.123.45:25565
⏰ 時間: Tue Aug 27 15:25:30 UTC 2025
```

## 💡 實際使用場景

### 場景 1: 好友聚會
```bash
# 開服前通知
./scripts/notify.sh custom -m "今晚 8 點一起玩 Minecraft！伺服器已準備就緒 🎮"

# 啟動伺服器（自動發送連線資訊）
./scripts/start.sh
```

### 場景 2: 活動公告
```bash
# 特殊活動通知
./scripts/notify.sh custom -m "🎉 週末建築大賽開始！獎品：鑽石裝備套組"
```

### 場景 3: 維護通知
```bash
# 維護前通知
./scripts/notify.sh custom -m "⚠️ 伺服器將在 5 分鐘後重啟更新，請先將物品存放好"

# 維護完成通知（伺服器重啟時自動發送）
./scripts/start.sh
```

### 場景 4: 定期狀態報告
```bash
# 設定 crontab 每日定時發送
crontab -e
# 每天晚上 8 點發送狀態報告
0 20 * * * /home/ubuntu/yu-minecraft/scripts/notify.sh status
```

---

**🎯 結果**: 朋友們再也不用問「伺服器地址是什麼？」，一切都自動化了！
