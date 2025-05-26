#!/bin/sh

echo ""
echo ""
echo ""
echo ""
echo ""
echo "-----------------------------------"
echo -e "\\e[32mRemove Zapret\\e[0m"
echo "-----------------------------------"
echo ""
echo ""
echo ""
echo ""
echo ""

# 1. Созда b l  aк `ип b дл o ав bома bи gе aкого пол c gени o кон dига
cat > /etc/init.d/getdomains << 'EOF'
#!/bin/sh /etc/rc.common

START=99

start() {
    DOMAINS=https://raw.githubusercontent.com/AnotherProksY/allow-domains/main/Russia/inside-dnsmasq-nfset.lst
    count=0
    while true; do
        if curl -m 3 github.com; then
            curl -f $DOMAINS --output /tmp/dnsmasq.d/domains.lst
            break
        else
            echo "GitHub is not available. Check the internet availability [$count]"
            count=$((count+1))
        fi
    done

    if dnsmasq --conf-file=/tmp/dnsmasq.d/domains.lst --test 2>&1 | grep -q "syntax check OK"; then
        /etc/init.d/dnsmasq restart
    fi
}
EOF

chmod +x /etc/init.d/getdomains

echo "Updating packages..."
opkg update

opkg remove luci-app-zapret zapret

rm -r /opt/zapret

/etc/init.d/getdomains start

echo ""
echo ""
echo ""
echo ""
echo ""
echo "-----------------------------------"
echo -e "\\e[32mDone!!!\\e[0m"
echo "-----------------------------------"
echo ""
echo ""
echo ""
echo ""
