serpent = require("serpent")
lgi = require ('lgi')
redis = require('redis')
database = Redis.connect('127.0.0.1', 6379)
notify = lgi.require('Notify')
notify.init ("Telegram updates")
chats = {}
day = 86400
bot_id = 323370170 -- Your Bot USER_ID
sudo_users = {255317894--[[YOUE ID :|]]}
  -----------------------------------------------------------------------------------------------
                                     -- start functions --
  -----------------------------------------------------------------------------------------------
function is_sudo(msg)
  local var = false
  for k,v in pairs(sudo_users) do
    if msg.sender_user_id_ == v then
      var = true
    end
  end
  return var
end
-----------------------------------------------------------------------------------------------
function setrank(msg, name, value) -- setrank function
  local hash = nil
if chat_type(msg.chat_id_) ~= "supergroup" then
    hash = 'rank:'..msg.chat_id_..':variables'
  end
  if hash then
    database:hset(hash, name, value)
 send(msg.chat_id_, msg.id_, 1, '*User Rank* `"..name.."` *Changed To* `"..value.."`', 1, 'md')
  end
end
-----------------------------------------------------------------------------------------------
function is_admin(user_id)
    local var = false
	local hashs =  'bot:admins:'
    local admin = database:sismember(hashs, user_id)
	 if admin then
	    var = true
	 end
  for k,v in pairs(sudo_users) do
    if user_id == v then
      var = true
    end
  end
    return var
end
-----------------------------------------------------------------------------------------------
function is_vip_group(gp_id)
    local var = false
	local hashs =  'bot:vipgp:'
    local vip = database:sismember(hashs, gp_id)
	 if vip then
	    var = true
	 end
    return var
end
-----------------------------------------------------------------------------------------------
function is_owner(user_id, chat_id)
    local var = false
    local hash =  'bot:owners:'..chat_id
    local owner = database:sismember(hash, user_id)
	local hashs =  'bot:admins:'
    local admin = database:sismember(hashs, user_id)
	 if owner then
	    var = true
	 end
	 if admin then
	    var = true
	 end
    for k,v in pairs(sudo_users) do
    if user_id == v then
      var = true
    end
	end
    return var
end
-----------------------------------------------------------------------------------------------
function is_mod(user_id, chat_id)
    local var = false
    local hash =  'bot:mods:'..chat_id
    local mod = database:sismember(hash, user_id)
	local hashs =  'bot:admins:'
    local admin = database:sismember(hashs, user_id)
	local hashss =  'bot:owners:'..chat_id
    local owner = database:sismember(hashss, user_id)
	 if mod then
	    var = true
	 end
	 if owner then
	    var = true
	 end
	 if admin then
	    var = true
	 end
    for k,v in pairs(sudo_users) do
    if user_id == v then
      var = true
    end
	end
    return var
end
-----------------------------------------------------------------------------------------------
function is_banned(user_id, chat_id)
    local var = false
	local hash = 'bot:banned:'..chat_id
    local banned = database:sismember(hash, user_id)
	 if banned then
	    var = true
	 end
    return var
end
-----------------------------------------------------------------------------------------------
function is_muted(user_id, chat_id)
    local var = false
	local hash = 'bot:muted:'..chat_id
    local banned = database:sismember(hash, user_id)
	 if banned then
	    var = true
	 end
    return var
end
-----------------------------------------------------------------------------------------------
function is_gbanned(user_id)
    local var = false
	local hash = 'bot:gbanned:'
    local banned = database:sismember(hash, user_id)
	 if banned then
	    var = true
	 end
    return var
end
-----------------------------------------------------------------------------------------------
local function check_filter_words(msg, value)
  local hash = 'bot:filters:'..msg.chat_id_
  if hash then
    local names = database:hkeys(hash)
    local text = ''
    for i=1, #names do
	   if string.match(value:lower(), names[i]:lower()) and not is_mod(msg.sender_user_id_, msg.chat_id_)then
	     local id = msg.id_
         local msgs = {[0] = id}
         local chat = msg.chat_id_
        delete_msg(chat,msgs)
       end
    end
  end
end
-----------------------------------------------------------------------------------------------
function resolve_username(username,cb)
  tdcli_function ({
    ID = "SearchPublicChat",
    username_ = username
  }, cb, nil)
end
  -----------------------------------------------------------------------------------------------
function changeChatMemberStatus(chat_id, user_id, status)
  tdcli_function ({
    ID = "ChangeChatMemberStatus",
    chat_id_ = chat_id,
    user_id_ = user_id,
    status_ = {
      ID = "ChatMemberStatus" .. status
    },
  }, dl_cb, nil)
end
  -----------------------------------------------------------------------------------------------
function getInputFile(file)
  if file:match('/') then
    infile = {ID = "InputFileLocal", path_ = file}
  elseif file:match('^%d+$') then
    infile = {ID = "InputFileId", id_ = file}
  else
    infile = {ID = "InputFilePersistentId", persistent_id_ = file}
  end

  return infile
end
  -----------------------------------------------------------------------------------------------
function del_all_msgs(chat_id, user_id)
  tdcli_function ({
    ID = "DeleteMessagesFromUser",
    chat_id_ = chat_id,
    user_id_ = user_id
  }, dl_cb, nil)
end
  -----------------------------------------------------------------------------------------------
function getChatId(id)
  local chat = {}
  local id = tostring(id)

  if id:match('^-100') then
    local channel_id = id:gsub('-100', '')
    chat = {ID = channel_id, type = 'channel'}
  else
    local group_id = id:gsub('-', '')
    chat = {ID = group_id, type = 'group'}
  end

  return chat
end
  -----------------------------------------------------------------------------------------------
function chat_leave(chat_id, user_id)
  changeChatMemberStatus(chat_id, user_id, "Left")
end
  -----------------------------------------------------------------------------------------------
function from_username(msg)
   function gfrom_user(extra,result,success)
   if result.username_ then
   F = result.username_
   else
   F = 'nil'
   end
    return F
   end
  local username = getUser(msg.sender_user_id_,gfrom_user)
  return username
end
  -----------------------------------------------------------------------------------------------
function chat_kick(chat_id, user_id)
  changeChatMemberStatus(chat_id, user_id, "Kicked")
end
  -----------------------------------------------------------------------------------------------
function do_notify (user, msg)
  local n = notify.Notification.new(user, msg)
  n:show ()
end
  -----------------------------------------------------------------------------------------------
local function getParseMode(parse_mode)
  if parse_mode then
    local mode = parse_mode:lower()

    if mode == 'markdown' or mode == 'md' then
      P = {ID = "TextParseModeMarkdown"}
    elseif mode == 'html' then
      P = {ID = "TextParseModeHTML"}
    end
  end
  return P
end
  -----------------------------------------------------------------------------------------------
local function getMessage(chat_id, message_id,cb)
  tdcli_function ({
    ID = "GetMessage",
    chat_id_ = chat_id,
    message_id_ = message_id
  }, cb, nil)
end
-----------------------------------------------------------------------------------------------
function sendContact(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, phone_number, first_name, last_name, user_id)
  tdcli_function ({
    ID = "SendMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = reply_to_message_id,
    disable_notification_ = disable_notification,
    from_background_ = from_background,
    reply_markup_ = reply_markup,
    input_message_content_ = {
      ID = "InputMessageContact",
      contact_ = {
        ID = "Contact",
        phone_number_ = phone_number,
        first_name_ = first_name,
        last_name_ = last_name,
        user_id_ = user_id
      },
    },
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function sendPhoto(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, photo, caption)
  tdcli_function ({
    ID = "SendMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = reply_to_message_id,
    disable_notification_ = disable_notification,
    from_background_ = from_background,
    reply_markup_ = reply_markup,
    input_message_content_ = {
      ID = "InputMessagePhoto",
      photo_ = getInputFile(photo),
      added_sticker_file_ids_ = {},
      width_ = 0,
      height_ = 0,
      caption_ = caption
    },
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function getUserFull(user_id,cb)
  tdcli_function ({
    ID = "GetUserFull",
    user_id_ = user_id
  }, cb, nil)
end
-----------------------------------------------------------------------------------------------
function vardump(value)
  print(serpent.block(value, {comment=false}))
end
-----------------------------------------------------------------------------------------------
function dl_cb(arg, data)
end
-----------------------------------------------------------------------------------------------
local function send(chat_id, reply_to_message_id, disable_notification, text, disable_web_page_preview, parse_mode)
  local TextParseMode = getParseMode(parse_mode)

  tdcli_function ({
    ID = "SendMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = reply_to_message_id,
    disable_notification_ = disable_notification,
    from_background_ = 1,
    reply_markup_ = nil,
    input_message_content_ = {
      ID = "InputMessageText",
      text_ = text,
      disable_web_page_preview_ = disable_web_page_preview,
      clear_draft_ = 0,
      entities_ = {},
      parse_mode_ = TextParseMode,
    },
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function sendaction(chat_id, action, progress)
  tdcli_function ({
    ID = "SendChatAction",
    chat_id_ = chat_id,
    action_ = {
      ID = "SendMessage" .. action .. "Action",
      progress_ = progress or 100
    }
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function changetitle(chat_id, title)
  tdcli_function ({
    ID = "ChangeChatTitle",
    chat_id_ = chat_id,
    title_ = title
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function edit(chat_id, message_id, reply_markup, text, disable_web_page_preview, parse_mode)
  local TextParseMode = getParseMode(parse_mode)
  tdcli_function ({
    ID = "EditMessageText",
    chat_id_ = chat_id,
    message_id_ = message_id,
    reply_markup_ = reply_markup,
    input_message_content_ = {
      ID = "InputMessageText",
      text_ = text,
      disable_web_page_preview_ = disable_web_page_preview,
      clear_draft_ = 0,
      entities_ = {},
      parse_mode_ = TextParseMode,
    },
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function setphoto(chat_id, photo)
  tdcli_function ({
    ID = "ChangeChatPhoto",
    chat_id_ = chat_id,
    photo_ = getInputFile(photo)
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function add_user(chat_id, user_id, forward_limit)
  tdcli_function ({
    ID = "AddChatMember",
    chat_id_ = chat_id,
    user_id_ = user_id,
    forward_limit_ = forward_limit or 50
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function unpinmsg(channel_id)
  tdcli_function ({
    ID = "UnpinChannelMessage",
    channel_id_ = getChatId(channel_id).ID
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
local function blockUser(user_id)
  tdcli_function ({
    ID = "BlockUser",
    user_id_ = user_id
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
local function unblockUser(user_id)
  tdcli_function ({
    ID = "UnblockUser",
    user_id_ = user_id
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
local function getBlockedUsers(offset, limit)
  tdcli_function ({
    ID = "GetBlockedUsers",
    offset_ = offset,
    limit_ = limit
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function delete_msg(chatid,mid)
  tdcli_function ({
  ID="DeleteMessages",
  chat_id_=chatid,
  message_ids_=mid
  },
  dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function chat_del_user(chat_id, user_id)
  changeChatMemberStatus(chat_id, user_id, 'Editor')
end
-----------------------------------------------------------------------------------------------
function getChannelMembers(channel_id, offset, filter, limit)
  if not limit or limit > 200 then
    limit = 200
  end
  tdcli_function ({
    ID = "GetChannelMembers",
    channel_id_ = getChatId(channel_id).ID,
    filter_ = {
      ID = "ChannelMembers" .. filter
    },
    offset_ = offset,
    limit_ = limit
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function getChannelFull(channel_id)
  tdcli_function ({
    ID = "GetChannelFull",
    channel_id_ = getChatId(channel_id).ID
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
local function channel_get_bots(channel,cb)
local function callback_admins(extra,result,success)
    limit = result.member_count_
    getChannelMembers(channel, 0, 'Bots', limit,cb)
    end
  getChannelFull(channel,callback_admins)
end
-----------------------------------------------------------------------------------------------
local function getInputMessageContent(file, filetype, caption)
  if file:match('/') then
    infile = {ID = "InputFileLocal", path_ = file}
  elseif file:match('^%d+$') then
    infile = {ID = "InputFileId", id_ = file}
  else
    infile = {ID = "InputFilePersistentId", persistent_id_ = file}
  end

  local inmsg = {}
  local filetype = filetype:lower()

  if filetype == 'animation' then
    inmsg = {ID = "InputMessageAnimation", animation_ = infile, caption_ = caption}
  elseif filetype == 'audio' then
    inmsg = {ID = "InputMessageAudio", audio_ = infile, caption_ = caption}
  elseif filetype == 'document' then
    inmsg = {ID = "InputMessageDocument", document_ = infile, caption_ = caption}
  elseif filetype == 'photo' then
    inmsg = {ID = "InputMessagePhoto", photo_ = infile, caption_ = caption}
  elseif filetype == 'sticker' then
    inmsg = {ID = "InputMessageSticker", sticker_ = infile, caption_ = caption}
  elseif filetype == 'video' then
    inmsg = {ID = "InputMessageVideo", video_ = infile, caption_ = caption}
  elseif filetype == 'voice' then
    inmsg = {ID = "InputMessageVoice", voice_ = infile, caption_ = caption}
  end

  return inmsg
end

-----------------------------------------------------------------------------------------------
function send_file(chat_id, type, file, caption,wtf)
local mame = (wtf or 0)
  tdcli_function ({
    ID = "SendMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = mame,
    disable_notification_ = 0,
    from_background_ = 1,
    reply_markup_ = nil,
    input_message_content_ = getInputMessageContent(file, type, caption),
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function getUser(user_id, cb)
  tdcli_function ({
    ID = "GetUser",
    user_id_ = user_id
  }, cb, nil)
end
-----------------------------------------------------------------------------------------------
function pin(channel_id, message_id, disable_notification)
   tdcli_function ({
     ID = "PinChannelMessage",
     channel_id_ = getChatId(channel_id).ID,
     message_id_ = message_id,
     disable_notification_ = disable_notification
   }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function tdcli_update_callback(data)
	-------------------------------------------
  if (data.ID == "UpdateNewMessage") then
    local msg = data.message_
    --vardump(data)
    local d = data.disable_notification_
    local chat = chats[msg.chat_id_]
	-------------------------------------------
	if msg.date_ < (os.time() - 30) then
       return false
    end
	-------------------------------------------
	if not database:get("bot:enable:"..msg.chat_id_) and not is_admin(msg.sender_user_id_, msg.chat_id_) then
      return false
    end
    -------------------------------------------
      if msg and msg.send_state_.ID == "MessageIsSuccessfullySent" then
	  --vardump(msg)
	   function get_mymsg_contact(extra, result, success)
             --vardump(result)
       end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,get_mymsg_contact)
         return false
      end
    -------------* EXPIRE *-----------------
    if not database:get("bot:charge:"..msg.chat_id_) then
     if database:get("bot:enable:"..msg.chat_id_) then
      database:del("bot:enable:"..msg.chat_id_)
      for k,v in pairs(sudo_users) do
        send(v, 0, 1, "*Group Expire Ended!* \nLink : "..(database:get("bot:group:link"..msg.chat_id_) or "*Not Set!*").."\nID : "..msg.chat_id_..'\n\n*If You Need Leave Bot From this Group :*\n\n/leave'..msg.chat_id_..'\n*For Join To This Group:*\n/join'..msg.chat_id_..'\n_________________\n*For Charge Again Group:*\n\n*Charge For 30 Day :*\n/plan1'..msg.chat_id_..'\n\n*Charge For 60 Day :*\n/plan2'..msg.chat_id_..'\n\n*Charge For 90 Day :*\n/plan3'..msg.chat_id_, 1, 'md')
      end
        send(msg.chat_id_, 0, 1, '*Group Expire Ended! For Charge Contact* @MrBlackLife\n*If You Had a Report Go To :* *@Sphero_Bot*\n-------------------\n`شارز این گروه تمام شد!`\n`برای شارژ به ادمین ربات مراجعه کنید `\n', 1, 'md')
        send(msg.chat_id_, 0, 1, '*Group Expire Ended! For Charge Contact* @MrBlackLife\n*If You Had a Report Go To :* *@Sphero_Bot*\n-------------------\n`شارز این گروه تمام شد!`\n`برای شارژ به ادمین ربات مراجعه کنید `\n', 1, 'md')
	   chat_leave(msg.chat_id_, bot_id)
      end
    end
    --------- ANTI FLOOD & AutoLeave -------------------
	local hash = 'flood:max:'..msg.chat_id_
    if not database:get(hash) then
        floodMax = 5
    else
        floodMax = tonumber(database:get(hash))
    end

    local hash = 'flood:time:'..msg.chat_id_
    if not database:get(hash) then
        floodTime = 3
    else
        floodTime = tonumber(database:get(hash))
    end
    if not is_mod(msg.sender_user_id_, msg.chat_id_) then
        local hashse = 'anti-flood:'..msg.chat_id_
        if not database:get(hashse) then
                if not is_mod(msg.sender_user_id_, msg.chat_id_) then
                    local hash = 'flood:'..msg.sender_user_id_..':'..msg.chat_id_..':msg-num'
                    local msgs = tonumber(database:get(hash) or 0)
                    if msgs > (floodMax - 1) then
                        local user = msg.sender_user_id_
                        local chat = msg.chat_id_
                        local channel = msg.chat_id_
						 local user_id = msg.sender_user_id_
						 local banned = is_banned(user_id, msg.chat_id_)
                         if banned then
						local id = msg.id_
        				local msgs = {[0] = id}
       					local chat = msg.chat_id_
       						       del_all_msgs(msg.chat_id_, msg.sender_user_id_)
						    else
						 local id = msg.id_
                         local msgs = {[0] = id}
                         local chat = msg.chat_id_
		                chat_kick(msg.chat_id_, msg.sender_user_id_)
						 del_all_msgs(msg.chat_id_, msg.sender_user_id_)
						user_id = msg.sender_user_id_
						local bhash =  'bot:banned:'..msg.chat_id_
                        database:sadd(bhash, user_id)
                           send(msg.chat_id_, msg.id_, 1, '> *User*  `|'..msg.sender_user_id_..'|`\n*Banned For Spamming!*', 1, 'md')
					  end
                    end
                    database:setex(hash, floodTime, msgs+1)
                end
        end
	end
 if database:get("autoleave") == "yes" then
      if not database:get("bot:enable:"..msg.chat_id_) then
        if not database:get("bot:autoleave:"..msg.chat_id_) then
          database:setex("bot:autoleave:"..msg.chat_id_,1250,true)
        end
      end
      local autoleavetime = tonumber(database:ttl("bot:autoleave:"..msg.chat_id_))
      local time = 50
      if (autoleavetime) < tonumber(time) then
        database:set("lefting"..msg.chat_id_,true)
      end
      local id = tostring(msg.chat_id_)
      if id:match("-100(%d+)") then
        if database:get("lefting"..msg.chat_id_) then
          if not database:get("bot:enable:"..msg.chat_id_) then
            chat_leave(msg.chat_id_, bot_id)
            database:del("lefting"..msg.chat_id_)
            local v = tonumber(sudo_users)
            send(v, 0, 1,"*Bot Leaved From This Group!*\n*Name : *`|"..chat.title_.."|`\n*ID :* `|"..msg.chat_id_.."|`", 1, 'md')
          end
        end
      end
    end
	-------------------------------------------
	database:incr("bot:allmsgs")
	if msg.chat_id_ then
      local id = tostring(msg.chat_id_)
      if id:match('-100(%d+)') then
        if not database:sismember("bot:groups",msg.chat_id_) then
            database:sadd("bot:groups",msg.chat_id_)
        end
        elseif id:match('^(%d+)') then
        if not database:sismember("bot:userss",msg.chat_id_) then
            database:sadd("bot:userss",msg.chat_id_)
        end
        else
        if not database:sismember("bot:groups",msg.chat_id_) then
            database:sadd("bot:groups",msg.chat_id_)
        end
     end
    end
	-------------------------------------------
    -------------* MSG TYPES *-----------------
   if msg.content_ then
   	if msg.reply_markup_ and  msg.reply_markup_.ID == "ReplyMarkupInlineKeyboard" then
		print("INLINE KEYBOARD DETECTED!!")
	msg_type = 'MSG:Inline'
	-------------------------
    elseif msg.content_.ID == "MessageText" then
	text = msg.content_.text_
		print("TEXT MSG DETECTED!!")
	msg_type = 'MSG:Text'
	-------------------------
	--[[elseif msg.content_.ID == "MessagePhoto" then
	print("PHOTO DETECTED!!")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Photo']]
	-------------------------
	elseif msg.content_.ID == "MessageChatAddMembers" then
	print("NEW ADD DETECTED!!")
	msg_type = 'MSG:NewUserAdd'
	-------------------------
	elseif msg.content_.ID == "MessageChatJoinByLink" then
		print("NEW JOIN DETECTED!!")
	msg_type = 'MSG:NewUserLink'
	-------------------------
	elseif msg.content_.ID == "MessageSticker" then
		print("STICKER DETECTED!!")
	msg_type = 'MSG:Sticker'
	-------------------------
	elseif msg.content_.ID == "MessageAudio" then
		print("MUSIC DETECTED!!")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Audio'
	-------------------------
	elseif msg.content_.ID == "MessageVoice" then
		print("VOICE DETECTED!!")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Voice'
	-------------------------
	elseif msg.content_.ID == "MessageVideo" then
		print("VIDEO DETECTED!!")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Video'
	-------------------------
	elseif msg.content_.ID == "MessageAnimation" then
		print("GIF DETECTED!!")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Gif'
	-------------------------
	elseif msg.content_.ID == "MessageLocation" then
		print("LOCATION DETECTED!!")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Location'
	-------------------------
	elseif msg.content_.ID == "MessageChatJoinByLink" or msg.content_.ID == "MessageChatAddMembers" then
	msg_type = 'MSG:NewUser'
	-------------------------
	elseif msg.content_.ID == "MessageContact" then
		print("CONTACT DETECTED!!")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Contact'
	-------------------------
	end
   end
    -------------------------------------------
    -------------------------------------------
    if ((not d) and chat) then
      if msg.content_.ID == "MessageText" then
        do_notify (chat.title_, msg.content_.text_)
      else
        do_notify (chat.title_, msg.content_.ID)
      end
    end
  -----------------------------------------------------------------------------------------------
                                     -- end functions --
  -----------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------
                                     -- start code --
  -----------------------------------------------------------------------------------------------
  -------------------------------------- Process mod --------------------------------------------
  -----------------------------------------------------------------------------------------------

  -------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------
  --------------------------******** START MSG CHECKS ********-------------------------------------------
  -------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------
if is_banned(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
		  chat_kick(msg.chat_id_, msg.sender_user_id_)
		  return
end
if is_muted(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
          delete_msg(chat,msgs)
		  return
end
if is_gbanned(msg.sender_user_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
		  chat_kick(msg.chat_id_, msg.sender_user_id_)
		   return
end
if database:get('bot:muteall'..msg.chat_id_) and not is_mod(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
        return
end
    database:incr('user:msgs'..msg.chat_id_..':'..msg.sender_user_id_)
	database:incr('group:msgs'..msg.chat_id_)
if msg.content_.ID == "MessagePinMessage" then
  if database:get('pinnedmsg'..msg.chat_id_) and database:get('bot:pin:mute'..msg.chat_id_) then
   send(msg.chat_id_, msg.id_, 1, '*You Dont Have Access*\n*Sorry. but Me Unpinned Your Message*\n*if You Have a Rank in Bot*\n_Send Me_ */pin* _And just reply Your message_', 1, 'md')
   unpinmsg(msg.chat_id_)
   local pin_id = database:get('pinnedmsg'..msg.chat_id_)
         pin(msg.chat_id_,pin_id,0)
   end
end
if database:get('bot:viewget'..msg.sender_user_id_) then
    if not msg.forward_info_ then
		send(msg.chat_id_, msg.id_, 1, '_Got a problem!!_\n*Please Send Again Command And forward your post*', 1, 'md')
		database:del('bot:viewget'..msg.sender_user_id_)
	else
		send(msg.chat_id_, msg.id_, 1, 'Your Post Views:\n> '..msg.views_..' View!', 1, 'md')
        database:del('bot:viewget'..msg.sender_user_id_)
	end
end
if msg_type == 'MSG:Photo' then
   --vardump(msg)
 if not is_mod(msg.sender_user_id_, msg.chat_id_) then
if msg.forward_info_ then
if database:get('bot:forward:mute'..msg.chat_id_) then
	if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
     if database:get('bot:photo:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return
   end
   if caption_text then
      check_filter_words(msg, caption_text)
   if caption_text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or caption_text:match("[Tt].[Mm][Ee]") then
   if database:get('bot:links:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("@") or msg.content_.entities_[0].ID and msg.content_.entities_[0].ID == "MessageEntityMentionName" then
   if database:get('bot:tag:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("#") then
   if database:get('bot:hashtag:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("[Hh][Tt][Tt][Pp][Ss]://") or caption_text:match("[Hh][Tt][Tt][Pp]://") or caption_text:match(".[Ii][Rr]") or caption_text:match(".[Cc][Oo][Mm]") or caption_text:match(".[Oo][Rr][Gg]") or caption_text:match(".[Ii][Nn][Ff][Oo]") or caption_text:match("[Ww][Ww][Ww].") or caption_text:match(".[Tt][Kk]") then
   if database:get('bot:webpage:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("[\216-\219][\128-\191]") then
   if database:get('bot:arabic:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("[ASDFGHJKLQWERTYUIOPZXCVBNMasdfghjklqwertyuiopzxcvbnm]") then
   if database:get('bot:english:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
   end
  elseif msg_type == 'MSG:Inline' then
   if not is_mod(msg.sender_user_id_, msg.chat_id_) then
    if database:get('bot:inline:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return
   end
   end
  elseif msg_type == 'MSG:Sticker' then
   if not is_mod(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:sticker:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return
   end
   end
elseif msg_type == 'MSG:NewUserLink' then
  if database:get('bot:tgservice:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return
   end
   function get_welcome(extra,result,success)
    if database:get('welcome:'..msg.chat_id_) then
        text = database:get('welcome:'..msg.chat_id_)
    else
        text = '*Hi {firstname} 😃*'
    end
    local text = text:gsub('{firstname}',(result.first_name_ or ''))
    local text = text:gsub('{lastname}',(result.last_name_ or ''))
    local text = text:gsub('{username}',(result.username_ or ''))
         send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
   end
	  if database:get("bot:welcome"..msg.chat_id_) then
        getUser(msg.sender_user_id_,get_welcome)
      end
elseif msg_type == 'MSG:NewUserAdd' then
  if database:get('bot:tgservice:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return
   end
      --vardump(msg)
   if msg.content_.members_[0].username_ and msg.content_.members_[0].username_:match("[Bb][Oo][Tt]$") then
      if database:get('bot:bots:mute'..msg.chat_id_) and not is_mod(msg.content_.members_[0].id_, msg.chat_id_) then
		 chat_kick(msg.chat_id_, msg.content_.members_[0].id_)
		 return false
	  end
   end
   if is_banned(msg.content_.members_[0].id_, msg.chat_id_) then
		 chat_kick(msg.chat_id_, msg.content_.members_[0].id_)
		 return false
   end
   if database:get("bot:welcome"..msg.chat_id_) then
    if database:get('welcome:'..msg.chat_id_) then
        text = database:get('welcome:'..msg.chat_id_)
    else
        text = '*Hi {firstname} 😃*'
    end
    local text = text:gsub('{firstname}',(msg.content_.members_[0].first_name_ or ''))
    local text = text:gsub('{lastname}',(msg.content_.members_[0].last_name_ or ''))
    local text = text:gsub('{username}',('@'..msg.content_.members_[0].username_ or ''))
         send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
   end
elseif msg_type == 'MSG:Contact' then
 if not is_mod(msg.sender_user_id_, msg.chat_id_) then
if msg.forward_info_ then
if database:get('bot:forward:mute'..msg.chat_id_) then
	if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
  if database:get('bot:contact:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return
   end
   end
elseif msg_type == 'MSG:Audio' then
 if not is_mod(msg.sender_user_id_, msg.chat_id_) then
if msg.forward_info_ then
if database:get('bot:forward:mute'..msg.chat_id_) then
	if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
  if database:get('bot:music:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return
   end
   if caption_text then
      check_filter_words(msg, caption_text)
   if caption_text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or caption_text:match("[Tt].[Mm][Ee]") then
   if database:get('bot:links:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
 if caption_text:match("@") or msg.content_.entities_[0].ID == "MessageEntityMentionName" then
   if database:get('bot:tag:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
  	if caption_text:match("#") then
   if database:get('bot:hashtag:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if caption_text:match("[Hh][Tt][Tt][Pp][Ss]://") or caption_text:match("[Hh][Tt][Tt][Pp]://") or caption_text:match(".[Ii][Rr]") or caption_text:match(".[Cc][Oo][Mm]") or caption_text:match(".[Oo][Rr][Gg]") or caption_text:match(".[Ii][Nn][Ff][Oo]") or caption_text:match("[Ww][Ww][Ww].") or caption_text:match(".[Tt][Kk]") then
   if database:get('bot:webpage:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
     if caption_text:match("[\216-\219][\128-\191]") then
    if database:get('bot:arabic:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("[ASDFGHJKLQWERTYUIOPZXCVBNMasdfghjklqwertyuiopzxcvbnm]") then
   if database:get('bot:english:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
   end
elseif msg_type == 'MSG:Voice' then
 if not is_mod(msg.sender_user_id_, msg.chat_id_) then
if msg.forward_info_ then
if database:get('bot:forward:mute'..msg.chat_id_) then
	if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
  if database:get('bot:voice:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return
   end
   if caption_text then
      check_filter_words(msg, caption_text)
  if caption_text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or caption_text:match("[Tt].[Mm][Ee]") then
   if database:get('bot:links:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
  if caption_text:match("@") then
  if database:get('bot:tag:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if caption_text:match("#") then
   if database:get('bot:hashtag:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
	if caption_text:match("[Hh][Tt][Tt][Pp][Ss]://") or caption_text:match("[Hh][Tt][Tt][Pp]://") or caption_text:match(".[Ii][Rr]") or caption_text:match(".[Cc][Oo][Mm]") or caption_text:match(".[Oo][Rr][Gg]") or caption_text:match(".[Ii][Nn][Ff][Oo]") or caption_text:match("[Ww][Ww][Ww].") or caption_text:match(".[Tt][Kk]") then
   if database:get('bot:webpage:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	 if caption_text:match("[\216-\219][\128-\191]") then
    if database:get('bot:arabic:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("[ASDFGHJKLQWERTYUIOPZXCVBNMasdfghjklqwertyuiopzxcvbnm]") then
   if database:get('bot:english:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
   end
elseif msg_type == 'MSG:Location' then
 if not is_mod(msg.sender_user_id_, msg.chat_id_) then
if msg.forward_info_ then
if database:get('bot:forward:mute'..msg.chat_id_) then
	if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
  if database:get('bot:location:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return
   end
   if caption_text then
      check_filter_words(msg, caption_text)
   if caption_text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or caption_text:match("[Tt].[Mm][Ee]") then
   if database:get('bot:links:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("@") or msg.content_.entities_[0].ID and msg.content_.entities_[0].ID == "MessageEntityMentionName" then
   if database:get('bot:tag:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if caption_text:match("#") then
   if database:get('bot:hashtag:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if caption_text:match("[Hh][Tt][Tt][Pp][Ss]://") or caption_text:match("[Hh][Tt][Tt][Pp]://") or caption_text:match(".[Ii][Rr]") or caption_text:match(".[Cc][Oo][Mm]") or caption_text:match(".[Oo][Rr][Gg]") or caption_text:match(".[Ii][Nn][Ff][Oo]") or caption_text:match("[Ww][Ww][Ww].") or caption_text:match(".[Tt][Kk]") then
   if database:get('bot:webpage:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if caption_text:match("[\216-\219][\128-\191]") then
   if database:get('bot:arabic:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("[ASDFGHJKLQWERTYUIOPZXCVBNMasdfghjklqwertyuiopzxcvbnm]") then
   if database:get('bot:english:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
   end
elseif msg_type == 'MSG:Video' then
 if not is_mod(msg.sender_user_id_, msg.chat_id_) then
if msg.forward_info_ then
if database:get('bot:forward:mute'..msg.chat_id_) then
	if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
  if database:get('bot:video:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return
   end
   if caption_text then
      check_filter_words(msg, caption_text)
  if caption_text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or caption_text:match("[Tt].[Mm][Ee]") then
   if database:get('bot:links:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("@") or msg.content_.entities_[0].ID and msg.content_.entities_[0].ID == "MessageEntityMentionName" then
   if database:get('bot:tag:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if caption_text:match("#") then
   if database:get('bot:hashtag:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if caption_text:match("[Hh][Tt][Tt][Pp][Ss]://") or caption_text:match("[Hh][Tt][Tt][Pp]://") or caption_text:match(".[Ii][Rr]") or caption_text:match(".[Cc][Oo][Mm]") or caption_text:match(".[Oo][Rr][Gg]") or caption_text:match(".[Ii][Nn][Ff][Oo]") or caption_text:match("[Ww][Ww][Ww].") or caption_text:match(".[Tt][Kk]") then
   if database:get('bot:webpage:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if caption_text:match("[\216-\219][\128-\191]") then
   if database:get('bot:arabic:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("[ASDFGHJKLQWERTYUIOPZXCVBNMasdfghjklqwertyuiopzxcvbnm]") then
   if database:get('bot:english:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
   end
elseif msg_type == 'MSG:Gif' then
 if not is_mod(msg.sender_user_id_, msg.chat_id_) then
if msg.forward_info_ then
if database:get('bot:forward:mute'..msg.chat_id_) then
	if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
  if database:get('bot:gifs:mute'..msg.chat_id_) and not is_mod(msg.sender_user_id_, msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return
   end
   if caption_text then
   check_filter_words(msg, caption_text)
   if caption_text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or caption_text:match("[Tt].[Mm][Ee]") then
   if database:get('bot:links:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("@") or msg.content_.entities_[0].ID and msg.content_.entities_[0].ID == "MessageEntityMentionName" then
   if database:get('bot:tag:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if caption_text:match("#") then
   if database:get('bot:hashtag:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
	if caption_text:match("[Hh][Tt][Tt][Pp][Ss]://") or caption_text:match("[Hh][Tt][Tt][Pp]://") or caption_text:match(".[Ii][Rr]") or caption_text:match(".[Cc][Oo][Mm]") or caption_text:match(".[Oo][Rr][Gg]") or caption_text:match(".[Ii][Nn][Ff][Oo]") or caption_text:match("[Ww][Ww][Ww].") or caption_text:match(".[Tt][Kk]") then
   if database:get('bot:webpage:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if caption_text:match("[\216-\219][\128-\191]") then
   if database:get('bot:arabic:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("[ASDFGHJKLQWERTYUIOPZXCVBNMasdfghjklqwertyuiopzxcvbnm]") then
   if database:get('bot:english:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
   end
elseif msg_type == 'MSG:Text' then
 --vardump(msg)
    if database:get("bot:group:link"..msg.chat_id_) == 'Waiting For Link!\nPlease Send Group Link.' and is_mod(msg.sender_user_id_, msg.chat_id_) then
      if text:match("(https://telegram.me/joinchat/%S+)") then
	  local glink = text:match("(https://telegram.me/joinchat/%S+)")
      local hash = "bot:group:link"..msg.chat_id_
               database:set(hash,glink)
			  send(msg.chat_id_, msg.id_, 1, '*New link Set!*', 1, 'md')
			  send(msg.chat_id_, 0, 1, '<b>Newlink:</b>\n'..glink, 1, 'html')
      end
   end
    function check_username(extra,result,success)
	 --vardump(result)
	local username = (result.username_ or '')
	local svuser = 'user:'..result.id_
	if username then
      database:hset(svuser, 'username', username)
    end
	if username and username:match("[Bb][Oo][Tt]$") then
      if database:get('bot:bots:mute'..msg.chat_id_) and not is_mod(result.id_, msg.chat_id_) then
		 chat_kick(msg.chat_id_, result.id_)
		 return false
		 end
	  end
   end
    getUser(msg.sender_user_id_,check_username)
   database:set('bot:editid'.. msg.id_,msg.content_.text_)
   if not is_mod(msg.sender_user_id_, msg.chat_id_) then
    check_filter_words(msg, text)
	if text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or text:match("[Tt].[Mm][Ee]") then
     if database:get('bot:links:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
	if text then
     if database:get('bot:text:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
if msg.forward_info_ then
if database:get('bot:forward:mute'..msg.chat_id_) then
	if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
   if text:match("@") or msg.content_.entities_[0] and msg.content_.entities_[0].ID == "MessageEntityMentionName" then
   if database:get('bot:tag:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if text:match("#") then
      if database:get('bot:hashtag:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if text:match("[Hh][Tt][Tt][Pp][Ss]://") or text:match("[Hh][Tt][Tt][Pp]://") or text:match(".[Ii][Rr]") or text:match(".[Cc][Oo][Mm]") or text:match(".[Oo][Rr][Gg]") or text:match(".[Ii][Nn][Ff][Oo]") or text:match("[Ww][Ww][Ww].") or text:match(".[Tt][Kk]") then
      if database:get('bot:webpage:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if text:match("[\216-\219][\128-\191]") then
      if database:get('bot:arabic:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	  if text:match("[ASDFGHJKLQWERTYUIOPZXCVBNMasdfghjklqwertyuiopzxcvbnm]") then
      if database:get('bot:english:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	  end
     end
    end
   end
  -------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------
  ---------------------------******** END MSG CHECKS ********--------------------------------------------
  -------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------
  if database:get('bot:cmds'..msg.chat_id_) and not is_mod(msg.sender_user_id_, msg.chat_id_) then
  return
  else
    ------------------------------------ With Pattern -------------------------------------------
	if text:match("^[#!/]ping$") then
	   send(msg.chat_id_, msg.id_, 1, '*Online..!*', 1, 'md')
	end
	-----------------------------------------------------------------------------------------------
	if text:match("^[!/#]leave$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	     chat_leave(msg.chat_id_, bot_id)
    end
	----------------------------------------------------------------------------------------------
	local text = msg.content_.text_:gsub('ارتقا','promote')
  local text = msg.content_.text_:gsub('p','promote')
if text:match("^[#!/]promote$") and is_owner(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function promote_by_reply(extra, result, success)
	local hash = 'bot:mods:'..msg.chat_id_
	if database:sismember(hash, result.sender_user_id_) then
         send(msg.chat_id_, msg.id_, 1, '*User* `|'..result.sender_user_id_..'|` *Is Already Moderator!*', 1, 'md')
	else
         database:sadd(hash, result.sender_user_id_)
         send(msg.chat_id_, msg.id_, 1, '*User* `|'..result.sender_user_id_..'|` *Has Been Promoted!*', 1, 'md')
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,promote_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]promote @(.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local ap = {string.match(text, "^[#/!](promote) @(.*)$")}
	function promote_by_username(extra, result, success)
	if result.id_ then
	        database:sadd('bot:mods:'..msg.chat_id_, result.id_)
            texts = '*User* `|'..result.id_..'|` *Has Been Promoted!*'
            else
            texts = '*UserName InCorrect!*'
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'md')
    end
	      resolve_username(ap[2],promote_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]promote (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local ap = {string.match(text, "^[#/!](promote) (%d+)$")}
	        database:sadd('bot:mods:'..msg.chat_id_, ap[2])
	send(msg.chat_id_, msg.id_, 1, '*User* `|'..ap[2]..'|` *Has Been Promoted!*', 1, 'md')
    end
	-----------------------------------------------------------------------------------------------
		local text = msg.content_.text_:gsub('عزل','demote')
    local text = msg.content_.text_:gsub('d','demote')
	if text:match("^[#!/]demote$") and is_owner(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function demote_by_reply(extra, result, success)
	local hash = 'bot:mods:'..msg.chat_id_
	if not database:sismember(hash, result.sender_user_id_) then
         send(msg.chat_id_, msg.id_, 1, '*User* `|'..result.sender_user_id_..'|` *Has Been Demoted!*', 1, 'md')
	else
         database:srem(hash, result.sender_user_id_)
         send(msg.chat_id_, msg.id_, 1, '*User* `|'..result.sender_user_id_..'|` *Has Been Demoted!*', 1, 'md')
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,demote_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]demote @(.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local hash = 'bot:mods:'..msg.chat_id_
	local ap = {string.match(text, "^[#/!](demote) @(.*)$")}
	function demote_by_username(extra, result, success)
	if result.id_ then
         database:srem(hash, result.id_)
            texts = '*User* `|'..result.id_..'|` *Has Been Demoted!*'
            else
            texts = '*UserName InCorrect!*'
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'md')
    end
	      resolve_username(ap[2],demote_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]demote (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local hash = 'bot:mods:'..msg.chat_id_
	local ap = {string.match(text, "^[#/!](demote) (%d+)$")}
         database:srem(hash, ap[2])
	send(msg.chat_id_, msg.id_, 1, '*User* `|'..ap[2]..'|` *Demoted!*', 1, 'md')
    end
	-----------------------------------------------------------------------------------------------
		local text = msg.content_.text_:gsub('بن','ban')
    local text = msg.content_.text_:gsub('b','ban')
	if text:match("^[#!/]ban$") and is_mod(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function ban_by_reply(extra, result, success)
	local hash = 'bot:banned:'..msg.chat_id_
	if is_mod(result.sender_user_id_, result.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Cant Ban|Kick Admins!*', 1, 'md')
    else
    if database:sismember(hash, result.sender_user_id_) then
         send(msg.chat_id_, msg.id_, 1, '*User* `|'..result.sender_user_id_..'|` *Is Already Banned!*', 1, 'md')
		 chat_kick(result.chat_id_, result.sender_user_id_)
	else
         database:sadd(hash, result.sender_user_id_)
         send(msg.chat_id_, msg.id_, 1, '*User* `|'..result.sender_user_id_..'|` *Banned!*', 1, 'md')
		 chat_kick(result.chat_id_, result.sender_user_id_)
	end
    end
	end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,ban_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]ban @(.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local ap = {string.match(text, "^[#/!](ban) @(.*)$")}
	function ban_by_username(extra, result, success)
	if result.id_ then
	if is_mod(result.id_, msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Cant Ban|Kick Admins!*', 1, 'md')
    else
	        database:sadd('bot:banned:'..msg.chat_id_, result.id_)
            texts = '*User* `|'..result.id_..'|` *Banned!*'
		 chat_kick(msg.chat_id_, result.id_)
	end
            else
            texts = '*UserName InCorrect!*'
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'md')
    end
	      resolve_username(ap[2],ban_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]ban (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local ap = {string.match(text, "^[#/!](ban) (%d+)$")}
	if is_mod(ap[2], msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Cant Ban|Kick Admins!*', 1, 'md')
    else
	        database:sadd('bot:banned:'..msg.chat_id_, ap[2])
		 chat_kick(msg.chat_id_, ap[2])
	send(msg.chat_id_, msg.id_, 1, '*User* `|'..ap[2]..'|` Banned!', 1, 'md')
	end
    end
	-----------------------------------------------------------------------------------------------
				local text = msg.content_.text_:gsub('سوپربن','superban')
        local text = msg.content_.text_:gsub('sb','superban')
			     if text:match("^[!#/]superban$") and is_sudo(msg) and msg.reply_to_message_id_ then
              function ban_by_reply(extra, result, success)
                local hash = 'bot:gbanned:'
                if is_mod(result.sender_user_id_, result.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '*You Cant Gban Admins!*', 1, 'md')
                else
                  if database:sismember(hash, result.sender_user_id_) then
                    send(msg.chat_id_, msg.id_, 1, '*User* `|'..result.sender_user_id_..'|` *Globally Banned!*', 1, 'md')
                    chat_kick(result.chat_id_, result.sender_user_id_)
                  else
                    database:sadd(hash, result.sender_user_id_)
                    send(msg.chat_id_, msg.id_, 1, '*User* `|'..result.sender_user_id_..'|` *Globally Banned!*', 1, 'md')
                    chat_kick(result.chat_id_, result.sender_user_id_)
                  end
                end
              end
              getMessage(msg.chat_id_, msg.reply_to_message_id_,ban_by_reply)
            end
            -----------------------------------------------------------------------------------------------
            if text:match("^[!#/]superban @(.*)$") and is_sudo(msg) then
              local ap = {string.match(text, "^([!#/]superban) @(.*)$")}
              function ban_by_username(extra, result, success)
                if result.id_ then
                  if is_mod(result.id_, msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, '*You Cant Gban Admins!*', 1, 'md')
                  else
                    database:sadd('bot:gbanned:',result.id_)
                    chat_kick(msg.chat_id_, result.id_)
                    texts = '*User* `|'..result.id_..'|` *Globally Banned!*!'
                    chat_kick(msg.chat_id_, result.id_)
                  end
                else
                  texts = '*UserName InCorrect!*'
                end
                send(msg.chat_id_, msg.id_, 1, texts, 1, 'md')
              end
              resolve_username(ap[2],ban_by_username)
            end
            -----------------------------------------------------------------------------------------------
            if text:match("^[!#/]superban (%d+)$") and is_sudo(msg) then
              local ap = {string.match(text, "^([!#/]superban) (%d+)$")}
              if is_mod(ap[2], msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '*You Cant Gban Admins!*', 1, 'md')
              else
                database:sadd('bot:gbanned:',ap[2])
                send(msg.chat_id_, msg.id_, 1, '*User* `|'..ap[2]..'|` *Globally Banned!*', 1, 'md')
                chat_kick(msg.chat_id_, result.id_)
					end
            end
	-----------------------------------------------------------------------------------------------
			local text = msg.content_.text_:gsub('پاک کردن همه','delall')
      local text = msg.content_.text_:gsub('delall','da')
	if text:match("^[#!/]delall$") and is_owner(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function delall_by_reply(extra, result, success)
	if is_mod(result.sender_user_id_, result.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t Delete Msgs from Moderators!!*', 1, 'md')
    else
         send(msg.chat_id_, msg.id_, 1, '*All Msgs From* `|'..result.sender_user_id_..'|` *Has been Deleted!!*', 1, 'md')
		     del_all_msgs(result.chat_id_, result.sender_user_id_)
    end
	end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,delall_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]delall (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
		local ass = {string.match(text, "^[#/!](delall) (%d+)$")}
	if is_mod(ass[2], msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t Delete Msgs from Moderators!!*', 1, 'md')
    else
	 		     del_all_msgs(msg.chat_id_, ass[2])
         send(msg.chat_id_, msg.id_, 1, '*All Msgs From* `|'..ass[2]..'|` *Has been Deleted!!*', 1, 'md')
    end
	end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]delall @(.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local ap = {string.match(text, "^[#/!](delall) @(.*)$")}
	function delall_by_username(extra, result, success)
	if result.id_ then
	if is_mod(result.id_, msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t Delete Msgs from Moderators!!*', 1, 'md')
		 return false
    end
		 		     del_all_msgs(msg.chat_id_, result.id_)
            text = '*All Msgs From* `|'..result.id_..'|` *Has been Deleted!!*'
            else
            text = '*UserName InCorrect!*'
    end
	         send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
    end
	      resolve_username(ap[2],delall_by_username)
    end
	-----------------------------------------------------------------------------------------------
		local text = msg.content_.text_:gsub('انبن','unban')
    local text = msg.content_.text_:gsub('ub','unban')
	if text:match("^[#!/]unban$") and is_mod(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function unban_by_reply(extra, result, success)
	local hash = 'bot:banned:'..msg.chat_id_
	if not database:sismember(hash, result.sender_user_id_) then
         send(msg.chat_id_, msg.id_, 1, '*User* `|'..result.sender_user_id_..'|` *Is Already Unbanned!*', 1, 'md')
	else
         database:srem(hash, result.sender_user_id_)
         send(msg.chat_id_, msg.id_, 1, '*User* `|'..result.sender_user_id_..'|` *Unbanned!*', 1, 'md')
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,unban_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]unban @(.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local ap = {string.match(text, "^[#/!](unban) @(.*)$")}
	function unban_by_username(extra, result, success)
	if result.id_ then
         database:srem('bot:banned:'..msg.chat_id_, result.id_)
            text = '*User* `|'..result.id_..'|` *Unbanned!*'
            else
            text = '*User InCorrect'
    end
	         send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
    end
	      resolve_username(ap[2],unban_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]unban (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local ap = {string.match(text, "^[#/!](unban) (%d+)$")}
	        database:srem('bot:banned:'..msg.chat_id_, ap[2])
	send(msg.chat_id_, msg.id_, 1, '*User* `|'..ap[2]..'|` *Unbanned!*', 1, 'md')
    end
	-----------------------------------------------------------------------------------------------
		local text = msg.content_.text_:gsub('بیصدا','muteuser')
    local text = msg.content_.text_:gsub('muteuser','m')
	if text:match("^[#!/]muteuser$") and is_mod(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function mute_by_reply(extra, result, success)
	local hash = 'bot:muted:'..msg.chat_id_
	if is_mod(result.sender_user_id_, result.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Cant Mute Admins!*', 1, 'md')
    else
    if database:sismember(hash, result.sender_user_id_) then
         send(msg.chat_id_, msg.id_, 1, '*User* `|'..result.sender_user_id_..'|` *Is Already Muted!*', 1, 'md')
	else
         database:sadd(hash, result.sender_user_id_)
         send(msg.chat_id_, msg.id_, 1, '*User* `|'..result.sender_user_id_..'|` *Has Been Muted!*', 1, 'md')
	end
    end
	end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,mute_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]muteuser @(.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local ap = {string.match(text, "^[#/!](muteuser) @(.*)$")}
	function mute_by_username(extra, result, success)
	if result.id_ then
	if is_mod(result.id_, msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Cant Mute Admins!*', 1, 'md')
    else
	        database:sadd('bot:muted:'..msg.chat_id_, result.id_)
            texts = '*User* `|'..result.id_..'|` *Muted!*'
		 chat_kick(msg.chat_id_, result.id_)
	end
            else
            texts = '*UserName InCorrect!*'
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'md')
    end
	      resolve_username(ap[2],mute_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]muteuser (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local ap = {string.match(text, "^[#/!](muteuser) (%d+)$")}
	if is_mod(ap[2], msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Cant Mute Admins!*', 1, 'md')
    else
	        database:sadd('bot:muted:'..msg.chat_id_, ap[2])
	send(msg.chat_id_, msg.id_, 1, '*User* `|'..ap[2]..'|` *Has Been Muted!*', 1, 'md')
	end
    end
	-----------------------------------------------------------------------------------------------
		local text = msg.content_.text_:gsub('صدادار','unmuteuser')
    local text = msg.content_.text_:gsub('unmuteuser','um')
	if text:match("^[#!/]unmuteuser$") and is_mod(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function unmute_by_reply(extra, result, success)
	local hash = 'bot:muted:'..msg.chat_id_
	if not database:sismember(hash, result.sender_user_id_) then
         send(msg.chat_id_, msg.id_, 1, '*User* `|'..result.sender_user_id_..'|` *Is Already Unmuted!*', 1, 'md')
	else
         database:srem(hash, result.sender_user_id_)
         send(msg.chat_id_, msg.id_, 1, '*User* `|'..result.sender_user_id_..'|` *Has Been Unmuted!*', 1, 'md')
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,unmute_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]unmuteuser @(.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local ap = {string.match(text, "^[#/!](unmuteuser) @(.*)$")}
	function unmute_by_username(extra, result, success)
	if result.id_ then
         database:srem('bot:muted:'..msg.chat_id_, result.id_)
            text = '*User* `|'..result.id_..'|` *Has Been Unmuted!*'
            else
            text = '*UserName InCorrect!*'
    end
	         send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
    end
	      resolve_username(ap[2],unmute_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]unmuteuser (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local ap = {string.match(text, "^[#/!](unmuteuser) (%d+)$")}
	        database:srem('bot:muted:'..msg.chat_id_, ap[2])
	send(msg.chat_id_, msg.id_, 1, '*User* `|'..ap[2]..'|` *Has Been Unmuted!*', 1, 'md')
    end
	-----------------------------------------------------------------------------------------------
		local text = msg.content_.text_:gsub('ادمین','setowner')
    local text = msg.content_.text_:gsub('setowner','sow')
	if text:match("^[#!/]setowner$") and is_admin(msg.sender_user_id_) and msg.reply_to_message_id_ then
	function setowner_by_reply(extra, result, success)
	local hash = 'bot:owners:'..msg.chat_id_
	if database:sismember(hash, result.sender_user_id_) then
         send(msg.chat_id_, msg.id_, 1, '*User* `|'..result.sender_user_id_..'|` *Is Already Moderator!*', 1, 'md')
	else
         database:sadd(hash, result.sender_user_id_)
         send(msg.chat_id_, msg.id_, 1, '*User* `|'..result.sender_user_id_..'|` *Promoted to GroupOwner!*', 1, 'md')
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,setowner_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]setowner @(.*)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	local ap = {string.match(text, "^[#/!](setowner) @(.*)$")}
	function setowner_by_username(extra, result, success)
	if result.id_ then
	        database:sadd('bot:owners:'..msg.chat_id_, result.id_)
            texts = '*User* `|'..result.id_..'|` *Promoted to GroupOwner!*'
            else
            texts = '*UserName InCorrect!*'
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'md')
    end
	      resolve_username(ap[2],setowner_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]setowner (%d+)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	local ap = {string.match(text, "^[#/!](setowner) (%d+)$")}
	        database:sadd('bot:owners:'..msg.chat_id_, ap[2])
	send(msg.chat_id_, msg.id_, 1, '*User* `|'..ap[2]..'|` *Promoted to GroupOwner!*', 1, 'md')
    end
	-----------------------------------------------------------------------------------------------
	local text = msg.content_.text_:gsub('عزل ادمین','demowner')
  local text = msg.content_.text_:gsub('demowner','dow')
	if text:match("^[#!/]demowner$") and is_admin(msg.sender_user_id_) and msg.reply_to_message_id_ then
	function deowner_by_reply(extra, result, success)
	local hash = 'bot:owners:'..msg.chat_id_
	if not database:sismember(hash, result.sender_user_id_) then
         send(msg.chat_id_, msg.id_, 1, '*User* `|'..result.sender_user_id_..'|` *Is Not GroupOwner*', 1, 'md')
	else
         database:srem(hash, result.sender_user_id_)
         send(msg.chat_id_, msg.id_, 1, '*User* `|'..result.sender_user_id_..'|` *Removed From GroupOwners!*', 1, 'md')
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,deowner_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]demowner @(._)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	local hash = 'bot:owners:'..msg.chat_id_
	local ap = {string.match(text, "^[#/!](demowner) @(._)$")}
	function remowner_by_username(extra, result, success)
	if result.id_ then
         database:srem(hash, result.id_)
            texts = '*User* `|'..result.id_..'|` *Removed From GroupOwners!*'
            else
            texts = '*UserName InCorrect!*'
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'md')
    end
	      resolve_username(ap[2],remowner_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]demowner (%d+)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	local hash = 'bot:owners:'..msg.chat_id_
	local ap = {string.match(text, "^[#/!](demowner) (%d+)$")}
         database:srem(hash, ap[2])
	send(msg.chat_id_, msg.id_, 1, '*User* `|'..ap[2]..'|` *Removed From GroupOwners!*', 1, 'md')
    end
	-----------------------------------------------------------------------------------------------
		local text = msg.content_.text_:gsub('ادمین ربات','addadmin')
    local text = msg.content_.text_:gsub('addadmin','aa')
	if text:match("^[#!/]addadmin$") and is_sudo(msg) and msg.reply_to_message_id_ then
	function addadmin_by_reply(extra, result, success)
	local hash = 'bot:admins:'
	if database:sismember(hash, result.sender_user_id_) then
         send(msg.chat_id_, msg.id_, 1, '*User* `|'..result.sender_user_id_..'|` *Is Already Admin!*', 1, 'md')
	else
         database:sadd(hash, result.sender_user_id_)
         send(msg.chat_id_, msg.id_, 1, '*User* `|'..result.sender_user_id_..'|` *Added To Bot Admins!*', 1, 'md')
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,addadmin_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]addadmin @(.*)$") and is_sudo(msg) then
	local ap = {string.match(text, "^[#/!](addadmin) @(.*)$")}
	function addadmin_by_username(extra, result, success)
	if result.id_ then
	        database:sadd('bot:admins:', result.id_)
            texts = '*User* `|'..result.id_..'|` *Added To Bot Admins!*'
            else
            texts = '*UserName InCorrect!*'
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'md')
    end
	      resolve_username(ap[2],addadmin_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]addadmin (%d+)$") and is_sudo(msg) then
	local ap = {string.match(text, "^[#/!](addadmin) (%d+)$")}
	        database:sadd('bot:admins:', ap[2])
	send(msg.chat_id_, msg.id_, 1, '*User* `|'..ap[2]..'|` *Added to Bot Admins!*', 1, 'md')
    end
	-----------------------------------------------------------------------------------------------
		local text = msg.content_.text_:gsub('عزل ادمین ربات','remadmin')
    local text = msg.content_.text_:gsub('remadmin','ra')
	if text:match("^[#!/]remadmin$") and is_sudo(msg) and msg.reply_to_message_id_ then
	function deadmin_by_reply(extra, result, success)
	local hash = 'bot:admins:'
	if not database:sismember(hash, result.sender_user_id_) then
         send(msg.chat_id_, msg.id_, 1, '*User* `|'..result.sender_user_id_..'|` *Is Not Admin!*', 1, 'md')
	else
         database:srem(hash, result.sender_user_id_)
         send(msg.chat_id_, msg.id_, 1, '*User* `|'..result.sender_user_id_..'|` *Removed From Bot Admins!*', 1, 'md')
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,deadmin_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]remadmin @(.*)$") and is_sudo(msg) then
	local hash = 'bot:admins:'
	local ap = {string.match(text, "^[#/!](remadmin) @(.*)$")}
	function remadmin_by_username(extra, result, success)
	if result.id_ then
         database:srem(hash, result.id_)
            texts = '*User* `|'..result.id_..'|` *Removed From Bot Admins!*'
            else
            texts = '*UserName InCorrect!*'
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'md')
    end
	      resolve_username(ap[2],remadmin_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]remadmin (%d+)$") and is_sudo(msg) then
	local hash = 'bot:admins:'
	local ap = {string.match(text, "^[#/!](remadmin) (%d+)$")}
         database:srem(hash, ap[2])
	send(msg.chat_id_, msg.id_, 1, '*User* `|'..ap[2]..'|` *Removed From Admins!*', 1, 'md')
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]modlist$") or text:match("^[#!/]mods$") or text:match("^[#!/]لیست مدیران$") or text:match("^[#!/]ml$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
    local hash =  'bot:mods:'..msg.chat_id_
	local list = database:smembers(hash)
	local text = "*Modlist:*\n\n"
	for k,v in pairs(list) do
	local user_info = database:hgetall('user:'..v)
		if user_info and user_info.username then
			local username = user_info.username
			text = text..k.." - @"..username.." ["..v.."]\n"
		else
			text = text..k.." - "..v.."\n"
		end
	end
	if #list == 0 then
       text = "Modlist is *Empty*"
    end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]mutelist$") or text:match("^[#!/]لیست بیصداها$") or text:match("^[#!/]mul$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
    local hash =  'bot:muted:'..msg.chat_id_
	local list = database:smembers(hash)
	local text = "*MuteList:*\n\n"
	for k,v in pairs(list) do
	local user_info = database:hgetall('user:'..v)
		if user_info and user_info.username then
			local username = user_info.username
			text = text..k.." - @"..username.." ["..v.."]\n"
		else
			text = text..k.." - "..v.."\n"
		end
	end
	if #list == 0 then
       text = "MuteList is *Empty*"
    end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]owner$") or text:match("^[#!/]owners$") or text:match("^[#!/]owners$") or text:match("^[#!/]owl$") and is_sudo(msg) then
    local hash =  'bot:owners:'..msg.chat_id_
	local list = database:smembers(hash)
	local text = "*Owner's List:*\n\n"
	for k,v in pairs(list) do
	local user_info = database:hgetall('user:'..v)
		if user_info and user_info.username then
			local username = user_info.username
			text = text..k.." - @"..username.." ["..v.."]\n"
		else
			text = text..k.." - "..v.."\n"
		end
	end
	if #list == 0 then
       text = "Ownerlist is *Empty*"
    end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]banlist$") or text:match("^[#!/]bl$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
    local hash =  'bot:banned:'..msg.chat_id_
	local list = database:smembers(hash)
	local text = "*Banlist*\n\n"
	for k,v in pairs(list) do
	local user_info = database:hgetall('user:'..v)
		if user_info and user_info.username then
			local username = user_info.username
			text = text..k.." - @"..username.." ["..v.."]\n"
		else
			text = text..k.." - "..v.."\n"
		end
	end
	if #list == 0 then
       text = "Ban List is *Empty*"
    end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
    end
	-----------------------------------------------------------------------------------------------
				if text:match("^[#!/]gbanlist$") or text:match("^[#!/]gbl$") and is_sudo(msg) then
    local hash =  'bot:gbanned:'..msg.chat_id_
	local list = database:smembers(hash)
	local text = "*Globall Banlist*\n\n"
	for k,v in pairs(list) do
	local user_info = database:hgetall('user:'..v)
		if user_info and user_info.username then
			local username = user_info.username
			text = text..k.." - @"..username.." ["..v.."]\n"
		else
			text = text..k.." - "..v.."\n"
		end
	end
	if #list == 0 then
       text = "GloballBan List is *Empty*"
    end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]adminlist$") or text:match("^[#!/]al$") and is_sudo(msg) then
    local hash =  'bot:admins:'
	local list = database:smembers(hash)
	local text = "*Admins:*\n\n"
	for k,v in pairs(list) do
	local user_info = database:hgetall('user:'..v)
		if user_info and user_info.username then
			local username = user_info.username
			text = text..k.." - @"..username.." ["..v.."]\n"
		else
			text = text..k.."` - "..v.."\n"
		end
	end
	if #list == 0 then
       text = "*No Admins Available!*"
    end
    send(msg.chat_id_, msg.id_, 1, '`'..text..'`', 'md')
    end
	-----------------------------------------------------------------------------------------------
   if text:match("^[#!/]id$") and msg.reply_to_message_id_ ~= 0 then
      function id_by_reply(extra, result, success)
	  local user_msgs = database:get('user:msgs'..result.chat_id_..':'..result.sender_user_id_)
        send(msg.chat_id_, msg.id_, 1, "*ID :* `"..result.sender_user_id_.."`\n*Total Message's *:_ `"..user_msgs.."`", 1, 'md')
        end
   getMessage(msg.chat_id_, msg.reply_to_message_id_,id_by_reply)
  end
  -----------------------------------------------------------------------------------------------
-----------------------------------------Setlang-------------------------------------------------
  if text:match("^[!/#][Ss]etlang (.*)$") or text:match("^[!/#]تنظیم زبان (.*)$") or text:match("^[#!/]sl$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
          local langs = {string.match(text, "^(.*) (.*)$")}
          if langs[2] == "fa" or langs[2] == "فارسی" then
            if not database:get('lang:gp:'..msg.chat_id_) then
              send(msg.chat_id_, msg.id_, 1, '> زبان ربات از قبل روی فارسی قرار دارد!', 1, 'md')
            else
              send(msg.chat_id_, msg.id_, 1, '>زبان ربات فارسی شد! ', 1, 'md')
              database:del('lang:gp:'..msg.chat_id_)
            end
          end
          if langs[2] == "en" or langs[2] == "انگلیسی" then
            if database:get('lang:gp:'..msg.chat_id_) then
              send(msg.chat_id_, msg.id_, 1, '> *Bot Lang Is Already En*!', 1, 'md')
            else
              send(msg.chat_id_, msg.id_, 1, '_> Bot Lang Changed To_ : *En*!', 1, 'md')
              database:set('lang:gp:'..msg.chat_id_,true)
            end
          end
        end
-----------------------------------------------------------------------------------------------
    if text:match("^[#!/]id @(.*)$") then
	local ap = {string.match(text, "^[#/!](id) @(.*)$")}
	function id_by_username(extra, result, success)
	if result.id_ then
	if is_sudo(result) then
	  t = 'Sudo'
      elseif is_admin(result.id_) then
	  t = 'Global Admin'
      elseif is_owner(result.id_, msg.chat_id_) then
	  t = 'Group Owner'
      elseif is_mod(result.id_, msg.chat_id_) then
	  t = 'Moderator'
      else
	  t = 'Member'
	  end
            texts = '*Username* : `@'..ap[2]..'`\n*Your ID* : `('..result.id_..')`\n*Your Rank* : `'..t..'`'
            else
            texts = '*UserName InCorrect!*'
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'md')
    end
	      resolve_username(ap[2],id_by_username)
    end
    -----------------------------------------------------------------------------------------------
 if text:match("^[#!/]kick$") or text:match("^[#!/]block$") or text:match("^[#!/]k$") or text:match("^[#!/]b$") and msg.reply_to_message_id_ and is_mod(msg.sender_user_id_, msg.chat_id_) then
      function kick_reply(extra, result, success)
	if is_mod(result.sender_user_id_, result.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Cant Ban|Kick Admins!*', 1, 'md')
    else
        send(msg.chat_id_, msg.id_, 1, '*User* `|'..result.sender_user_id_..'|` *Blocked|Kicked!*', 1, 'md')
        chat_kick(result.chat_id_, result.sender_user_id_)
        end
	end
   getMessage(msg.chat_id_,msg.reply_to_message_id_,kick_reply)
    end
    -----------------------------------------------------------------------------------------------
  if text:match("^[#!/]inv$") and msg.reply_to_message_id_ and is_sudo(msg) then
      function inv_reply(extra, result, success)
           add_user(result.chat_id_, result.sender_user_id_, 5)
        end
   getMessage(msg.chat_id_, msg.reply_to_message_id_,inv_reply)
    end
	-----------------------------------------------------------------------------------------------
    if text:match("^[#!/]id$") and msg.reply_to_message_id_ == 0  then
    local user_msgs = database:get('user:msgs'..msg.chat_id_..':'..msg.sender_user_id_)
	if is_sudo(msg) then
	  t = 'Sudo'
      elseif is_admin(msg) then
	  t = 'Global Admin'
      elseif is_owner(msg.sender_user_id_, msg.chat_id_) then
	  t = 'Group Owner'
      elseif is_mod(msg.sender_user_id_, msg.chat_id_) then
	  t = 'Moderator'
      else
	  t = 'Member'
	end
      send(msg.chat_id_, msg.id_, 1, "> *SuperGroup ID* : `"..msg.chat_id_.."`\n> *Your ID*: `"..msg.sender_user_id_.."`\n> *Total Messages*: `"..user_msgs.."`\n> *Rank*: `"..t.."`", 1, 'md')
	end
	-----------------------------------------------------------------------------------------------
    if text:match("^[#!/]getpro (%d+)$") and msg.reply_to_message_id_ == 0  then
		local pronumb = {string.match(text, "^[#/!](getpro) (%d+)$")}
local function gpro(extra, result, success)
--vardump(result)
   if pronumb[2] == '1' then
   if result.photos_[0] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[0].sizes_[1].photo_.persistent_id_)
   else
      send(msg.chat_id_, msg.id_, 1, "*You Have'nt Profile Photo!!*", 1, 'md')
   end
   elseif pronumb[2] == '2' then
   if result.photos_[1] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[1].sizes_[1].photo_.persistent_id_)
   else
      send(msg.chat_id_, msg.id_, 1, "*You Have'nt 2 Profile Photo!!*", 1, 'md')
   end
   elseif pronumb[2] == '3' then
   if result.photos_[2] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[2].sizes_[1].photo_.persistent_id_)
   else
      send(msg.chat_id_, msg.id_, 1, "*You Have'nt 3 Profile Photo!!*", 1, 'md')
   end
   elseif pronumb[2] == '4' then
      if result.photos_[3] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[3].sizes_[1].photo_.persistent_id_)
   else
      send(msg.chat_id_, msg.id_, 1, "*You Have'nt 4 Profile Photo!!*", 1, 'md')
   end
   elseif pronumb[2] == '5' then
   if result.photos_[4] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[4].sizes_[1].photo_.persistent_id_)
   else
      send(msg.chat_id_, msg.id_, 1, "*You Have'nt 5 Profile Photo!!*", 1, 'md')
   end
   elseif pronumb[2] == '6' then
   if result.photos_[5] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[5].sizes_[1].photo_.persistent_id_)
   else
      send(msg.chat_id_, msg.id_, 1, "*You Have'nt 6 Profile Photo!!*", 1, 'md')
   end
   elseif pronumb[2] == '7' then
   if result.photos_[6] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[6].sizes_[1].photo_.persistent_id_)
   else
      send(msg.chat_id_, msg.id_, 1, "*You Have'nt 7 Profile Photo!!*", 1, 'md')
   end
   elseif pronumb[2] == '8' then
   if result.photos_[7] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[7].sizes_[1].photo_.persistent_id_)
   else
      send(msg.chat_id_, msg.id_, 1, "*You Have'nt 8 Profile Photo!!*", 1, 'md')
   end
   elseif pronumb[2] == '9' then
   if result.photos_[8] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[8].sizes_[1].photo_.persistent_id_)
   else
      send(msg.chat_id_, msg.id_, 1, "*You Have'nt 9 Profile Photo!!*", 1, 'md')
   end
   elseif pronumb[2] == '10' then
   if result.photos_[9] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[9].sizes_[1].photo_.persistent_id_)
   else
      send(msg.chat_id_, msg.id_, 1, "*You Have'nt 10 Profile Photo!!*", 1, 'md')
   end
   else
      send(msg.chat_id_, msg.id_, 1, "*I just can get last 10 profile photos!:(*", 1, 'md')
   end
   end
   tdcli_function ({
    ID = "GetUserProfilePhotos",
    user_id_ = msg.sender_user_id_,
    offset_ = 0,
    limit_ = pronumb[2]
  }, gpro, nil)
	end
	-----------------------------------------------------------------------------------------------
  local text = msg.content_.text_:gsub('lock','l')
	if text:match("^[#!/]lock (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local lockpt = {string.match(text, "^[#/!](lock) (.*)$")}
    --[[  if lockpt[2] == "edit" then
         send(msg.chat_id_, msg.id_, 1, '*Now, Members Cant Edit Messages!*', 1, 'md')
         database:set('editmsg'..msg.chat_id_,'delmsg')
	  end]]
	  if lockpt[2] == "cmds" then
         send(msg.chat_id_, msg.id_, 1, '> *Bot Cmds Locked!*\n', 1, 'md')
         database:set('bot:cmds'..msg.chat_id_,true)
      end
	  if lockpt[2] == "bots" then
         send(msg.chat_id_, msg.id_, 1, '> *Bots Join Has Been Locked!*', 1, 'md')
         database:set('bot:bots:mute'..msg.chat_id_,true)
      end
	  if lockpt[2] == "flood" then
         send(msg.chat_id_, msg.id_, 1, '*Flood Has Been Locked!*', 1, 'md')
         database:del('anti-flood:'..msg.chat_id_)
	  end
	  if lockpt[2] == "pin" then
         send(msg.chat_id_, msg.id_, 1, "*Now, Your Admin's Cant Pin Messages!*", 1, 'md')
	     database:set('bot:pin:mute'..msg.chat_id_,true)
      end
	end
	-----------------------------------------------------------------------------------------------
 local text = msg.content_.text_:gsub('setflood','sf')
if text:match("^[#!/]setflood (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local floodmax = {string.match(text, "^[#/!](setflood) (%d+)$")}
	if tonumber(floodmax[2]) < 2 then
         send(msg.chat_id_, msg.id_, 1, '*Your Number So Low!*\n`Minimum:` *2*', 1, 'md')
	else
    database:set('flood:max:'..msg.chat_id_,floodmax[2])
         send(msg.chat_id_, msg.id_, 1, '> > *Sensitivity Set to :* `'..floodmax[2]..'`.', 1, 'md')
	end
	end
	-----------------------------------------------------------------------------------------------
  local text = msg.content_.text_:gsub('setfloodtime','sft')
	if text:match("^[#!/]setfloodtime (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local floodt = {string.match(text, "^[#/!](setfloodtime) (%d+)$")}
	if tonumber(floodt[2]) < 2 then
         send(msg.chat_id_, msg.id_, 1, '`Error.`\n*Your Number So Low!*\n`Minimum:` *2*', 1, 'md')
	else
    database:set('flood:time:'..msg.chat_id_,floodt[2])
         send(msg.chat_id_, msg.id_, 1, '> *Flood Time Set to :* `'..floodt[2]..'`.', 1, 'md')
	end
	end
	-----------------------------------------------[Lock - Edit]------------------------------------------------
	if text:match("^[#!/]lock edit$") or text:match("^[#!/]l edit$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Edit Has Been Locked!*', 1, 'md')
         database:set('editmsg'..msg.chat_id_,'didam')
	end
	------------------------------------------[Unlock - Edit]-----------------------------------------------------
	if text:match("^[#!/]ul edit$") or text:match("^[#!/]unlock edit$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Edit Has Been UnLocked!*', 1, 'md')
         database:del('editmsg'..msg.chat_id_,'didam')
	end
	-----------------------------------------------------------------------------------------------
if text:match("^[#!/]setlink$") or text:match("^[#!/]sl$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Now, Send Me GroupLink!*', 1, 'md')
         database:set("bot:group:link"..msg.chat_id_, 'Send Your GroupLink')
	end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]link$") or text:match("^[#!/]l$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local link = database:get("bot:group:link"..msg.chat_id_)
	  if link then
         send(msg.chat_id_, msg.id_, 1, '*GroupLink:* \n'..link, 1, 'md')
	  else
         send(msg.chat_id_, msg.id_, 1, '_Bot Is Not Group_ *Creator*.\n*You Can Set Link By* /setlink *Command!*', 1, 'md')
	  end
 	end

	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]welcome on$") or text:match("^[#!/]w on$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '> Welcome *Enabled* In This Supergroup!', 1, 'md')
		 database:set("bot:welcome"..msg.chat_id_,true)
	end
	if text:match("^[#!/]welcome off$") or text:match("^[#!/]w off$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '> Welcome *Disabled* In This Supergroup!', 1, 'md')
		 database:del("bot:welcome"..msg.chat_id_)
	end
    local text = msg.content_.text_:gsub('set welcome','sw')
	if text:match("^[#!/]set welcome (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local welcome = {string.match(text, "^[#/!](set welcome) (.*)$")}
         send(msg.chat_id_, msg.id_, 1, '*Welcome Msg Has Been Saved!*\nWlc Text:\n\n`'..welcome[2]..'`', 1, 'md')
		 database:set('welcome:'..msg.chat_id_,welcome[2])
	end
	if text:match("^[#!/]del welcome$") or text:match("^[#!/]dw$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Welcome Msg Has Been Deleted!*', 1, 'md')
		 database:del('welcome:'..msg.chat_id_)
	end
	if text:match("^[#!/]get welcome$") or text:match("^[#!/]gw$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local wel = database:get('welcome:'..msg.chat_id_)
	if wel then
         send(msg.chat_id_, msg.id_, 1, wel, 1, 'md')
    else
         send(msg.chat_id_, msg.id_, 1, '*Welcome msg not saved!*', 1, 'md')
	end
	end
	-----------------------------------------------------------------------------------------------
      local text = msg.content_.text_:gsub('action','a')
	if text:match("^[#!/]action (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local lockpt = {string.match(text, "^[#/!](action) (.*)$")}
      if lockpt[2] == "typing" or "ty" then
          sendaction(msg.chat_id_, 'Typing')
	  end
	  if lockpt[2] == "video" or "vi" then
          sendaction(msg.chat_id_, 'RecordVideo')
	  end
	  if lockpt[2] == "voice" or "vo" then
          sendaction(msg.chat_id_, 'RecordVoice')
	  end
	  if lockpt[2] == "photo" or "ph" then
          sendaction(msg.chat_id_, 'UploadPhoto')
	  end
	end
	-----------------------------------------------------------------------------------------------
  local text = msg.content_.text_:gsub('filter','f')
	if text:match("^[#!/]filter (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local filters = {string.match(text, "^[#/!](filter) (.*)$")}
    local name = string.sub(filters[2], 1, 50)
          database:hset('bot:filters:'..msg.chat_id_, name, 'filtered')
		  send(msg.chat_id_, msg.id_, 1, "*New Word Filtered!*\n> `"..name.."`", 1, 'md')
	end
	-----------------------------------------------------------------------------------------------
  local text = msg.content_.text_:gsub('rw','uf')
	if text:match("^[#!/]rw (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local rws = {string.match(text, "^[#/!](rw) (.*)$")}
    local name = string.sub(rws[2], 1, 50)
          database:hdel('bot:filters:'..msg.chat_id_, rws[2])
		  send(msg.chat_id_, msg.id_, 1, "`"..rws[2].."` *Removed From Filtered List!*", 1, 'md')
	end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]filterlist$") or text:match("^[!/#]fl$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local hash = 'bot:filters:'..msg.chat_id_
      if hash then
         local names = database:hkeys(hash)
         local text = '*Filtered Words :*\n\n'
    for i=1, #names do
      text = text..'> `'..names[i]..'`\n'
    end
	if #names == 0 then
       text = "*Filter List is Empty*"
    end
		  send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
       end
    end
	-----------------------------------------------------------------------------------------------
  local text = msg.content_.text_:gsub('broadcast','bc')
	if text:match("^[#!/]broadcast (.*)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
    local gps = database:scard("bot:groups") or 0
    local gpss = database:smembers("bot:groups") or 0
	local rws = {string.match(text, "^[#/!](broadcast) (.*)$")}
	for i=1, #gpss do
		  send(gpss[i], 0, 1, rws[2], 1, 'md')
    end
                   send(msg.chat_id_, msg.id_, 1, '*Your Msg Send to* `|'..gps..'|` *Groups*!', 1, 'md')
	end
	-----------------------------------------------------------------------------------------------
if text:match("^[#!/]stats$") or text:match("^[#!/]st$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
    local gps = database:scard("bot:groups")
	local users = database:scard("bot:userss")
    local allmgs = database:get("bot:allmsgs")
    if database:get('autoleave') == "yes" then
            autoleave = "Yes"
          elseif database:get('autoleave') == "no" then
            autoleave = "No"
          elseif not database:get('autoleave') then
            autoleave = "No"
          end
                   send(msg.chat_id_, msg.id_, 1, '*Stats:*\n\n> *Groups*:  `'..gps..'`\n> *Users*:  `'..users..'`\n> *All Recieved Msgs*:  `'..allmgs..'`\n> *AutoLeave*:  `'..autoleave..'`', 1, 'md')
	end
	-----------------------------------------------------------------------------------------------
  local text = msg.content_.text_:gsub('unlock','ul')
if text:match("^[#!/]unlock (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local unlockpt = {string.match(text, "^[#/!](unlock) (.*)$")}
  --[[    if unlockpt[2] == "edit" then
       send(msg.chat_id_, msg.id_, 1, '*Now, Members Allowed to Edit Msgs!*', 1, 'md')
         database:del('editmsg'..msg.chat_id_)
      end]]
	  if unlockpt[2] == "cmds" then
         send(msg.chat_id_, msg.id_, 1, '*Bots Cmd Allowed For Members!*', 1, 'md')
         database:del('bot:cmds'..msg.chat_id_)
      end
	  if unlockpt[2] == "bots" then
         send(msg.chat_id_, msg.id_, 1, '*Bots Join Has Been Allowed!*', 1, 'md')
         database:del('bot:bots:mute'..msg.chat_id_)
      end
	  if unlockpt[2] == "flood" then
         send(msg.chat_id_, msg.id_, 1, '*Flood Has Been Allowed!*', 1, 'md')
         database:set('anti-flood:'..msg.chat_id_,true)
	  end
	  if unlockpt[2] == "pin" then
         send(msg.chat_id_, msg.id_, 1, "*Now, Admins Allowed to Pin Message's!*", 1, 'md')
	     database:del('bot:pin:mute'..msg.chat_id_)
      end
    end
	-----------------------------------------------------------------------------------------------
  local text = msg.content_.text_:gsub('mute all','mua')
  	 	if text:match("^[#!/]mute all (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local mutept = {string.match(text, "^[#!/]mute all (%d+)$")}
	    		database:setex('bot:muteall'..msg.chat_id_, tonumber(mutept[1]), true)
         send(msg.chat_id_, msg.id_, 1, '*Group Muted For* `'..mutept[1]..'` *Seconds!*', 1, 'md')
	end
	-----------------------------------------------------------------------------------------------
  local text = msg.content_.text_:gsub('lock','l')
  		if text:match("^[#!/]lock (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local mutept = {string.match(text, "^[#/!](lock) (.*)$")}
      if mutept[2] == "all" then
         send(msg.chat_id_, msg.id_, 1, '*All Items Has Been Locked!*', 1, 'md')
						database:set('bot:muteall'..msg.chat_id_,true)
      end
	  if mutept[2] == "text" then
         send(msg.chat_id_, msg.id_, 1, '*Texts Has Been Locked!*', 1, 'md')
						database:set('bot:text:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "inline" then
         send(msg.chat_id_, msg.id_, 1, '*Inline Keyboard Has Been Locked!*', 1, 'md')
						database:set('bot:inline:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "photo" then
         send(msg.chat_id_, msg.id_, 1, '*Photo Send Has Been Locked!*', 1, 'md')
						database:set('bot:photo:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "video" then
         send(msg.chat_id_, msg.id_, 1, '*Video Has Been Locked!*', 1, 'md')
						database:set('bot:video:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "gifs" then
         send(msg.chat_id_, msg.id_, 1, '*Gifs Has Been Locked!*', 1, 'md')
						database:set('bot:gifs:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "music" then
         send(msg.chat_id_, msg.id_, 1, '*Music Has Been Locked!*', 1, 'md')
						database:set('bot:music:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "voice" then
         send(msg.chat_id_, msg.id_, 1, '*Voice Has Been Locked!*', 1, 'md')
						database:set('bot:voice:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "links" then
         send(msg.chat_id_, msg.id_, 1, '*Links Has Been Locked!*', 1, 'md')
						database:set('bot:links:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "location" then
         send(msg.chat_id_, msg.id_, 1, '*Location Has Been Locked!*', 1, 'md')
						database:set('bot:location:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "username" then
         send(msg.chat_id_, msg.id_, 1, '*Username Has Been Locked!*', 1, 'md')
						database:set('bot:tag:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "tag" then
         send(msg.chat_id_, msg.id_, 1, '*Tag Has Been Locked!*', 1, 'md')
						database:set('bot:hashtag:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "contact" then
         send(msg.chat_id_, msg.id_, 1, '*Contact Share Has Been Locked!*', 1, 'md')
						database:set('bot:contact:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "webpage" then
         send(msg.chat_id_, msg.id_, 1, '*Webpage Has Been Locked!*', 1, 'md')
						database:set('bot:webpage:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "arabic" then
         send(msg.chat_id_, msg.id_, 1, '*Arabic Has Been Locked!*', 1, 'md')
						database:set('bot:arabic:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "english" then
         send(msg.chat_id_, msg.id_, 1, '*English Has Been Locked!*', 1, 'md')
						database:set('bot:english:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "sticker" then
         send(msg.chat_id_, msg.id_, 1, '*Sticker Has Been Locked!*', 1, 'md')
						database:set('bot:sticker:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "service" then
         send(msg.chat_id_, msg.id_, 1, '*TGservice Msgs Has Been Locked!*', 1, 'md')
						database:set('bot:tgservice:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "forward" then
         send(msg.chat_id_, msg.id_, 1, '*Forward Has Been Locked!*', 1, 'md')
						database:set('bot:forward:mute'..msg.chat_id_,true)
      end
	end
	-----------------------------------------------------------------------------------------------
  local text = msg.content_.text_:gsub('unlock','ul')
  	if text:match("^[#!/]unlock (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local unmutept = {string.match(text, "^[#/!](unlock) (.*)$")}
      if unmutept[2] == "all" then
         send(msg.chat_id_, msg.id_, 1, '*All Items Has Been Allowed!*', 1, 'md')
         database:del('bot:muteall'..msg.chat_id_)
      end
	  if unmutept[2] == "text" then
         send(msg.chat_id_, msg.id_, 1, '*Texts Has Been Allowed!*', 1, 'md')
         database:del('bot:text:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "photo" then
         send(msg.chat_id_, msg.id_, 1, '*Photo Has Been Allowed!*', 1, 'md')
         database:del('bot:photo:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "video" then
         send(msg.chat_id_, msg.id_, 1, '*Video Has Been Allowed!*', 1, 'md')
         database:del('bot:video:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "inline" then
         send(msg.chat_id_, msg.id_, 1, '*Inline keyboard Has Been Allowed!*', 1, 'md')
         database:del('bot:inline:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "gifs" then
         send(msg.chat_id_, msg.id_, 1, '*Gif Send Has Been Allowed!*', 1, 'md')
         database:del('bot:gifs:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "music" then
         send(msg.chat_id_, msg.id_, 1, '*Music Has Been Allowed!*', 1, 'md')
         database:del('bot:music:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "voice" then
         send(msg.chat_id_, msg.id_, 1, '*Voice Record Has Been Allowed!*', 1, 'md')
         database:del('bot:voice:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "links" then
         send(msg.chat_id_, msg.id_, 1, '*Link Send Has Been Allowed!*', 1, 'md')
         database:del('bot:links:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "location" then
         send(msg.chat_id_, msg.id_, 1, '*Location Has Been Allowed!*', 1, 'md')
         database:del('bot:location:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "username" then
         send(msg.chat_id_, msg.id_, 1, '*Username Has Been Allowed!*', 1, 'md')
         database:del('bot:tag:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "tag" then
         send(msg.chat_id_, msg.id_, 1, '*Tag Has Been Allowed!*', 1, 'md')
         database:del('bot:hashtag:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "contact" then
         send(msg.chat_id_, msg.id_, 1, '*Contact Has Been Allowed!*', 1, 'md')
         database:del('bot:contact:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "webpage" then
         send(msg.chat_id_, msg.id_, 1, '*Webpage Has Been Allowed!*', 1, 'md')
         database:del('bot:webpage:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "arabic" then
         send(msg.chat_id_, msg.id_, 1, '*Arabic Has Been Allowed!*', 1, 'md')
         database:del('bot:arabic:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "english" then
         send(msg.chat_id_, msg.id_, 1, '*English Has Been Allowed!*', 1, 'md')
         database:del('bot:english:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "service" then
         send(msg.chat_id_, msg.id_, 1, '*TGservice Msgs Has Been Allowed!*', 1, 'md')
         database:del('bot:tgservice:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "sticker" then
         send(msg.chat_id_, msg.id_, 1, '*Sticker Send Has Been Allowed!*', 1, 'md')
         database:del('bot:sticker:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "forward" then
         send(msg.chat_id_, msg.id_, 1, '*Forward Has Been Allowed!*', 1, 'md')
         database:del('bot:forward:mute'..msg.chat_id_)
      end
	end
	-----------------------------------------------------------------------------------------------
  local text = msg.content_.text_:gsub('edit','e')
  	if text:match("^[#!/]edit (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local editmsg = {string.match(text, "^[#/!](edit) (.*)$")}
		 edit(msg.chat_id_, msg.reply_to_message_id_, nil, editmsg[2], 1, 'md')
    end
	-----------------------------------------------------------------------------------------------
    if text:match('^[!/#]update') or text:match('^[!/#]u') and is_sudo(msg) then
          local s = io.popen("git pull")
          local text = ( s:read("*a") )
          send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
        end
       -----------------------------------------------------------------------------------------------
       local text = msg.content_.text_:gsub('clean','c')
  	if text:match("^[#!/]clean (.*)$") then
	local txt = {string.match(text, "^[#/!](clean) (.*)$")}
       if txt[2] == 'banlist' then
	      database:del('bot:banned:'..msg.chat_id_)
          send(msg.chat_id_, msg.id_, 1, '_> Banlist has been_ *Cleaned*', 1, 'md')
       end
	   if txt[2] == 'bots' and is_mod(msg.sender_user_id_, msg.chat_id_) then
	  local function g_bots(extra,result,success)
      local bots = result.members_
      for i=0 , #bots do
          chat_kick(msg.chat_id_,bots[i].user_id_)
          end
      end
    channel_get_bots(msg.chat_id_,g_bots)
	          send(msg.chat_id_, msg.id_, 1, '*> All bots* *Kicked!*', 1, 'md')
	end
	   if txt[2] == 'modlist' and is_owner(msg.sender_user_id_, msg.chat_id_) then
	      database:del('bot:mods:'..msg.chat_id_)
          send(msg.chat_id_, msg.id_, 1, '*> Modlist has been* *Cleaned*', 1, 'md')
   end
	  if txt[2] == 'gbanlist' and is_sudo(msg) then
	      database:del('bot:gbanned'..msg.chat_id_)
          send(msg.chat_id_, msg.id_, 1, '*> GBanList has been* *Cleaned*', 1, 'md')
       end
	   if txt[2] == 'filterlist' and is_mod(msg.sender_user_id_, msg.chat_id_) then
	      database:del('bot:filters:'..msg.chat_id_)
          send(msg.chat_id_, msg.id_, 1, '*> Filterlist has been* *Cleaned*', 1, 'md')
       end
	   if txt[2] == 'mutelist' and is_mod(msg.sender_user_id_, msg.chat_id_) then
	      database:del('bot:muted:'..msg.chat_id_)
          send(msg.chat_id_, msg.id_, 1, '*> Mutelist has been* *Cleaned*', 1, 'md')
       end
    end
	-----------------------------------------------------------------------------------------------
   	if text:match("^[#!/]settings$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	if database:get('bot:muteall'..msg.chat_id_) then
	mute_all = 'Locked'
	else
	mute_all = 'Allowed'
	end
	------------
	if database:get('bot:text:mute'..msg.chat_id_) then
	mute_text = 'Locked'
	else
	mute_text = 'Allowed'
	end
	------------
	if database:get('bot:photo:mute'..msg.chat_id_) then
	mute_photo = 'Locked'
	else
	mute_photo = 'Allowed'
	end
	------------
	if database:get('bot:video:mute'..msg.chat_id_) then
	mute_video = 'Locked'
	else
	mute_video = 'Allowed'
	end
	------------
	if database:get('bot:gifs:mute'..msg.chat_id_) then
	mute_gifs = 'Locked'
	else
	mute_gifs = 'Allowed'
	end
	------------
	if database:get('anti-flood:'..msg.chat_id_) then
	mute_flood = 'Allowed'
	else
	mute_flood = 'Locked'
	end
	------------
	if not database:get('flood:max:'..msg.chat_id_) then
	flood_m = 5
	else
	flood_m = database:get('flood:max:'..msg.chat_id_)
	end
	------------
	if not database:get('flood:time:'..msg.chat_id_) then
	flood_t = 3
	else
	flood_t = database:get('flood:time:'..msg.chat_id_)
	end
	------------
	if database:get('bot:music:mute'..msg.chat_id_) then
	mute_music = 'Locked'
	else
	mute_music = 'Allowed'
	end
	------------
	if database:get('bot:bots:mute'..msg.chat_id_) then
	mute_bots = 'Locked'
	else
	mute_bots = 'Allowed'
	end
	------------
	if database:get('bot:inline:mute'..msg.chat_id_) then
	mute_in = 'Locked'
	else
	mute_in = 'Allowed'
	end
	------------
	if database:get('bot:cmds'..msg.chat_id_) then
	mute_cmd = 'Off'
	else
	mute_cmd = 'On'
	end
	------------
	if database:get('bot:voice:mute'..msg.chat_id_) then
	mute_voice = 'Locked'
	else
	mute_voice = 'Allowed'
	end
	------------
	if database:get('editmsg'..msg.chat_id_) then
	mute_edit = 'Locked'
	else
	mute_edit = 'Allowed'
	end
    ------------
	if database:get('bot:links:mute'..msg.chat_id_) then
	mute_links = 'Locked'
	else
	mute_links = 'Allowed'
	end
    ------------
	if database:get('bot:pin:mute'..msg.chat_id_) then
	lock_pin = 'Locked'
	else
	lock_pin = 'Allowed'
	end
    ------------
	if database:get('bot:sticker:mute'..msg.chat_id_) then
	lock_sticker = 'Locked'
	else
	lock_sticker = 'Allowed'
	end
	------------
    if database:get('bot:tgservice:mute'..msg.chat_id_) then
	lock_tgservice = 'Locked'
	else
	lock_tgservice = 'Allowed'
	end
	------------
    if database:get('bot:webpage:mute'..msg.chat_id_) then
	lock_wp = 'Locked'
	else
	lock_wp = 'Allowed'
	end
	------------
    if database:get('bot:hashtag:mute'..msg.chat_id_) then
	lock_htag = 'Locked'
	else
	lock_htag = 'Allowed'
	end
	------------
    if database:get('bot:tag:mute'..msg.chat_id_) then
	lock_tag = 'Locked'
	else
	lock_tag = 'Allowed'
	end
	------------
    if database:get('bot:location:mute'..msg.chat_id_) then
	lock_location = 'Locked'
	else
	lock_location = 'Allowed'
	end
	------------
    if database:get('bot:contact:mute'..msg.chat_id_) then
	lock_contact = 'Locked'
	else
	lock_contact = 'Allowed'
	end
	------------
    if database:get('bot:english:mute'..msg.chat_id_) then
	lock_english = 'Locked'
	else
	lock_english = 'Allowed'
	end
	------------
    if database:get('bot:arabic:mute'..msg.chat_id_) then
	lock_arabic = 'Locked'
	else
	lock_arabic = 'Allowed'
	end
	------------
    if database:get('bot:forward:mute'..msg.chat_id_) then
	lock_forward = 'Locked'
	else
	lock_forward = 'Allowed'
	end
	------------
	if database:get("bot:welcome"..msg.chat_id_) then
	send_welcome = 'Enable'
	else
	send_welcome = 'Disable'
	end
	------------
	local ex = database:ttl("bot:charge:"..msg.chat_id_)
                if ex == -1 then
				exp_dat = 'Unlimited'
				else
				exp_dat = math.floor(ex / 86400) + 1
			    end
 	------------
	local TXT = ">*Settings:*\n\n"
	          .."|*Welcome*> `"..send_welcome.."`\n"
	          .."|*Sticker* > `"..lock_sticker.."`\n"
	          .."|*Tgservice* > `"..lock_tgservice.."`\n"
	          .."|*Links* > `"..mute_links.."`\n"
	          .."|*Site Addres* > `"..lock_wp.."`\n"
	          .."|*Username* > `"..lock_tag.."`\n"
	          .."|*[#] Status* > `"..lock_htag.."`\n"
	          .."|*Contacts *> `"..lock_contact.."`\n"
	          .."|*English* > `"..lock_english.."`\n"
	          .."|*Location* > `"..lock_location.."`\n"
	          .."|*Bots * > `"..mute_bots.."`\n"
	          .."|*Inline Msg's* > `"..mute_in.."`\n"
	          .."|*Persian *> `"..lock_arabic.."`\n"
	          .."|*Fwd Status* > `"..lock_forward.."`\n"
	          .."|*Edit Msg's *> `"..mute_edit.."`\n"
	          .."|*Pin Msg's *> `"..lock_pin.."`\n"
	          .."|*Flood *> `"..mute_flood.."`\n"
	          .."|*Flood Sensitivity* > `"..flood_m.."`\n"
	          .."|*Flood Time* > `"..flood_t.."`\n"
		  .."|*Bot Cmd's* > `"..mute_cmd.."`\n"
		  .."|*Expire *> `"..exp_dat.."`\n"
	          .."________________________\n"
	          .."|*Mute All* > `"..mute_all.."`\n"
	          .."|*Mute Texts* > `"..mute_text.."`\n"
	          .."|*Mute Photos* > `"..mute_photo.."`\n"
	          .."|*Mute Videos* > `"..mute_video.."`\n"
	          .."|*Mute Gifs* > `"..mute_gifs.."`\n"
	          .."|*Mute Audio|Music *> `"..mute_music.."`\n"
	          .."|*Mute Voice* > `"..mute_voice.."`\n"
		  .."________________________\n"
	          .."|*Version : 4.0*\n"
	          .."|*Dev By* @MrBlackLife|\n"
         send(msg.chat_id_, msg.id_, 1, TXT, 1, 'md')
    end
	-----------------------------------------------------------------------------------------------
  local text = msg.content_.text_:gsub('echo','ec')
  	if text:match("^[#!/]echo (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local txt = {string.match(text, "^[#/!](echo) (.*)$")}
         send(msg.chat_id_, msg.id_, 1, txt[2], 1, 'md')
    end
	-----------------------------------------------------------------------------------------------
  local text = msg.content_.text_:gsub('leave','le')
          if text:match("^[!/#][Ll]eave$") and is_sudo(msg) then
            chat_leave(msg.chat_id_, bot_id)
            database:srem("bot:groups",msg.chat_id_)
        end
 	-----------------------------------------------------------------------------------------------
  local text = msg.content_.text_:gsub('setrules','sr')
    	if text:match("^[#!/]setrules (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local txt = {string.match(text, "^[#/!](setrules) (.*)$")}
	database:set('bot:rules'..msg.chat_id_, txt[2])
         send(msg.chat_id_, msg.id_, 1, '*Group Rules Set!*', 1, 'md')
    end
	-----------------------------------------------------------------------------------------------
  local text = msg.content_.text_:gsub('rules','r')
  	if text:match("^[#!/]rules$") then
	local rules = database:get('bot:rules'..msg.chat_id_)
         send(msg.chat_id_, msg.id_, 1, rules, 1, nil)
    end
	-----------------------------------------------------------------------------------------------
  	if text:match("^[#!/]share$") or text:match("^[!/#]sh$") then
       sendContact(msg.chat_id_, msg.id_, 0, 1, nil, 14433047824, 'SpheroTc', 'Update!', 323370170)
    end
	-----------------------------------------------------------------------------------------------
  local text = msg.content_.text_:gsub('sn','setname')
	if text:match("^[#!/]setname (.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local txt = {string.match(text, "^[#/!](setname) (.*)$")}
	     changetitle(msg.chat_id_, txt[2])
         send(msg.chat_id_, msg.id_, 1, '*Group Name Updated!*_', 1, 'md')
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]getme$") then
	function guser_by_reply(extra, result, success)
         --vardump(result)
    end
	     getUser(msg.sender_user_id_,guser_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]setphoto$") or text:match("^[#!/]sp$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_Please send a photo now!_', 1, 'md')
		 database:set('bot:setphoto'..msg.chat_id_..':'..msg.sender_user_id_,true)
    end
	-----------------------------------------------------------------------------------------------
  local text = msg.content_.text_:gsub('charge','setexpire')
  local text = msg.content_.text_:gsub('charge','se')
  local text = msg.content_.text_:gsub('charge','c')
	if text:match("^[#!/]charge (%d+)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
		local a = {string.match(text, "^[#/!](charge) (%d+)$")}
         send(msg.chat_id_, msg.id_, 1, '*Group Charged for *`|'..a[2]..'|`* Days*', 1, 'md')
		 local time = a[2] * day
         database:setex("bot:charge:"..msg.chat_id_,time,true)
		 database:set("bot:enable:"..msg.chat_id_,true)
    end
	-----------------------------------------------------------------------------------------------
local text = msg.content_.text_:gsub('charge stats','expire')
local text = msg.content_.text_:gsub('charge stats','cst')
	if text:match("^[#!/]charge stats") and is_mod(msg.sender_user_id_, msg.chat_id_) then
    local ex = database:ttl("bot:charge:"..msg.chat_id_)
       if ex == -1 then
		send(msg.chat_id_, msg.id_, 1, '*Infinity!*', 1, 'md')
       else
        local d = math.floor(ex / day ) + 1
	   		send(msg.chat_id_, msg.id_, 1, "`"..d.."` *Later!*", 1, 'md')
       end
    end
	-----------------------------------------------------------------------------------------------
  local text = msg.content_.text_:gsub('charge stats','expire')
local text = msg.content_.text_:gsub('charge stats','cst')
	if text:match("^[#!/]charge stats (%d+)") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	local txt = {string.match(text, "^[#/!](charge stats) (%d+)$")}
    local ex = database:ttl("bot:charge:"..txt[2])
       if ex == -1 then
		send(msg.chat_id_, msg.id_, 1, '*Infinity!*', 1, 'md')
       else
        local d = math.floor(ex / day ) + 1
	   		send(msg.chat_id_, msg.id_, 1, "`"..d.."` *Later!*", 1, 'md')
       end
    end
	-----------------------------------------------------------------------------------------------
	 if is_sudo(msg) then
  -----------------------------------------------------------------------------------------------
  local text = msg.content_.text_:gsub('leave','l')
  if text:match("^[#!/]leave_(-%d+)") and is_admin(msg.sender_user_id_, msg.chat_id_) then
  	local txt = {string.match(text, "^[#/!](leave)(-%d+)$")}
	   send(msg.chat_id_, msg.id_, 1, '*Bot Succefulli Leaved From >* `|'..txt[2]..'|` *=)*', 1, 'md')
	   send(txt[2], 0, 1, 'ربات ب دلایلی از گروه خارج میشود برای اطلاعات بیشتر ب یکی از دو ایدی زیر مراجعه کنید\n@MrBlacklife\n@niyazrobo', 1, 'html')
	   chat_leave(txt[2], bot_id)
  end
  -----------------------------------------------------------------------------------------------
  local text = msg.content_.text_:gsub('plan','p')
  if text:match('^[#!/]plan1(-%d+)') and is_admin(msg.sender_user_id_, msg.chat_id_) then
       local txt = {string.match(text, "^[#/!](plan1)(-%d+)$")}
       local timeplan1 = 2592000
       database:setex("bot:charge:"..txt[2],timeplan1,true)
	   send(msg.chat_id_, msg.id_, 1, 'پلن 1 با موفقیت برای گروه '..txt[2]..' فعال شد\nاین گروه تا 30 روز دیگر اعتبار دارد! ( 1 ماه )', 1, 'md')
	   send(txt[2], 0, 1, 'ربات با موفقیت فعال شد و تا 30 روز دیگر اعتبار دارد!', 1, 'md')
	   for k,v in pairs(sudo_users) do
	      send(v, 0, 1, "*User"..msg.sender_user_id_.." Added bot to new group*" , 1, 'md')
       end
	   database:set("bot:enable:"..txt[2],true)
  end
  -----------------------------------------------------------------------------------------------
  local text = msg.content_.text_:gsub('plan','p')
  if text:match('^[#!/]plan2(-%d+)') and is_admin(msg.sender_user_id_, msg.chat_id_) then
       local txt = {string.match(text, "^[#/!](plan2)(-%d+)$")}
       local timeplan2 = 7776000
       database:setex("bot:charge:"..txt[2],timeplan2,true)
	   send(msg.chat_id_, msg.id_, 1, 'پلن 2 با موفقیت برای گروه '..txt[2]..' فعال شد\nاین گروه تا 90 روز دیگر اعتبار دارد! ( 3 ماه )', 1, 'md')
	   send(txt[2], 0, 1, 'ربات با موفقیت فعال شد و تا 90 روز دیگر اعتبار دارد!', 1, 'md')
	   for k,v in pairs(sudo_users) do
	      send(v, 0, 1, "*User"..msg.sender_user_id_.." Added bot to new group*" , 1, 'md')
       end
	   database:set("bot:enable:"..txt[2],true)
  end
  -----------------------------------------------------------------------------------------------
  local text = msg.content_.text_:gsub('plan','p')
  if text:match('^[#!/]plan3(-%d+)') and is_admin(msg.sender_user_id_, msg.chat_id_) then
       local txt = {string.match(text, "^[#/!](plan3)(-%d+)$")}
       database:set("bot:charge:"..txt[2],true)
	   send(msg.chat_id_, msg.id_, 1, 'پلن 3 با موفقیت برای گروه '..txt[2]..' فعال شد\nاین گروه به صورت نامحدود شارژ شد!', 1, 'md')
	   send(txt[2], 0, 1, 'ربات بدون محدودیت فعال شد ! ( نامحدود )', 1, 'md')
	   for k,v in pairs(sudo_users) do
	      send(v, 0, 1, "*User* `|"..msg.sender_user_id_.."|` *Added bot To New Group!*" , 1, 'md')
       end
	   database:set("bot:enable:"..txt[2],true)
  end
  -----------------------------------------------------------------------------------------------
  local text = msg.content_.text_:gsub('add','a')
  if text:match('^[#!/]add$') and is_admin(msg.sender_user_id_, msg.chat_id_) then
       local txt = {string.match(text, "^[#/!](add)$")}
       database:set("bot:charge:"..msg.chat_id_,true)
	   send(msg.chat_id_, msg.id_, 1, 'Group Added!', 1, 'md')
	   for k,v in pairs(sudo_users) do
	      send(v, 0, 1, "*User* `|"..msg.sender_user_id_.."|` *Added bot To New Group!*" , 1, 'md')
       end
	   database:set("bot:enable:"..msg.chat_id_,true)
  end
  -----------------------------------------------------------------------------------------------
  local text = msg.content_.text_:gsub('rem','r')
  if text:match('^[#!/]rem$') and is_admin(msg.sender_user_id_, msg.chat_id_) then
       local txt = {string.match(text, "^[#/!](rem)$")}
       database:del("bot:charge:"..msg.chat_id_)
	   send(msg.chat_id_, msg.id_, 1, 'Group Removed!', 1, 'md')
	   for k,v in pairs(sudo_users) do
	      send(v, 0, 1, "*User* `|"..msg.sender_user_id_.."|` *Removed bot To New Group!*" , 1, 'md')
       end
  end
  -----------------------------------------------------------------------------------------------
  local text = msg.content_.text_:gsub('join','j')
   if text:match('join(-%d+)') and is_admin(msg.sender_user_id_, msg.chat_id_) then
       local txt = {string.match(text, "^[#/!](join)(-%d+)$")}
	   send(msg.chat_id_, msg.id_, 1, '*You Are Succefulli Joined >* `|'..txt[3]..'|` *=)*', 1, 'md')
	   send(txt[2], 0, 1, '*Admin Joined!🌚*', 1, 'md')
	   add_user(txt[2], msg.sender_user_id_, 10)
  end
  end
   -----------------------------------------------------------------------------------------------
   local text = msg.content_.text_:gsub('autoleave','al')
          if text:match("^[!/#][Aa]utoleave (.*)$") and is_sudo(msg) then
            local status = {string.match(text, "^([!/#][Aa]utoleave) (.*)$")}
            if status[2] == "yes" then
              if database:get('autoleave') == "yes" then
                  send(msg.chat_id_, msg.id_, 1, '*> AutoLeave Is Already Active!*', 1, 'md')
else
                  send(msg.chat_id_, msg.id_, 1, '*> AutoLeave Has Been Activated!*', 1, 'md')
                end
                database:set('autoleave','yes')
              end
            end
            if status[2] == "no" then
              if database:get('autoleave') == "Off" then
                  send(msg.chat_id_, msg.id_, 1, '*> Auto Leave is Already Deactive !*', 1, 'md')
              else
                  send(msg.chat_id_, msg.id_, 1, '*> AutoLeave Has Been Deactived !*', 1, 'md')
                end
                database:del('autoleave','Off')
              end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]reload$") or text:match("^[#!/]rl$") and is_sudo(msg) then
         send(msg.chat_id_, msg.id_, 1, '*Reloaded!*', 1, 'md')
    end
	-----------------------------------------------------------------------------------------------
  local text = msg.content_.text_:gsub('whois','wi')
          if text:match("^[!/#][Ww]hois (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
            local memb = {string.match(text, "^([!/#][Ww]hois) (.*)$")}
            function whois(extra,result,success)
                send(msg.chat_id_, msg.id_, 1, '*> FirstName :* `|'..result.first_name_..'|`\n*> Username :* `|@'..result.username_..'|`\n> *User ID :* `|'..msg.sender_user_id_..'|`', 1, 'md')
              end
            getUser(memb[2],whois)
          end
	-----------------------------------------------------------------------------------------------
   if text:match("^[#!/]me$") then
      if is_sudo(msg) then
	  t = '`Sudo`'
      elseif is_admin(msg.sender_user_id_) then
	  t = '`Bot Admin`'
      elseif is_owner(msg.sender_user_id_, msg.chat_id_) then
	  t = '`Group Owner`'
      elseif is_mod(msg.sender_user_id_, msg.chat_id_) then
	  t = '`Moderator`'
      else
	  t = '`Member`'
	  end
         send(msg.chat_id_, msg.id_, 1, '*Your ID: *'..msg.sender_user_id_..'\n*Your Rank: *'..t..'.', 1, 'md')
    end
   -----------------------------------------------------------------------------------------------
  if text:match("^[#!/]pin$") or text:match("^[#!/]p$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
       pin(msg.chat_id_,msg.reply_to_message_id_,0)
	send(msg.chat_id_, msg.id_, 1, '*Message Pinned!*', 1, 'md')
	   database:set('pinnedmsg'..msg.chat_id_,msg.reply_to_message_id_)
   end
   -----------------------------------------------------------------------------------------------

   if text:match("^[#!/]unpin$") or text:match("^[#!/]up$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
         unpinmsg(msg.chat_id_)
         send(msg.chat_id_, msg.id_, 1, '*Message Unpinned!*', 1, 'md')
   end
   -----------------------------------------------------------------------------------------------
   if text:match("^[#!/]repin$") or text:match("^[#!/]rp$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
local pin_id = database:get('pinnedmsg'..msg.chat_id_)
        if pin_id then
         pin(msg.chat_id_,pin_id,0)
         send(msg.chat_id_, msg.id_, 1, '*Last Pinned Msg Has Been Repinned!*', 1, 'md')
		else
         send(msg.chat_id_, msg.id_, 1, "*i Can't Find Last Pinned Msgs...*", 1, 'md')
		 end
   end
   -----------------------------------------------------------------------------------------------
   if text:match("^[#!/]help$") or text:match("^[#!/]h$") and is_mod(msg.sender_user_id_, msg.chat_id_) then

   local text = [[`راهنمای ربات

برای قفل کردن و باز کردن تنظیمات:

/lock |links|webpage|sticker|service|username|tag|contact|english|arabic|forward|all|photo|video|gifs|music|voice|text|
/lock [edit/pin]
----------------------------------------
چند نکته لازم:

مثال :
برای قفل لینک از
/lock links
استفاده کنید بقیه هم همینطور
----------------------------------------
/lock edit
این دستور برای وقتیه که میخواین اگه کسی پیامشو ادیت کرد پاک بشه
----------------------------------------
/show edit
اگه کسی پیامشو ادیت کرده و دوس دارید بدونید قبل اون چی نوشته بوده از این دستور استفاده کنید
----------------------------------------
/lock pin
و
/pin
توجه کنید شما میخواید ی پیامو پین کنید و ادمیناتون نتونن تغییرش بدن
اول با دستور
/pin
و ریپلی روی متن مورد نظر اون رو پین میکنید بعد
/lock pin
میزنید
و ربات اینطور میشه ک اگه ادمیناتون بخوان متنی رو پین کنن ربات برش میگردونه سر متنی ک شما پین کردید :)
----------------------------------------
/unlock |links|webpage|sticker|service|username|tag|contact|english|arabic|forward|
/unlock |all|photo|video|gifs|music|voice|text|
/lock [edit|pin]
رای باز کردن اون موارد بالا ک گفتم
----------------------------------------
/welcome on
فعال کردن پیام خوشامد گویی
----------------------------------------
/welcome off
غیر فعال کردن پیام خوشامد گویی
----------------------------------------
/get welcome متن مورد نظر
تنظیم کردن متن دلخواه به عنوان متن خوشامد گویی
----------------------------------------
اگه میخواید اسم و ایدی فردی ک میاد تو گروه نشون داده بشه از دستور زیر استفاده کنید

/set welcome Salam {username}
اسم = {firstname}
فامیل = {lastname}
----------------------------------------
/get welcome
مشاهده متن خوشامد گویی
----------------------------------------
/del welcome
حذف کردن پیام خوشامد گویی
----------------------------------------
/ban |با ریپلی|
اخراج همیشگی کاربر از گروه
----------------------------------------
/unban |با ریپلی|
حذف کاربر از لیست بن
----------------------------------------
/banlist
لیست افراد بن شده
----------------------------------------
/muteuser |با ریپلی|
اضافه کردن کاربر به لیست افراد میوت شده
----------------------------------------
/unmuteuser |با ریپلی|
حذف کردن کاربر از لیست افراد میوت شده
----------------------------------------
/mutelist
لیست افراد میوت شده
----------------------------------------
/promote |با ریپلی|
ادمین کردن فرد مورد نظر
----------------------------------------
/demote |با ریپلی|
دراوردن از ادمینی فرد مورد نظر
----------------------------------------
/modlist
لیست ادمین های ربات در گروه
----------------------------------------
/getpro [1-10]
دریافت عکس پروفایل شما
مثال
/getpro 2
----------------------------------------
/setlink
تنظیم لینک برای گروه
----------------------------------------
/setrules قوانین
تنظیم متن قوانین گروه
----------------------------------------
/rules
دریافت قوانین
----------------------------------------
/settings
دریافت تنظیمات گروه
----------------------------------------
/clean [banlist/mutelist/modlist]
حذف کردن لیست افراد بن/میوت/پروموت شده
----------------------------------------
/del عدد
پاک کردن پیام های اخیر گروه
مثال
/del 42
برای پاک 42 پیام آخر گروه
----------------------------------------
/dellall @ایدی
با این دستور میتونید کل پیام های یک فرد رو پاک کنید همچنین این دستور با ریپلی هم کار میکنه
----------------------------------------
/charge stats
مایش اینکه چند روز دیگر از زمان گروه شما باقی مانده
----------------------------------------
/share
دریافت شماره ی ربات
----------------------------------------
/user
دریافت یوزرنیم خودتون
----------------------------------------
/mute all [عدد]
قفل کردن گروه بر اساس ثانیه
مثال:
/mute all 10
با زدن این دستور گروه برای ده ثانیه قفل میشود.
----------------------------------------
/filter [کلمه]
غیرمجاز کردن یک کلمه و اگه ربات اون کلمه رو ببینه پاکش میکنه
----------------------------------------
/rw [کلمه]
مجاز کردن کلم ای که غیر مجاز کردین
----------------------------------------
/filterlist
لیست کلمات غیرمجاز
----------------------------------------`

*Full Help COmming Soon...*

]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   -----------------------------------------------------------------------------------------------
   if text:match("^[#!/]gview$") then
        database:set('bot:viewget'..msg.sender_user_id_,true)
        send(msg.chat_id_, msg.id_, 1, '*Please send a post now!*', 1, 'md')
   end
  end
  -----------------------------------------------------------------------------------------------
 end
  -----------------------------------------------------------------------------------------------
                                       -- end code --
  -----------------------------------------------------------------------------------------------
  elseif (data.ID == "UpdateChat") then
    chat = data.chat_
    chats[chat.id_] = chat
  -----------------------------------------------------------------------------------------------
  elseif (data.ID == "UpdateMessageEdited") then
   local msg = data
  -- vardump(msg)
  	function get_msg_contact(extra, result, success)
	local text = (result.content_.text_ or result.content_.caption_)
    --vardump(result)
	if result.id_ and result.content_.text_ then
	database:set('bot:editid'..result.id_,result.content_.text_)
	end
  if not is_mod(result.sender_user_id_, result.chat_id_) then
   check_filter_words(result, text)
   if text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or text:match("[Tt].[Mm][Ee]") then
   if database:get('bot:links:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end
   end
   	if text:match("[Hh][Tt][Tt][Pp][Ss]://") or text:match("[Hh][Tt][Tt][Pp]://") or text:match(".[Ii][Rr]") or text:match(".[Cc][Oo][Mm]") or text:match(".[Oo][Rr][Gg]") or text:match(".[Ii][Nn][Ff][Oo]") or text:match("[Ww][Ww][Ww].") or text:match(".[Tt][Kk]") then
   if database:get('bot:webpage:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end
   end
   if text:match("@") then
   if database:get('bot:tag:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end
   end
   	if text:match("#") then
   if database:get('bot:hashtag:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end
   end
   	if text:match("[\216-\219][\128-\191]") then
   if database:get('bot:arabic:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end
   end
   if text:match("[ASDFGHJKLQWERTYUIOPZXCVBNMasdfghjklqwertyuiopzxcvbnm]") then
   if database:get('bot:english:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end
   end
    end
	end
	if database:get('editmsg'..msg.chat_id_) == 'delmsg' then
        local id = msg.message_id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
              delete_msg(chat,msgs)
	elseif database:get('editmsg'..msg.chat_id_) == 'didam' then
	if database:get('bot:editid'..msg.message_id_) then
		local old_text = database:get('bot:editid'..msg.message_id_)
	    send(msg.chat_id_, msg.message_id_, 1, 'Dont Edit!\n*I See You What Say :D*:\n*Edit Was Locked!*\n*I"ll Delete Your Message*\n_Your Say: _*'..old_text..'*', 1, 'md')
	end
	end
    getMessage(msg.chat_id_, msg.message_id_,get_msg_contact)
  -----------------------------------------------------------------------------------------------
  elseif (data.ID == "UpdateOption" and data.name_ == "my_id") then
    tdcli_function ({ID="GetChats", offset_order_="9223372036854775807", offset_chat_id_=0, limit_=20}, dl_cb, nil)
  end
  -----------------------------------------------------------------------------------------------
end
