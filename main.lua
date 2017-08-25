package.path = package.path..';.luarocks/share/lua/5.2/?.lua;.luarocks/share/lua/5.2/?/init.lua'
package.cpath = package.cpath..';.luarocks/lib/lua/5.2/?.so'

function dl_cb (arg, data)
end

redis = require('redis')
redis = redis.connect('127.0.0.1', 6379)

Ads_id = "ADS-ID"

require('TG')
