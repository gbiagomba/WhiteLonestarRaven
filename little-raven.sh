#!/bin/bash
#Author: Gilles Biagomba
#Program: terminus.sh
#Description: This script checks a file with URLs to see if they can be reached via a curl command.\n
#	      The objective is to test to see if paths to a web server that requires authentication \n
#	      Could be reached from a user who is not authenticated\n
#	      reference: https://stackoverflow.com/questions/6136022/script-to-get-the-http-status-code-of-a-list-of-urls


# for debugging purposes
# set -eux
trap "echo Booh!" SIGINT SIGTERM

# initiallizing variables
current_time=$(date +%Y.%m.%d.%H.%M.%S.%N)
outputFile="$HOSTNAME-$projectName-nmap_output-$current_time"
declare -i min=0
declare -i c=10
NMAP_PING="nmap -T5 --min-rate 1500p --randomize-hosts --resolve-all -PA"21-23,25,53,79,80-83,88,110,111,135,139,161,179,443,445,497,515,535,548,993,1025,1028,1029,1917,2869,3389,5000,5060,6000,8080,9001,9100,49000" -PE -PM -PP -PO -PR -PS"21-23,25,53,79,80-83,88,110,111,135,139,161,179,443,445,497,515,535,548,993,1025,1028,1029,1917,2869,3389,5000,5060,6000,8080,9001,9100,49000" -PU"42,53,67-68,88,111,123,135,137,138,161,500,3389,5355" -PY"22,80,179,5060" -R --reason --resolve-all -sn"
NMAP_PING6="nmap -6 -T5 --min-rate 1500p --randomize-hosts --resolve-all -PA"21-23,25,53,79,80-83,88,110,111,135,139,161,179,443,445,497,515,535,548,993,1025,1028,1029,1917,2869,3389,5000,5060,6000,8080,9001,9100,49000" -PS"21-23,25,53,79,80-83,88,110,111,135,139,161,179,443,445,497,515,535,548,993,1025,1028,1029,1917,2869,3389,5000,5060,6000,8080,9001,9100,49000" -PU"42,53,67-68,88,111,123,135,137,138,161,500,3389,5355" -PY"22,80,179,5060" -T5 -R --reason --resolve-all -sn"
NMAP_PORT="nmap -T4 --min-rate 1500p --randomize-hosts --max-retries 3 --defeat-rst-ratelimit --script-timeout 5 -A -Pn -R --reason --resolve-all -sSV --open -p-"
NMAP_PORT6="nmap -6 -T4 --min-rate 1500p --randomize-hosts --max-retries 3 --defeat-rst-ratelimit --script-timeout 5 -A -Pn -R --reason --resolve-all -sSV --open -p-"
NMAP_UDP="nmap -T5 --min-rate 1500p --randomize-hosts --max-retries 2 --defeat-icmp-ratelimit --script-timeout 5 -A -Pn -R --reason --resolve-all -sUV --open --top-ports 1000"
NMAP_UDP6="nmap -6 -T5 --min-rate 1500p --randomize-hosts --max-retries 2 --defeat-icmp-ratelimit --script-timeout 5 -A -Pn -R --reason --resolve-all -sUV --open --top-ports 1000"

while [ ! $# -eq 0 ]; do
	case "$1" in
		--help | -h)
            shift
			echo
			echo "Usage:"
			echo "-h, --help               show brief help"
			echo "-l, --target-file        specify the target list"
            echo "-c, --count              specify how many instances of nmap do you want running in parallel (default is 10)"
            echo "-p, --project            specify project name"
			echo
			echo "Example:"
			echo "little-raven.sh -l targets.list -p "ULA-2022Q1""
            echo "little-raven.sh -l targets.list -c 25 -p "MyProject-YYYYQX""
			exit
            shift
            ;;
        --target-file | -l)
            shift
            targetFile=$1
            shift
            ;;
        --count | -c)
            shift
            threadCount=$1
            shift
            ;;
        --output | -o)
            shift
            outputFile=$1
            shift
            ;;
        --project | -p)
            shift
            projectName=$1
            shift
            ;;
	esac
	shift
done

# Banner function
function banner
{
    echo "
    ___      ___   _______  _______  ___      _______         ______    _______  __   __  _______  __    _ 
    |   |    |   | |       ||       ||   |    |       |       |    _ |  |   _   ||  | |  ||       ||  |  | |
    |   |    |   | |_     _||_     _||   |    |    ___| ____  |   | ||  |  |_|  ||  |_|  ||    ___||   |_| |
    |   |    |   |   |   |    |   |  |   |    |   |___ |____| |   |_||_ |       ||       ||   |___ |       |
    |   |___ |   |   |   |    |   |  |   |___ |    ___|       |    __  ||       ||       ||    ___||  _    |
    |       ||   |   |   |    |   |  |       ||   |___        |   |  | ||   _   | |     | |   |___ | | |   |
    |_______||___|   |___|    |___|  |_______||_______|       |___|  |_||__| |__|  |___|  |_______||_|  |__|
    "
}

# dependencies function
function dep
{
    # Checking if the user is root
    if [ "$EUID" -ne 0 ]
    then echo "Please run as root"
    exit
    fi

    # Checking to see if nmap is installed
    if [ ! -x nmap ] && ! hash nmap 2> /dev/null; then
        echo "Please install nmap - https://nmap.org/download.html & try again"
        exit
    fi

    # Checking the thread flag input
    if [ -z $threadCount ]; then
        threadCount=$c
        echo
    fi

    # Checking target flag input
    if [ -z $targetFile ]; then
        echo "What is the name of the targets file? The file with all the IP addresses or FQDNs?"
        read targetFile
        echo
    elif [ ! -e $targetFile ]; then
        echo "Target file not found! Try again!?"
        exit
    fi

    # Checking project name flag input
    if [ -z $projectName ]; then
        projectName="OneOffPrj-$RANDOM"
    fi

    # Checking outputfile flag input
    if [ -z $outputFile ]; then
        echo "What is the output file name?"
        read outputFile
        echo
    fi

    # Figuring out how many nmaps are running
    nmapCount=$(pgrep -x nmap -u $(id -u $USERNAME) | wc -l | tr -d " ")
    threadCount=$(expr $nmapCount + $threadCount)
}

# cleanup function
function cleanup
{
    for i in `ls | egrep -i "\.gnmap|\.nmap"`; do
        if [ `tail -n 1 $i | cut -d "(" -f 2 | cut -d ")" -f 1 | cut -d " " -f 1` eq 0 ]; then
            rm -f $i
        fi
    done

    if [ -d $HOME/../scantron/autoforklift/ingest/ ]; then
        for i in `ls | grep -i "\.xml"`; do
            cp -r $i $HOME/../scantron/autoforklift/ingest/
        done
    fi
    find $PWD -type d,f -empty | xargs rm -rf
    XZ_OPT=-e9 tar -cvJf $PWD/../$projectName.tar.xz $PWD/
    mv $PWD/../$projectName.tar.xz $PWD/
}
# parse results files
function parse_results
{
    local nmapOutput=$1
    cat $nmapOutput | cut -d "(" -f 2 | cut -d ")" -f 1 | sort -fu | grep -iv "nmap" | tee -a $nmapOutput.list
}

# main function
function main
{
	local local_target=$1
    local current_time=$(date "+%Y.%m.%d.%H.%M.%S.%N")
    local NMAP_SCRIPTARG="newtargets,iX=$HOSTNAME-$projectName-pingsweep-$current_time.xml"
    local NMAP_SCRIPTARG6="newtargets,iX=$HOSTNAME-$projectName-pingsweep6-$current_time.xml"
    local NMAP_SCRIPTS="vulners,targets-xml"
    local NMAP_CMD="$NMAP_PING -oA $HOSTNAME-$projectName-pingsweep-$current_time "$local_target"; $NMAP_PORT --script $NMAP_SCRIPTS --script-args $NMAP_SCRIPTARG -oA $HOSTNAME-$projectName-portknock-$current_time; $NMAP_UDP --script $NMAP_SCRIPTS --script-args $NMAP_SCRIPTARG -oA $HOSTNAME-$projectName-portknock_udp-$current_time"
    local NMAP_CMD6="$NMAP_PING6 -oA $HOSTNAME-$projectName-pingsweep6-$current_time "$local_target"; $NMAP_PORT6 --script $NMAP_SCRIPTS --script-args $NMAP_SCRIPTARG6 -oA $HOSTNAME-$projectName-portknock6-$current_time; $NMAP_UDP6 --script $NMAP_SCRIPTS --script-args $NMAP_SCRIPTARG6 -oA $HOSTNAME-$projectName-portknock_udp6-$current_time"
    if [ -x screen ] || hash screen 2>/dev/null; then
        echo "Using screen to scan $local_target"; screen -dmS $RANDOM bash -c "$NMAP_CMD" # ; parse_results $HOSTNAME-$projectName-pingsweep-$current_time.gnmap; $NMAP_CMD6"
    elif [ -x tmux ] || hash tmux 2>/dev/null; then
        echo "Using tmux to scan $local_target"; tmux new -d -s $RANDOM; tmux send-keys -t $(tmux ls | cut -d ":" -f 1 | sort -fnru | tail -n 1).0 "$NMAP_CMD" # ; parse_results $HOSTNAME-$projectName-pingsweep-$current_time.gnmap; $NMAP_CMD6" ENTER
    fi
}

# Launching main
{
    banner
    dep
    for i in `cat $targetFile | sort -R`; do
        main $i
        while [ $(pgrep -x nmap -u $(id -u $USERNAME) | wc -l | tr -d " ") -ge $threadCount ]; do sleep 10; done
    done
} | tee $outputFile.out