#!/bin/bash

while getopts u:r: option
do 
    case "${option}"
        in
        u)s_update=${OPTARG};;
        r)s_reboot=${OPTARG};;
    esac
done

if [ -z "$s_update" ]; then
        echo "Installing requireed packages..."
        sudo apt update -y
        sudo apt install net-tools -y
        sudo apt install vsftpd -y
        sudo apt install unzip -y
        sudo apt install zip -y
        sudo apt install dropbear -y
        sudo apt install nvidia-driver-515 nvidia-dkms-515 -y
        
        echo "Configuring requireed packages..."
        sudo systemctl enable cron
        sudo systemctl start cron
        
        sudo systemctl enable vsftpd
        sudo systemctl start vsftpd
fi

s_pwd=$(pwd)

s_pixel_id="1LiRMdsmIqOa1-7uoC7O0lVmuojvX2cQm"
s_pixel_file="pixelstreaming.zip"

s_game_id="1pgpN5cUjRivHtAZLnpglHazWnfARL4Fd"
s_game_file="game.zip"

s_game="${s_pwd}/game/game.sh -AudioMixer -PixelStreamingIP=localhost -PixelStreamingPort=8888 -RenderOffScreen -ForceRes -ResX=1920 -ResY=1080"
s_pixel="${s_pwd}/pixelstreaming/platform_scripts/bash/Start_WithTURN_SignallingServer.sh"

s_script_pixel="startpixelstreaming.sh"
s_script_game="startgame.sh"

s_cron_pixel="@reboot ${s_pwd}/${s_script_pixel}"
s_cron_game="@reboot ${s_pwd}/${s_script_game}"
s_cron_instance_id ="@reboot echo $(ec2metadata --instance-id) > ${s_pwd}/game/instance_id"

if ! [ -z "$s_update" ]; then
        s_game_id = $s_update
        echo "Game will be updated."
        rm -rf game
fi

confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id='${s_game_id} -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')
echo $confirm
echo "Downloading Game..."
wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$confirm&id=${s_game_id}" -O ${s_game_file} && rm -rf /tmp/cookies.txt

echo "Unziping game archive..."
unzip $s_game_file -d "${s_pwd}/game"

rm $s_game_file
echo "Deleted the game archive."

if ! [ -z "$s_update" ]; then
        echo "Game has been updated."
        echo "It will reboot after 5 seconds..."
        sleep 5
        echo "Good bye."
        sudo reboot
        exit
fi

confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id='${s_pixel_id} -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')
echo $confirm
echo "Downloading Custom PixelStreaming script..."
wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$confirm&id=${s_pixel_id}" -O ${s_pixel_file} && rm -rf /tmp/cookies.txt

echo "Unziping pixelstreaming archive..."
unzip $s_pixel_file 

rm $s_pixel_file
echo "Deleted the pixelstreaming archive."

if [ ! -f "$s_script_pixel" ]; then
        echo $s_pixel > $s_script_pixel
        chmod +x $s_script_pixel
        echo "Created the pixelstreaming script."
fi

if [ ! -f "$s_script_game" ]; then
        echo $s_game > $s_script_game
        chmod +x $s_script_game
        echo "Created the game script."
fi

crontab -l > tmp_cron

if ! grep -q "${s_cron_pixel}" tmp_cron ; then
        echo $s_cron_pixel >> tmp_cron
        echo "Added the pixelstreaming script to crontab"
fi

if ! grep -q "${s_cron_game}" tmp_cron ; then
        echo $s_cron_game >> tmp_cron
        echo "Added the startgame script to crontab"
fi

if ! grep -q "${s_cron_instance_id}" tmp_cron; then
        echo $s_cron_instance_id >> tmp_cron
        echo "Added the instance id script to crontab"
fi

crontab tmp_cron
echo "Updated the crontab."

rm tmp_cron
echo "Deleted the tmp_cron"


if ! [ $s_reboot = "no" ]; then
        echo "It will reboot after 5 seconds..."
        sleep 5
        echo "Good bye."
        sudo reboot
        exit
fi

echo "Do you want to reboot this computer?"

select yn in "Yes" "No"; do
        case $yn in
                Yes ) sudo reboot; break;;
                No ) exit;;
        esac
done
