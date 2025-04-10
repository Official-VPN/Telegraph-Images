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


# 1. Обновить скрипт getdomains
cat > /etc/init.d/getdomains << EOF
#!/bin/sh /etc/rc.common

START=99

start () {
    VPN_NOT_WOKRING=\$(sing-box -c /etc/sing-box/config.json tools fetch instagram.com 2>&1 | grep FATAL)
    if [ -z "\${VPN_NOT_WOKRING}" ]
    then
        # WITHOUT YOUTUBE
        DOMAINS=https://raw.githubusercontent.com/AnotherProksY/allow-domains-no-youtube/main/Russia/inside-dnsmasq-nfset.lst
    else
        # WITH YOUTUBE
        DOMAINS=https://raw.githubusercontent.com/AnotherProksY/allow-domains/main/Russia/inside-dnsmasq-nfset.lst
    fi

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

# 2. Даем права на выполнение
chmod +x /etc/init.d/getdomains

# 3. Создать скрипт для автоматического получения конфига
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

# 4. Скопировать скрипт в другую директорию
cp /etc/hotplug.d/iface/40-getvpnconfig /etc/hotplug.d/net/

# 5. Добавить права на исполнение
chmod +x /etc/hotplug.d/iface/40-getvpnconfig

# 6. Обновление пакетов openwrt 
opkg update 

# 7. Скачиваем файлы zapret в /tmp
wget -O /tmp/zapret-core.ipk https://raw.githubusercontent.com/AnotherProksY/TelegraphImages/main/zapret-files/zapret-core.ipk
wget -O /tmp/luciapp-zapret.ipk https://raw.githubusercontent.com/AnotherProksY/TelegraphImages/main/zapret-files/luciapp-zapret.ipk

# 8. Устанавливаем файлы
if opkg install /tmp/zapret-core.ipk; then
    echo "Zapret installed successfully."
else
    echo "Failed to install Zapret."
    exit 1
fi

if opkg install /tmp/luciapp-zapret.ipk; then
    echo "LuCI app installed successfully."
else
    echo "Failed to install LuCI app."
    exit 1
fi

# 9. Удаляем файлы zapret из /tmp
rm /tmp/zapret-core.ipk
rm /tmp/luciapp-zapret.ipk

# 10. Удалить старый конфиг (если он есть)
rm -rf /etc/sing-box/config.json

# 11. Запустить скрипт 40-getvpnconfig
/etc/hotplug.d/iface/40-getvpnconfig

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
