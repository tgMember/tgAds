package.path = package.path..';.luarocks/share/lua/5.2/?.lua;.luarocks/share/lua/5.2/?/init.lua'
package.cpath = package.cpath..';.luarocks/lib/lua/5.2/?.so'

redis = require('redis')
redis = redis.connect('127.0.0.1', 6379)
json = require'dkjson'
serpent = require "serpent"
ltn12=require("ltn12")
lgi = require ('lgi')
notify = lgi.require('Notify')
notify.init ("Telegram updates")
chats = {}
day = 86400

Ads_id = "ADS-ID"

require('TG')

function do_notify (user, msg)
  local n = notify.Notification.new("message", "" .. user .. "".. msg .. "")
  local n = notify.Notification.new(user, msg)
  n:show ()
end

function vardump(value)
  print(serpent.block(value, {comment=false}))
end

function dl_cb (arg, data)
end

function tdcli_update_callback(data)
	Doing(data, Ads_id)
end
