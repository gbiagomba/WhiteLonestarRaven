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
current_time=$(date "+%Y.%m.%d-%H.%M.%S")
TodaysYEAR=$(date +%Y)
wrkpth=$PWD
targets=$1
prj_name=$2

# Setting Envrionment
mkdir -p $wrkpth/tools/nmap $wrkpth/tools/masscan

# Requesting target file name or checking the target file exists & requesting the project name
if [ -z $targets ]; then
    echo "What is the name of the targets file? The file with all the IP addresses or FQDNs?"
    read targets
    echo
elif [ ! -e $targets ]; then
    echo "File not found! Try again!"
    exit
fi

if [ -z $prj_name ]; then
    echo "What is the name of the project or SAS?"
    read prj_name
    echo
elif [ -z $prj_name ]; then
    prj_name=`echo $RANDOM`
fi

# ------------------------------------------------------
# HOST DISCOVERY - Pingsweep using ICMP echo, netmask, timestamp
# ------------------------------------------------------
echo "--------------------------------------------------"
echo "Nmap Pingsweep - ICMP echo, netmask, timestamp & TCP SYN, and UDP"
echo "--------------------------------------------------"
nmap -T5 --host-timeout 30m --randomize-hosts -PA "21-23,25,53,80,88,110,111,135,139,443,445,3389,8080" -PE -PM -PP -PS "21-23,25,53,80,88,110,111,135,139,443,445,3389,8080" -PU "42,53,67-68,88,111,123,135,137,138,161,500,3389,5355" -PY "22,80,179,5060" -R --reason --resolve-all -sn -iL $targets -oA $wrkpth/tools/nmap/$prj_name-nmap_pingsweep-$current_time
nmap -T5 --host-timeout 30m --randomize-hosts -PA"21-23,25,53,80,88,110,111,135,139,443,445,3389,8080" -PE -PS"21-23,25,53,80,88,110,111,135,139,443,445,3389,8080" -PU"42,53,67-68,88,111,123,135,137,138,161,500,3389,5355" -PY"22,80,179,5060" -T5 -R --reason --resolve-all -sn -6 -iL $targets -oA $wrkpth/tools/nmap/$prj_name-nmap_pingsweepv6-$current_time
if [ -s $wrkpth/tools/nmap/$prj_name-nmap_pingsweep-$current_time.gnmap ] && [ -r $wrkpth/tools/nmap/$prj_name-nmap_pingsweepv6-$current_time.gnmap ]; then
    cat $wrkpth/tools/nmap/$prj_name-nmap_pingsweep-$current_time.gnmap $wrkpth/tools/nmap/$prj_name-nmap_pingsweepv6-$current_time | grep Up | cut -d ' ' -f 2 | sort -u >> $wrkpth/tools/nmap/$prj_name-livehosts-$current_time.list
    cat $wrkpth/tools/nmap/$prj_name-nmap_pingsweep-$current_time.gnmap $wrkpth/tools/nmap/$prj_name-nmap_pingsweepv6-$current_time | cut -d "(" -f 2 | cut -d ")" -f 1 | sort -u >> $wrkpth/tools/nmap/$prj_name-livehosts-$current_time.list
elif [ ! -s $wrkpth/tools/nmap/$prj_name-nmap_pingsweep-$current_time.gnmap  && [ ! -s $wrkpth/tools/nmap/$prj_name-nmap_pingsweepv6-$current_time ]; then
    echo "$wrkpth/tools/nmap/$prj_name-nmap_pingsweep-$current_time.gnmap does not exist"
    echo "Check stdout (terminal output) for any errors in nmap & check internet connection"
    exit
fi
echo

# ------------------------------------------------------
# PORT SCANNING - Full TCP SYN & UDP scan on live targets
# ------------------------------------------------------
echo "--------------------------------------------------"
echo "Performing portknocking scan using Nmap"
echo "--------------------------------------------------"
echo "Full TCP SYN & UDP scan on live targets"
nmap -A -Pn -R --reason --resolve-all -sSUV --randomize-hosts -T4 --open -F --scripts "vulners,vuln,auth,brute,targets-xml" --script-args=newtargets,iX=$wrkpth/tools/nmap/$prj_name-nmap_pingsweep-$current_time.xml -oA $wrkpth/tools/nmap/$prj_name-nmap_fs-$current_time
nmap -6 -A -Pn -R --reason --resolve-all -sSUV --randomize-hosts -T4 --open -F --scripts "vulners,vuln,auth,brute,targets-xml" --script-args=newtargets,iX=$wrkpth/tools/nmap/$prj_name-nmap_pingsweepv6-$current_time.xml -oA $wrkpth/tools/nmap/$prj_name-nmap_fs6-$current_time
if [ -r $wrkpth/tools/nmap/$prj_name-nmap_fs-$current_time.gnmap ] || [ -r $wrkpth/tools/nmap/$prj_name-nmap_fs6-$current_time.gnmap ]; then
    for i in domain http imap isakmp microsoft-ds ms-wbt-server netbios-ssn smtp snmp ssh ssl telnet; do cat $wrkpth/tools/nmap/$prj_name-nmap_fs-$current_time.gnmap $wrkpth/tools/nmap/$prj_name-nmap_fs6-$current_time.gnmap | grep $i | grep open | cut -d ' ' -f 2 > $wrkpth/tools/nmap/$prj_name-`echo $i | tr '[:lower:]' '[:upper:]'`$current_time.list; done
    for i in `ls | grep xml`; do python3 /opt/nmap-converter/nmap-converter.py -o "$wrkpth/tools/nmap/$prj_name-nmap_fs$current_time.xlsx" "$i"; python3 /opt/nmaptocsv/nmaptocsv.py -x "$i" -S -d "," -n -o $wrkpth/tools/nmap/$i$current_time.csv; done
    batea -A $wrkpth/tools/nmap/$prj_name-*.xml > $wrkpth/tools/nmap/$prj_name-batea$current_time.json
elif [ ! -s $wrkpth/tools/nmap/$prj_name-nmap_fs-$current_time.gnmap ] && [ ! -s $wrkpth/tools/nmap/$prj_name-nmap_fs6-$current_time.gnmap ]; then
    echo "$wrkpth/tools/nmap/$prj_name-nmap_fs-$current_time.gnmap does not exist"
    echo "Check stdout (terminal output) for any errors in nmap & check internet connection"
    exit
echo

echo "--------------------------------------------------"
echo "Performing portknocking scan using Nmap"
echo "--------------------------------------------------"
echo "Full TCP SYN & UDP scan on live targets"
masscan --rate 1000 --banners --open-only --retries 3 -p 0-65535 -iL $wrkpth/tools/nmap/$prj_name-livehosts-$current_time.list -oA $wrkpth/tools/masscan/$prj_name-masscan-$current_time.list

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
for var in TodaysYEAR wrkpth wrktmp targets ; do unset $var; done
unset var
exit