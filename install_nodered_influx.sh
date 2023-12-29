#!/bin/bash

HOME_DIR="/home/rpaha"

# Installe Node-RED
echo "Installation de Node-RED..."
apt install -y npm
npm install -gy --unsafe-perm node-red

# Installe InfluxDB
echo "Installation d'InfluxDB..."
apt update
apt install -y mysql-server

# Démarrage des services
echo "Démarrage des services..."
systemctl start mysql
systemctl enable mysql

# Attendre un court instant pour s'assurer que InfluxDB est démarré
sleep 5

# Création d'une table dans InfluxDB
echo "Création d'une table dans InfluxDB..."
mysql -e "CREATE USER 'rpaha'@'localhost' IDENTIFIED BY 'rpaha';"
mysql -e "CREATE DATABASE collector;"
mysql -e "GRANT ALL PRIVILEGES ON collector.* TO 'rpaha'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"
mysql -e "USE collector; CREATE TABLE IF NOT EXISTS \`collector\`.\`ecg\` (\`id\` int(11) NOT NULL AUTO_INCREMENT, \`date\` datetime NOT NULL, \`hrb\` INT NOT NULL, PRIMARY KEY (\`id\`));"

# Copie des fichiers locaux vers les dossiers de configuration
echo "Copie des fichiers de configuration..."
mkdir $HOME_DIR/.node-red
chown -R rpaha:rpaha $HOME_DIR/.node-red
cp volumes/node-red/settings.js $HOME_DIR/.node-red/settings.js
cp volumes/node-red/flows.json $HOME_DIR/.node-red/flows.json
cp volumes/node-red/flows_cred.json $HOME_DIR/.node-red/flows_cred.json
cp volumes/node-red/package-lock.json $HOME_DIR/.node-red/package-lock.json
cp volumes/node-red/package.json $HOME_DIR/.node-red/package.json
cp volumes/node-red/.config.nodes.json $HOME_DIR/.node-red/.config.nodes.json
cp volumes/node-red/.config.nodes.json.backup $HOME_DIR/.node-red/.config.nodes.json.backup
cp volumes/node-red/.config.runtime.json $HOME_DIR/.node-red/.config.runtime.json
cp volumes/node-red/.config.users.json $HOME_DIR/.node-red/.config.users.json
cp volumes/node-red/.config.users.json.backup $HOME_DIR/.node-red/.config.users.json.backup
cp -r volumes/node-red/node_modules $HOME_DIR/.node-red/node_modules

# Redémarrage des services
echo "Redémarrage des services..."
systemctl restart mysql

echo "Installation terminée."
