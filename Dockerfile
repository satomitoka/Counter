FROM wjqserver/caddy:alpine AS builder

ARG USER=WJQSERVER
ARG REPO=Counter
ARG APPLICATION=counter
ARG TARGETOS
ARG TARGETARCH
ARG TARGETPLATFORM

# 拉取依赖
RUN apk add --no-cache wget curl

# 创建目录
RUN mkdir -p /data/www
RUN mkdir -p /data/${APPLICATION}/config 
RUN mkdir -p /data/${APPLICATION}/config.d
RUN mkdir -p /data/${APPLICATION}/count
RUN mkdir -p /data/${APPLICATION}/log

# 前端
RUN wget -O /data/www/index.html https://raw.githubusercontent.com/${USER}/${REPO}/main/pages/index.html

# Caddyfile
RUN wget -O /data/caddy/Caddyfile https://raw.githubusercontent.com/${USER}/${REPO}/main/Caddyfile

# 后端
RUN VERSION=$(curl -s https://raw.githubusercontent.com/${USER}/${REPO}/main/VERSION) && \
    wget -O /data/${APPLICATION}/${APPLICATION} https://github.com/${USER}/${REPO}/releases/download/$VERSION/${APPLICATION}-${TARGETOS}-${TARGETARCH}
RUN wget -O /data/${APPLICATION}/config.d/config.yaml https://raw.githubusercontent.com/${USER}/${REPO}/main/config/config.yaml
RUN wget -O /usr/local/bin/init.sh https://raw.githubusercontent.com/${USER}/${REPO}/main/init.sh

# 权限
RUN chmod +x /data/${APPLICATION}/${APPLICATION}
RUN chmod +x /usr/local/bin/init.sh

FROM wjqserver/caddy:alpine

COPY --from=builder /data/www /data/www
COPY --from=builder /data/caddy /data/caddy
COPY --from=builder /data/${APPLICATION} /data/${APPLICATION}
COPY --from=builder /usr/local/bin/init.sh /usr/local/bin/init.sh

# 权限
RUN chmod +x /data/${APPLICATION}/${APPLICATION}
RUN chmod +x /usr/local/bin/init.sh

CMD ["/usr/local/bin/init.sh"]

