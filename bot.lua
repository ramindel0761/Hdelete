
----------------------------
--*********Serpent*******--
serpent = require("serpent")
--***********Lgi*********--
lgi = require('lgi')
--*********Redis*******--
redis = require('redis')
--*******DataBase******--
database = Redis.connect('127.0.0.1', 6379)
--*********Notify*******--
notify = lgi.require('Notify')
notify.init ("Telegram updates")
chats = {}
day = 86400
--*********BOT ID*******--
bot_id = 385919496 -- [[385919496]]
--**********************--
--*********SUDO ID*******--
sudo_users = {356602661} -- [[محل قرار گیری آیدی سودو ها]]
--***********************--
--********BOT OWNER******--
bot_owner = 356602661 -- [[ محل قرار گیری آیدی مدیر اصلی ربات ]]
--***********************--
-----------------------------------------------------------------------------------------------
---------------
-- Start Functions --
---------------
-----------------------------------------------------------------------------------------------
-----------Bot Owner-------------
function is_leader(msg)
  local var = false
  if msg.sender_user_id_ == tonumber(bot_owner) then
    var = true
  end
  return var
end

function is_leaderid(user_id)
  local var = false
  if user_id == tonumber(bot_owner) then
    var = true
  end
  return var
end
--------------Sudo----------------
function is_sudo(msg)
  local var = false
  for k,v in pairs(sudo_users) do
    if msg.sender_user_id_ == v then
      var = true
    end
  end
  if msg.sender_user_id_ == tonumber(bot_owner) then
    var = true
  end
  return var
end

function is_sudoid(user_id)
  local var = false
  for k,v in pairs(sudo_users) do
    if user_id == v then
      var = true
    end
  end
  if user_id == tonumber(bot_owner) then
    var = true
  end
  return var
end
---------------Admin-----------------
function is_admin(user_id)
  local var = false
  local hashsb =  'bot:admins:'
  local admin = database:sismember(hashsb, user_id)
  if admin then
    var = true
  end
  for k,v in pairs(sudo_users) do
    if user_id == v then
      var = true
    end
  end
  if user_id == tonumber(bot_owner) then
    var = true
  end
  return var
end
---------------Owner-------------------
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
  if user_id == tonumber(bot_owner) then
    var = true
  end
  return var
end
------------------Mod-------------------
function is_momod(user_id, chat_id)
  local var = false
  local hash =  'bot:momod:'..chat_id
  local momod = database:sismember(hash, user_id)
  local hashs =  'bot:admins:'
  local admin = database:sismember(hashs, user_id)
  local hashss =  'bot:owners:'..chat_id
  local owner = database:sismember(hashss, user_id)
  if momod then
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
  if user_id == tonumber(bot_owner) then
    var = true
  end
  return var
end
--------------VIP MEMBER-----------------
function is_vipmem(user_id, chat_id)
  local var = false
  local hash =  'bot:momod:'..chat_id
  local momod = database:sismember(hash, user_id)
  local hashs =  'bot:admins:'
  local admin = database:sismember(hashs, user_id)
  local hashss =  'bot:owners:'..chat_id
  local owner = database:sismember(hashss, user_id)
  local hashsss = 'bot:vipmem:'..chat_id
  local vipmem = database:sismember(hashsss, user_id)
  if vipmem then
    var = true
  end
  if momod then
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
  if user_id == tonumber(bot_owner) then
    var = true
  end
  return var
end
-------------------FreeWords--------------------
local function is_free(msg, value)
  local var = false
  local hash = 'bot:freewords:'..msg.chat_id_
  if hash then
    local names = database:hkeys(hash)
    local text = ''
    local value = value:gsub('-','')
    for i=1, #names do
      if string.match(value:lower(), names[i]:lower()) then
        var = true
      end
    end
  end
  return var
end
-------------------Banned---------------------
local function is_banned(user_id, chat_id)
  local var = false
  local hash = 'bot:banned:'..chat_id
  local banned = database:sismember(hash, user_id)
  if banned then
    var = true
  end
  return var
end
------------------Muted----------------------
local function is_muted(user_id, chat_id)
  local var = false
  local hash = 'bot:muted:'..chat_id
  local banned = database:sismember(hash, user_id)
  if banned then
    var = true
  end
  return var
end
------------------Gbaned--------------------
function is_gbanned(user_id)
  local var = false
  local hash = 'bot:gban:'
  local gbanned = database:sismember(hash, user_id)
  if gbanned then
    var = true
  end
  return var
end
--------------------------------------------------
function delete_msg(chatid ,mid)
  tdcli_function ({
    ID = "DeleteMessages",
    chat_id_ = chatid,
    message_ids_ = mid
  }, dl_cb, nil)
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
function do_notify (user, msg)
  local n = notify.Notification.new(user, msg)
  n:show ()
end
-----------------------------------------------------------------------------------------------
function chat_kick(chat_id, user_id)
  changeChatMemberStatus(chat_id, user_id, "Kicked")
end
-----------------------------------------------------------------------------------------------
function getParseMode(parse_mode)
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
function getMessage(chat_id, message_id,cb)
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
----------------------------------------------------------------------------------------------
function delete_msg(chatid ,mid)
  tdcli_function ({
    ID = "DeleteMessages",
    chat_id_ = chatid,
    message_ids_ = mid
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function send(chat_id, reply_to_message_id, disable_notification, text, disable_web_page_preview, parse_mode)
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
function pinmsg(channel_id, message_id, disable_notification) 
   tdcli_function ({ 
     ID = "PinChannelMessage", 
     channel_id_ = getChatId(channel_id).ID, 
     message_id_ = message_id, 
     disable_notification_ = disable_notification 
   }, dl_cb, nil) 
end 
------------------------------------------------------------------------------------------------
function unpinmsg(channel_id)
  tdcli_function ({
    ID = "UnpinChannelMessage",
    channel_id_ = getChatId(channel_id).ID
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function blockUser(user_id)
  tdcli_function ({
    ID = "BlockUser",
    user_id_ = user_id
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function unblockUser(user_id)
  tdcli_function ({
    ID = "UnblockUser",
    user_id_ = user_id
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function getBlockedUsers(offset, limit)
  tdcli_function ({
    ID = "GetBlockedUsers",
    offset_ = offset,
    limit_ = limit
  }, dl_cb, nil)
end
------------------------------------------------------------------------------------------------
function delmsg(arg,data)
  for k,v in pairs(data.messages_) do
    delete_msg(v.chat_id_,{[0] = v.id_})
  end
end
-------------------------------------------------------------------------------------------------
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
function channel_get_bots(channel,cb)
  local function callback_admins(extra,result,success)
    limit = result.member_count_
    getChannelMembers(channel, 0, 'Bots', limit,cb)
  end
  getChannelFull(channel,callback_admins)
end
-----------------------------------------------------------------------------------------------
function getInputMessageContent(file, filetype, caption)
  if file:match('/') or file:match('.') then
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
function getUser(user_id, cb)
  tdcli_function ({
    ID = "GetUser",
    user_id_ = user_id
  }, cb, nil)
end
----------------------------------------------------------------------------------------------
local function check_filter_words(msg, value)
  local hash = 'bot:filters:'..msg.chat_id_
  if hash then
    local names = database:hkeys(hash)
    local text = ''
	local value = value:gsub(' ','')
    for i=1, #names do
      if string.match(value:lower(), names[i]:lower()) and not is_momod(msg.sender_user_id_, msg.chat_id_)then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
      end
    end
  end
end
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
function tdcli_update_callback(data)
  -------------------------------------------
  if (data.ID == "UpdateNewMessage") then
    local msg = data.message_
    --vardump(data)
    local d = data.disable_notification_
    local chat = chats[msg.chat_id_]
    ----------------OLD MSG--------------------
    if msg.date_ < (os.time() - 30) then
      print("**** OLD MSG ****")
      return false
    end
    -------* Expire & AutoLeave *-------
    local expiretime = database:ttl("bot:charge:"..msg.chat_id_)
    if expiretime == 0 then
      local v = tonumber(bot_owner)
      send(v, 0, 1, "⭕️ تاریخ تمدید این گروه فرا رسید !\n🔹لینک : "..(database:get("bot:group:link"..msg.chat_id_) or "تنظیم نشده").."\n🔸شناسه گروه :  "..msg.chat_id_..'\n🔹نام گروه : '..chat.title_..'\n\n🔹اگر میخواهید ربات گروه را ترک کند از دستور زیر استفاده کنید :\n\n🔖 leave'..msg.chat_id_..'\n\n🔸اگر قصد وارد شدن به گروه را دارید از دستور زیر استفاده کنید :\n\n🔖 join'..msg.chat_id_..'\n\n🔹اگر میخواهید ربات داخل گروه اعلام کند از دستور زیر استفاده کنید :\n\n🔖 meld'..msg.chat_id_..'\n\n🔅🔅🔅🔅🔅🔅\n\n📅 اگر قصد تمدید گروه را دارید از دستورات زیر استفاده کنید : \n\n⭕️برای شارژ به صورت یک ماه :\n🔖 plan1'..msg.chat_id_..'\n\n⭕️برای شارژ به صورت سه ماه :\n🔖 plan2'..msg.chat_id_..'\n\n⭕️برای شارژ به صورت نامحدود :\n🔖 plan3'..msg.chat_id_, 1, 'html')
    end
    if database:get("autoleave") == "On" then
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
            local v = tonumber(bot_owner)
            send(v, 0, 1," >  🔙 ربات از گروہ با مشـפֿـصات زیر פֿـارج شد〽️☭! \n#نام_گروه 🇮🇷: "..chat.title_.."\n#آیدی_گروه 🆔: "..msg.chat_id_, 1, 'html')
          end
        end
      end
    end
    ---------* Secretary *-----------
    if database:get("clerk") == "On" then
      function clerk(extra, result, success)
        local id = tostring(msg.chat_id_)
        if id:match("^(%d+)") then
          if not is_admin(msg.sender_user_id_) then
            local text = database:get("textsec")
            if not database:get("secretary:"..msg.chat_id_) then
              if text then
                local text = text:gsub('FIRSTNAME',(result.first_name_ or ''))
                local text = text:gsub('LASTNAME',(result.last_name_ or ''))
                local text = text:gsub('USERNAME',('@'..result.username_ or ''))
                local text = text:gsub('USERID',(result.id_ or ''))
                send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
                database:setex("secretary:"..msg.chat_id_,86400,true)
                return false
              else
                return ""
              end
            end
          end
        end
      end
      getUser(msg.sender_user_id_,clerk)
    end
    -------------------------------------------
    local idf = tostring(msg.chat_id_)
    if not database:get("bot:enable:"..msg.chat_id_) and not idf:match("^(%d+)") and not is_admin(msg.sender_user_id_, msg.chat_id_) then
      print("Return False [ Not Enable ]")
      return false
    end
    -------------------------------------------
    if msg and msg.send_state_.ID == "MessageIsSuccessfullySent" then
      function get_mymsg_contact(extra, result, success)
      end
      getMessage(msg.chat_id_, msg.reply_to_message_id_,get_mymsg_contact)
      return
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
      if msg.reply_markup_ and msg.reply_markup_.ID == "ReplyMarkupInlineKeyboard" then
        print("This is [ Inline ]")
        msg_type = 'MSG:Inline'
      end
      -------------------------
      if msg.content_.ID == "MessageText" then
        text = msg.content_.text_
        print("This is [ Text ]")
        msg_type = 'MSG:Text'
      end
      -------------------------
      if msg.content_.ID == "MessagePhoto" then
        print("This is [ Photo ]")
        msg_type = 'MSG:Photo'
      end
      -------------------------
      if msg.content_.ID == "MessageChatAddMembers" then
        print("This is [ New User Add ]")
        msg_type = 'MSG:NewUserAdd'
      end
      -----------------------------------
      if msg.content_.ID == "MessageDocument" then
        print("This is [ File Or Document ]")
        msg_type = 'MSG:Document'
      end
      -------------------------
      if msg.content_.ID == "MessageSticker" then
        print("This is [ Sticker ]")
        msg_type = 'MSG:Sticker'
      end
      -------------------------
      if msg.content_.ID == "MessageAudio" then
        print("This is [ Audio ]")
        msg_type = 'MSG:Audio'
      end
      -------------------------
      if msg.content_.ID == "MessageVoice" then
        print("This is [ Voice ]")
        msg_type = 'MSG:Voice'
      end
      -------------------------
      if msg.content_.ID == "MessageVideo" then
        print("This is [ Video ]")
        msg_type = 'MSG:Video'
      end
      -------------------------
      if msg.content_.ID == "MessageAnimation" then
        print("This is [ Gif ]")
        msg_type = 'MSG:Gif'
      end
      -------------------------
      if msg.content_.ID == "MessageLocation" then
        print("This is [ Location ]")
        msg_type = 'MSG:Location'
      end
      -------------------------
      if msg.content_.ID == "MessageChatJoinByLink" then
        print("This is [ Msg Join By link ]")
        msg_type = 'MSG:NewUser'
      end
      -------------------------
      if not msg.reply_markup_ and msg.via_bot_user_id_ ~= 0 then
        print("This is [ MarkDown ]")
        msg_type = 'MSG:MarkDown'
      end
      -------------------------
      if msg.content_.ID == "MessageChatJoinByLink" then
        print("This is [ Msg Join By Link ]")
        msg_type = 'MSG:JoinByLink'
      end
      -------------------------
      if msg.content_.ID == "MessageContact" then
        print("This is [ Contact ]")
        msg_type = 'MSG:Contact'
      end
      -------------------------
    end
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
    ----------------------------------------Anti FLood---------------------------------------------
    --------------Flood Max --------------
    local flmax = 'flood:max:'..msg.chat_id_
    if not database:get(flmax) then
      floodMax = 5
    else
      floodMax = tonumber(database:get(flmax))
    end
    -----------------End-------------------
    -----------------Msg-------------------
    local pm = 'flood:'..msg.sender_user_id_..':'..msg.chat_id_..':msgs'
    if not database:get(pm) then
      msgs = 0
    else
      msgs = tonumber(database:get(pm))
    end
    -----------------End-------------------
    ------------Flood Check Time-----------
    local TIME_CHECK = 2
    -----------------End-------------------
    -------------Flood Check---------------
    local hashflood = 'anti-flood:'..msg.chat_id_
    if msgs > (floodMax - 1) then
      if database:get('floodstatus'..msg.chat_id_) == 'Kicked' then
        del_all_msgs(msg.chat_id_, msg.sender_user_id_)
        chat_kick(msg.chat_id_, msg.sender_user_id_)
      elseif database:get('floodstatus'..msg.chat_id_) == 'DelMsg' then
        del_all_msgs(msg.chat_id_, msg.sender_user_id_)
      else
        del_all_msgs(msg.chat_id_, msg.sender_user_id_)
      end
    end
    -----------------End-------------------

    --------------ANTI ATTACK-------------
    local pmonpv = 'antiattack:'..msg.sender_user_id_..':'..msg.chat_id_..':msgs'
    if not database:get(pmonpv) then
      msgsonpv = 0
    else
      msgsonpv = tonumber(database:get(pmonpv))
    end
    if msgsonpv > (13 - 1) then
      blockUser(msg.sender_user_id_)
    end
    local idmem = tostring(msg.chat_id_)
    if idmem:match("^(%d+)") then
      database:setex(pmonpv, TIME_CHECK, msgsonpv+1)
    end
    -------------------------------------- Process mod --------------------------------------------
    -----------------------------------------------------------------------------------------------

    -------------------------------------------------------------------------------------------------------
    -------------------------------------------------------------------------------------------------------
    -----------------------------******** START MSG CHECKS ********----------------------------------------
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
      delete_msg(chat,msgs)
      return
    end
    if database:get('bot:muteall'..msg.chat_id_) and not is_momod(msg.sender_user_id_, msg.chat_id_) then
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
        unpinmsg(msg.chat_id_)
        local pin_id = database:get('pinnedmsg'..msg.chat_id_)
        pinmsg(msg.chat_id_,pin_id,0)
      end
    end
    if database:get('bot:viewget'..msg.sender_user_id_) then
      if not msg.forward_info_ then
        if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '`Oᴘᴇʀᴀᴛɪᴏɴ اِرورEʀʀᴏʀ 🚯﹗` \n\n >` 🗯🎴Please re-submit the command and then view the number👁‍🗨 of hits to get forward more!`', 1, 'md')
        else
          send(msg.chat_id_, msg.id_, 1, '`🚷خطا در انجامERROr عملیات !`\n\n > `🗯🎴لطفا دستور را مجدد ارسال کنید و سپس عمل مشاهده تعداد بازدید 👁‍🗨را با فوروارد مطلب دریافت کنید` !', 1, 'md')
        end
        database:del('bot:viewget'..msg.sender_user_id_)
      else
        if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '>📊 The more 👁‍🗨hits you : '..msg.views_..' seen📯', 1, 'md')
        else
          send(msg.chat_id_, msg.id_, 1, '>📊 میزان بازدید 👁‍🗨پست شما: '..msg.views_..'📯 بازدید', 1, 'md')
        end
        database:del('bot:viewget'..msg.sender_user_id_)
      end
    end
    --Photo
    --Photo
    ------- --- Photo--------- Photo
    -- -----------------Photo
    --Photo
    --Photo
    if msg_type == 'MSG:Photo' then
      if not is_vipmem(msg.sender_user_id_, msg.chat_id_) then
        if database:get('anti-flood:'..msg.chat_id_) then
          database:setex(pm, TIME_CHECK, msgs+1)
        end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Fwd] [Photo]")
            end
          end
        end
        if database:get('bot:photo:mute'..msg.chat_id_) then
          local id = msg.id_
          local msgs = {[0] = id}
          local chat = msg.chat_id_
          delete_msg(chat,msgs)
          print("Deleted [Lock] [Photo]")
        end
        if msg.content_.caption_ then
          check_filter_words(msg, msg.content_.caption_)
          if database:get('bot:links:mute'..msg.chat_id_) then
            if msg.content_.caption_:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or msg.content_.caption_:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") or msg.content_.caption_:match("[Tt].[Mm][Ee]") then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Link] [Photo]")
              if database:get('bot:strict'..msg.chat_id_) then
                chat_kick(msg.chat_id_, msg.sender_user_id_)
              end
            end
          end
          if database:get('tags:lock'..msg.chat_id_) then
            if msg.content_.caption_:match("@") then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Tag] [Photo]")
            end
          end
          if msg.content_.caption_:match("#") then
            if database:get('bot:hashtag:mute'..msg.chat_id_) then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Hashtag] [Photo]")
            end
          end
          if msg.content_.caption_:match("[Hh][Tt][Tt][Pp][Ss]://") or msg.content_.caption_:match("[Hh][Tt][Tt][Pp]://") or msg.content_.caption_:match(".[Ii][Rr]") or msg.content_.caption_:match(".[Cc][Oo][Mm]") or msg.content_.caption_:match(".[Oo][Rr][Gg]") or msg.content_.caption_:match(".[Ii][Nn][Ff][Oo]") or msg.content_.caption_:match("[Ww][Ww][Ww].") or msg.content_.caption_:match(".[Tt][Kk]") or msg.content_.ID == "MessageEntityTextUrl" or msg.content_.ID == "MessageEntityUrl" then
            if database:get('bot:webpage:mute'..msg.chat_id_) then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Hashtag] [Photo]")
            end
          end
          if msg.content_.caption_:match("[\216-\219][\128-\191]") then
            if database:get('bot:arabic:mute'..msg.chat_id_) then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Farsi] [Photo]")
            end
          end
          if msg.content_.caption_:match("[A-Z]") or msg.content_.caption_:match("[a-z]") then
            if database:get('bot:english:mute'..msg.chat_id_) then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [English] [Photo]")
            end
          end
        end
      end

      --Markdown
      --Markdown
      ------- --- Markdown--------- Markdown
      -- -----------------Markdown
      --Markdown
      --Markdown
    elseif msg_type == 'MSG:MarkDown' then
      if database:get('markdown:lock'..msg.chat_id_) then
        if not is_vipmem(msg.sender_user_id_, msg.chat_id_) then
          local id = msg.id_
          local msgs = {[0] = id}
          local chat = msg.chat_id_
          delete_msg(chat,msgs)
        end
      end
      --Document
      --Document
      ------- --- Document--------- Document
      -- -----------------Document
      --Document
      --Document
    elseif msg_type == 'MSG:Document' then
      if not is_vipmem(msg.sender_user_id_, msg.chat_id_) then
        if database:get('anti-flood:'..msg.chat_id_) then
          database:setex(pm, TIME_CHECK, msgs+1)
        end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Fwd] [Document]")
            end
          end
        end
        if database:get('bot:document:mute'..msg.chat_id_) then
          local id = msg.id_
          local msgs = {[0] = id}
          local chat = msg.chat_id_
          delete_msg(chat,msgs)
          print("Deleted [Lock] [Document]")
        end
        if msg.content_.caption_ then
          check_filter_words(msg, msg.content_.caption_)
          if database:get('bot:links:mute'..msg.chat_id_) then
            if msg.content_.caption_:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or msg.content_.caption_:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") or msg.content_.caption_:match("[Tt].[Mm][Ee]") then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Link] [Document]")
              if database:get('bot:strict'..msg.chat_id_) then
                chat_kick(msg.chat_id_, msg.sender_user_id_)
              end
            end
          end
          if database:get('tags:lock'..msg.chat_id_) then
            if msg.content_.caption_:match("@") then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Tag] [Document]")
            end
          end
          if msg.content_.caption_:match("#") then
            if database:get('bot:hashtag:mute'..msg.chat_id_) then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Hashtag] [Document]")
            end
          end
          if msg.content_.caption_:match("[Hh][Tt][Tt][Pp][Ss]://") or msg.content_.caption_:match("[Hh][Tt][Tt][Pp]://") or msg.content_.caption_:match(".[Ii][Rr]") or msg.content_.caption_:match(".[Cc][Oo][Mm]") or msg.content_.caption_:match(".[Oo][Rr][Gg]") or msg.content_.caption_:match(".[Ii][Nn][Ff][Oo]") or msg.content_.caption_:match("[Ww][Ww][Ww].") or msg.content_.caption_:match(".[Tt][Kk]") or msg.content_.ID == "MessageEntityTextUrl" or msg.content_.ID == "MessageEntityUrl" then
            if database:get('bot:webpage:mute'..msg.chat_id_) then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Web] [Document]")
            end
          end
          if msg.content_.caption_:match("[\216-\219][\128-\191]") then
            if database:get('bot:arabic:mute'..msg.chat_id_) then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Farsi] [Document]")
            end
          end
          if msg.content_.caption_:match("[A-Z]") or msg.content_.caption_:match("[a-z]") then
            if database:get('bot:english:mute'..msg.chat_id_) then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [English] [Document]")
            end
          end
        end
      end
      --Inline
      --Inline
      ------- --- Inline--------- Inline
      -- -----------------Inline
      --Inline
      --Inline
    elseif msg.reply_markup_ and msg.reply_markup_.ID == "ReplyMarkupInlineKeyboard" and msg.via_bot_user_id_ ~= 0 then
      if not is_vipmem(msg.sender_user_id_, msg.chat_id_) then
        if database:get('anti-flood:'..msg.chat_id_) then
          database:setex(pm, TIME_CHECK, msgs+1)
        end
        if database:get('bot:inline:mute'..msg.chat_id_) then
          local id = msg.id_
          local msgs = {[0] = id}
          local chat = msg.chat_id_
          delete_msg(chat,msgs)
          print("Deleted [Lock] [Inline]")
        end
      end
      --Sticker
      --Sticker
      ------- --- Sticker--------- Sticker
      -- -----------------Sticker
      --Sticker
      --Sticker
    elseif msg_type == 'MSG:Sticker' then
      if not is_vipmem(msg.sender_user_id_, msg.chat_id_) then
        if database:get('anti-flood:'..msg.chat_id_) then
          database:setex(pm, TIME_CHECK, msgs+1)
        end
        if database:get('bot:sticker:mute'..msg.chat_id_) then
          local id = msg.id_
          local msgs = {[0] = id}
          local chat = msg.chat_id_
          delete_msg(chat,msgs)
          print("Deleted [Lock] [Sticker]")
        end
      end
    elseif msg_type == 'MSG:JoinByLink' then
      if database:get('bot:tgservice:mute'..msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
        print("Deleted [Lock] [Tgservice] [JoinByLink]")
        return
      end
      function get_welcome(extra,result,success)
        if database:get('welcome:'..msg.chat_id_) then
          text = database:get('welcome:'..msg.chat_id_)
        else
          if database:get('lang:gp:'..msg.chat_id_) then
            text = 'нı✌ {firstname} ➳🃏 Wεʟcσмε Tσ ➳ Gяσυρ🀄️ 👥✘'
          else
            text = 'سلاܢܢ 💕{firstname}  ⚜פֿـوش اومدی 🇮🇷'
          end
        end
        local text = text:gsub('{firstname}',(result.first_name_ or ''))
        local text = text:gsub('{lastname}',(result.last_name_ or ''))
        local text = text:gsub('{username}',(result.username_ or ''))
        local text = text:gsub('{gpname}',(chat.title_ or ''))
        send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
      end
      if database:get("bot:welcome"..msg.chat_id_) then
        getUser(msg.sender_user_id_,get_welcome)
      end
      --New User Add
      --New User Add
      ------- --- New User Add--------- New User Add
      -- -----------------New User Add
      --New User Add
      --New User Add
    elseif msg_type == 'MSG:NewUserAdd' then
      if database:get('bot:tgservice:mute'..msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
        print("Deleted [Lock] [Tgservice] [NewUserAdd]")
        return
      end
      if msg.content_.members_[0].username_ and msg.content_.members_[0].username_:match("[Bb][Oo][Tt]$") then
        if not is_momod(msg.content_.members_[0].id_, msg.chat_id_) then
          if database:get('bot:bots:mute'..msg.chat_id_) then
            chat_kick(msg.chat_id_, msg.content_.members_[0].id_)
            return false
          end
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
          if database:get('lang:gp:'..msg.chat_id_) then
            text = 'Hi Welcome To Group'
          else
            text = 'سلام خوش اومدی'
          end
        end
        local text = text:gsub('{firstname}',(msg.content_.members_[0].first_name_ or ''))
        local text = text:gsub('{lastname}',(msg.content_.members_[0].last_name_ or ''))
        local text = text:gsub('{username}',('@'..msg.content_.members_[0].username_ or ''))
        send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
      end
      --Contact
      --Contact
      ------- --- Contact--------- Contact
      -- -----------------Contact
      --Contact
      --Contact
    elseif msg_type == 'MSG:Contact' then
      if not is_vipmem(msg.sender_user_id_, msg.chat_id_) then
        if database:get('anti-flood:'..msg.chat_id_) then
          database:setex(pm, TIME_CHECK, msgs+1)
        end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Fwd] [Contact]")
            end
          end
        end
        if database:get('bot:contact:mute'..msg.chat_id_) then
          local id = msg.id_
          local msgs = {[0] = id}
          local chat = msg.chat_id_
          delete_msg(chat,msgs)
          print("Deleted [Lock] [Contact]")
        end
      end
      --Audio
      --Audio
      ------- --- Audio--------- Audio
      -- -----------------Audio
      --Audio
      --Audio
    elseif msg_type == 'MSG:Audio' then
      if not is_vipmem(msg.sender_user_id_, msg.chat_id_) then
        if database:get('anti-flood:'..msg.chat_id_) then
          database:setex(pm, TIME_CHECK, msgs+1)
        end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Fwd] [Audio]")
            end
          end
        end
        if database:get('bot:music:mute'..msg.chat_id_) then
          local id = msg.id_
          local msgs = {[0] = id}
          local chat = msg.chat_id_
          delete_msg(chat,msgs)
          print("Deleted [Lock] [Audio]")
        end
        if msg.content_.caption_ then
          check_filter_words(msg, msg.content_.caption_)
          if database:get('bot:links:mute'..msg.chat_id_) then
            if msg.content_.caption_:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or msg.content_.caption_:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") or msg.content_.caption_:match("[Tt].[Mm][Ee]") then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Link] [Audio]")
            end
          end
          if database:get('tags:lock'..msg.chat_id_) then
            if msg.content_.caption_:match("@") then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Tag] [Audio]")
            end
          end
          if msg.content_.caption_:match("#") then
            if database:get('bot:hashtag:mute'..msg.chat_id_) then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Hashtag] [Audio]")
            end
          end
          if msg.content_.caption_:match("[Hh][Tt][Tt][Pp][Ss]://") or msg.content_.caption_:match("[Hh][Tt][Tt][Pp]://") or msg.content_.caption_:match(".[Ii][Rr]") or msg.content_.caption_:match(".[Cc][Oo][Mm]") or msg.content_.caption_:match(".[Oo][Rr][Gg]") or msg.content_.caption_:match(".[Ii][Nn][Ff][Oo]") or msg.content_.caption_:match("[Ww][Ww][Ww].") or msg.content_.caption_:match(".[Tt][Kk]") or msg.content_.ID == "MessageEntityTextUrl" or msg.content_.ID == "MessageEntityUrl" then
            if database:get('bot:webpage:mute'..msg.chat_id_) then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Web] [Audio]")
            end
          end
          if msg.content_.caption_:match("[\216-\219][\128-\191]") then
            if database:get('bot:arabic:mute'..msg.chat_id_) then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Farsi] [Audio]")
            end
          end
          if msg.content_.caption_:match("[A-Z]") or msg.content_.caption_:match("[a-z]") then
            if database:get('bot:english:mute'..msg.chat_id_) then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [English] [Audio]")
            end
          end
        end
      end
      --Voice
      --Voice
      ------- --- Voice--------- Voice
      -- -----------------Voice
      --Voice
      --Voice
    elseif msg_type == 'MSG:Voice' then
      if not is_vipmem(msg.sender_user_id_, msg.chat_id_) then
        if database:get('anti-flood:'..msg.chat_id_) then
          database:setex(pm, TIME_CHECK, msgs+1)
        end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Fwd] [Voice]")
            end
          end
        end
        if database:get('bot:voice:mute'..msg.chat_id_) then
          local id = msg.id_
          local msgs = {[0] = id}
          local chat = msg.chat_id_
          delete_msg(chat,msgs)
          print("Deleted [Lock] [Voice]")
        end
        if msg.content_.caption_ then
          check_filter_words(msg, msg.content_.caption_)
          if database:get('bot:links:mute'..msg.chat_id_) then
            if msg.content_.caption_:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or msg.content_.caption_:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") or msg.content_.caption_:match("[Tt].[Mm][Ee]") then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Link] [Voice]")
            end
          end
          if database:get('tags:lock'..msg.chat_id_) then
            if msg.content_.caption_:match("@") then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Tag] [Voice]")
            end
          end
          if msg.content_.caption_:match("#") then
            if database:get('bot:hashtag:mute'..msg.chat_id_) then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Hashtag] [Voice]")
            end
          end
          if msg.content_.caption_:match("[Hh][Tt][Tt][Pp][Ss]://") or msg.content_.caption_:match("[Hh][Tt][Tt][Pp]://") or msg.content_.caption_:match(".[Ii][Rr]") or msg.content_.caption_:match(".[Cc][Oo][Mm]") or msg.content_.caption_:match(".[Oo][Rr][Gg]") or msg.content_.caption_:match(".[Ii][Nn][Ff][Oo]") or msg.content_.caption_:match("[Ww][Ww][Ww].") or msg.content_.caption_:match(".[Tt][Kk]") or msg.content_.ID == "MessageEntityTextUrl" or msg.content_.ID == "MessageEntityUrl" then
            if database:get('bot:webpage:mute'..msg.chat_id_) then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Web] [Voice]")
            end
          end
          if msg.content_.caption_:match("[\216-\219][\128-\191]") then
            if database:get('bot:arabic:mute'..msg.chat_id_) then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Farsi] [Voice]")
            end
          end
          if msg.content_.caption_:match("[A-Z]") or msg.content_.caption_:match("[a-z]") then
            if database:get('bot:english:mute'..msg.chat_id_) then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [English] [Voice]")
            end
          end
        end
      end
      --Location
      --Location
      ------- --- Location--------- Location
      -- -----------------Location
      --Location
      --Location
    elseif msg_type == 'MSG:Location' then
      if not is_vipmem(msg.sender_user_id_, msg.chat_id_) then
        if database:get('anti-flood:'..msg.chat_id_) then
          database:setex(pm, TIME_CHECK, msgs+1)
        end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [English] [Location]")
            end
          end
        end
        if database:get('bot:location:mute'..msg.chat_id_) then
          local id = msg.id_
          local msgs = {[0] = id}
          local chat = msg.chat_id_
          delete_msg(chat,msgs)
          print("Deleted [Lock] [Location]")
          return
        end
        if msg.content_.caption_ then
          check_filter_words(msg, msg.content_.caption_)
          if database:get('bot:links:mute'..msg.chat_id_) then
            if msg.content_.caption_:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or msg.content_.caption_:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") or msg.content_.caption_:match("[Tt].[Mm][Ee]") then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Link] [Location]")
            end
          end
          if database:get('tags:lock'..msg.chat_id_) then
            if msg.content_.caption_:match("@") then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Tag] [Location]")
            end
          end
          if msg.content_.caption_:match("#") then
            if database:get('bot:hashtag:mute'..msg.chat_id_) then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Hashtag] [Location]")
            end
          end
          if msg.content_.caption_:match("[Hh][Tt][Tt][Pp][Ss]://") or msg.content_.caption_:match("[Hh][Tt][Tt][Pp]://") or msg.content_.caption_:match(".[Ii][Rr]") or msg.content_.caption_:match(".[Cc][Oo][Mm]") or msg.content_.caption_:match(".[Oo][Rr][Gg]") or msg.content_.caption_:match(".[Ii][Nn][Ff][Oo]") or msg.content_.caption_:match("[Ww][Ww][Ww].") or msg.content_.caption_:match(".[Tt][Kk]") or msg.content_.ID == "MessageEntityTextUrl" or msg.content_.ID == "MessageEntityUrl" then
            if database:get('bot:webpage:mute'..msg.chat_id_) then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Web] [Location]")
            end
          end
          if msg.content_.caption_:match("[\216-\219][\128-\191]") then
            if database:get('bot:arabic:mute'..msg.chat_id_) then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Farsi] [Location]")
            end
          end
          if msg.content_.caption_:match("[A-Z]") or msg.content_.caption_:match("[a-z]") then
            if database:get('bot:english:mute'..msg.chat_id_) then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [English] [Location]")
            end
          end
        end
      end
      --Video
      --Video
      ------- --- Video--------- Video
      -- -----------------Video
      --Video
      --Video
    elseif msg_type == 'MSG:Video' then
      if not is_vipmem(msg.sender_user_id_, msg.chat_id_) then
        if database:get('anti-flood:'..msg.chat_id_) then
          database:setex(pm, TIME_CHECK, msgs+1)
        end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Fwd] [Video]")
            end
          end
        end
        if database:get('bot:video:mute'..msg.chat_id_) then
          local id = msg.id_
          local msgs = {[0] = id}
          local chat = msg.chat_id_
          delete_msg(chat,msgs)
          print("Deleted [Lock] [Video]")
        end
        if msg.content_.caption_ then
          check_filter_words(msg, msg.content_.caption_)
          if database:get('bot:links:mute'..msg.chat_id_) then
            if msg.content_.caption_:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or msg.content_.caption_:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") or msg.content_.caption_:match("[Tt].[Mm][Ee]") then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Link] [Video]")
            end
          end
          if database:get('tags:lock'..msg.chat_id_) then
            if msg.content_.caption_:match("@") then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Tag] [Video]")
            end
          end
          if msg.content_.caption_:match("#") then
            if database:get('bot:hashtag:mute'..msg.chat_id_) then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Hashtag] [Video]")
            end
          end
          if msg.content_.caption_:match("[Hh][Tt][Tt][Pp][Ss]://") or msg.content_.caption_:match("[Hh][Tt][Tt][Pp]://") or msg.content_.caption_:match(".[Ii][Rr]") or msg.content_.caption_:match(".[Cc][Oo][Mm]") or msg.content_.caption_:match(".[Oo][Rr][Gg]") or msg.content_.caption_:match(".[Ii][Nn][Ff][Oo]") or msg.content_.caption_:match("[Ww][Ww][Ww].") or msg.content_.caption_:match(".[Tt][Kk]") or msg.content_.ID == "MessageEntityTextUrl" or msg.content_.ID == "MessageEntityUrl" then
            if database:get('bot:webpage:mute'..msg.chat_id_) then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Web] [Video] ")
            end
          end
          if msg.content_.caption_:match("[\216-\219][\128-\191]") then
            if database:get('bot:arabic:mute'..msg.chat_id_) then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Farsi] [Video] ")
            end
          end
          if msg.content_.caption_:match("[A-Z]") or msg.content_.caption_:match("[a-z]") then
            if database:get('bot:english:mute'..msg.chat_id_) then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [English] [Video]")
            end
          end
        end
      end
      --Gif
      --Gif
      ------- --- Gif--------- Gif
      -- -----------------Gif
      --Gif
      --Gif
    elseif msg_type == 'MSG:Gif' then
      if not is_vipmem(msg.sender_user_id_, msg.chat_id_) then
        if database:get('anti-flood:'..msg.chat_id_) then
          database:setex(pm, TIME_CHECK, msgs+1)
        end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Fwd] [Gif]")
            end
          end
        end
        if database:get('bot:gifs:mute'..msg.chat_id_) then
          local id = msg.id_
          local msgs = {[0] = id}
          local chat = msg.chat_id_
          delete_msg(chat,msgs)
          print("Deleted [Lock] [Gif]")
        end
        if msg.content_.caption_ then
          check_filter_words(msg, msg.content_.caption_)
          if database:get('bot:links:mute'..msg.chat_id_) then
            if msg.content_.caption_:match("[Hh][Tt][Tt][Pp][Ss]://") or msg.content_.caption_:match("[Hh][Tt][Tt][Pp]://") then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Link] [Gif] ")
            end
          end
          if database:get('tags:lock'..msg.chat_id_) then
            if msg.content_.caption_:match("@") then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Tag] [Gif]")
            end
          end
          if msg.content_.caption_:match("#") then
            if database:get('bot:hashtag:mute'..msg.chat_id_) then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Hashtag] [Gif]")
            end
          end
          if msg.content_.caption_:match("[Hh][Tt][Tt][Pp][Ss]://") or msg.content_.caption_:match("[Hh][Tt][Tt][Pp]://") or msg.content_.caption_:match(".[Ii][Rr]") or msg.content_.caption_:match(".[Cc][Oo][Mm]") or msg.content_.caption_:match(".[Oo][Rr][Gg]") or msg.content_.caption_:match(".[Ii][Nn][Ff][Oo]") or msg.content_.caption_:match("[Ww][Ww][Ww].") or msg.content_.caption_:match(".[Tt][Kk]") then
            if database:get('bot:webpage:mute'..msg.chat_id_) then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Web] [Gif]")
            end
          end
          if msg.content_.caption_:match("[\216-\219][\128-\191]") then
            if database:get('bot:arabic:mute'..msg.chat_id_) then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Farsi] [Gif]")
            end
          end
          if msg.content_.caption_:match("[A-Z]") or msg.content_.caption_:match("[a-z]") then
            if database:get('bot:english:mute'..msg.chat_id_) then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [English] [Gif]")
            end
          end
        end
      end
      --Text
      --Text
      ------- --- Text--------- Text
      -- -----------------Text
      --Text
      --Text
    elseif msg_type == 'MSG:Text' then
      if not is_vipmem(msg.sender_user_id_, msg.chat_id_) then
        if database:get('anti-flood:'..msg.chat_id_) then
          database:setex(pm, TIME_CHECK, msgs+1)
        end
      end
      --vardump(msg)
      if database:get("bot:group:link"..msg.chat_id_) == 'waiting' and is_momod(msg.sender_user_id_, msg.chat_id_) then
        if msg.content_.text_:match("(https://telegram.me/joinchat/%S+)") or msg.content_.text_:match("(https://t.me/joinchat/%S+)") then
          local glink = msg.content_.text_:match("(https://telegram.me/joinchat/%S+)") or msg.content_.text_:match("(https://t.me/joinchat/%S+)")
          local hash = "bot:group:link"..msg.chat_id_
          database:set(hash,glink)
          if database:get('lang:gp:'..msg.chat_id_) then
            send(msg.chat_id_, msg.id_, 1, '`⚜Group link has been saved 🇮🇷`', 1, 'md')
          else
            send(msg.chat_id_, msg.id_, 1, ' `لینک گروه ثبت شد 🇮🇷`', 1, 'md')
          end
        end
      end
      function check_username(extra,result,success)
        --vardump(result)
        local username = (result.username_ or '')
        local svuser = 'user:'..result.id_
        if username then
          database:hset(svuser, 'username', username)
        end
        if username and username:match("[Bb][Oo][Tt]$") or username:match("_[Bb][Oo][Tt]$") then
          if database:get('bot:bots:mute'..msg.chat_id_) and not is_momod(msg.chat_id_, msg.chat_id_) then
            local id = msg.id_
            local msgs = {[0] = id}
            local chat = msg.chat_id_
            delete_msg(chat,msgs)
            chat_kick(msg.chat_id_, msg.sender_user_id_)
            return false
          end
        end
      end
      getUser(msg.sender_user_id_,check_username)
      database:set('bot:editid'.. msg.id_,msg.content_.text_)
      if not is_free(msg, msg.content_.text_) then
        if not is_vipmem(msg.sender_user_id_, msg.chat_id_) then
          check_filter_words(msg,text)
          if text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") or text:match("[Tt].[Mm][Ee]") then
            if database:get('bot:links:mute'..msg.chat_id_) then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Link] [Text]")
              if database:get('bot:strict'..msg.chat_id_) then
                chat_kick(msg.chat_id_, msg.sender_user_id_)
              end
            end
          end
          if database:get('bot:text:mute'..msg.chat_id_) then
            local id = msg.id_
            local msgs = {[0] = id}
            local chat = msg.chat_id_
            delete_msg(chat,msgs)
            print("Deleted [Lock] [Text]")
          end
          if msg.forward_info_ then
            if database:get('bot:forward:mute'..msg.chat_id_) then
              if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
                local id = msg.id_
                local msgs = {[0] = id}
                local chat = msg.chat_id_
                delete_msg(chat,msgs)
                print("Deleted [Lock] [Fwd] [Text]")
              end
            end
          end
          if msg.content_.text_:match("@") then
            if database:get('tags:lock'..msg.chat_id_) then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Tag] [Text]")
            end
          end
          if msg.content_.text_:match("#") then
            if database:get('bot:hashtag:mute'..msg.chat_id_) then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Hashtag] [Text]")
            end
          end
          if text:match("[Hh][Tt][Tt][Pp][Ss]://") or text:match("[Hh][Tt][Tt][Pp]://") or text:match(".[Ii][Rr]") or text:match(".[Cc][Oo][Mm]") or text:match(".[Oo][Rr][Gg]") or text:match(".[Ii][Nn][Ff][Oo]") or text:match("[Ww][Ww][Ww].") or text:match(".[Tt][Kk]") or msg.content_.ID == "MessageEntityTextUrl" or msg.content_.ID == "MessageEntityUrl" then
            if database:get('bot:webpage:mute'..msg.chat_id_) then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Web] [Text]")
            end
          end
          if msg.content_.text_:match("[\216-\219][\128-\191]") then
            if database:get('bot:arabic:mute'..msg.chat_id_) then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Farsi] [Text]")
            end
          end
          if msg.content_.text_ then
            local _nl, ctrl_chars = string.gsub(text, '%c', '')
            local _nl, real_digits = string.gsub(text, '%d', '')
            local id = msg.id_
            local msgs = {[0] = id}
            local chat = msg.chat_id_
            local hash = 'bot:sens:spam'..msg.chat_id_
            if not database:get(hash) then
              sens = 400
            else
              sens = tonumber(database:get(hash))
            end
            if database:get('bot:spam:mute'..msg.chat_id_) and string.len(msg.content_.text_) > (sens) or ctrl_chars > (sens) or real_digits > (sens) then
              delete_msg(chat,msgs)
              print("Deleted [Lock] [Spam] ")
            end
          end
          if msg.content_.text_:match("[A-Z]") or msg.content_.text_:match("[a-z]") then
            if database:get('bot:english:mute'..msg.chat_id_) then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
              print("Deleted [Lock] [English] [Text]")
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
	 local text = text:gsub('[!/#]','')
      if database:get('bot:cmds'..msg.chat_id_) and not is_momod(msg.sender_user_id_, msg.chat_id_) then
        print("Return False [Lock] [Cmd]")
        return false
      else
        ------------------------------------ With Pattern -------------------------------------------
        if is_momod(msg.sender_user_id_, msg.chat_id_) then
          if text:match("^[!/#]ping$") or text:match("^پینگ$") then
            if database:get('lang:gp:'..msg.chat_id_) then
              send(msg.chat_id_, msg.id_, 1, '*🇮🇷ᴏɴʟɪɴᴇ...*', 1, 'md')
            else
              send(msg.chat_id_, msg.id_, 1, '`🔰رُبات هَمچّناטּ در حال مُدیریَت گُروہ مِیباشَد 🇮🇷`', 1, 'md')
            end
          end
        end
        -----------------------------------------------------------------------------------------------
        if is_admin(msg.sender_user_id_, msg.chat_id_) then
          if text:match("^[!/#][Ll]eave$") or text:match("^ترک گروه$") then
            chat_leave(msg.chat_id_, bot_id)
            database:srem("bot:groups",msg.chat_id_)
          end
        end
        -----------------------------------------------------------------------------------------------
        local text = msg.content_.text_:gsub('ارتقا مقام','Promote')
        if text:match("^[!/#][Pp]romote$") and is_owner(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ ~= 0  then
          function promote_by_reply(extra, result, success)
            local hash = 'bot:momod:'..msg.chat_id_
            if database:sismember(hash, result.sender_user_id_) then
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> 👤Usᴇʀ 🇮🇷: '..result.sender_user_id_..'`🎴is now a moderator🃏`', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> 👤ڪًـاربر با شِناسِـہ 🇮🇷: '..result.sender_user_id_..'`🎴هم اکنون مدیر است🃏` !', 1, 'md')
              end
            else
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> 👤Usᴇʀ 🇮🇷: '..result.sender_user_id_..'🃏*ᴘʀᴏᴍᴏᴛᴇᴅ* ƬƠ ᴍᴏᴅᴇʀᴀᴛᴏʀ🇮🇷', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> 👤ڪًـاربر با شِناسِـہ 🇮🇷: '..result.sender_user_id_..' `☈🃏به مدیریت ارتقا مقام یافت🇮🇷` !', 1, 'md')
              end
              database:sadd(hash, result.sender_user_id_)
            end
          end
          getMessage(msg.chat_id_, msg.reply_to_message_id_,promote_by_reply)
        end
        -----------------------------------------------------------------------------------------------
        if text:match("^[!/#][Pp]romote @(.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
          local ap = {string.match(text, "^([!/#][Pp]romote) @(.*)$")}
          function promote_by_username(extra, result, success)
            if result.id_ then
              if database:get('lang:gp:'..msg.chat_id_) then
                texts = '> 🔻Usᴇʀ 🔸:'..result.id_..'🌐*ᴘʀᴏᴍᴏᴛᴇᴅ* ƬƠ ᴍᴏᴅᴇʀᴀᴛᴏʀ🃏'
              else
                texts = '>👤ڪـاربر با شِناسِـہ 🇮🇷: '..result.id_..'⚜ `بـہ مدیریت ارتقا مقام یافت🉐!`'
              end
              database:sadd('bot:momod:'..msg.chat_id_, result.id_)
            else
              if not database:get('lang:gp:'..msg.chat_id_) then
                texts = '>⚠️ Usᴇʀ ɴᴏᴛ ғᴏᴜɴᴅ'
              else
                texts = '>  ڪًـاربر یافت نشد ! ⚠️'
              end
            end
            send(msg.chat_id_, msg.id_, 1, texts, 1, 'md')
          end
          resolve_username(ap[2],promote_by_username)
        end
        -----------------------------------------------------------------------------------------------
        if text:match("^[!/#][Pp]romote (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
          local ap = {string.match(text, "^([!/#][Pp]romote) (%d+)$")}
          if database:get('lang:gp:'..msg.chat_id_) then
            send(msg.chat_id_, msg.id_, 1, '> 🔻Usᴇʀ 🔸: '..ap[2]..'🌐*ᴘʀᴏᴍᴏᴛᴇᴅ* ƬƠ ᴍᴏᴅᴇʀᴀᴛᴏʀ🃏', 1, 'md')
          else
            send(msg.chat_id_, msg.id_, 1, '>👤ڪـاربر با شِناسِـہ 🇮🇷: '..ap[2]..' ⚜ `بـہ مدیریت ارتقا مقام یافت🉐!`', 1, 'md')
          end
          database:sadd('bot:momod:'..msg.chat_id_, ap[2])
        end
        -----------------------------------------------------------------------------------------------
        local text = msg.content_.text_:gsub('عزل مقام','Demote')
        if text:match("^[!/#][Dd]emote$") and is_owner(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ ~= 0 then
          function demote_by_reply(extra, result, success)
            local hash = 'bot:momod:'..msg.chat_id_
            if not database:sismember(hash, result.sender_user_id_) then
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> 🔻Usᴇʀ 🔸: '..result.sender_user_id_..'🚫 ɪs ɴᴏᴛ ᴀ ᴍᴏᴅᴇʀᴀᴛᴏʀ🌐﹗', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '>👤ڪـاربر با شِناسِـہ 🇮🇷: '..result.sender_user_id_..' 🚫 مدیر نمیباشد〽️ !', 1, 'md')
              end
            else
              database:srem(hash, result.sender_user_id_)
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> 🔻Usᴇʀ 🔸: '..result.sender_user_id_..' 〽️ᴡᴀs *reмoved*❌ ƒяσм ᴍᴏᴅᴇʀᴀᴛᴏʀ 🌐!', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '>👤ڪـاربر با شِناسِـہ 🇮🇷: '..result.sender_user_id_..' 〽️از مدیریت حذف❌ شد 🌐!', 1, 'md')
              end
            end
          end
          getMessage(msg.chat_id_, msg.reply_to_message_id_,demote_by_reply)
        end
        -----------------------------------------------------------------------------------------------
        if text:match("^[!/#][Dd]emote @(.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
          local hash = 'bot:momod:'..msg.chat_id_
          local ap = {string.match(text, "^([!/#][Dd]emote) @(.*)$")}
          function demote_by_username(extra, result, success)
            if result.id_ then
              if database:get('lang:gp:'..msg.chat_id_) then
                texts = '> 🔻Usᴇʀ 🔸: '..result.id_..'〽️ ᴡᴀs ɗємσтєɗ❌'
              else
                texts = '>👤ڪـاربر با شِناسِـہ 🇮🇷: '..result.id_..'〽️ عزل مقام شد❌'
              end
              database:srem(hash, result.id_)
            else
              if not database:get('lang:gp:'..msg.chat_id_) then
                texts = '>⚠️ Usᴇʀ ɴᴏᴛ ғᴏᴜɴᴅ !'
              else
                texts = '>  ڪًـاربر یافت نشد ⚠️'
              end
            end
            send(msg.chat_id_, msg.id_, 1, texts, 1, 'md')
          end
          resolve_username(ap[2],demote_by_username)
        end
        -----------------------------------------------------------------------------------------------
        if text:match("^[!/#][Dd]emote (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
          local hash = 'bot:momod:'..msg.chat_id_
          local ap = {string.match(text, "^([!/#][Dd]emote) (%d+)$")}
          if database:get('lang:gp:'..msg.chat_id_) then
            send(msg.chat_id_, msg.id_, 1, '> 🔻Usᴇʀ 🔸: '..ap[2]..' 〽️ᴡᴀs ɗємσтєɗ❌ !', 1, 'md')
          else
            send(msg.chat_id_, msg.id_, 1, '>👤ڪـاربر با شِناسِـہ 🇮🇷: '..ap[2]..' 〽️ عزل مقام شد❌ !', 1, 'md')
          end
          database:srem(hash, ap[2])
        end
        -----------------------------------------------------------------------------------------------
        if is_momod(msg.sender_user_id_, msg.chat_id_) then
          local text = msg.content_.text_:gsub('ارتقا به عضو ویژه','Setvip')
          if text:match("^[!/#][Ss]etvip$") and msg.reply_to_message_id_ ~= 0  then
            function promote_by_reply(extra, result, success)
              local hash = 'bot:vipmem:'..msg.chat_id_
              if database:sismember(hash, result.sender_user_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> 🔻Usᴇʀ 🔸: '..result.sender_user_id_..' is now a VIP member !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '>👤ڪـاربر با شِناسِـہ 🇮🇷: '..result.sender_user_id_..' هم اکنون عضو ویژه است !', 1, 'md')
                end
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> 🔻Usᴇʀ 🔸: '..result.sender_user_id_..' *promoted* to VIP member !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '>👤ڪـاربر با شِناسِـہ 🇮🇷: '..result.sender_user_id_..' به عضو ویژه ارتقا مقام یافت !', 1, 'md')
                end
                database:sadd(hash, result.sender_user_id_)
              end
            end
            getMessage(msg.chat_id_, msg.reply_to_message_id_,promote_by_reply)
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[!/#][Ss]etvip @(.*)$") then
            local ap = {string.match(text, "^([!/#][Ss]etvip) @(.*)$")}
            function promote_by_username(extra, result, success)
              if result.id_ then
                if database:get('lang:gp:'..msg.chat_id_) then
                  texts = '> User :'..result.id_..' *promoted* to VIP member !'
                else
                  texts = '> کاربر با شناسه : '..result.id_..' به عضو ویژه ارتقا مقام یافت !'
                end
                database:sadd('bot:vipmem:'..msg.chat_id_, result.id_)
              else
                if not database:get('lang:gp:'..msg.chat_id_) then
                  texts = '> User not found'
                else
                  texts = '> کاربر یافت نشد !'
                end
              end
              send(msg.chat_id_, msg.id_, 1, texts, 1, 'md')
            end
            resolve_username(ap[2],promote_by_username)
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[!/#][Ss]etvip (%d+)$") then
            local ap = {string.match(text, "^([!/#][Ss]etvip) (%d+)$")}
            if database:get('lang:gp:'..msg.chat_id_) then
              send(msg.chat_id_, msg.id_, 1, '> User : '..ap[2]..' *promoted* to VIP member !', 1, 'md')
            else
              send(msg.chat_id_, msg.id_, 1, '> کاربر با شناسه : '..ap[2]..' به عضو ویژه ارتقا مقام یافت !', 1, 'md')
            end
            database:sadd('bot:vipmem:'..msg.chat_id_, ap[2])
          end
          -----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('حذف از عضو ویژه','Demvip')
          if text:match("^[!/#][Dd]emvip$") and msg.reply_to_message_id_ ~= 0 then
            function demote_by_reply(extra, result, success)
              local hash = 'bot:vipmem:'..msg.chat_id_
              if not database:sismember(hash, result.sender_user_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> User : '..result.sender_user_id_..' is not a VIP member !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> کاربر با شناسه : '..result.sender_user_id_..' مدیر نمیباشد !', 1, 'md')
                end
              else
                database:srem(hash, result.sender_user_id_)
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> User : '..result.sender_user_id_..' was *removed* from VIP member !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> کاربر با شناسه : '..result.sender_user_id_..' از عضو ویژه حذف شد !', 1, 'md')
                end
              end
            end
            getMessage(msg.chat_id_, msg.reply_to_message_id_,demote_by_reply)
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[!/#][Dd]emvip @(.*)$") then
            local hash = 'bot:vipmem:'..msg.chat_id_
            local ap = {string.match(text, "^([!/#][Dd]emvip) @(.*)$")}
            function demote_by_username(extra, result, success)
              if result.id_ then
                if database:get('lang:gp:'..msg.chat_id_) then
                  texts = '> User : '..result.id_..' was demoted from VIP member !'
                else
                  texts = '> کاربر با شناسه : '..result.id_..' از عضو ویژه حذف شد !'
                end
                database:srem(hash, result.id_)
              else
                if not database:get('lang:gp:'..msg.chat_id_) then
                  texts = '> User not found !'
                else
                  texts = '> کاربر یافت نشد !'
                end
              end
              send(msg.chat_id_, msg.id_, 1, texts, 1, 'md')
            end
            resolve_username(ap[2],demote_by_username)
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[!/#][Dd]emvip (%d+)$") then
            local hash = 'bot:vipmem:'..msg.chat_id_
            local ap = {string.match(text, "^([!/#][Dd]emvip) (%d+)$")}
            if database:get('lang:gp:'..msg.chat_id_) then
              send(msg.chat_id_, msg.id_, 1, '> User : '..ap[2]..' was demoted from VIP member !', 1, 'md')
            else
              send(msg.chat_id_, msg.id_, 1, '> کاربر با شناسه : '..ap[2]..' از عضو ویژه شد !', 1, 'md')
            end
            database:srem(hash, ap[2])
          end
        end
        -------------------------------------------------------------------------------------------------------
        if text:match("^[!/#][Gg]p id$") or text:match("^شناسه گروه$") then
          if database:get('lang:gp:'..msg.chat_id_) then
            texts = "> Group ID : "..msg.chat_id_
          else
            texts = "> شناسه گروه : "..msg.chat_id_
          end
          send(msg.chat_id_, msg.id_, 1, texts, 1, 'md')
        end
        -----------------------------------------------------------------------------------------------
        if text:match("^[!/#][Mm]y username$") or text:match("^یوزرنیم من$") then
          function get_username(extra,result,success)
            if database:get('lang:gp:'..msg.chat_id_) then
              text = '> Your Username : {User}'
            else
              text = '> یوزرنیم شما : {User}'
            end
            local text = text:gsub('{User}',('@'..result.username_ or ''))
            send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
          end
          getUser(msg.sender_user_id_,get_username)
        end
        -----------------------------------------------------------------------------------------------
        if is_momod(msg.sender_user_id_, msg.chat_id_) then
          if text:match("^[!/#][Dd]el$") or text:match("^حذف$") and is_sudo(msg) and msg.reply_to_message_id_ ~= 0 then
            local id = msg.id_
            local msgs = {[0] = id}
            delete_msg(msg.chat_id_,{[0] = msg.reply_to_message_id_})
            delete_msg(msg.chat_id_,msgs)
          end
          ----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('مسدود','Ban')
          if text:match("^[!/#][Bb]an$") and msg.reply_to_message_id_ ~= 0 then
            function ban_by_reply(extra, result, success)
              local hash = 'bot:banned:'..msg.chat_id_
              if not is_momod(result.sender_user_id_, result.chat_id_) then
                if database:sismember(hash, result.sender_user_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, '> User : '..result.sender_user_id_..' is already banned !', 1, 'md')
                  else
                    send(msg.chat_id_, msg.id_, 1, '> کاربر با شناسه : '..result.sender_user_id_..' هم اکنون مسدود است !', 1, 'md')
                  end
                  chat_kick(result.chat_id_, result.sender_user_id_)
                else
                  database:sadd(hash, result.sender_user_id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, '> User : '..result.sender_user_id_..' has been banned !', 1, 'md')
                  else
                    send(msg.chat_id_, msg.id_, 1, '> کاربر با شناسه : '..result.sender_user_id_..' مسدود گردید !', 1, 'md')
                  end
                  chat_kick(result.chat_id_, result.sender_user_id_)
                end
              end
            end
            getMessage(msg.chat_id_, msg.reply_to_message_id_,ban_by_reply)
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[!/#][Bb]an @(.*)$") then
            local ap = {string.match(text, "^([!/#][Bb]an) @(.*)$")}
            function ban_by_username(extra, result, success)
              if result.id_ then
                if not is_momod(result.id_, msg.chat_id_) then
                  database:sadd('bot:banned:'..msg.chat_id_, result.id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
                    texts = '> User : '..result.id_..' has been banned !'
                  else
                    texts = '> کاربر با شناسه : '..result.id_..' مسدود گردید !'
                  end
                  chat_kick(msg.chat_id_, result.id_)
                end
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  texts = '> User not found'
                else
                  texts = '> کاربر یافت نشد !'
                end
              end
              send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
            end
            resolve_username(ap[2],ban_by_username)
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[!/#][Bb]an (%d+)$") then
            local ap = {string.match(text, "^([!/#][Bb]an) (%d+)$")}
            if not is_momod(ap[2], msg.chat_id_) then
              database:sadd('bot:banned:'..msg.chat_id_, ap[2])
              chat_kick(msg.chat_id_, ap[2])
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> User : '..ap[2]..' has been banned !', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> کاربر با شناسه : '..ap[2]..' مسدود گردید !', 1, 'md')
              end
            end
          end
          -----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('حذف کلی پیام','Delall')
          if text:match("^[!/#][Dd]elall$") and msg.reply_to_message_id_ ~= 0 then
            function delall_by_reply(extra, result, success)
              del_all_msgs(result.chat_id_, result.sender_user_id_)
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
            getMessage(msg.chat_id_, msg.reply_to_message_id_,delall_by_reply)
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[!/#][Dd]elall (%d+)$") then
            local ass = {string.match(text, "^([!/#][Dd]elall) (%d+)$")}
            if not ass then
              return false
            else
              del_all_msgs(msg.chat_id_, ass[2])
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> All messages from User : '..ass[2]..' has been deleted !', 1, 'html')
              else
                send(msg.chat_id_, msg.id_, 1, '> تمامی پیام های ارسالی کاربر با شناسه : '..ass[2]..' حذف شد !', 1, 'html')
              end
            end
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[!/#][Dd]elall @(.*)$") then
            local ap = {string.match(text, "^([!/#][Dd]elall) @(.*)$")}
            function delall_by_username(extra, result, success)
              if result.id_ then
                del_all_msgs(msg.chat_id_, result.id_)
                if database:get('lang:gp:'..msg.chat_id_) then
                  text = '> All messages from User : '..result.id_..' has been deleted !'
                else
                  text = '> تمامی پیام های ارسالی کاربر با شناسه : '..result.id_..' حذف شد !'
                end
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  text = '> User not found !'
                else
                  text = '> کاربر یافت نشد !'
                end
              end
              send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
            resolve_username(ap[2],delall_by_username)
          end
          -----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('آزاد کردن','Unban')
          if text:match("^[!/#][Uu]nban$") and msg.reply_to_message_id_ ~= 0 then
            function unban_by_reply(extra, result, success)
              local hash = 'bot:banned:'..msg.chat_id_
              if not database:sismember(hash, result.sender_user_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> User : '..result.sender_user_id_..' is not banned !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> کاربر با شناسه : '..result.sender_user_id_..' مسدود نیست !', 1, 'md')
                end
              else
                database:srem(hash, result.sender_user_id_)
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> User : '..result.sender_user_id_..' has been unbanned !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> کاربر با شناسه : '..result.sender_user_id_..' آزاد شد !', 1, 'md')
                end
              end
            end
            getMessage(msg.chat_id_, msg.reply_to_message_id_,unban_by_reply)
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[!/#][Uu]nban @(.*)$") then
            local ap = {string.match(text, "^([!/#][Uu]nban) @(.*)$")}
            function unban_by_username(extra, result, success)
              if result.id_ then
                if not database:sismember('bot:banned:'..msg.chat_id_, result.id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, '> User : '..result.id_..' is not banned !', 1, 'md')
                  else
                    send(msg.chat_id_, msg.id_, 1, '> کاربر با شناسه : '..result.id_..' مسدود نیست !', 1, 'md')
                  end
                else
                  database:srem('bot:banned:'..msg.chat_id_, result.id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
                    text = '> User : '..result.id_..' has been unbanned !'
                  else
                    text = '> کاربر با شناسه : '..result.id_..' آزاد شد !'
                  end
                end
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  text = '> User not found !'
                else
                  text = '> کاربر یافت نشد !'
                end
              end
              send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
            resolve_username(ap[2],unban_by_username)
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[!/#][Uu]nban (%d+)$") then
            local ap = {string.match(text, "^([!/#][Uu]nban) (%d+)$")}
            if not database:sismember('bot:banned:'..msg.chat_id_, ap[2]) then
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> User : '..ap[2]..' is not banned !', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> کاربر با شناسه : '..ap[2]..' مسدود نیست !', 1, 'md')
              end
            else
              database:srem('bot:banned:'..msg.chat_id_, ap[2])
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> User : '..ap[2]..' has been unbanned !', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> کاربر با شناسه : '..ap[2]..' آزاد شد !', 1, 'md')
              end
            end
          end
          ---------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('مسدودسازی','Banall')
          if text:match("^[!/#][Bb]anall$") and is_sudo(msg) and msg.reply_to_message_id_ then
            function gban_by_reply(extra, result, success)
              local hash = 'bot:gban:'
              database:sadd(hash, result.sender_user_id_)
              chat_kick(result.chat_id_, result.sender_user_id_)
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> User : '..result.sender_user_id_..' has been globaly banned !', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> کاربر با شناسه : '..result.sender_user_id_..' به طور کلی مسدود سازی گردید !', 1, 'md')
              end
            end
            getMessage(msg.chat_id_, msg.reply_to_message_id_,gban_by_reply)
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[!/#][Bb]anall @(.*)$") and is_sudo(msg) then
            local aps = {string.match(text, "^([!/#][Bb]anall) @(.*)$")}
            function gban_by_username(extra, result, success)
              local hash = 'bot:gban:'
              if result.id_ then
                if database:get('lang:gp:'..msg.chat_id_) then
                  text = '> User : '..result.id_..' has been globaly banned !'
                else
                  text = '> کاربر با شناسه : '..result.id_..' به صورت کلی مسدود گردید !'
                end
                database:sadd(hash, result.id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  text = '> User not found !'
                else
                  text = '> کاربر یافت نشد !'
                end
              end
              send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
            resolve_username(aps[2],gban_by_username)
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[!/#][Bb]anall (%d+)$") and is_sudo(msg) then
            local ap = {string.match(text, "^([!/#][Bb]anall) (%d+)$")}
            local hash = 'bot:gban:'
            if database:get('lang:gp:'..msg.chat_id_) then
              send(msg.chat_id_, msg.id_, 1, '> User : '..ap[2]..' has been globaly banned !', 1, 'md')
            else
              send(msg.chat_id_, msg.id_, 1, '> کاربر با شناسه : '..ap[2]..' به صورت کلی مسدود گردید !', 1, 'md')
            end
            database:set('bot:gban:'..ap[2],true)
            database:sadd(hash, ap[2])
          end
          -----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('آزادسازی','unbanall')
          if text:match("^[!/#][Uu]nbanall$") and is_sudo(msg) and msg.reply_to_message_id_ then
            function ungban_by_reply(extra, result, success)
              local hash = 'bot:gban:'
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> User : '..result.sender_user_id_..' has been unbanned (Gban)!', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> کاربر با شناسه : '..result.sender_user_id_..' آزادسازی شد !', 1, 'md')
              end
              database:srem(hash, result.sender_user_id_)
            end
            getMessage(msg.chat_id_, msg.reply_to_message_id_,ungban_by_reply)
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[!/#][Uu]nbanall @(.*)$") and is_sudo(msg) then
            local apid = {string.match(text, "^([!/#][Uu]nbanall) @(.*)$")}
            function ungban_by_username(extra, result, success)
              local hash = 'bot:gban:'
              if result.id_ then
                if database:get('lang:gp:'..msg.chat_id_) then
                  text = '> User : '..result.id_..' has been unbanned (Gban) !'
                else
                  text = '> کاربر با شناسه : '..result.id_..' از لیست مسدودیت ربات آزاد شد !'
                end
                database:srem(hash, result.id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  text = '> User not found !'
                else
                  text = '> کاربر یافت نشد !'
                end
              end
              send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
            resolve_username(apid[2],ungban_by_username)
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[!/#][Uu]nbanall (%d+)$") and is_sudo(msg) then
            local ap = {string.match(text, "^([!/#][Uu]nbanall) (%d+)$")}
            local hash = 'bot:gban:'
              database:srem(hash, ap[2])
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> User : '..ap[2]..' has been unbanned !', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> کاربر با شناسه : '..ap[2]..' آزادسازی شد !', 1, 'md')
              end
            end
          -----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('بی صدا','Muteuser')
          if text:match("^[!/#][Mm]uteuser$") and msg.reply_to_message_id_ ~= 0 then
            function mute_by_reply(extra, result, success)
              local hash = 'bot:muted:'..msg.chat_id_
              if database:sismember(hash, result.sender_user_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> User : '..result.sender_user_id_..' is already muted !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> کاربر با شناسه : '..result.sender_user_id_..' هم اکنون بی صدا است !', 1, 'md')
                end
              else
                database:sadd(hash, result.sender_user_id_)
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> User : '..result.sender_user_id_..' has been muted !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> کاربر با شناسه : '..result.sender_user_id_..' بی صدا گردید !', 1, 'md')
                end
              end
            end
            getMessage(msg.chat_id_, msg.reply_to_message_id_,mute_by_reply)
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[!/#][Mm]uteuser @(.*)$") then
            local ap = {string.match(text, "^([!/#][Mm]uteuser) @(.*)$")}
            function mute_by_username(extra, result, success)
              if result.id_ then
                database:sadd('bot:muted:'..msg.chat_id_, result.id_)
                if database:get('lang:gp:'..msg.chat_id_) then
                  texts = '> User : '..result.id_..' has been muted !'
                else
                  texts = '> کاربر با شناسه : '..result.id_..' بی صدا گردید !'
                end
                chat_kick(msg.chat_id_, result.id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  texts = '> User not found !'
                else
                  texts = '> کاربر یافت نشد !'
                end
              end
              send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
            end
            resolve_username(ap[2],mute_by_username)
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[!/#][Mm]uteuser (%d+)$") then
            local ap = {string.match(text, "^([!/#][Mm]uteuser) (%d+)$")}
            if database:sismember('bot:muted:'..msg.chat_id_, ap[2]) then
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> User : '..ap[2]..' is already muted !', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> کاربر با شناسه : '..ap[2]..' هم اکنون بی صدا است !', 1, 'md')
              end
            else
              database:sadd('bot:muted:'..msg.chat_id_, ap[2])
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> User : '..ap[2]..' has been muted !', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> کاربر با شناسه : '..ap[2]..' بی صدا گردید !', 1, 'md')
              end
            end
          end
          -----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('حذف بی صدا','Unmuteuser')
          if text:match("^[!/#][Uu]nmuteuser$") and msg.reply_to_message_id_ ~= 0 then
            function unmute_by_reply(extra, result, success)
              local hash = 'bot:muted:'..msg.chat_id_
              if not database:sismember(hash, result.sender_user_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> User : '..result.sender_user_id_..' not muted !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> کاربر با شناسه : '..result.sender_user_id_..' بی صدا نیست !', 1, 'md')
                end
              else
                database:srem(hash, result.sender_user_id_)
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> User : '..result.sender_user_id_..' has been unmuted !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> کاربر با شناسه : '..result.sender_user_id_..' از حالت بی صدا خارج گردید !', 1, 'md')
                end
              end
            end
            getMessage(msg.chat_id_, msg.reply_to_message_id_,unmute_by_reply)
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[!/#][Uu]nmuteuser @(.*)$") then
            local ap = {string.match(text, "^([!/#][Uu]nmuteuser) @(.*)$")}
            function unmute_by_username(extra, result, success)
              if result.id_ then
                if not database:sismember('bot:muted:'..msg.chat_id_, result.id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, '> User : '..result.id_..' is not muted !', 1, 'md')
                  else
                    send(msg.chat_id_, msg.id_, 1, '> کاربر با شناسه : '..result.id_..' بی صدا نیست !', 1, 'md')
                  end
                else
                  database:srem('bot:muted:'..msg.chat_id_, result.id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
                    text = '> User : '..result.id_..' has been unmuted !'
                  else
                    text = '> کاربر با شناسه : '..result.id_..' از حالت بی صدا خارج گردید !'
                  end
                end
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  text = '> User not found !'
                else
                  text = '> کاربر یافت نشد !'
                end
              end
              send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
            resolve_username(ap[2],unmute_by_username)
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[!/#][Uu]nmuteuser (%d+)$") then
            local ap = {string.match(text, "^([!/#][Uu]nmuteuser) (%d+)$")}
            if not database:sismember('bot:muted:'..msg.chat_id_, ap[2]) then
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> User : '..ap[2]..' is not muted !', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> کاربر با شناسه : '..ap[2]..' بی صدا نیست !', 1, 'md')
              end
            else
              database:srem('bot:muted:'..msg.chat_id_, ap[2])
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> User : '..ap[2]..' has been unmuted !', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> کاربر با شناسه : '..ap[2]..' از حالت بی صدا خارج گردید !', 1, 'md')
              end
            end
          end
        end
        -----------------------------------------------------------------------------------------------
        local text = msg.content_.text_:gsub('ارتقا به صاحب گروه','Setowner')
        if text:match("^[!/#][Ss]etowner$") and is_admin(msg.sender_user_id_) and msg.reply_to_message_id_ ~= 0 then
          function setowner_by_reply(extra, result, success)
            local hash = 'bot:owners:'..msg.chat_id_
            if database:sismember(hash, result.sender_user_id_) then
              if database:get('lang:gp:'..msg.chat_id_) then

              else
                send(msg.chat_id_, msg.id_, 1, '> کاربر '..result.sender_user_id_..' هم اکنون صاحب گروه میباشد !', 1, 'md')
              end
            else
              database:sadd(hash, result.sender_user_id_)
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> User : '..result.sender_user_id_..' added to owner list !', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> کاربر '..result.sender_user_id_..' به عنوان صاحب گروه انتخاب شد !', 1, 'md')
              end
            end
          end
          getMessage(msg.chat_id_, msg.reply_to_message_id_,setowner_by_reply)
        end
        -----------------------------------------------------------------------------------------------
        if text:match("^[!/#][Ss]etowner @(.*)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
          local ap = {string.match(text, "^([!/#][Ss]etowner) @(.*)$")}
          function setowner_by_username(extra, result, success)
            if result.id_ then
              database:sadd('bot:owners:'..msg.chat_id_, result.id_)
              if database:get('lang:gp:'..msg.chat_id_) then
                texts = '> User : '..result.id_..' added to owner list !'
              else
                texts = '> کاربر '..result.id_..' به عنوان صاحب گروه انتخاب شد !'
              end
            else
              if database:get('lang:gp:'..msg.chat_id_) then
                texts = '> User not found !'
              else
                texts = '> کاربر یافت نشد !'
              end
            end
            send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
          end
          resolve_username(ap[2],setowner_by_username)
        end
        -----------------------------------------------------------------------------------------------
        if text:match("^[!/#][Ss]etowner (%d+)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
          local ap = {string.match(text, "^([!/#][Ss]etowner) (%d+)$")}
          database:sadd('bot:owners:'..msg.chat_id_, ap[2])
          if database:get('lang:gp:'..msg.chat_id_) then
            send(msg.chat_id_, msg.id_, 1, '> User : '..ap[2]..' added to owner list !', 1, 'md')
          else
            send(msg.chat_id_, msg.id_, 1, '> کاربر '..ap[2]..' به عنوان صاحب گروه انتخاب شد !', 1, 'md')
          end
        end
        -----------------------------------------------------------------------------------------------
        local text = msg.content_.text_:gsub('حذف از صاحب گروه','Demowner')
        if text:match("^[!/#][Dd]emowner$") and is_admin(msg.sender_user_id_) and msg.reply_to_message_id_ ~= 0 then
          function deowner_by_reply(extra, result, success)
            local hash = 'bot:owners:'..msg.chat_id_
            if not database:sismember(hash, result.sender_user_id_) then
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> User : '..result.sender_user_id_..' is not a owner !', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> کاربر : '..result.sender_user_id_..' صاحب گروه نیست !', 1, 'md')
              end
            else
              database:srem(hash, result.sender_user_id_)
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> User : '..result.sender_user_id_..' removed from owner list !', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> کاربر : '..result.sender_user_id_..' از مقام صاحب گروه حذف شد !', 1, 'md')
              end
            end
          end
          getMessage(msg.chat_id_, msg.reply_to_message_id_,deowner_by_reply)
        end
        -----------------------------------------------------------------------------------------------
        if text:match("^[!/#][Dd]emowner @(.*)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
          local hash = 'bot:owners:'..msg.chat_id_
          local ap = {string.match(text, "^([!/#][Dd]emowner) @(.*)$")}
          function remowner_by_username(extra, result, success)
            if result.id_ then
              database:srem(hash, result.id_)
              if database:get('lang:gp:'..msg.chat_id_) then
                texts = '> User : '..result.id_..' removed from owner list !'
              else
                texts = '> کاربر : '..result.id_..' از مقام صاحب گروه حذف شد !'
              end
            else
              if database:get('lang:gp:'..msg.chat_id_) then
                texts = '> User not found !'
              else
                texts = '> کاربر یافت نشد !'
              end
            end
            send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
          end
          resolve_username(ap[2],remowner_by_username)
        end
        -----------------------------------------------------------------------------------------------
        if text:match("^[!/#][Dd]emowner (%d+)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
          local hash = 'bot:owners:'..msg.chat_id_
          local ap = {string.match(text, "^([!/#][Dd]emowner) (%d+)$")}
          database:srem(hash, ap[2])
          if database:get('lang:gp:'..msg.chat_id_) then
            send(msg.chat_id_, msg.id_, 1, '> User : '..ap[2]..' removed from owner list !', 1, 'md')
          else
            send(msg.chat_id_, msg.id_, 1, '> کاربر : '..ap[2]..' از مقام صاحب گروه حذف شد !', 1, 'md')
          end
        end
        -----------------------------------------------------------------------------------------------
        local text = msg.content_.text_:gsub('ارتقا به ادمین ربات','Addadmin')
        if text:match("^[!/#][Aa]ddadmin$") and is_sudo(msg) and msg.reply_to_message_id_ ~= 0 then
          function addadmin_by_reply(extra, result, success)
            local hash = 'bot:admins:'
            if database:sismember(hash, result.sender_user_id_) then
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> User : '..result.sender_user_id_..' is already admin !', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> کاربر : '..result.sender_user_id_..' هم اکنون ادمین است !', 1, 'md')
              end
            else
              database:sadd(hash, result.sender_user_id_)
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> User : '..result.sender_user_id_..' added to admin list !', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> کاربر : '..result.sender_user_id_..' به ادمین ها اضافه شد !', 1, 'md')
              end
            end
          end
          getMessage(msg.chat_id_, msg.reply_to_message_id_,addadmin_by_reply)
        end
        -----------------------------------------------------------------------------------------------
        if text:match("^[!/#][Aa]ddadmin @(.*)$") and is_sudo(msg) then
          local ap = {string.match(text, "^([!/#][Aa]ddadmin) @(.*)$")}
          function addadmin_by_username(extra, result, success)
            if result.id_ then
              if database:get('lang:gp:'..msg.chat_id_) then
                texts = '> User : '..result.id_..' added to admin list !'
              else
                texts = '> کاربر : '..result.id_..' به ادمین ها اضافه شد !'
              end
              database:sadd('bot:admins:', result.id_)
            else
              if database:get('lang:gp:'..msg.chat_id_) then
                texts = '> User not found !'
              else
                texts = '> کاربر یافت نشد !'
              end
            end
            send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
          end
          resolve_username(ap[2],addadmin_by_username)
        end
        -----------------------------------------------------------------------------------------------
        if text:match("^[!/#][Aa]ddadmin (%d+)$") and is_sudo(msg) then
          local ap = {string.match(text, "^([!/#][Aa]ddadmin) (%d+)$")}
          if database:get('lang:gp:'..msg.chat_id_) then
            send(msg.chat_id_, msg.id_, 1, '> User : '..ap[2]..' added to admin list !', 1, 'md')
          else
            send(msg.chat_id_, msg.id_, 1, '> کاربر : '..ap[2]..' به ادمین ها اضافه شد !', 1, 'md')
          end
          database:sadd('bot:admins:', ap[2])
        end
        -----------------------------------------------------------------------------------------------
        local text = msg.content_.text_:gsub('حذف از ادمین ربات','Remadmin')
        if text:match("^[!/#][Rr]emadmin$") and is_sudo(msg) and msg.reply_to_message_id_ ~= 0 then
          function deadmin_by_reply(extra, result, success)
            local hash = 'bot:admins:'
            if not database:sismember(hash, result.sender_user_id_) then
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> User : '..result.sender_user_id_..' is not admin !', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> کاربر : '..result.sender_user_id_..' ادمین نیست !', 1, 'md')
              end
            else
              database:srem(hash, result.sender_user_id_)
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> User : '..result.sender_user_id_..' removed from admin list !', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> کاربر : '..result.sender_user_id_..' از ادمینی حذف شد !', 1, 'md')
              end
            end
          end
          getMessage(msg.chat_id_, msg.reply_to_message_id_,deadmin_by_reply)
        end
        -----------------------------------------------------------------------------------------------
        if text:match("^[!/#][Rr]emadmin @(.*)$") and is_sudo(msg) then
          local hash = 'bot:admins:'
          local ap = {string.match(text, "^([!/#][Rr]emadmin) @(.*)$")}
          function remadmin_by_username(extra, result, success)
            if result.id_ then
              database:srem(hash, result.id_)
              if database:get('lang:gp:'..msg.chat_id_) then
                texts = '> User : '..result.id_..' removed from admin list !'
              else
                texts = '> کاربر : '..result.id_..' از ادمینی حذف شد !'
              end
            else
              if database:get('lang:gp:'..msg.chat_id_) then
                texts = '> User not found !'
              else
                texts = '> کاربر یافت نشد !'
              end
            end
            send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
          end
          resolve_username(ap[2],remadmin_by_username)
        end
        -----------------------------------------------------------------------------------------------
        if text:match("^[!/#][Rr]emadmin (%d+)$") and is_sudo(msg) then
          local hash = 'bot:admins:'
          local ap = {string.match(text, "^([!/#][Rr]emadmin) (%d+)$")}
          database:srem(hash, ap[2])
          if database:get('lang:gp:'..msg.chat_id_) then
            send(msg.chat_id_, msg.id_, 1, '> User : '..ap[2]..' removed from admin list !', 1, 'md')
          else
            send(msg.chat_id_, msg.id_, 1, '> کاربر : '..ap[2]..' از ادمینی حذف شد !', 1, 'md')
          end
        end
 if is_momod(msg.sender_user_id_, msg.chat_id_) then
          if text:match("^[!/#][Hh]elp$") or text:match("^راهنما$") then
            local help = io.open("./Help/help.txt", "r")
            local helpen = io.open("./Help/helpen.txt", "r")
            local helptime = 15
            local a = ( help:read("*a") )
            local aen = ( helpen:read("*a") )
            database:setex('helptime:'..msg.chat_id_, helptime, true)
            if database:get('lang:gp:'..msg.chat_id_) then
              send(msg.chat_id_, msg.id_, 1, aen, 1, 'md')
            else
              send(msg.chat_id_, msg.id_, 1, a, 1, 'md')
            end
          end
          if database:get('helptime:'..msg.chat_id_) then
            if is_momod(msg.sender_user_id_, msg.chat_id_) then
              if database:get('lang:gp:'..msg.chat_id_) then
                local helplocken = io.open("./Help/helplocken.txt", "r")
                local helpmediaen = io.open("./Help/helpmediaen.txt", "r")
                local helpsetlinken = io.open("./Help/helpsetlinken.txt", "r")
                local helpprodemoen = io.open("./Help/helpprodemoen.txt", "r")
                local helpjanebien = io.open("./Help/helpjanebien.txt", "r")
                local helpspamflooden = io.open("./Help/helpfloodspamen.txt", "r")
                local helpvaziaten = io.open("./Help/helpvaziaten.txt", "r")
                if text:match("^1$") then
                  database:del('helptime:'..msg.chat_id_)
                  local b = ( helpvaziaten:read("*a") )
                  send(msg.chat_id_, msg.id_, 1, b, 1, 'md')
                elseif text:match("^2$") then
                  database:del('helptime:'..msg.chat_id_)
                  local c = ( helplocken:read("*a") )
                  send(msg.chat_id_, msg.id_, 1, c, 1, 'md')
                elseif text:match("^3$") then
                  database:del('helptime:'..msg.chat_id_)
                  local d = ( helpmediaen:read("*a") )
                  send(msg.chat_id_, msg.id_, 1, d, 1, 'md')
                elseif text:match("^4$") then
                  database:del('helptime:'..msg.chat_id_)
                  local e = ( helpspamflooden:read("*a") )
                  send(msg.chat_id_, msg.id_, 1, e, 1, 'md')
                elseif text:match("^5$") then
                  database:del('helptime:'..msg.chat_id_)
                  local f = ( helpprodemoen:read("*a") )
                  send(msg.chat_id_, msg.id_, 1, f, 1, 'md')
                elseif text:match("^6$") then
                  database:del('helptime:'..msg.chat_id_)
                  local g = ( helpsetlinken:read("*a") )
                  send(msg.chat_id_, msg.id_, 1, g, 1, 'md')
                elseif text:match("^7$") then
                  database:del('helptime:'..msg.chat_id_)
                  local h = ( helpjanebien:read("*a") )
                  send(msg.chat_id_, msg.id_, 1, h, 1, 'md')
                elseif text:match("^0$") then
                  send(msg.chat_id_, msg.id_, 1, '> The operation was canceled !', 1, 'md')
                  database:del('help:'..msg.chat_id_)
				if database:ttl('helptime:'..msg.chat_id_, helptime) == 0 then
		send(msg.chat_id_, msg.id_, 1, '> زمان استفاده از راهنما به پایان رسید\nبرای استفاده دوباره\n`راهنما`\nبزنید!', 1, 'md')
                else
                  if text:match("^%d+$") then
                    send(msg.chat_id_, msg.id_, 1, '> Your number is not in the list!', 1, 'md')
                    database:del('help:'..msg.chat_id_)
                end
              end
		end
		end
              if not database:get('lang:gp:'..msg.chat_id_) then
                local helplock = io.open("./Help/helplock.txt", "r")
                local helpmedia = io.open("./Help/helpmedia.txt", "r")
                local helpsetlink = io.open("./Help/helpsetlink.txt", "r")
                local helpprodemo = io.open("./Help/helpprodemo.txt", "r")
                local helpjanebi = io.open("./Help/helpjanebi.txt", "r")
                local helpspamflood = io.open("./Help/helpfloodspam.txt", "r")
                local helpvaziat = io.open("./Help/helpvaziat.txt", "r")
                if text:match("^1$") then
                  database:del('helptime:'..msg.chat_id_)
                  local b = ( helpvaziat:read("*a") )
                  send(msg.chat_id_, msg.id_, 1, b, 1, 'md')
                elseif text:match("^2$") then
                  database:del('helptime:'..msg.chat_id_)
                  local c = ( helplock:read("*a") )
                  send(msg.chat_id_, msg.id_, 1, c, 1, 'md')
                elseif text:match("^3$") then
                  database:del('helptime:'..msg.chat_id_)
                  local d = ( helpmedia:read("*a") )
                  send(msg.chat_id_, msg.id_, 1, d, 1, 'md')
                elseif text:match("^4$") then
                  database:del('helptime:'..msg.chat_id_)
                  local e = ( helpspamflood:read("*a") )
                  send(msg.chat_id_, msg.id_, 1, e, 1, 'md')
                elseif text:match("^5$") then
                  database:del('helptime:'..msg.chat_id_)
                  local f = ( helpprodemo:read("*a") )
                  send(msg.chat_id_, msg.id_, 1, f, 1, 'md')
                elseif text:match("^6$") then
                  database:del('helptime:'..msg.chat_id_)
                  local g = ( helpsetlink:read("*a") )
                  send(msg.chat_id_, msg.id_, 1, g, 1, 'md')
                elseif text:match("^7$") then
                  database:del('helptime:'..msg.chat_id_)
                  local h = ( helpjanebi:read("*a") )
                  send(msg.chat_id_, msg.id_, 1, h, 1, 'md')
                elseif text:match("^0$") then
                  send(msg.chat_id_, msg.id_, 1, '> عملیات لغو گردید !', 1, 'md')
                  database:del('help:'..msg.chat_id_)
		if database:ttl('helptime:'..msg.chat_id_, helptime) == 0 then
		send(msg.chat_id_, msg.id_, 1, '> زمان استفاده از راهنما به پایان رسید\nبرای استفاده دوباره\n`راهنما`\nبزنید!', 1, 'md')
                else
                  if text:match("^%d+$") then
                    send(msg.chat_id_, msg.id_, 1, '> شماره مورد نظر شما در لیست موجود نمیباشد !', 1, 'md')
                  end
		end
                end
              end
            end
          end
        end
        -----------------------------------------------------------------------------------------------
        if is_momod(msg.sender_user_id_, msg.chat_id_) then
          if text:match("^[!/#][Mm]odlist$") or text:match("^لیست مدیران گروه$") then
            local hash =  'bot:momod:'..msg.chat_id_
            local list = database:smembers(hash)
            if database:get('lang:gp:'..msg.chat_id_) then
              text = "> List of moderator : \n\n"
            else
              text = "> لیست مدیران گروه : \n\n"
            end
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
              if database:get('lang:gp:'..msg.chat_id_) then
                text = "> List of moderator is empty !"
              else
                text = "> لیست مدیران خالی است !"
              end
            end
            send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
          end
          ---------------------------------------------------------------------------
          if text:match("^[!/#][Vv]iplist$") or text:match("^لیست عضو های ویژه$") then
            local hash =  'bot:vipmem:'..msg.chat_id_
            local list = database:smembers(hash)
            if database:get('lang:gp:'..msg.chat_id_) then
              text = "> List of VIP Members : \n\n"
            else
              text = "> لیست عضو های ویژه :\n\n"
            end
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
              if database:get('lang:gp:'..msg.chat_id_) then
                text = "> List of VIP members is empty !"
              else
                text = "> لیست عضو های ویژه خالی است !"
              end
            end
            send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[!/#][Mm]utelist$") or text:match("^لیست افراد بی صدا$") then
            local hash =  'bot:muted:'..msg.chat_id_
            local list = database:smembers(hash)
            if database:get('lang:gp:'..msg.chat_id_) then
              text = "> List of muted users : \n\n"
            else
              text = "> لیست افراد بی صدا : \n\n"
            end
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
              if database:get('lang:gp:'..msg.chat_id_) then
                text = "> List of muted users is empty ! "
              else
                text = "> لیست افراد بی صدا خالی است ! "
              end
            end
            send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[!/#][Oo]wner$") or text:match("^[Oo]wnerlist$") or text:match("^لیست صاحب گروهان$") then
            local hash =  'bot:owners:'..msg.chat_id_
            local list = database:smembers(hash)
            if not database:get('lang:gp:'..msg.chat_id_) then
              text = "> لیست صاحبان گروه : \n\n"
            else
              text = "> Owners list : \n\n"
            end
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
              if database:get('lang:gp:'..msg.chat_id_) then
                text = "> Owner list is empty !"
              else
                text = "> لیست صاحبان گروه خالی است !"
              end
            end
            send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[!/#][Bb]anlist$") or text:match("^لیست افراد مسدود$") then
            local hash =  'bot:banned:'..msg.chat_id_
            local list = database:smembers(hash)
            if database:get('lang:gp:'..msg.chat_id_) then
              text = "> List of banlist : \n\n"
            else
              text = "> لیست افراد مسدود شده : \n\n"
            end
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
              if database:get('lang:gp:'..msg.chat_id_) then
                text = "> list of banlist is empty !"
              else
                text = "> لیست افراد مسدود شده خالی است !"
              end
            end
            send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
          end
        end
        -----------------------------------------------------------------------------------------------
        if is_sudo(msg) then
          if text:match("^[!/#][Bb]analllist$") or text:match("^لیست افراد تحت مسدودیت$") then
            local hash =  'bot:gban:'
            local list = database:smembers(hash)
            if database:get('lang:gp:'..msg.chat_id_) then
              text = "> List of banlist : \n\n"
            else
              text = "> لیست افراد تحت مسدودیت : \n\n"
            end
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
              if database:get('lang:gp:'..msg.chat_id_) then
                text = "> list of banalllist is empty !"
              else
                text = "> لیست افراد تحت مسدودیت شده خالی است !"
              end
            end
            send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
          end
        end
        -----------------------------------------------------------------------------------------------
        if text:match("^[!/#][Aa]dminlist$") or text:match("^لیست ادمین های ربات$") and is_leader(msg) then
          local hash =  'bot:admins:'
          local list = database:smembers(hash)
          if database:get('lang:gp:'..msg.chat_id_) then
            text = "> List of admins :\n\n"
          else
            text = "> لیست ادمین ها :\n\n"
          end
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
            if database:get('lang:gp:'..msg.chat_id_) then
              text = "> List of admins is empty !"
            else
              text = "> لیست ادمین ها خالی است !"
            end
          end
          send(msg.chat_id_, msg.id_, 1, text, 'html')
        end
        -----------------------------------------------------------------------------------------------
        if text:match("^[!/#][Gg]etid$") or text:match("^دریافت شناسه$") and msg.reply_to_message_id_ ~= 0 then
          function id_by_reply(extra, result, success)
            if database:get('lang:gp:'..msg.chat_id_) then
              send(msg.chat_id_, msg.id_, 1, "> User ID : "..result.sender_user_id_, 1, 'md')
            else
              send(msg.chat_id_, msg.id_, 1, "> شناسه کاربر : "..result.sender_user_id_, 1, 'md')
            end
          end
          getMessage(msg.chat_id_,msg.reply_to_message_id_,id_by_reply)
        end
        -----------------------------------------------------------------------------------------------
        if is_momod(msg.sender_user_id_, msg.chat_id_) then
          if text:match("^[!/#][Ii]d @(.*)$") then
            local ap = {string.match(text, "^([Ii]d) @(.*)$")}
            function id_by_username(extra, result, success)
              if result.id_ then
                if database:get('lang:gp:'..msg.chat_id_) then
                  if tonumber(result.id_) == tonumber(bot_owner) then
                    t = 'Chief'
                  elseif is_sudoid(result.id_) then
                    t = 'Sudo'
                  elseif is_admin(result.id_) then
                    t = 'Bot Admin'
                  elseif is_owner(result.id_, msg.chat_id_) then
                    t = 'Owner'
                  elseif is_momod(result.id_, msg.chat_id_) then
                    t = 'Group Admin'
                  elseif result.id_ == bot_id then
                    t = 'Myself'
                  else
                    t = 'Member'
                  end
                end
                if not database:get('lang:gp:'..msg.chat_id_) then
                  if tonumber(result.id_) == tonumber(bot_owner) then
                    t = 'مدیر کل'
                  elseif is_sudoid(result.id_) then
                    t = 'مدیر ربات'
                  elseif is_admin(result.id_) then
                    t = 'ادمین ربات'
                  elseif is_owner(result.id_, msg.chat_id_) then
                    t = 'صاحب گروه'
                  elseif is_momod(result.id_, msg.chat_id_) then
                    t = 'مدیر گروه'
                  elseif result.id_ == bot_id then
                    t = 'خودم'
                  else
                    t = 'کاربر'
                  end
                end
                local gpid = tostring(result.id_)
                if gpid:match('^(%d+)') then
                  if database:get('lang:gp:'..msg.chat_id_) then
                    text = '> Username : @'..ap[2]..'\n> ID : ('..result.id_..')\n> Rank : '..t
                  else
                    text = '> یوزرنیم : @'..ap[2]..'\n> شناسه : ('..result.id_..')\n> مقام : '..t
                  end
                else
                  if database:get('lang:gp:'..msg.chat_id_) then
                    text = '> Username : @'..ap[2]..'\n> ID : ('..result.id_..')'
                  else
                    text = '> یوزرنیم : @'..ap[2]..'\n> شناسه : ('..result.id_..')'
                  end
                end
              end
              if not result.id_ then
                if database:get('lang:gp:'..msg.chat_id_) then
                  text = '> Username is not correct ! '
                else
                  text = '> یوزنیم صحیح نمیباشد  ! '
                end
              end
              send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
            resolve_username(ap[2],id_by_username)
          end
          if text:match("^آیدی @(.*)$") then
            local ap = {string.match(text, "^(آیدی) @(.*)$")}
            function id_by_username(extra, result, success)
              if result.id_ then
                if database:get('lang:gp:'..msg.chat_id_) then
                  if tonumber(result.id_) == tonumber(bot_owner) then
                    t = 'Chief'
                  elseif is_sudoid(result.id_) then
                    t = 'Sudo'
                  elseif is_admin(result.id_) then
                    t = 'Bot Admin'
                  elseif is_owner(result.id_, msg.chat_id_) then
                    t = 'Owner'
                  elseif is_momod(result.id_, msg.chat_id_) then
                    t = 'Group Admin'
                  elseif result.id_ == bot_id then
                    t = 'Myself'
                  else
                    t = 'Member'
                  end
                end
                if not database:get('lang:gp:'..msg.chat_id_) then
                  if tonumber(result.id_) == tonumber(bot_owner) then
                    t = 'مدیر کل'
                  elseif is_sudoid(result.id_) then
                    t = 'مدیر ربات'
                  elseif is_admin(result.id_) then
                    t = 'ادمین ربات'
                  elseif is_owner(result.id_, msg.chat_id_) then
                    t = 'صاحب گروه'
                  elseif is_momod(result.id_, msg.chat_id_) then
                    t = 'مدیر گروه'
                  elseif result.id_ == bot_id then
                    t = 'خودم'
                  else
                    t = 'کاربر'
                  end
                end
                local gpid = tostring(result.id_)
                if gpid:match('^(%d+)') then
                  if database:get('lang:gp:'..msg.chat_id_) then
                    text = '> Username : @'..ap[2]..'\n> ID : ('..result.id_..')\n> Rank : '..t
                  else
                    text = '> یوزرنیم : @'..ap[2]..'\n> شناسه : ('..result.id_..')\n> مقام : '..t
                  end
                else
                  if database:get('lang:gp:'..msg.chat_id_) then
                    text = '> Username : @'..ap[2]..'\n> ID : ('..result.id_..')'
                  else
                    text = '> یوزرنیم : @'..ap[2]..'\n> شناسه : ('..result.id_..')'
                  end
                end
              end
              if not result.id_ then
                if database:get('lang:gp:'..msg.chat_id_) then
                  text = '> Username is not correct ! '
                else
                  text = '> یوزنیم صحیح نمیباشد  ! '
                end
              end
              send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
            resolve_username(ap[2],id_by_username)
          end
          -----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('اخراج','Kick')
          if text:match("^[!/#][Kk]ick$") and msg.reply_to_message_id_ ~= 0 then
            function kick_reply(extra, result, success)
              if not is_momod(result.sender_user_id_, result.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> User : '..result.sender_user_id_..' has been kicked !', 1, 'html')
                else
                  send(msg.chat_id_, msg.id_, 1, '> کاربر با شناسه : '..result.sender_user_id_..' اخراج شد !', 1, 'html')
                end
                chat_kick(result.chat_id_, result.sender_user_id_)
              end
            end
            getMessage(msg.chat_id_,msg.reply_to_message_id_,kick_reply)
          end
          ---------------------------------------------------------
          if text:match("^[!/#][Kk]ick @(.*)$") then
            local ap = {string.match(text, "^([!/#][Kk]ick) @(.*)$")}
            function ban_by_username(extra, result, success)
              if result.id_ then
                if not is_momod(result.id_, msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
                    texts = '> User : '..result.id_..' has been kicked !'
                  else
                    texts = '> کاربر با شناسه : '..result.id_..' اخراج گردید !'
                  end
                  chat_kick(msg.chat_id_, result.id_)
                end
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  texts = '> User not found'
                else
                  texts = '> کاربر یافت نشد !'
                end
              end
              send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
            end
            resolve_username(ap[2],ban_by_username)
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[!/#][Kk]ick (%d+)$") then
            local ap = {string.match(text, "^([!/#][Kk]ick) (%d+)$")}
            if not is_momod(ap[2], msg.chat_id_) then
              chat_kick(msg.chat_id_, ap[2])
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> User : '..ap[2]..' has been kicked !', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> کاربر با شناسه : '..ap[2]..' اخراج گردید !', 1, 'md')
              end
            end
          end
          ----------------------------------------------------------------------------------------------
          if text:match("^[!/#][Ff]ilterlist$") or text:match("^لیست فیلتر$") then
            local hash = 'bot:filters:'..msg.chat_id_
            if hash then
              local names = database:hkeys(hash)
              if database:get('lang:gp:'..msg.chat_id_) then
                text = '> Filterlist : \n\n'
              else
                text = '> لیست کلمات فیلتر شده : \n\n'
              end
              for i=1, #names do
                text = text..'> '..names[i]..'\n'
              end
              if #names == 0 then
                if database:get('lang:gp:'..msg.chat_id_) then
                  text = "> Filterlist is empty !"
                else
                  text = "> لیست کلمات فیلتر شده خالی است !"
                end
              end
              send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
            end
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[!/#][Ff]reelist$") or text:match("^لیست مجاز$") then
            local hash = 'bot:freewords:'..msg.chat_id_
            if hash then
              local names = database:hkeys(hash)
              if database:get('lang:gp:'..msg.chat_id_) then
                text = '> Freelist : \n\n'
              else
                text = '> لیست عنوان های مجاز : \n\n'
              end
              for i=1, #names do
                text = text..'> '..names[i]..'\n'
              end
              if #names == 0 then
                if database:get('lang:gp:'..msg.chat_id_) then
                  text = "> Freelist is empty !"
                else
                  text = "> لیست عنوان های مجاز خالی است !"
                end
              end
              send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
          -----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('اینوایت','Invite')
          if text:match("^[!/#][Ii]nvite$") and msg.reply_to_message_id_ ~= 0 then
            function inv_reply(extra, result, success)
              add_user(result.chat_id_, result.sender_user_id_, 5)
            end
            getMessage(msg.chat_id_, msg.reply_to_message_id_,inv_reply)
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[!/#][Ii]nvite @(.*)$") then
            local ap = {string.match(text, "^([!/#][Ii]nvite) @(.*)$")}
            function invite_by_username(extra, result, success)
              if result.id_ then
                add_user(msg.chat_id_, result.id_, 5)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  texts = '> User not found !'
                else
                  texts = '> کاربر یافت نشد !'
                end
                send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
              end
            end
            resolve_username(ap[2],invite_by_username)
          end
        end
        -----------------------------------------------------------------------------------------------
        if text:match("^[!/#][Ii]nvite (%d+)$") then
          local ap = {string.match(text, "^([!/#][Ii]nvite) (%d+)$")}
          add_user(msg.chat_id_, ap[2], 5)
        end
        -----------------------------------------------------------------------------------------------
        if msg.reply_to_message_id_ ~= 0 then
          return ""
        else
          if text:match("^[!/#][Ii]d$") then
            local user_msgs = database:get('user:msgs'..msg.chat_id_..':'..msg.sender_user_id_)
            local function getproen(extra, result, success)
              if database:get('getidstatus'..msg.chat_id_) == "Photo" then
                if result.photos_[0] then
                  if database:get('lang:gp:'..msg.chat_id_) then
                    sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[0].sizes_[1].photo_.persistent_id_,'> Your ID : '..msg.sender_user_id_..'\n> Number of messages : '..user_msgs,msg.id_,msg.id_)
                  else
                    sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[0].sizes_[1].photo_.persistent_id_,'> شناسه شما : '..msg.sender_user_id_..'\n> تعداد پیام های ارسالی شما : '..user_msgs,msg.id_,msg.id_)
                  end
                else
                  if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "> You don't have profile photo !\n\n> Your ID : "..msg.sender_user_id_.."\n> Number of messages  : "..user_msgs, 1, 'md')
                  else
                    send(msg.chat_id_, msg.id_, 1, "> شما عکس پروفایل ندارید !\n\n> شناسه شما : "..msg.sender_user_id_.."\n> تعداد پیام های ارسالی شما : "..user_msgs, 1, 'md')
                  end
                end
              end
              if database:get('getidstatus'..msg.chat_id_) == "Simple" then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, "> Your ID : "..msg.sender_user_id_.."\n> Number of messages : "..user_msgs, 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, "> شناسه شما : "..msg.sender_user_id_.."\n> تعداد پیام های ارسالی شما : "..user_msgs, 1, 'md')
                end
              end
              if not database:get('getidstatus'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, "> Your ID : "..msg.sender_user_id_.."\n> Number of messages : "..user_msgs, 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, "> شناسه شما : "..msg.sender_user_id_.."\n> تعداد پیام های ارسالی شما : "..user_msgs, 1, 'md')
                end
              end
            end
            tdcli_function ({
              ID = "GetUserProfilePhotos",
              user_id_ = msg.sender_user_id_,
              offset_ = 0,
              limit_ = 1
            }, getproen, nil)
          end
          if text:match("^آیدی$") then
            local user_msgs = database:get('user:msgs'..msg.chat_id_..':'..msg.sender_user_id_)
            local function getprofa(extra, result, success)
              if database:get('getidstatus'..msg.chat_id_) == "Photo" then
                if result.photos_[0] then
                  if database:get('lang:gp:'..msg.chat_id_) then
                    sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[0].sizes_[1].photo_.persistent_id_,'> Your ID : '..msg.sender_user_id_..'\n> Number of messages : '..user_msgs,msg.id_,msg.id_)
                  else
                    sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[0].sizes_[1].photo_.persistent_id_,'> شناسه شما : '..msg.sender_user_id_..'\n> تعداد پیام های ارسالی شما : '..user_msgs,msg.id_,msg.id_)
                  end
                else
                  if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "> You don't have profile photo !\n\n> Your ID : "..msg.sender_user_id_.."\n> Number of messages  : "..user_msgs, 1, 'md')
                  else
                    send(msg.chat_id_, msg.id_, 1, "> شما عکس پروفایل ندارید !\n\n> شناسه شما : "..msg.sender_user_id_.."\n> تعداد پیام های ارسالی شما : "..user_msgs, 1, 'md')
                  end
                end
              end
              if database:get('getidstatus'..msg.chat_id_) == "Simple" then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, "> Your ID : "..msg.sender_user_id_.."\n> Number of messages : "..user_msgs, 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, "> شناسه شما : "..msg.sender_user_id_.."\n> تعداد پیام های ارسالی شما : "..user_msgs, 1, 'md')
                end
              end
              if not database:get('getidstatus'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, "> Your ID : "..msg.sender_user_id_.."\n> Number of messages : "..user_msgs, 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, "> شناسه شما : "..msg.sender_user_id_.."\n> تعداد پیام های ارسالی شما : "..user_msgs, 1, 'md')
                end
              end
            end
            tdcli_function ({
              ID = "GetUserProfilePhotos",
              user_id_ = msg.sender_user_id_,
              offset_ = 0,
              limit_ = 1
            }, getprofa, nil)
          end
        end
		local function check_member_super_deleted(cb_extra, success, result)
 local msg = cb_extra.msg
  local deleted = 0 
if success == 0 then
send(msg.chat.id, "*first set me as admin!*", 1, 'md') 
end
if text:match("^[!/#][Cc]lean deleted$") then
for k,v in pairs(result) do
  if not v.first_name and not v.last_name then
deleted = deleted + 1
 chat_kick(v.peer_id,msg.to.id)
 end
 end
 send(msg.chat.id, deleted.." *Deleted account removed from group!*", 1, 'md') 
 end 
end
        -----------------------------------------------------------------------------------------------
        local text = msg.content_.text_:gsub('وضعیت دریافت عکس پروفایل','Getprofilestatus')
        if is_momod(msg.sender_user_id_, msg.chat_id_) then
          if text:match("^[!/#][Gg]etprofilestatus (.*)$") then
            local status = {string.match(text, "^([Gg]etprofilestatus) (.*)$")}
            if status[2] == "active" or status[2] == "فعال" then
              if database:get('getpro:'..msg.chat_id_) == "Active" then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Get profile photo is *already* actived ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> وضعیت دریافت عکس پروفایل از قبل بر روی حالت #فعال میباشد ! ', 1, 'md')
                end
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Get profile photo has been changed to *active* ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> وضعیت دریافت عکس پروفایل بر روی حالت #فعال تنظیم شد !', 1, 'md')
                end
                database:set('getpro:'..msg.chat_id_,'Active')
              end
            end
            if status[2] == "deactive" or status[2] == "غیرفعال" then
              if database:get('getpro:'..msg.chat_id_) == "Deactive" then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Get profile photo is *already* deactived', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> وضعیت دریافت عکس پروفایل از قبل بر روی حالت #غیرفعال میباشد !', 1, 'md')
                end
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, 'Get profile photo has been change to *deactive* !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> وضعیت دریافت عکس پروفایل بر روی حالت #غیرفعال تنظیم شد !', 1, 'md')
                end
                database:set('getpro:'..msg.chat_id_,'Deactive')
              end
            end
          end
        end
        -----------------------------------------------------------------------------------------------
        if text:match("^[!/#][Gg]etpro (%d+)$") then
          local pronumb = {string.match(text, "^([Gg]etpro) (%d+)$")}
          local function gproen(extra, result, success)
            if not is_momod(msg.sender_user_id_, msg.chat_id_) and database:get('getpro:'..msg.chat_id_) == "Deactive" then
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, "> Get profile photo is deactive !", 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, "> دریافت عکس پروفایل غیرفعال شده است !", 1, 'md')
              end
            else
              if pronumb[2] == '1' then
                if result.photos_[0] then
                  sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[0].sizes_[1].photo_.persistent_id_)
                else
                  if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "You don't have profile photo !", 1, 'md')
                  else
                    send(msg.chat_id_, msg.id_, 1, "شما عکس پروفایل ندارید", 1, 'md')
                  end
                end
              elseif pronumb[2] == '2' then
                if result.photos_[1] then
                  sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[1].sizes_[1].photo_.persistent_id_)
                else
                  if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "You don't have 2 profile photo !", 1, 'md')
                  else
                    send(msg.chat_id_, msg.id_, 1, "شما 2 عکس پروفایل ندارید", 1, 'md')
                  end
                end
              elseif pronumb[2] == '3' then
                if result.photos_[2] then
                  sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[2].sizes_[1].photo_.persistent_id_)
                else
                  if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "You don't have 3 profile photo !", 1, 'md')
                  else
                    send(msg.chat_id_, msg.id_, 1, "شما 3 عکس پروفایل ندارید", 1, 'md')
                  end
                end
              elseif pronumb[2] == '4' then
                if result.photos_[3] then
                  sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[3].sizes_[1].photo_.persistent_id_)
                else
                  if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "You don't have 4 profile photo !", 1, 'md')
                  else
                    send(msg.chat_id_, msg.id_, 1, "شما 4 عکس پروفایل ندارید", 1, 'md')
                  end
                end
              elseif pronumb[2] == '5' then
                if result.photos_[4] then
                  sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[4].sizes_[1].photo_.persistent_id_)
                else
                  if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "You don't 5 have profile photo !", 1, 'md')
                  else
                    send(msg.chat_id_, msg.id_, 1, "شما 5 عکس پروفایل ندارید", 1, 'md')
                  end
                end
              elseif pronumb[2] == '6' then
                if result.photos_[5] then
                  sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[5].sizes_[1].photo_.persistent_id_)
                else
                  if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "You don't have 6 profile photo !", 1, 'md')
                  else
                    send(msg.chat_id_, msg.id_, 1, "شما 6 عکس پروفایل ندارید", 1, 'md')
                  end
                end
              elseif pronumb[2] == '7' then
                if result.photos_[6] then
                  sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[6].sizes_[1].photo_.persistent_id_)
                else
                  if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "You don't have 7 profile photo !", 1, 'md')
                  else
                    send(msg.chat_id_, msg.id_, 1, "شما 7 عکس پروفایل ندارید", 1, 'md')
                  end
                end
              elseif pronumb[2] == '8' then
                if result.photos_[7] then
                  sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[7].sizes_[1].photo_.persistent_id_)
                else
                  if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "You don't have 8 profile photo !", 1, 'md')
                  else
                    send(msg.chat_id_, msg.id_, 1, "شما 8 عکس پروفایل ندارید", 1, 'md')
                  end
                end
              elseif pronumb[2] == '9' then
                if result.photos_[8] then
                  sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[8].sizes_[1].photo_.persistent_id_)
                else
                  if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "You don't have 9 profile photo !", 1, 'md')
                  else
                    send(msg.chat_id_, msg.id_, 1, "شما 9 عکس پروفایل ندارید", 1, 'md')
                  end
                end
              elseif pronumb[2] == '10' then
                if result.photos_[9] then
                  sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[9].sizes_[1].photo_.persistent_id_)
                else
                  if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "You don't have 10 profile photo !", 1, 'md')
                  else
                    send(msg.chat_id_, msg.id_, 1, "شما 10 عکس پروفایل ندارید", 1, 'md')
                  end
                end
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, "> I just can get last 10 profile photos !", 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, "> من فقط میتوانم  10 عکس آخر را نمایش دهم !", 1, 'md')
                end
              end
            end
          end
          tdcli_function ({
            ID = "GetUserProfilePhotos",
            user_id_ = msg.sender_user_id_,
            offset_ = 0,
            limit_ = pronumb[2]
          }, gproen, nil)
        end
        if text:match("^عکس پروفایلم (%d+)$") then
          local pronumb = {string.match(text, "^(عکس پروفایلم) (%d+)$")}
          if not is_momod(msg.sender_user_id_, msg.chat_id_) and database:get('getpro:'..msg.chat_id_) == "Deactive" then
            if database:get('lang:gp:'..msg.chat_id_) then
              send(msg.chat_id_, msg.id_, 1, "> Get profile photo is deactive !", 1, 'md')
            else
              send(msg.chat_id_, msg.id_, 1, "> دریافت عکس پروفایل غیرفعال شده است !", 1, 'md')
            end
          else
            local function gprofa(extra, result, success)
              --vardump(result)
              if pronumb[2] == '1' then
                if result.photos_[0] then
                  sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[0].sizes_[1].photo_.persistent_id_)
                else
                  if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "You don't have profile photo !", 1, 'md')
                  else
                    send(msg.chat_id_, msg.id_, 1, "شما عکس پروفایل ندارید", 1, 'md')
                  end
                end
              elseif pronumb[2] == '2' then
                if result.photos_[1] then
                  sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[1].sizes_[1].photo_.persistent_id_)
                else
                  if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "You don't have 2 profile photo !", 1, 'md')
                  else
                    send(msg.chat_id_, msg.id_, 1, "شما 2 عکس پروفایل ندارید", 1, 'md')
                  end
                end
              elseif pronumb[2] == '3' then
                if result.photos_[2] then
                  sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[2].sizes_[1].photo_.persistent_id_)
                else
                  if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "You don't have 3 profile photo !", 1, 'md')
                  else
                    send(msg.chat_id_, msg.id_, 1, "شما 3 عکس پروفایل ندارید", 1, 'md')
                  end
                end
              elseif pronumb[2] == '4' then
                if result.photos_[3] then
                  sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[3].sizes_[1].photo_.persistent_id_)
                else
                  if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "You don't have 4 profile photo !", 1, 'md')
                  else
                    send(msg.chat_id_, msg.id_, 1, "شما 4 عکس پروفایل ندارید", 1, 'md')
                  end
                end
              elseif pronumb[2] == '5' then
                if result.photos_[4] then
                  sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[4].sizes_[1].photo_.persistent_id_)
                else
                  if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "You don't 5 have profile photo !", 1, 'md')
                  else
                    send(msg.chat_id_, msg.id_, 1, "شما 5 عکس پروفایل ندارید", 1, 'md')
                  end
                end
              elseif pronumb[2] == '6' then
                if result.photos_[5] then
                  sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[5].sizes_[1].photo_.persistent_id_)
                else
                  if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "You don't have 6 profile photo !", 1, 'md')
                  else
                    send(msg.chat_id_, msg.id_, 1, "شما 6 عکس پروفایل ندارید", 1, 'md')
                  end
                end
              elseif pronumb[2] == '7' then
                if result.photos_[6] then
                  sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[6].sizes_[1].photo_.persistent_id_)
                else
                  if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "You don't have 7 profile photo !", 1, 'md')
                  else
                    send(msg.chat_id_, msg.id_, 1, "شما 7 عکس پروفایل ندارید", 1, 'md')
                  end
                end
              elseif pronumb[2] == '8' then
                if result.photos_[7] then
                  sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[7].sizes_[1].photo_.persistent_id_)
                else
                  if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "You don't have 8 profile photo !", 1, 'md')
                  else
                    send(msg.chat_id_, msg.id_, 1, "شما 8 عکس پروفایل ندارید", 1, 'md')
                  end
                end
              elseif pronumb[2] == '9' then
                if result.photos_[8] then
                  sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[8].sizes_[1].photo_.persistent_id_)
                else
                  if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "You don't have 9 profile photo !", 1, 'md')
                  else
                    send(msg.chat_id_, msg.id_, 1, "شما 9 عکس پروفایل ندارید", 1, 'md')
                  end
                end
              elseif pronumb[2] == '10' then
                if result.photos_[9] then
                  sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[9].sizes_[1].photo_.persistent_id_)
                else
                  if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "You don't have 10 profile photo !", 1, 'md')
                  else
                    send(msg.chat_id_, msg.id_, 1, "شما 10 عکس پروفایل ندارید", 1, 'md')
                  end
                end
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, "> I just can get last 10 profile photos !", 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, "> من فقط میتوانم  10 عکس آخر را نمایش دهم !", 1, 'md')
                end
              end
            end
          end
          tdcli_function ({
            ID = "GetUserProfilePhotos",
            user_id_ = msg.sender_user_id_,
            offset_ = 0,
            limit_ = pronumb[2]
          }, gprofa, nil)
        end
        -----------------------------------------------------------------------------------------------
        if is_momod(msg.sender_user_id_, msg.chat_id_) then
          if text:match("^[!/#][Ll]ock (.*)$") or text:match("^قفل (.*)$") and is_momod(msg.sender_user_id_, msg.chat_id_) then
            local lockpt = {string.match(text, "^([!/#][Ll]ock) (.*)$")}
            local lockptf = {string.match(text, "^(قفل) (.*)$")}
            if lockpt[2] == "edit" or lockptf[2] == "ویرایش پیام" then
              if not database:get('editmsg'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock edit has been *activated* !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل ویرایش پیام #فعال شد ! ', 1, 'md')
                end
                database:set('editmsg'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock edit is *already* activated ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل ویرایش پیام از قبل #فعال است ! ', 1, 'md')
                end
              end
            end
            if lockpt[2] == "cmd" or lockptf[2] == "حالت عدم جواب" then
              if not database:get('bot:cmds'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Case of no answer has been *enable* !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> حالت عدم جواب #فعال شد ! ', 1, 'md')
                end
                database:set('bot:cmds'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Case of no answer is *already* enable !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> حالت عدم جواب از قبل #فعال است ! ', 1, 'md')
                end
              end
            end
            if lockpt[2] == "bots" or lockptf[2] == "ربات" then
              if not database:get('bot:bots:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock bots has been *activated* ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل ورود ربات #فعال شد ! ', 1, 'md')
                end
                database:set('bot:bots:mute'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock bots is *already* enable ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل ورود ربات از قبل #فعال است ! ', 1, 'md')
                end
              end
            end
            if lockpt[2] == "flood" or lockptf[2] == "فلود" then
              if not database:get('anti-flood:'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock flood has been *activated* ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل فلود #فعال شد ! ', 1, 'md')
                end
                database:set('anti-flood:'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock flood is *already* enable ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل فلود از قبل #فعال است ! ', 1, 'md')
                end
              end
            end
            if lockpt[2] == "pin" or lockptf[2] == "سنجاق پیام" then
              if not database:get('bot:pin:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock pin has been *activated* ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, "> قفل سنجاق پیام #فعال شد ! ", 1, 'md')
                end
                database:set('bot:pin:mute'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock pin is *already* enable ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, "> قفل سنجاق پیام از قبل #فعال است ! ", 1, 'md')
                end
              end
            end
          end
        end
        -----------------------------------------------------------------------------------------------
        local text = msg.content_.text_:gsub('تنظیم فلود','Setflood')
        if is_momod(msg.sender_user_id_, msg.chat_id_) then
          if text:match("^[!/#][Ss]etflood (%d+)$") then
            local floodmax = {string.match(text, "^([!/#][Ss]etflood) (%d+)$")}
            if tonumber(floodmax[2]) < 2 then
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> Select a number greater than 2 !', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> عددی بزرگتر از 2 وارد کنید !', 1, 'md')
              end
            else
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> Flood sensitivity change to '..floodmax[2]..' !', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> حساسیت فلود به '..floodmax[2]..' تنظیم شد !', 1, 'md')
              end
              database:set('flood:max:'..msg.chat_id_,floodmax[2])
            end
          end
            if text:match("^[!/#][Ss]etstatus (.*)$") then
          -----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('وضعیت فلود','Setstatus')
          if text:match("^[!/#][Ss]etstatus (.*)$") then
            local status = {string.match(text, "^([!/#][Ss]etstatus) (.*)$")}
            if status[2] == "kick" or status[2] == "اخراج" then
              if database:get('floodstatus'..msg.chat_id_) == "Kicked" then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Flood status is *already* on Kicked ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> وضعیت فلود از قبل بر روی حالت #اخراج میباشد ! ', 1, 'md')
                end
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Flood status change to *Kicking* ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> وضعیت فلود بر روی حالت #اخراج تنظیم شد ! ', 1, 'md')
                end
                database:set('floodstatus'..msg.chat_id_,'Kicked')
              end
            end
            if status[2] == "del" or status[2] == "حذف پیام" then
              if database:get('floodstatus'..msg.chat_id_) == "DelMsg" then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Flood status is *already* on Deleting !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> وضعیت فلود از قبل بر روی حالت #حذف پیام میباشد !  ', 1, 'md')
                end
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Flood status has been change to *Deleting* ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> وضعیت فلود بر روی حالت #حذف پیام تنظیم شد ! ', 1, 'md')
                end
                database:set('floodstatus'..msg.chat_id_,'DelMsg')
              end
            end
          end
          -----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('وضعیت دریافت آیدی','Getidstatus')
          if text:match("^[!/#][Gg]etidstatus (.*)$") then
            local status = {string.match(text, "^([!/#][Gg]etidstatus) (.*)$")}
            if status[2] == "photo" or status[2] == "عکس" then
              if database:get('getidstatus'..msg.chat_id_) == "Photo" then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Get id status is *already* on Photo ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> وضعیت دریافت آیدی از قبل بر روی حالت #عکس میباشد ! ', 1, 'md')
                end
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Get ID status has been changed to *Photo* ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> وضعیت دریافت آیدی بر روی حالت #عکس تنظیم شد ! ', 1, 'md')
                end
                database:set('getidstatus'..msg.chat_id_,'Photo')
              end
            end
            if status[2] == "simple" or status[2] == "ساده" then
              if database:get('getidstatus'..msg.chat_id_) == "Simple" then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Get ID status is *already* on Simple ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> وضعیت دریافت آیدی از قبل بر روی حالت #ساده میباشد ! ', 1, 'md')
                end
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, 'Get ID status has been change to *Simple* !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> وضعیت دریافت آیدی بر روی حالت #ساده تنظیم شد ! ', 1, 'md')
                end
                database:set('getidstatus'..msg.chat_id_,'Simple')
              end
            end
          end
        end
        -----------------------------------------------------------------------------------------------
        if is_sudo(msg) then
          local text = msg.content_.text_:gsub('خروج خودکار','Autoleave')
          if text:match("^[!/#][Aa]utoleave (.*)$") then
            local status = {string.match(text, "^([!/#][Aa]utoleave) (.*)$")}
            if status[2] == "فعال" or status[2] == "on" then
              if database:get('autoleave') == "On" then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Auto Leave is now active !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> خروج خودکار از قبل فعال است ! ', 1, 'md')
                end
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Auto Leave has been actived !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> خروج خودکار فعال شد !', 1, 'md')
                end
                database:set('autoleave','On')
              end
            end
            if status[2] == "غیرفعال" or status[2] == "off" then
              if database:get('autoleave') == "Off" then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Auto Leave is now deactive !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> خروج خودکار از قبل غیرفعال میباشد !', 1, 'md')
                end
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Auto leave has been deactived !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> خروج خودکار غیرفعال شد !', 1, 'md')
                end
                database:set('autoleave','Off')
              end
            end
          end
          -----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('منشی','Clerk')
          if text:match("^[!/#][Cc]lerk (.*)$") then
            local status = {string.match(text, "^([!/#][Cc]lerk) (.*)$")}
            if status[2] == "فعال" or status[2] == "on" then
              if database:get('clerk') == "On" then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Clerk is now active !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> منشی از قبل فعال است ! ', 1, 'md')
                end
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Clerk has been actived !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> منشی فعال شد !', 1, 'md')
                end
                database:set('clerk','On')
              end
            end
            if status[2] == "غیرفعال" or status[2] == "off" then
              if database:get('clerk') == "Off" then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Clerk is now deactive !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> منشی از قبل غیرفعال میباشد !', 1, 'md')
                end
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Auto leave has been deactived !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> منشی غیرفعال شد !', 1, 'md')
                end
                database:set('clerk','Off')
              end
            end
          end
        end
        -----------------------------------------------------------------------------------------------
        if is_momod(msg.sender_user_id_, msg.chat_id_) then
          if text:match("^[!/#][Ss]etlink$") or text:match("^تنظیم لینک$") then
            if database:get('lang:gp:'..msg.chat_id_) then
              send(msg.chat_id_, msg.id_, 1, '> Plese send your group link now :', 1, 'md')
            else
              send(msg.chat_id_, msg.id_, 1, '> لطفا لینک گروه را ارسال نمایید :', 1, 'md')
            end
            database:set("bot:group:link"..msg.chat_id_, 'waiting')
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[!/#][Ll]ink$") or text:match("^دریافت لینک$") then
            local link = database:get("bot:group:link"..msg.chat_id_)
            if link then
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> Group link :\n'..link, 1, 'html')
              else
                send(msg.chat_id_, msg.id_, 1, '> لینک گروه :\n'..link, 1, 'html')
              end
            else
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> Group link is not set ! \n Plese send command Setlink and set it 🌹', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> لینک گروه هنوز ذخیره نشده است ! \n لطفا با دستور Setlink آن را ذخیره کنید 🌹', 1, 'md')
              end
            end
          end
        end
        -----------------------------------------------------------------------------------------------
        if is_momod(msg.sender_user_id_, msg.chat_id_) then
          if text:match("^[!/#][Ww]elcome on$") or text:match("^خوش امدگویی روشن$") then
            if database:get('lang:gp:'..msg.chat_id_) then
              send(msg.chat_id_, msg.id_, 1, '> Welcome activated !', 1, 'md')
            else
              send(msg.chat_id_, msg.id_, 1, '> خوش آمد گویی فعال شد !', 1, 'md')
            end
            database:set("bot:welcome"..msg.chat_id_,true)
          end
          if text:match("^[!/#][Ww]elcome off$") or text:match("^خوش امدگویی خاموش") then
            if database:get('lang:gp:'..msg.chat_id_) then
              send(msg.chat_id_, msg.id_, 1, '> Welcome deactivated !', 1, 'md')
            else
              send(msg.chat_id_, msg.id_, 1, '> خوش آمد گویی غیرفعال شد !', 1, 'md')
            end
            database:del("bot:welcome"..msg.chat_id_)
          end
          if text:match("^[!/#][Ss]et welcome (.*)$") or text:match("^تنظیم متن خوش امدگویی (.*)$") then
            local welcome = {string.match(text, "^([!/#][Ss]et welcome) (.*)$")}
            if database:get('lang:gp:'..msg.chat_id_) then
              send(msg.chat_id_, msg.id_, 1, '> Welcome text has been saved !\n\nWelcome text :\n\n'..welcome[2], 1, 'html')
            else
              send(msg.chat_id_, msg.id_, 1, '> پیام خوش آمد گویی ذخیره شد !\n\nمتن خوش آمد گویی :\n\n'..welcome[2], 1, 'html')
            end
            database:set('welcome:'..msg.chat_id_,welcome[2])
          end
          if text:match("^[!/#][Dd]el welcome$") or text:match("^حذف متن خوش امدگویی$") then
            if database:get('lang:gp:'..msg.chat_id_) then
              send(msg.chat_id_, msg.id_, 1, '> Welcome text has been removed !', 1, 'md')
            else
              send(msg.chat_id_, msg.id_, 1, '> پیام خوش آمد گویی حذف شد !', 1, 'md')
            end
            database:del('welcome:'..msg.chat_id_)
          end
          if text:match("^[!/#][Gg]et welcome$") or text:match("^دریافت متن خوش امدگویی$") then
            local wel = database:get('welcome:'..msg.chat_id_)
            if wel then
              send(msg.chat_id_, msg.id_, 1, wel, 1, 'md')
            else
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> Welcome text not found !', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> پیامی در لیست نیست !', 1, 'md')
              end
            end
          end
        end
        -----------------------------------------------------------------------------------------------
        if is_sudo(msg) then
		  local text = msg.content_.text_:gsub('تنظیم متن منشی','Set clerk')
          if text:match("^[!/#][Ss]et clerk (.*)$") then
            local clerk = {string.match(text, "^([!/#][Ss]et clerk) (.*)$")}
            if database:get('lang:gp:'..msg.chat_id_) then
              send(msg.chat_id_, msg.id_, 1, '> Clerk text has been saved !\nWelcome text :\n\n'..clerk[2], 1, 'html')
            else
              send(msg.chat_id_, msg.id_, 1, '> پیام منشی ذخیره شد !\n\nمتن منشی :\n\n'..clerk[2], 1, 'html')
            end
            database:set('textsec',clerk[2])
          end
          if text:match("^[!/#][Dd]el clerk$") or text:match("^حذف متن منشی$") then
            if database:get('lang:gp:'..msg.chat_id_) then
              send(msg.chat_id_, msg.id_, 1, '> Clerk text has been removed !', 1, 'md')
            else
              send(msg.chat_id_, msg.id_, 1, '> پیام منشی حذف شد !', 1, 'md')
            end
            database:del('textsec')
          end
          if text:match("^[!/#][Gg]et clerk$") or text:match("^دریافت متن منشی$") then
            local cel = database:get('textsec')
            if cel then
              send(msg.chat_id_, msg.id_, 1, cel, 1, 'html')
            else
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> Clerk text not found !', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> پیامی در لیست نیست !', 1, 'md')
              end
            end
          end
        end
        -----------------------------------------------------------------------------------------------
        if text:match("^[!/#][Aa]ction (.*)$") and is_sudo(msg) then
          local lockpt = {string.match(text, "^([!/#][Aa]ction) (.*)$")}
          if lockpt[2] == "typing" then
            sendaction(msg.chat_id_, 'Typing')
          end
          if lockpt[2] == "video" then
            sendaction(msg.chat_id_, 'RecordVideo')
          end
          if lockpt[2] == "voice" then
            sendaction(msg.chat_id_, 'RecordVoice')
          end
          if lockpt[2] == "photo" then
            sendaction(msg.chat_id_, 'UploadPhoto')
          end
        end
        -----------------------------------------------------------------------------------------------
        if is_momod(msg.sender_user_id_, msg.chat_id_) then
          if text:match("^[!/#][Ff]ilter (.*)$") or text:match("^فیلتر (.*)$") then
            local filters = {string.match(text, "^([!/#][Ff]ilter) (.*)$")}
            local filterss = {string.match(text, "^(فیلتر) (.*)$")}
            local name = string.sub(filters[2] or filterss[2], 1, 50)
            local hash = 'bot:filters:'..msg.chat_id_
            database:hset(hash, name,'newword')
            if database:get('lang:gp:'..msg.chat_id_) then
              send(msg.chat_id_, msg.id_, 1, "> Word [ "..name.." ] has been filtered !", 1, 'md')
            else
              send(msg.chat_id_, msg.id_, 1, "> کلمه [ "..name.." ] فیلتر شد !", 1, 'md')
            end
          end
        end
        -----------------------------------------------------------------------------------------------
        if is_momod(msg.sender_user_id_, msg.chat_id_) then
          if text:match("^[!/#][Uu]nfilter (.*)$") or text:match("^حذف فیلتر (.*)$") then
            local rws = {string.match(text, "^([!/#][Uu]nfilter) (.*)$")}
            local rwss = {string.match(text, "^(حذف فیلتر) (.*)$")}
            local name = string.sub(rws[2] or rwss[2], 1, 50)
            local cti = msg.chat_id_
            local hash = 'bot:filters:'..msg.chat_id_
            if not database:hget(hash, name)then
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, "> Word : ["..name.."] is not in filterlist !", 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, "> کلمه : ["..name.."] در لیست یافت نشد !", 1, 'md')
              end
            else
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, "> Word : ["..name.."] removed from filterlist !", 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, "> کلمه : ["..name.."] از لیست فیلتر حذف شد !", 1, 'md')
              end
              database:hdel(hash, name)
            end
          end
        end
        -----------------------------------------------------------------------------------------------
        if is_momod(msg.sender_user_id_, msg.chat_id_) then
          if text:match("^[!/#][Ff]ree (.*)$") or text:match("^مجاز (.*)$") then
            local filters = {string.match(text, "^([!/#][Ff]ree) (.*)$")}
            local filterss = {string.match(text, "^(مجاز) (.*)$")}
            local name = string.sub(filters[2] or filterss[2], 1, 50)
            local hash = 'bot:freewords:'..msg.chat_id_
            database:hset(hash, name,'newword')
            if database:get('lang:gp:'..msg.chat_id_) then
              send(msg.chat_id_, msg.id_, 1, "> Caption [ "..name.." ] has been freed !", 1, 'html')
            else
              send(msg.chat_id_, msg.id_, 1, "> عنوان [ "..name.." ] مجاز شد !", 1, 'html')
            end
          end
        end
        -----------------------------------------------------------------------------------------------
        if is_momod(msg.sender_user_id_, msg.chat_id_) then
          if text:match("^[!/#][Uu]nfree (.*)$") or text:match("^حذف مجاز (.*)$") then
            local rws = {string.match(text, "^([!/#][Uu]nfree) (.*)$")}
            local rwss = {string.match(text, "^(حذف مجاز) (.*)$")}
            local name = string.sub(rws[2] or rwss[2], 1, 50)
            local cti = msg.chat_id_
            local hash = 'bot:freewords:'..msg.chat_id_
            if not database:hget(hash, name)then
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, "> Caption : ["..name.."] is not in freelist !", 1, 'html')
              else
                send(msg.chat_id_, msg.id_, 1, "> عنوان : ["..name.."] در لیست یافت نشد !", 1, 'html')
              end
            else
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, "> Caption : ["..name.."] removed from freelist !", 1, 'html')
              else
                send(msg.chat_id_, msg.id_, 1, "> عنوان : ["..name.."] از لیست مجاز حذف شد !", 1, 'html')
              end
              database:hdel(hash, name)
            end
          end
        end
        -----------------------------------------------------------------------------------------------
if text:match("^[!/#][Bb]roadcast (.*)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
    local gps = database:scard("bot:groups") or 0
          local gpss = database:smembers("bot:groups") or 0
          local rws = {string.match(text, "^([!/#][Bb]roadcast) (.*)$")}
	for i=1, #gpss do
		  send(gpss[i], 0, 1, rws[2], 1, 'md')
    end
                   send(msg.chat_id_, msg.id_, 1, '*Your Msg Send to* `|'..gps..'|` *Groups*!', 1, 'md')
	end
        -----------------------------------------------------------------------------------------------
        if text:match("^[/!#][Ss]tats$") or text:match("^وضعیت ربات$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
          local gps = database:scard("bot:groups")
          local users = database:scard("bot:userss")
          local allmgs = database:get("bot:allmsgs")
          if database:get('autoleave') == "On" then
            autoleaveen = "Active"
            autoleavefa = "فعال"
          elseif database:get('autoleave') == "Off" then
            autoleaveen = "Deactive"
            autoleavefa = "غیرفعال"
          elseif not database:get('autoleave') then
            autoleaveen = "Deactive"
            autoleavefa = "غیرفعال"
          end
		  if database:get('clerk') == "On" then
            clerken = "Active"
            clerkfa = "فعال"
          elseif database:get('clerk') == "Off" then
            clerken = "Deactive"
            clerkfa = "غیرفعال"
          elseif not database:get('clerk') then
            clerken = "Deactive"
            clerkfa = "غیرفعال"
          end
          if database:get('lang:gp:'..msg.chat_id_) then
            send(msg.chat_id_, msg.id_, 1, '> Status : \n\n> Groups : '..gps..'\n\n> Msg received  : '..allmgs..'\n\n> Auto Leave : '..autoleaveen..'\n\n> Clerk : '..clerken, 1, 'md')
          else
            send(msg.chat_id_, msg.id_, 1, '> وضعیت ربات : \n\n> تعداد گروه ها : '..gps..'\n\n> تعداد پیام های دریافتی  : '..allmgs..'\n\n> خروج خودکار : '..autoleavefa..'\n\n> منشی : '..clerkfa, 1, 'md')
          end
        end
        ------------------------------------------------------------------------------
        if text:match("^[!/#][Rr]esgp$") or text:match("^بروزرسانی گروه های ربات$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
          if database:get('lang:gp:'..msg.chat_id_) then
            send(msg.chat_id_, msg.id_, 1, '> Nubmper of groups bot has been update !', 1, 'md')
          else
            send(msg.chat_id_, msg.id_, 1, '> تعداد گروه های ربات با موفقیت بروزرسانی گردید !', 'md')
          end
          database:del("bot:groups")
        end
        ------------------------------------------------------------------------------
        if text:match("^[!/#][Nn]amegp$") or text:match("^دریافت نام گروه$") and is_momod(msg.sender_user_id_, msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '> نام گروه : '..chat.title_, 1, 'md')
        end
        -----------------------------------------------------------------------------------------------
        if text:match("^[!/#][Rr]esmsg$") or text:match("^شروع مجدد شمارش پیام دریافتی$") and is_sudo(msg) then
          database:del("bot:allmsgs")
          if database:get('lang:gp:'..msg.chat_id_) then
            send(msg.chat_id_, msg.id_, 1, '> All msg received has been reset !', 1, 'md')
          else
            send(msg.chat_id_, msg.id_, 1, '> شمارش پیام های دریافتی ، از نو شروع شد !', 1, 'md')
          end
        end
        -----------------------------------------------------------------------------------------------
        if text:match("^[!/#][Ss]etlang (.*)$") or text:match("^تنظیم زبان (.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
          local langs = {string.match(text, "^(.*) (.*)$")}
          if langs[2] == "fa" or langs[2] == "فارسی" then
            if not database:get('lang:gp:'..msg.chat_id_) then
              send(msg.chat_id_, msg.id_, 1, '> زبان ربات هم اکنون بر روی فارسی قرار دارد !', 1, 'md')
            else
              send(msg.chat_id_, msg.id_, 1, '> زبان ربات به فارسی تغییر پیدا کرد ! ', 1, 'md')
              database:del('lang:gp:'..msg.chat_id_)
            end
          end
          if langs[2] == "en" or langs[2] == "انگلیسی" then
            if database:get('lang:gp:'..msg.chat_id_) then
              send(msg.chat_id_, msg.id_, 1, '> Language Bot is *already* English', 1, 'md')
            else
              send(msg.chat_id_, msg.id_, 1, '> Language Bot has been changed to *English* !', 1, 'md')
              database:set('lang:gp:'..msg.chat_id_,true)
            end
          end
        end
        -----------------------------------------------------------------------------------------------
        if is_momod(msg.sender_user_id_, msg.chat_id_) then
          if text:match("^[!/#][Uu]nlock (.*)$") or text:match("^بازکردن (.*)$") then
            local unlockpt = {string.match(text, "^([!/#][Uu]nlock) (.*)$")}
            local unlockpts = {string.match(text, "^(بازکردن) (.*)$")}
            if unlockpt[2] == "edit" or unlockpts[2] == "ویرایش پیام" then
              if database:get('editmsg'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock edit has been *inactive* !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل ویرایش پیام #غیرفعال شد ! ', 1, 'md')
                end
                database:del('editmsg'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock edit is *already* inactive ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل ویرایش پیام از قبل #غیرفعال است ! ', 1, 'md')
                end
              end
            end
            if unlockpt[2] == "cmd" or unlockpts[2] == "حالت عدم جواب" then
              if database:get('bot:cmds'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Case of no answer has been *inactive* !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> حالت عدم جواب #غیرفعال شد ! ', 1, 'md')
                end
                database:del('bot:cmds'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Case of no answer is *already* inactive ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> حالت عدم جواب از قبل #غیرفعال است ! ', 1, 'md')
                end
              end
            end
            if unlockpt[2] == "bots" or unlockpts[2] == "ربات" then
              if database:get('bot:bots:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock bot has been *inactive* !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل ورود ربات #غیرفعال شد ! ', 1, 'md')
                end
                database:del('bot:bots:mute'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock bots is *already* inactive ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل ورود ربات از قبل #غیرفعال است ! ', 1, 'md')
                end
              end
            end
            if unlockpt[2] == "flood" or unlockpts[2] == "فلود" then
              if database:get('anti-flood:'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock flood has been *inactive* ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل فلود #غیرفعال شد ! ', 1, 'md')
                end
                database:del('anti-flood:'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock flood is *already* inactive ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل قلود از قبل #غیرفعال است ! ', 1, 'md')
                end
              end
            end
            if unlockpt[2] == "pin" or unlockpts[2] == "سنجاق پیام" then
              if database:get('bot:pin:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, "> Lock pin has been *inactive* ! ", 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, "> قفل سنجاق پیام #غیرفعال شد ! ", 1, 'md')
                end
                database:del('bot:pin:mute'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, "> Lock pin is *already* inactive !", 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, "> قفل سنجاق پیام از قبل #غیرفعال است ! ", 1, 'md')
                end
              end
            end
          end
        end
        -----------------------------------------------------------------------------------------------
        if is_momod(msg.sender_user_id_, msg.chat_id_) then
          if text:match("^[!/#][Ll]ock all (%d+)$") then
            local mutept = {string.match(text, "^[Ll]ock all (%d+)$")}
            local hour = string.gsub(mutept[1], 'h', '')
            local num1 = tonumber(hour) * 3600
            local num = tonumber(num1)
            database:setex('bot:muteall'..msg.chat_id_, num, true)
            if database:get('lang:gp:'..msg.chat_id_) then
              send(msg.chat_id_, msg.id_, 1, "> Lock all has been enable for "..mutept[1].." hours !", 'md')
            else
              send(msg.chat_id_, msg.id_, 1, "> قفل گروه [ همه چیز ] به مدت "..mutept[1].." ساعت #فعال شد !", 'md')
            end
          end
          if text:match("^قفل جی تایم (%d+)$") then
            local mutept = {string.match(text, "^قفل جی تایم (%d+)$")}
            local hour = string.gsub(mutept[1], 'h', '')
            local num1 = tonumber(hour) * 3600
            local num = tonumber(num1)
            database:setex('bot:muteall'..msg.chat_id_, num, true)
            if database:get('lang:gp:'..msg.chat_id_) then
              send(msg.chat_id_, msg.id_, 1, "> Lock all has been enable for "..mutept[1].." hours !", 'md')
            else
              send(msg.chat_id_, msg.id_, 1, "> قفل گروه [ همه چیز ] به مدت "..mutept[1].." ساعت #فعال شد !", 'md')
            end
          end
        end
        -----------------------------------------------------------------------------------------------
        if is_momod(msg.sender_user_id_, msg.chat_id_) then
          if text:match("^[!/#][Ll]ock (.*)$") or text:match("^قفل (.*)$") then
            local mutept = {string.match(text, "^([!/#][Ll]ock) (.*)$")}
            local mutepts = {string.match(text, "^(قفل) (.*)$")}
            if mutept[2] == "all" or  mutepts[2] == "گروه" then
              if not database:get('bot:muteall'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock all has been *actived* !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل گروه [ همه چیز ] #فعال شد !', 1, 'md')
                end
                database:set('bot:muteall'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock all is *already* actived !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل گروه [ همه چیز ] از قبل #فعال است !', 1, 'md')
                end
              end
            end
            if mutept[2] == "text" or mutepts[2] == "متن" then
              if not database:get('bot:text:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock text has been *actived* !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل متن [ چت ] #فعال شد !', 1, 'md')
                end
                database:set('bot:text:mute'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock text is *already* actived !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل متن [ چت ] از قبل #فعال است !', 1, 'md')
                end
              end
            end
            if mutept[2] == "inline" or mutepts[2] == "دکمه شیشه ای" then
              if not database:get('bot:inline:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock inline has been *actived* !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل دکمه شیشه ایی #فعال شد !', 1, 'md')
                end
                database:set('bot:inline:mute'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock inline is *already* actived !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل دکمه شیشه ایی از قبل #فعال است !', 1, 'md')
                end
              end
            end
            if mutept[2] == "photo" or mutepts[2] == "عکس" then
              if not database:get('bot:photo:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock photo has been *actived* !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل عکس #فعال شد !', 1, 'md')
                end
                database:set('bot:photo:mute'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock photo is *already* actived !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل عکس از قبل #فعال است !', 1, 'md')
                end
              end
            end
            if mutept[2] == "spam" or mutepts[2] == "اسپم" then
              if not database:get('bot:spam:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock spam has been *actived* !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل اسپم #فعال شد !', 1, 'md')
                end
                database:set('bot:spam:mute'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock spam is *already* actived !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل اسپم از قبل #فعال است !', 1, 'md')
                end
              end
            end
            if mutept[2] == "video" or mutepts[2] == "فیلم" then
              if not database:get('bot:video:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock video has been *actived* !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل فیلم #فعال شد !', 1, 'md')
                end
                database:set('bot:video:mute'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock video is *already* actived !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل فیلم از قبل #فعال است !', 1, 'md')
                end
              end
            end
            if mutept[2] == "gif" or mutepts[2] == "گیف" then
              if not database:get('bot:gifs:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock gif has been *actived* !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل گیف #فعال شد !', 1, 'md')
                end
                database:set('bot:gifs:mute'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock gif is *already* actived !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل گیف از قبل #فعال است !', 1, 'md')
                end
              end
            end
            if mutept[2] == "music" or mutepts[2] == "موزیک" then
              if not database:get('bot:music:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock music has been *actived* !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل موزیک #فعال شد !', 1, 'md')
                end
                database:set('bot:music:mute'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock music is *alraedy* actived !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل موزیک از قبل #فعال است !', 1, 'md')
                end
              end
            end
            if mutept[2] == "voice" or mutepts[2] == "ویس" then
              if not database:get('bot:voice:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock voice has been actived !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل ویس #فعال شد !', 1, 'md')
                end
                database:set('bot:voice:mute'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock voice is *already* actived !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل ویس از قبل #فعال است !', 1, 'md')
                end
              end
            end
            if mutept[2] == "links" or mutepts[2] == "لینک" then
              if not database:get('bot:links:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock links has been *actived* !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل لینک #فعال شد ! ', 1, 'md')
                end
                database:set('bot:links:mute'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock links is *already* actived !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل لینک از قبل #فعال است !', 1, 'md')
                end
              end
            end
            if mutept[2] == "location" or mutepts[2] == "موقعیت مکانی" then
              if not database:get('bot:location:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock location has been *actived* ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل موقعیت مکانی #فعال شد ! ', 1, 'md')
                end
                database:set('bot:location:mute'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock location is *already* actived !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل موقعیت مکانی از قبل #فعال است !', 1, 'md')
                end
              end
            end
            if mutept[2] == "tag" or mutepts[2] == "تگ" then
              if not database:get('tags:lock'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock tag has been *actived* !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل تگ #فعال شد ! ', 1, 'md')
                end
                database:set('tags:lock'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock tag is *already* actived !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل تگ از قبل #فعال است !', 1, 'md')
                end
              end
            end
            if mutept[2] == "strict" or  mutepts[2] == "حالت سختگیرانه" then
              if not database:get('bot:strict'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Strict mode has been *enable* ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> حالت [ سختگیرانه ] #فعال شد ! ', 1, 'md')
                end
                database:set('bot:strict'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Strict mode is *already* enable ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> حالت [ سختگیرانه ] از قبل #فعال است ! ', 1, 'md')
                end
              end
            end
            if mutept[2] == "file" or mutepts[2] == "فایل" then
              if not database:get('bot:document:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock file has been *actived* ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل فایل #فعال شد ! ', 1, 'md')
                end
                database:set('bot:document:mute'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock file is *already* actived  !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل فایل از قبل #فعال است !', 1, 'md')
                end
              end
            end
            if mutept[2] == "hashtag" or mutepts[2] == "هشتگ" then
              if not database:get('bot:hashtag:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock hastag has been actived ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل هشتگ #فعال شد ! ', 1, 'md')
                end
                database:set('bot:hashtag:mute'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock hashtag is *already* actived !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل هشتگ از قبل #فعال است !', 1, 'md')
                end
              end
            end
            if mutept[2] == "contact" or mutepts[2] == "مخاطب" then
              if not database:get('bot:contact:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock contact has been *actived* ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل ارسال مخاطب #فعال شد ! ', 1, 'md')
                end
                database:set('bot:contact:mute'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock contact is *already* actived !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل ارسال مخاطب از قبل #فعال است !', 1, 'md')
                end
              end
            end
            if mutept[2] == "webpage" or mutepts[2] == "صفحات اینترنتی" then
              if not database:get('bot:webpage:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock webpage has been *actived* ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل ارسال صفحه اینترنتی #فعال شد ! ', 1, 'md')
                end
                database:set('bot:webpage:mute'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock webpage is *already* actived !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل ارسال صفحه اینترنتی از قبل #فعال است !', 1, 'md')
                end
              end
            end
            if mutept[2] == "farsi" or mutepts[2] == "نوشتار فارسی" then
              if not database:get('bot:arabic:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock farsi has been *actived* ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل نوشتار فارسی #فعال شد ! ', 1, 'md')
                end
                database:set('bot:arabic:mute'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock farsi is *already* actived', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل نوشتار فارسی از قبل #فعال است !', 1, 'md')
                end
              end
            end
            if mutept[2] == "english" or mutepts[2] == "نوشتار انگلیسی" then
              if not database:get('bot:english:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock english has been *actived* ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل نوشتار انگلیسی #فعال شد ! ', 1, 'md')
                end
                database:set('bot:english:mute'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock english is *already* actived !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل نوشتار انگلیسی از قبل #فعال است !', 1, 'md')
                end
              end
            end
            if mutept[2] == "sticker" or mutepts[2] == "استیکر" then
              if not database:get('bot:sticker:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock sticker has been *actived* !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل استیکر #فعال شد ! ', 1, 'md')
                end
                database:set('bot:sticker:mute'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock sticker is *already* actived !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل استیکر از قبل #فعال است !', 1, 'md')
                end
              end
            end
            if mutept[2] == "markdown" or mutepts[2] == "مدل نشانه گذاری" then
              if not database:get('markdown:lock'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock markdown has been *actived* ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل مدل نشانه گذاری #فعال شد ! ', 1, 'md')
                end
                database:set('markdown:lock'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock markdown is *already* actived !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل مدل نشانه گذاری از قبل #فعال است !', 1, 'md')
                end
              end
            end
            if mutept[2] == "tgservice" or mutepts[2] == "سرویس تلگرام" then
              if not database:get('bot:tgservice:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock tgservice has been *actived* ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل سرویس تلگرام #فعال شد ! ', 1, 'md')
                end
                database:set('bot:tgservice:mute'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock tgservice is *already* actived !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل سرویس تلگرام از قبل #فعال است !', 1, 'md')
                end
              end
            end
            if mutept[2] == "fwd" or mutepts[2] == "فروارد" then
              if not database:get('bot:forward:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock forward has been *actived* ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل فروارد #فعال شد ! ', 1, 'md')
                end
                database:set('bot:forward:mute'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock forward is *already* actived !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل فروارد از قبل #فعال است !', 1, 'md')
                end
              end
            end
          end
        end
        -----------------------------------------------------------------------------------------------
        if is_momod(msg.sender_user_id_, msg.chat_id_) then
          if text:match("^[!/#][Uu]nlock (.*)$") or text:match("^بازکردن (.*)$") then
            local unmutept = {string.match(text, "^([!/#][Uu]nlock) (.*)$")}
            local unmutepts = {string.match(text, "^(بازکردن) (.*)$")}
            if unmutept[2] == "all" or unmutept[2] == "gtime" or unmutepts[2] == "گروه" then
              if database:get('bot:muteall'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock all has been *inactived* !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل گروه [ همه چیز ] #غیرفعال شد ! ', 1, 'md')
                end
                database:del('bot:muteall'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock all is *already* inactived ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل گروه [ همه چیز ] از قبل #غیرفعال است ! ', 1, 'md')
                end
              end
            end
            if unmutept[2] == "text" or unmutepts[2] == "متن" then
              if database:get('bot:text:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock text has been *inactived* ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل متن [ چت ] #غیرفعال شد ! ', 1, 'md')
                end
                database:del('bot:text:mute'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock text is *already* inactived ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل متن [ چت ] از قبل #غیرفعال است ! ', 1, 'md')
                end
              end
            end
            if unmutept[2] == "photo" or unmutepts[2] == "عکس" then
              if database:get('bot:photo:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock photo has been *inactived* ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل عکس #غیرفعال شد ! ', 1, 'md')
                end
                database:del('bot:photo:mute'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, 'Lock photo is *already* inactived ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل عکس از قبل #غیرفعال است ! ', 1, 'md')
                end
              end
            end
            if unmutept[2] == "spam" or unmutepts[2] == "اسپم" then
              if database:get('bot:spam:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock spam has been *inactived* ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل اسپم #غیرفعال شد ! ', 1, 'md')
                end
                database:del('bot:spam:mute'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, 'Lock spam is *already* inactived ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل اسپم از قبل #غیرفعال است ! ', 1, 'md')
                end
              end
            end
            if unmutept[2] == "video" or unmutepts[2] == "فیلم" then
              if database:get('bot:video:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock video has been *inactived* ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل فیلم #غیرفعال شد ! ', 1, 'md')
                end
                database:del('bot:video:mute'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, 'Lock video is *already* inactived ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل فیلم از قبل #غیرفعال است ! ', 1, 'md')
                end
              end
            end
            if unmutept[2] == "file" or unmutepts[2] == "فایل" then
              if database:get('bot:document:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock file has been *inactived* ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل فایل #غیرفعال شد ! ', 1, 'md')
                end
                database:del('bot:document:mute'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, 'Lock file is *already* inactived ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل فایل از قبل #غیرفعال است ! ', 1, 'md')
                end
              end
            end
            if unmutept[2] == "inline" or unmutepts[2] == "دکمه شیشه ای" then
              if database:get('bot:inline:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock inline has been *inactived* ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل دکمه شیشه ایی #غیرفعال شد ! ', 1, 'md')
                end
                database:del('bot:inline:mute'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, 'Lock inline is *already* inactived ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل دکمه شیشه ایی از قبل #غیرفعال است ! ', 1, 'md')
                end
              end
            end
            if unmutept[2] == "markdown" or unmutepts[2] == "مدل نشانه گذاری" then
              if database:get('markdown:lock'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock markdown has been *inactived* ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل مدل نشانه گذاری #غیرفعال شد ! ', 1, 'md')
                end
                database:del('markdown:lock'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, 'Lock markdown is *already* inactived ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل مدل نشانه گذاری از قبل #غیرفعال است ! ', 1, 'md')
                end
              end
            end
            if unmutept[2] == "gif" or unmutepts[2] == "گیف" then
              if database:get('bot:gifs:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock gif has been *inactived* ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل گیف #غیرفعال شد ! ', 1, 'md')
                end
                database:del('bot:gifs:mute'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, 'Lock gif is *already* inactived ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل گیف از قبل #غیرفعال است ! ', 1, 'md')
                end
              end
            end
            if unmutept[2] == "music" or unmutepts[2] == "موزیک" then
              if database:get('bot:music:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock music has been *inactived* ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل موزیک #غیرفعال شد ! ', 1, 'md')
                end
                database:del('bot:music:mute'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, 'Lock music is *already* inactived ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل موزیک از قبل #غیرفعال است ! ', 1, 'md')
                end
              end
            end
            if unmutept[2] == "voice" or unmutepts[2] == "ویس" then
              if database:get('bot:voice:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock voice has been *inactived* ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل ویس #غیرفعال شد ! ', 1, 'md')
                end
                database:del('bot:voice:mute'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, 'Lock voice is *already* inactived ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل ویس از قبل #غیرفعال است ! ', 1, 'md')
                end
              end
            end
            if unmutept[2] == "links" or unmutepts[2] == "لینک" then
              if database:get('bot:links:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock links has been *inactived* ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل لینک #غیرفعال شد ! ', 1, 'md')
                end
                database:del('bot:links:mute'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, 'Lock link is *already* inactived ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل لینک از قبل #غیرفعال است ! ', 1, 'md')
                end
              end
            end
            if unmutept[2] == "location" or unmutepts[2] == "موقعیت مکانی" then
              if database:get('bot:location:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock location has been *inactived* ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل موقعیت مکانی #غیرفعال شد ! ', 1, 'md')
                end
                database:del('bot:location:mute'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, 'Lock location is *already* inactived ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل موقعیت مکانی از قبل #غیرفعال است ! ', 1, 'md')
                end
              end
            end
            if unmutept[2] == "tag" or unmutepts[2] == "تگ" then
              if database:get('tags:lock'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock tag has been *inactived* ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل تگ #غیرفعال شد ! ', 1, 'md')
                end
                database:del('tags:lock'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, 'Lock tag is *already* inactived ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل تگ از قبل #غیرفعال است ! ', 1, 'md')
                end
              end
            end
            if unmutept[2] == "strict" or unmutepts[2] == "حالت سختگیرانه" then
              if database:get('bot:strict'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Strict mode has been *inactived* ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> حالت [ سختگیرانه ] #غیرفعال شد ! ', 1, 'md')
                end
                database:del('bot:strict'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, 'Strict mode is *already* inactived ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> حالت [ سختگیرانه ] از قبل #غیرفعال است ! ', 1, 'md')
                end
              end
            end
            if unmutept[2] == "hashtag" or unmutepts[2] == "هشتگ" then
              if database:get('bot:hashtag:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock hashtag has been *inactived* ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل ارسال مخاطب #غیرفعال شد ! ', 1, 'md')
                end
                database:del('bot:hashtag:mute'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, 'Lock hashtag is *already* inactived ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل هشتگ از قبل #غیرفعال است ! ', 1, 'md')
                end
              end
            end
            if unmutept[2] == "contact" or unmutepts[2] == "مخاطب" then
              if database:get('bot:contact:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock contact has been *inactived* ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل مخاطب #غیرفعال شد ! ', 1, 'md')
                end
                database:del('bot:contact:mute'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, 'Lock contact is *already* inactived ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, ' > قفل ارسال مخاطب از قبل #غیرفعال است ! ', 1, 'md')
                end
              end
            end
            if unmutept[2] == "webpage" or unmutepts[2] == "صفحات اینترنتی" then
              if database:get('bot:webpage:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock webpage has been *inactived* ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل ارسال صفحه اینترنتی #غیرفعال شد ! ', 1, 'md')
                end
                database:del('bot:webpage:mute'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, 'Lock webpage is *already* inactived ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل ارسال صفحه اینترنتی از قبل #غیرفعال است !', 1, 'md')
                end
              end
            end
            if unmutept[2] == "farsi" or unmutepts[2] == "نوشتار فارسی" then
              if database:get('bot:arabic:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock farsi has been *inactived* ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل نوشتار فارسی #غیرفعال شد ! ', 1, 'md')
                end
                database:del('bot:arabic:mute'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, 'Lock farsi is *already* inactived ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل نوشتار فارسی از قبل #غیرفعال است ! ', 1, 'md')
                end
              end
            end
            if unmutept[2] == "english" or unmutepts[2] == "نوشتار انگلیسی" then
              if database:get('bot:english:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock english has been *inactived* ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل نوشتار انگلیسی #غیرفعال شد ! ', 1, 'md')
                end
                database:del('bot:english:mute'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, 'Lock english is *already* inactived ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل نوشتار انگلیسی از قبل #غیرفعال است ! ', 1, 'md')
                end
              end
            end
            if unmutept[2] == "tgservice" or unmutepts[2] == "سرویس تلگرام" then
              if database:get('bot:tgservice:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock tgservice has been *inactived* ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل سرویس تلگرام #غیرفعال شد ! ', 1, 'md')
                end
                database:del('bot:tgservice:mute'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, 'Lock tgservice is *already* inactived ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل سرویس تلگرام از قبل #غیرفعال است ! ', 1, 'md')
                end
              end
            end
            if unmutept[2] == "sticker" or unmutepts[2] == "استیکر" then
              if database:get('bot:sticker:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock sticker has been *inactived* ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل استیکر #غیرفعال شد ! ', 1, 'md')
                end
                database:del('bot:sticker:mute'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, 'Lock sticker is *already* inactived ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل استیکر از قبل #غیرفعال است ! ', 1, 'md')
                end
              end
            end
            if unmutept[2] == "fwd" or unmutepts[2] == "فروارد" then
              if database:get('bot:forward:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Lock forward has been *inactived* ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل فروارد #غیرفعال شد ! ', 1, 'md')
                end
                database:del('bot:forward:mute'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, 'Lock forward is *already* inactived ! ', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> قفل فروارد از قبل #غیرفعال است ! ', 1, 'md')
                end
              end
            end
          end
        end
        -----------------------------------------------------------------------------------------------
        if is_momod(msg.sender_user_id_, msg.chat_id_) then
          if text:match("^[!/#][Ss]etspam (%d+)$") then
            local sensspam = {string.match(text, "^([!/#][Ss]etspam) (%d+)$")}
            if tonumber(sensspam[2]) < 40 then
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> Enter a number greater than 40 !', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> عددی بزرگتر از 40 وارد کنید !', 1, 'md')
              end
            else
              database:set('bot:sens:spam'..msg.chat_id_,sensspam[2])
              if not database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> حساسیت اسپم به '..sensspam[2]..' کاراکتر تنظیم شد !\nجملاتی که بیش از '..sensspam[2]..' حرف داشته باشند ، حذف خواهند شد !', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> Spam sensitivity has been set to [ ' ..sensspam[2]..' ] !\nSentences have over '..sensspam[2]..' character will delete !', 1, 'md')
              end
            end
          end
          if text:match("^تنظیم اسپم (%d+)$") then
            local sensspam = {string.match(text, "^(تنظیم اسپم) (%d+)$")}
            if tonumber(sensspam[2]) < 40 then
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> Enter a number greater than 40 !', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> عددی بزرگتر از 40 وارد کنید !', 1, 'md')
              end
            else
              database:set('bot:sens:spam'..msg.chat_id_,sensspam[2])
              if not database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> حساسیت اسپم به '..sensspam[2]..' کاراکتر تنظیم شد !\nجملاتی که بیش از '..sensspam[2]..' حرف داشته باشند ، حذف خواهند شد !', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> Spam sensitivity has been set to [ ' ..sensspam[2]..' ] !\nSentences have over '..sensspam[2]..' character will delete !', 1, 'md')
              end
            end
          end
        end
        -----------------------------------------------------------------------------------------------
        if is_sudo(msg) then
          if text:match("^[!/#][Ee]dit (.*)$") then
            local editmsg = {string.match(text, "^([!/#][Ee]dit) (.*)$")}
            edit(msg.chat_id_, msg.reply_to_message_id_, nil, editmsg[2], 1, 'html')
          end
          if text:match("^ویرایش (.*)$") then
            local editmsgs = {string.match(text, "^(ویرایش) (.*)$")}
            edit(msg.chat_id_, msg.reply_to_message_id_, nil,editmsgs[2], 1, 'html')
          end
        end
        -----------------------------------------------------------------------------------------------
        if is_momod(msg.sender_user_id_, msg.chat_id_) then
          if text:match("^[!/#][Cc]lean (.*)$") or text:match("^پاکسازی (.*)$")then
            local txt = {string.match(text, "^([!/#][Cc]lean) (.*)$")}
            local txts = {string.match(text, "^(پاکسازی) (.*)$")}
            if txt[2] == 'banlist' or txts[2] == 'لیست افراد مسدود' then
              database:del('bot:banned:'..msg.chat_id_)
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> Banlist has been cleared !', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> لیست افراد مسدود پاکسازی شد !', 1, 'md')
              end
            end
            if is_sudo(msg) then
              if txt[2] == 'banalllist' or txts[2] == 'لیست افراد تحت مسدودیت' then
                database:del('bot:gban:')
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '> Banlist has been cleared !', 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '> لیست افراد مسدود پاکسازی شد !', 1, 'md')
                end
              end
            end
            if txt[2] == 'bots' or txts[2] == 'ربات ها' then
              local function g_bots(extra,result,success)
                local bots = result.members_
                for i=0 , #bots do
                  chat_kick(msg.chat_id_, bots[i].user_id_)
                end
              end
              channel_get_bots(msg.chat_id_,g_bots)
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> All bots has been removed from group !', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> تمامی ربات ها از گروه پاکسازی شدند !', 1, 'md')
              end
            end
            if txt[2] == 'modlist' or txts[2] == 'لیست مدیران گروه' then
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> Mod list has been cleared ', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> لیست مدیران گروه پاکسازی شد !', 1, 'md')
              end
              database:del('bot:momod:'..msg.chat_id_)
            end
            if txt[2] == 'viplist' or txts[2] == 'لیست عضو های ویژه' then
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> VIP Members list has been cleared ', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> لیست اعضای ویژه پاکسازی شد !', 1, 'md')
              end
              database:del('bot:vipmem:'..msg.chat_id_)
            end
            if txt[2] == 'filterlist' or txts[2] == 'لیست فیلتر' then
              local hash = 'bot:filters:'..msg.chat_id_
              database:del(hash)
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> Filterlist has been cleared !', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> لیست کلمات فیلتر شده پاکسازی شد !', 1, 'md')
              end
            end
            if txt[2] == 'freelist' or txts[2] == 'لیست مجاز' then
              local hash = 'bot:freewords:'..msg.chat_id_
              database:del(hash)
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> Freelist has been cleared !', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> لیست عنوان های مجاز پاکسازی شد !', 1, 'md')
              end
            end
            if txt[2] == 'mutelist' or txts[2] == 'لیست افراد بی صدا' then
              database:del('bot:muted:'..msg.chat_id_)
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> Muted users list has been cleared !', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> لیست افراد بی صدا پاکسازی شد !', 1, 'md')
              end
            end
          end
        end
        -----------------------------------------------------------------------------------------------
        if is_momod(msg.sender_user_id_, msg.chat_id_) then
          if text:match("^[Ss]ettings$") or text:match("^تنظیمات$") then
            if database:get('bot:muteall'..msg.chat_id_) then
              mute_all = '#فعال'
            else
              mute_all = '#غیرفعال'
            end
            ------------
            if database:get('bot:text:mute'..msg.chat_id_) then
              mute_text = '#فعال'
            else
              mute_text = '#غیرفعال'
            end
            ------------
            if database:get('bot:photo:mute'..msg.chat_id_) then
              mute_photo = '#فعال'
            else
              mute_photo = '#غیرفعال'
            end
            ------------
            if database:get('bot:video:mute'..msg.chat_id_) then
              mute_video = '#فعال'
            else
              mute_video = '#غیرفعال'
            end
            ------------
            if database:get('bot:gifs:mute'..msg.chat_id_) then
              mute_gifs = '#فعال'
            else
              mute_gifs = '#غیرفعال'
            end
            ------------
            if database:get('anti-flood:'..msg.chat_id_) then
              mute_flood = '#فعال'
            else
              mute_flood = '#غیرفعال'
            end
            ------------
            if not database:get('flood:max:'..msg.chat_id_) then
              flood_m = 5
            else
              flood_m = database:get('flood:max:'..msg.chat_id_)
            end
            ------------
            if not database:get('bot:sens:spam'..msg.chat_id_) then
              spam_c = 250
            else
              spam_c = database:get('bot:sens:spam'..msg.chat_id_)
            end
            ------------
            if database:get('floodstatus'..msg.chat_id_) == "DelMsg" then
              floodstatus = "حذف پیام"
            elseif database:get('floodstatus'..msg.chat_id_) == "Kicked" then
              floodstatus = "اخراج"
            elseif not database:get('floodstatus'..msg.chat_id_) then
              floodstatus = "حذف پیام"
            end
            ----------------------------------------------------
            if database:get('bot:music:mute'..msg.chat_id_) then
              mute_music = '#فعال'
            else
              mute_music = '#غیرفعال'
            end
            ------------
            if database:get('bot:bots:mute'..msg.chat_id_) then
              mute_bots = '#فعال'
            else
              mute_bots = '#غیرفعال'
            end
            ------------
            if database:get('bot:inline:mute'..msg.chat_id_) then
              mute_in = '#فعال'
            else
              mute_in = '#غیرفعال'
            end
            ------------
            if database:get('bot:cmds'..msg.chat_id_) then
              mute_cmd = '#فعال'
            else
              mute_cmd = '#غیرفعال'
            end
            ------------
            if database:get('bot:voice:mute'..msg.chat_id_) then
              mute_voice = '#فعال'
            else
              mute_voice = '#غیرفعال'
            end

            ------------
            if database:get('editmsg'..msg.chat_id_) then
              mute_edit = '#فعال'
            else
              mute_edit = '#غیرفعال'
            end

            ------------
            if database:get('bot:links:mute'..msg.chat_id_) then
              mute_links = '#فعال'
            else
              mute_links = '#غیرفعال'
            end
            ------------
            if database:get('bot:pin:mute'..msg.chat_id_) then
              lock_pin = '#فعال'
            else
              lock_pin = '#غیرفعال'
            end
            ------------
            if database:get('bot:sticker:mute'..msg.chat_id_) then
              lock_sticker = '#فعال'
            else
              lock_sticker = '#غیرفعال'
            end
            ------------
            if database:get('bot:tgservice:mute'..msg.chat_id_) then
              lock_tgservice = '#فعال'
            else
              lock_tgservice = '#غیرفعال'
            end
            ------------
            if database:get('bot:webpage:mute'..msg.chat_id_) then
              lock_wp = '#فعال'
            else
              lock_wp = '#غیرفعال'
            end
            ------------
            if database:get('bot:strict'..msg.chat_id_) then
              strict = '#فعال'
            else
              strict = '#غیرفعال'
            end
            ------------
            if database:get('bot:hashtag:mute'..msg.chat_id_) then
              lock_htag = '#فعال'
            else
              lock_htag = '#غیرفعال'
            end
            ------------
            if database:get('tags:lock'..msg.chat_id_) then
              lock_tag = '#فعال'
            else
              lock_tag = '#غیرفعال'
            end
            ------------
            if database:get('bot:location:mute'..msg.chat_id_) then
              lock_location = '#فعال'
            else
              lock_location = '#غیرفعال'
            end
            ------------
            if database:get('bot:contact:mute'..msg.chat_id_) then
              lock_contact = '#فعال'
            else
              lock_contact = '#غیرفعال'
            end
            ------------
            if database:get('bot:english:mute'..msg.chat_id_) then
              lock_english = '#فعال'
            else
              lock_english = '#غیرفعال'
            end
            ------------
            if database:get('bot:arabic:mute'..msg.chat_id_) then
              lock_arabic = '#فعال'
            else
              lock_arabic = '#غیرفعال'
            end
            ------------
            if database:get('bot:forward:mute'..msg.chat_id_) then
              lock_forward = '#فعال'
            else
              lock_forward = '#غیرفعال'
            end
            ------------
            if database:get('bot:document:mute'..msg.chat_id_) then
              lock_file = '#فعال'
            else
              lock_file = '#غیرفعال'
            end
            ------------
            if database:get('markdown:lock'..msg.chat_id_) then
              markdown = '#فعال'
            else
              markdown = '#غیرفعال'
            end
            ------------
            if database:get('bot:spam:mute'..msg.chat_id_) then
              lock_spam = '#فعال'
            else
              lock_spam = '#غیرفعال'
            end
            ------------
            if database:get("bot:welcome"..msg.chat_id_) then
              send_welcome = '#فعال'
            else
              send_welcome = '#غیرفعال'
            end
            ------------
            local TXTFA = "⚙ تنظیمات گروه :\n\n"
            .."> حالت سختگیرانه : "..strict.."\n"
            .."> حالت قفل کلی گروه : "..mute_all.."\n"
            .."> حالت عدم جواب : "..mute_cmd.."\n\n"
            .."🔃 قفل های اصلی :\n\n"
            .."> قفل اسپم : "..lock_spam.."\n"
            .."> قفل لینک : "..mute_links.."\n"
            .."️> قفل آدرس اینترنتی :  "..lock_wp.."\n"
            .."> قفل تگ : "..lock_tag.."\n"
            .."️> قفل هشتگ : "..lock_htag.."\n"
            .."> قفل فروارد : "..lock_forward.."\n"
            .."> قفل ورود ربات :  "..mute_bots.."\n"
            .."️> قفل ویرایش پیام :  "..mute_edit.."\n"
            .."️> قفل سنجاق پیام : "..lock_pin.."\n"
            .."> قفل دکمه شیشه ایی : "..mute_in.."\n"
            .."> قفل نوشتار فارسی :  "..lock_arabic.."\n"
            .."> قفل نوشتار انگلیسی : "..lock_english.."\n"
            .."> قفل مدل نشانه گذاری : "..markdown.."\n"
            .."️> قفل سرویس تلگرام : "..lock_tgservice.."\n"
            .."> قفل فلود : "..mute_flood.."\n"
            .."> وضعیت فلود : "..floodstatus.."\n"
            .."> حساسیت فلود : [ "..flood_m.." ]\n"
            .."️> حساسیت اسپم : [ "..spam_c.." ]\n\n"
            .." 🔃قفل های رسانه :\n\n"
            .."> قفل متن [ چت ] : "..mute_text.."\n"
            .."> قفل عکس : "..mute_photo.."\n"
            .."> قفل فیلم : "..mute_video.."\n"
            .."> قفل گیف : "..mute_gifs.."\n"
            .."> قفل موزیک : "..mute_music.."\n"
            .."> قفل ویس : "..mute_voice.."\n"
            .."> قفل فایل : "..lock_file.."\n"
            .."> قفل استیکر : "..lock_sticker.."\n"
            .."> قفل ارسال مخاطب : "..lock_contact.."\n"
            .."️> قفل موقعیت مکانی : "..lock_location.."\n"
            local TXTEN = "⚙ Group Settings :\n\n"
            .."> *Strict Mode* : "..strict.."\n"
            .."> *Group lock All* : "..mute_all.."\n"
            .."> *Case of no answer* : "..mute_cmd.."\n\n"
            .."🔃 *Centerial Settings* :\n\n"
            .."> *Lock Spam* : "..lock_spam.."\n"
            .."> *Lock Links* : "..mute_links.."\n"
            .."️> *Lock Web-Page* :  "..lock_wp.."\n"
            .."> *Lock Tag* : "..lock_tag.."\n"
            .."️> *Lock Hashtag* : "..lock_htag.."\n"
            .."> *Lock Forward* : "..lock_forward.."\n"
            .."> *Lock Bots* :  "..mute_bots.."\n"
            .."️> *Lock Edit* :  "..mute_edit.."\n"
            .."️> *Lock Pin* : "..lock_pin.."\n"
            .."> *Lock Inline* : "..mute_in.."\n"
            .."> *Lock Farsi* :  "..lock_arabic.."\n"
            .."> *Lock English* : "..lock_english.."\n"
            .."> *Lock MarkDown* : "..markdown.."\n"
            .."️> *Lock TgService* : "..lock_tgservice.."\n"
            .."> *Lock Flood* : "..mute_flood.."\n"
            .."> *Flood Status* : "..floodstatus.."\n"
            .."> *Flood Sensitivity* : [ "..flood_m.." ]\n"
            .."️> *Spam Sensitivity* : [ "..spam_c.." ]\n\n"
            .." 🔃 *Media Settings* :\n\n"
            .."> *Lock Text* : "..mute_text.."\n"
            .."> *Lock Photo* : "..mute_photo.."\n"
            .."> *Lock Videos* : "..mute_video.."\n"
            .."> *Lock Gifs* : "..mute_gifs.."\n"
            .."> *Lock Music* : "..mute_music.."\n"
            .."> *Lock Voice* : "..mute_voice.."\n"
            .."> *Lock File* : "..lock_file.."\n"
            .."> *Lock Sticker* : "..lock_sticker.."\n"
            .."> *Lock Contact* : "..lock_contact.."\n"
            .."️> *Lock location* : "..lock_location.."\n"
            TXTEN = TXTEN:gsub("#فعال","Active")
            TXTEN = TXTEN:gsub("#غیرفعال","Inactive")
            TXTEN = TXTEN:gsub("حذف پیام","Deleting")
            TXTEN = TXTEN:gsub("اخراج","Kicking")
            if database:get('lang:gp:'..msg.chat_id_) then
              send(msg.chat_id_, msg.id_, 1, TXTEN, 1, 'md')
            else
              send(msg.chat_id_, msg.id_, 1, TXTFA, 1, 'md')
            end
          end
        end
        -----------------------------------------------------------------------------------------------
        if text:match("^[!/#][Ee]cho (.*)$") and is_leader(msg) then
          local txt = {string.match(text, "^([!/#][Ee]cho) (.*)$")}
          send(msg.chat_id_,0, 1, txt[2], 1, 'md')
          local id = msg.id_
          local msgs = {[0] = id}
          local chat = msg.chat_id_
          delete_msg(chat,msgs)
        end
        -----------------------------------------------------------------------------------------------
        if is_momod(msg.sender_user_id_, msg.chat_id_) then
          if text:match("^[!/#][Ss]etrules (.*)$") then
            local txt = {string.match(text, "^([!/#][Ss]etrules) (.*)$")}
            database:set('bot:rules'..msg.chat_id_, txt[2])
            if database:get('lang:gp:'..msg.chat_id_) then
              send(msg.chat_id_, msg.id_, 1, '> Group rules has been saved !', 1, 'md')
            else
              send(msg.chat_id_, msg.id_, 1, '> قوانین گروه تنظیم شد !', 1, 'md')
            end
          end
          if text:match("^تنظیم قوانین (.*)$") then
            local txt = {string.match(text, "^(تنظیم قوانین) (.*)$")}
            database:set('bot:rules'..msg.chat_id_, txt[2])
            if database:get('lang:gp:'..msg.chat_id_) then
              send(msg.chat_id_, msg.id_, 1, '> Group rules has been saved !', 1, 'md')
            else
              send(msg.chat_id_, msg.id_, 1, '> قوانین گروه تنظیم شد !', 1, 'md')
            end
          end
        end
        -----------------------------------------------------------------------------------------------
        if text:match("^[!/#][Nn]ote (.*)$") and is_leader(msg) then
          local txt = {string.match(text, "^([!/#][Nn]ote) (.*)$")}
          database:set('owner:note1', txt[2])
          if database:get('lang:gp:'..msg.chat_id_) then
            send(msg.chat_id_, msg.id_, 1, '> Saved !', 1, 'md')
          else
            send(msg.chat_id_, msg.id_, 1, '> ذخیره شد !', 1, 'md')
          end
        end
        -----------------------------------------------------------------------------------------------
        if text:match("^[!/#][Gg]etnote$") and is_leader(msg) then
          local note = database:get('owner:note1')
          send(msg.chat_id_, msg.id_, 1, note, 1, nil)
        end
        -------------------------------------------------------------------------------------------------
        if text:match("^[!/#][Rr]ules$") or text:match("^دریافت قوانین$") then
          local rules = database:get('bot:rules'..msg.chat_id_)
          send(msg.chat_id_, msg.id_, 1, rules, 1, nil)
        end
        -----------------------------------------------------------------------------------------------
        if text:match("^[!/#][Ss]hare$") and is_sudo(msg) then
          sendContact(msg.chat_id_, msg.id_, 0, 1, nil, 14433047824, 'Sphero', 'TC', 228572542)
        end
        -----------------------------------------------------------------------------------------------
        if text:match("^[!/#][Ss]etname (.*)$") or text:match("^تنظیم نام گروه (.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
          local txt = {string.match(text, "^([!/#][Ss]etname) (.*)$")}
          local txt = {string.match(text, "^(تنظیم نام گروه) (.*)$")}
          changetitle(msg.chat_id_, txt[2])
          if database:get('lang:gp:'..msg.chat_id_) then
            send(msg.chat_id_, msg.id_, 1, '> Group name has been changed !', 1, 'md')
          else
            send(msg.chat_id_, msg.id_, 1, '> نام گروه تغییر یافت !', 1, 'md')
          end
        end
        -----------------------------------------------------------------------------------------------
        if text:match("^[!/#][Ss]etphoto$") or text:match("^تنظیم عکس گروه$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
          if database:get('lang:gp:'..msg.chat_id_) then
            send(msg.chat_id_, msg.id_, 1, '> Plese send group photo :', 1, 'md')
          else
            send(msg.chat_id_, msg.id_, 1, '> لطفا عکس را ارسال کنید :', 1, 'md')
          end
          database:set('bot:setphoto'..msg.chat_id_..':'..msg.sender_user_id_,true)
        end
        -----------------------------------------------------------------------------------------------
        if text:match("^[!/#][Cc]harge (%d+)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
          local a = {string.match(text, "^([!/#][Cc]harge) (%d+)$")}
            if database:get('lang:gp:'..msg.chat_id_) then
              send(msg.chat_id_, msg.id_, 1, '> Group has been charged for '..a[2]..' day(s)!', 1, 'md')
            else
              send(msg.chat_id_, msg.id_, 1, '> گروه برای مدت '..a[2]..' روز شارژ شد !', 1, 'md')
            end
            local time = a[2] * day
            database:setex("bot:charge:"..msg.chat_id_,time,true)
            database:set("bot:enable:"..msg.chat_id_,true)
          end
        if text:match("^[!/#][Cc]harge [Uu]nit$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
          function unit(extra,result,success)
            local v = tonumber(bot_owner)
            send(msg.chat_id_, msg.id_, 1, '> این گروه به صورت نامحدود شارژ شد !', 1, 'md')
            send(v, 0, 1,'> همکار '..result.first_name_..' با شناسه : '..msg.sender_user_id_..' گروه با نام '..chat.title_..' را به صورت نامحدود شارژ کرد !', 1, 'md')
            database:set("bot:charge:"..msg.chat_id_,true)
            database:set("bot:enable:"..msg.chat_id_,true)
          end
          getUser(msg.sender_user_id_,unit)
        end
        -----------------------------------------------------------------------------------------------
        if is_momod(msg.sender_user_id_, msg.chat_id_) then
          if text:match("^[!/#][Ee]xpire") or text:match("^اعتبار گروه") then
            local ex = database:ttl("bot:charge:"..msg.chat_id_)
            if ex == -1 then
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> Unlimited !', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> بدون محدودیت ( نامحدود ) !', 1, 'md')
              end
            else
              local b = math.floor(ex / day ) + 1
              if b == 0 then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, "> Credit Group has ended !", 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, "> اعتبار گروه به پایان رسیده است !", 1, 'md')
                end
              else
                local d = math.floor(ex / day ) + 1
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, "> Group have validity for "..d.." day(s)", 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, "> گروه دارای "..d.." روز اعتبار میباشد ", 1, 'md')
                end
              end
            end
          end
        end
		        -----------------------------------------------------------------------------------------------
        if is_momod(msg.sender_user_id_, msg.chat_id_) then
          if text:match("^[!/#][Pp]in$") or text:match("^سنجاق کن$") and msg.reply_to_message_id_ == 0 then
            local id = msg.id_
            local msgs = {[0] = id}
            pinmsg(msg.chat_id_,msg.reply_to_message_id_,'')
            database:set('pinnedmsg'..msg.chat_id_, msg.reply_to_message_id_)
			                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, "> The message has been pinned !", 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, "> پیام مورد نظر سنجاق شد ! ", 1, 'md')
                end
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[!/#][Uu]npin$") or text:match("^حذف سنجاق$") then
            unpinmsg(msg.chat_id_)
			             if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, "> The message has been unpinned !", 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, "> پیام سنجاق شده از حالت سنجاق خارج شد !", 1, 'md')
                end
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[!/#][Rr]epin$") or text:match("^سنجاق مجدد$") then
            local pin_id = database:get('pinnedmsg'..msg.chat_id_)
            if pin_id then
              pinmsg(msg.chat_id_,pin_id,0)
             if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, "> The message has been repinned !", 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, "> پیام سنجاق شده سابق مجدد سنجاق شد !", 1, 'md')
                end
				else
				             if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, "> Message pinned the former was not found !", 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, "> پیام سنجاق شده سابق یافت نشد  !", 1, 'md')
                end
            end
          end
        end
        -----------------------------------------------------------------------------------------------
        if text:match("^[!/#][Cc]harge stats (%d+)") and is_admin(msg.sender_user_id_, msg.chat_id_) then
          local txt = {string.match(text, "^([!/#][Cc]harge stats) (%d+)$")}
          local ex = database:ttl("bot:charge:"..txt[2])
          if ex == -1 then
            send(msg.chat_id_, msg.id_, 1, '> بدون محدودیت ( نامحدود ) !', 1, 'md')
          else
            local d = math.floor(ex / day ) + 1
            send(msg.chat_id_, msg.id_, 1, "> گروه دارای "..d.." روز اعتبار میباشد ", 1, 'md')
          end
        end
        -----------------------------------------------------------------------------------------------
        if text:match("^[!/#][Ll]eave(-%d+)") and is_admin(msg.sender_user_id_, msg.chat_id_) then
          local txt = {string.match(text, "^([!/#][Ll]eave)(-%d+)$")}
          send(msg.chat_id_, msg.id_, 1, 'ربات با موفقیت از گروه '..txt[2]..' خارج شد.', 1, 'md')
          if database:get('lang:gp:'..txt[2]) then
            send(txt[2], 0, 1, '⚠️ *The robot for some reason left the band!*\n*For more information, stay tuned to support* ✅', 1, 'html')
          else
            send(txt[2], 0, 1, '⚠️ ربات به دلایلی گروه را ترک میکند\nبرای اطلاعات بیشتر میتوانید با پشتیبانی در ارتباط باشید ✅', 1, 'html')
          end
          chat_leave(txt[2], bot_id)
          database:srem("bot:groups",txt[2])
        end
        -----------------------------------------------------------------------------------------------
        if text:match('^[!/#][Pp]lan1(-%d+)') and is_admin(msg.sender_user_id_, msg.chat_id_) then
          local txt = {string.match(text, "^([!/#][Pp]lan1)(-%d+)$")}
          local timeplan1 = 2592000
          database:setex("bot:charge:"..txt[2],timeplan1,true)
          send(msg.chat_id_, msg.id_, 1, 'پلن 1 با موفقیت برای گروه '..txt[2]..' فعال شد\nاین گروه تا 30 روز دیگر اعتبار دارد! ( 1 ماه )', 1, 'md')
          database:set("bot:enable:"..txt[2],true)
        end
        -----------------------------------------------------------------------------------------------
        if text:match('^[!/#][Pp]lan2(-%d+)') and is_admin(msg.sender_user_id_, msg.chat_id_) then
          local txt = {string.match(text, "^([!/#][Pp]lan2)(-%d+)$")}
          local timeplan2 = 7776000
          database:setex("bot:charge:"..txt[2],timeplan2,true)
          send(msg.chat_id_, msg.id_, 1, 'پلن 2 با موفقیت برای گروه '..txt[2]..' فعال شد\nاین گروه تا 90 روز دیگر اعتبار دارد! ( 3 ماه )', 1, 'md')
          database:set("bot:enable:"..txt[2],true)
        end
        -----------------------------------------------------------------------------------------------
        if text:match('^[!/#][Pp]lan3(-%d+)') and is_admin(msg.sender_user_id_, msg.chat_id_) then
          local txt = {string.match(text, "^([!/#][Pp]lan3)(-%d+)$")}
          database:set("bot:charge:"..txt[2],true)
          send(msg.chat_id_, msg.id_, 1, 'پلن 3 با موفقیت برای گروه '..txt[2]..' فعال شد\nاین گروه به صورت نامحدود شارژ شد!', 1, 'md')
          database:set("bot:enable:"..txt[2],true)
        end
        -----------------------------------------------------------------------------------------------
        if text:match('^[!/#][Aa]dd$') and is_admin(msg.sender_user_id_, msg.chat_id_) then
          function adding(extra,result,success)
            local txt = {string.match(text, "^([!/#][Aa]dd)$")}
            if database:get("bot:enable:"..msg.chat_id_) then
              if not database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, ' گروه از قبل در لیست مدیریتی ربات میباشد !', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> This group is already in list management !', 1, 'md')
              end
            else
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> This group has been added to list management !', 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '> گروه به لیست مدیریتی ربات اضافه شد !', 1, 'md')
              end
            --  send(bot_owner, 0, 1, '> گروه جدیدی به لیست مدیریتی ربات اضافه شد !\n\n🌀 مشخصات همکار اضافه کننده :\n🔸آیدی همکار : '..msg.sender_user_id_..'\n🔸نام همکار : '..result.first_name_..'\n\n🌀مشخصات گروه :\n🔸 آیدی گروه : '..msg.chat_id_..'\n🔸نام گروه : '..chat.title_..'\n\n🔹اگر میخواهید ربات گروه را ترک کند از دستور زیر استفاده کنید : \n\n🔖 leave'..msg.chat_id_..'\n\n🔸اگر قصد وارد شدن به گروه را دارید از دستور زیر استفاده کنید : \n\n🔖 join'..msg.chat_id_..'\n\n🔅🔅🔅🔅🔅🔅\n\n📅 اگر قصد تمدید گروه را دارید از دستورات زیر استفاده کنید : \n\n⭕️برای شارژ به صورت یک ماه :\n🔖 plan1'..msg.chat_id_..'\n\n⭕️برای شارژ به صورت سه ماه :\n🔖 plan2'..msg.chat_id_..'\n\n⭕️برای شارژ به صورت نامحدود :\n🔖 plan3'..msg.chat_id_..'\n' , 1, 'html')
              database:set("bot:enable:"..msg.chat_id_,true)
              database:setex("bot:charge:"..msg.chat_id_,900,true)
              database:sadd('sudo:data:'..msg.sender_user_id_, msg.chat_id_)
            end
          end
          getUser(msg.sender_user_id_,adding)
        end
        -----------------------------------------------------------------------------------------------
        if text:match('^[!/#][Rr]em$') and is_admin(msg.sender_user_id_, msg.chat_id_) then
          local txt = {string.match(text, "^([!/#][Rr]em)$")}
          if not database:get("bot:enable:"..msg.chat_id_) then
            if database:get('lang:gp:'..msg.chat_id_) then
              send(msg.chat_id_, msg.id_, 1, '> Group is not in list management !', 1, 'md')
            else
              send(msg.chat_id_, msg.id_, 1, '> گروه در لیست مدیریتی ربات نیست !', 1, 'md')
            end
          else
            if database:get('lang:gp:'..msg.chat_id_) then
              send(msg.chat_id_, msg.id_, 1, '> Group has been removed from list management !', 1, 'md')
            else
              send(msg.chat_id_, msg.id_, 1, '> گروه از لیست مدیریتی ربات حذف شد !', 1, 'md')
            end
            database:del("bot:charge:"..msg.chat_id_)
            database:del("bot:enable:"..msg.chat_id_)
            database:srem('sudo:data:'..msg.sender_user_id_, msg.chat_id_)
            local v = tonumber(bot_owner)
            send(v, 0, 1, "⭕️ گروهی با مشخصات زیر از لیست مدیریتی حذف شد !\n\n 🌀مشخصات فرد حذف کننده : \n 🔹آیدی فرد : "..msg.sender_user_id_.."\n\n 🌀مشخصات گروه :\n 🔸آیدی گروه : "..msg.chat_id_.."\n 🔸نام گروه : "..chat.title_ , 1, 'md')
          end
        end
        if text:match('^[Rr]em(-%d+)$') and is_admin(msg.sender_user_id_, msg.chat_id_) then
          local gp = {string.match(text, "^([Rr]em)(-%d+)$")}
          database:del("bot:charge:"..gp[2])
          local v = tonumber(bot_owner)
          send(msg.chat_id_, msg.id_, 1, '> گروه با شناسه '..gp[2]..' از لیست مدیریتی ربات حذف شد !', 1, 'md')
          send(v, 0, 1, "⭕️ گروهی با مشخصات زیر از لیست مدیریتی حذف شد !\n\n 🌀مشخصات فرد حذف کننده : \n 🔹آیدی فرد : "..msg.sender_user_id_.."\n\n 🌀مشخصات گروه :\n 🔸آیدی گروه : "..gp[2] , 1, 'md')
        end
        -----------------------------------------------------------------------------------------------
        if text:match('^[!/#][Ss]erverinfo') and is_sudo(msg) then
          local s = io.popen("sh ./data.sh")
          local text = ( s:read("*a") )
          send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
        end
        ----------------------------------------------------------------------------------------------
        if text:match('^[!/#][Dd]ata (%d+)') and is_sudo(msg) then
          local txt = {string.match(text, "^([!/#][Dd]ata) (%d+)$")}
          local hash =  'sudo:data:'..txt[2]
          local list = database:smembers(hash)
          if tonumber(txt[2]) == 181612899 then
            name = "محمد"
          elseif tonumber(txt[2]) == 192191034 then
            name = "احسان"
          elseif tonumber(txt[2]) == 222751735 then
            name = "محمد رضا"
          elseif tonumber(txt[2]) == 258220821 then
            name = "دانیال"
          elseif tonumber(txt[2]) == 272376346 then
            name = "علیرضا"
          elseif tonumber(txt[2]) == 228572542 then
            name = "سجاد مومن"
          else
            name = "ناشناس"
            --elseif txt[2] ==
            --name =
            --elseif txt[2] ==
            --name =
            --elseif txt[2] ==
            --name =
            --elseif txt[2] ==
            --name =
          end
          local text = " > اطلاعات همکار : \n\n نام : "..name.."\n\n  گروه های اضافه شده توسط این فرد :\n\n"
          for k,v in pairs(list) do
            text = text..'\n'..k.." : "..v.."\n"
          end
          if #list == 0 then
            text = "> اطلاعات همکار : \n\n نام : "..name.." \n\n تا به حال گروهی به ربات اضافه نکرده است "
          end
          send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
        end
        -----------------------------------------------------------------------------------------------
        if text:match('^[!/#][Aa]ddgp (%d+) (-%d+)') and is_leader(msg) then
          local txt = {string.match(text, "^([!/#][Aa]ddgp) (%d+) (-%d+)$")}
          local sudo = txt[2]
          local gp = txt[3]
          send(msg.chat_id_, msg.id_, 1, "> گروه مورد نظر با موفقیت به لیست گروه های همکار با شناسه : "..txt[2].." #اضافه شد", 1, 'html')
          database:sadd('sudo:data:'..sudo, gp)
        end
        -----------------------------------------------------------------------------------------------
        if text:match('^[!/#][Rr]emgp (%d+) (-%d+)') and is_leader(msg) then
          local txt = {string.match(text, "^([!/#][Rr]emgp) (%d+) (-%d+)$")}
          local hash = 'sudo:data:'..txt[2]
          local gp = txt[3]
          send(msg.chat_id_, msg.id_, 1, "> گروه مورد نظر با موفقیت از لیست گروه های همکار با شناسه : "..txt[2].." #حذف شد", 1, 'html')
          database:srem(hash, gp)
        end
        -----------------------------------------------------------------------------------
        if text:match('^[!/#][Jj]oin(-%d+)') and is_admin(msg.sender_user_id_, msg.chat_id_) then
          local txt = {string.match(text, "^([!/#][Jj]oin)(-%d+)$")}
          send(msg.chat_id_, msg.id_, 1, 'باموفقیت شما را به گروه '..txt[2]..' اضافه کردم !', 1, 'md')
          add_user(txt[2], msg.sender_user_id_, 20)
        end
        ------------------------------------------------------------------------------------
        if text:match('^[!/#][Mm]eld(-%d+)') and is_sudo(msg) then
          local meld = {string.match(text, "^([!/#][Mm]eld)(-%d+)$")}
          send(msg.chat_id_, msg.id_, 1, '> با موفقیت در گروه مورد نظر اعلام گردید !', 1, 'md')
          if database:get('lang:gp:'..meld[2]) then
            send(meld[2], 0, 1, '⚠️ *Dear Manager :\n\nCredibility of this group is over !\n\nPlease visit as soon as possible to recharge the robot support* !', 1, 'md')
          else
            send(meld[2], 0, 1, '⚠️_ مدیران گرامی :\n\nاعتبار این گروه به پایان رسیده است !\n\nلطفا هرچه سریع تر برای شارژ مجدد به پشتیبانی ربات مراجعه فرمایید !_', 1, 'md')
          end
        end
        ----------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------
        if is_momod(msg.sender_user_id_, msg.chat_id_) then
          if text:match('^[!/#]rmsg (%d+)$') then
            local matches = {string.match(text, "^([!/#]rmsg) (%d+)$")}
            if msg.chat_id_:match("^-100") then
              if tonumber(matches[2]) > 100 or tonumber(matches[2]) < 1 then
                if database:get('lang:gp:'..msg.chat_id_) then
                  pm = '> Please use a number greater than 1 and less than 100 !'
                else
                  pm = '> لطفا از عددی بزرگتر از 1 و کوچکتر از 100 استفاده کنید !'
                end
                send(msg.chat_id_,0, 1, pm, 1, 'html')
              else
                tdcli_function ({
                  ID = "GetChatHistory",
                  chat_id_ = msg.chat_id_,
                  from_message_id_ = 0,
                  offset_ = 0,
                  limit_ = tonumber(matches[2])
                }, delmsg, nil)
                if database:get('lang:gp:'..msg.chat_id_) then
                  pm ='> *'..matches[2]..' recent message removed*!'
                else
                  pm ='> '..matches[2]..' پیام اخیر حذف شد !'
                end
                send(msg.chat_id_,0, 1, pm, 1, 'html')
              end
            else
              if database:get('lang:gp:'..msg.chat_id_) then
                pm ='> This is not possible in the conventional group !'
              else
                pm ='> در گروه معمولی این امکان وجود ندارد !'
              end
              send(msg.chat_id_, msg.id_, 1, pm, 1, 'html')
            end
          end
          if text:match('^پاکسازی (%d+)$') then
            local matches = {string.match(text, "^(پاکسازی) (%d+)$")}
            if msg.chat_id_:match("^-100") then
              if tonumber(matches[2]) > 100 or tonumber(matches[2]) < 1 then
                if database:get('lang:gp:'..msg.chat_id_) then
                  pm = '> Please use a number greater than 1 and less than 100 !'
                else
                  pm = '> لطفا از عددی بزرگتر از 1 و کوچکتر از 100 استفاده کنید !'
                end
                send(msg.chat_id_,0, 1, pm, 1, 'html')
              else
                tdcli_function ({
                  ID = "GetChatHistory",
                  chat_id_ = msg.chat_id_,
                  from_message_id_ = 0,
                  offset_ = 0,
                  limit_ = tonumber(matches[2])
                }, delmsg, nil)
                if database:get('lang:gp:'..msg.chat_id_) then
                  pm ='> *'..matches[2]..' recent message removed*!'
                else
                  pm ='> '..matches[2]..' پیام اخیر حذف شد !'
                end
                send(msg.chat_id_,0, 1, pm, 1, 'html')
              end
            else
              if database:get('lang:gp:'..msg.chat_id_) then
                pm ='> This is not possible in the conventional group !'
              else
                pm ='> در گروه معمولی این امکان وجود ندارد !'
              end
              send(msg.chat_id_, msg.id_, 1, pm, 1, 'html')
            end
          end
        end
        ----------------------------------------------------------------------------------------------
        if text:match("^[!/#][Mm]e$") then
          function get_me(extra,result,success)
            if is_leaderid(result.id_) then
              ten = 'Chief'
              tfa = 'مدیر کل'
            elseif is_sudoid(result.id_) then
              ten = 'Sudo'
              tfa = 'مدیر ربات'
            elseif is_admin(result.id_) then
              ten = 'Bot Admin'
              tfa = 'ادمین ربات'
            elseif is_owner(result.id_, msg.chat_id_) then
              ten = 'Owner'
              tfa = 'صاحب گروه'
            elseif is_momod(result.id_, msg.chat_id_) then
              ten = '*Group Admin*'
              tfa = 'مدیر گروه'
            else
              ten = 'Member'
              tfa = 'کاربر'
            end
            if result.username_ then
              username = '@'..result.username_
            else
              if database:get('lang:gp:'..msg.chat_id_) then
                username = 'Not Found'
              else
                username = 'یافت نشد'
              end
            end
            if result.last_name_ then
              lastname = result.last_name_
            else
              lastname = ''
            end
            if database:get('lang:gp:'..msg.chat_id_) then
              send(msg.chat_id_, msg.id_, 1, '> Your Name : '..result.first_name_..' '..lastname..'\n> Your Username : '..username..'\n> Your ID : '..result.id_..'\n> Your Rank : '..ten, 1, 'html')
            else
              send(msg.chat_id_, msg.id_, 1, '> نام شما : '..result.first_name_..' '..lastname..'\n> یوزرنیم شما : '..username..'\n> شناسه شما : '..result.id_..'\n> مقام شما : '..tfa, 1, 'html')
            end
          end
          getUser(msg.sender_user_id_,get_me)
        end
        if text:match("^اطلاعات من$") then
          function get_me(extra,result,success)
            if is_leaderid(result.id_) then
              ten = 'Chief'
              tfa = 'مدیر کل'
            elseif is_sudoid(result.id_) then
              ten = 'Sudo'
              tfa = 'مدیر ربات'
            elseif is_admin(result.id_) then
              ten = 'Bot Admin'
              tfa = 'ادمین ربات'
            elseif is_owner(result.id_, msg.chat_id_) then
              ten = 'Owner'
              tfa = 'صاحب گروه'
            elseif is_momod(result.id_, msg.chat_id_) then
              ten = '*Group Admin*'
              tfa = 'مدیر گروه'
            else
              ten = 'Member'
              tfa = 'کاربر'
            end
            if result.username_ then
              username = '@'..result.username_
            else
              if database:get('lang:gp:'..msg.chat_id_) then
                username = 'Not Found'
              else
                username = 'یافت نشد'
              end
            end
            if database:get('lang:gp:'..msg.chat_id_) then
              send(msg.chat_id_, msg.id_, 1, '> Your Name : '..result.first_name_..'\n> Your Username : '..username..'\n> Your ID : '..result.id_..'\n> Your Rank : '..ten, 1, 'html')
            else
              send(msg.chat_id_, msg.id_, 1, '> نام شما : '..result.first_name_..'\n> یوزرنیم شما : '..username..'\n> شناسه شما : '..result.id_..'\n> مقام شما : '..tfa, 1, 'html')
            end
          end
          getUser(msg.sender_user_id_,get_me)
        end
        -----------------------------------------------------------------------------------------------
        if is_momod(msg.sender_user_id_, msg.chat_id_) then
          if text:match("^[!/#][Ww]hois (.*)$") then
            local memb = {string.match(text, "^([!/#][Ww]hois) (.*)$")}
            function whois(extra,result,success)
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> Name :'..result.first_name_..'\n> Username : @'..result.username_..'\n> ID : '..msg.sender_user_id_, 1, 'html')
              else
                send(msg.chat_id_, msg.id_, 1, '> نام : '..result.first_name_..'\n> یوزرنیم : @'..result.username_..'\n> شناسه : '..msg.sender_user_id_, 1, 'html')
              end
            end
            getUser(memb[2],whois)
          end
          if text:match("^اطلاعات (.*)$") then
            local memb = {string.match(text, "^(اطلاعات) (.*)$")}
            function whois(extra,result,success)
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> Name :'..result.first_name_..'\n> Username : @'..result.username_..'\n> ID : '..msg.sender_user_id_, 1, 'html')
              else
                send(msg.chat_id_, msg.id_, 1, '> نام : '..result.first_name_..'\n> یوزرنیم : @'..result.username_..'\n> شناسه : '..msg.sender_user_id_, 1, 'html')
              end
            end
            getUser(memb[2],whois)
          end
        end
        -----------------------------------------------------------------------------------------------
        if text:match("^[!/#][Gg]view$") or text:match("^میزان بازدید$") then
          database:set('bot:viewget'..msg.sender_user_id_,true)
          if database:get('lang:gp:'..msg.chat_id_) then
            send(msg.chat_id_, msg.id_, 1, '> Plese forward your post : ', 1, 'md')
          else
            send(msg.chat_id_, msg.id_, 1, '> لطفا مطلب خود را فروراد کنید : ', 1, 'md')
          end
        end
        ---------------------------------------Help Bot------------------------------------------------
        -----------------------------------------------------------------------------------------------
        if text:match("^vasdfafawfawdfawf$") and is_sudo(msg) then
          send(msg.chat_id_, msg.id_, 1, 'https://www.payping.ir/EndlessLine', 1, 'html')
        end
      end
      -----------------------------------------------------------------------------------------------
    end
    -----------------------------------------------------------------------------------------------
    -- END CODE --
    -- Number Update 5
    -----------------------------------------------------------------------------------------------
  elseif (data.ID == "UpdateChat") then
    chat = data.chat_
    chats[chat.id_] = chat
    -----------------------------------------------------------------------------------------------
  elseif (data.ID == "UpdateMessageEdited") then
    local msg = data
    function get_msg_contact(extra, result, success)
      local text = (result.content_.text_ or result.content_.caption_)
      if result.id_ and result.content_.text_ then
        database:set('bot:editid'..result.id_,result.content_.text_)
      end
      if not is_vipmem(result.sender_user_id_, result.chat_id_) then
        check_filter_words(result, text)
        if database:get('editmsg'..msg.chat_id_) then
          local msgs = {[0] = data.message_id_}
          delete_msg(msg.chat_id_,msgs)
        end
        if text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") or text:match("[Tt].[Mm][Ee]") then
          if database:get('bot:links:mute'..result.chat_id_) then
            local msgs = {[0] = data.message_id_}
            delete_msg(msg.chat_id_,msgs)
          end
        end
        if text:match("[Hh][Tt][Tt][Pp][Ss]://") or text:match("[Hh][Tt][Tt][Pp]://") or text:match(".[Ii][Rr]") or text:match(".[Cc][Oo][Mm]") or text:match(".[Oo][Rr][Gg]") or text:match(".[Ii][Nn][Ff][Oo]") or text:match("[Ww][Ww][Ww].") or text:match(".[Tt][Kk]") or text:match("/") then
          if database:get('bot:webpage:mute'..result.chat_id_) then
            local msgs = {[0] = data.message_id_}
            delete_msg(msg.chat_id_,msgs)
          end
        end
        if text:match("@") then
          if database:get('tags:lock'..result.chat_id_) then
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
        if text:match("[A-Z]") or text:match("[a-z]") then
          if database:get('bot:english:mute'..result.chat_id_) then
            local msgs = {[0] = data.message_id_}
            delete_msg(msg.chat_id_,msgs)
          end
        end
      end
    end
    getMessage(msg.chat_id_, msg.message_id_,get_msg_contact)
    -----------------------------------------------------------------------------------------------
  elseif (data.ID == "UpdateOption" and data.name_ == "my_id") then
    tdcli_function ({ID="GetChats", offset_order_="9223372036854775807", offset_chat_id_=0, limit_=20}, dl_cb, nil)
  end
		end
  -----------------------------------------------------------------------------------------------
end
-- END VERSION 3.5
