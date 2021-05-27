#!/bin/bash

KIBANA_HOST=178.154.246.73:5601
LOGSTASH_HOST=178.154.246.73:5045
METRICS_REST_SERVER=http://178.154.246.73:8080
METRICS_WS_SERVER=http://178.154.246.73:8080
SOCKET_AUTH_TOKEN=o2LGITIfEac2ARsl1req
NGROK_AUTH_TOKEN=1mKIdYYbflBsAQkW2nzzYRHZpZr_4KNrHkR9VTeWBgVUHC7PN
ARCHITECTURE=`uname -m`

LOCAL_METRICS_PORT=8080
METRICS_INTERVAL=300000 # 5 minutes

add_to_startup () {
    local SERVICE_NAME=$1
    local SERVICE_SCRIPT=$2
    sudo rm -f /etc/init.d/$SERVICE_NAME
    sudo touch /etc/init.d/$SERVICE_NAME
    echo \#\!/bin/bash | sudo tee -a /etc/init.d/$SERVICE_NAME
    echo "### BEGIN INIT INFO" | sudo tee -a /etc/init.d/$SERVICE_NAME
    echo "# Provides:       $SERVICE_NAME" | sudo tee -a /etc/init.d/$SERVICE_NAME
    echo "# Required-Start:    \$local_fs \$syslog" | sudo tee -a /etc/init.d/$SERVICE_NAME
    echo "# Required-Stop:     \$local_fs \$syslog" | sudo tee -a /etc/init.d/$SERVICE_NAME
    echo "# Default-Start:     2 3 4 5" | sudo tee -a /etc/init.d/$SERVICE_NAME
    echo "# Default-Stop:      0 1 6" | sudo tee -a /etc/init.d/$SERVICE_NAME
    echo "# Short-Description: starts $SERVICE_NAME" | sudo tee -a /etc/init.d/$SERVICE_NAME
    echo "# Description:       starts $SERVICE_NAME using start-stop-daemon" | sudo tee -a /etc/init.d/$SERVICE_NAME
    echo "### END INIT INFO" | sudo tee -a /etc/init.d/$SERVICE_NAME
    echo "" | sudo tee -a /etc/init.d/$SERVICE_NAME
    echo $SERVICE_SCRIPT | sudo tee -a /etc/init.d/$SERVICE_NAME
    echo "exit 0" | sudo tee -a /etc/init.d/$SERVICE_NAME
    sudo chmod 755 /etc/init.d/$SERVICE_NAME
    sudo update-rc.d $SERVICE_NAME defaults
}

# sudo raspi-config --expand-rootfs
passwd

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install tmux -y
sudo apt-get clean -y

mkdir -p ~/Dev
mkdir -p ~/app
mkdir -p ~/Dev/scripts

echo "PATH=\$PATH:~/Dev/scripts" >> ~/.profile

echo ""
echo "[CONFIGURE]: General setup"
cd ~/Dev
read -p "Company name: " company_name
read -p "Hardware type: " hardware_type
read -p "Client id: " client_id
read -p "Installation id: " installation_id

touch monitoring.config
echo "export COMPANY_NAME=$company_name" >> monitoring.config
echo "export HARDWARE_TYPE=$hardware_type" >> monitoring.config
echo "export CLIENT_ID=$client_id" >> monitoring.config
echo "export INSTALLATION_ID=$installation_id" >> monitoring.config
echo "######## FIXED CONFIGURATIONS ########" >> monitoring.config
echo "export KIBANA_HOST=$KIBANA_HOST" >> monitoring.config
echo "export LOGSTASH_HOST=$LOGSTASH_HOST" >> monitoring.config
echo "export METRICS_REST_SERVER=$METRICS_REST_SERVER" >> monitoring.config
echo "export METRICS_WS_SERVER=$METRICS_WS_SERVER" >> monitoring.config
echo "export LOCAL_METRICS_PORT=8080" >> monitoring.config
echo "export METRICS_INTERVAL=1000" >> monitoring.config
echo "export SOCKET_AUTH_TOKEN=$SOCKET_AUTH_TOKEN" >> monitoring.config
echo "export NGROK_AUTH_TOKEN=$NGROK_AUTH_TOKEN" >> monitoring.config
echo "export ARCHITECTURE=$ARCHITECTURE" >> monitoring.config

echo "source ~/Dev/monitoring.config" >> ~/.profile
source ~/Dev/monitoring.config
cd ~/Dev

echo ""
echo "[NODE.JS]: Installing"
cd ~/Dev
wget "https://nodejs.org/dist/v14.15.4/node-v14.15.4-linux-$ARCHITECTURE.tar.xz"
tar -xJf node-v14.15.4-linux-$ARCHITECTURE.tar.xz
rm *.tar*
cd node-v14.15.4-linux-$ARCHITECTURE
sudo cp -R * /usr/local/
cd ~/Dev
rm -rf node-v14.15.4-linux-$ARCHITECTURE

echo ""
echo "[CONFIGURE]: Downloading and configuring metricbeat"
cd ~/Dev
wget "https://storage.yandexcloud.net/solar-monitoring/packages/metricbeat-oss-7.10.1-linux-$ARCHITECTURE.tar.gz"
tar xfvz metricbeat-oss-7.10.1-linux-$ARCHITECTURE.tar.gz
rm *.tar*
mv metricbeat-7.10.1-linux-armv7 metricbeat-oss-7.10.1-linux-$ARCHITECTURE
cd ~/Dev/scripts
wget "https://storage.yandexcloud.net/solar-monitoring/scripts/update.metricbeat.config.sh"
chmod 755 update.metricbeat.config.sh
./update.metricbeat.config.sh
cd ~/Dev

echo ""
echo "[CONFIGURE]: Downloading and configuring node-local-server"
cd ~/app
sudo npm install -g nodemon

cd ~/Dev/scripts
wget "https://storage.yandexcloud.net/solar-monitoring/scripts/update.app.sh"
chmod 755 update.app.sh
./update.app.sh
cd ~/Dev

echo ""
echo "[METRICBEAT]: Add to startup"
cd ~/Dev/scripts
touch start.metricbeat.sh
echo \#\!/bin/bash >> start.metricbeat.sh
echo "/bin/su -c \"tmux new-session -d -s metricbeat 'cd /home/pi/Dev/metricbeat-oss-7.10.1-linux-$ARCHITECTURE && sudo ./metricbeat -e'\" - pi" >> start.metricbeat.sh
sudo chmod 755 start.metricbeat.sh
add_to_startup start.metricbeat /home/pi/Dev/scripts/start.metricbeat.sh
cd ~/Dev

echo ""
echo "[NODE-LOCAL-SERVER]: Add to startup"
cd ~/Dev/scripts
touch start.node.local.sh
echo \#\!/bin/bash >> start.node.local.sh
echo "/bin/su -c \"tmux new-session -d -s node-monitoring 'source /home/pi/Dev/monitoring.config && cd /home/pi/app/node-local-server && nodemon index.monitoring.js'\" - pi" >> start.node.local.sh
echo "/bin/su -c \"tmux new-session -d -s node-io 'source /home/pi/Dev/monitoring.config && cd /home/pi/app/node-local-server && nodemon index.io.js'\" - pi" >> start.node.local.sh
sudo chmod 755 start.node.local.sh
add_to_startup start.node.local /home/pi/Dev/scripts/start.node.local.sh
cd ~/Dev

sudo reboot