#!/bin/bash
sudo apt update -y
sudo apt install apache2 -y
sudo systemctl start apache2
sudo systemctl enable apache2
# echo "This is server *1* in AWS Region US-EAST-1 in AZ US-EAST-1a" | sudo tee /var/www/html/index.html

echo  "Hello from $(hostname)" | sudo tee /var/www/html/index.html | sudo tee /var/www/html/index.html