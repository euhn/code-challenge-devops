#!/bin/bash

sudo apt -y update
sudo apt -y install nginx
sudo service nginx start
echo "<h1>ByteCubed Challenge ${HOSTNAME}</h1>" | sudo tee /var/www/html/index.html
