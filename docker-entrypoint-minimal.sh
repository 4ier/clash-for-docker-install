#!/bin/sh

echo "🐳 启动Clash Docker容器 (最小化版本)..."

# 初始化环境变量
CLASH_URL=${CLASH_URL:-""}
CLASH_SECRET=${CLASH_SECRET:-""}
CLASH_LOG_LEVEL=${CLASH_LOG_LEVEL:-"info"}

# 切换到配置目录
cd /opt/clash

# 如果提供了订阅链接且没有配置文件，尝试下载配置
if [ -n "$CLASH_URL" ] && [ ! -f "/opt/clash/config.yaml" ]; then
    echo "📥 尝试下载订阅配置: $CLASH_URL"
    echo "$CLASH_URL" > /opt/clash/url
    
    # 使用wget下载（Alpine自带）
    if command -v wget >/dev/null 2>&1; then
        wget -q -O /opt/clash/config.yaml "$CLASH_URL" || echo "⚠️ 下载失败，请手动提供配置文件"
    else
        echo "⚠️ 无法下载，请挂载配置文件到 /opt/clash/config.yaml"
    fi
fi

# 检查配置文件
if [ ! -f "/opt/clash/config.yaml" ]; then
    echo "❌ 未找到配置文件"
    echo "📝 解决方案："
    echo "   1. 设置CLASH_URL环境变量"
    echo "   2. 挂载配置文件: -v /path/to/config.yaml:/opt/clash/config.yaml"
    echo "   3. 挂载整个配置目录: -v /path/to/clash-config:/opt/clash"
    exit 1
fi

# 合并mixin配置 (如果yq可用)
if [ -f "/opt/clash/mixin.yaml" ] && [ -x "/opt/clash/bin/yq" ]; then
    /opt/clash/bin/yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' /opt/clash/config.yaml /opt/clash/mixin.yaml > /opt/clash/runtime.yaml 2>/dev/null || cp /opt/clash/config.yaml /opt/clash/runtime.yaml
else
    cp /opt/clash/config.yaml /opt/clash/runtime.yaml
fi

# 更新Web控制台密钥
if [ -n "$CLASH_SECRET" ] && [ -x "/opt/clash/bin/yq" ]; then
    /opt/clash/bin/yq -i ".secret = \"$CLASH_SECRET\"" /opt/clash/runtime.yaml 2>/dev/null || echo "⚠️ 无法设置密钥"
    echo "🔐 Web控制台密钥已设置"
fi

# 确保external-controller监听所有接口
if [ -x "/opt/clash/bin/yq" ]; then
    /opt/clash/bin/yq -i '.external-controller = "0.0.0.0:9090"' /opt/clash/runtime.yaml 2>/dev/null || echo "⚠️ 无法更新控制器配置"
fi

echo "🚀 启动Clash服务..."
echo "📊 Web控制台: http://localhost:9090/ui"
if [ -n "$CLASH_SECRET" ]; then
    echo "🔑 控制台密钥: $CLASH_SECRET"
else
    echo "🔓 控制台无密钥（建议设置CLASH_SECRET环境变量）"
fi

# 启动mihomo
exec /opt/clash/bin/mihomo -d /opt/clash -f /opt/clash/runtime.yaml