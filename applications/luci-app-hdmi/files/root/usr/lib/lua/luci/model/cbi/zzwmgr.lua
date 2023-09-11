--[[
LuCI - Lua Configuration Interface

Copyright 2010 Jo-Philipp Wich <luci@lists.subsignal>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0
]]--

local http = require 'luci.http'

local cr = require("luci.model.uci").cursor()
local zzwip =cr:get("zzw", "zzwip", "zzw_addr")
if zzwip and zzwip ~= '' then
    http.redirect(string.format("http://%s",zzwip))
end
