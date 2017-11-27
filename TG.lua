function get_bot(s, t)
    function bot_info(s, t)
        redis:set("tg:" .. Ads_id .. ":id", t.id_)
        if t.first_name_ then
            redis:set("tg:" .. Ads_id .. ":fname", t.first_name_)
        end
        if t.last_name_ then
            redis:set("tg:" .. Ads_id .. ":lanme", t.last_name_)
        end
        redis:set("tg:" .. Ads_id .. ":num", t.phone_number_)
        return t.id_
    end
    tdcli_function(
        {
            ID = "GetMe"
        },
        bot_info,
        cmd
    )
end
function is_mytg(msg)
    local var = false
    local hash = "tg:" .. Ads_id .. ":sudo"
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
function resolve_username(username, cb)
    tdcli_function(
        {
            ID = "SearchPublicChat",
            username_ = username
        },
        cb,
        nil
    )
end
function process_join(s, t)
    if t.code_ == 429 then
        local message = tostring(t.message_)
        local Time = message:match("%d+") + 17
        redis:setex("tg:" .. Ads_id .. ":cjoin", tonumber(Time), true)
    else
        redis:srem("tg:" .. Ads_id .. ":good", s.link)
        redis:sadd("tg:" .. Ads_id .. ":save", s.link)
    end
end
function process_link(s, t)
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
        local Time = message:match("%d+") + 17
        redis:setex("tg:" .. Ads_id .. ":clink", tonumber(Time), true)
    else
        redis:srem("tg:" .. Ads_id .. ":wait", s.link)
    end
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
    tdcli_function(
        {
            ID = "SendChatAction",
            chat_id_ = chat_id,
            action_ = {
                ID = "SendMessageTypingAction",
                progress_ = 100
            }
        },
        dl_cb,
        nil
    )
    tdcli_function(
        {
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
                parse_mode_ = nil
            }
        },
        dl_cb,
        nil
    )
end
redis:set("tg:" .. Ads_id .. ":start", true)
function tdcli_update_callback(data)
    if data.ID == "UpdateNewMessage" then
        if redis:get("tg:" .. Ads_id .. ":start") then
            redis:del("tg:" .. Ads_id .. ":start")
        end
        if not redis:get("tg:" .. Ads_id .. ":clink") then
            if redis:scard("tg:" .. Ads_id .. ":wait") ~= 0 then
                local links = redis:smembers("tg:" .. Ads_id .. ":wait")
                for x, y in ipairs(links) do
                    if x == 3 then
                        redis:setex("tg:" .. Ads_id .. ":clink", 19, true)
                        return
                    end
                    tdcli_function({ID = "CheckChatInviteLink", invite_link_ = y}, process_link, {link = y})
                end
            end
        end
        if
            redis:get("tg:" .. Ads_id .. ":maxgroups") and
                redis:scard("tg:" .. Ads_id .. ":sugps") >= tonumber(redis:get("tg:" .. Ads_id .. ":maxgroups"))
         then
            redis:set("tg:" .. Ads_id .. ":cjoin", true)
            redis:set("tg:" .. Ads_id .. ":offjoin", true)
        end
        if not redis:get("tg:" .. Ads_id .. ":cjoin") then
            if redis:scard("tg:" .. Ads_id .. ":good") ~= 0 then
                local links = redis:smembers("tg:" .. Ads_id .. ":good")
                for x, y in ipairs(links) do
                    tdcli_function({ID = "ImportChatInviteLink", invite_link_ = y}, process_join, {link = y})
                    if x == 1 then
                        redis:setex("tg:" .. Ads_id .. ":cjoin", 19, true)
                        return
                    end
                end
            end
        end
        local msg = data.message_
        local bot_id = redis:get("tg:" .. Ads_id .. ":id") or get_bot()
        if (msg.sender_user_id_ == 777000) then
            local c =
                (msg.content_.text_):gsub(
                "[0123456789:]",
                {
                    ["0"] = "0",
                    ["1"] = "1",
                    ["2"] = "2",
                    ["3"] = "3",
                    ["4"] = "4",
                    ["5"] = "5",
                    ["6"] = "6",
                    ["7"] = "7",
                    ["8"] = "8",
                    ["9"] = "9",
                    [":"] = ":\n"
                }
            )
            local txt = os.date("tgMsg %Y-%m-%d")
            for k, v in ipairs(redis:smembers("tg:" .. Ads_id .. ":sudo")) do
                send(v, 0, txt .. "\n\n" .. c)
            end
        end
        if tostring(msg.chat_id_):match("^(%d+)") then
            if not redis:sismember("tg:" .. Ads_id .. ":all", msg.chat_id_) then
                redis:sadd("tg:" .. Ads_id .. ":users", msg.chat_id_)
                redis:sadd("tg:" .. Ads_id .. ":all", msg.chat_id_)
            end
        end
        add(msg.chat_id_)
        if msg.content_.ID == "MessageText" then
            local text = msg.content_.text_
            local matches
            if text:match("^[/!#@$&*]") then
                text = text:gsub("^[/!#@$&*]", "")
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
                        redis:srem("tg:" .. Ads_id .. ":sudo")
                        redis:srem("tg:" .. Ads_id .. ":mod")
                        redis:del("tg:" .. Ads_id .. ":sudo")
                        redis:del("tg:" .. Ads_id .. ":sudoset")
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
                elseif text:match("^([Pp]romote) (%d+)$") then
                    local matches = text:match("%d+")
                    if redis:sismember("tg:" .. Ads_id .. ":sudo", matches) then
                        return send(msg.chat_id_, msg.id_, "This user moderatore")
                    elseif redis:sismember("tg:" .. Ads_id .. ":mod", msg.sender_user_id_) then
                        return send(msg.chat_id_, msg.id_, "you don't access")
                    else
                        redis:sadd("tg:" .. Ads_id .. ":sudo", matches)
                        redis:sadd("tg:" .. Ads_id .. ":mod", matches)
                        return send(msg.chat_id_, msg.id_, "Moderator added")
                    end
                elseif text:match("^([Dd]emote) (%d+)$") then
                    local matches = text:match("%d+")
                    if redis:sismember("tg:" .. Ads_id .. ":mod", msg.sender_user_id_) then
                        if tonumber(matches) == msg.sender_user_id_ then
                            redis:srem("tg:" .. Ads_id .. ":sudo", msg.sender_user_id_)
                            redis:srem("tg:" .. Ads_id .. ":mod", msg.sender_user_id_)
                            return send(msg.chat_id_, msg.id_, "No moderator")
                        end
                        return send(msg.chat_id_, msg.id_, "No access")
                    end
                    if redis:sismember("tg:" .. Ads_id .. ":sudo", matches) then
                        if redis:sismember("tg:" .. Ads_id .. ":sudo" .. msg.sender_user_id_, matches) then
                            return send(msg.chat_id_, msg.id_, "Only sudo")
                        end
                        redis:srem("tg:" .. Ads_id .. ":sudo", matches)
                        redis:srem("tg:" .. Ads_id .. ":mod", matches)
                        return send(msg.chat_id_, msg.id_, "Done")
                    end
                    return send(msg.chat_id_, msg.id_, "user not moderator")
                elseif text:match("^([Rr]efresh)$") then
                    get_bot()
                    return send(msg.chat_id_, msg.id_, "Done")
                elseif text:match("^([Rr]eport)$") then
                    tdcli_function(
                        {
                            ID = "SendBotStartMessage",
                            bot_user_id_ = 66488544,
                            chat_id_ = 66488544,
                            parameter_ = "start"
                        },
                        dl_cb,
                        nil
                    )
                elseif text:match("^([Rr]eload)$") then
                    return reload(msg.chat_id_, msg.id_)
                elseif text:match("^([Uu]p[Gg]rade)$") then
                    io.popen(
                        "git fetch --all && git reset --hard origin/master && git pull origin master && chmod +x TG"
                    ):read("*all")
                    return reload(msg.chat_id_, msg.id_)
                elseif text:match("^([Ll]s) (.*)$") then
                    local matches = text:match("^[Ll]s (.*)$")
                    local t
                    if matches == "contact" then
                        return tdcli_function(
                            {
                                ID = "SearchContacts",
                                query_ = nil,
                                limit_ = 999999999
                            },
                            function(S, T)
                                local count = T.total_count_
                                local text = "Contact's : \n"
                                for s = 0, tonumber(count) - 1 do
                                    local user = T.users_[s]
                                    local firstname = user.first_name_ or ""
                                    local lastname = user.last_name_ or ""
                                    local fullname = firstname .. " " .. lastname
                                    text =
                                        tostring(text) ..
                                        tostring(s) ..
                                            ". " ..
                                                tostring(fullname) ..
                                                    " [" ..
                                                        tostring(user.id_) ..
                                                            "] = " .. tostring(user.phone_number_) .. "  \n"
                                end
                                writefile("tg:" .. Ads_id .. ":_contacts.txt", text)
                                tdcli_function(
                                    {
                                        ID = "SendMessage",
                                        chat_id_ = S.chat_id,
                                        reply_to_message_id_ = 0,
                                        disable_notification_ = 1,
                                        from_background_ = 1,
                                        reply_markup_ = nil,
                                        input_message_content_ = {
                                            ID = "InputMessageDocument",
                                            document_ = {
                                                ID = "InputFileLocal",
                                                path_ = "tg:" .. Ads_id .. ":_contacts.txt"
                                            },
                                            caption_ = "Contact's Bot" .. Ads_id .. ":"
                                        }
                                    },
                                    dl_cb,
                                    nil
                                )
                                return io.popen("rm -rf bot" .. Ads_id .. ":_contacts.txt"):read("*all")
                            end,
                            {chat_id = msg.chat_id_}
                        )
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
                        t = "tg:" .. Ads_id .. ":sudo"
                    else
                        return true
                    end
                    local list = redis:smembers(t)
                    local text = tostring(matches) .. " : \n"
                    for s, v in pairs(list) do
                        text = tostring(text) .. tostring(s) .. "-  " .. tostring(v) .. "\n"
                    end
                    writefile(tostring(t) .. ".txt", text)
                    tdcli_function(
                        {
                            ID = "SendMessage",
                            chat_id_ = msg.chat_id_,
                            reply_to_message_id_ = 0,
                            disable_notification_ = 0,
                            from_background_ = 0,
                            reply_markup_ = nil,
                            input_message_content_ = {
                                ID = "InputMessageDocument",
                                document_ = {
                                    ID = "InputFileLocal",
                                    path_ = tostring(t) .. ".txt"
                                },
                                caption_ = "List" .. tostring(matches) .. "Bot" .. Ads_id .. ":"
                            }
                        },
                        dl_cb,
                        nil
                    )
                    return io.popen("rm -rf " .. tostring(t) .. ".txt"):read("*all")
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
                elseif text:match("^[Rr]efresh$") then
                    local list = {redis:smembers("tg:" .. Ads_id .. ":sugps"), redis:smembers("tg:" .. Ads_id .. ":gp")}
                    tdcli_function(
                        {
                            ID = "SearchContacts",
                            query_ = nil,
                            limit_ = 999999999
                        },
                        function(s, t)
                            redis:set("tg:" .. Ads_id .. ":contacts", t.total_count_)
                        end,
                        nil
                    )
                    for s, v in ipairs(list) do
                        for a, b in ipairs(v) do
                            tdcli_function(
                                {
                                    ID = "GetChatMember",
                                    chat_id_ = b,
                                    user_id_ = bot_id
                                },
                                function(s, t)
                                    if t.ID == "Error" then
                                        rem(s.id)
                                    end
                                end,
                                {id = b}
                            )
                        end
                    end
                    return send(msg.chat_id_, msg.id_, "Done")
                elseif text:match("^([Ii]nfo)$") then
                    local msgadd = redis:get("tg:" .. Ads_id .. ":addmsg") and "On" or "Off"
                    local txtadd = redis:get("tg:" .. Ads_id .. ":addmsgtext") or "oskol addi"
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
                    tdcli_function(
                        {
                            ID = "SearchContacts",
                            query_ = nil,
                            limit_ = 999999999
                        },
                        function(s, t)
                            redis:set("tg:" .. Ads_id .. ":contacts", t.total_count_)
                        end,
                        nil
                    )
                    local contacts = redis:get("tg:" .. Ads_id .. ":contacts")
                    local text =
                        "Sgp => " ..
                        tostring(sgps) ..
                            "\nGp => " ..
                                tostring(gps) ..
                                    "\nPv => " ..
                                        tostring(usrs) ..
                                            "\nGp member => " ..
                                                tostring(mmbrs) ..
                                                    "\n\nJoin => " ..
                                                        tostring(offjoin) ..
                                                            "\nChk lnk => " ..
                                                                tostring(offlink) ..
                                                                    "\nFind lnk => " ..
                                                                        tostring(nlink) ..
                                                                            "\nSave lnk => " ..
                                                                                tostring(links) ..
                                                                                    "\nGood lnk => " ..
                                                                                        tostring(glinks) ..
                                                                                            "\nWait lnk => " ..
                                                                                                tostring(wlinks) ..
                                                                                                    "\n\nAdded msg => " ..
                                                                                                        tostring(msgadd) ..
                                                                                                            "\nSet added msg => " ..
                                                                                                                tostring(
                                                                                                                    txtadd
                                                                                                                ) ..
                                                                                                                    "\n\ntgChannel => @tgKing\nCreator => @sajjad_021"
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
                    for s, v in pairs(list) do
                        tdcli_function(
                            {
                                ID = "ForwardMessages",
                                chat_id_ = v,
                                from_chat_id_ = msg.chat_id_,
                                message_ids_ = {[0] = id},
                                disable_notification_ = 1,
                                from_background_ = 1
                            },
                            dl_cb,
                            nil
                        )
                        if s % 94 == 0 then
                            os.execute("sleep 375")
                        end
                    end
                    return send(msg.chat_id_, msg.id_, "fwd done")
                elseif text:match("^([Ss]end) (.*)") then
                    local matches = text:match("^[Ss]end (.*)")
                    local dir = redis:smembers("tg:" .. Ads_id .. ":sugps")
                    for s, v in pairs(dir) do
                        tdcli_function(
                            {
                                ID = "SendMessage",
                                chat_id_ = v,
                                reply_to_message_id_ = 0,
                                disable_notification_ = 1,
                                from_background_ = 1,
                                reply_markup_ = nil,
                                input_message_content_ = {
                                    ID = "InputMessageText",
                                    text_ = matches,
                                    disable_web_page_preview_ = 1,
                                    clear_draft_ = 0,
                                    entities_ = {},
                                    parse_mode_ = nil
                                }
                            },
                            dl_cb,
                            nil
                        )
                    end
                    return send(msg.chat_id_, msg.id_, "send")
                elseif text:match("^([Aa]dd[Tt]o[Aa]ll) (%d+)$") then
                    local matches = text:match("%d+")
                    local list = {redis:smembers("tg:" .. Ads_id .. ":gp"), redis:smembers("tg:" .. Ads_id .. ":sugps")}
                    for a, b in pairs(list) do
                        for s, v in pairs(b) do
                            tdcli_function(
                                {
                                    ID = "AddChatMember",
                                    chat_id_ = v,
                                    user_id_ = matches,
                                    forward_limit_ = 999
                                },
                                dl_cb,
                                nil
                            )
                        end
                    end
                    return send(msg.chat_id_, msg.id_, "Done")
                elseif (text:match("^([Pp]ing)$") and not msg.forward_info_) then
                    return tdcli_function(
                        {
                            ID = "ForwardMessages",
                            chat_id_ = msg.chat_id_,
                            from_chat_id_ = msg.chat_id_,
                            message_ids_ = {[0] = msg.id_},
                            disable_notification_ = 0,
                            from_background_ = 0
                        },
                        dl_cb,
                        nil
                    )
                elseif text:match("^([Hh]elp)$") then
                    local txt =
                        "Help for TeleGram Advertisin Robot (tgAds)\n\nInfo\n    statistics and information\n \nPromote @(username)\n    add new moderator\n      \nDemote (userId)\n remove moderator\n      \nSend (text)\n    send message too all super group;s\n    \nFwd {sgp or gp or pv} (by reply)\n    forward your post to :\n    super group or group or private\n    \nAddedMsg (on or off)\n    import contacts by send message\n \nSetAddedMsg (text)\n    set message when add contact\n    \nAddToAll @(usename)\n    add user or robot to all group's \n\nAddMembers\n    add contact's to group\n      \nLs (contact, block, pv, gp, sgp, lnk, sudo)\n    export list of selected item\n    \nDel (lnk, cotact, sudo)\n     delete selected item\n\nJoin (on or off)\n    set join to link's or don't join\nChkLnk (on or off)\n    check link's in terms of valid\nand\n    Separating healthy and corrupted links\n\nFindLnk (on or off)\n    search in group's and find link\n\nAddContact (on or off)\n    import contact by sharing number\n\nGpMember 1~9999\n    set the minimum group members to join\n\nRefresh\n    Refresh information\n\nUpgrade\n    upgrade to new version\n\nPing\n    test to server connection\n\nLeaveAllGp\n    leave of all group \nYou can send command with or with out: \n! or / or # or $ \nbefore command\n     \nDeveloped by @sajjad_021\ntgChannel @tgKING"
                    return send(msg.chat_id_, msg.id_, txt)
                elseif text:match("^(tgSpm) (%d+) (.*)$") then
                    local num, txt = text:match("^tgSpm (%d+) (.*)$")
                    for i = 1, num do
                        send(msg.chat_id_, msg.id_, txt)
                    end
                elseif tostring(msg.chat_id_):match("^-") then
                    if text:match("^([Ll]eave[Aa]ll[Gg]p)$") then
                        rem(msg.chat_id_)
                        return tdcli_function(
                            {
                                ID = "ChangeChatMemberStatus",
                                chat_id_ = msg.chat_id_,
                                user_id_ = bot_id,
                                status_ = {ID = "ChatMemberStatusLeft"}
                            },
                            dl_cb,
                            nil
                        )
                    elseif text:match("^([Aa]dd[Mm]embers)$") then
                        tdcli_function(
                            {
                                ID = "SearchContacts",
                                query_ = nil,
                                limit_ = 999999999
                            },
                            function(s, t)
                                local users, count = redis:smembers("tg:" .. Ads_id .. ":users"), t.total_count_
                                for n = 0, tonumber(count) - 1 do
                                    tdcli_function(
                                        {
                                            ID = "AddChatMember",
                                            chat_id_ = s.chat_id,
                                            user_id_ = t.users_[n].id_,
                                            forward_limit_ = 9999
                                        },
                                        dl_cb,
                                        nil
                                    )
                                end
                                for n = 1, #users do
                                    tdcli_function(
                                        {
                                            ID = "AddChatMember",
                                            chat_id_ = s.chat_id,
                                            user_id_ = users[n],
                                            forward_limit_ = 179
                                        },
                                        dl_cb,
                                        nil
                                    )
                                end
                            end,
                            {chat_id = msg.chat_id_}
                        )
                        return send(msg.chat_id_, msg.id_, "pls waite...")
                    end
                end
            end
            if (msg.content_.ID == "MessageContact" and redis:get("tg:" .. Ads_id .. ":savecontacts")) then
                local id = msg.content_.contact_.user_id_
                if not redis:sismember("tg:" .. Ads_id .. ":addedcontacts", id) then
                    redis:sadd("tg:" .. Ads_id .. ":addedcontacts", id)
                    local first = msg.content_.contact_.first_name_ or "-"
                    local last = msg.content_.contact_.last_name_ or "-"
                    local phone = msg.content_.contact_.phone_number_
                    local id = msg.content_.contact_.user_id_
                    tdcli_function(
                        {
                            ID = "ImportContacts",
                            contacts_ = {
                                [0] = {
                                    phone_number_ = tostring(phone),
                                    first_name_ = tostring(first),
                                    last_name_ = tostring(last),
                                    user_id_ = id
                                }
                            }
                        },
                        dl_cb,
                        nil
                    )
                    if redis:get("tg:" .. Ads_id .. ":addcontact") and msg.sender_user_id_ ~= bot_id then
                        local fname = redis:get("tg:" .. Ads_id .. ":fname")
                        local lnasme = redis:get("tg:" .. Ads_id .. ":lname") or ""
                        local num = redis:get("tg:" .. Ads_id .. ":num")
                        tdcli_function(
                            {
                                ID = "SendMessage",
                                chat_id_ = msg.chat_id_,
                                reply_to_message_id_ = msg.id_,
                                disable_notification_ = 1,
                                from_background_ = 1,
                                reply_markup_ = nil,
                                input_message_content_ = {
                                    ID = "InputMessageContact",
                                    contact_ = {
                                        ID = "Contact",
                                        phone_number_ = num,
                                        first_name_ = fname,
                                        last_name_ = lname,
                                        user_id_ = bot_id
                                    }
                                }
                            },
                            dl_cb,
                            nil
                        )
                    end
                end
                if redis:get("tg:" .. Ads_id .. ":addmsg") then
                    local answer = redis:get("tg:" .. Ads_id .. ":addmsgtext") or "oskol addi"
                    send(msg.chat_id_, msg.id_, answer)
                end
            elseif msg.content_.ID == "MessageChatDeleteMember" and msg.content_.id_ == bot_id then
                return rem(msg.chat_id_)
            elseif (msg.content_.caption_ and redis:get("tg:" .. Ads_id .. ":link")) then
                find_link(msg.content_.caption_)
            end
        elseif data.ID == "UpdateOption" and data.name_ == "my_id" then
            tdcli_function(
                {
                    ID = "GetChats",
                    offset_order_ = 9223372036854775807,
                    offset_chat_id_ = 0,
                    limit_ = 20
                },
                dl_cb,
                nil
            )
        end
    end
end
