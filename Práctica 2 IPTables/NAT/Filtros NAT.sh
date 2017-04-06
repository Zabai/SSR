# Configuración de la red
cp ./Configuración/ifcfg-eth1 /etc/sysconfig/network-scripts/ifcfg-eth1
service network restart

# - Formateo las tablas
iptables -F
iptables -t nat -F

# - Reglas por defecto
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# - Acepto establecidas y relacionadas
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# --- Pasarela ---
# Permitir tráfico loopback
iptables -A INPUT -i lo -m state --state NEW -j ACCEPT
iptables -A OUTPUT -o lo -m state --state NEW -j ACCEPT

# Permitir tráfico saliente ICMP
iptables -A INPUT -i eth1 -s 192.168.120.0/24 -p icmp -m state --state NEW -j ACCEPT
iptables -A OUTPUT -p icmp -m state --state NEW -j ACCEPT

# Permitir SSH a pasarela
iptables -A INPUT -i eth1 -s 192.168.120.0/24 -p tcp --dport 22 -m state --state NEW -j ACCEPT

# Permitir HTTP - HTTPS - Campus Virtual
iptables -A OUTPUT -p tcp -m multiport --dports 80,443,8443 -m state --state NEW -j ACCEPT

# Permitir DNS
iptables -A OUTPUT -p udp --dport 53 -m state --state NEW -j ACCEPT


# --- Estación ---
# Permitir tráfico ICMP saliente
iptables -A FORWARD -p icmp -i eth1 -o eth0 -s 192.168.120.0/24 -m state --state NEW -j ACCEPT

# Permitir HTTP - HTTPS - Campus Virtual
iptables -A FORWARD -p tcp -m multiport --dports 80,443,8443 -m state --state NEW -j ACCEPT

# Permitir DNS
iptables -A FORWARD -p udp --dport 53 -m state --state NEW -j ACCEPT

# Permitir acceder a neptuno.redes.dis.ulpgc.es via SSH
iptables -A FORWARD -p tcp --dport 22 -d 10.110.1.24 -m state --state NEW -j LOG --log-prefix "Log SSH: "
iptables -A FORWARD -p tcp --dport 22 -d 10.110.1.24 -m state --state NEW -j ACCEPT

# Prerouting: destino 10.110.1.2 -> 192.168.120.2
iptables -t nat -A PREROUTING -p tcp -d 10.110.1.2 --dport 80 -j DNAT --to 192.168.120.2
iptables -t nat -A PREROUTING -p tcp -d 10.110.1.2 --dport 433 -j DNAT --to 192.168.120.2

# Postrouting: fuente: 192.168.120.2 -> 10.110.1.2
iptables -t nat -A POSTROUTING -o eth0 -j SNAT --to 10.110.1.2