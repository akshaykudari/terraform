#!/bin/bash

set -e
sudo rm -rf /var/www/html/*
echo "hello from terraform" | sudo tee /var/www/html/index.html
sudo systemctl restart nginx 