#!/bin/sh

# installieren der Sensormessung
sudo apt install lm-sensors

while true
do
    sensors >> temp_history.txt
    echo "--------------------" >> temp_history.txt
    sleep 5
done