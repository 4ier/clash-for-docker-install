#!/bin/bash
source ./script/common.sh
source ./script/clashctl.sh

_valid_env

[ ! -d "$CLASH_BASE_PATH" ] && echo "😾 未安装或已卸载,开始自动清理相关配置..."

clashoff >/dev/null 2>&1

systemctl disable clash >/dev/null 2>&1
rm -f /etc/systemd/system/clash.service
systemctl daemon-reload

rm -rf "$CLASH_BASE_PATH"
sed -i '/clashupdate/d' "$CLASH_CRONTAB_TARGET_PATH"
echo '😼 已卸载，相关配置已清除'
# 未 export 的变量和函数不会被继承
sed -i '/clashctl.sh/d' /etc/bashrc && exec bash
