--[[
LuCI - Lua Configuration Interface

Copyright 2010 Jo-Philipp Wich <luci@lists.subsignal>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0
]]--

require("luci.sys")

m = Map("vpn", translate("xl2tp"), translate("Configure xl2tp client."))

s = m:section(TypedSection, "vpn", "client")
s.addremove = false
s.anonymous = true

enable = s:option(Flag, "enable", translate("Enable"))
name = s:option(Value, "username", translate("Username"))
pass = s:option(Value, "password", translate("Password"))
pass.password = true
domain = s:option(Value, "server_addr", translate("Server IP"))


local apply = luci.http.formvalue("cbi.apply")
if apply then
	io.popen("sleep 3 && /etc/init.d/vpnclient restart &")
end

return m
