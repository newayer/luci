include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-relay
PKG_VERSION=1.0
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-relay
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=RELAY Client for LuCI
	PKGARCH:=all
endef

define Package/luci-app-relay/description
	This package contains LuCI configuration pages for relay mode.
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-relay/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	
	$(INSTALL_CONF) ./files/root/etc/config/relay $(1)/etc/config/relay
	$(INSTALL_BIN) ./files/root/etc/init.d/relay $(1)/etc/init.d/relay
	$(INSTALL_BIN) ./files/root/usr/bin/relay.sh $(1)/usr/bin/relay.sh
	$(INSTALL_DATA) ./files/root/usr/lib/lua/luci/model/cbi/relay.lua $(1)/usr/lib/lua/luci/model/cbi/relay.lua
	$(INSTALL_DATA) ./files/root/usr/lib/lua/luci/controller/relay.lua $(1)/usr/lib/lua/luci/controller/relay.lua
endef

$(eval $(call BuildPackage,luci-app-relay))
