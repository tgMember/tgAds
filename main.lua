package.path = package.path..';.luarocks/share/lua/5.2/?.lua;.luarocks/share/lua/5.2/?/init.lua'
package.cpath = package.cpath..';.luarocks/lib/lua/5.2/?.so'

redis = require('redis')
redis = redis.connect('127.0.0.1', 6379)
Ads_id = "ADS-ID"

function dl_cb(arg, data)
end

require('TG')

function tdcli_update_callback(data)
	Doing(data, Ads_id)
end