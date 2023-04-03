#! /bin/bash
amazon-linux-extras install php7.2 -y
yum install httpd mysql jq -y
sudo service httpd start
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r  wordpress/* /var/www/html
chown -R  apache: /var/www/html
cd /var/www/html
cp wp-config-sample.php wp-config.php
secret=$(aws secretsmanager get-secret-value --secret-id piyushrds --query SecretString --output text --region us-west-1)
dbname=$(echo $secret |jq -r .dbname)
username=$(echo $secret |jq -r .username)
password=$(echo $secret |jq -r .password)
host=$(echo $secret |jq -r .host)
sudo sed -i "s/database_name_here/$dbname/" /var/www/html/wp-config.php 
sudo sed -i "s/username_here/$username/" /var/www/html/wp-config.php
sudo sed -i "s/password_here/$password/" /var/www/html/wp-config.php
sudo sed -i "s/localhost/$host/" /var/www/html/wp-config.php
sudo sed -i "/.*Add any custom values/idefine( 'WP_HOME', 'https://piyush.groveops.net' );\ndefine( 'WP_SITEURL', 'https://piyush.groveops.net' );\ndefine('FORCE_SSL_ADMIN', true);\nif (strpos(\$_SERVER['HTTP_X_FORWARDED_PROTO'], 'https') !== false)\n\$_SERVER['HTTPS']='on';" /var/www/html/wp-config.php
sudo service httpd restart