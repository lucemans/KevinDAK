#!/bin/bash

clear
echo "=========="
echo "KevinDAK Installer by Lucemans"
echo ""
echo "WARNING: This script was designed for use with a RaspberryPI 3/4,"
echo "if you are running this on any other device proceed at YOUR OWN RISK"
echo "=========="
echo ""
echo ""

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo "[KevinDAK] Pulling latest repositories"

#apt update

echo "[KevinDAK] Detecting dialog installation"
dpkg -s dialog &> /dev/null
if [[ $? -ne 0 ]]; then
	echo "[KevinDAK] Dialog not found, installing now"
	apt install dialog
fi

echo "[KevinDAK] Launching dialog"
dialog --title "KevinDAK Installer" --msgbox "Welcome to the KevinDAK DAKBoard installer for the RaspberryPI 3/4" 10 50

cmd=(dialog --ok-label "Lets do this!" --cancel-label "Ive changed my mind" --stdout --checklist "Here is a list of actions this script is going to do, if for some reason you dont want to perform a certain step, use <space> to disable it:" 0 0 0  1 "Install Chromium" on 2 "Remove Cursor using unclutter" on  3 "Setup Startup script (rc.local)" on  4 "Remove Voltage Warning Overlay" on)

exitstatus=$("${cmd[@]}")

echo $exitstatus

# chromium browser


# cursor removal

cmd=(dialog --stdout --title "Enter the WEB-URL" --inputbox "URL you want to connect to:" 0 0)
url=$("${cmd[@]}")
clear
echo $url
# startup script



# voltage warning


# rc.local setup
