# scanner
nmap/ndiff based scanner with template based notification system in case of infrastructure changes

## Purpose
In situations you want to keep track of your network configuration (in this context: variation of open ports over time), `nmap` and `ndiff` come in handy.

This script tries to solve a problem if you have to track several networks or individual hosts that you want to scan consecutively. 
In case a network change is detected, the difference is sent in a (templated) mail to a configurable recipient.

