package.path = package.path..';.luarocks/share/lua/5.2/?.lua;.luarocks/share/lua/5.2/?/init.lua'
package.cpath = package.cpath..';.luarocks/lib/lua/5.2/?.so'

local ltn12=require("ltn12")
local lgi = require ('lgi')
local notify = lgi.require('Notify')
notify.init ("Telegram updates")

chats = {}

function do_notify (user, msg)
  local n = notify.Notification.new("message", "" .. user .. "".. msg .. "")
  local n = notify.Notification.new(user, msg)
  n:show ()
end

function dl_cb (arg, data)
end

redis = require('redis')
redis = redis.connect('127.0.0.1', 6379)

Ads_id = "ADS-ID"

require('TG')
