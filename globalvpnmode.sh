#!/bin/sh

echo ""
echo ""
echo ""
echo ""
echo ""
echo "-----------------------------------"
echo -e "\\e[32mInstall Global VPN mode\\e[0m"
echo "-----------------------------------"
echo ""
echo ""
echo ""
echo ""
echo ""

cat > /etc/init.d/getdomains << 'EOF'
#!/bin/sh /etc/rc.common

START=99

start () {
echo "nftset=/#/4#inet#fw4#vpn_domains" > /tmp/dnsmasq.d/domains.lst
}
EOF

chmod +x /etc/init.d/getdomains

/etc/init.d/getdomains start

service dnsmasq restart

reboot

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
