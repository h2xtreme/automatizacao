#!/bin/bash

echo "Qual o ip da máquina"
read IP;
echo "Qual o nome da máquina"
read NOME;
echo "Qual a GW"
read GW;

#Configuracao ficheiro hosts
hosts="127.0.0.1\tlocalhost\tlocalhost.localdomain\tlocalhost4\tlocalhost4.localdomain4\n
::1\t\tlocalhost\tlocalhost.localdomain\tlocalhost6\tlocalhost6.localdomain6\n
$IP\t$NOME\t$NOME.localdomain"
echo -e $hosts | tr -d ' ' > /etc/hosts

#Configuracao Hostname e Rede
hostname $NOME

echo > /etc/udev/rules.d/70-persistent-net.rules
start_udev

HWADDRNOVO=`ifconfig -a  | grep -m 1 eth | awk {'print$5'}`

network="NETWORKING=yes\n
HOSTNAME=$NOME\n
IPV6INIT=no\n
NETWORKING_IPV6=no\n
NOZEROCONF=yes\n
GATEWAY=$GW"
echo -e $network | tr -d ' ' > /etc/sysconfig/network

eth0="DEVICE=eth0\n
HWADDR=$HWADDRNOVO\n
BOOTPROTO=none\n
NM_CONTROLLED=yes\n
ONBOOT=yes\n
TYPE=Ethernet\n
IPV6INIT=no\n
USERCTL=no\n
IPADDR=$IP\n
NETMASK=255.255.255.0"
echo -e $eth0 | tr -d ' ' > /etc/sysconfig/network-scripts/ifcfg-eth0

echo > /etc/udev/rules.d/70-persistent-net.rules
start_udev
/etc/init.d/network restart
