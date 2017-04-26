#!/bin/sh

iptables -t nat -A PREROUTING -p tcp -i eth1 --dport 80 -j REDIRECT --to-port 8080
