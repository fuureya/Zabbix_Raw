# 🚀 Panduan Migrasi Zabbix Server - Database Version Mismatch

## 🔍 MASALAH
Database Zabbix version: **7040000** (Zabbix 7.4)
Container image version: **7000000** (Zabbix 7.0.8)
Error: "The Zabbix database version does not match current requirements"

## ✅ SOLUSI 1: UPGRADE KE ZABBIX 7.4 (RECOMMENDED)

### Langkah 1: Gunakan Docker Compose untuk Server
```bash
# Gunakan file khusus untuk server
docker-compose -f docker-compose-server.yml down
docker-compose -f docker-compose-server.yml up -d
```

### Langkah 2: Atau Update docker-compose.yml yang ada
File `docker-compose.yml` sudah diupdate dengan:
- `zabbix/zabbix-server-mysql:7.4-ubuntu-latest`
- `zabbix/zabbix-web-nginx-mysql:7.4-ubuntu-latest`

```bash
docker-compose down
docker-compose up -d
```

## ⚠️ SOLUSI 2: DOWNGRADE KE ZABBIX 7.0 (DATA LOSS RISK)

### Opsi A: Migrasi Otomatis (Gunakan Script)
```bash
./migrate-to-zabbix70.sh
```

### Opsi B: Migrasi Manual
```bash
# 1. Backup database
docker exec zabbix-mysql mysqldump -u root -p[password] zabbix > backup.sql

# 2. Reset database
docker-compose down -v

# 3. Update images ke 7.0.8
sed -i 's/7.4-ubuntu-latest/7.0.8-ubuntu/g' docker-compose.yml

# 4. Start fresh
docker-compose up -d
```

## 🔧 TROUBLESHOOTING

### Jika masih error setelah upgrade:
```bash
# Restart containers
docker-compose restart

# Check logs
docker logs zabbix-server
docker logs zabbix-web
```

### Jika perlu force database upgrade:
```bash
# Add environment variable
ZBX_ALLOWUNSUPPORTEDDBVERSIONS=1
```

## 📝 CATATAN PENTING

1. **Backup selalu database** sebelum migrasi
2. **Zabbix 7.4 lebih baru** dari 7.0.8 - upgrade lebih aman
3. **Downgrade bisa menyebabkan data loss**
4. **Test di environment development** dulu

## 🌐 AKSES SETELAH MIGRASI

- **Zabbix Web**: http://[server-ip]:8080
- **phpMyAdmin**: http://[server-ip]:8082
- **Default Login**: Admin / zabbix

## 📞 SUPPORT

Jika masih ada masalah, check:
1. Container logs: `docker logs [container-name]`
2. Database connectivity: `docker exec zabbix-mysql mysql -u zabbix -p`
3. Network connectivity: `docker network ls`