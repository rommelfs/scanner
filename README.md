# scanner
nmap/ndiff based scanner with template based notification system in case of infrastructure changes

## Purpose
In situations you want to keep track of your network configuration (in this context: variation of open ports over time), `nmap` and `ndiff` come in handy.

This script tries to solve a problem if you have to track several networks or individual hosts that you want to scan consecutively. 
In case a network change is detected, the difference is sent in a (templated) mail to a configurable recipient.

## Installation
git pull this repository at a location of your choice. Make sure `nmap` and `ndiff` are installed. 
Sending emails should be working from command line using the `mail` command. `logger` is being used for logging.
The user running the script should be in the sudoers file, especially for running `nmap`:
`username        ALL=NOPASSWD: /usr/bin/nmap`

## Configuration
There are a few options in the example config file that can be changed, as well as all the templating for the mails.
Copy the config file `scan.conf-example` to `scan.conf` and edit it accordingy your wishes.


## Running

### Running standalone
`./scan.sh [IP]/[CIDR] [Email address]` 

### Running through parallels
Create a file called `targets` (see `targets-example` to get an idea) and define your targets, notification addresses and `nmap` options there.
`cat targets |parallel -j 4 ./scan.sh -r {}`

You can tune the number of parallel tasks with the '-j n' parameter.

## Sample output
```
This email contains information regarding a subsequent network port scan performed 
by ORG, which discovered a network change.
Hereafter the result of the scan and the changes (additional open ports or new hosts 
indicated by a plus ('+') sign, closed ports indicated by a minus ('-') sign) 
regarding the network 127.0.0.1/32:
PORT    STATE         SERVICE VERSION
22/tcp  open          ssh
25/tcp  open          smtp
+23/tcp  open          Telnet

If this network change was unexpected, please review what caused the change and 
react accordingly. 
```

## Copyright
Copyright: Sascha Rommelfangen, CIRCL, Smile g.i.e, 2018-01-31

## License
GNU General Public License v2.0
