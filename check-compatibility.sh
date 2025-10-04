#!/bin/bash

echo "=== ZABBIX COMPATIBILITY CHECKER ==="
echo ""

# Check if database exists and get version
if docker ps | grep -q zabbix-mysql; then
    echo "✅ MySQL container running"

    # Check database version
    echo "🔍 Checking database version..."
    DB_VERSION=$(docker exec zabbix-mysql mysql -u root -p${MYSQL_ROOT_PASSWORD:-zabbix_root_password} -D ${MYSQL_DATABASE:-zabbix} -se "SELECT mandatory FROM dbversion;" 2>/dev/null)

    if [ ! -z "$DB_VERSION" ]; then
        echo "📊 Database version: $DB_VERSION"

        case $DB_VERSION in
            "07000000")
                echo "✅ Compatible dengan Zabbix 7.0.x"
                echo "🎯 Recommended images:"
                echo "   - zabbix/zabbix-server-mysql:7.0.8-ubuntu"
                echo "   - zabbix/zabbix-web-nginx-mysql:7.0.8-ubuntu"
                ;;
            "07040000")
                echo "✅ Compatible dengan Zabbix 7.4.x"
                echo "🎯 Recommended images:"
                echo "   - zabbix/zabbix-server-mysql:7.4-ubuntu-latest"
                echo "   - zabbix/zabbix-web-nginx-mysql:7.4-ubuntu-latest"
                ;;
            *)
                echo "⚠️  Database version tidak dikenali: $DB_VERSION"
                echo "🔧 Silakan check manual compatibility"
                ;;
        esac
    else
        echo "❌ Tidak bisa mendapatkan database version"
        echo "🔧 Pastikan database berisi schema Zabbix"
    fi
else
    echo "❌ MySQL container tidak running"
    echo "🚀 Start container dulu: docker-compose up -d zabbix-mysql"
fi

echo ""
echo "🐳 Current Docker images:"
docker images | grep zabbix

echo ""
echo "📋 Container status:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(zabbix|mysql)"