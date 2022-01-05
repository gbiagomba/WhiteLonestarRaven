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
current_time=$(date "+%Y.%m.%d-%H.%M.%S.%N")
outputfile="$HOSTNAME-$projectName-nmap_output-$current_time"
declare -i min=0
declare -i c=10
NMAP_PING="nmap -T5 --min-rate 1500p --resolve-all -PA"21-23,25,53,79,80-83,88,110,111,135,139,161,179,443,445,497,515,535,548,993,1025,1028,1029,1917,2869,3389,5000,5060,6000,8080,9001,9100,49000" -PE -PM -PP -PO -PR -PS"21-23,25,53,79,80-83,88,110,111,135,139,161,179,443,445,497,515,535,548,993,1025,1028,1029,1917,2869,3389,5000,5060,6000,8080,9001,9100,49000" -PU"42,53,67-68,88,111,123,135,137,138,161,500,3389,5355" -PY"22,80,179,5060" -R --reason --resolve-all -sn --append-output"
NMAP_PING6="nmap -6 -T5 --min-rate 1500p --resolve-all -PA"21-23,25,53,79,80-83,88,110,111,135,139,161,179,443,445,497,515,535,548,993,1025,1028,1029,1917,2869,3389,5000,5060,6000,8080,9001,9100,49000" -PS"21-23,25,53,79,80-83,88,110,111,135,139,161,179,443,445,497,515,535,548,993,1025,1028,1029,1917,2869,3389,5000,5060,6000,8080,9001,9100,49000" -PU"42,53,67-68,88,111,123,135,137,138,161,500,3389,5355" -PY"22,80,179,5060" -T5 -R --reason --resolve-all -sn --append-output"
NMAP_PORT=" nmap -T4 --min-rate 1000p --max-retries 3 --defeat-rst-ratelimit --script-timeout 5 -A -Pn -R --reason --resolve-all -sSV --open -p- --append-output"
NMAP_PORT6="nmap -6 -T4 --min-rate 1000p --max-retries 3 --defeat-rst-ratelimit --script-timeout 5 -A -Pn -R --reason --resolve-all -sSV --open -p- --append-output"
NMAP_UDP="nmap -T4 --min-rate 1000p --max-retries 2 --defeat-icmp-ratelimit --script-timeout 5 -A -Pn -R --reason --resolve-all -sUV --open --top-ports 1000 --append-output"
NMAP_UDP6="nmap -6 -T4 --min-rate 1000p --max-retries 2 --defeat-icmp-ratelimit --script-timeout 5 -A -Pn -R --reason --resolve-all -sUV --open --top-ports 1000 --append-output"

# Menu
# while getopts h:l:c:p: flag; do
# 	case "${flag}" in
#                 i) infolder=${OPTARG}
#                         ;;
#                 o) outfolder=${OPTARG}
#                          ;;
#                 *) echo "Invalid option: -$flag" ;;
#         esac
# done

# while [ ! $# -eq 0 ]; do
# 	case "$1" in

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
			echo "nhopper.sh -l targets.list -p "ULA-2022Q1""
            echo "nhopper.sh -l targets.list -c 25 -p "MyProject-YYYYQX""
			exit
            shift
            ;;
        --target-file | -l)
            shift
            targetfile=$1
            shift
            ;;
        --count | -c)
            shift
            threadcount=$1
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

    # Checking port flag input
    if [ -z $threadcount ]; then
        threadcount=$c
        echo
    fi

    # Checking target flag input
    if [ -z $targetfile ]; then
        echo "What is the name of the targets file? The file with all the IP addresses or FQDNs?"
        read targetfile
        echo
    elif [ ! -e $targetfile ]; then
        echo "File not found! Try again!"
        exit
    fi

    # Checking port flag input
    if [ -z $projectName ]; then
        echo "What is the name of the project name?"
        read projectName
        echo
    fi
}

# main function
function main
{
	local local_target=$1
    local current_time=$(date "+%Y.%m.%d-%H.%M.%S.%N")
    local NMAP_SCRIPTARG="newtargets,iX=$HOSTNAME-$projectName-pingsweep-$current_time.xml"
    local NMAP_SCRIPTS="vulners,targets-xml"
    if [ -x screen ] || hash screen 2>/dev/null; then
        echo "Using screen to scan $local_target"
        screen -dmS $RANDOM bash -c "$NMAP_PING -oA $HOSTNAME-$projectName-pingsweep-$current_time "$local_target"; $NMAP_PORT --script $NMAP_SCRIPTS --script-args $NMAP_SCRIPTARG -oA $HOSTNAME-$projectName-$outputfile-portknock-$current_time; wait ;$NMAP_UDP --script $NMAP_SCRIPTS --script-args $NMAP_SCRIPTARG -oA $HOSTNAME-$projectName-$outputfile-portknock_udp-$current_time"
    elif [ -x tmux ] || hash tmux 2>/dev/null; then
        echo "Using tmux to scan $local_target"
        tmux new -d -s $RANDOM
        tmux send-keys -t $(tmux ls | cut -d ":" -f 1 | sort -fnru | tail -n 1).0 "$NMAP_PING -oA $HOSTNAME-$projectName-pingsweep-$current_time "$local_target"; $NMAP_PORT --script $NMAP_SCRIPTS --script-args $NMAP_SCRIPTARG -oA $HOSTNAME-$projectName-$outputfile-portknock-$current_time; wait ;$NMAP_UDP --script $NMAP_SCRIPTS --script-args $NMAP_SCRIPTARG -oA $HOSTNAME-$projectName-$outputfile-portknock_udp-$current_time" ENTER
    fi
}

# Launching main
{
    dep
    for i in `cat $targetfile`; do
        main $i
        let "min+=1"
        if (( $min == $threadcount ));then
            while pgrep -x nmap > /dev/null; do sleep 10; done; min=0
        fi
    done
    cp -r $PWD/*.xml $HOME/../scantron/autoforklift/ingest/
    find $PWD -type d,f -empty | xargs rm -rf
} | tee $outputfile.out