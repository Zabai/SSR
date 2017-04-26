#!/bin/sh

iptables -A OUTPUT -p tcp --sport 8080 -m state --state NEW -j ACCEPT
iptables -A INPUT -p tcp --dport 8080 -m state --state NEW -j ACCEPT
