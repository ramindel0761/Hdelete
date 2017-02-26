serpent = (loadfile "serpent.lua")()
redis = (loadfile "lua-redis.lua")()
database = Redis.connect('127.0.0.1', 6379)
chats = {}
day = 86400
bot_id = 345998203 -- Your Bot USER_ID
sudo_users = {   218722292,
    253756305,
    247473926,
    352682438,
36665774,
    259080779,
    283279752,
    321624563,
    68853039,
    230559741--[[YOUE ID :|]]}
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
function chat_kick(chat_id, user_id)
  changeChatMemberStatus(chat_id, user_id, "Kicked")
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
    --------- ANTI FLOOD -------------------
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
                           send(msg.chat_id_, msg.id_, 1, '☘ _ایدی_  _('..msg.sender_user_id_..')_ \n_اسپم اینجا مجاز نیست._\n`اسپمر حذف شد!!`', 1, 'md')
					  end
                    end
                    database:setex(hash, floodTime, msgs+1)
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
    -------------_ MSG TYPES _-----------------
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
	elseif msg.content_.ID == "MessagePhoto" then
	print("PHOTO DETECTED!!")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Photo'
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
  --------------------------________ START MSG CHECKS ________-------------------------------------------
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
   send(msg.chat_id_, msg.id_, 1, 'شما دسترسی به این کار را ندارید...\nمن پیام شما را آنپین و در صورت در دسترس بودن پیام قبل رو دوباره پین میکنم...\nدر صورتی که در ربات مقامی دارید میتوانید با ریپلی کردن پیام و ارسال دستور /pin پیام جدید رو برای پین شدن تنظیم کنید!', 1, 'md')
   unpinmsg(msg.chat_id_)
   local pin_id = database:get('pinnedmsg'..msg.chat_id_)
         pin(msg.chat_id_,pin_id,0)
   end
end
if database:get('bot:viewget'..msg.sender_user_id_) then 
    if not msg.forward_info_ then
		send(msg.chat_id_, msg.id_, 1, '_Error_\n`Please send this command again and forward your post(from channel)`', 1, 'md')
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
      
   if caption_text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or caption_text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") or caption_text:match("[Tt].[Mm][Ee]") then
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
        text = '_Hi {firstname} 😃_'
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
        text = '_Hi {firstname} 😃_'
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
      
   if caption_text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or caption_text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") or caption_text:match("[Tt].[Mm][Ee]") then
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
      
  if caption_text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or caption_text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") or caption_text:match("[Tt].[Mm][Ee]") then
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
      
   if caption_text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or caption_text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") or caption_text:match("[Tt].[Mm][Ee]") then
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
      
  if caption_text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or caption_text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") or caption_text:match("[Tt].[Mm][Ee]") then
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
   
   if caption_text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or caption_text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") or caption_text:match("[Tt].[Mm][Ee]") then
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
    if database:get("bot:group:link"..msg.chat_id_) == '☘ لطفا لینک خود را ارسال کنید!\n\nکانال ما > @JoveTeam' and is_mod(msg.sender_user_id_, msg.chat_id_) then
      if text:match("(https://t.me/joinchat/%S+)") then
	  local glink = text:match("(https://t.me/joinchat/%S+)")
      local hash = "bot:group:link"..msg.chat_id_
               database:set(hash,glink)
			  send(msg.chat_id_, msg.id_, 1, '_لینک جدید ثبت شد!_', 1, 'md')
			  send(msg.chat_id_, 0, 1, '☘ <i>لینک جدید گروه:</i>\n'..glink, 1, 'html')
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
	if text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") or text:match("[Tt].[Mm][Ee]") then
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
  ---------------------------________ END MSG CHECKS ________--------------------------------------------
  -------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------
  if database:get('bot:cmds'..msg.chat_id_) and not is_mod(msg.sender_user_id_, msg.chat_id_) then
  return 
  else
    ------------------------------------ With Pattern -------------------------------------------
	if text:match("^[#!/]ping$") then
	   send(msg.chat_id_, msg.id_, 1, '☘ _Pong_', 1, 'md')
	end
	-----------------------------------------------------------------------------------------------
	if text:match("^[!/#]leave$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	     chat_leave(msg.chat_id_, bot_id)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]promote$") and is_owner(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function promote_by_reply(extra, result, success)
	local hash = 'bot:mods:'..msg.chat_id_
	if database:sismember(hash, result.sender_user_id_) then
         send(msg.chat_id_, msg.id_, 1, '☘ _کاربر_ _'..result.sender_user_id_..'_ _ازقبل مدیر است._', 1, 'md')
	else
         database:sadd(hash, result.sender_user_id_)
         send(msg.chat_id_, msg.id_, 1, '☘ _کاربر_ _'..result.sender_user_id_..'_ _به عنوان مدیر منصوب شد._', 1, 'md')
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,promote_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]promote @(._)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local ap = {string.match(text, "^[#/!](promote) @(._)$")} 
	function promote_by_username(extra, result, success)
	if result.id_ then
	        database:sadd('bot:mods:'..msg.chat_id_, result.id_)
            texts = '☘ <i>کاربر </i><code>'..result.id_..'</code> <i>به عنوان مدیر منصوب شد!</i>'
            else 
            texts = '<code> ☘کاربرپیدا نشد!</code>'
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(ap[2],promote_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]promote (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local ap = {string.match(text, "^[#/!](promote) (%d+)$")} 	
	        database:sadd('bot:mods:'..msg.chat_id_, ap[2])
	send(msg.chat_id_, msg.id_, 1, '☘ _کاربر_ _'..ap[2]..'_ _به عنوان مدیر منصوب شد._', 1, 'md')
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]demote$") and is_owner(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function demote_by_reply(extra, result, success)
	local hash = 'bot:mods:'..msg.chat_id_
	if not database:sismember(hash, result.sender_user_id_) then
         send(msg.chat_id_, msg.id_, 1, '☘ _کاربر_ _'..result.sender_user_id_..'_ _مدیر نیست._', 1, 'md')
	else
         database:srem(hash, result.sender_user_id_)
         send(msg.chat_id_, msg.id_, 1, '☘ _کاربر_ _'..result.sender_user_id_..'_ _عزل شد._', 1, 'md')
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,demote_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]demote @(._)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local hash = 'bot:mods:'..msg.chat_id_
	local ap = {string.match(text, "^[#/!](demote) @(._)$")} 
	function demote_by_username(extra, result, success)
	if result.id_ then
         database:srem(hash, result.id_)
            texts = '<i»کاربر </i><code>'..result.id_..'</code> <i>عزل شد</i>'
            else 
            texts = '<code»کاربر پیدا نشد!</code>'
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(ap[2],demote_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]demote (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local hash = 'bot:mods:'..msg.chat_id_
	local ap = {string.match(text, "^[#/!](demote) (%d+)$")} 	
         database:srem(hash, ap[2])
	send(msg.chat_id_, msg.id_, 1, '☘ _کاربر_ _'..ap[2]..'_ _عزل شد._', 1, 'md')
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]ban$") and is_mod(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function ban_by_reply(extra, result, success)
	local hash = 'bot:banned:'..msg.chat_id_
	if is_mod(result.sender_user_id_, result.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '☘ _شما نمیتوانید مدیران را [اخراج/بن] کنید!!_', 1, 'md')
    else
    if database:sismember(hash, result.sender_user_id_) then
         send(msg.chat_id_, msg.id_, 1, '☘ _کاربر_ _'..result.sender_user_id_..'_ _ازقبل بن است._', 1, 'md')
		 chat_kick(result.chat_id_, result.sender_user_id_)
	else
         database:sadd(hash, result.sender_user_id_)
         send(msg.chat_id_, msg.id_, 1, '☘ _کاربر_ _'..result.sender_user_id_..'_ _بن شد_', 1, 'md')
		 chat_kick(result.chat_id_, result.sender_user_id_)
	end
    end
	end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,ban_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]ban @(._)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local ap = {string.match(text, "^[#/!](ban) @(._)$")} 
	function ban_by_username(extra, result, success)
	if result.id_ then
	if is_mod(result.id_, msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '☘ _شما نمیتوانید مدیران را [اخراج/بن] کنید!!_', 1, 'md')
    else
	        database:sadd('bot:banned:'..msg.chat_id_, result.id_)
            texts = '<i» کاربر </i><code>'..result.id_..'</code> <i>بن شد.!</i>'
		 chat_kick(msg.chat_id_, result.id_)
	end
            else 
            texts = '<code»کاربرپیدا نشد!</code>'
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(ap[2],ban_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]ban (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local ap = {string.match(text, "^[#/!](ban) (%d+)$")}
	if is_mod(ap[2], msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '☘ _شما نمیتوانید مدیران را [اخراج/بن] کنید!!_', 1, 'md')
    else
	        database:sadd('bot:banned:'..msg.chat_id_, ap[2])
		 chat_kick(msg.chat_id_, ap[2])
	send(msg.chat_id_, msg.id_, 1, '☘ _کاربر_ _'..ap[2]..'_ _بن شد._', 1, 'md')
	end
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]unban$") and is_mod(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function unban_by_reply(extra, result, success)
	local hash = 'bot:banned:'..msg.chat_id_
	if not database:sismember(hash, result.sender_user_id_) then
         send(msg.chat_id_, msg.id_, 1, '☘ _کاربر_ _'..result.sender_user_id_..'_ _بن نیست._', 1, 'md')
	else
         database:srem(hash, result.sender_user_id_)
         send(msg.chat_id_, msg.id_, 1, '☘ _کاربر_ _'..result.sender_user_id_..'_ _انبن شد._', 1, 'md')
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,unban_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]unban @(._)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local ap = {string.match(text, "^[#/!](unban) @(._)$")} 
	function unban_by_username(extra, result, success)
	if result.id_ then
         database:srem('bot:banned:'..msg.chat_id_, result.id_)
            text = '☘ <i>کاربر </i><code>'..result.id_..'</code> <i>انبن شد.!</i>'
            else 
            text = '<code»کاربر پیدا نشد!</code>'
    end
	         send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
    end
	      resolve_username(ap[2],unban_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]unban (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local ap = {string.match(text, "^[#/!](unban) (%d+)$")} 	
	        database:srem('bot:banned:'..msg.chat_id_, ap[2])
	send(msg.chat_id_, msg.id_, 1, '☘ _کاربر_ _'..ap[2]..'_ _انبن شد._', 1, 'md')
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]muteuser$") and is_mod(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function mute_by_reply(extra, result, success)
	local hash = 'bot:muted:'..msg.chat_id_
	if is_mod(result.sender_user_id_, result.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '☘ _شما نمیتوانید مدیران را [ساکت] کنید!!_', 1, 'md')
    else
    if database:sismember(hash, result.sender_user_id_) then
         send(msg.chat_id_, msg.id_, 1, '☘ _کاربر_ _'..result.sender_user_id_..'_ _ازقبل ساکت شده است._', 1, 'md')
	else
         database:sadd(hash, result.sender_user_id_)
         send(msg.chat_id_, msg.id_, 1, '☘ _کاربر_ _'..result.sender_user_id_..'_ _ساکت شد._', 1, 'md')
	end
    end
	end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,mute_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]muteuser @(._)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local ap = {string.match(text, "^[#/!](muteuser) @(._)$")} 
	function mute_by_username(extra, result, success)
	if result.id_ then
	if is_mod(result.id_, msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '☘ _شما نمیتوانید مدیران را [ساکت] کنید!!_', 1, 'md')
    else
	        database:sadd('bot:muted:'..msg.chat_id_, result.id_)
            texts = '☘<i>کاربر </i><code>'..result.id_..'</code> <i>ساکت شد.!</i>'
		 chat_kick(msg.chat_id_, result.id_)
	end
            else 
            texts = '<code»کاربر پیدا نشد!</code>'
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(ap[2],mute_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]muteuser (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local ap = {string.match(text, "^[#/!](muteuser) (%d+)$")}
	if is_mod(ap[2], msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_شما نمیتوانید مدیران را [ساکت] کنید!!_', 1, 'md')
    else
	        database:sadd('bot:muted:'..msg.chat_id_, ap[2])
	send(msg.chat_id_, msg.id_, 1, '☘ _کاربر_ _'..ap[2]..'_ _ساکت شد._', 1, 'md')
	end
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]unmuteuser$") and is_mod(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function unmute_by_reply(extra, result, success)
	local hash = 'bot:muted:'..msg.chat_id_
	if not database:sismember(hash, result.sender_user_id_) then
         send(msg.chat_id_, msg.id_, 1, '☘_کاربر_ _'..result.sender_user_id_..'_ _ساکت نیست._', 1, 'md')
	else
         database:srem(hash, result.sender_user_id_)
         send(msg.chat_id_, msg.id_, 1, '☘_کاربر_ _'..result.sender_user_id_..'_ _از لیست ساکتین در آمد._', 1, 'md')
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,unmute_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]unmuteuser @(._)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local ap = {string.match(text, "^[#/!](unmuteuser) @(._)$")} 
	function unmute_by_username(extra, result, success)
	if result.id_ then
         database:srem('bot:muted:'..msg.chat_id_, result.id_)
            text = '☘<i>کاربر </i><code>'..result.id_..'</code> <i>از لیست ساکتین در آمد.!</i>'
            else 
            text = '<code»کاربر پیدا نشد!</code>'
    end
	         send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
    end
	      resolve_username(ap[2],unmute_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]unmuteuser (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local ap = {string.match(text, "^[#/!](unmuteuser) (%d+)$")} 	
	        database:srem('bot:muted:'..msg.chat_id_, ap[2])
	send(msg.chat_id_, msg.id_, 1, '☘ _کاربر_ _'..ap[2]..'_ _از لیست ساکتین در آمد._', 1, 'md')
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]setowner$") and is_admin(msg.sender_user_id_) and msg.reply_to_message_id_ then
	function setowner_by_reply(extra, result, success)
	local hash = 'bot:owners:'..msg.chat_id_
	if database:sismember(hash, result.sender_user_id_) then
         send(msg.chat_id_, msg.id_, 1, '☘ _کاربر_ _'..result.sender_user_id_..'_ _ازقبل مدیر است._', 1, 'md')
	else
         database:sadd(hash, result.sender_user_id_)
         send(msg.chat_id_, msg.id_, 1, '☘ _کاربر_ _'..result.sender_user_id_..'_ _به عنوان مدیر منصوب شد._', 1, 'md')
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,setowner_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]setowner @(._)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	local ap = {string.match(text, "^[#/!](setowner) @(._)$")} 
	function setowner_by_username(extra, result, success)
	if result.id_ then
	        database:sadd('bot:owners:'..msg.chat_id_, result.id_)
            texts = '<i»کاربر </i><code>'..result.id_..'</code> <i>به عنوان مالک گروه منصوب شد.!</i>'
            else 
            texts = '<code»کاربر پیدا نشد!</code>'
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(ap[2],setowner_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]setowner (%d+)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	local ap = {string.match(text, "^[#/!](setowner) (%d+)$")} 	
	        database:sadd('bot:owners:'..msg.chat_id_, ap[2])
	send(msg.chat_id_, msg.id_, 1, '☘ _کاربر_ _'..ap[2]..'_ _به عنوان مالک گروه منصوب شد._', 1, 'md')
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]demowner$") and is_admin(msg.sender_user_id_) and msg.reply_to_message_id_ then
	function deowner_by_reply(extra, result, success)
	local hash = 'bot:owners:'..msg.chat_id_
	if not database:sismember(hash, result.sender_user_id_) then
         send(msg.chat_id_, msg.id_, 1, '☘_کاربر_ _'..result.sender_user_id_..'_ _مالک گروه نیست._', 1, 'md')
	else
         database:srem(hash, result.sender_user_id_)
         send(msg.chat_id_, msg.id_, 1, '☘ _کاربر_ _'..result.sender_user_id_..'_ _از لیست مالکین گروه حذف شد._', 1, 'md')
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
            texts = '<i»کاربر </i><code>'..result.id_..'</code> <i>از لیست مالکین حذف شد</i>'
            else 
            texts = '<code»کاربر یافت نشد!</code>'
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(ap[2],remowner_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]demowner (%d+)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	local hash = 'bot:owners:'..msg.chat_id_
	local ap = {string.match(text, "^[#/!](demowner) (%d+)$")} 	
         database:srem(hash, ap[2])
	send(msg.chat_id_, msg.id_, 1, '☘_کاربر_ _'..ap[2]..'_ _از لیست مالکین حذف شد._', 1, 'md')
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]addadmin$") and is_sudo(msg) and msg.reply_to_message_id_ then
	function addadmin_by_reply(extra, result, success)
	local hash = 'bot:admins:'
	if database:sismember(hash, result.sender_user_id_) then
         send(msg.chat_id_, msg.id_, 1, '☘_کاربر_ _'..result.sender_user_id_..'_ _از قبل ادمین است._', 1, 'md')
	else
         database:sadd(hash, result.sender_user_id_)
         send(msg.chat_id_, msg.id_, 1, '☘_کاربر_ _'..result.sender_user_id_..'_ _به لیست ادمین های ربات اضافه شد._', 1, 'md')
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,addadmin_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]addadmin @(._)$") and is_sudo(msg) then
	local ap = {string.match(text, "^[#/!](addadmin) @(._)$")} 
	function addadmin_by_username(extra, result, success)
	if result.id_ then
	        database:sadd('bot:admins:', result.id_)
            texts = '☘<i>کاربر </i><code>'..result.id_..'</code> <i>به لیست مدیران اضافه شد.!</i>'
            else 
            texts = '<code»کاربر یافت نشد!</code>'
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(ap[2],addadmin_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]addadmin (%d+)$") and is_sudo(msg) then
	local ap = {string.match(text, "^[#/!](addadmin) (%d+)$")} 	
	        database:sadd('bot:admins:', ap[2])
	send(msg.chat_id_, msg.id_, 1, '☘_کاربر_ _'..ap[2]..'_ _به لیست مدیران افزوده شد._', 1, 'md')
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]remadmin$") and is_sudo(msg) and msg.reply_to_message_id_ then
	function deadmin_by_reply(extra, result, success)
	local hash = 'bot:admins:'
	if not database:sismember(hash, result.sender_user_id_) then
         send(msg.chat_id_, msg.id_, 1, '☘_کاربر_ _'..result.sender_user_id_..'_ _ادمین نیست._', 1, 'md')
	else
         database:srem(hash, result.sender_user_id_)
         send(msg.chat_id_, msg.id_, 1, '☘_کاربر_ _'..result.sender_user_id_..'_ _ازلیست مدیران حذف شد!._', 1, 'md')
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,deadmin_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]remadmin @(._)$") and is_sudo(msg) then
	local hash = 'bot:admins:'
	local ap = {string.match(text, "^[#/!](remadmin) @(._)$")} 
	function remadmin_by_username(extra, result, success)
	if result.id_ then
         database:srem(hash, result.id_)
            texts = '☘<i>کاربر </i><code>'..result.id_..'</code> <i>ازلیست مدیران حذف شد!</i>'
            else 
            texts = '☘<code>کاربر یافت نشد!</code>'
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(ap[2],remadmin_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]remadmin (%d+)$") and is_sudo(msg) then
	local hash = 'bot:admins:'
	local ap = {string.match(text, "^[#/!](remadmin) (%d+)$")} 	
         database:srem(hash, ap[2])
	send(msg.chat_id_, msg.id_, 1, '☘_کاربر_ _'..ap[2]..'_ ازلیست مدیران حذف شد!_', 1, 'md')
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]modlist$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
    local hash =  'bot:mods:'..msg.chat_id_
	local list = database:smembers(hash)
	local text = "<i»لیست مدیران:</i>\n\n"
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
       text = "☘لیست مدیران خالی است"
    end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]mutelist$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
    local hash =  'bot:muted:'..msg.chat_id_
	local list = database:smembers(hash)
	local text = "<i»لیست ساکت شدگان:</i>\n\n"
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
       text = "☘لیست ساکت شدگان خالی است"
    end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]owner$") or text:match("^[#!/]ownerlist$") and is_sudo(msg) then
    local hash =  'bot:owners:'..msg.chat_id_
	local list = database:smembers(hash)
	local text = "<i»لیست مدیران:</i>\n\n"
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
       text = "☘لیست مدیران خالی است"
    end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]banlist$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
    local hash =  'bot:banned:'..msg.chat_id_
	local list = database:smembers(hash)
	local text = "<i»لیست بن:</i>\n\n"
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
       text = "☘لیست بن خالی است"
    end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]adminlist$") and is_sudo(msg) then
    local hash =  'bot:admins:'
	local list = database:smembers(hash)
	local text = "☘ادمین های ژوپیتر:\n\n"
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
       text = "☘لیست ادمین ها خالی است"
    end
    send(msg.chat_id_, msg.id_, 1, '`'..text..'`', 'md')
    end
	-----------------------------------------------------------------------------------------------
    if text:match("^[#!/]id$") and msg.reply_to_message_id_ ~= 0 then
      function id_by_reply(extra, result, success)
	  local user_msgs = database:get('user:msgs'..result.chat_id_..':'..result.sender_user_id_)
        send(msg.chat_id_, msg.id_, 1, "_☘شناسه کاربری:_ `"..result.sender_user_id_.."`\n_☘تعداد پیام ها:_ `"..user_msgs.."`", 1, 'md')
        end
   getMessage(msg.chat_id_, msg.reply_to_message_id_,id_by_reply)
  end
  -----------------------------------------------------------------------------------------------
    if text:match("^[#!/]id @(._)$") then
	local ap = {string.match(text, "^[#/!](id) @(._)$")} 
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
            texts = '☘_نام کاربری_ : `@'..ap[2]..'`\n☘_شناسه کاربری_ : `('..result.id_..')`\n☘_مقام_ : `'..t..'`'
            else 
            texts = '<code»کاربر یافت نشد</code>'
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'md')
    end
	      resolve_username(ap[2],id_by_username)
    end
    -----------------------------------------------------------------------------------------------
  if text:match("^[#!/]kick$") and msg.reply_to_message_id_ and is_mod(msg.sender_user_id_, msg.chat_id_) then
      function kick_reply(extra, result, success)
	if is_mod(result.sender_user_id_, result.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_☘شما نمیتوانید مدیران را اخراج/بن کنید!!_', 1, 'md')
    else
        send(msg.chat_id_, msg.id_, 1, '☘کاربر '..result.sender_user_id_..' اخراج شد.', 1, 'html')
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
local function getpro(extra, result, success)
local user_msgs = database:get('user:msgs'..msg.chat_id_..':'..msg.sender_user_id_)
   if result.photos_[0] then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[0].sizes_[1].photo_.persistent_id_,'> ☘شناسه سوپرگروه: '..msg.chat_id_..'\n> ☘ایدی شما: '..msg.sender_user_id_..'\n> ☘تعداد پیام های شما: '..user_msgs,msg.id_,msg.id_)
   else
      send(msg.chat_id_, msg.id_, 1, "☘شما عکس پروفایل ندارید!!\n\n_☘شناسه کاربری گروه:_ `"..msg.chat_id_.."`\n_☘ایدی شما:_ `"..msg.sender_user_id_.."`\n_☘تعدادپیام های شما:_ `"..user_msgs.."`", 1, 'md')
   end
   end
   tdcli_function ({
    ID = "GetUserProfilePhotos",
    user_id_ = msg.sender_user_id_,
    offset_ = 0,
    limit_ = 1
  }, getpro, nil)
	end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]lock (._)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local lockpt = {string.match(text, "^[#/!](lock) (._)$")} 
      if lockpt[2] == "edit" then
         send(msg.chat_id_, msg.id_, 1, '_☘انجام شد_\n_پیام های ویرایش شده کاربران حذف خواهد شد_', 1, 'md')
         database:set('editmsg'..msg.chat_id_,'delmsg')
	  end
	  if lockpt[2] == "cmds" then
         send(msg.chat_id_, msg.id_, 1, '_> ☘دستورات ربات قفل شد_\n', 1, 'md')
         database:set('bot:cmds'..msg.chat_id_,true)
      end
	  if lockpt[2] == "bots" then
         send(msg.chat_id_, msg.id_, 1, '_> ☘ورود ربات قفل شد_ ', 1, 'md')
         database:set('bot:bots:mute'..msg.chat_id_,true)
      end
	  if lockpt[2] == "flood" then
         send(msg.chat_id_, msg.id_, 1, '_☘حساسیت قفل شد_', 1, 'md')
         database:del('anti-flood:'..msg.chat_id_)
	  end
	  if lockpt[2] == "pin" then
         send(msg.chat_id_, msg.id_, 1, "_☘از این به بعد کاربران نمیتوانند پیغام سنجاق کنند_", 1, 'md')
	     database:set('bot:pin:mute'..msg.chat_id_,true)
      end
	end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]setflood (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local floodmax = {string.match(text, "^[#/!](setflood) (%d+)$")} 
	if tonumber(floodmax[2]) < 2 then
         send(msg.chat_id_, msg.id_, 1, '_☘خطا_,_عدد باید بین  [2-99999] باشد_', 1, 'md')
	else
    database:set('flood:max:'..msg.chat_id_,floodmax[2])
         send(msg.chat_id_, msg.id_, 1, '_> ☘حساسیت تنظیم شد به_ _'..floodmax[2]..'_', 1, 'md')
	end
	end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]setfloodtime (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local floodt = {string.match(text, "^[#/!](setfloodtime) (%d+)$")} 
	if tonumber(floodt[2]) < 2 then
         send(msg.chat_id_, msg.id_, 1, '_☘خطا_,_عدد انتخابی باید بین  [2-99999] باشد_', 1, 'md')
	else
    database:set('flood:time:'..msg.chat_id_,floodt[2])
         send(msg.chat_id_, msg.id_, 1, '_> ☘مقدار حساسیت تنظیم شد به_ _'..floodt[2]..'_', 1, 'md')
	end
	end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]setlink$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_☘لینک گروه خود راارسال کنید!_', 1, 'md')
         database:set("bot:group:link"..msg.chat_id_, '☘لینک گروه خود راارسال کنید\n\nکانال > @JoveTeam')
	end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]link$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local link = database:get("bot:group:link"..msg.chat_id_)
	  if link then
         send(msg.chat_id_, msg.id_, 1, '☘<i>لینک گروه:</i>\n'..link, 1, 'html')
	  else 
         send(msg.chat_id_, msg.id_, 1, '☘_هم اکنون هیچی لینکی ثبت نشده است.با #setlink یک لینک ثبت کنید._', 1, 'md')
	  end
 	end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]stats$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
    local gps = database:scard("bot:groups")
	local users = database:scard("bot:userss")
    local allmgs = database:get("bot:allmsgs")
                   send(msg.chat_id_, msg.id_, 1, '_☘آمار_\n\n_> گروه ها: _ `'..gps..'`\n_> کاربران: _ `'..users..'`\n_> کل پیام ها: _ `'..allmgs..'`', 1, 'md')
	end
	-----------------------------------------------------------------------------------------------
  	if text:match("^[#!/]unlock (._)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local unlockpt = {string.match(text, "^[#/!](unlock) (._)$")} 
      if unlockpt[2] == "edit" then
         send(msg.chat_id_, msg.id_, 1, '_☘انجام شد_\n_ویرایش ازاد شد._', 1, 'md')
         database:del('editmsg'..msg.chat_id_)
      end
	  if unlockpt[2] == "cmds" then
         send(msg.chat_id_, msg.id_, 1, '_» دستورات ربات ازاد شد_', 1, 'md')
         database:del('bot:cmds'..msg.chat_id_)
      end
	  if unlockpt[2] == "bots" then
         send(msg.chat_id_, msg.id_, 1, '_» ورود ربات ازاد شد_', 1, 'md')
         database:del('bot:bots:mute'..msg.chat_id_)
      end
	  if unlockpt[2] == "flood" then
         send(msg.chat_id_, msg.id_, 1, '_☘حساسیت ازاد شد_', 1, 'md')
         database:set('anti-flood:'..msg.chat_id_,true)
	  end
	  if unlockpt[2] == "pin" then
         send(msg.chat_id_, msg.id_, 1, "_☘حالا کاربران میتوانند یک پیام سنجاق کنند_", 1, 'md')
	     database:del('bot:pin:mute'..msg.chat_id_)
      end
    end
	-----------------------------------------------------------------------------------------------
  	if text:match("^[#!/]mute all (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local mutept = {string.match(text, "^[#!/]mute all (%d+)$")}
	    		database:setex('bot:muteall'..msg.chat_id_, tonumber(mutept[1]), true)
         send(msg.chat_id_, msg.id_, 1, '☘_> گروه برای_ _'..mutept[1]..'_ _ثانیه ساکت شد!_', 1, 'md')
	end
	-----------------------------------------------------------------------------------------------
  	if text:match("^[#!/]lock (._)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local mutept = {string.match(text, "^[#/!](lock) (._)$")} 
      if mutept[2] == "all" then
         send(msg.chat_id_, msg.id_, 1, '☘قفل همه _فعال شد_', 1, 'md')
						database:set('bot:muteall'..msg.chat_id_,true)
      end
	  if mutept[2] == "text" then
         send(msg.chat_id_, msg.id_, 1, '»متن _قفل شد_', 1, 'md')
						database:set('bot:text:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "inline" then
         send(msg.chat_id_, msg.id_, 1, '»اینلاین _قفل شد_', 1, 'md')
						database:set('bot:inline:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "photo" then
         send(msg.chat_id_, msg.id_, 1, '»عکس _قفل شد_', 1, 'md')
						database:set('bot:photo:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "video" then
         send(msg.chat_id_, msg.id_, 1, '»فیلم _قفل شد_', 1, 'md')
						database:set('bot:video:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "gifs" then
         send(msg.chat_id_, msg.id_, 1, '»گیف _قفل شد_', 1, 'md')
						database:set('bot:gifs:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "music" then
         send(msg.chat_id_, msg.id_, 1, '»اهنگ _قفل شد_', 1, 'md')
						database:set('bot:music:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "voice" then
         send(msg.chat_id_, msg.id_, 1, '»صدا _قفل شد_', 1, 'md')
						database:set('bot:voice:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "links" then
         send(msg.chat_id_, msg.id_, 1, '»_لینک قفل_ شد', 1, 'md')
						database:set('bot:links:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "location" then
         send(msg.chat_id_, msg.id_, 1, '»_موقعیت قفل_ شد', 1, 'md')
						database:set('bot:location:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "tag" then
         send(msg.chat_id_, msg.id_, 1, '»_تگ قفل_ شد', 1, 'md')
						database:set('bot:tag:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "hashtag" then
         send(msg.chat_id_, msg.id_, 1, '»_هشتگ قفل_ شد', 1, 'md')
						database:set('bot:hashtag:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "contact" then
         send(msg.chat_id_, msg.id_, 1, '»_مخاطب قفل_ شد', 1, 'md')
						database:set('bot:contact:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "webpage" then
         send(msg.chat_id_, msg.id_, 1, '»_وب لینک قفل_ شد', 1, 'md')
						database:set('bot:webpage:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "arabic" then
         send(msg.chat_id_, msg.id_, 1, '»_فارسی قفل_ شد', 1, 'md')
						database:set('bot:arabic:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "english" then
         send(msg.chat_id_, msg.id_, 1, '»_انگلیسی قفل_ شد', 1, 'md')
						database:set('bot:english:mute'..msg.chat_id_,true)
      end 
	  if mutept[2] == "sticker" then
         send(msg.chat_id_, msg.id_, 1, '»_استیکر قفل_ شد', 1, 'md')
						database:set('bot:sticker:mute'..msg.chat_id_,true)
      end 
	  if mutept[2] == "service" then
         send(msg.chat_id_, msg.id_, 1, '»_اعلان قفل_ شد', 1, 'md')
						database:set('bot:tgservice:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "forward" then
         send(msg.chat_id_, msg.id_, 1, '»_فروارد قفل_ شد', 1, 'md')
						database:set('bot:forward:mute'..msg.chat_id_,true)
      end
	end
	-----------------------------------------------------------------------------------------------
  	if text:match("^[#!/]unlock (._)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local unmutept = {string.match(text, "^[#/!](unlock) (._)$")} 
      if unmutept[2] == "all" then
         send(msg.chat_id_, msg.id_, 1, '☘قفل همه _غیرفعال شد_', 1, 'md')
         database:del('bot:muteall'..msg.chat_id_)
      end
	  if unmutept[2] == "text" then
         send(msg.chat_id_, msg.id_, 1, '»متن _باز شد_', 1, 'md')
         database:del('bot:text:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "photo" then
         send(msg.chat_id_, msg.id_, 1, '»عکس _باز شد_', 1, 'md')
         database:del('bot:photo:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "video" then
         send(msg.chat_id_, msg.id_, 1, '»فیلم _باز شد_', 1, 'md')
         database:del('bot:video:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "inline" then
         send(msg.chat_id_, msg.id_, 1, '»اینلاین _باز شد_', 1, 'md')
         database:del('bot:inline:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "gifs" then
         send(msg.chat_id_, msg.id_, 1, '»گیف _باز شد_', 1, 'md')
         database:del('bot:gifs:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "music" then
         send(msg.chat_id_, msg.id_, 1, '»اهنگ _باز شد_', 1, 'md')
         database:del('bot:music:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "voice" then
         send(msg.chat_id_, msg.id_, 1, '»صدا _باز شد_', 1, 'md')
         database:del('bot:voice:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "links" then
         send(msg.chat_id_, msg.id_, 1, '»_لینک ازاد_ شد', 1, 'md')
         database:del('bot:links:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "location" then
         send(msg.chat_id_, msg.id_, 1, '»_موقعیت ازاد_ شد', 1, 'md')
         database:del('bot:location:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "tag" then
         send(msg.chat_id_, msg.id_, 1, '»_تگ ازاد_ شد', 1, 'md')
         database:del('bot:tag:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "hashtag" then
         send(msg.chat_id_, msg.id_, 1, '»_هشتگ ازاد_ شد', 1, 'md')
         database:del('bot:hashtag:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "contact" then
         send(msg.chat_id_, msg.id_, 1, '»_مخاطب ازاد_ شد', 1, 'md')
         database:del('bot:contact:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "webpage" then
         send(msg.chat_id_, msg.id_, 1, '»_وب لینک ازاد_ شد', 1, 'md')
         database:del('bot:webpage:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "arabic" then
         send(msg.chat_id_, msg.id_, 1, '»_فارسی ازاد_ شد', 1, 'md')
         database:del('bot:arabic:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "english" then
         send(msg.chat_id_, msg.id_, 1, '»_انگلیسی ازاد_ شد', 1, 'md')
         database:del('bot:english:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "service" then
         send(msg.chat_id_, msg.id_, 1, '»_اعلان ازاد_ شد', 1, 'md')
         database:del('bot:tgservice:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "sticker" then
         send(msg.chat_id_, msg.id_, 1, '»_استیکر ازاد_ شد', 1, 'md')
         database:del('bot:sticker:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "forward" then
         send(msg.chat_id_, msg.id_, 1, '»_فروارد آزاد_ شد', 1, 'md')
         database:del('bot:forward:mute'..msg.chat_id_)
      end 
	end
	-----------------------------------------------------------------------------------------------
  	if text:match("^[#!/]clean (._)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local txt = {string.match(text, "^[#/!](clean) (._)$")} 
       if txt[2] == 'banlist' then
	      database:del('bot:banned:'..msg.chat_id_)
          send(msg.chat_id_, msg.id_, 1, '_» لیست بن_ _خالی شد_', 1, 'md')
       end
	   if txt[2] == 'bots' then
	  local function g_bots(extra,result,success)
      local bots = result.members_
      for i=0 , #bots do
          chat_kick(msg.chat_id_,bots[i].user_id_)
          end
      end
    channel_get_bots(msg.chat_id_,g_bots)
	          send(msg.chat_id_, msg.id_, 1, '_» کل ربات ها_ _اخراج شدند!_', 1, 'md')
	end
	   if txt[2] == 'modlist' then
	      database:del('bot:mods:'..msg.chat_id_)
          send(msg.chat_id_, msg.id_, 1, '_» لیست مدیران_ _خالی شد_', 1, 'md')
       end
	   if txt[2] == 'mutelist' then
	      database:del('bot:muted:'..msg.chat_id_)
          send(msg.chat_id_, msg.id_, 1, '_» لیست ممنوعیت_ _خالی شد_', 1, 'md')
       end
    end
	-----------------------------------------------------------------------------------------------
  	if text:match("^[#!/]settings$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	if database:get('bot:muteall'..msg.chat_id_) then
	mute_all = '🔸قفل'
	else
	mute_all = '🔹آزاد'
	end
	------------
	if database:get('bot:text:mute'..msg.chat_id_) then
	mute_text = '🔸قفل'
	else
	mute_text = '🔹آزاد'
	end
	------------
	if database:get('bot:photo:mute'..msg.chat_id_) then
	mute_photo = '🔸قفل'
	else
	mute_photo = '🔹آزاد'
	end
	------------
	if database:get('bot:video:mute'..msg.chat_id_) then
	mute_video = '🔸قفل'
	else
	mute_video = '🔹آزاد'
	end
	------------
	if database:get('bot:gifs:mute'..msg.chat_id_) then
	mute_gifs = '🔸قفل'
	else
	mute_gifs = '🔹آزاد'
	end
	------------
	if database:get('anti-flood:'..msg.chat_id_) then
	mute_flood = '🔹آزاد'
	else
	mute_flood = '🔸قفل'
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
	mute_music = '🔸قفل'
	else
	mute_music = '🔹آزاد'
	end
	------------
	if database:get('bot:bots:mute'..msg.chat_id_) then
	mute_bots = '🔸قفل'
	else
	mute_bots = '🔹آزاد'
	end
	------------
	if database:get('bot:inline:mute'..msg.chat_id_) then
	mute_in = '🔸قفل'
	else
	mute_in = '🔹آزاد'
	end
	------------
	if database:get('bot:cmds'..msg.chat_id_) then
	mute_cmd = '🔹غیرفعال'
	else
	mute_cmd = '🔸فعال'
	end
	------------
	if database:get('bot:voice:mute'..msg.chat_id_) then
	mute_voice = '🔸قفل'
	else
	mute_voice = '🔹آزاد'
	end
	------------
	if database:get('editmsg'..msg.chat_id_) then
	mute_edit = '🔸قفل'
	else
	mute_edit = '🔹آزاد'
	end
    ------------
	if database:get('bot:links:mute'..msg.chat_id_) then
	mute_links = '🔸قفل'
	else
	mute_links = '🔹آزاد'
	end
    ------------
	if database:get('bot:pin:mute'..msg.chat_id_) then
	lock_pin = '🔸قفل'
	else
	lock_pin = '🔹آزاد'
	end 
    ------------
	if database:get('bot:sticker:mute'..msg.chat_id_) then
	lock_sticker = '🔸قفل'
	else
	lock_sticker = '🔹آزاد'
	end
	------------
    if database:get('bot:tgservice:mute'..msg.chat_id_) then
	lock_tgservice = '🔸قفل'
	else
	lock_tgservice = '🔹آزاد'
	end
	------------
    if database:get('bot:webpage:mute'..msg.chat_id_) then
	lock_wp = '🔸قفل'
	else
	lock_wp = '🔹آزاد'
	end
	------------
    if database:get('bot:hashtag:mute'..msg.chat_id_) then
	lock_htag = '🔸قفل'
	else
	lock_htag = '🔹آزاد'
	end
	------------
    if database:get('bot:tag:mute'..msg.chat_id_) then
	lock_tag = '🔸قفل'
	else
	lock_tag = '🔹آزاد'
	end
	------------
    if database:get('bot:location:mute'..msg.chat_id_) then
	lock_location = '🔸قفل'
	else
	lock_location = '🔹آزاد'
	end
	------------
    if database:get('bot:contact:mute'..msg.chat_id_) then
	lock_contact = '🔸قفل'
	else
	lock_contact = '🔹آزاد'
	end
	------------
    if database:get('bot:english:mute'..msg.chat_id_) then
	lock_english = '🔸قفل'
	else
	lock_english = '🔹آزاد'
	end
	------------
    if database:get('bot:arabic:mute'..msg.chat_id_) then
	lock_arabic = '🔸قفل'
	else
	lock_arabic = '🔹آزاد'
	end
	------------
    if database:get('bot:forward:mute'..msg.chat_id_) then
	lock_forward = '🔸قفل'
	else
	lock_forward = '🔹آزاد'
	end
	------------
	if database:get("bot:welcome"..msg.chat_id_) then
	send_welcome = 'Enable'
	else
	send_welcome = '🔹غیرفعال'
	end
	------------
	local ex = database:ttl("bot:charge:"..msg.chat_id_)
                if ex == -1 then
				exp_dat = 'نامحدود'
				else
				exp_dat = math.floor(ex / 86400) + 1
			    end
 	------------
	local TXT = "☘_تنظیمات گروه:_\n\n"
	          .."_خوش آمدگویی_ => `"..send_welcome.."`\n"
	          .."_استیکر_ => `"..lock_sticker.."`\n"
	          .."_اعلان_ => `"..lock_tgservice.."`\n"
	          .."_لینک_ => `"..mute_links.."`\n"
	          .."_وب لینک_ => `"..lock_wp.."`\n"
	          .."_تگ{@}_ => `"..lock_tag.."`\n"
	          .."_هشتگ{#}_ ~> `"..lock_htag.."`\n"
	          .."_مخاطب_ => `"..lock_contact.."`\n"
	          .."_انگلیسی_ => `"..lock_english.."`\n"
	          .."_موقعیت_ => `"..lock_location.."`\n"
	          .."_ربات_ => `"..mute_bots.."`\n"
	          .."_اینلاین_ => `"..mute_in.."`\n"
	          .."_فارسی_ => `"..lock_arabic.."`\n"
	          .."_فروارد_ => `"..lock_forward.."`\n"
	          .."_ویرایش_ => `"..mute_edit.."`\n"
	          .."_سنجاق_ => `"..lock_pin.."`\n"
	          .."_حساسیت_ => `"..mute_flood.."`\n"
	          .."_تعداد حساسیت_ => `"..flood_m.."`\n"
	          .."_زمان حساسیت_ => `"..flood_t.."`\n"
	          .."________________________\n"
	          .."_ممنوعیت همه_ => `"..mute_all.."`\n"
	          .."_متن_ => `"..mute_text.."`\n"
	          .."_عکس_ => `"..mute_photo.."`\n"
	          .."_فیلم_ => `"..mute_video.."`\n"
	          .."_گیف_ => `"..mute_gifs.."`\n"
	          .."_اهنگ_ => `"..mute_music.."`\n"
	          .."_صدا_ => `"..mute_voice.."`\n"
	          .."________________________\n"
	          .."_دستورات ربات_ => `"..mute_cmd.."`\n"
	          .."_زبان گروه_ => _EN_\n"
	          .."_تاریخ انقضا_ => `"..exp_dat.."`\n"
		  .."________________________\n"
	          .."_نام ربات_ => `ژوپیتر`\n"
	          .."_ورژن_ => _8.5_\n"
	          .."_کانال_ => @JoveTeam\n"
         send(msg.chat_id_, msg.id_, 1, TXT, 1, 'md')
    end
	-----------------------------------------------------------------------------------------------
  	if text:match("^[#!/]echo (._)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local txt = {string.match(text, "^[#/!](echo) (._)$")} 
         send(msg.chat_id_, msg.id_, 1, txt[2], 1, 'md')
    end
	-----------------------------------------------------------------------------------------------
  	if text:match("^[#!/]setrules (._)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local txt = {string.match(text, "^[#/!](setrules) (._)$")}
	database:set('bot:rules'..msg.chat_id_, txt[2])
         send(msg.chat_id_, msg.id_, 1, '☘_قوانین گروه بروز رسانی شد..._', 1, 'md')
    end
	-----------------------------------------------------------------------------------------------
  	if text:match("^[#!/]rules$") then
	local rules = database:get('bot:rules'..msg.chat_id_)
         send(msg.chat_id_, msg.id_, 1, rules, 1, nil)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]rename (._)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local txt = {string.match(text, "^[#/!](rename) (._)$")} 
	     changetitle(msg.chat_id_, txt[2])
         send(msg.chat_id_, msg.id_, 1, '☘_اسم گروه بروزرسانی شد!_', 1, 'md')
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]getme$") then
	function guser_by_reply(extra, result, success)
         --vardump(result)
    end
	     getUser(msg.sender_user_id_,guser_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]setphoto$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_عکس جدید را برای من بفرستید!_☘', 1, 'md')
		 database:set('bot:setphoto'..msg.chat_id_..':'..msg.sender_user_id_,true)
    end
	-----------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------
	if text:match("^[#!/]reload$") and is_sudo(msg) then
         send(msg.chat_id_, msg.id_, 1, '☘_آپدیت شد_', 1, 'md') -- wtf
    end
	-----------------------------------------------------------------------------------------------
  	if text:match("^[#!/]rmsg (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
       local delnumb = {string.match(text, "^[#/!](rmsg) (%d+)$")} 
	   if tonumber(delnumb[2]) > 100 then
			send(msg.chat_id_, msg.id_, 1, '☘خطا\nاز /del [1-100] استفاده کنید', 1, 'md')
else
       local id = msg.id_ - 1
        for i= id - delnumb[2] , id do 
        delete_msg(msg.chat_id_,{[0] = i})
        end
			send(msg.chat_id_, msg.id_, 1, '»'..delnumb[2]..' پیام حذف شد.', 1, 'md')
    end
	end
	-----------------------------------------------------------------------------------------------
   if text:match("^[#!/]me$") then
      if is_sudo(msg) then
	  t = '_سودو_'
      elseif is_admin(msg.sender_user_id_) then
	  t = '_ادمین ژوپیتر_'
      elseif is_owner(msg.sender_user_id_, msg.chat_id_) then
	  t = '_مالک گروه_'
      elseif is_mod(msg.sender_user_id_, msg.chat_id_) then
	  t = '_مدیر_'
      else
	  t = '_عضو_'
	  end
         send(msg.chat_id_, msg.id_, 1, '☘ _شناسه کاربری شما >_ _'..msg.sender_user_id_..'_\n☘ _مقام شما:_ '..t, 1, 'md')
    end
   -----------------------------------------------------------------------------------------------
   if text:match("^[#!/]pin$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
       pin(msg.chat_id_,msg.reply_to_message_id_,0)
	   database:set('pinnedmsg'..msg.chat_id_,msg.reply_to_message_id_)
   end
   -----------------------------------------------------------------------------------------------
   if text:match("^[#!/]unpin$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
         unpinmsg(msg.chat_id_)
         send(msg.chat_id_, msg.id_, 1, '☘پیام سنجاق حذف شد', 1, 'md')
   end
   -----------------------------------------------------------------------------------------------
   if text:match("^[#!/]help$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text = [[_راهنمای ربات

برای قفل کردن

/mute [links/webpage/sticker/service/tag/hashtag/contact/english/arabic/forward/all/photo/video/gifs/music/voice/text]

/lock [edit/pin]
---------
نکاتی درباره ی قفل های بالا

برای مثال درصورتیکه قصد دارید ارسال لینک قفل شود از دستور
/mute links
استفاده کنید.

هنگامی که از دستور 
/lock edit 
استفاده کنید وقتی اعضای گروه پیامی را ادیت کنند پیامشان پاک میشوذ
در صورتی که دوست دارید بفهمید متن قبل از ادیت کردن پیام چه چیزی بوده میتوانید از دستور 
/show edit 
استفاده کنید.

برای درست کار کردن دستور
/lock pin
باید ابتدا پیام مورد نظر را ارسال کرده و سپس با ریپلی کردن روی آن پیام و ارسال دستور 
/pin
و سپس ارسال دستور 
/lock pin
میتوانید دسترسی پین کردن پیام را از ادمین های گروه بگیرید و در صورت پین کردن پیامی توسط ادمین های دیگر ربات دوباره پیام شما را پین میکند


/unmute [links/webpage/sticker/service/tag/hashtag/contact/english/arabic/forward/all/photo/video/gifs/music/voice/text]
/unlock [edit/pin]
برای باز کردن قفل موارد بالا

/welcome on
فعال کردن پیام خوشامد گویی

/welcome off
غیر فعال کردن پیام خوشامد گویی

/get welcome متن مورد نظر
تنظیم کردن متن دلخواه به عنوان متن خوشامد گویی

برای نشان دادن ایدی و اسم از مثال زیر استفاده کنید.

#set welcome Salam {username} 
esmet {firstname}
familit {lastname}


/get welcome
حذف کردن پیام خوشامد گویی

/del welcome
حذف کردن پیام خوشامد گویی

/ban [فقط با ریپلی]
اخراج دایمی کاربر
/unban [فقط با ریپلی]
حذف کاربر از لیست افراد محروم
/banlist
لیست افراد محروم شده

/muteuser [فقط با ریپلی]
اضافه کردن کاربر به لیست افراد میوت شده
/unmuteuser [فقط با ریپلی]
حذف کردن کاربر به لیست افراد میوت شده
/mutelist
لیست افراد میوت شده

/promote [فقط با ریپلی]
ارتقا دادن کاربر
/demote [فقط با ریپلی]
خلع مقام کردن کاربر
/modlist
لیست ادمین های ربات در گروه

/getpro [1-10]
دریافت عکس پروفایل شما
مثال
/getpro 2

/setlink
تنظیم لینک برای گروه

/setrules قوانین
تنظیم متن قوانین گروه

/rules
دریافت قوانین

/settings
دریافت تنظیمات گروه

/clean [banlist/mutelist/modlist]
حذف کردن لیست افراد بن/میوت/پروموت شده

/del عدد
پاک کردن پیام های اخیر گروه
مثال
/del 100
برای پاک کردن 100 پیام آخر


راهنما بزودی کامل میشود!!!_
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   -----------------------------------------------------------------------------------------------
   if text:match("^[#!/]gview$") then
        database:set('bot:viewget'..msg.sender_user_id_,true)
        send(msg.chat_id_, msg.id_, 1, '_Please send a post now!_', 1, 'md')
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
  elseif (data.ID == "UpdateOption" and data.name_ == "my_id") then
    tdcli_function ({ID="GetChats", offset_order_="9223372036854775807", offset_chat_id_=0, limit_=20}, dl_cb, nil)    
  end
  -----------------------------------------------------------------------------------------------
end
