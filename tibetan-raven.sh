#!/usr/bin/env bash
# Author: Gilles Biagomba
# Program: tibetan-raven.sh
# Description: This script designed to perform a pingsweep & portknock scan of a target network.\n
#              First it performs a comprehensive pingsweep across ICMP, TCP and UDP using nmap.\n
#              Then using nmap, it performs a portknock of all 65k ports.\n
#              Lastly, results are compressesed into a file.\n
#              FOOTNOTE: This is the heavy variant of the script.\n
# References:
# https://www.codenamegenerator.com/
# https://www.fantasynamegenerators.com/code-names.php

trap "echo Booh!" SIGINT SIGTERM

echo "
 _______  ___   _______  _______  _______  _______  __    _         ______    _______  __   __  _______  __    _ 
|       ||   | |  _    ||       ||       ||   _   ||  |  | |       |    _ |  |   _   ||  | |  ||       ||  |  | |
|_     _||   | | |_|   ||    ___||_     _||  |_|  ||   |_| | ____  |   | ||  |  |_|  ||  |_|  ||    ___||   |_| |
  |   |  |   | |       ||   |___   |   |  |       ||       ||____| |   |_||_ |       ||       ||   |___ |       |
  |   |  |   | |  _   | |    ___|  |   |  |       ||  _    |       |    __  ||       ||       ||    ___||  _    |
  |   |  |   | | |_|   ||   |___   |   |  |   _   || | |   |       |   |  | ||   _   | |     | |   |___ | | |   |
  |___|  |___| |_______||_______|  |___|  |__| |__||_|  |__|       |___|  |_||__| |__|  |___|  |_______||_|  |__|
"

# ------------------------------------------------------
# SETTING UP
# ------------------------------------------------------

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

# Check that nmao output file exists
function fileExists {
  if [ ! -s $wrkpth/Nmap/$prj_name-nmap_pingsweep-$TodaysDAY-$TodaysYEAR.gnmap ]; then
    echo "$wrkpth/Nmap/$prj_name-nmap_pingsweep-$TodaysDAY-$TodaysYEAR.gnmap does not exist"
    echo "Check stdout (terminal output) for any errors in nmap & check internet connection"
    exit
  fi
}

echo "What is the name of the project or SAS?"
read prj_name
echo

if [ -z $prj_name ]; then
    prj_name=`echo $RANDOM`
fi

# ------------------------------------------------------
# HOST DISCOVERY
# ------------------------------------------------------

# Nmap - Pingsweep using ICMP echo, timestamp, netmask
echo "--------------------------------------------------"
echo "Nmap Pingsweep - ICMP echo, netmask, timestamp"
echo "--------------------------------------------------"
nmap -R --reason --resolve-all -sn -PE -iL $targets -oA $wrkpth/Nmap/$prj_name-icmpecho-$TodaysDAY-$TodaysYEAR
nmap -R --reason --resolve-all -sn -PP -iL $targets -oA $wrkpth/Nmap/$prj_name-icmptimestamp-$TodaysDAY-$TodaysYEAR
nmap -R --reason --resolve-all -sn -PM -iL $targets -oA $wrkpth/Nmap/$prj_name-icmpnetmask-$TodaysDAY-$TodaysYEAR
echo

# Parsing Systems that responded to ping (finding)
cat `ls $wrkpth/Nmap/ | grep $prj_name | grep gnmap | grep $TodaysDAY-$TodaysYEAR` | grep Up | cut -d ' ' -f 2 | sort | uniq >> $wrkpth/Nmap/$prj_name-live-$TodaysDAY-$TodaysYEAR
fileExists

# Nmap - Pingsweep using TCP SYN/ACK, UDP and SCTP
echo "--------------------------------------------------"
echo "Nmap Pingsweep -  TCP SYN/ACK, UDP and SCTP"
echo "--------------------------------------------------"
nmap -R --reason --resolve-all -sn -PS "21,22,23,25,53,80,88,110,111,135,139,443,445,8080" -iL $wrkpth/Nmap/$prj_name-live-$TodaysDAY-$TodaysYEAR -oA $wrkpth/Nmap/$prj_name-pingsweepTCP-$TodaysDAY-$TodaysYEAR
nmap -R --reason --resolve-all -sn -PU "42,53,67-68,88,111,123,135,137,138,161,500,3389,5355" -iL $wrkpth/Nmap/$prj_name-live-$TodaysDAY-$TodaysYEAR -oA $wrkpth/Nmap/$prj_name-pingsweepUDP-$TodaysDAY-$TodaysYEAR
nmap -R --reason --resolve-all -sn -PA "21-23,25,53,80,88,110,111,135,139,443,445,3389,8080" -iL $wrkpth/Nmap/$prj_name-live-$TodaysDAY-$TodaysYEAR -oA $wrkpth/Nmap/$prj_name-pingsweepTCP-ACK-$TodaysDAY-$TodaysYEAR
nmap -R --reason --resolve-all -sn -PY "22,80,179,5060" -iL $wrkpth/Nmap/$prj_name-pingresponse-$TodaysDAY-$TodaysYEAR -oA $wrkpth/Nmap/$prj_name-pingsweepSCTP-$TodaysDAY-$TodaysYEAR
cat `ls $wrkpth/Nmap/ | grep $prj_name | grep pingsweep | grep $TodaysDAY-$TodaysYEAR | grep gnmap` | grep Up | cut -d ' ' -f 2 >> $wrkpth/Nmap/$prj_name-live-$TodaysDAY-$TodaysYEAR
fileExists

# Create unique live-$TodaysDAY-$TodaysYEAR hosts file
cat $wrkpth/Nmap/$prj_name-live-$TodaysDAY-$TodaysYEAR | sort | uniq > $wrkpth/Nmap/$prj_name-livehosts-$TodaysDAY-$TodaysYEAR
cat $wrkpth/Nmap/$prj_name-live-$TodaysDAY-$TodaysYEAR | grep -E "(\.gov|\.us|\.net|\.com|\.edu|\.org|\.biz|\.io|\.info)" | sort | uniq >> $wrkpth/Nmap/$prj_name-livehosts-$TodaysDAY-$TodaysYEAR

# ------------------------------------------------------
# PORT SCANNING
# ------------------------------------------------------

# Nmap - Full TCP SYN scan on live
nmap -R --reason --resolve-all -sSV -PN -A -T4 -p0-65535 -iL $wrkpth/Nmap/$prj_name-livehosts-$TodaysDAY-$TodaysYEAR -oA $wrkpth/Nmap/$prj_name-TCPdetails-$TodaysDAY-$TodaysYEAR --script=rdp-enum-encryption,ssl-enum-ciphers,vulners,vulscan/vulscan.nse
if [ -r$wrkpth/Nmap/$prj_name-TCPdetails-$TodaysDAY-$TodaysYEAR.gnmap ] && [ -s$wrkpth/Nmap/$prj_name-TCPdetails-$TodaysDAY-$TodaysYEAR.gnmap ]; then
  cat $wrkpth/Nmap/$prj_name-TCPdetails-$TodaysDAY-$TodaysYEAR.gnmap | grep smtp | grep open | cut -d ' ' -f 2 > $wrkpth/Nmap/$prj_name-SMTP-$TodaysDAY-$TodaysYEAR
  cat $wrkpth/Nmap/$prj_name-TCPdetails-$TodaysDAY-$TodaysYEAR.gnmap | grep domain | grep open | cut -d ' ' -f 2 > $wrkpth/Nmap/$prj_name-DNS-$TodaysDAY-$TodaysYEAR
  cat $wrkpth/Nmap/$prj_name-TCPdetails-$TodaysDAY-$TodaysYEAR.gnmap | grep telnet | grep open | cut -d ' ' -f 2 > $wrkpth/Nmap/$prj_name-telnet-$TodaysDAY-$TodaysYEAR
  cat $wrkpth/Nmap/$prj_name-TCPdetails-$TodaysDAY-$TodaysYEAR.gnmap | grep microsoft-ds | grep open | cut -d ' ' -f 2 > $wrkpth/Nmap/$prj_name-SMB-$TodaysDAY-$TodaysYEAR
  cat $wrkpth/Nmap/$prj_name-TCPdetails-$TodaysDAY-$TodaysYEAR.gnmap | grep netbios-ssn | grep open | cut -d ' ' -f 2 > $wrkpth/Nmap/$prj_name-netbios-$TodaysDAY-$TodaysYEAR
  cat $wrkpth/Nmap/$prj_name-TCPdetails-$TodaysDAY-$TodaysYEAR.gnmap | grep http | grep open | cut -d ' ' -f 2 > $wrkpth/Nmap/$prj_name-HTTP-$TodaysDAY-$TodaysYEAR
  cat $wrkpth/Nmap/$prj_name-TCPdetails-$TodaysDAY-$TodaysYEAR.gnmap | grep ssh | grep open | cut -d ' ' -f 2 > $wrkpth/Nmap/$prj_name-SSH-$TodaysDAY-$TodaysYEAR
  cat $wrkpth/Nmap/$prj_name-TCPdetails-$TodaysDAY-$TodaysYEAR.gnmap | grep ssl | grep open | cut -d ' ' -f 2 > $wrkpth/Nmap/$prj_name-SSL-$TodaysDAY-$TodaysYEAR
  cat $wrkpth/Nmap/$prj_name-TCPdetails-$TodaysDAY-$TodaysYEAR.gnmap | grep ms-wbt-server | grep open | cut -d ' ' -f 2 > $wrkpth/Nmap/$prj_name-RDP-$TodaysDAY-$TodaysYEAR
  cat $wrkpth/Nmap/$prj_name-TCPdetails-$TodaysDAY-$TodaysYEAR.gnmap | grep imap | grep open | cut -d ' ' -f 2 > $wrkpth/Nmap/$prj_name-IMAP-$TodaysDAY-$TodaysYEAR
elif [ ! -s $wrkpth/Nmap/$prj_name-TCPdetails-$TodaysDAY-$TodaysYEAR.gnmap ]; then
    echo "$wrkpth/Nmap/$prj_name-TCPdetails-$TodaysDAY-$TodaysYEAR.gnmap does not exist"
    echo "Check stdout (terminal output) for any errors in nmap & check internet connection"
    exit
  fi

# Nmap - Default UDP scan on live
nmap -R --reason --resolve-all -sUV -PN -T4 --host-timeout 30m -iL $wrkpth/Nmap/$prj_name-livehosts-$TodaysDAY-$TodaysYEAR -oA $wrkpth/Nmap/$prj_name-UDPdetails-$TodaysDAY-$TodaysYEAR
if [ -r cat $wrkpth/Nmap/$prj_name-UDPdetails-$TodaysDAY-$TodaysYEAR.gnmap ] && [ - s cat $wrkpth/Nmap/$prj_name-UDPdetails-$TodaysDAY-$TodaysYEAR.gnmap ]; then
  cat $wrkpth/Nmap/$prj_name-UDPdetails-$TodaysDAY-$TodaysYEAR.gnmap | grep snmp | grep open | cut -d ' ' -f 2 > $wrkpth/Nmap/$prj_name-SNMP-$TodaysDAY-$TodaysYEAR
  cat $wrkpth/Nmap/$prj_name-UDPdetails-$TodaysDAY-$TodaysYEAR.gnmap | grep isakmp | grep open | cut -d ' ' -f 2 > $wrkpth/Nmap/$prj_name-ISAKMP-$TodaysDAY-$TodaysYEAR
elif [ ! -s $wrkpth/Nmap/$prj_name-UDPdetails-$TodaysDAY-$TodaysYEAR.gnmap ]; then
    echo "$wrkpth/Nmap/$prj_name-UDPdetails-$TodaysDAY-$TodaysYEAR.gnmap does not exist"
    echo "Check stdout (terminal output) for any errors in nmap & check internet connection"
    exit
fi

# Nmap - Reporting
for i in `ls | grep xml`; do 
    python3 /opt/nmap-converter/nmap-converter.py -o "$wrkpth/Nmap/$prj_name-nmap_portknock-$TodaysDAY-$TodaysYEAR.xlsx" "$i"
    python3 /opt/nmaptocsv/nmaptocsv.py -x "$i" -S -d "," -n -o $wrkpth/Nmap/$i-$TodaysDAY-$TodaysYEAR.csv
done
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