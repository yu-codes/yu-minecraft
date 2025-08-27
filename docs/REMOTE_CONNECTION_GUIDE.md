# 🌐 遠端連線部署方案指南

提供多種 Minecraft 伺服器部署方案，適合不同需求和技術水平的用戶。

## � 完整方案比較

| 方案 | 成本 | 設定難度 | 穩定性 | 效能 | 維護 | 適用場景 |
|------|------|----------|--------|------|------|----------|
| **Oracle Cloud** | ⭐⭐⭐⭐⭐ 永久免費 | ⭐⭐ 中等 | ⭐⭐⭐⭐⭐ 最高 | ⭐⭐⭐⭐⭐ 最高 | ⭐⭐ 中等 | 長期運行，24/7 |
| **AWS EC2** | ⭐⭐⭐ 12個月免費 | ⭐⭐⭐ 中等 | ⭐⭐⭐⭐⭐ 最高 | ⭐⭐⭐⭐⭐ 最高 | ⭐⭐ 中等 | 企業級部署 |
| **Tailscale** | ⭐⭐⭐⭐ 免費 | ⭐⭐⭐⭐ 簡單 | ⭐⭐⭐⭐⭐ 最高 | ⭐⭐⭐⭐ 高 | ⭐⭐⭐⭐ 簡單 | 私人朋友圈 |
| **ngrok** | ⭐⭐ 免費+限制 | ⭐⭐⭐⭐⭐ 最簡單 | ⭐⭐ 低 | ⭐⭐⭐⭐ 高 | ⭐⭐⭐⭐ 簡單 | 臨時測試 |
| **Playit.gg** | ⭐⭐⭐⭐ 免費 | ⭐⭐⭐⭐ 簡單 | ⭐⭐⭐ 中等 | ⭐⭐⭐ 中等 | ⭐⭐⭐⭐ 簡單 | 快速分享 |
| **本地部署** | ⭐⭐⭐⭐⭐ 免費 | ⭐⭐⭐⭐⭐ 最簡單 | ⭐⭐⭐ 中等 | ⭐⭐⭐⭐⭐ 最高 | ⭐⭐⭐ 中等 | 開發測試 |

## 🥇 推薦方案：Oracle Cloud

### 優勢
- **永久免費**：無需信用卡付費（僅驗證用）
- **高效能**：ARM 處理器，4 核心 + 24GB RAM
- **24/7 運行**：不需要保持電腦開機
- **固定 IP**：不會頻繁變更地址
- **企業級**：Oracle 企業級雲端基礎設施

### 部署指令
```bash
./scripts/remote-connect-oracle.sh
```

### 詳細指南
完整設置說明請參考：[ORACLE_CLOUD_GUIDE.md](./ORACLE_CLOUD_GUIDE.md)

## 🥈 替代雲端方案：AWS EC2

### 優勢
- **穩定可靠**：AWS 全球領先的雲端服務
- **12個月免費**：t2.micro 實例免費使用
- **豐富工具**：完整的監控和管理功能
- **彈性擴展**：隨時升級實例規格

### 部署指南
詳細設置說明請參考：[AWS_DEPLOYMENT_GUIDE.md](./AWS_DEPLOYMENT_GUIDE.md)

## 🔒 最安全方案：Tailscale

### 優勢
- **完全私密**：VPN 加密連線
- **無需公網 IP**：不用修改路由器設定
- **連線穩定**：不會斷線重連
- **跨平台支援**：支援所有主要平台

### 自動設置
```bash
./scripts/remote-connect-tailscale.sh
```

### 手動設置步驟

1. **所有人安裝 Tailscale**：
   - 下載：https://tailscale.com/download
   - 支援 Windows、Mac、Linux、手機

2. **使用相同帳號登入**：
   - 可以用 Google、Microsoft 或 GitHub 帳號
   - 所有玩家登入同一個帳號

3. **查看 Tailscale IP**：
   ```bash
   tailscale ip -4
   ```

4. **分享連線地址**：
   - 格式：`你的Tailscale IP:25565`
   - 例如：`100.64.0.1:25565`

## ⚡ 最快方案：ngrok

### 優勢
- **設置最簡單**：幾分鐘內完成
- **無需技術知識**：適合新手
- **即開即用**：立即建立公網連線

### 限制
- **免費版限制**：每 2 小時需重新啟動
- **隨機地址**：每次重啟會變更網址
- **連線不穩**：可能會突然斷線

### 自動設置
```bash
./scripts/remote-connect-ngrok.sh
```

### 手動設置步驟

1. **註冊 ngrok**：
   - 訪問：https://ngrok.com/signup
   - 免費註冊帳號

2. **安裝 ngrok**：
   ```bash
   # macOS
   brew install ngrok/ngrok/ngrok
   
   # 或下載：https://ngrok.com/download
   ```

3. **設置認證**：
   ```bash
   ngrok config add-authtoken <你的authtoken>
   ```

4. **啟動隧道**：
   ```bash
   ngrok tcp 25565
   ```

## 🎯 簡單方案：Playit.gg

### 優勢
- **免費使用**：無時間限制
- **簡單設置**：網頁介面操作
- **無需註冊雲端**：不用申請雲端帳號

### 自動設置
```bash
./scripts/remote-connect-playit.sh
```

### 手動設置步驟

1. **訪問 Playit.gg**：
   - 網址：https://playit.gg
   - 無需註冊

2. **下載客戶端**：
   - 支援多平台

3. **建立隧道**：
   - 選擇 Minecraft
   - 設定本地埠 25565

## 🏠 本地部署方案

### 適用情況
- 開發測試
- 本地網路遊戲
- 學習 Docker

### 部署指令
```bash
# 直接本地啟動
docker-compose up -d

# 查看狀態
docker-compose ps

# 連線地址
localhost:25565
```

## �️ 統一部署助手

使用統一的部署腳本，輕鬆選擇最適合的方案：

```bash
./scripts/deploy.sh
```

選單包含：
1. Oracle Cloud - 永久免費雲端（推薦）
2. AWS EC2 - 12個月免費雲端
3. Tailscale - 私人網路連線
4. ngrok - 臨時公網連線
5. Playit.gg - 簡單免費方案
6. 本地部署 - Docker 本地運行

## 💡 選擇建議

### 長期運行（推薦）
1. **Oracle Cloud** - 永久免費，最佳選擇
2. **AWS** - 企業級穩定性
3. **Tailscale** - 私人朋友圈

### 臨時測試
1. **ngrok** - 最快上手
2. **Playit.gg** - 簡單免費
3. **本地部署** - 開發學習

### 技術水平考量
- **新手**：ngrok → Playit.gg → Tailscale
- **進階**：Tailscale → Oracle Cloud → AWS
- **專家**：Oracle Cloud → AWS → 自建

## 🔧 故障排除

### 連線問題
```bash
# 檢查服務狀態
docker-compose ps

# 查看日誌
docker-compose logs minecraft

# 測試本地連線
telnet localhost 25565
```

### 防火牆設置
```bash
# 檢查埠口是否開放
netstat -an | grep 25565

# Linux 開放埠口
sudo ufw allow 25565
```

### 效能監控
```bash
# 系統資源
htop

# Docker 資源
docker stats

# 伺服器效能
./scripts/performance.sh report
```

選擇最適合你需求的方案，開始你的 Minecraft 伺服器之旅！�
