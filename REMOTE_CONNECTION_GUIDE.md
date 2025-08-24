# 🌐 無法修改路由器？外網連線替代方案

如果你無法修改路由器設定（學校宿舍、公司網路、租屋等），這裡提供多種解決方案。

## 🚀 推薦方案比較

| 方案 | 難度 | 穩定性 | 費用 | 適合場景 |
|------|------|--------|------|----------|
| **ngrok** | ⭐ | ⭐⭐ | 免費/付費 | 快速測試、臨時遊戲 |
| **Tailscale** | ⭐⭐ | ⭐⭐⭐⭐⭐ | 免費 | 長期使用、多人遊戲 |
| **雲端伺服器** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 免費/付費 | 24/7 運行、大型社群 |

## 🎯 方案一：ngrok（最簡單）

### 自動設置

```bash
# 一鍵設置，腳本會自動處理所有步驟
./scripts/remote-connect-ngrok.sh
```

### 手動設置

1. **註冊 ngrok**：
   - 訪問：https://ngrok.com/signup
   - 免費註冊帳號

2. **安裝 ngrok**：

   ```bash
   # macOS (推薦)
   brew install ngrok/ngrok/ngrok
   
   # 或下載：https://ngrok.com/download
   ```

3. **設置認證**：

   ```bash
   # 在 ngrok 網站取得 authtoken
   ngrok config add-authtoken <你的authtoken>
   ```

4. **啟動隧道**：

   ```bash
   # 建立隧道到你的 Minecraft 伺服器
   ngrok tcp 25565
   ```

5. **分享連線地址**：
   - ngrok 會顯示：`tcp://0.tcp.ngrok.io:12345`
   - 將此地址給朋友連線

### ngrok 限制

- 🔄 免費版每 2 小時需重新啟動
- 🎲 每次重啟會得到新的隨機網址
- 💰 付費版可以使用固定網址

---

## 🔒 方案二：Tailscale（最推薦）

### 自動設置

```bash
# 一鍵設置，腳本會自動處理所有步驟
./scripts/remote-connect-tailscale.sh
```

### 手動設置

1. **所有人安裝 Tailscale**：
   - 你和朋友都需要安裝
   - 下載：https://tailscale.com/download

2. **使用相同帳號登入**：
   - 可以用 Google、Microsoft 或 GitHub 帳號
   - 所有人登入同一個帳號

3. **查看你的 Tailscale IP**：

   ```bash
   tailscale ip -4
   ```

4. **朋友連線方式**：
   - 地址：`你的Tailscale IP:25565`
   - 例如：`100.64.0.1:25565`

### Tailscale 優點

- 🔐 完全私密和安全（VPN）
- 🔄 連線穩定，不會斷線
- 🆓 完全免費（100 台設備內）
- 🌐 跨平台支援（Windows、Mac、手機）

---

## ☁️ 方案三：雲端伺服器（24/7 運行）

適合想要伺服器 24 小時運行的用戶。

### 免費雲端選項

1. **Oracle Cloud Always Free**：
   - 永久免費
   - 1GB RAM VM
   - 註冊：https://cloud.oracle.com

2. **Google Cloud Platform**：
   - 300 美元免費額度
   - 註冊：https://cloud.google.com

3. **AWS Free Tier**：
   - 12 個月免費
   - t2.micro 執行個體
   - 註冊：https://aws.amazon.com

### 部署到雲端

```bash
# 在雲端伺服器上執行
git clone https://github.com/yu-codes/yu-minecraft.git
cd yu-minecraft
docker compose -f docker/docker-compose.yml up -d
```

---

## 🔍 方案四：其他選項

### 使用 Hamachi

1. 下載 LogMeIn Hamachi
2. 建立網路，邀請朋友加入
3. 使用 Hamachi IP 連線

### 使用 Radmin VPN

1. 下載 Radmin VPN（完全免費）
2. 建立網路，邀請朋友
3. 使用虛擬 IP 連線

---

## 🎮 開始遊戲

選擇任一方案設置完成後：

1. **確認伺服器運行**：

   ```bash
   docker compose -f docker/docker-compose.yml ps
   ```

2. **查看伺服器記錄**：

   ```bash
   docker compose -f docker/docker-compose.yml logs minecraft
   ```

3. **給朋友連線地址**，例如：
   - ngrok: `0.tcp.ngrok.io:12345`
   - Tailscale: `100.64.0.1:25565`
   - 雲端: `雲端伺服器IP:25565`

## 💡 小技巧

- **測試連線**：你可以先用 `localhost:25565` 測試本地連線
- **查看玩家**：在伺服器控制台輸入 `list` 查看線上玩家
- **備份世界**：定期執行 `./scripts/backup.sh` 備份遊戲資料
- **效能監控**：使用 `./scripts/monitor.sh` 監控伺服器效能

選擇最適合你的方案，開始和朋友一起玩 Minecraft 吧！🎉
