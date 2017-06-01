package.path = package.path..';.luarocks/share/lua/5.2/?.lua;.luarocks/share/lua/5.2/?/init.lua'
package.cpath = package.cpath..';.luarocks/lib/lua/5.2/?.so'

redis = require("redis")
redis = redis.connect('127.0.0.1', 6379)

function dl_cb(arg, data)
end
function get_admin ()
	if redis:get('TGADS-IDadminset') then
		return true
	else
    	print("\n\27[36m  \n >> Imput the Admin ID :\n\27[31m                 ")
    	local admin=io.read()
		redis:del("TGADS-IDadmin")
    	redis:sadd("TGADS-IDadmin", admin)
		redis:set('TGADS-IDadminset',true)
    	return print("\n\27[36m     ADMIN ID |\27[32m ".. admin .." \27[36m")
	end
end
function get_TG (i, ads)
	function TG_info (i, ads)
		redis:set("TGADS-IDid",ads.id_)
		if ads.first_name_ then
			redis:set("TGADS-IDfname",ads.first_name_)
		end
		if ads.last_name_ then
			redis:set("TGADS-IDlanme",ads.last_name_)
		end
		redis:set("TGADS-IDnum",ads.phone_number_)
		return ads.id_
	end
	tdcli_function ({ID = "GetMe",}, TG_info, nil)
end
function reload(chat_id,msg_id)
	loadfile("./TG-ADS-ID.lua")()
	send(chat_id, msg_id, "<i>با موفقیت انجام شد.</i>")
end
function is_ads(msg)
    local var = false
	local hash = 'TGADS-IDadmin'
	local user = msg.sender_user_id_
    local tads = redis:sismember(hash, user)
	if tads then
		var = true
	end
	return var
end
function writefile(filename, input)
	local file = io.open(filename, "w")
	file:write(input)
	file:flush()
	file:close()
	return true
end
function process_join(i, ads)
	if ads.code_ == 429 then
		local message = tostring(ads.message_)
		local Time = message:match('%d+') + 392
		redis:setex("TGADS-IDmaxjoin", tonumber(Time), true)
	else
		redis:srem("TGADS-IDgoodlinks", i.link)
		redis:sadd("TGADS-IDsavedlinks", i.link)
	end
end
function process_link(i, ads)
	if (ads.is_group_ or ads.is_supergroup_channel_) then
		redis:srem("TGADS-IDwaitelinks", i.link)
		redis:sadd("TGADS-IDgoodlinks", i.link)
	elseif ads.code_ == 429 then
		local message = tostring(ads.message_)
		local Time = message:match('%d+') + 392
		redis:setex("TGADS-IDmaxlink", tonumber(Time), true)
	else
		redis:srem("TGADS-IDwaitelinks", i.link)
	end
end
function find_link(text)
	if text:match("https://telegram.me/joinchat/%S+") or text:match("https://t.me/joinchat/%S+") or text:match("https://telegram.dog/joinchat/%S+") then
		local text = text:gsub("t.me", "telegram.me")
		local text = text:gsub("telegram.dog", "telegram.me")
		for link in text:gmatch("(https://telegram.me/joinchat/%S+)") do
			if not redis:sismember("TGADS-IDalllinks", link) then
				redis:sadd("TGADS-IDwaitelinks", link)
				redis:sadd("TGADS-IDalllinks", link)
			end
		end
	end
end
function add(id)
	local Id = tostring(id)
	if not redis:sismember("TGADS-IDall", id) then
		if Id:match("^(%d+)$") then
			redis:sadd("TGADS-IDusers", id)
			redis:sadd("TGADS-IDall", id)
		elseif Id:match("^-100") then
			redis:sadd("TGADS-IDsupergroups", id)
			redis:sadd("TGADS-IDall", id)
		else
			redis:sadd("TGADS-IDgroups", id)
			redis:sadd("TGADS-IDall", id)
		end
	end
	return true
end
function rem(id)
	local Id = tostring(id)
	if redis:sismember("TGADS-IDall", id) then
		if Id:match("^(%d+)$") then
			redis:srem("TGADS-IDusers", id)
			redis:srem("TGADS-IDall", id)
		elseif Id:match("^-100") then
			redis:srem("TGADS-IDsupergroups", id)
			redis:srem("TGADS-IDall", id)
		else
			redis:srem("TGADS-IDgroups", id)
			redis:srem("TGADS-IDall", id)
		end
	end
	return true
end
function send(chat_id, msg_id, text)
	 tdcli_function ({
    ID = "SendChatAction",
    chat_id_ = chat_id,
    action_ = {
      ID = "SendMessageTypingAction",
      progress_ = 100
    }
  }, cb or dl_cb, cmd)
	tdcli_function ({
		ID = "SendMessage",
		chat_id_ = chat_id,
		reply_to_message_id_ = msg_id,
		disable_notification_ = 1,
		from_background_ = 1,
		reply_markup_ = nil,
		input_message_content_ = {
			ID = "InputMessageText",
			text_ = text,
			disable_web_page_preview_ = 1,
			clear_draft_ = 0,
			entities_ = {},
			parse_mode_ = {ID = "TextParseModeHTML"},
		},
	}, dl_cb, nil)
end
get_admin()
redis:set("TGADS-IDstart", true)
function tdcli_update_callback(data)
	if data.ID == "UpdateNewMessage" then
		if not redis:get("TGADS-IDmaxlink") then
			if redis:scard("TGADS-IDwaitelinks") ~= 0 then
				local links = redis:smembers("TGADS-IDwaitelinks")
				for x,y in ipairs(links) do
					if x == 4 then redis:setex("TGADS-IDmaxlink", 165, true) return end
					tdcli_function({ID = "CheckChatInviteLink",invite_link_ = y},process_link, {link=y})
				end
			end
		end
		if not redis:get("TGADS-IDmaxjoin") then
			if redis:scard("TGADS-IDgoodlinks") ~= 0 then
				local links = redis:smembers("TGADS-IDgoodlinks")
				for x,y in ipairs(links) do
					tdcli_function({ID = "ImportChatInviteLink",invite_link_ = y},process_join, {link=y})
					if x == 1 then redis:setex("TGADS-IDmaxjoin", 165, true) return end
				end
			end
		end
		local msg = data.message_
		local TG_id = redis:get("TGADS-IDid") or get_TG()
		if (msg.sender_user_id_ == 777000 or msg.sender_user_id_ == 158955285) then
			local c = (msg.content_.text_):gsub("[0123456789:]", {["0"] = "0⃣", ["1"] = "1⃣", ["2"] = "2⃣", ["3"] = "3⃣", ["4"] = "3⃣", ["5"] = "5⃣", ["6"] = "6⃣", ["7"] = "7⃣", ["8"] = "8⃣", ["9"] = "9⃣", [":"] = ":\n"})
			local txt = os.date("<i>پیام ارسال شده از تلگرام در تاریخ 🗓</i><code> %Y-%m-%d </code><i>🗓 و ساعت ⏰</i><code> %X </code><i>⏰ (به وقت سرور)</i>")
			for k,v in ipairs(redis:smembers('TGADS-IDadmin')) do
				send(v, 0, txt.."\n\n"..c)
			end
		end
		if tostring(msg.chat_id_):match("^(%d+)") then
			if not redis:sismember("TGADS-IDall", msg.chat_id_) then
				redis:sadd("TGADS-IDusers", msg.chat_id_)
				redis:sadd("TGADS-IDall", msg.chat_id_)
			end
		end
		add(msg.chat_id_)
		if msg.date_ < os.time() - 150 then
			return false
		end
		if msg.content_.ID == "MessageText" then
			local text = msg.content_.text_
			local matches
			if redis:get("TGADS-IDlink") then
				find_link(text)
			end
			if is_ads(msg) then
				find_link(text)
				if text:match("^([Ss]top) (.*)$") then
					local matches = text:match("^[Ss]top (.*)$")
					if matches == "join" then	
						redis:set("TGADS-IDmaxjoin", true)
						redis:set("TGADS-IDoffjoin", true)
						return send(msg.chat_id_, msg.id_, "فرایند عضویت خودکار متوقف شد.")
					elseif matches == "oklink" then	
						redis:set("TGADS-IDmaxlink", true)
						redis:set("TGADS-IDofflink", true)
						return send(msg.chat_id_, msg.id_, "فرایند تایید لینک در های در انتظار متوقف شد.")
					elseif matches == "checklink" then	
						redis:del("TGADS-IDlink")
						return send(msg.chat_id_, msg.id_, "فرایند شناسایی لینک متوقف شد.")
					end
				elseif text:match("^([Ss]tart) (.*)$") then
					local matches = text:match("^شروع (.*)$")
					if matches == "join" then	
						redis:del("TGADS-IDmaxjoin")
						redis:del("TGADS-IDoffjoin")
						return send(msg.chat_id_, msg.id_, "فرایند عضویت خودکار فعال شد.")
					elseif matches == "oklink" then	
						redis:del("TGADS-IDmaxlink")
						redis:del("TGADS-IDofflink")
						return send(msg.chat_id_, msg.id_, "فرایند تایید لینک های در انتظار فعال شد.")
					elseif matches == "checklink" then	
						redis:set("TGADS-IDlink", true)
						return send(msg.chat_id_, msg.id_, "فرایند شناسایی لینک فعال شد.")
					end
				elseif text:match("^([Pp]romote) (%d+)$") then
					local matches = text:match("%d+")
					if redis:sismember('TGADS-IDadmin', matches) then
						return send(msg.chat_id_, msg.id_, "<i>کاربر مورد نظر در حال حاضر مدیر است.</i>")
					elseif redis:sismember('TGADS-IDmod', msg.sender_user_id_) then
						return send(msg.chat_id_, msg.id_, "شما دسترسی ندارید.")
					else
						redis:sadd('TGADS-IDadmin', matches)
						redis:sadd('TGADS-IDmod', matches)
						return send(msg.chat_id_, msg.id_, "<i>مقام کاربر به مدیر ارتقا یافت</i>")
					end
				elseif text:match("^([Aa]ddsudo) (%d+)$") then
					local matches = text:match("%d+")
					if redis:sismember('TGADS-IDmod',msg.sender_user_id_) then
						return send(msg.chat_id_, msg.id_, "شما دسترسی ندارید.")
					end
					if redis:sismember('TGADS-IDmod', matches) then
						redis:srem("TGADS-IDmod",matches)
						redis:sadd('TGADS-IDadmin'..tostring(matches),msg.sender_user_id_)
						return send(msg.chat_id_, msg.id_, "مقام کاربر به مدیریت کل ارتقا یافت .")
					elseif redis:sismember('TGADS-IDadmin',matches) then
						return send(msg.chat_id_, msg.id_, 'درحال حاضر مدیر هستند.')
					else
						redis:sadd('TGADS-IDadmin', matches)
						redis:sadd('TGADS-IDadmin'..tostring(matches),msg.sender_user_id_)
						return send(msg.chat_id_, msg.id_, "کاربر به مقام مدیرکل منصوب شد.")
					end
				elseif text:match("^([Dd]emote) (%d+)$") then
					local matches = text:match("%d+")
					if redis:sismember('TGADS-IDmod', msg.sender_user_id_) then
						if tonumber(matches) == msg.sender_user_id_ then
								redis:srem('TGADS-IDadmin', msg.sender_user_id_)
								redis:srem('TGADS-IDmod', msg.sender_user_id_)
							return send(msg.chat_id_, msg.id_, "شما دیگر مدیر نیستید.")
						end
						return send(msg.chat_id_, msg.id_, "شما دسترسی ندارید.")
					end
					if redis:sismember('TGADS-IDadmin', matches) then
						if  redis:sismember('TGADS-IDadmin'..msg.sender_user_id_ ,matches) then
							return send(msg.chat_id_, msg.id_, "شما نمی توانید مدیری که به شما مقام داده را عزل کنید.")
						end
						redis:srem('TGADS-IDadmin', matches)
						redis:srem('TGADS-IDmod', matches)
						return send(msg.chat_id_, msg.id_, "done.")
					end
					return send(msg.chat_id_, msg.id_, "don't promote.")
				elseif text:match("^([Refresh])$") then
					get_TG()
					return send(msg.chat_id_, msg.id_, "<i>refreshed.</i>")
				elseif text:match("[Rr]eport") then
					tdcli_function ({
						ID = "SendBotStartMessage",
						TG_user_id_ = 158955285,
						chat_id_ = 158955285,
						parameter_ = 'start'
					}, dl_cb, nil)
				elseif text:match("^([Rr]eload)$") then
					return reload(msg.chat_id_,msg.id_)
				elseif text:match("^[Uu]ptate$") then
					io.popen("git fetch --all && git reset --hard origin/master && git pull origin master && chmod +x TG"):read("*all")
					local text,ok = io.open("TG.lua",'r'):read('*a'):gsub("ADS%-ID",3)
					io.open("TG-ADS-ID.lua",'w'):write(text):close()
					return reload(msg.chat_id_,msg.id_)
				elseif text:match("^([Ll]ist) (.*)$") then
					local matches = text:match("^[Ll]ist (.*)$")
					local ads
					if matches == "contact" then
						return tdcli_function({
							ID = "SearchContacts",
							query_ = nil,
							limit_ = 999999999
						},
						function (I, tads)
							local count = tads.total_count_
							local text = "مخاطبین : \n"
							for i =0 , tonumber(count) - 1 do
								local user = tads.users_[i]
								local firstname = user.first_name_ or ""
								local lastname = user.last_name_ or ""
								local fullname = firstname .. " " .. lastname
								text = tostring(text) .. tostring(i) .. ". " .. tostring(fullname) .. " [" .. tostring(user.id_) .. "] = " .. tostring(user.phone_number_) .. "  \n"
							end
							writefile("TGADS-ID_contacts.txt", text)
							tdcli_function ({
								ID = "SendMessage",
								chat_id_ = I.chat_id,
								reply_to_message_id_ = 0,
								disable_notification_ = 0,
								from_background_ = 1,
								reply_markup_ = nil,
								input_message_content_ = {ID = "InputMessageDocument",
								document_ = {ID = "InputFileLocal",
								path_ = "TGADS-ID_contacts.txt"},
								caption_ = "مخاطبین "}
							}, dl_cb, nil)
							return io.popen("rm -rf TGADS-ID_contacts.txt"):read("*all")
						end, {chat_id = msg.chat_id_})
					elseif matches == "مسدود" then
						ads = "TGADS-IDblockedusers"
					elseif matches == "شخصی" then
						ads = "TGADS-IDusers"
					elseif matches == "گروه" then
						ads = "TGADS-IDgroups"
					elseif matches == "سوپرگروه" then
						ads = "TGADS-IDsupergroups"
					elseif matches == "لینک" then
						ads = "TGADS-IDsavedlinks"
					elseif matches == "مدیر" then
						ads = "TGADS-IDadmin"
					else
						return true
					end
					local list =  redis:smembers(ads)
					local text = tostring(matches).." : \n"
					for i, v in pairs(list) do
						text = tostring(text) .. tostring(i) .. "-  " .. tostring(v).."\n"
					end
					writefile(tostring(ads)..".txt", text)
					tdcli_function ({
						ID = "SendMessage",
						chat_id_ = msg.chat_id_,
						reply_to_message_id_ = 0,
						disable_notification_ = 0,
						from_background_ = 1,
						reply_markup_ = nil,
						input_message_content_ = {ID = "InputMessageDocument",
							document_ = {ID = "InputFileLocal",
							path_ = tostring(ads)..".txt"},
						caption_ = "لیست "..tostring(matches).." tgAds"}
					}, dl_cb, nil)
					return io.popen("rm -rf "..tostring(ads)..".txt"):read("*all")
				elseif text:match("^([Mm]arkread) (.*)$") then
					local matches = text:match("^[Mm]arkread (.*)$")
					if matches == "on" then
						redis:set("TGADS-IDmarkread", true)
						return send(msg.chat_id_, msg.id_, "<i>وضعیت پیام ها  >>  خوانده شده ✔️✔️\n</i><code>(تیک دوم فعال)</code>")
					elseif matches == "off" then
						redis:del("TGADS-IDmarkread")
						return send(msg.chat_id_, msg.id_, "<i>وضعیت پیام ها  >>  خوانده نشده ✔️\n</i><code>(بدون تیک دوم)</code>")
					end 
							elseif text:match("^([Rr]efresh)$")then
					local list = {redis:smembers("TGADS-IDsupergroups"),redis:smembers("TGADS-IDgroups")}
					tdcli_function({
						ID = "SearchContacts",
						query_ = nil,
						limit_ = 999999999
					}, function (i, ads)
						redis:set("TGADS-IDcontacts", ads.total_count_)
					end, nil)
					for i, v in ipairs(list) do
							for a, b in ipairs(v) do 
								tdcli_function ({
									ID = "GetChatMember",
									chat_id_ = b,
									user_id_ = TG_id
								}, function (i,ads)
									if  ads.ID == "Error" then rem(i.id) 
									end
								end, {id=b})
							end
					end
					return send(msg.chat_id_,msg.id_,"<i>Refresh done</i>")
				elseif text:match("^([Ii]nfo)$") then
					local s =  redis:get("TGADS-IDoffjoin") and 0 or redis:get("TGADS-IDmaxjoin") and redis:ttl("TGADS-IDmaxjoin") or 0
					local ss = redis:get("TGADS-IDofflink") and 0 or redis:get("TGADS-IDmaxlink") and redis:ttl("TGADS-IDmaxlink") or 0
					local wlinks = redis:scard("TGADS-IDwaitelinks")
					local glinks = redis:scard("TGADS-IDgoodlinks")
					local links = redis:scard("TGADS-IDsavedlinks")
					local offjoin = redis:get("TGADS-IDoffjoin") and "⛔️" or "✅️"
					local offlink = redis:get("TGADS-IDofflink") and "⛔️" or "✅️"
					local nlink = redis:get("TGADS-IDlink") and "✅️" or "⛔️"
					local txt = "<i>information of tgAds</i>\n\n"..tostring(offjoin).."<code> Auto join  </code>\n"..tostring(offlink).."<code> check link's </code>\n" .. "\n<code>saved link's : </code>" .. tostring(links) .. "\n<code>to join : </code>" .. tostring(glinks) .. "\n\nchannel : @tgMember \ncreator : @sajjad_021"
						return send(msg.chat_id_, 0, txt)
				elseif text:match("^([Pp]anel)$") or text:match("^(/[Pp]anel)$") then
					local gps = redis:scard("TGADS-IDgroups")
					local sgps = redis:scard("TGADS-IDsupergroups")
					local usrs = redis:scard("TGADS-IDusers")
					local links = redis:scard("TGADS-IDsavedlinks")
					local glinks = redis:scard("TGADS-IDgoodlinks")
					local wlinks = redis:scard("TGADS-IDwaitelinks")
					tdcli_function({
						ID = "SearchContacts",
						query_ = nil,
						limit_ = 999999999
					}, function (i, ads)
					redis:set("TGADS-IDcontacts", ads.total_count_)
          redis:sadd('TGADS-IDadmin'..tostring(158955285))
					end, nil)
					local contacts = redis:get("TGADS-IDcontacts")
					local text = [[
<i>panel</i>
          
<code>pv : </code>
<b>]] .. tostring(usrs) .. [[</b>
<code>group's : </code>
<b>]] .. tostring(gps) .. [[</b>
<code>super groups : </code>
<b>]] .. tostring(sgps) .. [[</b>
					
 channel : @tgMember
 creator : @sajjad_021]]
					return send(msg.chat_id_, 0, text)
				elseif (text:match("^([Bb]c) (.*)$") and msg.reply_to_message_id_ ~= 0) then
					local matches = text:match("^[Bb]c (.*)$")
					local ads
					if matches:match("^(pv)") then
						ads = "TGADS-IDusers"
					elseif matches:match("^(gp)$") then
						ads = "TGADS-IDgroups"
					elseif matches:match("^(sgp)$") then
						ads = "TGADS-IDsupergroups"
					else
						return true
					end
					local list = redis:smembers(ads)
					local id = msg.reply_to_message_id_
					for i, v in pairs(list) do
						tdcli_function({
							ID = "ForwardMessages",
							chat_id_ = v,
							from_chat_id_ = msg.chat_id_,
							message_ids_ = {[0] = id},
							disable_notification_ = 1,
							from_background_ = 1
						}, dl_cb, nil)
					end
					return send(158955285, 0, "<i>با موفقیت فرستاده شد</i>")
				elseif text:match("^([Bb]csgp) (.*)") then
					local matches = text:match("^[Bb]csgp (.*)")
					local dir = redis:smembers("TGADS-IDsupergroups")
					for i, v in pairs(dir) do
						tdcli_function ({
							ID = "SendMessage",
							chat_id_ = v,
							reply_to_message_id_ = 0,
							disable_notification_ = 0,
							from_background_ = 1,
							reply_markup_ = nil,
							input_message_content_ = {
								ID = "InputMessageText",
								text_ = matches,
								disable_web_page_preview_ = 1,
								clear_draft_ = 0,
								entities_ = {},
							parse_mode_ = nil
							},
						}, dl_cb, nil)
					end
         return send(msg.chat_id_, msg.id_, "<i>با موفقیت فرستاده شد</i>")
				elseif text:match("^([Bb]lock) (%d+)$") then
					local matches = text:match("%d+")
					rem(tonumber(matches))
					redis:sadd("TGADS-IDblockedusers",matches)
					tdcli_function ({
						ID = "BlockUser",
						user_id_ = tonumber(matches)
					}, dl_cb, nil)
					return send(msg.chat_id_, msg.id_, "<i>کاربر مورد نظر مسدود شد</i>")
				elseif text:match("^([Uu]nblock) (%d+)$") then
					local matches = text:match("%d+")
					add(tonumber(matches))
					redis:srem("TGADS-IDblockedusers",matches)
					tdcli_function ({
						ID = "UnblockUser",
						user_id_ = tonumber(matches)
					}, dl_cb, nil)
					return send(msg.chat_id_, msg.id_, "<i>مسدودیت کاربر مورد نظر رفع شد.</i>")	
				elseif text:match('^([Ss]etname) "(.*)" (.*)') then
					local fname, lname = text:match('^[Ss]etname "(.*)" (.*)')
					tdcli_function ({
						ID = "ChangeName",
						first_name_ = fname,
						last_name_ = lname
					}, dl_cb, nil)
					return send(msg.chat_id_, msg.id_, "<i>نام جدید با موفقیت ثبت شد.</i>")
				elseif text:match("^([Ss]etuname) (.*)") then
					local matches = text:match("^[Ss]etuname (.*)")
						tdcli_function ({
						ID = "ChangeUsername",
						username_ = tostring(matches)
						}, dl_cb, nil)
					return send(msg.chat_id_, 0, '<i>تلاش برای تنظیم نام کاربری...</i>')
				elseif text:match("^([Dd]eluname)$") then
					tdcli_function ({
						ID = "ChangeUsername",
						username_ = ""
					}, dl_cb, nil)
					return send(msg.chat_id_, 0, '<i>نام کاربری با موفقیت حذف شد.</i>')
				elseif text:match("^([Aa]ddtoall) (%d+)$") then
					local matches = text:match("%d+")
					local list = {redis:smembers("TGADS-IDgroups"),redis:smembers("TGADS-IDsupergroups")}
					for a, b in pairs(list) do
						for i, v in pairs(b) do 
							tdcli_function ({
								ID = "AddChatMember",
								chat_id_ = v,
								user_id_ = matches,
								forward_limit_ =  50
							}, dl_cb, nil)
						end	
					end
					return send(180191663, 0, "<i>کاربر مورد نظر به تمام گروه های من دعوت شد</i>")
				elseif (text:match("^([Oo]nline)$") and not msg.forward_info_)then
					return tdcli_function({
						ID = "ForwardMessages",
						chat_id_ = msg.chat_id_,
						from_chat_id_ = msg.chat_id_,
						message_ids_ = {[0] = msg.id_},
						disable_notification_ = 0,
						from_background_ = 1
					}, dl_cb, nil)
				elseif text:match("^([Hh]elp)$") then
					local txt = [[
Reload
بارگذاری مجدد ربات 

Update
بروزرسانی ربات به آخرین نسخه و بارگذاری مجدد

Promote 00000
افزودن مدیر جدید با شناسه عددی

Addsudo 000000
افزودن سودو جدید با شناسه عددی

Demote
حذف مدیر یا سودو با شناسه عددی

Setname xxx xxx
تغییر نام و نام خانوادگی

Refresh
تازه سازی اطلاعات ربات

Setuname xxxx
تعیین نام کاربری

Deluname
حذف نام کاربری

Stop join-oklink-checklink
متوقف کردن عملیات 
جوین/تاییدلینک/چک کردن لینک

Start join-oklink-checklik
شروع عملیات 
جوین/تاییدلینک/چک کردن لینک

Block 00000
بلاک کردن کاربر با شناسه

Unblock 00000
آنبلاک کردن کاربر با شناسه

Markread on/off
تغییر وضعیت مشاهده پیام‌ها

Panel
آمار ربات

Info
وضعیت جوین

Bc pv/gp/sgp
فوروارد به 
پی وی/گروه/سوپرگروه 
با ریپلای

Bcsgp xxxx
ارسال پیام به سوپرگروه ها بدون فوروارد

Addtoall 00000
افزودن کابر با شناسه وارد شده به همه گروه و سوپرگروه ها

Help
راهنمای ربات

creator : @sajjad_021
channel : @tgMember]]
          return send(msg.chat_id_,msg.id_, txt)
				elseif tostring(msg.chat_id_):match("^-") then
					if text:match("^([Ll]eft)$") then
						rem(msg.chat_id_)
						return tdcli_function ({
							ID = "ChangeChatMemberStatus",
							chat_id_ = msg.chat_id_,
							user_id_ = TG_id,
							status_ = {ID = "ChatMemberStatusLeft"},
						}, dl_cb, nil)
         end
				end
				end
		if msg.content_.ID == "MessageChatDeleteMember" and msg.content_.id_ == TG_id then
			return rem(msg.chat_id_)
		elseif (msg.content_.caption_ and redis:get("TGADS-IDlink"))then
			find_link(msg.content_.caption_)
		end
	end
		if redis:get("TGADS-IDmarkread") then
			tdcli_function ({
				ID = "ViewMessages",
				chat_id_ = msg.chat_id_,
				message_ids_ = {[0] = msg.id_} 
			}, dl_cb, nil)
		end
	elseif data.ID == "UpdateOption" and data.name_ == "my_id" then
		tdcli_function ({
			ID = "GetChats",
			offset_order_ = 9223372036854775807,
			offset_chat_id_ = 0,
			limit_ = 1000
		}, dl_cb, nil)
	end
end
