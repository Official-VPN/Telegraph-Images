#!/bin/sh

echo ""
printf '%s\n' "  ___   __  __ _      _       ___     ______  _   _   "
printf '%s\n' " / _ \ / _|/ _(_) ___(_) __ _| \ \   / /  _ \| \ | |  "
printf '%s\n' "| | | | |_| |_| |/ __| |/ _\` | |\ \ / /| |_) |  \| |  "
printf '%s\n' "| |_| |  _|  _| | (__| | (_| | | \ V / |  __/| |\  |  "
printf '%s\n' " \___/|_| |_| |_|\___|_|\__,_|_|  \_/  |_|   |_| \_|  "
echo ""
echo "         Router Update Script v2.0"
echo "    ======================================"
echo "    Do not turn off the power!"
echo "    ======================================"
echo ""

echo " _____ ___ __  __ ___   ___ _   _ _  _  ___"
echo "|_   _|_ _|  \/  | __| / __| | | | \| |/ __|"
echo "  | |  | || |\/| | _|  \__ \ |_| | .\` | (__ "
echo "  |_| |___|_|  |_|___| |___/\___/|_|\_|\___|"
echo ""
echo "Syncing time with NTP..."
ntpd -n -q -p 0.pool.ntp.org -p 1.pool.ntp.org -p 2.pool.ntp.org
echo "Current time: $(date)"
echo ""

cat > /etc/init.d/getdomains << EOF
#!/bin/sh /etc/rc.common

START=99

start () {
    DOMAINS=https://raw.githubusercontent.com/AnotherProksY/allow-domains/main/Russia/inside-dnsmasq-nfset.lst
    count=0
    while true; do
        if curl -m 3 github.com; then
            curl -f \$DOMAINS --output /tmp/dnsmasq.d/domains.lst
            break
        else
            echo "GitHub is not available. Check the internet availability [\$count]"
            count=\$((count+1))
        fi
    done

    if dnsmasq --conf-file=/tmp/dnsmasq.d/domains.lst --test 2>&1 | grep -q "syntax check OK"; then
        /etc/init.d/dnsmasq restart
    fi
}
EOF

chmod +x /etc/init.d/getdomains

cat > /etc/hotplug.d/iface/40-getvpnconfig << EOF
#!/bin/sh

sleep 10

ROUTER_MAC=\$(uci show network.@device[1].macaddr | cut -d"'" -f 2 | tr -d ':' | awk '{ print toupper(\$0) }')
SINGBOX_CONFIG_PATH='/etc/sing-box/config.json'

/etc/init.d/getdomains start

request_vpn_config() {
    REQUEST_URI="https://getconfig.tgvpnbot.com/getrouterconfig?routermac=\$ROUTER_MAC"

    curl \$REQUEST_URI > \$SINGBOX_CONFIG_PATH

    service sing-box restart
}

if [ -e \$SINGBOX_CONFIG_PATH ]
then
    SINGBOX_CONFIG_EMPTY=\$(cat \$SINGBOX_CONFIG_PATH)
    if [ -z "\${SINGBOX_CONFIG_EMPTY}" ]
    then
        request_vpn_config
    else
        exit 0
    fi
else
    request_vpn_config
fi
EOF

cp /etc/hotplug.d/iface/40-getvpnconfig /etc/hotplug.d/net/

chmod +x /etc/hotplug.d/iface/40-getvpnconfig

FIREWALL_CONF='/etc/config/firewall'

add_firewall_rule() {
    RULE_NAME="$1"
    RULE_BODY="$2"
    if ! grep -q "option name '${RULE_NAME}'" "$FIREWALL_CONF"; then
        echo "" >> "$FIREWALL_CONF"
        echo "$RULE_BODY" >> "$FIREWALL_CONF"
        echo "Firewall rule '${RULE_NAME}' added."
    else
        echo "Firewall rule '${RULE_NAME}' already exists, skipping."
    fi
}

add_firewall_rule 'WhatsApp Voice' "config rule
	option name 'WhatsApp Voice'
	option src 'lan'
	option dest '*'
	option proto 'udp'
	option set_mark '0x1'
	option target 'MARK'
	option family 'ipv4'
	option dest_port '3478 3479'"

add_firewall_rule 'Telegram VPN' "config rule
	option name 'Telegram VPN'
	option src 'lan'
	option dest '*'
	option proto 'all'
	option set_mark '0x1'
	option target 'MARK'
	option family 'ipv4'
	option dest_ip '91.108.8.0/22 91.108.16.0/22 91.108.12.0/22 149.154.160.0/20 91.105.192.0/23 91.108.20.0/22 185.76.151.0/24'"

add_firewall_rule 'VoIP' "config rule
	option name 'VoIP'
	option src 'lan'
	option dest '*'
	option proto 'udp'
	option set_mark '0x1'
	option target 'MARK'
	option family 'ipv4'
	option dest_port '5060 5061'"

add_firewall_rule 'Cloudflare' "config rule
	option name 'Cloudflare'
	option src 'lan'
	option dest '*'
	option proto 'all'
	option set_mark '0x1'
	option target 'MARK'
	option family 'ipv4'
	option dest_ip '173.245.48.0/20 103.21.244.0/22 103.22.200.0/22 103.31.4.0/22 141.101.64.0/18 108.162.192.0/18 190.93.240.0/20 188.114.96.0/20 197.234.240.0/22 198.41.128.0/17 162.158.0.0/15 104.16.0.0/13 104.24.0.0/14 172.64.0.0/13 131.0.72.0/22'"

add_firewall_rule 'Discord-Default' "config rule
	option name 'Discord-Default'
	option src 'lan'
	option dest '*'
	option proto 'all'
	option set_mark '0x1'
	option target 'MARK'
	option family 'ipv4'
	option dest_ip '162.159.130.234 162.159.134.234 162.159.133.234 162.159.135.234 162.159.136.234 162.159.137.232 162.159.135.232 162.159.136.232 162.159.138.232 162.159.128.233 198.244.231.90 162.159.129.233 162.159.130.233 162.159.133.233 162.159.134.233 162.159.135.233 162.159.138.234 162.159.137.234 162.159.134.232 162.159.130.235 162.159.129.235 162.159.129.232 162.159.128.235 162.159.130.232 162.159.133.232 162.159.128.232 34.126.226.51'"

add_firewall_rule 'Discord-Voice' "config rule
	option name 'Discord-Voice'
	option src 'lan'
	option dest '*'
	option proto 'udp'
	option set_mark '0x1'
	option target 'MARK'
	option family 'ipv4'
	option dest_ip '66.22.243.0/24 64.233.165.94 35.207.188.57 35.207.81.249 35.207.171.222 195.62.89.0/24 66.22.192.0/18 66.22.196.0/24 66.22.197.0/24 66.22.198.0/24 66.22.199.0/24 66.22.216.0/24 66.22.217.0/24 66.22.237.0/24 66.22.238.0/24 66.22.241.0/24 66.22.242.0/24 66.22.244.0/24 64.71.8.96/29 34.0.240.0/24 34.0.241.0/24 34.0.242.0/24 34.0.243.0/24 34.0.244.0/24 34.0.245.0/24 34.0.246.0/24 34.0.247.0/24 34.0.248.0/24 34.0.249.0/24 34.0.250.0/24 34.0.251.0/24 12.129.184.160/29 138.128.136.0/21 162.158.0.0/15 172.64.0.0/13 34.0.0.0/15 34.2.0.0/15 35.192.0.0/12 35.208.0.0/12 5.200.14.128/25'"

/etc/init.d/firewall restart

rm -f /etc/sing-box/config.json

/etc/hotplug.d/iface/40-getvpnconfig

echo ""
echo "  ____   ___  _   _ _____ _ "
echo " |  _ \ / _ \| \ | | ____| |"
echo " | | | | | | |  \| |  _| | |"
echo " | |_| | |_| | |\  | |___|_|"
echo " |____/ \___/|_| \_|_____(_)"
echo ""
echo "  OfficialVPN router has been updated!"
echo "        Thanks for waiting :)"
echo ""
echo " ____  _____ ____   ___   ___ _____ ___ _   _  ____ "
echo "|  _ \| ____| __ ) / _ \ / _ \_   _|_ _| \ | |/ ___|"
echo "| |_) |  _| |  _ \| | | | | | || |  | ||  \| | |  _ "
echo "|  _ <| |___| |_) | |_| | |_| || |  | || |\  | |_| |"
echo "|_| \_\_____|____/ \___/ \___/ |_| |___|_| \_|\____|"
echo ""
echo "    The router will reboot in a moment..."
echo ""

reboot
