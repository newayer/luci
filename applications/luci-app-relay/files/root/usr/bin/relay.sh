#!/bin/sh

UCI_DIR="/etc/config"
UCI_GET="uci -q -c $UCI_DIR get"

start_relay()
{
   wan_ip=$($UCI_GET relay.relay_mode.wan_ip)
   bss_net=$($UCI_GET relay.relay_mode.bss_net)
   gw=$($UCI_GET relay.relay_mode.gw)

   ifconfig eth0 $wan_ip netmask 255.255.255.0
   route add default gw $gw dev eth0 metric 256
   route add -net $bss_net netmask 255.255.255.0 dev eth0 metric 256
   brctl addif br-lan eth0
}

stop_relay()
{
   wan_ip=$($UCI_GET relay.relay_mode.wan_ip)
   bss_net=$($UCI_GET relay.relay_mode.bss_net)
   gw=$($UCI_GET relay.relay_mode.gw)
   
   [ x$wan_ip != x ] && ip addr del $wan_ip/24 dev eth0
   brctl delif br-lan eth0
}


cmd="$1"
if [ "$cmd" = "start" ]; then                
    start_relay                                                           
elif [ "$cmd" = "stop" ]; then                             
    stop_relay   
else
    echo "param invalid."
fi
