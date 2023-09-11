module("luci.controller.hdmi", package.seeall)

function index()
        entry({"admin", "status", "hdmi"}, cbi("hdmi"), _("HDMI"), 11)
        entry({"admin", "network", "zzw"}, cbi("zzw"), _("自组网配置"), 101)
	entry({"admin", "status", "zzwmgr"}, cbi("zzwmgr"), _("自组网管理"), 12)
        end
