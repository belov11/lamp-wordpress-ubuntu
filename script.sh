#!/bin/bash

#install and download nessesary software
sudo apt-get install apache2 apache2-utils -y
sudo apt-get install php libapache2-mod-php php-mysql php-curl php-gd php-intl php-mbstring php-soap php-xml php-xmlrpc php-zip -y
sudo apt-get install mariadb-server mariadb-client -y
wget https://wordpress.org/wordpress-5.1.16.tar.gz && tar -xzvf wordpress-5.1.16.tar.gz 
#create wordpress config file for apache and create permissons for this file
sudo touch /etc/apache2/sites-available/wordpress.conf
sudo chmod 777 /etc/apache2/sites-available/wordpress.conf
#fill in this config file
sudo cat << EOF > /etc/apache2/sites-available/wordpress.conf
<VirtualHost *:80>
	ServerAdmin web@localhost
	DocumentRoot /var/www/wordpress
	ErrorLog /error.log
	CustomLog /access.log combined
</VirtualHost>
EOF
#remove premissons for file wordpress config apache 
sudo chmod 755 /etc/apache2/sites-available/wordpress.conf
#create wordpress config file for wordpress and move to var/www/
cp wordpress/wp-config-sample.php wordpress/wp-config.php
sudo mv wordpress/ /var/www/wordpress
#add permissions and change owner for wordpress folder
sudo chmod -R 755 /var/www/wordpress
sudo chown -R www-data:www-data /var/www/wordpress 
#disconnect standart config file apache and connect new config file
sudo a2dissite 000-default.conf
sudo a2ensite wordpress.conf
#testing config file and restart apache service
sudo apache2ctl configtest
sudo systemctl restart apache2
#create name and pass for mysql
pass_wp="$(openssl rand -base64 12)"
name_wp="$(whoami)_wp"
#create pass root and database, user
sudo mysql_secure_installation
sudo mysql -u root -p -e "CREATE DATABASE ${name_wp};"
sudo mysql -u root -p -e "CREATE USER '${name_wp}'@'localhost' IDENTIFIED BY '${pass_wp}';"
sudo mysql -u root -p -e "GRANT ALL PRIVILEGES ON ${name_wp}.* TO '${name_wp}'@'localhost';"
sudo mysql -u root -p -e "FLUSH PRIVILEGES;"
#change info in wordpress config file
sudo sed -i "s/database_name_here/${name_wp}/" /var/www/wordpress/wp-config.php
sudo sed -i "s/username_here/${name_wp}/" /var/www/wordpress/wp-config.php
sudo sed -i "s/password_here/${pass_wp}/" /var/www/wordpress/wp-config.php
