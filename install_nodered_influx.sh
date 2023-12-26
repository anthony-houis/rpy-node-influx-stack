#!/bin/bash

HOME_DIR="/home/rpaha"

# Installe Node-RED
echo "Installation de Node-RED..."
apt install -y npm
npm install -gy --unsafe-perm node-red

# Installe InfluxDB
echo "Installation d'InfluxDB..."
apt update
curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" >> sudo tee /etc/apt/sources.list
apt update && apt install -y influxdb && apt install -y influxdb-client

# Démarrage des services
echo "Démarrage des services..."
systemctl start influxdb
systemctl enable influxdb

# Attendre un court instant pour s'assurer que InfluxDB est démarré
sleep 5

# Création d'une table dans InfluxDB
echo "Création d'une table dans InfluxDB..."
influx -execute "CREATE DATABASE collector"
influx -execute "USE collector"
influx -execute "CREATE RETENTION POLICY \"default\" ON \"collector\" DURATION 2m REPLICATION 1 DEFAULT"

# Redémarrage des services
echo "Redémarrage des services..."
node-red

sleep 20

systemctl restart influxdb

echo "Installation terminée."

# Copie des fichiers locaux vers les dossiers de configuration
echo "Copie des fichiers de configuration..."
cp volumes/node-red/settings.js $HOME_DIR/.node-red/settings.js
cp volumes/node-red/flows.json $HOME_DIR/.node-red/flows.json
cp volumes/node-red/flows_cred.json $HOME_DIR/.node-red/flows_cred.json
cp volumes/node-red/package-lock.json $HOME_DIR/.node-red/package-lock.json
cp volumes/node-red/package.json $HOME_DIR/.node-red/package.json
cp volumes/node-red/.config.nodes.json $HOME_DIR/.node-red/.config.nodes.json
cp volumes/node-red/.config.nodes.json.backup $HOME_DIR/.node-red/.config.nodes.json.backup
cp volumes/node-red/.config.runtime.json $HOME_DIR/.node-red/.config.runtime.json
cp volumes/node-red/.config.user.json $HOME_DIR/.node-red/.config.user.json
cp volumes/node-red/.config.user.json.backup $HOME_DIR/.node-red/.config.user.json.backup
cp -r volumes/node-red/node_modules $HOME_DIR/.node-red/node_modules
