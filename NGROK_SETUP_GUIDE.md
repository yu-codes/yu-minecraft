# 🌐 ngrok 設置完整指南

ngrok 是一個強大的隧道服務，可以讓你的本地 Minecraft 伺服器在外網可見。本指南將詳細說明如何設置 ngrok，包括信用卡綁定流程。

## 📋 目錄

1. [註冊 ngrok 帳號](#註冊-ngrok-帳號)
2. [綁定信用卡](#綁定信用卡)
3. [取得 authtoken](#取得-authtoken)
4. [安裝 ngrok](#安裝-ngrok)
5. [設置隧道](#設置隧道)
6. [測試連線](#測試連線)
7. [常見問題](#常見問題)

## 🆕 註冊 ngrok 帳號

### 步驟 1：訪問註冊頁面

1. 打開瀏覽器，訪問：https://ngrok.com/signup
2. 選擇註冊方式：
   - **推薦**：使用 Google 帳號快速註冊
   - 或使用 GitHub 帳號
   - 或手動填寫郵箱和密碼

### 步驟 2：完成帳號驗證

1. 如果使用郵箱註冊，檢查郵箱收取驗證信
2. 點擊驗證連結完成帳號啟用
3. 登入 ngrok 控制台

## 💳 綁定信用卡

### 為什麼需要綁定信用卡？

從 2023 年開始，ngrok 要求免費用戶綁定信用卡才能使用 TCP 隧道（Minecraft 需要）：
- **目的**：防止濫用，保護服務品質
- **費用**：免費額度內**不會扣款**
- **額度**：每月免費 1GB 流量，40,000 分鐘連線時間

### 步驟 1：進入計費設置

1. 登入 ngrok 後，點擊右上角的用戶頭像
2. 選擇 "Settings" 或 "設置"
3. 在左側菜單找到 "Billing" 或 "帳單"

### 步驟 2：添加信用卡

1. 點擊 "Add Credit Card" 或 "新增信用卡"
2. 填寫信用卡資訊：
   - 卡號（16 位數字）
   - 有效期限（MM/YY）
   - CVV（背面 3 位數字）
   - 持卡人姓名
   - 帳單地址

### 步驟 3：驗證卡片

1. 銀行可能會發送驗證碼到你的手機
2. 輸入驗證碼完成綁定
3. 看到 "Card verified" 表示成功

### 💡 信用卡使用說明

- **免費額度**：每月 1GB 流量 + 40,000 分鐘連線
- **計費方式**：超出免費額度才收費
- **一般用途**：家庭遊戲使用通常不會超出免費額度
- **安全性**：可隨時在設置中移除卡片

## 🔑 取得 authtoken

### 步驟 1：訪問 authtoken 頁面

1. 登入 ngrok 控制台
2. 訪問：https://dashboard.ngrok.com/get-started/your-authtoken
3. 或在控制台左側菜單點擊 "Your Authtoken"

### 步驟 2：複製 authtoken

1. 看到類似這樣的字串：`2abc_def123...`
2. 點擊 "Copy" 按鈕複製
3. **重要**：請妥善保管，不要分享給他人

## 📦 安裝 ngrok

### 自動安裝（推薦）

```bash
# 使用我們的腳本自動安裝和設置
./scripts/remote-connect-ngrok.sh
```

### 手動安裝

#### macOS 用戶

```bash
# 使用 Homebrew（推薦）
brew install ngrok/ngrok/ngrok

# 或下載安裝包
curl -O https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-darwin-amd64.zip
unzip ngrok-stable-darwin-amd64.zip
sudo mv ngrok /usr/local/bin/
```

#### Linux 用戶

```bash
# 下載並安裝
wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
unzip ngrok-stable-linux-amd64.zip
sudo mv ngrok /usr/local/bin/
```

#### Windows 用戶

1. 訪問：https://ngrok.com/download
2. 下載 Windows 版本
3. 解壓到想要的目錄
4. 將目錄加入系統 PATH

## ⚙️ 設置隧道

### 步驟 1：設置 authtoken

```bash
# 替換成你的 authtoken
ngrok config add-authtoken 你的authtoken
```

### 步驟 2：確認 Minecraft 伺服器運行

```bash
# 啟動伺服器（如果還沒啟動）
docker compose -f docker/docker-compose.yml up -d

# 檢查狀態
docker compose -f docker/docker-compose.yml ps
```

### 步驟 3：啟動 ngrok 隧道

```bash
# 建立 TCP 隧道到 Minecraft 伺服器
ngrok tcp 25565
```

### 步驟 4：取得連線地址

隧道啟動後，你會看到類似這樣的輸出：

```
ngrok by @inconshreveable

Session Status                online
Account                       你的郵箱 (Plan: Free)
Version                       2.3.40
Region                        United States (us)
Web Interface                 http://127.0.0.1:4040
Forwarding                    tcp://0.tcp.ngrok.io:12345 -> localhost:25565

Connections                   ttl     opn     rt1     rt5     p50     p90
                              0       0       0.00    0.00    0.00    0.00
```

**重要**：`tcp://0.tcp.ngrok.io:12345` 就是你要給朋友的連線地址！

## 🧪 測試連線

### 步驟 1：本地測試

```bash
# 測試本地連線
nc -z localhost 25565
echo $?  # 如果返回 0 表示成功
```

### 步驟 2：外網測試

1. 開啟 Minecraft 客戶端
2. 選擇 "多人遊戲"
3. 添加伺服器：`0.tcp.ngrok.io:12345`（替換成你的實際地址）
4. 嘗試連線

### 步驟 3：朋友測試

1. 將 ngrok 地址發給朋友
2. 請朋友在 Minecraft 中添加伺服器
3. 測試連線和遊戲

## 🎮 使用技巧

### Web 界面監控

ngrok 提供了本地 Web 界面來監控連線：

```bash
# ngrok 運行時，訪問：
open http://localhost:4040
```

你可以看到：
- 即時連線統計
- 流量使用情況
- 連線記錄

### 固定子域名（付費功能）

如果你升級到付費版，可以使用固定子域名：

```bash
# 使用自訂子域名
ngrok tcp -subdomain=my-minecraft-server 25565
```

這樣連線地址就變成：`my-minecraft-server.tcp.ngrok.io:端口`

### 背景運行

如果你想讓 ngrok 在背景運行：

```bash
# 使用 nohup 讓程序在背景運行
nohup ngrok tcp 25565 > ngrok.log 2>&1 &

# 查看記錄
tail -f ngrok.log

# 停止背景程序
pkill ngrok
```

## ❓ 常見問題

### Q: 信用卡會被扣款嗎？

**A**: 在免費額度內（每月 1GB 流量 + 40,000 分鐘）不會扣款。一般家庭遊戲使用很難超出這個額度。

### Q: 每次重啟網址都會變嗎？

**A**: 是的，免費版每次重啟會得到隨機網址。付費版可以使用固定子域名。

### Q: 隧道斷線怎麼辦？

**A**: 免費版隧道會在 2 小時後自動斷線，需要重新啟動：

```bash
# 重新啟動隧道
ngrok tcp 25565
```

### Q: 如何查看流量使用情況？

**A**: 
1. 登入 ngrok 控制台
2. 查看 "Usage" 或 "使用情況" 頁面
3. 或在本地 Web 界面 http://localhost:4040 查看

### Q: 可以同時運行多個隧道嗎？

**A**: 免費版只能同時運行一個隧道。付費版可以運行多個。

### Q: 連線速度慢怎麼辦？

**A**: 
- ngrok 伺服器在美國，延遲較高是正常的
- 可以考慮升級到付費版選擇更近的區域
- 或使用其他隧道服務如 Tailscale

### Q: 安全性如何？

**A**: 
- ngrok 使用 HTTPS/TLS 加密
- 建議設置 Minecraft 伺服器白名單
- 不要分享 authtoken 給他人
- 可以在控制台隨時撤銷 authtoken

## 🔄 升級到付費版

如果你需要更多功能，可以考慮升級：

### 付費版優勢

- **固定子域名**：不用每次都換地址
- **更多同時隧道**：可以運行多個服務
- **更多區域選擇**：降低延遲
- **更高流量限制**：適合大型伺服器
- **自訂域名**：使用你自己的域名

### 升級方式

1. 登入 ngrok 控制台
2. 點擊 "Upgrade" 或 "升級"
3. 選擇適合的方案
4. 完成付款

## 📱 手機 App

ngrok 也有手機 App，可以隨時監控隧道狀態：

- **iOS**: 在 App Store 搜索 "ngrok"
- **Android**: 在 Google Play 搜索 "ngrok"

## 🎯 快速開始

如果你想立即開始，按照以下步驟：

```bash
# 1. 註冊並綁定信用卡（完成上述步驟）

# 2. 運行自動設置腳本
```bash
# 2. 運行自動設置腳本
./scripts/remote-connect-ngrok.sh
```

# 3. 輸入你的 authtoken

# 4. 隧道建立後，分享地址給朋友
```

完成設置後，你就可以和朋友一起享受 Minecraft 了！🎮

---

**注意**: 請妥善保管你的 ngrok authtoken，不要分享給他人。如有安全疑慮，可隨時在控制台重新生成。
