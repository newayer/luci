module("luci.controller.relay", package.seeall)

function index()
        entry({"admin", "network", "relay"}, cbi("relay"), _("中继"), 111)
        end
