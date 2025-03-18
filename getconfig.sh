#!/bin/sh

echo ""
echo ""
echo ""
echo ""
echo ""
echo "-----------------------------------"
echo -e "\e[32mRouter OfficialVPN update (do not turn off the power)\e[0m"
echo "-----------------------------------"
echo ""
echo ""
echo ""
echo ""
echo ""


# 1. Создать скрипт для автоматического получения конфига
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

# 2. Скопировать скрипт в другую директорию
cp /etc/hotplug.d/iface/40-getvpnconfig /etc/hotplug.d/net/

# 3. Добавить права на исполнение
chmod +x /etc/hotplug.d/iface/40-getvpnconfig

# 4. Удалить старый конфиг (если он есть)
rm -rf /etc/sing-box/config.json

# 5. Запустить скрипт 40-getvpnconfig
/etc/hotplug.d/iface/40-getvpnconfig

# 5. Обновление пакетов openwrt 
opkg update 

echo ""
echo ""
echo ""
echo ""
echo ""
echo "-----------------------------------"
echo -e "\e[32mOfficialVPN router has been updated! Thanks for waiting\e[0m"
echo "-----------------------------------"
echo ""
echo ""
echo ""
echo ""
echo ""
echo "-----------------------------------"
echo -e "\e[32mThe router will reboot\e[0m"
echo "-----------------------------------"
echo ""
echo ""
echo ""
echo ""
echo ""

reboot
