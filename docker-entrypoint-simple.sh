#!/bin/bash
set -e

echo "🐳 启动Clash Docker容器..."

# 初始化环境变量
CLASH_URL=${CLASH_URL:-""}
CLASH_SECRET=${CLASH_SECRET:-""}
CLASH_LOG_LEVEL=${CLASH_LOG_LEVEL:-"info"}

# 切换到配置目录
cd /opt/clash

# 如果提供了订阅链接且没有配置文件，下载配置
if [ -n "$CLASH_URL" ] && [ ! -f "/opt/clash/config.yaml" ]; then
    echo "📥 下载订阅配置: $CLASH_URL"
    echo "$CLASH_URL" > /opt/clash/url
    
    # 简化：直接下载订阅内容（如果有wget/curl）
    if command -v wget >/dev/null 2>&1; then
        wget -O /opt/clash/config.yaml "$CLASH_URL" || echo "⚠️ 下载失败，请手动提供配置文件"
    elif command -v curl >/dev/null 2>&1; then
        curl -fsSL -o /opt/clash/config.yaml "$CLASH_URL" || echo "⚠️ 下载失败，请手动提供配置文件"
    else
        echo "⚠️ 没有下载工具，请挂载配置文件到 /opt/clash/config.yaml"
    fi
fi

# 检查配置文件
if [ ! -f "/opt/clash/config.yaml" ]; then
    echo "❌ 未找到配置文件，请挂载配置文件到 /opt/clash/config.yaml 或设置 CLASH_URL 环境变量"
    echo "📝 您可以挂载配置: -v /path/to/config.yaml:/opt/clash/config.yaml"
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
    /opt/clash/bin/yq -i ".secret = \"$CLASH_SECRET\"" /opt/clash/runtime.yaml
    echo "🔐 Web控制台密钥已设置"
fi

# 确保external-controller监听所有接口
/opt/clash/bin/yq -i '.external-controller = "0.0.0.0:9090"' /opt/clash/runtime.yaml

echo "🚀 启动Clash服务..."
echo "📊 Web控制台: http://localhost:9090/ui"
if [ -n "$CLASH_SECRET" ]; then
    echo "🔑 控制台密钥: $CLASH_SECRET"
else
    echo "🔓 控制台无密钥（建议设置CLASH_SECRET环境变量）"
fi

# 启动mihomo
exec /opt/clash/bin/mihomo -d /opt/clash -f /opt/clash/runtime.yaml