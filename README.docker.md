# Clash Docker 部署指南

本文档提供详细的 Docker 部署说明和最佳实践。

## 🚀 快速开始

### 最简单的启动方式

```bash
# 一键启动（替换为您的订阅链接）
CLASH_URL="https://your-subscription-url" docker-compose up -d
```

### 完整部署流程

```bash
# 1. 克隆项目
git clone https://github.com/your-repo/clash-for-docker-install.git
cd clash-for-docker-install

# 2. 配置环境变量
cp .env.example .env
vim .env  # 编辑配置

# 3. 启动服务
docker-compose up -d

# 4. 检查状态
docker-compose ps
docker-compose logs -f
```

## 📁 项目结构

```
clash-for-docker-install/
├── Dockerfile                 # 主要构建文件
├── docker-compose.yml         # 标准模式配置
├── docker-compose.tun.yml     # Tun模式配置
├── .env.example              # 环境变量模板
├── .dockerignore             # Docker忽略文件
├── config/
│   └── mixin-tun.yaml        # Tun模式配置
├── resources/                # 资源文件
└── script/                   # 原始脚本
```

## 🔧 配置详解

### 环境变量配置

创建 `.env` 文件：

```bash
# 必需配置
CLASH_URL=https://your-subscription-url-here

# 可选配置
CLASH_SECRET=your-random-secret-key
CLASH_LOG_LEVEL=info
TZ=Asia/Shanghai
```

### Docker Compose 配置

#### 标准模式 (docker-compose.yml)

```yaml
version: '3.8'
services:
  clash:
    build: .
    container_name: clash-docker
    restart: unless-stopped
    environment:
      - CLASH_URL=${CLASH_URL}
      - CLASH_SECRET=${CLASH_SECRET}
    ports:
      - "9090:9090"  # Web控制台
      - "7890:7890"  # HTTP代理
      - "7891:7891"  # SOCKS5代理
      - "7892:7892"  # 混合代理
    volumes:
      - clash-data:/opt/clash
```

#### Tun模式 (docker-compose.tun.yml)

```yaml
version: '3.8'
services:
  clash-tun:
    build: .
    container_name: clash-docker-tun
    restart: unless-stopped
    privileged: true
    network_mode: host
    environment:
      - CLASH_URL=${CLASH_URL}
    volumes:
      - clash-tun-data:/opt/clash
      - ./config/mixin-tun.yaml:/opt/clash/mixin.yaml:ro
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    devices:
      - /dev/net/tun:/dev/net/tun
```

## 🌐 网络配置

### 标准代理模式

在标准模式下，Clash 监听以下端口：

- **9090**: Web 控制台
- **7890**: HTTP 代理端口
- **7891**: SOCKS5 代理端口
- **7892**: 混合代理端口 (HTTP + SOCKS5)
- **1053**: DNS 服务端口

### 系统代理设置

```bash
# 设置系统代理
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890
export all_proxy=socks5://127.0.0.1:7891
export no_proxy=localhost,127.0.0.1,::1

# 或使用混合代理
export http_proxy=http://127.0.0.1:7892
export https_proxy=http://127.0.0.1:7892
```

### Tun模式

Tun模式下，所有流量会自动路由到Clash，无需手动设置代理。

**注意事项：**
- 需要特权模式运行 (`privileged: true`)
- 使用host网络模式 (`network_mode: host`)
- 需要 `/dev/net/tun` 设备支持

## 📊 管理和监控

### 服务管理命令

```bash
# 启动服务
docker-compose up -d

# 查看状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 重启服务
docker-compose restart

# 停止服务
docker-compose down

# 停止并删除数据
docker-compose down -v
```

### 健康检查

容器内置健康检查，可以通过以下方式查看：

```bash
# 查看容器健康状态
docker ps
docker inspect clash-docker | jq '.[0].State.Health'

# 手动健康检查
docker exec clash-docker curl -f http://localhost:9090/version
```

### Web控制台

访问 Web 控制台: http://localhost:9090/ui

默认配置：
- 端口: 9090
- 密钥: 环境变量 `CLASH_SECRET` 设置的值

## 🔄 配置更新

### 自动更新订阅

容器启动时会自动下载最新的订阅配置。要手动更新：

```bash
# 重启容器重新下载配置
docker-compose restart

# 或设置新的订阅链接
CLASH_URL="new-url" docker-compose up -d
```

### 自定义配置

#### 方法1: 挂载配置目录

```yaml
volumes:
  - ./custom-config:/opt/clash
```

#### 方法2: 自定义 mixin 配置

```bash
# 创建自定义mixin文件
cat > custom-mixin.yaml << EOF
# 自定义规则
rules:
  - DOMAIN,example.com,DIRECT
EOF

# 挂载到容器
volumes:
  - ./custom-mixin.yaml:/opt/clash/mixin.yaml:ro
```

## 💾 数据持久化

### 数据卷说明

- `clash-data`: 标准模式数据卷
- `clash-tun-data`: Tun模式数据卷

### 备份和恢复

```bash
# 备份数据
docker run --rm -v clash-data:/data -v $(pwd):/backup alpine \
  tar czf /backup/clash-backup-$(date +%Y%m%d).tar.gz -C /data .

# 恢复数据
docker run --rm -v clash-data:/data -v $(pwd):/backup alpine \
  tar xzf /backup/clash-backup-YYYYMMDD.tar.gz -C /data

# 查看数据卷内容
docker run --rm -v clash-data:/data alpine ls -la /data
```

## 🐛 故障排除

### 常见问题

#### 1. 容器启动失败

```bash
# 查看详细错误
docker-compose logs

# 检查配置
docker-compose config

# 检查镜像构建
docker-compose build --no-cache
```

#### 2. 无法访问Web控制台

```bash
# 检查端口占用
netstat -tulpn | grep 9090
ss -tulpn | grep 9090

# 检查防火墙
sudo ufw status
sudo ufw allow 9090

# 检查容器网络
docker exec clash-docker netstat -tulpn
```

#### 3. 代理不工作

```bash
# 测试HTTP代理
curl -x http://127.0.0.1:7890 http://ip.sb

# 测试SOCKS5代理
curl -x socks5://127.0.0.1:7891 http://ip.sb

# 检查规则匹配
curl http://127.0.0.1:9090/proxies
```

#### 4. Tun模式问题

```bash
# 检查TUN设备
ls -la /dev/net/tun

# 加载TUN模块
sudo modprobe tun

# 检查权限
docker run --rm --privileged alpine ls -la /dev/net/tun
```

### 调试技巧

#### 进入容器调试

```bash
# 进入运行中的容器
docker exec -it clash-docker /bin/bash

# 查看进程
docker exec clash-docker ps aux

# 查看网络
docker exec clash-docker ip addr
docker exec clash-docker ss -tulpn
```

#### 查看详细日志

```bash
# 实时查看日志
docker-compose logs -f --tail=100

# 查看特定服务日志
docker-compose logs clash

# 查看系统日志
journalctl -u docker
```

## 🔒 安全建议

### 基础安全

1. **设置强密钥**
   ```bash
   CLASH_SECRET=$(openssl rand -base64 32)
   ```

2. **限制网络访问**
   ```yaml
   # 仅本地访问
   environment:
     - CLASH_BIND_ADDRESS=127.0.0.1
   ```

3. **定期更新**
   ```bash
   # 更新镜像
   docker-compose pull
   docker-compose up -d
   ```

### 防火墙配置

```bash
# Ubuntu/Debian
sudo ufw allow from 192.168.0.0/16 to any port 9090
sudo ufw deny 9090

# CentOS/RHEL
sudo firewall-cmd --add-rich-rule="rule family=ipv4 source address=192.168.0.0/16 port port=9090 protocol=tcp accept"
```

## 📈 性能优化

### 资源限制

```yaml
services:
  clash:
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'
        reservations:
          memory: 256M
          cpus: '0.25'
```

### 日志管理

```yaml
services:
  clash:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

## 📚 参考资料

- [Clash 官方文档](https://clash.wiki/)
- [mihomo 项目](https://github.com/MetaCubeX/mihomo)
- [Docker Compose 文档](https://docs.docker.com/compose/)
- [原项目地址](https://github.com/nelvko/clash-for-linux-install)