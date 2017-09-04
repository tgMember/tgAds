package.path = package.path..';.luarocks/share/lua/5.2/?.lua;.luarocks/share/lua/5.2/?/init.lua'
package.cpath = package.cpath..';.luarocks/lib/lua/5.2/?.so'

redis = require('redis')
redis = redis.connect('127.0.0.1', 6379)
serpent = require "serpent"
ltn12=require("ltn12")

Ads_id = "ADS-ID"

require('TG')

function vardump(value)
  print(serpent.block(value, {comment=false}))
end

function dl_cb (arg, data)
end

function tdcli_update_callback(data)
	Doing(data, Ads_id)
end
