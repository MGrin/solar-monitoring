#!/bin/bash

read -p "Did you write the Respberry Pi OS Lite to your SDCard? [Yn]" sdcard_initiated

if [[ "$sdcard_initiated" == 'n' ]]; then
  echo "Please follow this instruction first and then come back: https://www.raspberrypi.org/documentation/installation/installing-images/"
  exit 1
fi

SDCARD_PATH="/Volumes/boot"

echo "Connection mechanism:"
echo "1) Ethernet"
echo "2) WiFi"
read -p "Choose number [1,2]: " connection_type

if [[ "$connection_type" != "1" && "$connection_type" != "2" ]]; then
  echo "Please, type 1 or 2. Exiting"
  exit 1
fi

if [[ "$connection_type" == "2" ]]; then
  touch $SDCARD_PATH/ssh

  read -p "Country code in two capital letters (like RU for Russia, UK for United Kingdom, etc.): " country_code
  read -p "WiFi name: " ssid
  read -p "WiFi password: " psk

  rm $SDCARD_PATH/wpa_supplicant.conf
  touch $SDCARD_PATH/wpa_supplicant.conf

  echo "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev" >> $SDCARD_PATH/wpa_supplicant.conf
  echo "update_config=1" >> $SDCARD_PATH/wpa_supplicant.conf
  echo "country=$country_code" >> $SDCARD_PATH/wpa_supplicant.conf

  echo "network={" >> $SDCARD_PATH/wpa_supplicant.conf
  echo "  ssid=\"$ssid\"" >> $SDCARD_PATH/wpa_supplicant.conf
  echo "  psk=\"$psk\"" >> $SDCARD_PATH/wpa_supplicant.conf
  echo "}" >> $SDCARD_PATH/wpa_supplicant.conf
fi

echo "Please now insert your SDCard into your Raspberry Pi and connect it to power."
echo "You'll have to manually find out the IP of the RPI in your local network."
