# Function banner
function banner
{
    echo "--------------------------------------------------"
    echo "Performing $1"
    echo "--------------------------------------------------"
}

# Check that nmap output file exists
function fileExists {
  if [ ! -s $1.gnmap  ] || [ ! -e $1.gnmap ]; then
    echo "$1 does not exist"
    echo "Check stdout (terminal output) for any errors in nmap & check internet connection"
    exit
  fi
}

# fastscan, fullsweep, logincheck, pingsweep, portknock
function Modes
{
    echo
    echo "fastscan/6              Performes fast nmap scan (-F), fastscan6 is the IPv6 scanner"
    echo "fullsweep/6             Performs a pingsweep, portknock and service check, for IPv6 scanning use fullsweep6"
    echo "logincheck/6            Performs pingsweep, and checks for weak credentials for login services (e.g., rsh,sql,ssh,ntp,telnet, etc.) on default ports"
    echo "pingsweep/6             Performs a pingsweep of the target(s) and nothing else"
    echo "portknock/6             Performs a pingsweep and portknock of the target(s) but it will not perform host discovery"
    exit
}

# Pingsweep
function pingSweep
{
    # Nmap - Pingsweep using ICMP echo, timestamp, netmask
    banner "Nmap Pingsweep - ICMP echo, netmask, timestamp"
    $NMAP_PING $
    $NMAP_PING6
    fileExists
    echo
}
# Fastscan
function portKnock

# Fullsweep
function fastScan

# Logincheck
function fullSweep

# Portknock
function loginCheck