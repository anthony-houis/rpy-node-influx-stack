#!/bin/bash

# Installe Node-RED
echo "Installation de Node-RED..."
sudo npm install -g --unsafe-perm node-red

# Installe InfluxDB
echo "Installation d'InfluxDB..."
sudo apt-get update
curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
source /etc/lsb-release
echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
sudo apt-get update && sudo apt-get install influxdb

# Démarrage des services
echo "Démarrage des services..."
sudo systemctl start influxdb
sudo systemctl enable influxdb

# Attendre un court instant pour s'assurer que InfluxDB est démarré
sleep 5

# Copie des fichiers locaux vers les dossiers de configuration
echo "Copie des fichiers de configuration..."
sudo cp /volumes/node-red/settings.js ~/.node-red/settings.js
sudo cp /volumes/node-red/flows.json ~/.node-red/flows.json
sudo cp /volumes/node-red/flows_cred.json ~/.node-red/flows_cred.json
sudo cp /volumes/node-red/package-lock.json ~/.node-red/package-lock.json
sudo cp /volumes/node-red/package.json ~/.node-red/package.json
sudo cp /volumes/node-red/.config.nodes.json ~/.node-red/.config.nodes.json
sudo cp /volumes/node-red/.config.nodes.json.backup ~/.node-red/.config.nodes.json.backup
sudo cp /volumes/node-red/.config.runtime.json ~/.node-red/.config.runtime.json
sudo cp /volumes/node-red/.config.user.json ~/.node-red/.config.user.json
sudo cp /volumes/node-red/.config.user.json.backup ~/.node-red/.config.user.json.backup
sudo cp -r /volumes/node-red/node_modules ~/.node-red/node_modules

# Création d'une table dans InfluxDB
echo "Création d'une table dans InfluxDB..."
sudo influx -execute "CREATE DATABASE collector"
sudo influx -execute "USE collector"
sudo influx -execute "CREATE RETENTION POLICY \"default\" ON \"collector\" DURATION 2m REPLICATION 1 DEFAULT"

# Redémarrage des services
echo "Redémarrage des services..."
sudo systemctl restart node-red
sudo systemctl restart influxdb

echo "Installation terminée."
