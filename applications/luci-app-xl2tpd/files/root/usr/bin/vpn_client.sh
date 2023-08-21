#!/bin/sh

UCI_DIR="/etc/config"
UCI_GET="uci -q -c $UCI_DIR get"
LAST_VPN_TYEP_FILE="/opt/last_vpn_type"
PPTP_PPP_UNIT=10  #ifname:ppp10
PPTP_OPTION_FILE="/opt/vpn/etc/ppp/options.pptp"
PPTP_RPPTP_FILE="/opt/vpn/etc/ppp/peers/pptp"
L2TP_PPP_UNIT=20  #ifname:ppp20
#L2TP_OPTION_FILE="/etc/ppp/options.xl2tpd"
L2TP_OPTION_FILE="/var/run/xl2tpd/options.xl2tpd"
#L2TP_CONFIG_FILE="/etc/xl2tpd/xl2tpd.conf"
L2TP_CONFIG_FILE="/var/run/xl2tpd/xl2tpd.conf"
#L2TP_CONFIG_TMP_FILE="/etc/ppp/xl2tpd_tmp.conf"
L2TP_CONFIG_TMP_FILE="/var/run/xl2tpd/xl2tpd_tmp.conf"
L2TP_CONTROL_FILE="/var/run/xl2tpd/l2tp-control"
L2TP_PPP_PID_FILE="/var/run/ppp-l2tp.pid"
VPN_RESOLV_FILE="/opt/vpn/etc/ppp/vpn_resolv.conf"
VPN_CONN_SCRIPT_RUNNING_FIEL="/var/run/vpn_conn_script_running"

xl2tpd_need_restart=0

set_vpn_dns_config()
{
    local dns_list=`$UCI_GET vpn.client.dns_list`
    if [ -n "$dns_list" ]; then
        echo -n > "$VPN_RESOLV_FILE"
        for dns in $dns_list; do
            echo "nameserver $dns" >> "$VPN_RESOLV_FILE"
        done
    elif [ -e "$VPN_RESOLV_FILE" ]; then
        rm -f "$VPN_RESOLV_FILE"
    fi
}

create_pptp_config_file()
{
    local username=`$UCI_GET vpn.client.username`
    local password=`$UCI_GET vpn.client.password`
    local server_addr=`$UCI_GET vpn.client.server_addr`
    
    if [ ! -d "/opt/vpn/etc/ppp/peers" ];then
        mkdir -p /opt/vpn/etc/ppp/peers
    fi
    if [ -z "$username" -o -z "$password" -o -z "$server_addr" ]; then
        echo "pptp config invalid, connect exit."
        exit 1
    fi
    
    local mtu=`$UCI_GET vpn.client.mtu`
    [ -z "$mtu" -o "$mtu" = "0" ] && mtu=1444
    
    #options.pptp
    echo "unit $PPTP_PPP_UNIT" > "$PPTP_OPTION_FILE"  #ppp10
    #echo "lock" >> "$PPTP_OPTION_FILE"
    echo "noauth" >> "$PPTP_OPTION_FILE"
    echo "nopcomp" >> "$PPTP_OPTION_FILE"
    echo "noaccomp" >> "$PPTP_OPTION_FILE"
    echo "nobsdcomp" >> "$PPTP_OPTION_FILE"
    echo "nodeflate" >> "$PPTP_OPTION_FILE"
    echo "lcp-echo-interval 20" >> "$PPTP_OPTION_FILE"
    echo "lcp-echo-failure 3" >> "$PPTP_OPTION_FILE"
    echo "mtu $mtu" >> "$PPTP_OPTION_FILE"
    echo "holdoff 2" >> "$PPTP_OPTION_FILE"
    echo "refuse-eap" >> "$PPTP_OPTION_FILE"
    #echo "wantype 4" >> "$PPTP_OPTION_FILE"
    
    #/etc/ppp/peers/pptp 
    local local_ip=`$UCI_GET vpn.client.local_ip`
    local remote_ip=`$UCI_GET vpn.client.remote_ip`
    echo "name $username" > "$PPTP_RPPTP_FILE"
    echo "user $username" >> "$PPTP_RPPTP_FILE"
    echo "password $password" >> "$PPTP_RPPTP_FILE"
    echo "pty \"pptp $server_addr --nolaunchpppd\"" >> "$PPTP_RPPTP_FILE"
    echo "file $PPTP_OPTION_FILE" >> "$PPTP_RPPTP_FILE"
    echo "remotename pptp" >> "$PPTP_RPPTP_FILE"
    echo "linkname pptp" >> "$PPTP_RPPTP_FILE"
    echo "ipparam pptp" >> "$PPTP_RPPTP_FILE"
    echo "novj" >> "$PPTP_RPPTP_FILE"
    #echo "nomppc" >> "$PPTP_RPPTP_FILE"
    echo "noccp" >> "$PPTP_RPPTP_FILE"
    echo "persist" >> "$PPTP_RPPTP_FILE"
    echo "noauth" >> "$PPTP_RPPTP_FILE"
    echo "nobsdcomp" >> "$PPTP_RPPTP_FILE"
    echo "nodetach" >> "$PPTP_RPPTP_FILE"
    echo "usepeerdns" >> "$PPTP_RPPTP_FILE"
    echo "noipdefault" >> "$PPTP_RPPTP_FILE"
    echo "plugin pptp.so pptp_server $server_addr" >> "$PPTP_RPPTP_FILE"
    [ -n "$local_ip" ] && echo "$local_ip:$remote_ip" >> "$PPTP_RPPTP_FILE"
    
    local auth_type=`$UCI_GET vpn.client.auth_type | tr 'a-z' 'A-Z'`
    if [ "$auth_type" = "PAP" ]; then
        echo "refuse-chap" >> "$PPTP_RPPTP_FILE"
        echo "refuse-mschap" >> "$PPTP_RPPTP_FILE"
        echo "refuse-mschap-v2" >> "$PPTP_RPPTP_FILE"
    elif [ "$auth_type" = "CHAP" ]; then
        echo "refuse-pap" >> "$PPTP_RPPTP_FILE"
        echo "refuse-mschap" >> "$PPTP_RPPTP_FILE"
        echo "refuse-mschap-v2" >> "$PPTP_RPPTP_FILE"
    elif [ "$auth_type" = "MSCHAP" ]; then
        echo "refuse-pap" >> "$PPTP_RPPTP_FILE"
        echo "refuse-chap" >> "$PPTP_RPPTP_FILE"
        echo "refuse-mschap-v2" >> "$PPTP_RPPTP_FILE"
    elif [ "$auth_type" = "MSCHAP-V2" ]; then
        echo "refuse-pap" >> "$PPTP_RPPTP_FILE"
        echo "refuse-chap" >> "$PPTP_RPPTP_FILE"
        echo "refuse-mschap" >> "$PPTP_RPPTP_FILE"
    fi
    
    set_vpn_dns_config
}

create_l2tp_config_file()
{
    local username=`$UCI_GET vpn.client.username`
    local password=`$UCI_GET vpn.client.password`
    local server_addr=`$UCI_GET vpn.client.server_addr`
    if [ -z "$username" -o -z "$password" -o -z "$server_addr" ]; then
        echo "l2tp config invalid, connect exit."
        exit 1
    fi

    mkdir -p /var/run/xl2tpd
    local mtu=`$UCI_GET vpn.client.mtu`
    [ -z "$mtu" -o "$mtu" = "0" ] && mtu=1460

    #options.xl2tpd
    echo "name $username" > "$L2TP_OPTION_FILE"
    echo "user $username" >> "$L2TP_OPTION_FILE"
    echo "password $password" >> "$L2TP_OPTION_FILE"
    echo "unit $L2TP_PPP_UNIT" >> "$L2TP_OPTION_FILE"  #ppp20
    echo "linkname l2tp" >> "$L2TP_OPTION_FILE"
    #echo "lock" >> "$L2TP_OPTION_FILE"
    echo "refuse-eap" >> "$L2TP_OPTION_FILE"
    echo "noauth" >> "$L2TP_OPTION_FILE"
    echo "persist" >> "$L2TP_OPTION_FILE"
    echo "nopcomp" >> "$L2TP_OPTION_FILE"
    echo "noaccomp" >> "$L2TP_OPTION_FILE"
    echo "nobsdcomp" >> "$L2TP_OPTION_FILE"
    echo "nodeflate" >> "$L2TP_OPTION_FILE"
    echo "nodetach" >> "$L2TP_OPTION_FILE"
    echo "novj" >> "$L2TP_OPTION_FILE"
    echo "noccp" >> "$L2TP_OPTION_FILE"
    echo "default-asyncmap" >> "$L2TP_OPTION_FILE"
    echo "mtu $mtu" >> "$L2TP_OPTION_FILE"
    echo "lcp-echo-interval 20" >> "$L2TP_OPTION_FILE"
    echo "lcp-echo-failure 3" >> "$L2TP_OPTION_FILE"
    echo "usepeerdns" >> "$L2TP_OPTION_FILE"
    echo "defaultroute" >> "$L2TP_OPTION_FILE"
    #echo "wantype 6" >> "$L2TP_OPTION_FILE"
    echo "noipdefault" >> "$L2TP_OPTION_FILE"
    
    # /etc/xl2tpd/xl2tpd.conf
    local local_ip=`$UCI_GET vpn.client.local_ip`
    local remote_ip=`$UCI_GET vpn.client.remote_ip`
    echo "[global]" > "$L2TP_CONFIG_TMP_FILE"
    echo "port = 1701" >> "$L2TP_CONFIG_TMP_FILE"
    echo "[lac client]" >> "$L2TP_CONFIG_TMP_FILE"
    echo "lns = $server_addr" >> "$L2TP_CONFIG_TMP_FILE"
    echo "name = $username" >> "$L2TP_CONFIG_TMP_FILE"
    echo "pppoptfile = $L2TP_OPTION_FILE" >> "$L2TP_CONFIG_TMP_FILE"
    echo "redial = yes" >> "$L2TP_CONFIG_TMP_FILE"
    echo "redial timeout = 10" >> "$L2TP_CONFIG_TMP_FILE"
    echo "max redials = 3" >> "$L2TP_CONFIG_TMP_FILE"
    [ -n "$local_ip" ] && echo "local ip = $local_ip" >> "$L2TP_CONFIG_TMP_FILE"
    [ -n "$remote_ip" ] && echo "remote ip = $remote_ip" >> "$L2TP_CONFIG_TMP_FILE"
    
    local auth_type=`$UCI_GET vpn.client.auth_type | tr 'a-z' 'A-Z'`
    if [ "$auth_type" = "PAP" ]; then
        echo "refuse-chap" >> "$L2TP_OPTION_FILE"
        echo "refuse-mschap" >> "$L2TP_OPTION_FILE"
        echo "refuse-mschap-v2" >> "$L2TP_OPTION_FILE"
        echo "refuse chap = yes" >> "$L2TP_CONFIG_TMP_FILE"
    elif [ "$auth_type" = "CHAP" ]; then
        echo "refuse-pap" >> "$L2TP_OPTION_FILE"
        echo "refuse-mschap" >> "$L2TP_OPTION_FILE"
        echo "refuse-mschap-v2" >> "$L2TP_OPTION_FILE"
        echo "refuse pap = yes" >> "$L2TP_CONFIG_TMP_FILE"
    elif [ "$auth_type" = "MSCHAP" ]; then
        echo "refuse-pap" >> "$L2TP_OPTION_FILE"
        echo "refuse-chap" >> "$L2TP_OPTION_FILE"
        echo "refuse-mschap-v2" >> "$L2TP_OPTION_FILE"
        echo "refuse pap = yes" >> "$L2TP_CONFIG_TMP_FILE"
    elif [ "$auth_type" = "MSCHAP-V2" ]; then
        echo "refuse-pap" >> "$L2TP_OPTION_FILE"
        echo "refuse-chap" >> "$L2TP_OPTION_FILE"
        echo "refuse-mschap" >> "$L2TP_OPTION_FILE"
        echo "refuse pap = yes" >> "$L2TP_CONFIG_TMP_FILE"
    fi
    
    diff "$L2TP_CONFIG_TMP_FILE" "$L2TP_CONFIG_FILE" > /dev/null 2>&1
    xl2tpd_need_restart="$?"
    [ "$xl2tpd_need_restart" != "0" ] && cp -a "$L2TP_CONFIG_TMP_FILE" "$L2TP_CONFIG_FILE"

    set_vpn_dns_config
}

vpn_pptp_connect()
{
    create_pptp_config_file
    pppd call pptp &
    #set_fast_flag "PPTP"
}

vpn_pptp_disconnect()
{
    local pptp_pppd_pids=`ps |grep "pppd call pptp" | grep -v grep | awk '{print $1}'`
    if [ -n "$pptp_pppd_pids" ]; then
        for pptp_ppp_pid in $pptp_pppd_pids; do
            kill -15 $pptp_ppp_pid > /dev/null 2>&1
            killall pptp
        done
        
        local count=100
        while [ "$count" -gt 0 ]; do
            local pptp_pppd_exits=`ps | grep "pppd call pptp" | grep -v grep`
            if [ -z "$pptp_pppd_exits" ]; then
                break
            fi
            count=`expr $count - 1`
            sleep 0.1  #sleep 100ms
        done
    fi
}

vpn_l2tp_connect()
{
    create_l2tp_config_file
    
    local xl2tpd_exsit=`ps |grep xl2tpd |grep -v grep`
    
    if [ -z "$xl2tpd_exsit" ]; then
        xl2tpd -c "$L2TP_CONFIG_FILE" -D &
        sleep 3
    elif [ -n "$xl2tpd_exsit" -a "$xl2tpd_need_restart" != "0" ]; then
        echo "restart xl2tpd"
        killall -9 xl2tpd
        sleep 1
        xl2tpd -c "$L2TP_CONFIG_FILE" -D &
        sleep 3
    fi
    
    echo 'c client' > "$L2TP_CONTROL_FILE"
    
    #set_fast_flag "L2TP"
}

vpn_l2tp_disconnect()
{
    local xl2tpd_exist=`ps |grep "xl2tpd" |grep -v grep`

    if [ -n "$xl2tpd_exist" ]; then
        echo 'd client' > "$L2TP_CONTROL_FILE"
        if [ "$force" = "1" ]; then
            sleep 1
            killall -9 xl2tpd
        fi
        
        if [ -e "$L2TP_PPP_PID_FILE" ]; then
            local l2tp_pppd_pid=`sed -n 1p "$L2TP_PPP_PID_FILE"`
            if [ -n "$l2tp_pppd_pid" ]; then
                local count=100
                while [ "$count" -gt 0 ]; do
                    local l2tp_pppd_exist=`ps | grep pppd | grep "$l2tp_pppd_pid"`
                    if [ -z "$l2tp_pppd_exist" ]; then
                        break
                    fi
                    count=`expr $count - 1`
                    sleep 0.1  #sleep 100ms
                done
            fi
        fi
    fi
}

vpn_disconnect()
{
    local last_vpn_type=""
    if [ -e $LAST_VPN_TYEP_FILE ]; then
        last_vpn_type=`cat $LAST_VPN_TYEP_FILE`
    else
        last_vpn_type=`$UCI_GET vpn.client.proto | tr 'a-z' 'A-Z'`
    fi
    
    if [ "$last_vpn_type" = "PPTP" ]; then
        vpn_pptp_disconnect
    elif [ "$last_vpn_type" = "L2TP" ]; then
        vpn_l2tp_disconnect
    else
        echo "vpn disconnect type invalid."
    fi
}

vpn_connect()
{
    vpn_disconnect
    local vpn_type=`$UCI_GET vpn.client.proto | tr 'a-z' 'A-Z'`
    echo "$vpn_type" > $LAST_VPN_TYEP_FILE
    
    if [ "$vpn_type" = "PPTP" ]; then
        vpn_pptp_connect
    elif [ "$vpn_type" = "L2TP" ]; then
        vpn_l2tp_connect
    else
        echo "vpn connect type invalid."
    fi
}

vpn_conn_script_lock()
{
    local count=100
    
    while [ "$count" -gt 0 -a -e "$VPN_CONN_SCRIPT_RUNNING_FIEL" ]; do
        sleep 0.1  #sleep 100ms
        count=`expr $count - 1`
    done
    
    echo "lock" > "$VPN_CONN_SCRIPT_RUNNING_FIEL"
    sync
}

vpn_conn_script_unlock()
{
    local count=100
    
    while [ "$count" -gt 0 -a -e "$VPN_CONN_SCRIPT_RUNNING_FIEL" ]; do
        sleep 0.1  #sleep 100ms
        count=`expr $count - 1`
        rm -f "$VPN_CONN_SCRIPT_RUNNING_FIEL"
        sync
    done
}

vpn_conn_script_lock
cmd="$1"
force="$2"                                  
if [ "$cmd" = "conn" ]; then                
    vpn_connect                                                            
elif [ "$cmd" = "disconn" ]; then                             
    vpn_disconnect   
else
    echo "param invalid."
fi
vpn_conn_script_unlock
sync


