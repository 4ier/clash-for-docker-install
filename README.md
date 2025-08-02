# Linux 一键安装 Clash

![GitHub License](https://img.shields.io/github/license/nelvko/clash-for-linux-install)
![GitHub top language](https://img.shields.io/github/languages/top/nelvko/clash-for-linux-install)
![GitHub Repo stars](https://img.shields.io/github/stars/nelvko/clash-for-linux-install)

![preview](resources/preview.png)

- 默认安装 `mihomo` 内核，[可选安装](https://github.com/nelvko/clash-for-linux-install/wiki/FAQ#%E5%AE%89%E8%A3%85-clash-%E5%86%85%E6%A0%B8) `clash`。
- 自动使用 [subconverter](https://github.com/tindy2013/subconverter) 进行本地订阅转换。
- 多架构支持，适配主流 `Linux` 发行版：`CentOS 7.6`、`Debian 12`、`Ubuntu 24.04.1 LTS`。
- 🐳 **新增 Docker 支持**：一键部署，支持普通模式和 Tun 模式。

## 快速开始

### 🐳 Docker 部署 (推荐)

#### 环境要求

- Docker 20.10+
- Docker Compose 2.0+

#### 基本使用

```bash
# 克隆项目
git clone --branch master --depth 1 https://gh-proxy.com/https://github.com/nelvko/clash-for-linux-install.git
cd clash-for-linux-install

# 复制环境变量模板
cp .env.example .env

# 编辑配置文件，设置订阅链接
vim .env
# 设置 CLASH_URL=https://your-subscription-url

# 启动服务
docker-compose up -d
```

#### 快速启动命令

```bash
# 一键启动 (请替换为您的订阅链接)
CLASH_URL="https://your-subscription-url" \
CLASH_SECRET="your-secret" \
docker-compose up -d
```

#### Tun 模式部署

```bash
# 使用专用的 Tun 模式配置
CLASH_URL="https://your-subscription-url" \
docker-compose -f docker-compose.tun.yml up -d
```

#### 服务管理

```bash
# 查看状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 重启服务
docker-compose restart

# 停止服务
docker-compose down

# 更新配置后重启
docker-compose down && docker-compose up -d
```

#### 访问控制台

- Web 控制台：http://localhost:9090/ui
- 代理端口：
  - HTTP: 7890
  - SOCKS5: 7891  
  - 混合代理: 7892

#### 环境变量说明

| 变量名 | 说明 | 默认值 | 示例 |
|--------|------|--------|------|
| `CLASH_URL` | 订阅链接 (必填) | - | `https://example.com/sub` |
| `CLASH_SECRET` | Web控制台密钥 | 空 | `your-random-secret` |
| `CLASH_LOG_LEVEL` | 日志级别 | `info` | `warning`, `debug` |
| `TZ` | 时区 | `Asia/Shanghai` | `UTC` |

### 📦 传统安装

#### 环境要求

- 用户权限：`root`、`sudo`。（无权限可参考：[#91](https://github.com/nelvko/clash-for-linux-install/issues/91)）
- `shell` 支持：`bash`、`zsh`、`fish`。

#### 一键安装

下述命令适用于 `x86_64` 架构，其他架构请戳：[一键安装-多架构](https://github.com/nelvko/clash-for-linux-install/wiki#%E4%B8%80%E9%94%AE%E5%AE%89%E8%A3%85-%E5%A4%9A%E6%9E%B6%E6%9E%84)

```bash
git clone --branch master --depth 1 https://gh-proxy.com/https://github.com/nelvko/clash-for-linux-install.git \
  && cd clash-for-linux-install \
  && sudo bash install.sh
```

> 如遇问题，请在查阅[常见问题](https://github.com/nelvko/clash-for-linux-install/wiki/FAQ)及 [issue](https://github.com/nelvko/clash-for-linux-install/issues?q=is%3Aissue) 未果后进行反馈。

- 上述克隆命令使用了[加速前缀](https://gh-proxy.com/)，如失效请更换其他[可用链接](https://ghproxy.link/)。
- 默认通过远程订阅获取配置进行安装，本地配置安装详见：[#39](https://github.com/nelvko/clash-for-linux-install/issues/39)
- 没有订阅？[click me](https://次元.net/auth/register?code=oUbI)

### 命令一览

执行 `clashctl` 列出开箱即用的快捷命令。

> 同 `clash`、`mihomo`、`mihomoctl`

```bash
$ clashctl
Usage:
    clash     COMMAND [OPTION]
    
Commands:
    on                   开启代理
    off                  关闭代理
    ui                   面板地址
    status               内核状况
    proxy    [on|off]    系统代理
    tun      [on|off]    Tun 模式
    mixin    [-e|-r]     Mixin 配置
    secret   [SECRET]    Web 密钥
    update   [auto|log]  更新订阅
```

### 优雅启停

```bash
$ clashon
😼 已开启代理环境

$ clashoff
😼 已关闭代理环境
```
- 启停代理内核的同时，设置系统代理。
- 亦可通过 `clashproxy` 单独控制系统代理。

### Web 控制台

```bash
$ clashui
╔═══════════════════════════════════════════════╗
║                😼 Web 控制台                  ║
║═══════════════════════════════════════════════║
║                                               ║
║     🔓 注意放行端口：9090                      ║
║     🏠 内网：http://192.168.0.1:9090/ui       ║
║     🌏 公网：http://255.255.255.255:9090/ui   ║
║     ☁️ 公共：http://board.zash.run.place      ║
║                                               ║
╚═══════════════════════════════════════════════╝

$ clashsecret 666
😼 密钥更新成功，已重启生效

$ clashsecret
😼 当前密钥：666
```

- 通过浏览器打开 Web 控制台，实现可视化操作：切换节点、查看日志等。
- 控制台密钥默认为空，若暴露到公网使用建议更新密钥。

### 更新订阅

```bash
$ clashupdate https://example.com
👌 正在下载：原配置已备份...
🍃 下载成功：内核验证配置...
🍃 订阅更新成功

$ clashupdate auto [url]
😼 已设置定时更新订阅

$ clashupdate log
✅ [2025-02-23 22:45:23] 订阅更新成功：https://example.com
```

- `clashupdate` 会记住上次更新成功的订阅链接，后续执行无需再指定。
- 可通过 `crontab -e` 修改定时更新频率及订阅链接。
- 通过配置文件进行更新：[pr#24](https://github.com/nelvko/clash-for-linux-install/pull/24#issuecomment-2565054701)

### `Tun` 模式

```bash
$ clashtun
😾 Tun 状态：关闭

$ clashtun on
😼 Tun 模式已开启
```

- 作用：实现本机及 `Docker` 等容器的所有流量路由到 `clash` 代理、DNS 劫持等。
- 原理：[clash-verge-rev](https://www.clashverge.dev/guide/term.html#tun)、 [clash.wiki](https://clash.wiki/premium/tun-device.html)。
- 注意事项：[#100](https://github.com/nelvko/clash-for-linux-install/issues/100#issuecomment-2782680205)

### `Mixin` 配置

```bash
$ clashmixin
😼 less 查看 mixin 配置

$ clashmixin -e
😼 vim 编辑 mixin 配置

$ clashmixin -r
😼 less 查看 运行时 配置
```

- 持久化：将自定义配置写在 `Mixin` 而不是原配置中，可避免更新订阅后丢失自定义配置。
- 运行时配置是订阅配置和 `Mixin` 配置的并集。
- 相同配置项优先级：`Mixin` 配置 > 订阅配置。

### 卸载

```bash
sudo bash uninstall.sh
```

## 🐳 Docker 常见问题

### 启动问题

**Q: 容器启动失败，提示配置无效**
```bash
# 检查环境变量是否正确设置
docker-compose config

# 查看详细错误日志
docker-compose logs
```

**Q: 无法访问Web控制台**
```bash
# 检查端口是否被占用
netstat -tulpn | grep 9090

# 确保防火墙允许访问
sudo ufw allow 9090
```

### Tun模式问题

**Q: Tun模式启动失败**
```bash
# 确保有足够权限
docker-compose -f docker-compose.tun.yml up -d

# 检查内核模块
modprobe tun
```

**Q: Docker容器中无法使用代理**
- Tun模式下Docker容器会自动路由
- 普通模式需要在容器中设置代理环境变量

### 配置更新

**Q: 如何更新订阅配置**
```bash
# 重启容器会自动重新下载订阅
docker-compose restart

# 或者设置新的订阅链接
CLASH_URL="new-subscription-url" docker-compose up -d
```

**Q: 如何自定义配置**
```bash
# 挂载自定义配置目录
# 在docker-compose.yml中添加：
# volumes:
#   - ./config:/opt/clash
```

### 数据备份

**Q: 如何备份配置数据**
```bash
# 备份Docker卷
docker run --rm -v clash-data:/data -v $(pwd):/backup alpine tar czf /backup/clash-backup.tar.gz -C /data .

# 恢复数据
docker run --rm -v clash-data:/data -v $(pwd):/backup alpine tar xzf /backup/clash-backup.tar.gz -C /data
```

## 常见问题

[wiki](https://github.com/nelvko/clash-for-linux-install/wiki/FAQ)

## 引用

- [Clash 知识库](https://clash.wiki/)
- [Clash 家族下载](https://www.clash.la/releases/)
- [Clash Premium 2023.08.17](https://downloads.clash.wiki/ClashPremium/)
- [mihomo v1.19.2](https://github.com/MetaCubeX/mihomo)
- [subconverter v0.9.0：本地订阅转换](https://github.com/tindy2013/subconverter)
- [yacd v0.3.8：Web 控制台](https://github.com/haishanh/yacd)
- [yq v4.45.1：处理 yaml](https://github.com/mikefarah/yq)

## Star History

<a href="https://www.star-history.com/#nelvko/clash-for-linux-install&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=nelvko/clash-for-linux-install&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=nelvko/clash-for-linux-install&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=nelvko/clash-for-linux-install&type=Date" />
 </picture>
</a>

## Thanks

[@鑫哥](https://github.com/TrackRay)

## 特别声明

1. 编写本项目主要目的为学习和研究 `Shell` 编程，不得将本项目中任何内容用于违反国家/地区/组织等的法律法规或相关规定的其他用途。
2. 本项目保留随时对免责声明进行补充或更改的权利，直接或间接使用本项目内容的个人或组织，视为接受本项目的特别声明。
