#!/usr/bin/env bash
# Checking dependencies - halberd, sublist3r, theharvester, metagoofil, nikto, dirb, masscan, nmap, sn1per, 
#                         wapiti, sslscan, testssl, jexboss, xsstrike, grabber, golismero, docker, wappalyzer
#                         sshscan, ssh-audit, dnsrecon, retirejs, python3, gobuster, seclists

# Checking user is root & Ensuring system is debian based
if [ "$EUID" -ne 0 ]
    then echo "Please run as root"
    exit
fi

# Setting up variables
wrkpth="$PWD"
SUDOH="sudo -H"


# Function banner
function banner
{
    echo "--------------------------------------------------"
    echo "Installing $1"
    echo "--------------------------------------------------"
}

# Figuring out the default package monitor
if hash apt 2> /dev/null; then
  PKGMAN_INSTALL="apt install -y"
  PKGMAN_UPDATE="apt update"
  PKGMAN_UPGRADE="apt upgrade -y"
  PKGMAN_RM="apt remove -y"
elif hash yum; then
  PKGMAN_INSTALL="yum install -y"
  PKGMAN_UPDATE="yum update"
  PKGMAN_UPGRADE="yum upgrade -y"
  PKGMAN_RM="yum remove -y"
elif hash snap 2> /dev/null; then
  PKGMAN_INSTALL="snap install"
  PKGMAN_UPGRADE="snap refresh"
  PKGMAN_UPDATE=$PKGMAN_UPGRADE
  PKGMAN_RM="snap remove"
elif hash brew 2> /dev/null; then
  PKGMAN_INSTALL="brew install"
  PKGMAN_UPDATE="brew update"
  PKGMAN_UPGRADE="brew upgrade"
  PKGMAN_RM="brew uninstall"
fi

# Doing the basics
banner "system updates"
$PKGMAN_UPDATE
$PKGMAN_UPGRADE

# Installing main system dependencies
for i in masscan nmap python3 python3-pip rustscan seclists unzip zip; do
    if ! hash $i 2> /dev/null; then
        banner $i
        $PKGMAN_INSTALL $i
    fi
done

# Downloading the VulScan Nmap Script
banner VulScan
git clone https://github.com/scipag/VulScan $wrkpth/VulScan
for i in https://www.computec.ch/projekte/vulscan/download/cve.csv https://www.computec.ch/projekte/vulscan/download/exploitdb.csv https://www.computec.ch/projekte/vulscan/download/openvas.csv https://www.computec.ch/projekte/vulscan/download/osvdb.csv https://www.computec.ch/projekte/vulscan/download/scipvuldb.csv https://www.computec.ch/projekte/vulscan/download/securityfocus.csv https://www.computec.ch/projekte/vulscan/download/securitytracker.csv https://www.computec.ch/projekte/vulscan/download/xforce.csv; do
    wget $i
done
ln -s $wrkpth/VulScan /usr/share/nmap/scripts/vulscan

# Downloading & installing nmap-converter
banner nmap-converter
git clone https://github.com/mrschyte/nmap-converter $wrkpth/nmap-converter
cd $wrkpth/nmap-converter
pip3 install -r requirements.txt --user

# Downloading & installing nmaptocsv
banner nmaptocsv
git clone https://github.com/maaaaz/nmaptocsv $wrkpth/nmaptocsv
cd $wrkpth/nmaptocsv
pip3 install -r requirements.txt --user

# Downloading & installing batea
banner batea
git clone git@github.com:delvelabs/batea.git $wrkpth/batea
cd $wrkpth/batea
python3 setup.py sdist --user
pip3 install -r requirements.txt --user
pip3 install -e . --user

# Downloading & installing batea
if [ ! -e /usr/share/seclists/ ]; then
    banner seclists
    cd /usr/share/; wget -c https://github.com/danielmiessler/SecLists/archive/master.zip -O SecList.zip; unzip SecList.zip; rm -f SecList.zip; mv SecLists-master/ /usr/share/seclists/; 
fi

# Done
echo finished!