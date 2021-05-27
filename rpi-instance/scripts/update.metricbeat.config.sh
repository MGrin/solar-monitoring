#!/bin/bash

cd ~/Dev
rm metricbeat.yml
wget "https://storage.yandexcloud.net/solar-monitoring/configs/metricbeat.yml"
sudo cp metricbeat.yml metricbeat-oss-7.10.1-linux-$ARCHITECTURE/metricbeat.yml
cd metricbeat-oss-7.10.1-linux-$ARCHITECTURE
echo "" | sudo tee -a metricbeat.yml
echo "metricbeat.config.modules:" | sudo tee -a metricbeat.yml
echo "" | sudo tee -a metricbeat.yml
echo '  path: "${path.config}/modules.d/*.yml"' | sudo tee -a metricbeat.yml
echo ""  | sudo tee -a metricbeat.yml
echo "  reload.period: 10s" | sudo tee -a metricbeat.yml
echo "" | sudo tee -a metricbeat.yml
echo "  reload.enabled: true" | sudo tee -a metricbeat.yml

sudo sed -i "s/{{ COMPANY_NAME_VAR }}/"${COMPANY_NAME:-COMPANY_NAME}"/" metricbeat.yml
sudo sed -i "s/{{ CLIENT_ID_VAR }}/"${CLIENT_ID}"/" metricbeat.yml
sudo sed -i "s/{{ INSTALLATION_ID_VAR }}/"${INSTALLATION_ID}"/" metricbeat.yml
sudo sed -i "s~{{ KIBANA_HOST_VAR }}~${KIBANA_HOST}~g" metricbeat.yml
sudo sed -i "s~{{ LOGSTASH_HOST_VAR }}~${LOGSTASH_HOST}~g" metricbeat.yml

sudo chown root metricbeat.yml
sudo chown root modules.d/system.yml