#!/bin/bash

# Oracle Cloud 設置腳本 - 雲端伺服器部署方案
# 使用 Oracle Cloud 免費服務，部署 Minecraft 伺服器到雲端

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}☁️  Minecraft 伺服器 Oracle Cloud 部署助手${NC}"
echo "================================================="

echo -e "${BLUE}🎯 Oracle Cloud 優勢：${NC}"
echo "- 永久免費的雲端伺服器 (24/7 運行)"
echo "- 1-4 個 ARM CPU 核心"
echo "- 6-24GB RAM"
echo "- 最多 4 個永遠免費的實例"
echo "- 固定公網 IP"
echo "- 不需要修改家用路由器"
echo

# 檢查必要工具
echo -e "${YELLOW}🔍 檢查必要工具...${NC}"

# 檢查 OCI CLI
if ! command -v oci &> /dev/null; then
    echo -e "${YELLOW}⚠️  Oracle Cloud CLI 尚未安裝${NC}"
    echo
    echo "安裝方式："
    echo "1. 使用 pip 安裝 (推薦)"
    echo "2. 手動下載安裝"
    echo
    read -p "請選擇 (1 或 2): " choice
    
    case $choice in
        1)
            if command -v python3 &> /dev/null; then
                echo -e "${GREEN}📦 使用 pip 安裝 OCI CLI...${NC}"
                pip3 install oci-cli
            else
                echo -e "${RED}❌ 未找到 Python3，請先安裝 Python3${NC}"
                exit 1
            fi
            ;;
        2)
            echo -e "${YELLOW}📥 手動安裝 OCI CLI:${NC}"
            echo "1. 訪問: https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm"
            echo "2. 下載適合你系統的版本"
            echo "3. 按照指示安裝"
            echo
            read -p "完成安裝後按 Enter 繼續..."
            ;;
        *)
            echo -e "${RED}❌ 無效選擇${NC}"
            exit 1
            ;;
    esac
fi

# 檢查 Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker 未安裝，此腳本需要 Docker${NC}"
    echo "請先安裝 Docker Desktop"
    exit 1
fi

echo
echo -e "${GREEN}📋 Oracle Cloud 設置步驟${NC}"
echo "============================="

echo -e "${BLUE}步驟 1: 建立 Oracle Cloud 帳號${NC}"
echo "1. 訪問: https://cloud.oracle.com/zh_TW/"
echo "2. 點擊「開始免費使用」"
echo "3. 填寫基本資料（需要信用卡驗證，但不會扣款）"
echo "4. 完成電話驗證"
echo "5. 取得 $300 美金試用額度 + 永久免費服務"
echo
read -p "完成註冊後按 Enter 繼續..."

echo
echo -e "${BLUE}步驟 2: 設定 OCI CLI${NC}"
echo "1. 在 Oracle Cloud 控制台，點擊右上角個人資料"
echo "2. 選擇「使用者設定」→ 「API 金鑰」"
echo "3. 點擊「新增 API 金鑰」"
echo "4. 選擇「產生 API 金鑰配對」"
echo "5. 下載私密金鑰檔案"
echo
read -p "是否已完成 API 金鑰設定？ (y/n): " api_setup

if [[ ! $api_setup =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}⚠️  請先完成 API 金鑰設定${NC}"
    exit 1
fi

echo
echo -e "${GREEN}🔧 設定 OCI CLI 設定檔...${NC}"
if [ ! -f "$HOME/.oci/config" ]; then
    echo "執行 OCI CLI 設定..."
    oci setup config
else
    echo -e "${GREEN}✅ OCI CLI 設定檔已存在${NC}"
fi

echo
echo -e "${BLUE}步驟 3: 建立雲端實例${NC}"
echo "建議設定："
echo "- 作業系統: Ubuntu 22.04"
echo "- 形狀: VM.Standard.A1.Flex (ARM)"
echo "- CPU: 4 核心"
echo "- 記憶體: 24GB"
echo "- 儲存: 100GB"
echo

read -p "是否要使用自動化腳本建立實例？ (y/n): " auto_create

if [[ $auto_create =~ ^[Yy]$ ]]; then
    # 取得必要資訊
    echo
    echo -e "${YELLOW}📝 請提供以下資訊：${NC}"
    
    # 列出可用區域
    echo "取得可用區域..."
    oci iam availability-domain list --compartment-id $(oci iam compartment list --query 'data[0].id' --raw-output)
    
    read -p "請輸入可用區域名稱 (例: uRUe:AP-TOKYO-1-AD-1): " availability_domain
    read -p "請輸入實例名稱 (例: minecraft-server): " instance_name
    read -p "請輸入 SSH 公鑰路徑 (例: ~/.ssh/id_rsa.pub): " ssh_key_path
    
    if [ ! -f "$ssh_key_path" ]; then
        echo -e "${YELLOW}⚠️  SSH 金鑰不存在，正在產生...${NC}"
        ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
        ssh_key_path="$HOME/.ssh/id_rsa.pub"
    fi
    
    # 建立實例的自動化腳本
    cat > /tmp/oracle_instance_create.json << EOF
{
  "availabilityDomain": "${availability_domain}",
  "compartmentId": "\$(oci iam compartment list --query 'data[0].id' --raw-output)",
  "displayName": "${instance_name}",
  "imageId": "\$(oci compute image list --compartment-id \$(oci iam compartment list --query 'data[0].id' --raw-output) --operating-system 'Canonical Ubuntu' --operating-system-version '22.04' --shape 'VM.Standard.A1.Flex' --query 'data[0].id' --raw-output)",
  "shape": "VM.Standard.A1.Flex",
  "shapeConfig": {
    "ocpus": 4,
    "memoryInGBs": 24
  },
  "sourceDetails": {
    "sourceType": "image",
    "imageId": "\$(oci compute image list --compartment-id \$(oci iam compartment list --query 'data[0].id' --raw-output) --operating-system 'Canonical Ubuntu' --operating-system-version '22.04' --shape 'VM.Standard.A1.Flex' --query 'data[0].id' --raw-output)",
    "bootVolumeSizeInGBs": 100
  },
  "createVnicDetails": {
    "assignPublicIp": true
  },
  "metadata": {
    "ssh_authorized_keys": "\$(cat ${ssh_key_path})"
  }
}
EOF

    echo -e "${GREEN}🚀 正在建立 Oracle Cloud 實例...${NC}"
    echo "這可能需要幾分鐘時間..."
    
    # 替換變數並建立實例
    eval "oci compute instance launch --from-json file:///tmp/oracle_instance_create.json" > /tmp/instance_result.json
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 實例建立成功！${NC}"
        INSTANCE_ID=$(cat /tmp/instance_result.json | jq -r '.data.id')
        echo "實例 ID: $INSTANCE_ID"
        
        # 等待實例啟動
        echo "等待實例啟動..."
        oci compute instance get --instance-id $INSTANCE_ID --wait-for-state RUNNING
        
        # 取得公網 IP
        PUBLIC_IP=$(oci compute instance list-vnics --instance-id $INSTANCE_ID --query 'data[0]."public-ip"' --raw-output)
        echo -e "${GREEN}公網 IP: ${PUBLIC_IP}${NC}"
        
        # 儲存連線資訊
        echo "INSTANCE_ID=$INSTANCE_ID" > oracle_connection_info.txt
        echo "PUBLIC_IP=$PUBLIC_IP" >> oracle_connection_info.txt
        echo "SSH_KEY=~/.ssh/id_rsa" >> oracle_connection_info.txt
        
    else
        echo -e "${RED}❌ 實例建立失敗${NC}"
        exit 1
    fi
else
    echo
    echo -e "${YELLOW}📝 手動建立實例步驟：${NC}"
    echo "1. 登入 Oracle Cloud 控制台"
    echo "2. 選擇「運算」→「執行個體」"
    echo "3. 點擊「建立執行個體」"
    echo "4. 設定實例詳細資料："
    echo "   - 名稱: minecraft-server"
    echo "   - 映像: Ubuntu 22.04"
    echo "   - 形狀: VM.Standard.A1.Flex"
    echo "   - CPU: 4 核心, RAM: 24GB"
    echo "   - SSH 金鑰: 上傳你的公鑰"
    echo "5. 點擊「建立」"
    echo
    read -p "請輸入建立好的實例公網 IP: " PUBLIC_IP
    
    # 儲存連線資訊
    echo "PUBLIC_IP=$PUBLIC_IP" > oracle_connection_info.txt
    echo "SSH_KEY=~/.ssh/id_rsa" >> oracle_connection_info.txt
fi

echo
echo -e "${BLUE}步驟 4: 設定防火牆規則${NC}"
echo "需要開放 25565 埠供 Minecraft 連線"
echo
echo "自動設定防火牆規則..."

# 取得網路安全群組
if [ ! -z "$INSTANCE_ID" ]; then
    VNIC_ID=$(oci compute instance list-vnics --instance-id $INSTANCE_ID --query 'data[0].id' --raw-output)
    SUBNET_ID=$(oci network vnic get --vnic-id $VNIC_ID --query 'data."subnet-id"' --raw-output)
    VCN_ID=$(oci network subnet get --subnet-id $SUBNET_ID --query 'data."vcn-id"' --raw-output)
    
    # 建立安全群組規則
    cat > /tmp/security_rule.json << EOF
{
  "direction": "INGRESS",
  "protocol": "6",
  "source": "0.0.0.0/0",
  "tcpOptions": {
    "destinationPortRange": {
      "min": 25565,
      "max": 25565
    }
  }
}
EOF

    # 取得預設安全清單
    SECURITY_LIST_ID=$(oci network security-list list --compartment-id $(oci iam compartment list --query 'data[0].id' --raw-output) --vcn-id $VCN_ID --query 'data[0].id' --raw-output)
    
    echo "新增防火牆規則到安全清單..."
    oci network security-list update --security-list-id $SECURITY_LIST_ID --ingress-security-rules file:///tmp/security_rule.json
fi

echo
echo -e "${BLUE}步驟 5: 部署 Minecraft 伺服器${NC}"
echo "建立部署腳本..."

# 建立遠端部署腳本
cat > /tmp/deploy_minecraft.sh << 'EOF'
#!/bin/bash

# 更新系統
sudo apt update && sudo apt upgrade -y

# 安裝 Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker ubuntu

# 安裝 Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 建立專案目錄
mkdir -p ~/minecraft-server/config
cd ~/minecraft-server

# 建立 docker-compose.yml
cat > docker-compose.yml << 'COMPOSE_EOF'
version: '3.8'

services:
  minecraft:
    image: itzg/minecraft-server:latest
    container_name: minecraft-server
    restart: unless-stopped
    ports:
      - "25565:25565"
    environment:
      EULA: "TRUE"
      TYPE: "PAPER"
      VERSION: "1.21"
      MEMORY: "20G"
      MAX_PLAYERS: "20"
      DIFFICULTY: "normal"
      WHITELIST: "false"
      MOTD: "Oracle Cloud Minecraft Server"
      ONLINE_MODE: "true"
      ENABLE_RCON: "true"
      RCON_PASSWORD: "minecraft123"
    volumes:
      - ./data:/data
      - ./config:/config
    healthcheck:
      test: ["CMD", "mc-monitor", "status", "--host", "localhost", "--port", "25565"]
      interval: 30s
      timeout: 10s
      retries: 3

  # 監控和管理
  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    restart: unless-stopped
    ports:
      - "9000:9000"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data

volumes:
  portainer_data:
COMPOSE_EOF

# 建立備份腳本
cat > backup.sh << 'BACKUP_EOF'
#!/bin/bash
BACKUP_DIR="/home/ubuntu/minecraft-backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# 停止伺服器
docker-compose down

# 建立備份
tar -czf $BACKUP_DIR/minecraft_backup_$DATE.tar.gz data/

# 重啟伺服器
docker-compose up -d

# 清理舊備份 (保留最新 7 份)
ls -t $BACKUP_DIR/minecraft_backup_*.tar.gz | tail -n +8 | xargs -r rm

echo "備份完成: minecraft_backup_$DATE.tar.gz"
BACKUP_EOF

chmod +x backup.sh

# 建立 crontab 自動備份 (每天凌晨 2 點)
(crontab -l 2>/dev/null; echo "0 2 * * * /home/ubuntu/minecraft-server/backup.sh") | crontab -

# 啟動服務
docker-compose up -d

echo "Minecraft 伺服器部署完成！"
echo "管理介面: http://$(curl -s ifconfig.me):9000"
EOF

echo "上傳並執行部署腳本..."
if [ -f "oracle_connection_info.txt" ]; then
    source oracle_connection_info.txt
    
    # 上傳部署腳本
    scp -i $SSH_KEY -o StrictHostKeyChecking=no /tmp/deploy_minecraft.sh ubuntu@$PUBLIC_IP:~/
    
    # 執行部署
    ssh -i $SSH_KEY -o StrictHostKeyChecking=no ubuntu@$PUBLIC_IP 'chmod +x ~/deploy_minecraft.sh && ~/deploy_minecraft.sh'
    
    echo
    echo -e "${GREEN}🎉 Oracle Cloud Minecraft 伺服器部署完成！${NC}"
    echo "=================================="
    echo
    echo -e "${BLUE}📋 連線資訊：${NC}"
    echo "伺服器地址: ${PUBLIC_IP}:25565"
    echo "管理介面: http://${PUBLIC_IP}:9000"
    echo
    echo -e "${BLUE}📱 管理指令：${NC}"
    echo "連線到伺服器: ssh -i $SSH_KEY ubuntu@$PUBLIC_IP"
    echo "查看日誌: docker logs minecraft-server"
    echo "重啟伺服器: docker-compose restart minecraft"
    echo "手動備份: ./backup.sh"
    echo
    echo -e "${YELLOW}💰 成本預估：${NC}"
    echo "- ARM 實例免費額度: 永久免費"
    echo "- 流量費用: 每月 10TB 免費"
    echo "- 儲存費用: 每月 100GB 免費"
    echo
    echo -e "${GREEN}✅ 24/7 全天候運行，無需保持電腦開機！${NC}"
    
else
    echo -e "${YELLOW}⚠️  請手動執行部署腳本${NC}"
    echo "1. 上傳 /tmp/deploy_minecraft.sh 到你的 Oracle Cloud 實例"
    echo "2. 執行: chmod +x deploy_minecraft.sh && ./deploy_minecraft.sh"
fi

echo
echo -e "${BLUE}🔧 進階設定建議：${NC}"
echo "1. 設定網域名稱 (可選)"
echo "2. 設定 SSL 憑證"
echo "3. 設定自動更新"
echo "4. 監控系統資源使用"
echo
echo -e "${CYAN}📚 更多資訊：${NC}"
echo "- Oracle Cloud 文件: https://docs.oracle.com/"
echo "- Minecraft Docker 映像: https://github.com/itzg/docker-minecraft-server"
echo

# 清理暫存檔案
rm -f /tmp/oracle_instance_create.json /tmp/security_rule.json /tmp/deploy_minecraft.sh

echo -e "${GREEN}🎯 Oracle Cloud 部署流程完成！${NC}"
