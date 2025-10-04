#!/bin/bash

# Script untuk migrasi database Zabbix 7.4 ke 7.0
# PERINGATAN: Script ini akan menghapus data yang tidak kompatibel

echo "=== MIGRASI ZABBIX 7.4 ke 7.0 ==="
echo "PERINGATAN: Script ini akan:"
echo "1. Backup database yang ada"
echo "2. Downgrade schema ke versi 7.0"
echo "3. Data yang tidak kompatibel akan hilang"
echo ""

read -p "Apakah Anda yakin ingin melanjutkan? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Migrasi dibatalkan."
    exit 1
fi

# Load environment variables
if [ -f .env ]; then
    source .env
else
    echo "File .env tidak ditemukan!"
    exit 1
fi

echo "1. Membuat backup database..."
docker exec zabbix-mysql mysqldump -u root -p${MYSQL_ROOT_PASSWORD} ${MYSQL_DATABASE} > backup_zabbix_$(date +%Y%m%d_%H%M%S).sql

echo "2. Menghentikan container..."
docker-compose down

echo "3. Menghapus volume database lama..."
docker volume rm zabbix_zabbix-mysql-data 2>/dev/null || true

echo "4. Mengembalikan versi images ke 7.0.8..."
sed -i 's/7.4-ubuntu-latest/7.0.8-ubuntu/g' docker-compose.yml

echo "5. Memulai dengan database bersih..."
docker-compose up -d

echo "6. Menunggu database siap..."
sleep 30

echo "Migrasi selesai. Silakan import data manual jika diperlukan."
echo "File backup tersimpan di: backup_zabbix_$(date +%Y%m%d_%H%M%S).sql"