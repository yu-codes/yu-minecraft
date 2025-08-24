# 使用官方Java 17運行時作為基礎映像檔
FROM openjdk:17-jdk-slim

# 設定工作目錄
WORKDIR /minecraft

# 安裝必要的工具
RUN apt-get update && \
    apt-get install -y wget curl && \
    rm -rf /var/lib/apt/lists/*

# 建立minecraft使用者
RUN useradd -m -u 1000 minecraft && \
    chown minecraft:minecraft /minecraft

# 下載Minecraft伺服器jar檔案
ARG MC_VERSION=1.20.1
RUN wget -O server.jar https://launcher.mojang.com/v1/objects/84194a2f286ef7c14ed7ce0090dba59902951553/server.jar

# 複製配置檔案
COPY config/ ./

# 設定EULA為true
RUN echo "eula=true" > eula.txt

# 建立必要的目錄
RUN mkdir -p world plugins logs

# 設定檔案權限
RUN chown -R minecraft:minecraft /minecraft

# 切換到minecraft使用者
USER minecraft

# 暴露Minecraft伺服器埠號
EXPOSE 25565

# 暴露RCON埠號（用於遠端管理）
EXPOSE 25575

# 設定JVM參數和啟動指令
ENV JAVA_OPTS="-Xmx2G -Xms1G -XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -XX:MaxGCPauseMillis=100 -XX:+DisableExplicitGC -XX:TargetSurvivorRatio=90 -XX:G1NewSizePercent=50 -XX:G1MaxNewSizePercent=80 -XX:G1MixedGCLiveThresholdPercent=35 -XX:+AlwaysPreTouch -XX:+ParallelRefProcEnabled"

CMD java $JAVA_OPTS -jar server.jar nogui
