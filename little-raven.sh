#!/usr/bin/env bash
# Author: Gilles Biagomba
# Program: little-raven.sh
# Description: This script designed to perform a pingsweep & portknock scan of a target network.\n
#              First it performs a comprehensive pingsweep across ICMP, TCP and UDP using nmap.\n
#              Then using nmap, it performs a portknock of the top one-hundred (100) ports.\n
#              Lastly, results are compressesed into a file.\n
#              FOOTNOTE: This is the light variant of the script.\n
# References:
# https://www.codenamegenerator.com/
# https://www.fantasynamegenerators.com/code-names.php

trap "echo Booh!" SIGINT SIGTERM

echo "
 ___      ___   _______  _______  ___      _______         ______    _______  __   __  _______  __    _ 
|   |    |   | |       ||       ||   |    |       |       |    _ |  |   _   ||  | |  ||       ||  |  | |
|   |    |   | |_     _||_     _||   |    |    ___| ____  |   | ||  |  |_|  ||  |_|  ||    ___||   |_| |
|   |    |   |   |   |    |   |  |   |    |   |___ |____| |   |_||_ |       ||       ||   |___ |       |
|   |___ |   |   |   |    |   |  |   |___ |    ___|       |    __  ||       ||       ||    ___||  _    |
|       ||   |   |   |    |   |  |       ||   |___        |   |  | ||   _   | |     | |   |___ | | |   |
|_______||___|   |___|    |___|  |_______||_______|       |___|  |_||__| |__|  |___|  |_______||_|  |__|
"

# Checking if the user is root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Declaring variables
TodaysDAY=$(date +%m-%d)
TodaysYEAR=$(date +%Y)
wrkpth=$(pwd)
targets=$1

# Setting Envrionment
mkdir -p $wrkpth/Nmap/

# Requesting target file name or checking the target file exists & requesting the project name
if [ -z $targets ]; then
    echo "What is the name of the targets file? The file with all the IP addresses or FQDNs?"
    read targets
    echo
elif [ ! -e $targets ]; then
    echo "File not found! Try again!"
    exit
fi

echo "What is the name of the project or SAS?"
read prj_name
echo

if [ -z $prj_name ]; then
    prj_name=`echo $RANDOM`
fi

# ------------------------------------------------------
# HOST DISCOVERY
# ------------------------------------------------------
# Nmap - Pingsweep using ICMP echo, netmask, timestamp
echo
echo "--------------------------------------------------"
echo "Nmap Pingsweep - ICMP echo, netmask, timestamp & TCP SYN, and UDP"
echo "--------------------------------------------------"
nmap -PA"21-23,25,53,80,88,110,111,135,139,443,445,3389,8080" -PE -PM -PP -PS"21-23,25,53,80,88,110,111,135,139,443,445,3389,8080" -PU"42,53,67-68,88,111,123,135,137,138,161,500,3389,5355" -PY"22,80,179,5060" -T5 -R --reason --resolve-all -sn -iL $targets -oA $wrkpth/Nmap/$prj_name-nmap_pingsweep-$TodaysDAY-$TodaysYEAR
cat `ls $wrkpth/Nmap/$prj_name- | grep pingsweep-$TodaysDAY-$TodaysYEAR | grep gnmap` | grep Up | cut -d ' ' -f 2 | sort } uniq >> $wrkpth/Nmap/$prj_name-livehosts-$TodaysDAY-$TodaysYEAR
echo

# ------------------------------------------------------
# PORT SCANNING
# ------------------------------------------------------
# Nmap - Full TCP SYN & UDP scan on live targets
echo "--------------------------------------------------"
echo "Performing portknocking scan using Nmap"
echo "--------------------------------------------------"
echo
echo "Full TCP SYN & UDP scan on live targets"
nmap -A -Pn -R --reason --resolve-all -sSUV -T4 --open -F -iL $wrkpth/Nmap/$prj_name-livehosts-$TodaysDAY-$TodaysYEAR -oA $wrkpth/Nmap/$prj_name-nmap_portknock-$TodaysDAY-$TodaysYEAR
for i in domain http imap isakmp microsoft-ds ms-wbt-server netbios-ssn smtp snmp ssh ssl telnet; do cat $wrkpth/Nmap/$prj_name-nmap_portknock-$TodaysDAY-$TodaysYEAR | grep $i | grep open | cut -d ' ' -f 2 > $wrkpth/Nmap/$prj_name-`echo $i | tr '[:lower:]' '[:upper:]'`-$TodaysDAY-$TodaysYEAR; done
for i in `ls | grep xml`; do python3 /opt/nmap-converter/nmap-converter.py -o "$wrkpth/Nmap/$prj_name-nmap_portknock-$TodaysDAY-$TodaysYEAR.xlsx" "$i"; python3 /opt/nmaptocsv/nmaptocsv.py -x "$i" -S -d "," -n -o $wrkpth/Nmap/$i-$TodaysDAY-$TodaysYEAR.csv; done
batea -A $wrkpth/Nmap/$prj_name-*.xml > $wrkpth/Nmap/$prj_name-batea-$TodaysDAY-$TodaysYEAR.json

# ------------------------------------------------------
# CLEANING HOUSE
# ------------------------------------------------------

# Cleaning
echo "--------------------------------------------------"
echo "Gift wrapping everything and putting a bowtie on it!"
echo "--------------------------------------------------"
# Empty file cleanup
find $wrkpth/Nmap -type d,f -empty | xargs rm -rf

# Zipping the rest up
zip -ru9 $wrkpth/$prj_name-$TodaysYEAR.zip $wrkpth/Nmap

# Uninitializing variables
for var in TodaysDAY TodaysYEAR wrkpth wrktmp targets ; do unset $var; done
unset var