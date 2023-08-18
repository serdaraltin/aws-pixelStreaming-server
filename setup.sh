#!/bin/bash

workdir=$(pwd)


user="serdaraltin"
repo="AWS-PixelStreaming-Autoupdate"
autoupdate="autoupdate"

url_autoupdate_script="https://raw.githubusercontent.com/$user/$repo/main/$autoupdate.sh"
url_autoupdate_config="https://raw.githubusercontent.com/$user/$repo/main/$autoupdate.config"
file_autoupdate_script="autoupdate.sh"
file_autoupdate_config="autoupdate.config"
path_autoupdate="${workdir}/autoupdate"

id_game="1pgpN5cUjRivHtAZLnpglHazWnfARL4Fd"
zip_game="game.zip"
dir_game="game"
file_game="game.sh"
path_game="${workdir}/${dir_game}"

id_pixelstreaming="1LiRMdsmIqOa1-7uoC7O0lVmuojvX2cQm"
zip_stream="pixelstreaming.zip"
dir_stream="pixelstreaming"

file_signal="${dir_stream}/platform_scripts/bash/Start_WithTURN_SignallingServer.sh"
file_stream_script="startstream.sh"
path_stream="${workdir}/${dir_stream}"

file_replace_script="replace.py"

file_ssl_script="ssl.sh"


#Stream script context
script_pixelstreaming="#!/bin/bash
SHELL=/bin/bash
echo "'$(ec2metadata --instance-id) > '${workdir}/${dir_game}'/instance_id'" &&
${workdir}/${dir_game}/${file_game} -AudioMixer -PixelStreamingIP=localhost -PixelStreamingPort=8888 -RenderOffScreen -ForceRes -ResX=1920 -ResY=1080 > ${path_game}/log &
${path_stream}/${file_ssl_script} &
${workdir}/${file_signal} > ${path_stream}/log &"


cron_autoupdate="@reboot cd ${path_autoupdate} && bash ${file_autoupdate_script} > ${path_autoupdate}/log"
cron_stream="@reboot cd ${path_stream} && bash ${file_stream_script}"
cron_shutdown="@reboot shutdown -P +20"


while getopts u:r: option
do 
    case "${option}" 
    in
        u)arg_update=${OPTARG};;
        r)arg_reboot=${OPTARG};;
    esac
done

if [ -z "$arg_update" ]; then
        echo "Installing requireed packages..."
        sudo apt update -y
        sudo apt install certbot -y
        sudo apt install unzip -y
        sudo apt install zip -y
        sudo apt install jq -y
        sudo apt install nvidia-driver-515 nvidia-dkms-515 -y
        
        sudo systemctl enable cron
fi

if ! [ -z "$arg_update" ]; then
        id_gameW=$arg_update
        echo "Game will be updated."
        rm -rf ${dir_game}
fi

confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id='${id_game} -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')
echo $confirm
echo "Downloading Game..."
wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$confirm&id=${id_game}" -O ${zip_game} && rm -rf /tmp/cookies.txt

echo "Unziping game script..."
unzip -o ${zip_game} -d ${path_game}

rm $zip_game
echo "Deleted the game zip."

if ! [ -z "$arg_update" ]; then
        echo "Game has been updated."
        echo "It will reboot after 5 seconds..."
        sleep 5
        echo "Good bye."
        sudo reboot
        exit
fi

confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id='${id_pixelstreaming} -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')
echo $confirm
echo "Downloading Custom PixelStreaming script..."
wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$confirm&id=${id_pixelstreaming}" -O ${zip_stream} && rm -rf /tmp/cookies.txt

echo "Unziping pixelstreaming script..."
unzip -o ${zip_stream} -d ${workdir}


rm $zip_stream
echo "Deleted the pixelstreaming script."


if [ ! -f "$path_stream/${file_stream_script}" ]; then
        while IFS= read -r line; do
                echo "$line" >> "$path_stream/${file_stream_script}"
        done <<< "${script_pixelstreaming}"
        chmod +x "$path_stream/${file_stream_script}"
        echo "Created the stream script."
fi

if [ ! -f "$path_stream/${file_replace_script}" ]; then
script_replace="import sys
ip = sys.argv[1]
print(ip.replace('"."', '"-"'))" 
        while IFS= read -r line; do
                echo "$line" >> $path_stream/${file_replace_script}
        done <<< "$script_replace"

chmod +x "$path_stream/${file_replace_script}"
echo "Created the replace script."

fi

if [ ! -f "$path_stream/${file_ssl_script}" ]; then
script_ssl="#!/bin/bash
ip=$(curl http://checkip.amazonaws.com)
domain="testalesdigi.xyz"
subname="'$(python3 '${path_stream}/${file_replace_script}' $ip)'"
subdomain="'$subname.$domain'"

"'sudo certbot certonly --standalone --agree-tos --preferred-challenges http -d $subdomain --non-interactive -m ssl-certificate@digitales.com.tr'"

sudo mkdir ${path_stream}/certificates/
sudo cp /etc/letsencrypt/live/$subdomain/fullchain.pem ${path_stream}/certificates/client-cert.pem
sudo cp /etc/letsencrypt/live/$subdomain/privkey.pem ${path_stream}/certificates/client-key.pem"

        while IFS= read -r line; do
                echo "$line" >> $path_stream/${file_ssl_script}
        done <<< "$script_ssl"

chmod +x "$path_stream/${file_ssl_script}"
echo "Created the ssl script."

fi

if [ ! -f "${path_autoupdate}/${file_autoupdate_script}" ]; then
        mkdir "${path_autoupdate}"
        wget "${url_autoupdate_script}" -O "${path_autoupdate}/${file_autoupdate_script}"
        wget "${url_autoupdate_config}" -O "${path_autoupdate}/${file_autoupdate_config}"
        chmod +x "${path_autoupdate}/${file_autoupdate_script}"
        echo "Downloaded the autoupdate script."
fi

sudo chmod u+s /sbin/shutdown

crontab -l > tmp_cron

if ! grep -q "${cron_autoupdate}" tmp_cron ; then
        echo $cron_autoupdate >> tmp_cron
fi

if ! grep -q "${cron_stream}" tmp_cron ; then
        echo $cron_stream >> tmp_cron
fi

if ! grep -q "${cron_shutdown}" tmp_cron ; then
        echo $cron_shutdown >> tmp_cron
fi


echo "Added the all script to crontab."

crontab tmp_cron
echo "Updated the crontab."

rm tmp_cron
echo "Deleted the tmp_cron"

echo "Do you want to reboot this computer?"

select yn in "Yes" "No"; do
        case $yn in
                Yes ) sudo reboot; break;;
                No ) exit;;
        esac
done
