# White Lonestar Raven
I create this script to help automate host and port discovery during the recon phase of an assessment. This is a fork of https://github.com/gbiagomba/Nmap_Scripts

```
                                                 ,::::.._
                                               ,':::::::::.
                                           _,-'`:::,::(o)::`-,.._
                                        _.', ', `:::::::::;'-..__`.
                                   _.-'' ' ,' ,' ,\:::,'::-`'''
                               _.-'' , ' , ,'  ' ,' `:::/
                         _..-'' , ' , ' ,' , ,' ',' '/::
                 _...:::'`-..'_, ' , ,'  , ' ,'' , ,'::|
              _`.:::::,':::::,'::`-:..'_',_'_,'..-'::,'|
      _..-:::'::,':::::::,':::,':,'::,':::,'::::::,':::;
        `':,'::::::,:,':::::::::::::::::':::,'::_:::,'/
        __..:'::,':::::::--''' `-:,':,':::'::-' ,':::/
   _.::::::,:::.-''-`-`..'_,'. ,',  , ' , ,'  ', `','
 ,::SSt:''''`                 \:. . ,' '  ,',' '_,'
                               ``::._,'_'_,',.-'
                                   \\ \\
                                    \\_\\
                                     \\`-`.-'_
                                  .`-.\\__`. ``
                                     ``-.-._
                                         `


```

## Usage:
```
-h, --help               show brief help
-iL, --target-file       specify the target list
-l, --list-modes         list the modes and see what they are about
-m, --mode               specify scan mode (i.e., fastscan, fullsweep, logincheck, pingsweep, portknock)
-o, --output             specify the output file (default: stdout)
-p, --port               specify the port(s) you want to scan (default is top 250 ports)
-s, --sas-name           specify the SAS or SECVULN name (default is CPT)
-d, --target             specify the target you want to scan (e.g., 127.0.0.1, example.cable.comcast.com)

Example:
raven.sh -d example.cable.comcast.com
raven.sh -iL targets.list -o /path/to/output/filename # You do not need to specify the file extension
```
Obviously you would substitute the "desired_nmap_script.sh" with the actual script version you want.

## Versions:
There are two versions of the script, the little raven an the tibetan raven (credit to **Rita Pang** for the naming)of these scripts. Fun fact, a flock of ravens is called an "unkindness" or "conmspiracy", more credit to Rita for teaching me this. 
```

          :================:
         /||# nmap -A _   ||
        / ||              ||
       |  ||              ||
        \ ||              ||
          ==================
   ........... /      \.............
   :\        ############            \
   : ---------------------------------
   : |  *   |__________|| ::::::::::  |
   \ |      |          ||   .......   |
     --------------------------------- 8
```

### Little Raven:
Named after one of the smallest ravens in its species, this is a lightweight version of its counterpart. It was designed to perform a pingsweep and quick portknock scan of a target network. It achieves this by first performing a comprehensive pingsweep across ICMP, TCP and UDP. Then it performs a portknock of the top one-hundred (100) most commonly used TCP/UDP ports. Lastly, the results are dumped into a folder and that folder is later compressesed. 

### Tibetan Raven:
Named after one of the biggest ravens in its species. this is a heavyweight version of its counterpart. It was designed to perform a comprehensive pingsweep and portknock scan of a target network. First it performs seeprated/individual ICMP, TCP SYN/ACK, UDP scans. Then it checks all 65,535 TCP/UDP ports. Un;llike the counter part, this script will perform an agrevise scan and it will run additional scripts when performing the portknock. Lastly, the results are dumped into a folder and that folder is later compressesed.

## Dependencies:
I provided an install script, do note that install script will try to install those dependicies for you for most popular UNX/LNX distributions. If it fails, you than you will have to fetch the dependencies manually. You will need to clone the below reports into /opt/ and install all the dependencies for each repo. 
```
https://github.com/vulnersCom/nmap-vulners
https://github.com/scipag/VulScan
https://github.com/mrschyte/nmap-converter
https://github.com/maaaaz/nmaptocsv
https://github.com/delvelabs/batea
```
I will add support for other platforms in the install script later

## Conclusion:
As a wise man once said: "With great power, comes great responsibility" - Uncle Ben
```
                            __
                          .'`  '-.
                         /     _  \
                        /     (.)_J
                       /        / `'-.
                     .'         \`-.._`\
                   ,;-'~""'.    /`"'""``
                  /`        \  /
                /`    /      | ;
               /`       .'   | |
              ;           /  ; ;
             /   /     .'   / ;
            ;             .' /
           /  .'  /   _.-' .'
         .'        .-' _,-;
        /   _..--'`   /_.'
       ;.-;` / ;., .-'\=\        ,###"
   jgs  /   .'/  \=\   \=\    ,###"
       /.'/ //    \=\   \=\_###"
      /  . '/      \=\___#-.)))
     /  / _//      ((--.)))```
     |_/ / /       ,###"```
     /  / /     ,###"
    /.'/_/   ,###"
    |_/    ,###"
 
```

### TODO:
- [x] Add install script support for other UNX/NIX systems
- [x] Add a help menu
- [ ] Convert to rust program []INPROGRESS
- [x] Add IPv6 scanning detection/support