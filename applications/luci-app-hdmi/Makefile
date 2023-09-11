include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-hdmi
PKG_VERSION=1.0
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-hdmi
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=HDMI and ZZW
	PKGARCH:=all
endef

define Package/luci-app-hdmi/description
	This package contains LuCI configuration pages for HDMI AND ZZW.
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-hdmi/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	
	$(INSTALL_CONF) ./files/root/etc/config/zzw $(1)/etc/config/zzw
	$(INSTALL_DATA) ./files/root/usr/lib/lua/luci/model/cbi/hdmi.lua $(1)/usr/lib/lua/luci/model/cbi/hdmi.lua
	$(INSTALL_DATA) ./files/root/usr/lib/lua/luci/model/cbi/zzw.lua $(1)/usr/lib/lua/luci/model/cbi/zzw.lua
	$(INSTALL_DATA) ./files/root/usr/lib/lua/luci/model/cbi/zzwmgr.lua $(1)/usr/lib/lua/luci/model/cbi/zzwmgr.lua
	$(INSTALL_DATA) ./files/root/usr/lib/lua/luci/controller/hdmi.lua $(1)/usr/lib/lua/luci/controller/hdmi.lua
endef

$(eval $(call BuildPackage,luci-app-hdmi))
