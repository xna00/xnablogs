ip rule add fwmark 666 lookup 666
ip route add local 0.0.0.0/0 dev lo table 666

ip route list
ip rule list

# clash 链负责处理转发流量
iptables -t mangle -N clash

# 让所有流量通过 clash 链进行处理
iptables -t mangle -A PREROUTING -j clash

# 目标地址为局域网或保留地址的流量跳过处理
iptables -t mangle -A clash -d 0.0.0.0/8 -j RETURN
iptables -t mangle -A clash -d 127.0.0.0/8 -j RETURN
iptables -t mangle -A clash -d 10.0.0.0/8 -j RETURN
iptables -t mangle -A clash -d 172.16.0.0/12 -j RETURN
iptables -t mangle -A clash -d 192.168.0.0/16 -j RETURN
iptables -t mangle -A clash -d 169.254.0.0/16 -j RETURN
iptables -t mangle -A clash -d 224.0.0.0/4 -j RETURN
iptables -t mangle -A clash -d 240.0.0.0/4 -j RETURN

ip tables -t mangle -A clash -d

# tproxy 7890（clash） 端口，并打上 mark 666 命中策略，走 666 路由表
iptables -t mangle -A clash -s 192.168.2.143,192.168.2.194 -p tcp -j TPROXY --on-port 7893 --tproxy-mark 666
iptables -t mangle -A clash -s 192.168.2.143,192.168.2.194 -p udp -j TPROXY --on-port 7893 --tproxy-mark 666

# 转发所有 DNS 查询到 1053 端口
# 此操作会导致所有 DNS 请求全部返回虚假 IP(fake ip 198.18.0.1/16)
iptables -t nat -I PREROUTING -s 192.168.2.143 -p udp --dport 53 -j REDIRECT --to 1053

echo "iptables 规则已设置完成"