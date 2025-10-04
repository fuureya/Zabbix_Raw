#!/bin/bash

echo "Stopping zabbix-web container..."
docker-compose stop zabbix-web

echo "Waiting for database to be fully ready..."
sleep 10

echo "Starting zabbix-web container..."
docker-compose start zabbix-web

echo "Waiting for web interface to be ready..."
sleep 30

echo "Checking web interface status..."
docker logs zabbix-web --tail 20

echo ""
echo "Web interface should be available at:"
echo "http://192.168.250.5:8081"
echo ""
echo "Default login:"
echo "Username: Admin"
echo "Password: zabbix"