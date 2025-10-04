# Zabbix Docker Setup

Docker setup untuk Zabbix dengan Ubuntu base image mengikuti langkah instalasi official.

## Struktur File

```
.
├── Dockerfile              # Custom Zabbix server image dengan Ubuntu
├── docker-compose.yml      # Docker Compose configuration
├── .env                    # Environment variables
├── zabbix.sql             # Database export (existing)
├── configs/               # Configuration files
│   ├── zabbix_server.conf # Zabbix server configuration
│   ├── nginx.conf         # Nginx web server configuration
│   ├── php-fpm.conf       # PHP-FPM configuration
│   └── supervisord.conf   # Supervisor process manager
└── scripts/
    └── entrypoint.sh      # Container startup script
```

## Cara Penggunaan

1. **Build dan Start containers:**
   ```bash
   docker-compose up -d --build
   ```

2. **Akses Web Interface:**
   - Zabbix Web: http://localhost:8080
   - phpMyAdmin: http://localhost:8082

3. **Default Login Zabbix:**
   - Username: Admin
   - Password: zabbix

4. **Database Access:**
   - Host: zabbix-mysql
   - Username: zabbix
   - Password: zabbix_password
   - Database: zabbix

## Features

- ✅ Ubuntu 24.04 base image
- ✅ Zabbix Server 7.0 (latest)
- ✅ Nginx web server
- ✅ PHP 8.3 with FPM
- ✅ MySQL 8.0 database
- ✅ phpMyAdmin untuk database management
- ✅ Supervisor untuk process management
- ✅ Auto-import zabbix.sql jika database kosong
- ✅ Health checks untuk semua services
- ✅ Persistent data volumes

## Ports

- 8080: Zabbix Web Interface
- 8082: phpMyAdmin
- 10051: Zabbix Server
- 10050: Zabbix Agent
- 3306: MySQL Database

## Maintenance Commands

```bash
# View logs
docker-compose logs -f zabbix-server

# Restart services
docker-compose restart

# Stop services
docker-compose down

# Rebuild after config changes
docker-compose down
docker-compose up -d --build
```