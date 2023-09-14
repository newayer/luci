--[[
LuCI - Lua Configuration Interface

Copyright 2010 Jo-Philipp Wich <luci@lists.subsignal>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0
]]--

require("luci.sys")

m = Map("relay", translate("RELAY"), translate("中继模式配置"))

s = m:section(TypedSection, "relay", "relay")
s.addremove = false
s.anonymous = true

enable = s:option(Flag, "enable", translate("Enable"))
wan_ip = s:option(Value, "wan_ip", translate("Eth0 IP"))
bss_net = s:option(Value, "bss_net", translate("基站网络"))
gw = s:option(Value, "gw", translate("自组网网关"))

local apply = luci.http.formvalue("cbi.apply")

if apply then
	io.popen("sleep 3 && /etc/init.d/relay restart &")
end

return m
