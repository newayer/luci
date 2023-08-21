include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-xl2tpd
PKG_VERSION=1.0
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-xl2tpd
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=XL2TPD Client for LuCI
	PKGARCH:=all
endef

define Package/luci-app-xl2tpd/description
	This package contains LuCI configuration pages for xl2tpd.
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-xl2tpd/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	
	$(INSTALL_CONF) ./files/root/etc/config/vpn $(1)/etc/config/vpn
	$(INSTALL_BIN) ./files/root/etc/init.d/vpnclient $(1)/etc/init.d/vpnclient
	$(INSTALL_BIN) ./files/root/usr/bin/vpn_client.sh $(1)/usr/bin/vpn_client.sh
	$(INSTALL_DATA) ./files/root/usr/lib/lua/luci/model/cbi/xl2tpd.lua $(1)/usr/lib/lua/luci/model/cbi/xl2tpd.lua
	$(INSTALL_DATA) ./files/root/usr/lib/lua/luci/controller/xl2tpd.lua $(1)/usr/lib/lua/luci/controller/xl2tpd.lua
endef

$(eval $(call BuildPackage,luci-app-xl2tpd))
