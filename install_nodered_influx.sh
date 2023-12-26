#!/bin/bash

# Installe Node-RED
echo "Installation de Node-RED..."
npm install -g --unsafe-perm node-red

# Installe InfluxDB
echo "Installation d'InfluxDB..."
apt-get update
curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
source /etc/lsb-release
echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
apt-get update && apt-get install influxdb

# Démarrage des services
echo "Démarrage des services..."
systemctl start influxdb
systemctl enable influxdb

# Attendre un court instant pour s'assurer que InfluxDB est démarré
sleep 5

# Copie des fichiers locaux vers les dossiers de configuration
echo "Copie des fichiers de configuration..."
cp /volumes/node-red/settings.js ~/.node-red/settings.js
cp /volumes/node-red/flows.json ~/.node-red/flows.json
cp /volumes/node-red/flows_cred.json ~/.node-red/flows_cred.json
cp /volumes/node-red/package-lock.json ~/.node-red/package-lock.json
cp /volumes/node-red/package.json ~/.node-red/package.json
cp /volumes/node-red/.config.nodes.json ~/.node-red/.config.nodes.json
cp /volumes/node-red/.config.nodes.json.backup ~/.node-red/.config.nodes.json.backup
cp /volumes/node-red/.config.runtime.json ~/.node-red/.config.runtime.json
cp /volumes/node-red/.config.user.json ~/.node-red/.config.user.json
cp /volumes/node-red/.config.user.json.backup ~/.node-red/.config.user.json.backup
cp -r /volumes/node-red/node_modules ~/.node-red/node_modules

# Création d'une table dans InfluxDB
echo "Création d'une table dans InfluxDB..."
influx -execute "CREATE DATABASE collector"
influx -execute "USE collector"
influx -execute "CREATE RETENTION POLICY \"default\" ON \"collector\" DURATION 2m REPLICATION 1 DEFAULT"

# Redémarrage des services
echo "Redémarrage des services..."
systemctl restart node-red
systemctl restart influxdb

echo "Installation terminée."
