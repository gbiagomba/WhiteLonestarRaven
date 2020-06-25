#!/usr/bin/env bash
# Checking dependencies - halberd, sublist3r, theharvester, metagoofil, nikto, dirb, masscan, nmap, sn1per, 
#                         wapiti, sslscan, testssl, jexboss, xsstrike, grabber, golismero, docker, wappalyzer
#                         sshscan, ssh-audit, dnsrecon, retirejs, python3, gobuster, seclists

# Setting up variables
OS_CHK=$(cat /etc/os-release | grep -o debian)

# Checking user is root & Ensuring system is debian based
if [ "$EUID" -ne 0 ]
    then echo "Please run as root"
    exit
elif [ "$OS_CHK" != "debian" ]; then
    echo "Unfortunately this install script was written for debian based distributions only, sorry!"
    exit
fi

# Setting sudo to HOME variable to target user's home dir
SUDOH="sudo -H"

# Downloading the Vulners Nmap Script
cd /opt/
git clone https://github.com/vulnersCom/nmap-vulners
cp /opt/vulnersCom/nmap-vulners/vulners.nse /usr/share/nmap/scripts/

# Downloading the VulScan Nmap Script
cd /opt/
git clone https://github.com/scipag/VulScan
cd VulScan
for i in https://www.computec.ch/projekte/vulscan/download/cve.csv https://www.computec.ch/projekte/vulscan/download/exploitdb.csv https://www.computec.ch/projekte/vulscan/download/openvas.csv https://www.computec.ch/projekte/vulscan/download/osvdb.csv https://www.computec.ch/projekte/vulscan/download/scipvuldb.csv https://www.computec.ch/projekte/vulscan/download/securityfocus.csv https://www.computec.ch/projekte/vulscan/download/securitytracker.csv https://www.computec.ch/projekte/vulscan/download/xforce.csv; do
    wget $i
done
ln -s `pwd`/VulScan /usr/share/nmap/scripts/vulscan

# Downloading & installing nmap-converter
cd /opt/
git clone https://github.com/mrschyte/nmap-converter
cd nmap-converter
$SUDOH pip3 install -r requirements.txt

# Downloading & installing nmaptocsv
cd /opt/
git clone https://github.com/maaaaz/nmaptocsv
cd nmaptocsv
$SUDOH pip3 install -r requirements.txt

# Downloading & installing batea
cd /opt/
git clone git@github.com:delvelabs/batea.git
cd batea
$SUDOH python3 setup.py sdist
$SUDOH pip3 install -r requirements.txt
$SUDOH pip3 install -e .

# Done
echo finished!