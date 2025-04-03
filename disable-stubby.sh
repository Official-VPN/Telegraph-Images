#!/bin/sh

echo ""
echo ""
echo ""
echo ""
echo ""
echo "-----------------------------------"
echo -e "\e[32mReset stubby\e[0m"
echo "-----------------------------------"
echo ""
echo ""
echo ""
echo ""
echo ""

uci set dhcp.@dnsmasq[0].noresolv="0"

uci -q delete dhcp.@dnsmasq[0].server

uci commit dhcp

/etc/init.d/dnsmasq restart


echo ""
echo ""
echo ""
echo ""
echo ""
echo "-----------------------------------"
echo -e "\e[32mStubby has been dropped!\e[0m"
echo "-----------------------------------"
echo ""
echo ""
echo ""
echo ""
echo ""
