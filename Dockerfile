FROM ubuntu:24.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Jakarta

# Install basic packages and dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    gnupg2 \
    lsb-release \
    software-properties-common \
    tzdata \
    mysql-client \
    nginx \
    php8.3-fpm \
    php8.3-mysql \
    php8.3-bcmath \
    php8.3-gd \
    php8.3-mbstring \
    php8.3-xml \
    php8.3-ldap \
    supervisor \
    && ln -fs /usr/share/zoneinfo/$TZ /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata

# Install Zabbix repository
RUN wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.0+ubuntu24.04_all.deb \
    && dpkg -i zabbix-release_latest_7.0+ubuntu24.04_all.deb \
    && apt-get update

# Install Zabbix packages
RUN apt-get install -y \
    zabbix-server-mysql \
    zabbix-frontend-php \
    zabbix-nginx-conf \
    zabbix-sql-scripts \
    zabbix-agent \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create zabbix user and group if not exists
RUN getent group zabbix >/dev/null || groupadd -r zabbix \
    && getent passwd zabbix >/dev/null || useradd -r -g zabbix -d /var/lib/zabbix -s /sbin/nologin zabbix

# Create necessary directories
RUN mkdir -p /var/log/zabbix \
    && mkdir -p /var/run/zabbix \
    && mkdir -p /etc/zabbix/web \
    && chown -R zabbix:zabbix /var/log/zabbix \
    && chown -R zabbix:zabbix /var/run/zabbix

# Copy configuration files
COPY configs/zabbix_server.conf /etc/zabbix/zabbix_server.conf
COPY configs/nginx.conf /etc/zabbix/nginx.conf
COPY configs/php-fpm.conf /etc/zabbix/php-fpm.conf
COPY configs/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy startup script
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose ports
EXPOSE 80 10051 10050

# Set working directory
WORKDIR /var/lib/zabbix

# Start services via supervisor
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]