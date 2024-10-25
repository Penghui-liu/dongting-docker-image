FROM python:3.11.10-bullseye AS builder

COPY requirements.txt .

RUN pip config set global.index-url https://pypi.mirrors.ustc.edu.cn/simple/ \
 && pip install --default-timeout=120 --user -U pip --no-warn-script-location \
 && pip install --default-timeout=120 --user -r requirements.txt --no-warn-script-location

FROM python:3.11.10-slim-bullseye
WORKDIR /app

COPY --from=builder /root/.local /root/.local

RUN sed -i "s@http://deb.debian.org@http://mirrors.aliyun.com@g" /etc/apt/sources.list && \
    sed -i 's|security.debian.org/debian-security|mirrors.ustc.edu.cn/debian-security|g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install --no-install-recommends -y libgomp1 && \
    apt-get autoremove -y && \
    playwright install --with-deps chrome && \
    rm -rf /var/lib/apt/lists/*
