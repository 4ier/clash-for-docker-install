FROM alpine:3.18

# 设置代理环境变量（构建时使用）
ARG http_proxy
ARG https_proxy
ENV http_proxy=$http_proxy
ENV https_proxy=$https_proxy

# 配置国内镜像源
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

# 安装必要的依赖
RUN apk add --no-cache \
    bash \
    curl \
    wget \
    gzip \
    tar \
    ca-certificates \
    tzdata \
    iptables \
    iproute2 \
    && rm -rf /var/cache/apk/*

# 清除代理环境变量（运行时不需要）
ENV http_proxy=
ENV https_proxy=

# 设置时区
ENV TZ=Asia/Shanghai

# 创建工作目录
WORKDIR /app

# 复制项目文件
COPY . .

# 创建clash目录
RUN mkdir -p /opt/clash

# 设置执行权限
RUN chmod +x install.sh uninstall.sh script/*.sh

# 复制Docker启动脚本
COPY docker-entrypoint.sh /app/docker-entrypoint.sh

# 设置启动脚本权限
RUN chmod +x /app/docker-entrypoint.sh

# 暴露端口
# 9090: Web控制台
# 7890: HTTP代理
# 7891: SOCKS5代理  
# 7892: 混合代理
# 1053: DNS服务
EXPOSE 9090 7890 7891 7892 1053

# 设置数据卷
VOLUME ["/opt/clash"]

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:9090/version || exit 1

# 入口点
ENTRYPOINT ["/app/docker-entrypoint.sh"]