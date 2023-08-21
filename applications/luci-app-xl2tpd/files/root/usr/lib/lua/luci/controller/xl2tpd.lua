module("luci.controller.xl2tpd", package.seeall)

function index()
        entry({"admin", "network", "xl2tp"}, cbi("xl2tpd"), _("VPN"), 100)
        end
