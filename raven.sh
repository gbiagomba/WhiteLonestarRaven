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
                              ██▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓██                            
                            ██▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓██                          
                          ██▓▓▒▒▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓██                        
                        ██▓▓▒▒▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓██                      
                        ██▓▓▓▓▓▓▓▓▓▓▒▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓██                      
                      ██▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓██                    
                      ██▓▓▓▓██████▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓██████▓▓▓▓██                    
                      ██▓▓████████████▓▓▓▓▓▓▓▓▓▓▓▓▓▓████████████▓▓██                    
                    ██▒▒▓▓██████████████▓▓▒▒▓▓▒▒▓▓██████████████▓▓▓▓██                  
                    ██▓▓██████████████████▓▓▓▓▒▒██████████████████▓▓██                  
                    ██▓▓████████████████████▓▓████████████████████▓▓██                  
                    ██▓▓████░░██████████████████████████████░░████▓▓██                  
                    ██▓▓████  ██▓▓  ██████████████████  ▓▓██  ████▓▓██                  
                    ██▓▓████    ██████  ██████████  ██████    ████▓▓██                  
                    ██▓▓██████        ██████████████        ██████▓▓██                  
                  ██▓▓▓▓██████████████████████████████████████████▓▓▓▓██                
                  ██▓▓▓▓████████▒▒▒▒░░██████████████░░░░░░████████▓▓▓▓██                
                ██▓▓▓▓▒▒██████▒▒▒▒▒▒░░░░░░██████░░░░░░░░░░░░██████▓▓▓▓▓▓██              
                ██▓▓▓▓▓▓▓▓████▒▒▒▒▒▒▒▒░░░░░░██░░░░░░░░░░░░░░████▓▓▓▓▓▓▓▓██              
              ██▓▓▒▒▓▓▓▓▓▓██████▒▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░██████▓▓▓▓▓▓▓▓▓▓██            
              ██▒▒▓▓▓▓▓▓▓▓▓▓██████▒▒▒▒▒▒░░██████░░░░░░░░██████▓▓▓▓▓▓▓▓▓▓▓▓██            
              ██▓▓▓▓▓▓▓▓▓▓▓▓██████████▒▒▒▒░░░░░░░░░░██████████▓▓▓▓▓▓▓▓▓▓▓▓██            
                ██▓▓▓▓▓▓▓▓▓▓▓▓████████████▒▒░░░░████████████▓▓▓▓▓▓▓▓▓▓▓▓██              
                  ██▓▓▓▓▓▓▓▓▓▓▓▓████████▒▒██████░░████████▓▓▓▓▓▓▓▓▓▓▓▓██                
                    ██▓▓▓▓▓▓▓▓▓▓▓▓██████▒▒▒▒▒▒░░░░██████▓▓▒▒▓▓▓▓▓▓▓▓██                  
                      ████▓▓▓▓▓▓▓▓▓▓████▒▒▒▒▒▒░░░░████▓▓▓▓▓▓▓▓▓▓████                    
                          ████▓▓▓▓▓▓▓▓████▒▒░░░░████▓▓▓▓▓▓▓▓████                        
                              ██████▓▓▓▓▓▓██████▓▓▓▓▓▓██████                            
                                    ██████████████████                                  

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
source rsc/functions.sh
current_time=$(date "+%Y.%m.%d-%H.%M.%S")
MASSCAN="masscan --rate 300 --banners --open-only --retries 3 -p 0-65535"
NMAP_PING="nmap -T5 --min-rate 500 --resolve-all -PA"21-23,25,53,79,80-83,88,110,111,135,139,161,179,443,445,497,515,535,548,993,1025,1028,1029,1917,2869,3389,5000,5060,6000,8080,9001,9100,49000" -PE -PM -PP -PO -PR -PS"21-23,25,53,79,80-83,88,110,111,135,139,161,179,443,445,497,515,535,548,993,1025,1028,1029,1917,2869,3389,5000,5060,6000,8080,9001,9100,49000" -PU"42,53,67-68,88,111,123,135,137,138,161,500,3389,5355" -PY"22,80,179,5060" -R --reason --resolve-all -sn"
NMAP_PING6="nmap -6 -T5 --min-rate 500 --resolve-all -PA"21-23,25,53,79,80-83,88,110,111,135,139,161,179,443,445,497,515,535,548,993,1025,1028,1029,1917,2869,3389,5000,5060,6000,8080,9001,9100,49000" -PS"21-23,25,53,79,80-83,88,110,111,135,139,161,179,443,445,497,515,535,548,993,1025,1028,1029,1917,2869,3389,5000,5060,6000,8080,9001,9100,49000" -PU"42,53,67-68,88,111,123,135,137,138,161,500,3389,5355" -PY"22,80,179,5060" -T5 -R --reason --resolve-all -sn"
NMAP_PORT=" nmap -T4 --min-rate 300p -A -Pn -R --reason --resolve-all -sSU --open -p-"
NMAP_PORT6="nmap -6 -T4 --min-rate 300p -A -Pn -R --reason --resolve-all -sSU --open -p-"
NMAP_SCRIPTARG="newtargets,userdb=/usr/share/seclists/Usernames/cirt-default-usernames.txt,passdb=/usr/share/seclists/Passwords/cirt-default-passwords.txt,unpwdb.timelimit=15m,brute.firstOnly"
NMAP_SCRIPTS="vulners,vulscan/vulscan.nse,vuln,auth,brute,targets-xml"
wrkpth=$(pwd)

# Setting Envrionment
mkdir -p $wrkpth/Nmap/

# Menu & flags
# add modules and list modules flag(s)
while [ ! $# -eq 0 ]; do
	case "$1" in
		--help | -h | \? | *)
			echo
			echo "Usage:"
			echo "-h, --help               show brief help"
			echo "-iL, --target-file       specify the target list"
      echo "-l, --list-modes         list the modes and see what they are about"
      echo "-m, --mode               specify scan mode (i.e., fastscan, fullsweep, logincheck, pingsweep, portknock)"
			echo "-o, --output             specify the output file (default: stdout)"
      echo "-p, --port               specify the port(s) you want to scan (default is top 250 ports)"
			echo "-s, --sas-name           specify the SAS or SECVULN name (default is CPT)"
			echo "-d, --target             specify the target you want to scan (e.g., 127.0.0.1, example.cable.comcast.com)"
			echo
			echo "Example:"
			echo "tibetan-raven.sh -d example.cable.comcast.com"
			echo "tibetan-raven.sh -iL targets.list -o /path/to/output/filename # You do not need to specify the file extension"
			exit
			;;
		--target-file | -iL)
			shift
			targetfile=$1
			shift
			;;
    --list-modes | -l)
			shift
			Modes
			shift
			;;
		--output | -o)
			shift
			outputfile=$1
			shift
			;;
    --modde | -m)
			shift
			scan_mode="$1"
			shift
			;;
    --port | -p)
			shift
			port_number="-p $1"
			shift
			;;
		--sas-name | -s)
			shift
			prj_name=$1
			shift
			;;
		--target | -d)
			shift
			target=$1
			shift
			;;
	esac
	shift
done

# Checking target flag
if [ -z $targetfile ] && [ -z $targets ]; then
    echo "What is the name of the targets file? The file with all the IP addresses or FQDNs?"
    read targetfile
    echo
elif [ ! -e $targetfile ] && if [ ! -z $targetfile ]; then
    echo "File not found! Try again!"
    exit
fi

# Checking project name flag input
if [ -z $prj_name ]; then
    echo "Missing project name (e.g., SAS-1337, SECVULN-9000, etc.), assigning random value"
    prj_name="CPT-`echo $RANDOM`"
fi

# Checking scan name flag input
case $scan_mode in
  fastscan | fastscan6)
    fastScan
    ;;
  fullsweep | fullsweep6)
    pingSweep
    fullSweep
    ;;
  logincheck | logincheck6)
    pingSweep
    loginCheck
    ;;
  pingsweep | pingsweep6)
    pingSweep
    ;;
  portknock | portknock6)
    pingSweep
    portKnock
    ;;
  *)
    echo "Please select a scan mode"; exit
    ;;
esac

# Checking output dir flag
if [ -z $outputfile ]; then
    outputfile="$wrkpth/$prj_name"
elif [ ! -e $outputfile  ] && [ ! -z $outputfile ; then
    echo "File/Path not found! Try again!"
    exit
fi

# Checking port flag input
if [ -z $port_number ]; then
    port_number="--top-ports 250"
    echo
fi

# Checking target flag input
if [ -z $targets ]; then
    echo "What is the name of the target? (e.g, 127.0.0.1, example.cable.comcast.com)"
    read targets
    echo
elif [ ! -e $targets ]; then
    echo "File not found! Try again!"
    exit
fi

# ------------------------------------------------------
# HOST DISCOVERY
# ------------------------------------------------------



# Parsing Systems that responded to ping (finding)
cat `ls $wrkpth/Nmap/ | grep $prj_name | grep gnmap | grep $TodaysDAY-$TodaysYEAR` | grep Up | cut -d ' ' -f 2 | sort | uniq >> $wrkpth/Nmap/$prj_name-live-$TodaysDAY-$TodaysYEAR

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
echo

# Create unique live-$TodaysDAY-$TodaysYEAR hosts file
cat $wrkpth/Nmap/$prj_name-live-$TodaysDAY-$TodaysYEAR | sort | uniq > $wrkpth/Nmap/$prj_name-livehosts-$TodaysDAY-$TodaysYEAR
cat $wrkpth/Nmap/$prj_name-live-$TodaysDAY-$TodaysYEAR | grep -E "(\.gov|\.us|\.net|\.com|\.edu|\.org|\.biz|\.io|\.info|\.tv|\.sh|\.sys|\.ie)" | cut -d "(" -f 2 | cut -d ")" -f 1 | sort | uniq >> $wrkpth/Nmap/$prj_name-livehosts-$TodaysDAY-$TodaysYEAR

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