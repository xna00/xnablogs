#!/bin/sh

# 等待一段时间，否则会报错 bind error cannot assign requested address，原因未知
sleep 120

ip rule add fwmark 666 lookup 666
ip route add local 0.0.0.0/0 dev lo table 666
ip route list
ip rule list

/root/proxy.nft

/root/clash -d /etc/clash

