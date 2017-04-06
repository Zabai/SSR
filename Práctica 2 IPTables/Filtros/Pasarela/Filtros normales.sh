# Configuración de la red
cp ./Configuración/Pasarela/ifcfg-eth1 /etc/sysconfig/network-scripts/ifcfg-eth1
service network restart

# Formatear tablas
iptables -F

# Políticas por defecto
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD DROP


# --- Pasarela --- #

# Permitir tráfico loopback
iptables -A INPUT -i lo -j ACCEPT

# Permitir tráfico saliente ICMP
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT

# Solo responder a ICMP de red interna
iptables -A INPUT -p icmp --icmp-type echo-request -s 10.110.2.0/24 -j ACCEPT

# Permitir a estaciones acceder a pasarela via ssh/sftp
iptables -A INPUT -i eth1 -p tcp --dport 22 -s 10.110.2.0/24 -j ACCEPT

# Permitir acceso servidores DNS, HTTP, HTTPS
iptables -A INPUT -p udp --sport 53 -j ACCEPT
iptables -A INPUT -p tcp --sport 80 -j ACCEPT
iptables -A INPUT -p tcp --sport 443 -j ACCEPT

# Permitir acceso a Campus Virtual (8443)
iptables -A INPUT -p tcp --sport 8443 -j ACCEPT


# --- Estación --- #

# Permitir tráfico saliente ICMP
iptables -A FORWARD -i eth1 -o eth0 -p icmp --icmp-type echo-request -j ACCEPT
iptables -A FORWARD -i eth0 -o eth1 -p icmp --icmp-type echo-reply -j ACCEPT

# Permitir acceso servidores DNS, HTTP, HTTPS
iptables -A FORWARD -o eth0 -p udp --sport 53 -j ACCEPT
iptables -A FORWARD -i eth1 -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -o eth0 -p tcp --sport 80 -j ACCEPT
iptables -A FORWARD -i eth1 -p tcp --dport 80 -j ACCEPT
iptables -A FORWARD -i eth0 -p tcp --sport 443 -j ACCEPT
iptables -A FORWARD -i eth1 -p tcp --dport 443 -j ACCEPT

# Permitir acceso a Campus Virtual (8443)
iptables -A FORWARD -i eth0 -o eth1 -p tcp --sport 8443 -j ACCEPT
iptables -A FORWARD -i eth1 -o eth0 -p tcp --dport 8443 -j ACCEPT

# Permitir acceder a neptuno.redes.dis.ulpgc.es via ssh
iptables -A FORWARD -p tcp --sport 22 -s 10.110.1.24 -j LOG --log-prefix "Log SSH: "
iptables -A FORWARD -p tcp --sport 22 -s 10.110.1.24 -j ACCEPT
iptables -A FORWARD -p tcp --dport 22 -d 10.110.1.24 -j LOG --log-prefix "Log SSH: "
iptables -A FORWARD -p tcp --dport 22 -d 10.110.1.24 -j ACCEPT