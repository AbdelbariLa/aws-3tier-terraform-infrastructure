#!/bin/bash
apt update -y
apt install -y apache2 git curl
systemctl enable --now apache2

git clone --depth 1 https://github.com/gabrielecirulli/2048.git /tmp/site
rm -rf /var/www/html/*
cp -r /tmp/site/* /var/www/html/

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 60")
ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/instance-id)
AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/placement/availability-zone)
echo "Server: $(hostname) / $ID / $AZ" > /var/www/html/whoami.txt