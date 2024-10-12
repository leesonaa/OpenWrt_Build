#
#!/bin/bash
# © 2022 GitHub, Inc.
#====================================================================
# Copyright (c) 2022 Ing
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/wjz304/OpenWrt_Build
# File name: diy.sh
# Description: OpenWrt DIY script
#====================================================================



# uninstall duplicate packages
#./scripts/feeds uninstall luci-theme-argon
#./scripts/feeds uninstall luci-app-netdata
#./scripts/feeds uninstall luci-app-smartdns
#./scripts/feeds uninstall luci-app-pushbot

# install the new version in the ing source
#./scripts/feeds install -a -f -p ing


# Modify default IP
sed -i 's/192.168.1.1/192.168.8.1/g' package/base-files/files/bin/config_generate



# Modify the version number
#sed -i "s/OpenWrt /OpenWrt build $(TZ=UTC-8 date "+%Y.%m.%d") @ OpenWrt /g" package/lean/default-settings/files/zzz-default-settings
sed -i '/exit 0/i uci set network.globals.ula_prefix=\nuci commit network' package/emortal/default-settings/files/99-default-settings-chinese

# Modify default 
#sed -i '/exit 0/i uci set dhcp.lan.ra_dns="0"\nuci commit dhcp' package/emortal/default-settings/files/99-default-settings-chinese  # 关闭ipv6 ra通告dns

# Modify default theme
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
sed -i 's/bootstrap/argon/g' feeds/luci/modules/luci-base/root/etc/config/luci


# Modify maximum connections
sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=165535' package/base-files/files/etc/sysctl.conf



# Add kernel build user
[ -z $(grep "CONFIG_KERNEL_BUILD_USER=" .config) ] &&
    echo 'CONFIG_KERNEL_BUILD_USER="OpenWrt"' >>.config ||
    sed -i 's@\(CONFIG_KERNEL_BUILD_USER=\).*@\1$"OpenWrt"@' .config

# Add kernel build domain
[ -z $(grep "CONFIG_KERNEL_BUILD_DOMAIN=" .config) ] &&
    echo 'CONFIG_KERNEL_BUILD_DOMAIN="GitHub Actions"' >>.config ||
    sed -i 's@\(CONFIG_KERNEL_BUILD_DOMAIN=\).*@\1$"GitHub Actions"@' .config


