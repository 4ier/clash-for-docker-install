#!/bin/bash
set -e

# 导入通用函数
. /app/script/common.sh >&/dev/null
. /app/script/clashctl.sh >&/dev/null

# 初始化环境变量
CLASH_URL=${CLASH_URL:-""}
CLASH_SECRET=${CLASH_SECRET:-""}
CLASH_LOG_LEVEL=${CLASH_LOG_LEVEL:-"info"}

# 如果clash目录为空，执行初始化安装
if [ ! -f "/opt/clash/config.yaml" ] && [ ! -f "/opt/clash/runtime.yaml" ]; then
    echo "🐳 初始化Clash Docker环境..."
    
    # 设置环境变量，跳过systemd相关操作
    export DOCKER_MODE=true
    
    # 解压二进制文件
    mkdir -p /opt/clash/bin
    /usr/bin/install -D <(gzip -dc "$ZIP_MIHOMO") "/opt/clash/bin/mihomo"
    tar -xf "$ZIP_SUBCONVERTER" -C "/opt/clash/bin"
    tar -xf "$ZIP_YQ" -C "/opt/clash/bin"
    mv /opt/clash/bin/yq_* "/opt/clash/bin/yq"
    
    # 复制脚本和资源
    cp -rf script /opt/clash/
    cp -f resources/mixin.yaml /opt/clash/
    cp -f resources/Country.mmdb /opt/clash/
    tar -xf "$ZIP_UI" -C /opt/clash/
    
    # 设置权限
    chmod +x /opt/clash/bin/*
    
    echo "✅ Clash Docker环境初始化完成"
fi

# 更新配置
cd /opt/clash

# 如果提供了订阅链接，下载配置
if [ -n "$CLASH_URL" ]; then
    echo "📥 下载订阅配置: $CLASH_URL"
    echo "$CLASH_URL" > /opt/clash/url
    
    # 使用subconverter转换配置
    /opt/clash/bin/subconverter -g &
    sleep 2
    
    # 下载配置
    curl -fsSL "$CLASH_URL" -o /opt/clash/config.yaml.tmp
    
    # 转换配置
    curl -fsSL "http://127.0.0.1:25500/sub?target=clash&url=$(echo $CLASH_URL | sed 's/:/%3A/g; s/\//%2F/g')" -o /opt/clash/config.yaml
    
    # 停止subconverter
    pkill subconverter || true
    
    echo "✅ 订阅配置下载完成"
fi

# 检查配置文件
if [ ! -f "/opt/clash/config.yaml" ]; then
    echo "❌ 未找到配置文件，请挂载配置文件到 /opt/clash/config.yaml 或设置 CLASH_URL 环境变量"
    exit 1
fi

# 合并mixin配置
if [ -f "/opt/clash/mixin.yaml" ]; then
    /opt/clash/bin/yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' /opt/clash/config.yaml /opt/clash/mixin.yaml > /opt/clash/runtime.yaml
else
    cp /opt/clash/config.yaml /opt/clash/runtime.yaml
fi

# 更新Web控制台密钥
if [ -n "$CLASH_SECRET" ]; then
    /opt/clash/bin/yq -i ".secret = \"$CLASH_SECRET\"" /opt/clash/mixin.yaml
    echo "🔐 Web控制台密钥已设置"
fi

# 确保external-controller监听所有接口
/opt/clash/bin/yq -i '.external-controller = "0.0.0.0:9090"' /opt/clash/mixin.yaml

# 重新合并配置
/opt/clash/bin/yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' /opt/clash/config.yaml /opt/clash/mixin.yaml > /opt/clash/runtime.yaml

echo "🚀 启动Clash服务..."
echo "📊 Web控制台: http://localhost:9090/ui"
if [ -n "$CLASH_SECRET" ]; then
    echo "🔑 控制台密钥: $CLASH_SECRET"
fi

# 启动mihomo
exec /opt/clash/bin/mihomo -d /opt/clash -f /opt/clash/runtime.yaml