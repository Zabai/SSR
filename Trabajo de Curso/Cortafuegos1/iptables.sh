#!/bin/bash

# Flush
iptables -F

# Políticas
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# INPUT
iptables -A INPUT -i lo -j ACCEPT # tráfico loopback
#iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT
#iptables -A INPUT -p icmp --icmp-type echo-request -s 10.110.2.0/24 -j ACCEPT
iptables -A INPUT -p udp --sport 53 -j ACCEPT	# DNS
iptables -A INPUT -p tcp -m multiport --sports 53,80,443,8443 -j ACCEPT # DNS, HTTP, HTTPS, CV 

# FORWARD
#iptables -A FORWARD -i eth1 -o eth0 -p icmp --icmp-type echo-request -j ACCEPT
#iptables -A FORWARD -i eth0 -o eth1 -p icmp --icmp-type echo-reply -j ACCEPT
iptables -A FORWARD -p udp --sport 53 -j ACCEPT	# DNS
iptables -A FORWARD -p udp --dport 53 -j ACCEPT	# DNS
iptables -A FORWARD -p tcp -m multiport --sports 53,80,443,8443 -j ACCEPT # DNS, HTTP, HTTPS, CV
iptables -A FORWARD -p tcp -m multiport --dports 53,80,443,8443 -j ACCEPT # DNS, HTTP, HTTPS, CV

# OUTPUT
iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p udp -m state --state NEW -m udp --dport 53 -j ACCEPT #DNS
iptables -A OUTPUT -p tcp -m multiport --dports 53,80,443,8443 -m state --state NEW -j ACCEPT # DNS, HTTP, HTTPS, CV

