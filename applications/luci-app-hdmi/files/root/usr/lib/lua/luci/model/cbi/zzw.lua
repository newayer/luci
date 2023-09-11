--[[
LuCI - Lua Configuration Interface

Copyright 2010 Jo-Philipp Wich <luci@lists.subsignal>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0
]]--

require("luci.sys")

m = Map("zzw", translate("zzw"), translate("配置自组网地址"))

s = m:section(TypedSection, "zzw", "zzw")
s.addremove = false
s.anonymous = true


zzwip = s:option(Value, "zzw_addr", translate("ZZW IP"))

local apply = luci.http.formvalue("cbi.apply")

return m
