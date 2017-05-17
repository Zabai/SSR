#!/bin/bash

# Flush
iptables -F
iptables -t nat -F

# Políticas
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# FORWARD
iptables -A FORWARD -p udp --sport 53 -j ACCEPT	# DNS
iptables -A FORWARD -p udp --dport 53 -j ACCEPT	# DNS
#iptables -A FORWARD -p tcp -m multiport --sports 53,80,443,8443,25,143,8080 -j ACCEPT # DNS, HTTP, HTTPS, Campus, SMTP, IMAP, SQUID
#iptables -A FORWARD -p tcp -m multiport --dports 53,80,443,8443,25,143,8080 -j ACCEPT # DNS, HTTP, HTTPS, Campus, SMTP, IMAP, SQUID
iptables -A FORWARD -p tcp -m multiport --sports 53,25,143,8080,137:139,445 -j ACCEPT # DNS, SMTP, IMAP, SQUID, SAMBA
iptables -A FORWARD -p tcp -m multiport --dports 53,25,143,8080,137:139,445 -j ACCEPT # DNS, SMTP, IMAP, SQUID, SAMBA
iptables -A FORWARD -p tcp -i eth1 -o eth0 --dport 22 -j ACCEPT
iptables -A FORWARD -p tcp -i eth0 -o eth1 --sport 22 -j ACCEPT

# NAT
# Postrouting fuente: 192.168.10.2 -> 10.110.10.3
iptables -t nat -A POSTROUTING -o eth0 -j SNAT --to 10.110.10.3
