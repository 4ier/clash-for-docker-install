#!/bin/sh

echo "Starting Clash Docker..."

# Create directories
mkdir -p /opt/clash

# Check if config exists
if [ ! -f "/opt/clash/config.yaml" ]; then
    echo "No config found. Trying to download from URL..."
    if [ -n "$CLASH_URL" ]; then
        wget -O /opt/clash/config.yaml "$CLASH_URL" || echo "Download failed"
    fi
fi

# Final check
if [ ! -f "/opt/clash/config.yaml" ]; then
    echo "ERROR: No config file found!"
    echo "Please provide config via CLASH_URL or mount /opt/clash/config.yaml"
    exit 1
fi

# Copy runtime config
cp /opt/clash/config.yaml /opt/clash/runtime.yaml

# Set secret if provided
if [ -n "$CLASH_SECRET" ] && [ -x "/opt/clash/bin/yq" ]; then
    /opt/clash/bin/yq -i ".secret = \"$CLASH_SECRET\"" /opt/clash/runtime.yaml || echo "Failed to set secret"
fi

# Set external controller
if [ -x "/opt/clash/bin/yq" ]; then
    /opt/clash/bin/yq -i '.external-controller = "0.0.0.0:9090"' /opt/clash/runtime.yaml || echo "Failed to set controller"
fi

echo "Starting mihomo..."
echo "Web UI: http://localhost:9090/ui"
if [ -n "$CLASH_SECRET" ]; then
    echo "Secret: $CLASH_SECRET"
fi

# Start mihomo
exec /opt/clash/bin/mihomo -d /opt/clash -f /opt/clash/runtime.yaml