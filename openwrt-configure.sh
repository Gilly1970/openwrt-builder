#!/bin/bash

# DEVICE can be main or <nothing>
DEVICE="${DEVICE:$1}"
FULL_WPAD="${FULL_WPAD:'yes'}"

COMMAND="opkg update"
if [[ "$FULL_WPAD" =~ yes|Yes ]]; then
  COMMAND="$COMMAND; opkg remove wpad-basic-wolfssl;"
  COMMAND="$COMMAND; opkg remove wpad-basic-mbedtls; opkg install wpad-mbedtls"
fi

# basic packages
COMMAND="$COMMAND; opkg install collectd collectd-mod-sensors \
collectd-mod-thermal luci-app-statistics collectd-mod-irq \
luci luci-ssl luci-i18n-base-pl vim htop \
curl iperf3 irqbalance luci-app-attendedsysupgrade \
auc bmon"

# additional packages
if [[ "$DEVICE" =~ Main|main ]]; then
    COMMAND="$COMMAND luci-app-wireguard luci-proto-wireguard kmod-wireguard wireguard-tools qrencode"
    COMMAND="$COMMAND https-dns-proxy luci-app-https-dns-proxy luci-i18n-https-dns-proxy-pl"
    COMMAND="$COMMAND luci-app-sqm luci-i18n-sqm-pl collectd-mod-sqm"
fi

COMMAND="$COMMAND; /etc/init.d/uhttpd start ; /etc/init.d/uhttpd enable;"

read -n 1 -r -p "Should I execute command: $COMMAND ?" yn
case $yn in
    [Yy]* ) $COMMAND;;
    [Nn]* ) exit;;
    * ) echo "Please answer yes or no.";;
esac

read -n 1 -r -p "Should I reboot device?" yn
case $yn in
    [Yy]* ) reboot;;
    [Nn]* ) exit;;
    * ) echo "Please answer yes or no.";;
esac

# For https://firmware-selector.openwrt.org/
# Add packages. NOTE: To install wpad-wolfssl, just replace the package name with wpad-basic-wolfssl
### basic
# (...) collectd collectd-mod-sensors collectd-mod-thermal luci-app-statistics luci luci-ssl luci-i18n-base-pl vim htop curl iperf3 irqbalance luci-app-attendedsysupgrade auc bmon

### wireguard
#       luci-app-wireguard luci-proto-wireguard kmod-wireguard wireguard-tools qrencode

### DNS over HTTPS
#       https-dns-proxy luci-app-https-dns-proxy luci-i18n-https-dns-proxy-pl

### Bufferbloat - install SQM - https://openwrt.org/docs/guide-user/network/traffic-shaping/sqm
#       luci-app-sqm luci-i18n-sqm-pl collectd-mod-sqm

### to use mbedtls, replace:
# libustream-wolfssl and wpad-basic-wolfssl *WITH* libustream-mbedtls and wpad-basic-mbedtls.

# to enable 802.11k/v replace:
# wpad-basic-mbedtls with wpad-mbedtls