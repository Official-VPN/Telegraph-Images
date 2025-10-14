#!/bin/sh

WIRELESS_CONFIG="/etc/config/wireless"


OPENWRT_VERSION=$(cat /etc/os-release | grep 'VERSION_ID=' | cut -d'"' -f2 | cut -d'.' -f1)


cp "$WIRELESS_CONFIG" "$WIRELESS_CONFIG.bak" 2>/dev/null


if [ "$OPENWRT_VERSION" = "24" ]; then
    cat > "$WIRELESS_CONFIG" << 'EOF'
config wifi-device 'radio0'
        option type 'mac80211'
        option path 'platform/soc/18000000.wifi'
        option channel '1'
        option band '2g'
        option htmode 'HE20'
        option cell_density '0'

config wifi-iface 'default_radio0'
        option device 'radio0'
        option network 'lan'
        option mode 'ap'
        option ssid 'OfficialVPN_2G'
        option encryption 'psk2'
        option key '12345678'

config wifi-device 'radio1'
        option type 'mac80211'
        option path 'platform/soc/18000000.wifi+1'
        option band '5g'
        option channel '36'
        option htmode 'HE80'
        option cell_density '0'

config wifi-iface 'default_radio1'
        option device 'radio1'
        option network 'lan'
        option mode 'ap'
        option ssid 'OfficialVPN_5G'
        option encryption 'psk2'
        option key '12345678'
EOF
    echo "OS-Release 24 in $WIRELESS_CONFIG"
else
    cat > "$WIRELESS_CONFIG" << 'EOF'
config wifi-device 'radio0'
        option type 'mac80211'
        option path 'platform/18000000.wifi'
        option channel '1'
        option band '2g'
        option htmode 'HE20'
        option disabled '0'
        option country 'US'
        option cell_density '0'

config wifi-iface 'default_radio0'
        option device 'radio0'
        option network 'lan'
        option mode 'ap'
        option ssid 'OfficialVPN_2G'
        option encryption 'psk2'
        option key '12345678'

config wifi-device 'radio1'
        option type 'mac80211'
        option path 'platform/18000000.wifi+1'
        option channel '36'
        option band '5g'
        option htmode 'HE80'
        option disabled '0'
        option country 'US'
        option cell_density '0'

config wifi-iface 'default_radio1'
        option device 'radio1'
        option network 'lan'
        option mode 'ap'
        option ssid 'OfficialVPN_5G'
        option encryption 'psk2'
        option key '12345678'
EOF
    echo "OS-Release 23 in $WIRELESS_CONFIG"
fi
