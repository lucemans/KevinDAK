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

exitstatus=" "
exitstatus+=$("${cmd[@]}")
exitstatus+=" "

if [[ $exitstatus = "  " ]]; then
	clear
	echo "[KevinDAK] Installation aborted."
	exit 0
fi
clear

# chromium browser
if [[ $exitstatus == *" 1 "* ]]; then
	echo "[KevinDAK] Installing Chromium Browser"
	apt install chromium-browser
else
	echo "[KevinDAK] Skipping Chromium install"
fi

if [[ $exitstatus == *" 2 "* ]]; then
	echo "[KevinDAK] Installing Unclutter (This feature might not work to its fullest extend)"
	apt install unclutter
else
	echo "[KevinDAK] Skipping Unclutter install"
fi

cmd=(dialog --stdout --title "Enter the WEB-URL" --inputbox "URL you want to connect to:" 0 0)
url=$("${cmd[@]}")
clear

cd /
mkdir kevin
chmod 777 /kevin

echo "#!/bin/bash" &> /kevin/kevindak_start.sh
echo "/usr/bin/chromium-browser --no-first-run --window-size=1920,1080 --noerrdialogs --start-fullscreen --start-maximized --disable-notifications --disable-infobars --kiosk --incognito "$url >> /kevin/kevindak_start.sh
chmod 777 /kevin/kevindak_start.sh

echo #!/bin/sh
echo "xset s off" &> /kevin/kevindak_init.sh
echo "xset -dpms" >> /kevin/kevindak_init.sh
echo "xset s noblank" >> /kevin/kevindak_init.sh
echo "xinit /bin/su pi /kevin/kevindak_start.sh" >> /kevin/kevindak_init.sh
chmod 777 /kevin/kevindak_init.sh

if [[ $exitstatus == *" 3 "* ]]; then
	echo "[KevinDAK] Setting up install script reference (rc.local)"
	rcfile=$(cat /etc/rc.local)
	if [[ $rcfile == *"/bin/sh /kevin/kevindak_init.sh"* ]]; then
		echo "[KevinDAK] Already setup startup script found, not interfering"
	else
		tail -n 1 "/etc/rc.local" | wc -c | xargs -I {} truncate "/etc/rc.local" -s -{}
		rcfile=$(cat /etc/rc.local)
		while [[ $rcfile =~ .*exit\s0[\w\s]*$ ]]; do
			tail -n 1 "/etc/rc.local" | wc -c | xargs -I {} truncate "/etc/rc.local" -s -{}
			rcfile=$(cat /etc/rc.local)
		done
		echo "/bin/sh /kevin/kevindak_init.sh" >> /etc/rc.local
		echo "exit 0" >> /etc/rc.local
	fi
else
	echo "[KevinDAK] Skipping Autoboot Install script (rc.local)"
fi

if [[ $exitstatus == *" 4 "* ]]; then
	echo "[KevinDAK] Disabling Voltage Warning"

	settingsFile=$(cat /boot/config.txt)
        if [[ $settingsFile == *"avoid_warnings="* ]]; then
                echo "[KevinDAK] Option AVOID_WARNINGS is already specified"
        else
                echo "avoid_warnings=1" >> /boot/config.txt
        fi


else
	echo "[KevinDAK] Skipping Voltage Warning Removal"
fi
