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
Create a file called `targets` (see `targets-example` to get an idea) and define your targets, notification addresses and `nmap` options there. When reading from a file, `-r` needs to be specified to deal with the special condition.

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

Reminder of the Warranty clause of the GPLv2:
BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR REDISTRIBUTE THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
