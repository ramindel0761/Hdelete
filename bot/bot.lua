bot = dofile('/home/bot/data/utils.lua')
json = dofile('/home/bot/data/JSON.lua')
URL = require "socket.url"
serpent = require("serpent")
http = require "socket.http"
https = require "ssl.https"
redis = require('redis')
database = redis.connect('127.0.0.1', 6379)
BASE = '/home/bot/bot/'
day = 86400
SUDO = 123456789 --sudo id
sudo_users = {123456789,userid}
BOTS = 123456789 --bot id
bot_id = 123456789
function vardump(value)
  print(serpent.block(value, {comment=false}))
end
function dl_cb(arg, data)
 -- vardump(data)
  --vardump(arg)
end

  function is_sudo(msg)
  local var = false
  for k,v in pairs(sudo_users) do
    if msg.sender_user_id_ == v then
      var = true
    end
  end
  return var
end
 function is_admin(msg)
  local var = false
  for k,v in pairs(admins) do
    if msg.sender_user_id_ == v then
      var = true
    end
  end
  return var
end
function is_bot(msg)
  if tonumber(BOTS) == 123456789 then
    return true
    else
    return false
    end
  end
  ------------------------------------------------------------
function is_owner(msg) 
  local hash = database:sismember(SUDO..'owners:'..msg.chat_id_,msg.sender_user_id_)
if hash or is_sudo(msg) then
return true
else
return false
end
end
------------------------------------------------------------
function is_mod(msg) 
  local hash = database:sismember(SUDO..'mods:'..msg.chat_id_,msg.sender_user_id_)
if hash or is_sudo(msg) or is_owner(msg) then
return true
else
return false
end
end
------------------------------------------------------------
function is_banned(chat,user)
   local hash =  database:sismember(SUDO..'banned'..chat,user)
  if hash then
    return true
    else
    return false
    end
  end
  ------------------------------------------------------------
  function is_filter(msg, value)
  local hash = database:smembers(SUDO..'filters:'..msg.chat_id_)
  if hash then
    local names = database:smembers(SUDO..'filters:'..msg.chat_id_)
    local text = ''
    for i=1, #names do
	   if string.match(value:lower(), names[i]:lower()) and not is_mod(msg) then
	     local id = msg.id_
         local msgs = {[0] = id}
         local chat = msg.chat_id_
        delete_msg(chat,msgs)
       end
    end
  end
  end
  ------------------------------------------------------------
function is_muted(chat,user)
   local hash =  database:sismember(SUDO..'mutes'..chat,user)
  if hash then
    return true
    else
    return false
    end
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
function priv(chat,user)
  local ohash = database:sismember(SUDO..'owners:'..chat,user)
  local mhash = database:sismember(SUDO..'mods:'..chat,user)
 if tonumber(SUDO) == tonumber(user) or mhash or ohash then
   return true
    else
    return false
    end
  end
  	 -----------------------------------------------------------------------------------------------
function getInputFile(file)
local input = tostring(file)
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
function adduser(chat_id, user_id, forward_limit)
  tdcli_function ({
    ID = "AddChatMember",
    chat_id_ = chat_id,
    user_id_ = user_id,
    forward_limit_ = forward_limit or 50
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function kick(msg,chat,user)
  if tonumber(user) == tonumber(bot_id) then
    return false
    end
  if priv(chat,user) then
      bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>شما نمیتوانید دیگر مدیران را اخراج کنید!</code>', 'html')
    else
  bot.changeChatMemberStatus(chat, user, "Kicked")
    end
  end
  ------------------------------------------------------------
function ban(msg,chat,user)
  if tonumber(user) == tonumber(bot_id) then
    return false
    end
  if priv(chat,user) then
      bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>شما نمیتوانید دیگر مدیران را از گروه مسدود کنید!</code>', 'html')
    else
  bot.changeChatMemberStatus(chat, user, "Kicked")
  database:sadd(SUDO..'banned'..chat,user)
  local t = '<code>>کاربر</code> [<b>'..user..'</b>] <code>از گروه مسدود گردید.</code>'
  bot.sendMessage(msg.chat_id_, msg.id_, 1, t, 1, 'html')
  end
  end
  ------------------------------------------------------------
function mute(msg,chat,user)
    if tonumber(user) == tonumber(bot_id) then
    return false
    end
  if priv(chat,user) then
      bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>شما نمیتوانید توانایی گفتگو در گروه را از دیگر مدیران سلب کنید!</code>', 'html')
    else
  database:sadd(SUDO..'mutes'..chat,user)
  local t = '<code>>کاربر</code> [<b>'..user..'</b>] <code>به حالت سکوت کاربران افزوده گردید.</code>'
  bot.sendMessage(msg.chat_id_, msg.id_, 1, t,1, 'html')
  end
  end
  ------------------------------------------------------------
function unban(msg,chat,user)
    if tonumber(user) == tonumber(bot_id) then
    return false
    end
   database:srem(SUDO..'banned'..chat,user)
  local t = '<code>>کاربر</code> [<b>'..user..'</b>] <code>از لیست کاربران مسدود شده خارج گردید.</code>'
  bot.sendMessage(msg.chat_id_, msg.id_, 1, t,1, 'html')
  end
  ------------------------------------------------------------
function unmute(msg,chat,user)
    if tonumber(user) == tonumber(bot_id) then
    return false
    end
   database:srem(SUDO..'mutes'..chat,user)
  local t = '<code>>کاربر</code> [<b>'..user..'</b>]  <code>از حالت سکوت کاربران حذف گردید.</code>'
  bot.sendMessage(msg.chat_id_, msg.id_, 1, t,1, 'html')
  end
  ------------------------------------------------------------
 function delete_msg(chatid,mid)
  tdcli_function ({ID="DeleteMessages", chat_id_=chatid, message_ids_=mid}, dl_cb, nil)
end
------------------------------------------------------------
function user(msg,chat,text,user)
  entities = {}
  if text:match('<user>') and text:match('<user>') then
      local x = string.len(text:match('(.*)<user>'))
      local offset = x
      local y = string.len(text:match('<user>(.*)</user>'))
      local length = y
      text = text:gsub('<user>','')
      text = text:gsub('</user>','')
   table.insert(entities,{ID="MessageEntityMentionName", offset_=offset, length_=length, user_id_=user})
  end
    entities[0] = {ID='MessageEntityBold', offset_=0, length_=0}
return tdcli_function ({ID="SendMessage", chat_id_=chat, reply_to_message_id_=msg.id_, disable_notification_=0, from_background_=1, reply_markup_=nil, input_message_content_={ID="InputMessageText", text_=text, disable_web_page_preview_=1, clear_draft_=0, entities_=entities}}, dl_cb, nil)
end
------------------------------------------------------------
function settings(msg,value,lock) 
local hash = SUDO..'settings:'..msg.chat_id_..':'..value
  if value == 'file' then
      text = 'فیلتر-فایل'
   elseif value == 'keyboard' then
    text = 'فیلتر-درون.خطی(کیبرد شیشه ای)'
  elseif value == 'link' then
    text = 'قفل-ارسال لینک'
  elseif value == 'game' then
    text = 'انجام بازی های(انلاین)'
    elseif value == 'username' then
    text = 'ارسال یوزرنیم(@)'
	elseif value == 'hashtag' then
    text = 'ارسال هشتگ(#)'
   elseif value == 'pin' then
    text = 'قفل پین-کردن(پیام)'
    elseif value == 'photo' then
    text = 'فیلتر-تصاویر'
    elseif value == 'gif' then
    text = 'فیلتر-تصاویر-متحرک'
    elseif value == 'video' then
    text = 'فیلتر-ویدئو'
    elseif value == 'audio' then
    text = 'فیلتر-صدا(audio-voice)'
    elseif value == 'music' then
    text = 'فیلتر-آهنگ(MP3)'
    elseif value == 'text' then
    text = 'فیلتر-متن'
    elseif value == 'sticker' then
    text = 'ارسال-برچسب'
    elseif value == 'contact' then
    text = 'فیلتر-مخاطبین'
    elseif value == 'forward' then
    text = 'فیلتر-فوروارد'
    elseif value == 'persian' then
    text = 'فیلتر-گفتمان(فارسی)'
    elseif value == 'english' then
    text = 'فیلتر-گفتمان(انگلیسی)'
    elseif value == 'bot' then
    text = 'قفل ورود-ربات(API)'
    elseif value == 'tgservice' then
    text = 'فیلتر-پیغام-ورود،خروج افراد'
    else return false
    end
  if lock then
database:set(hash,true)
bot.sendMessage(msg.chat_id_, msg.id_, 1, '<b>*</b> <code>'..text..'</code> >  فعال شد.',1,'html')
    else
  database:del(hash)
bot.sendMessage(msg.chat_id_, msg.id_, 1, '<b>*</b> <code>'..text..'</code> >  غیرفعال شد.',1,'html')
end
end
------------------------------------------------------------
function is_lock(msg,value)
local hash = SUDO..'settings:'..msg.chat_id_..':'..value
 if database:get(hash) then
    return true 
    else
    return false
    end
  end
------------------------------------------------------------
function trigger_anti_spam(msg,type)
  if type == 'kick' then
    kick(msg,msg.chat_id_,msg.sender_user_id_)
    end
  if type == 'ban' then
    if is_banned(msg.chat_id_,msg.sender_user_id_) then else
bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>کاربر</code> [<b>'..msg.sender_user_id_..'</b>] <code>به دلیل ارسال پیام مکرر(بیش از حد مجاز) از گروه مسدود گردید و ارتباط آن با گروه قطع گردید.</code>', 1,'md')
      end
bot.changeChatMemberStatus(msg.chat_id_, msg.sender_user_id_, "Kicked")
  database:sadd(SUDO..'banned'..msg.chat_id_,msg.sender_user_id_)
  end
	if type == 'mute' then
    if is_muted(msg.chat_id_,msg.sender_user_id_) then else
bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>کاربر</code> [<b>'..msg.sender_user_id_..'</b>] <code>به دلیل ارسال پیام مکرر(بیش از حد مجاز) به حالت سکوت منتقل شد</code>\n<code>برای خارج شدن از لیست سکوت کاربران به مدیریت مراجعه کنید</code>', 1,'md')
      end
  database:sadd(SUDO..'mutes'..msg.chat_id_,msg.sender_user_id_)
	end
  end
function televardump(msg,value)
  local text = json:encode(value)
  bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 'html')
  end
------------------------------------------------------------
function run(msg,data)
   --vardump(data)
  --televardump(msg,data)

    if msg then
            database:incr(SUDO..'total:messages:'..msg.chat_id_..':'..msg.sender_user_id_)
      if msg.send_state_.ID == "MessageIsSuccessfullySent" then
      return false 
      end
      end
    if msg.chat_id_ then
      local id = tostring(msg.chat_id_)
      if id:match('-100(%d+)') then
        chat_type = 'super'
        elseif id:match('^(%d+)') then
        chat_type = 'user'
        else
        chat_type = 'group'
        end
      end
    local text = msg.content_.text_
	if text and text:match('[qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM]') then
		text = text
		end
    --------- messages type -------------------
    if msg.content_.ID == "MessageText" then
      msg_type = 'text'
    end
    if msg.content_.ID == "MessageChatAddMembers" then
      msg_type = 'add'
    end
    if msg.content_.ID == "MessageChatJoinByLink" then
      msg_type = 'join'
    end
    if msg.content_.ID == "MessagePhoto" then
      msg_type = 'photo'
      end
    -------------------------------------------
    if msg_type == 'text' and text then
      if text:match('^[/!]') then
      text = text:gsub('^[/!]','')
      end
    end
  
     if text then
      if not database:get(SUDO..'bot_id') then
         function cb(a,b,c)
         database:set(SUDO..'bot_id',b.id_)
         end
      bot.getMe(cb)
      end
    end
	 ------------------------------------------------------------
     if chat_type == 'super' then
local user_id = msg.sender_user_id_
floods = database:hget("flooding:settings:"..msg.chat_id_,"flood") or  'nil'
NUM_MSG_MAX = database:hget("flooding:settings:"..msg.chat_id_,"floodmax") or 5
TIME_CHECK = database:hget("flooding:settings:"..msg.chat_id_,"floodtime") or 5
if database:hget("flooding:settings:"..msg.chat_id_,"flood") then
if not is_mod(msg) then
	local post_count = tonumber(database:get('floodc:'..msg.sender_user_id_..':'..msg.chat_id_) or 0)
	if post_count > tonumber(database:hget("flooding:settings:"..msg.chat_id_,"floodmax") or 5) then
 local ch = msg.chat_id_
         local type = database:hget("flooding:settings:"..msg.chat_id_,"flood")
         trigger_anti_spam(msg,type)
 end
	database:setex('floodc:'..msg.sender_user_id_..':'..msg.chat_id_, tonumber(database:hget("flooding:settings:"..msg.chat_id_,"floodtime") or 3), post_count+1)
end
end
local edit_id = data.text_ or 'nil' 
    NUM_MSG_MAX = 5
    if database:hget("flooding:settings:"..msg.chat_id_,"floodmax") then
       NUM_MSG_MAX = database:hget("flooding:settings:"..msg.chat_id_,"floodmax")
      end
    if database:hget("flooding:settings:"..msg.chat_id_,"floodtime") then
		TIME_CHECK = database:hget("flooding:settings:"..msg.chat_id_,"floodtime")
      end		
	---%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--
-- save pin message id
  if msg.content_.ID == 'MessagePinMessage' then
 if is_lock(msg,'pin') and is_owner(msg) then
 database:set(SUDO..'pinned'..msg.chat_id_, msg.content_.message_id_)
  elseif not is_lock(msg,'pin') then
 database:set(SUDO..'pinned'..msg.chat_id_, msg.content_.message_id_)
 end
 end
 -- check filters
    if text and not is_mod(msg) then
     if is_filter(msg,text) then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
      end 
    end
-- check settings
    
     -- lock tgservice
      if is_lock(msg,'tgservice') then
        if msg.content_.ID == "MessageChatJoinByLink" or msg.content_.ID == "MessageChatAddMembers" or msg.content_.ID == "MessageChatDeleteMember" then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
          end
        end
    -- lock pin
    if is_owner(msg) then else
      if is_lock(msg,'pin') then
        if msg.content_.ID == 'MessagePinMessage' then
      bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>قفل پیغام پین شده فعال است</code>\n<code>شما دارای مقام نمیباشید و امکان پین کردن پیامی را ندارید</code>',1, 'html')
      bot.unpinChannelMessage(msg.chat_id_)
          local PinnedMessage = database:get(SUDO..'pinned'..msg.chat_id_)
          if PinnedMessage then
             bot.pinChannelMessage(msg.chat_id_, tonumber(PinnedMessage), 0)
            end
          end
        end
      end
      if is_mod(msg) then
        else
        -- lock link
        if is_lock(msg,'link') then
          if text then
        if msg.content_.entities_ and msg.content_.entities_[0] and msg.content_.entities_[0].ID == 'MessageEntityUrl' or msg.content_.text_.web_page_ then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
        end
            end
          if msg.content_.caption_ then
            local text = msg.content_.caption_
       local is_link = text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/") or text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]/") or text:match("[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/") or text:match("[Tt].[Mm][Ee]/")
            if is_link then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
              end
            end
        end
        -- lock username
        if is_lock(msg,'username') then
          if text then
       local is_username = text:match("@[%a%d]")
        if is_username then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
        end
            end
          if msg.content_.caption_ then
            local text = msg.content_.caption_
       local is_username = text:match("@[%a%d]")
            if is_username then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
              end
            end
        end
		-- lock hashtag
        if is_lock(msg,'hashtag') then
          if text then
       local is_hashtag = text:match("#")
        if is_hashtag then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
        end
            end
          if msg.content_.caption_ then
            local text = msg.content_.caption_
       local is_hashtag = text:match("#")
            if is_hashtag then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
              end
            end
        end
        -- lock sticker 
        if is_lock(msg,'sticker') then
          if msg.content_.ID == 'MessageSticker' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
end
          end
        -- lock forward
        if is_lock(msg,'forward') then
          if msg.forward_info_ then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
          end
          end
        -- lock photo
        if is_lock(msg,'photo') then
          if msg.content_.ID == 'MessagePhoto' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
          end
        end 
        -- lock file
        if is_lock(msg,'file') then
          if msg.content_.ID == 'MessageDocument' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
          end
        end
      -- lock file
        if is_lock(msg,'keyboard') then
          if msg.reply_markup_ and msg.reply_markup_.ID == 'ReplyMarkupInlineKeyboard' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
          end
        end 
      -- lock game
        if is_lock(msg,'game') then
          if msg.content_.game_ then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
          end
        end 
        -- lock music 
        if is_lock(msg,'music') then
          if msg.content_.ID == 'MessageAudio' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
            end
          end
        -- lock voice 
        if is_lock(msg,'audio') then
          if msg.content_.ID == 'MessageVoice' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
            end
          end
        -- lock gif
        if is_lock(msg,'gif') then
          if msg.content_.ID == 'MessageAnimation' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
            end
          end 
        -- lock contact
        if is_lock(msg,'contact') then
          if msg.content_.ID == 'MessageContact' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
            end
          end
        -- lock video 
        if is_lock(msg,'video') then
          if msg.content_.ID == 'MessageVideo' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
           end
          end
        -- lock text 
        if is_lock(msg,'text') then
          if msg.content_.ID == 'MessageText' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
            end
          end
        -- lock persian 
        if is_lock(msg,'persian') then
          if text:match('[ضصثقفغعهخحجچپشسیبلاتنمکگظطزرذدئو]') then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
            end 
         if msg.content_.caption_ then
        local text = msg.content_.caption_
       local is_persian = text:match("[ضصثقفغعهخحجچپشسیبلاتنمکگظطزرذدئو]")
            if is_persian then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
              end
            end
        end
        -- lock english 
        if is_lock(msg,'english') then
          if text:match('[qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM]') then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
            end 
         if msg.content_.caption_ then
        local text = msg.content_.caption_
       local is_english = text:match("[qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM]")
            if is_english then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
              end
            end
        end
        -- lock bot
        if is_lock(msg,'bot') then
       if msg.content_.ID == "MessageChatAddMembers" then
            if msg.content_.members_[0].type_.ID == 'UserTypeBot' then
        kick(msg,msg.chat_id_,msg.content_.members_[0].id_)
              end
            end
          end
      end

-- check mutes
      local muteall = database:get(SUDO..'muteall'..msg.chat_id_)
      if msg.sender_user_id_ and muteall and not is_mod(msg) then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
      end
      if msg.sender_user_id_ and is_muted(msg.chat_id_,msg.sender_user_id_) then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
      end
-- check bans
    if msg.sender_user_id_ and is_banned(msg.chat_id_,msg.sender_user_id_) then
      kick(msg,msg.chat_id_,msg.sender_user_id_)
      end
    if msg.content_ and msg.content_.members_ and msg.content_.members_[0] and msg.content_.members_[0].id_ and is_banned(msg.chat_id_,msg.content_.members_[0].id_) then
      kick(msg,msg.chat_id_,msg.content_.members_[0].id_)
      bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>کاربر مورد نظر مسدود نمیباشد!</code>',1, 'html')
      end
-- welcome
    local status_welcome = (database:get(SUDO..'status:welcome:'..msg.chat_id_) or 'disable') 
    if status_welcome == 'enable' then
			    if msg.content_.ID == "MessageChatJoinByLink" then
        if not is_banned(msg.chat_id_,msg.sender_user_id_) then
     function wlc(extra,result,success)
        if database:get(SUDO..'welcome:'..msg.chat_id_) then
        t = database:get(SUDO..'welcome:'..msg.chat_id_)
        else
        t = 'سلام {name}\nخوش آمدید!'
        end
      local t = t:gsub('{name}',result.first_name_)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, t,0)
          end
        bot.getUser(msg.sender_user_id_,wlc)
      end
        end
        if msg.content_.members_ and msg.content_.members_[0] and msg.content_.members_[0].type_.ID == 'UserTypeGeneral' then

    if msg.content_.ID == "MessageChatAddMembers" then
      if not is_banned(msg.chat_id_,msg.content_.members_[0].id_) then
      if database:get(SUDO..'welcome:'..msg.chat_id_) then
        t = database:get(SUDO..'welcome:'..msg.chat_id_)
        else
        t = 'سلام {name}\nخوش آمدید!'
        end
      local t = t:gsub('{name}',msg.content_.members_[0].first_name_)
         bot.sendMessage(msg.chat_id_, msg.id_, 1, t,0)
      end
        end
          end
      end
      -- locks
    if text and is_owner(msg) then
      local lock = text:match('^lock pin$')
       local unlock = text:match('^unlock pin$')
      if lock then
          settings(msg,'pin','lock')
          end
        if unlock then
          settings(msg,'pin')
        end
      end 
    if text and is_mod(msg) then
       local lock = text:match('^lock (.*)$')
       local unlock = text:match('^unlock (.*)$')
      local pin = text:match('^lock pin$') or text:match('^unlock pin$')
      if pin and is_mod(msg) then
        elseif pin and not is_mod(msg) then
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>انجام این دستور برای شما مجاز نمیباشد!</code>',1, 'html')
        elseif lock then
          settings(msg,lock,'lock')
        elseif unlock then
          settings(msg,unlock)
        end
        end
    
 -- lock flood settings
    if text and is_owner(msg) then
      if text == 'lock flood kick' then
      database:hset("flooding:settings:"..msg.chat_id_ ,"flood",'kick') 
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>قفل ارسال پیام مکرر فعال گردید!</code> \n<code>وضعیت</code> > <i>اخراج(کاربر)</i>',1, 'html')
      elseif text == 'lock flood ban' then
        database:hset("flooding:settings:"..msg.chat_id_ ,"flood",'ban') 
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>قفل ارسال پیام مکرر فعال گردید!</code> \n<code>وضعیت</code> > <i>مسدود-سازی(کاربر)</i>',1, 'html')
        elseif text == 'lock flood mute' then
        database:hset("flooding:settings:"..msg.chat_id_ ,"flood",'mute') 
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>قفل ارسال پیام مکرر فعال گردید!</code> \n<code>وضعیت</code> > <i>سکوت(کاربر)</i>',1, 'html')
        elseif text == 'unlock flood' then
        database:hdel("flooding:settings:"..msg.chat_id_ ,"flood") 
        bot.sendMessage(msg.chat_id_, msg.id_, 1, ' <code>قفل ارسال پیام مکرر غیرفعال گردید!</code> ',1, 'html')
            end
          end
       
        -- sudo
    if text then
      if is_sudo(msg) then
        if text == 'leave' then
            bot.changeChatMemberStatus(msg.chat_id_, bot_id, "Left")
			bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>ربات با موفقیت از گروه خارج گردید.</code>', 1, 'html')
          end
		  -----------------------group charge---------------
		  if text == 'charge1' then
		  local timeplan = 2592000
       database:setex("groupc:"..msg.chat_id_,timeplan,true)
	 bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>گروه با موفقیت به میزان</code> [<b>30</b>] <code>روز شارژ شد.</code>', 1, 'html')
       end
	   if text == 'charge2' then
		  local timeplan = 7776000
       database:setex("groupc:"..msg.chat_id_,timeplan,true)
	 bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>گروه با موفقیت به میزان</code> [<b>90</b>] <code>روز شارژ شد.</code>', 1, 'html')
       end
	   if text == 'charge3' then
       database:set("groupc:"..msg.chat_id_,true)
	 bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>گروه با موفقیت به میزان</code> [<b>نامحدود</b>] <code>شارژ شد.</code>', 1, 'html')
       end
	   if text and text:match('^charge (%d+)') then
          local gp = text:match('charge (%d+)')
		 local time = gp * day
		   database:setex("groupc:"..msg.chat_id_,time,true)
		   bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>گروه با موفقیت به میزان</code> ['..gp..'] <code>روز شارژ شد.</code>', 1, 'html')
    end
	   --------------------------------------------------
        if text == 'ownerset' then
          function prom_reply(extra, result, success)
        database:sadd(SUDO..'owners:'..msg.chat_id_,result.sender_user_id_)
        local user = result.sender_user_id_
         bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>کاربر</code> [<b>'..user..'</b>] <code>به لیست مالکین گروه افزوده گردید.</code>', 1, 'html')
        end
        if tonumber(tonumber(msg.reply_to_message_id_)) == 0 then
        else
           bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)
          end
        end
        if text and text:match('^ownerset (%d+)') then
          local user = text:match('ownerset (%d+)')
          database:sadd(SUDO..'owners:'..msg.chat_id_,user)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>کاربر</code> [<b>'..user..'</b>] <code>به لیست مالکین گروه افزوده گردید.</code>', 1, 'html')
      end
        if text == 'ownerdem' then
        function prom_reply(extra, result, success)
        database:srem(SUDO..'owners:'..msg.chat_id_,result.sender_user_id_)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>کاربر</code> [<b>'..result.sender_user_id_..'</b>] <code>از لیست مالکین گروه حذف گردید و توانایی مدیریت گروه از کاربر گفته شد.</code>', 1, 'html')
        end
        if tonumber(msg.reply_to_message_id_) == 0 then
        else
           bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)  
          end
        end
        if text and text:match('^ownerdem (%d+)') then
          local user = text:match('ownerdem (%d+)')
         database:srem(SUDO..'owners:'..msg.chat_id_,user)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>کاربر</code> [<b>'..user..'</b>] <code>از لیست مالکین گروه حذف گردید و توانایی مدیریت گروه از کاربر گفته شد.</code>', 1, 'html')
      end
        end
      if text == 'delete owners' or text == 'delete ownerlist' then
        database:del(SUDO..'owners:'..msg.chat_id_)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<code>>به لیست ادمین های ربات افزوده گردید.</code>', 1, 'html')
        end
	  ---############################################--
	   if text == 'reload' and is_sudo(msg) then
       dofile('bot.lua') 
 bot.sendMessage(msg.chat_id_, msg.id_, 1,'<code>>تغییرات مورد نظر شما اعمال شد.</code>', 1, 'html')
            end
	    if text == 'statsbot' and is_sudo(msg) then
    local gps = database:scard("botgp")
	local users = database:scard("usersbot")
    local allmgs = database:get("allmsg")

					bot.sendMessage(msg.chat_id_, msg.id_, 1, '>آمار ربات:\n\n`> سوپرگروه ها:` [*'..gps..'*]\n`> کاربران:` [*'..users..'*]\n`> کل پیام های دریافتی:` [*'..allmgs..'*]', 1, 'md')
	end
	  --###########################################--
      -- owner
     if is_owner(msg) then
        if text == 'delete bots' then
      local function cb(extra,result,success)
      local bots = result.members_
      for i=0 , #bots do
          kick(msg,msg.chat_id_,bots[i].user_id_)
          end
        end
       bot.channel_get_bots(msg.chat_id_,cb)
       end
          if text and text:match('^setlink (.*)') then
            local link = text:match('setlink (.*)')
            database:set(SUDO..'grouplink'..msg.chat_id_, link)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<code>>لینک جدید با موفقیت ذخیره و تغییر یافت.</code>', 1, 'html')
            end
          if text == 'remlink' then
            database:del(SUDO..'grouplink'..msg.chat_id_)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<code>>لینک تنظیم شده با موفقیت بازنشانی گردید.</code>', 1, 'html')
            end
			if text == 'remrules' then
            database:del(SUDO..'grouprules'..msg.chat_id_)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<code>>قوانین تنظیم شده گروه با موفقیت بازنشانی گردید.</code>', 1, 'html')
            end
			if text and text:match('^setrules (.*)') then
            local link = text:match('setrules (.*)')
            database:set(SUDO..'grouprules'..msg.chat_id_, link)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<code>>قوانین گروه بروزرسانی گردید.</code>', 1, 'html')
            end
            if text and text:match('^setname (.*)') then
            local name = text:match('^setname (.*)')
            bot.changeChatTitle(msg.chat_id_, name)
            end
        if text == 'welcome enable' then
          database:set(SUDO..'status:welcome:'..msg.chat_id_,'enable')
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<code>>ارسال پیام خوش آمدگویی فعال گردید.</code>', 1, 'html')
          end
        if text == 'welcome disable' then
          database:set(SUDO..'status:welcome:'..msg.chat_id_,'disable')
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<code>>ارسال پیام خوش آمدگویی غیرفعال گردید.</code>', 1, 'html')
          end
        if text and text:match('^setwelcome (.*)') then
          local welcome = text:match('^setwelcome (.*)')
          database:set(SUDO..'welcome:'..msg.chat_id_,welcome)
          local t = '<code>>پیغام خوش آمدگویی با موفقیت ذخیره و تغییر یافت.</code>\n<code>>متن پیام خوش آمدگویی تنظیم شده:</code>:\n{<code>'..welcome..'</code>}'
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
          end
        if text == 'delete welcome' then
          database:del(SUDO..'welcome:'..msg.chat_id_,welcome)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<code>>پیغام خوش آمدگویی بازنشانی گردید و به حالت پیشفرض تنظیم شد.</code>', 1, 'html')
          end
        if text == 'owners' or text == 'ownerlist' then
          local list = database:smembers(SUDO..'owners:'..msg.chat_id_)
          local t = '<code>>لیست مالکین گروه:</code> \n\n'
          for k,v in pairs(list) do
          t = t..k.." - <code>"..v.."</code>\n" 
          end
          t = t..'\nبرای مشاهده کاربر از دستور زیر استفاده کنید \n<code>/whois [آیدی کاربر]</code>\n مثال :\n <code>/whois 234458457</code>'
          if #list == 0 then
          t = '<code>>لیست مالکان گروه خالی میباشد!</code>'
          end
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
      end
    if text == 'modset' then
        function prom_reply(extra, result, success)
        database:sadd(SUDO..'mods:'..msg.chat_id_,result.sender_user_id_)
        local user = result.sender_user_id_
         bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>کاربر</code> [<b>'..user..'</b>] <code>به مقام مدیریت گروه ارتقاء یافت.</code>', 1, 'html')
        end
        if tonumber(msg.reply_to_message_id_) == 0 then
        else
           bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)  
          end
        end
        if text:match('^modset @(.*)') then
        local username = text:match('^modset @(.*)')
        function promreply(extra,result,success)
          if result.id_ then
        database:sadd(SUDO..'mods:'..msg.chat_id_,result.id_)
        text ='<code>>کاربر</code> [<code>'..result.id_..'</code>] <code>به مقام مدیریت گروه ارتقاء یافت.</code>' 
            else 
            text = '<code>کاربر مورد نظر یافت نشد</code>'
            end
           bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
          end
        bot.resolve_username(username,promreply)
        end
        if text and text:match('^modset (%d+)') then
          local user = text:match('modset (%d+)')
          database:sadd(SUDO..'mods:'..msg.chat_id_,user)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>کاربر</code> [<b>'..user..'</b>] <code>به مقام مدیریت گروه ارتقاء یافت.</code>', 1, 'html')
      end
        if text == 'moddem' then
        function prom_reply(extra, result, success)
        database:srem(SUDO..'mods:'..msg.chat_id_,result.sender_user_id_)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>کاربر</code> [<b>'..result.sender_user_id_..'</b>] <code>از مقام مدیریت گروه عزل گردید.</code>', 1, 'html')
        end
        if tonumber(msg.reply_to_message_id_) == 0 then
        else
           bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)  
          end
        end
        if text:match('^moddem @(.*)') then
        local username = text:match('^moddem @(.*)')
        function demreply(extra,result,success)
          if result.id_ then
        database:srem(SUDO..'mods:'..msg.chat_id_,result.id_)
        text = '<code>>کاربر</code> [<b>'..result.id_..'</b>] <code>از مقام مدیریت گروه عزل گردید.</code>'
            else 
            text = '<code>کاربر مورد نظر یافت نشد</code>'
            end
           bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
          end
        bot.resolve_username(username,demreply)
        end
        if text and text:match('^modset (%d+)') then
          local user = text:match('modset (%d+)')
          database:sadd(SUDO..'mods:'..msg.chat_id_,user)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>کاربر</code> [<b>'..user..'</b>] <code>به مقام مدیریت گروه ارتقاء یافت.</code>', 1, 'html')
      end
        if text and text:match('^moddem (%d+)') then
          local user = text:match('moddem (%d+)')
         database:srem(SUDO..'mods:'..msg.chat_id_,user)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>کاربر</code> [<b>'..user..'</b>] <code>از مقام مدیریت گروه عزل گردید.</code>', 1, 'html')
      end
  end
      end
	   -------------* EXPIRE *-----------------
    if not database:get("groupc:"..msg.chat_id_) and is_owner(msg) then
      local sudo = tonumber(159887854)
        bot.sendMessage(msg.chat_id_, msg.id_, 1,'شارژ گروه شما به پایان رسید.', 1, 'html')
	   bot.changeChatMemberStatus(msg.chat_id_, 341129968, "Left")
	   end
	   ----------------------------------------------------------------------------------------------- 
	if text == 'charge stats' and is_owner(msg) then
    local ex = database:ttl("groupc:"..msg.chat_id_)
       if ex == -1 then
		bot.sendMessage(msg.chat_id_, msg.id_, 1,'تاریخ انقضا برای گروه شما ثبت نشده است و مدت زمان گروه شما نامحدود میباشد', 1, 'html')
       else
        local expire = math.floor(ex / day ) + 1
			bot.sendMessage(msg.chat_id_, msg.id_, 1,"["..expire.."] روز تا پایان مدت زمان انتقضا گروه باقی مانده است.", 1, 'html') 
       end
    end
	--------------------------------
if text == 'delete blocklist' and is_owner(msg) then
    local function removeblocklist(extra, result)
      if tonumber(result.total_count_) == 0 then 
        bot.sendMessage(msg.chat_id_, msg.id_, 0,'کاربری در لیست سیاه گروه شما قرار ندارد.', 1, 'html')
      else
      local x = 0
      for x,y in pairs(result.members_) do
        x = x + 1
        bot.changeChatMemberStatus(msg.chat_id_, y.user_id_, 'Left', dl_cb, nil)
		end
	   bot.sendMessage(msg.chat_id_, msg.id_, 0,'تمامی کاربران لیست سیاه گروه شما حذف گردیدند.', 1, 'html')
    end
	end
	 bot.getChannelMembers(msg.chat_id_, 0, 'Kicked', 200, removeblocklist, {chat_id_ = msg.chat_id_, msg_id_ = msg.id_}) 
  end
  --------------------------------
  if text == 'delete deleted' and is_owner(msg) then
 local function deleteaccounts(extra, result)
    for k,v in pairs(result.members_) do 
local function cleanaccounts(extra, result)
if not result.first_name_ then
bot.changeChatMemberStatus(msg.chat_id_, result.id_, "Kicked")
end
end
bot.getUser(v.user_id_, cleanaccounts, nil)
 end 
	bot.sendMessage(msg.chat_id_, msg.id_, 0,'تمامی کاربران حذف حساب کاربری شده گروه حذف گردیدند.', 1, 'html')
  end 
  tdcli_function ({ID = "GetChannelMembers",channel_id_ = getChatId(msg.chat_id_).ID,offset_ = 0,limit_ = 1000}, deleteaccounts, nil)
  end 
  --------------------------------
-- mods
    if is_mod(msg) then
      local function getsettings(value)
        if value == 'muteall' then
        local hash = database:get(SUDO..'muteall'..msg.chat_id_)
        if hash then
         return '<code>فعال</code>'
          else
          return '<code>غیرفعال</code>'
          end
        elseif value == 'welcome' then
        local hash = database:get(SUDO..'welcome:'..msg.chat_id_)
        if hash == 'enable' then
         return '<code>فعال</code>'
          else
          return '<code>غیرفعال</code>'
          end
         elseif value == 'spam' then
        local hash = database:hget("flooding:settings:"..msg.chat_id_,"flood")
        if hash then
             if database:hget("flooding:settings:"..msg.chat_id_, "flood") == "kick" then
         return '<code>User-kick</code>'
              elseif database:hget("flooding:settings:"..msg.chat_id_,"flood") == "ban" then
              return '<code>User-ban</code>'
							elseif database:hget("flooding:settings:"..msg.chat_id_,"flood") == "mute" then
              return '<code>Mute</code>'
              end
          else
          return '<code>مجاز</code>'
          end
        elseif is_lock(msg,value) then
          return '<code>غیرمجاز</code>'
          else
          return '<code>مجاز</code>'
          end
        end
        ---------------------------------------------------
      if text == 'panel' then
          function inline(arg,data)
          tdcli_function({
        ID = "SendInlineQueryResultMessage",
        chat_id_ = msg.chat_id_,
        reply_to_message_id_ = msg.id_,
        disable_notification_ = 0,
        from_background_ = 1,
        query_id_ = data.inline_query_id_,
        result_id_ = data.results_[0].id_
      }, dl_cb, nil)
            end
          tdcli_function({
      ID = "GetInlineQueryResults",
      bot_user_id_ = 123456789,
      chat_id_ = msg.chat_id_,
      user_location_ = {
        ID = "Location",
        latitude_ = 0,
        longitude_ = 0
      },
      query_ = tostring(msg.chat_id_),
      offset_ = 0
    }, inline, nil)
       end
	  if text == 'settings' then
        local text = '><code>تنظیمات ابرگروه:</code>\n<b>------------------------</b>\n'
        ..'><code>ارسال لینک:</code> |'..getsettings('link')..'|\n'
        ..'><code>ارسال برچسب:</code> |'..getsettings('sticker')..'|\n'
		..'><code>ارسال یوزرنیم:</code> |'..getsettings('username')..'|\n'
		..'><code>ورود ربات(API):</code> |'..getsettings('bot')..'|\n'
        ..'><code>پین(پیام):</code> |'..getsettings('pin')..'|\n'
        ..'><code>گفتمان(فارسی):</code> |'..getsettings('persian')..'|\n'
        ..'><code>گفتمان(انگلیسی):</code> |'..getsettings('english')..'|\n'
        ..'><code>ارسال هرزنامه:</code> |'..getsettings('spam')..'|\n'
	    ..'><code>پیغام خوش آمدگویی:</code> |'..getsettings('welcome')..'|\n'
        ..'><code>ارسال پیام مکرر(تعداد):</code> |<b>'..NUM_MSG_MAX..'</b>|\n'
        ..'><code>ارسال پیام مکرر(زمان):</code> |<b>'..TIME_CHECK..'</b>|\n'
		..'><code>فیلترهای ابرگروه:</code>\n<b>------------------------</b>\n'
        ..'><code>فیلتر تصاویر:</code> |'..getsettings('photo')..'|\n'
        ..'><code>فیلتر ویدئو:</code> |'..getsettings('video')..'|\n'
        ..'><code>فیلتر صدا(audio-voice):</code> |'..getsettings('voice')..'|\n'
        ..'><code>فیلتر تصاویر متحرک:</code> |'..getsettings('gif')..'|\n'
        ..'><code>فیلتر آهنگ(MP3):</code> |'..getsettings('music')..'|\n'
        ..'><code>فیلتر فایل:</code> |'..getsettings('file')..'|\n'
        ..'><code>فیلتر متن:</code> |'..getsettings('text')..'|\n'
        ..'><code>فیلتر مخاطبین:</code> |'..getsettings('contact')..'|\n'
        ..'><code>فیلتر فوروارد:</code> |'..getsettings('forward')..'|\n'
        ..'><code>فیلتر بازی(inline):</code> |'..getsettings('game')..'|\n'
		..'><code>فیلتر درون خطی(کیبرد شیشه ای):</code> |'..getsettings('keyboard')..'|\n'
        ..'><code>فیلتر خدمات تلگرام:</code> |'..getsettings('tgservice')..'|\n'
        ..'><code>فیلتر گفتگوها:</code> |'..getsettings('muteall')..'|\n'
        bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, '')
       end
      if text and text:match('^setfloodmax (%d+)$') then
          database:hset("flooding:settings:"..msg.chat_id_ ,"floodmax" ,text:match('setfloodmax (.*)'))
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<code>>حداکثر پیام تشخیص ارسال پیام مکرر تنظیم شد به:</code> [<b>'..text:match('setfloodmax (.*)')..'</b>] <code>تغییر یافت.</code>', 1, 'html')
        end
        if text and text:match('^setfloodtime (%d+)$') then
          database:hset("flooding:settings:"..msg.chat_id_ ,"floodtime" ,text:match('setfloodtime (.*)'))
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<code>>حداکثر زمان تشخیص ارسال پیام مکرر تنظیم شد به:</code> [<b>'..text:match('setfloodtime (.*)')..'</b>] <code>ثانیه.</code>', 1, 'html')
        end
        if text == 'link' then
          local link = database:get(SUDO..'grouplink'..msg.chat_id_) 
          if link then
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>لینک گروه به گروه:</code> \n'..link, 1, 'html')
            else
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>لینک ورود به گروه تنظیم نشده است.</code>\n<code>ثبت لینک جدید با دستور</code>\n<b>/setlink</b> <i>link</i>\n<code>امکان پذیر است.</code>', 1, 'html')
            end
          end
		   if text == 'rules' then
          local rules = database:get(SUDO..'grouprules'..msg.chat_id_) 
          if rules then
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>قوانین ابرگروه:</code> \n'..rules, 1, 'html')
            else
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>قوانین برای گروه تنظیم نشده است.</code>', 1, 'html')
            end
          end
        if text == 'mutechat' then
          database:set(SUDO..'muteall'..msg.chat_id_,true)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>فیلتر تمامی گفتگو ها فعال گردید!</code>', 1, 'html')
          end
        if text and text:match('^mutechat (%d+)[mhs]') or text and text:match('^mutechat (%d+) [mhs]') then
          local matches = text:match('^mutechat (.*)')
          if matches:match('(%d+)h') then
          time_match = matches:match('(%d+)h')
          time = time_match * 3600
          end
          if matches:match('(%d+)s') then
          time_match = matches:match('(%d+)s')
          time = time_match
          end
          if matches:match('(%d+)m') then
          time_match = matches:match('(%d+)m')
          time = time_match * 60
          end
          local hash = SUDO..'muteall'..msg.chat_id_
          database:setex(hash, tonumber(time), true)
          bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>فیلتر تمامی گفتگو ها برای مدت زمان</code> [<b>'..time..'</b>] <code>ثانیه فعال گردید.</code>', 1, 'html')
          end
        if text == 'unmutechat' then
          database:del(SUDO..'muteall'..msg.chat_id_)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>فیلتر تمامی گفتگو ها غیرفعال گردید!</code>', 1, 'html')
          end
        if text == 'mutechat status' then
          local status = database:ttl(SUDO..'muteall'..msg.chat_id_)
          if tonumber(status) < 0 then
            t = 'زمانی برای آزاد شدن چت تعییین نشده است !'
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
            else
          t = '[<b>'..status..'</b>] <code>ثانیه دیگر تا غیرفعال شدن فیلتر تمامی گفتگو ها باقی مانده است.</code>'
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
          end
          end
    if text == 'bans' or text == 'banlist' then
          local list = database:smembers(SUDO..'banned'..msg.chat_id_)
          local t = '<code>>لیست افراد مسدود شده از گروه:</code> \n\n'
          for k,v in pairs(list) do
          t = t..k.." - <code>"..v.."</code>\n" 
          end
          t = t..'\n<code>>برای مشاهده کاربر از دستور زیر استفاده کنید </code>\n<code>/whois [آیدی کاربر]</code>\n مثال :\n <code>/whois 159887854</code>'
          if #list == 0 then
          t = '<code>>لیست افراد مسدود شده از گروه خالی میباشد.</code>'
          end
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
      end
      if text == 'delete bans' or text == 'delete banlist' then
        database:del(SUDO..'banned'..msg.chat_id_)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<code>>لیست کاربران مسدود شده از گروه با موفقیت بازنشانی گردید.</code>', 1, 'html')
        end
        if text == 'mutes' or text == 'silentlist' then
          local list = database:smembers(SUDO..'mutes'..msg.chat_id_)
          local t = '<code>لیست کاربران حالت سکوت</code> \n\n'
          for k,v in pairs(list) do
          t = t..k.." - <code>"..v.."</code>\n" 
          end
          t = t..'\n<code>>برای مشاهده کاربر از دستور زیر استفاده کنید </code> \n<code>/whois [آیدی کاربر]</code>\n مثال :\n <code>/whois 159887854</code>'
          if #list == 0 then
          t = 'لیست افراد میوت شده خالی است !'
          end
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
      end      
      if text == 'delete mutesss' or text == 'delete silentlist' then
        database:del(SUDO..'mutes'..msg.chat_id_)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<code>>لیست افراد کاربران لیست سکوت با موفقیت حذف گردید..</code>', 1, 'html')
        end
      if text == 'kick' and tonumber(msg.reply_to_message_id_) > 0 then
        function kick_by_reply(extra, result, success)
        kick(msg,msg.chat_id_,result.sender_user_id_)
          end
        bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),kick_by_reply)
        end
      if text and text:match('^kick (%d+)') then
        kick(msg,msg.chat_id_,text:match('kick (%d+)'))
        end
      if text and text:match('^kick @(.*)') then
        local username = text:match('kick @(.*)')
        function kick_username(extra,result,success)
          if result.id_ then
            kick(msg,msg.chat_id_,result.id_)
            else 
            text = '<code>کاربر مورد نظر یافت نشد!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,kick_username)
        end
        if text == 'ban' and tonumber(msg.reply_to_message_id_) > 0 then
        function banreply(extra, result, success)
        ban(msg,msg.chat_id_,result.sender_user_id_)
          end
        bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),banreply)
        end
      if text and text:match('^ban (%d+)') then
        ban(msg,msg.chat_id_,text:match('ban (%d+)'))
        end
      if text and text:match('^ban @(.*)') then
        local username = text:match('ban @(.*)')
        function banusername(extra,result,success)
          if result.id_ then
            ban(msg,msg.chat_id_,result.id_)
            else 
            text = '<code>کاربر مورد نظر یافت نشد!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,banusername)
        end
      if text == 'unban' and tonumber(msg.reply_to_message_id_) > 0 then
        function unbanreply(extra, result, success)
        unban(msg,msg.chat_id_,result.sender_user_id_)
          end
        bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),unbanreply)
        end
      if text and text:match('^unban (%d+)') then
        unban(msg,msg.chat_id_,text:match('unban (%d+)'))
        end
      if text and text:match('^unban @(.*)') then
        local username = text:match('unban @(.*)')
        function unbanusername(extra,result,success)
          if result.id_ then
            unban(msg,msg.chat_id_,result.id_)
            else 
            text = '<code>کاربر مورد نظر یافت نشد!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,unbanusername)
        end
        if text == 'silentuser' and tonumber(msg.reply_to_message_id_) > 0 then
        function mutereply(extra, result, success)
        mute(msg,msg.chat_id_,result.sender_user_id_)
          end
        bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),mutereply)
        end
      if text and text:match('^silentuser (%d+)') then
        mute(msg,msg.chat_id_,text:match('silentuser (%d+)'))
        end
      if text and text:match('^silentuser @(.*)') then
        local username = text:match('silentuser @(.*)')
        function muteusername(extra,result,success)
          if result.id_ then
            mute(msg,msg.chat_id_,result.id_)
            else 
            text = '<code>کاربر مورد نظر یافت نشد!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,muteusername)
        end
      if text == 'unsilentuser' and tonumber(msg.reply_to_message_id_) > 0 then
        function unmutereply(extra, result, success)
        unmute(msg,msg.chat_id_,result.sender_user_id_)
          end
        bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),unmutereply)
        end
      if text and text:match('^unsilentuser (%d+)') then
        unmute(msg,msg.chat_id_,text:match('unsilentuser (%d+)'))
        end
      if text and text:match('^unsilentuser @(.*)') then
        local username = text:match('unsilentuser @(.*)')
        function unmuteusername(extra,result,success)
          if result.id_ then
            unmute(msg,msg.chat_id_,result.id_)
            else 
            text = '<code>کاربر مورد نظر یافت نشد!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,unmuteusername)
        end
         if text == 'invite' and tonumber(msg.reply_to_message_id_) > 0 then
        function inv_by_reply(extra, result, success)
        bot.addChatMembers(msg.chat_id_,{[0] = result.sender_user_id_})
        end
        bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),inv_by_reply)
        end
      if text and text:match('^invite (%d+)') then
        bot.addChatMembers(msg.chat_id_,{[0] = text:match('invite (%d+)')})
        end
      if text and text:match('^invite @(.*)') then
        local username = text:match('invite @(.*)')
        function invite_username(extra,result,success)
          if result.id_ then
        bot.addChatMembers(msg.chat_id_,{[0] = result.id_})
            else 
            text = '<code>کاربر مورد نظر یافت نشد!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,invite_username)
        end
      if text and text:match('^del (%d+)$') then
        local limit = tonumber(text:match('^del (%d+)$'))
        if limit > 100 then
         bot.sendMessage(msg.chat_id_, msg.id_, 1, 'تعداد پیام وارد شده از حد مجاز (100 پیام) بیشتر است !', 1, 'html')
          else
         function cb(a,b,c)
        local msgs = b.messages_
        for i=1 , #msgs do
          delete_msg(msg.chat_id_,{[0] = b.messages_[i].id_})
        end
        end
        bot.getChatHistory(msg.chat_id_, 0, 0, limit + 1,cb)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, limit..' پیام اخیر گروه پاک شد !', 1, 'html')
        end
        end
      if tonumber(msg.reply_to_message_id_) > 0 then
    if text == "del" then
        delete_msg(msg.chat_id_,{[0] = tonumber(msg.reply_to_message_id_),msg.id_})
    end
        end
	
    if text == 'managers' or text == 'mods' then
          local list = database:smembers(SUDO..'mods:'..msg.chat_id_)
          local t = '<code>>لیست مدیران گروه:</code> \n\n'
          for k,v in pairs(list) do
          t = t..k.." - <code>"..v.."</code>\n" 
          end
          t = t..'\n<code>>برای مشاهده کاربر از دستور زیر استفاده کنید </code> \n<code>/whois [آیدی کاربر]</code>\n مثال :\n <code>/whois 159887854</code>'
          if #list == 0 then
          t = '<code>>مدیریت برای این گروه ثبت نشده است.</code>'
          end
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
      end
      if text == 'delete mods' or text == 'delete managers' then
        database:del(SUDO..'mods:'..msg.chat_id_)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<code>>لیست مدیران گروه با موفقیت بازنشانی شد</code>', 1, 'html')
        end
      if text and text:match('^filter +(.*)') then
        local w = text:match('^filter +(.*)')
         database:sadd(SUDO..'filters:'..msg.chat_id_,w)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'" '..w..' "  <code>>به لیست کلمات فیلتر شده اضاف گردید!</code>', 1, 'html')
       end
      if text and text:match('^unfilter +(.*)') then
        local w = text:match('^unfilter +(.*)')
         database:srem(SUDO..'filters:'..msg.chat_id_,w)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'" '..w..' "  <code>>از لیست کلمات فیلتر شده پاک شد!</code>', 1, 'html')
       end
      if text == 'delete filterlist' then
        database:del(SUDO..'filters:'..msg.chat_id_)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<code>>تمامی کلمات فیلتر شده با موفقیت حذف گردیدند.</code>', 1, 'html')
        end
      if text == 'admins' or text == 'adminlist' then
        local function cb(extra,result,success)
        local list = result.members_
           local t = '<code>>لیست ادمین های گروه:</code>\n\n'
          local n = 0
            for k,v in pairs(list) do
           n = (n + 1)
              t = t..n.." - "..v.user_id_.."\n"
                    end
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t..'\n<code>>برای مشاهده کاربر از دستور زیر استفاده کنید </code> \n<code>/whois [آیدی کاربر]</code>\n مثال :\n <code>/whois 159887854</code>', 1, 'html')
          end
       bot.channel_get_admins(msg.chat_id_,cb)
      end
      if text == 'filterlist' then
          local list = database:smembers(SUDO..'filters:'..msg.chat_id_)
          local t = '<code>>لیست کلمات فیلتر شده در گروه:</code> \n\n'
          for k,v in pairs(list) do
          t = t..k.." - "..v.."\n" 
          end
          if #list == 0 then
          t = '<code>>لیست کلمات فیلتر شده خالی میباشد</code>'
          end
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
      end
    local msgs = database:get(SUDO..'total:messages:'..msg.chat_id_..':'..msg.sender_user_id_)
    if msg_type == 'text' then
        if text then
      if text:match('^whois @(.*)') then
        local username = text:match('^whois @(.*)')
        function id_by_username(extra,result,success)
          if result.id_ then
            text = '<code>شناسه:</code> [<b>'..result.id_..'</b>]\n<code>تعداد پیام های ارسالی:</code> [<b>'..(database:get(SUDO..'total:messages:'..msg.chat_id_..':'..result.id_) or 0)..'</b>]'
            else 
            text = '<code>کاربر مورد نظر یافت نشد!</code>'
            end
           bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
          end
        bot.resolve_username(username,id_by_username)
        end
          if text == 'id' then
            if tonumber(msg.reply_to_message_id_) == 0 then
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>شناسه-گروه</code>: {<b>'..msg.chat_id_..'</b>}', 1, 'html')
          end
            end
			if text == 'pin' and msg.reply_to_message_id_ ~= 0 then
        local id = msg.id_
        local msgs = {[0] = id}
       pin(msg.chat_id_,msg.reply_to_message_id_,0)
	   bot.sendMessage(msg.chat_id_, msg.reply_to_message_id_, 1, "<code>>پیام مورد نظر شما پین شد.</code>", 1, 'html')
   end
			 if text == 'bot' then
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<b>BOT Online!</b>', 1, 'html')
      end
        if text and text:match('whois (%d+)') then
              local id = text:match('whois (%d+)')
            local text = 'برای مشاهده اطلاعات کاربر کلیک کنید.'
            tdcli_function ({ID="SendMessage", chat_id_=msg.chat_id_, reply_to_message_id_=msg.id_, disable_notification_=0, from_background_=1, reply_markup_=nil, input_message_content_={ID="InputMessageText", text_=text, disable_web_page_preview_=1, clear_draft_=0, entities_={[0] = {ID="MessageEntityMentionName", offset_=0, length_=36, user_id_=id}}}}, dl_cb, nil)
              end
        if text == "whois" then
        function id_by_reply(extra, result, success)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>شناسه:</code> [<b>'..result.sender_user_id_..'</b>]\n<code>تعداد پیام های ارسالی:</code> [<b>'..(database:get(SUDO..'total:messages:'..msg.chat_id_..':'..result.sender_user_id_) or 0)..'</b>]', 1, 'html')
        end
         if tonumber(msg.reply_to_message_id_) == 0 then
          else
    bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),id_by_reply)
      end
        end

          end
        end
      end
   -- member
   if text == 'ping' then
          local a = {"<code>ربات فعال و آماده کار است.</code>","<code>ربات فعال است</code>","<b>pong!</b>"}
          bot.sendMessage(msg.chat_id_, msg.id_, 1,''..a[math.random(#a)]..'', 1, 'html')
      end
	  database:incr("allmsg")
	  if msg.chat_id_ then
      local id = tostring(msg.chat_id_)
      if id:match('-100(%d+)') then
        if not database:sismember("botgp",msg.chat_id_) then  
            database:sadd("botgp",msg.chat_id_)
        end
        elseif id:match('^(%d+)') then
        if not database:sismember("usersbot",msg.chat_id_) then
            database:sadd("usersbot",msg.chat_id_)
        end
        else
        if not database:sismember("botgp",msg.chat_id_) then
            database:sadd("botgp",msg.chat_id_)
        end
     end
    end
    if text and msg_type == 'text' and not is_muted(msg.chat_id_,msg.sender_user_id_) then
       if text == "me" then
	    local msgs = database:get(SUDO..'total:messages:'..msg.chat_id_..':'..msg.sender_user_id_)
	   local function getpro(extra, result, success)
   if result.photos_[0] then
            sendPhoto(msg.chat_id_, msg.sender_user_id_, 0, 1, nil, result.photos_[0].sizes_[1].photo_.persistent_id_,'شناسه شما: '..msg.sender_user_id_..'\nتعداد پیام های ارسالی شما: '..msgs)
      else
     bot.sendMessage(msg.chat_id_, msg.id_, 1,'شناسه شما: ['..msg.sender_user_id_..']\nتعداد پیام های ارسالی شما: ['..msgs..']', 1, 'html')
   end
   end
    tdcli_function ({
    ID = "GetUserProfilePhotos",
    user_id_ = msg.sender_user_id_,
    offset_ = 0,
    limit_ = 1
  }, getpro, nil)
	end
end
end
  
  
  -- help 
  if text and text == 'help' then
    if is_sudo(msg) then
help = [[
	<code>>راهنمای مالک ربات</code>

*<b>[/#!]settings</b> --<code>دریافت تنظیمات گروه</code>
*<b>[/#!]setrules</b> --<code>تنظیم قوانین گروه</code>
*<b>[/#!]modset</b> @username|reply|user-id --<code>تنظیم مالک فرعی جدید برای گروه با یوزرنیم|ریپلی|شناسه -فرد</code>
*<b>[/#!]moddem</b> @username|reply|user-id --<code>حذف مالک فرعی از گروه با یوزرنیم|ریپلی|شناسه -فرد</code>
*<b>[/#!]ownerlist</b> --<code>دریافت لیست مدیران اصلی</code>
*<b>[/#!]managers</b> --<code>دریافت لیست مدیران فرعی گروه</code>
*<b>[/#!]setlink</b> <code>link</code> <code>{لینک-گروه} --تنظیم لینک گروه</code>
*<b>[/#!]link</b> <code>دریافت لینک گروه</code>
*<b>[/#!]kick</b> @username|reply|user-id <code>اخراج کاربر با ریپلی|یوزرنیم|شناسه</code>
<b>-------------------------------</b>
<code>>راهنمای بخش حذف ها</code>
*<b>[/#!]delete managers</b> <code>{حذف تمامی مدیران فرعی تنظیم شده برای گروه}</code>
*<b>[/#!]delete welcome</b> <code>{حذف پیغام خوش آمدگویی تنظیم شده برای گروه}</code>
*<b>[/#!]delete bots</b> <code>{حذف تمامی ربات های موجود در ابرگروه}</code>
*<b>[/#!]delete silentlist</b> <code>{حذف لیست سکوت کاربران}</code>
*<b>[/#!]delete filterlist</b> <code>{حذف لیست کلمات فیلتر شده در گروه}</code>
<b>-------------------------------</b>
<code>>راهنمای بخش خوش آمدگویی</code>
*<b>[/#!]welcome enable</b> --<code>(فعال کردن پیغام خوش آمدگویی در گروه)</code>
*<b>[/#!]welcome disable</b> --<code>(غیرفعال کردن پیغام خوش آمدگویی در گروه)</code>
*<b>[/#!]setwelcome text</b> --<code>(تنظیم پیغام خوش آمدگویی جدید در گروه)</code>
<b>-------------------------------</b>
<code>>راهنمای بخش فیلترگروه</code>
*<b>[/#!]mutechat</b> --<code>فعال کردن فیلتر تمامی گفتگو ها</code>
*<b>[/#!]unmutechat</b> --<code>غیرفعال کردن فیلتر تمامی گفتگو ها</code>
*<b>[/#!]mutechat number(h|m|s)</b> --<code>فیلتر تمامی گفتگو ها بر حسب زمان[ساعت|دقیقه|ثانیه]</code>
<b>-------------------------------</b>
<code>>راهنمای دستورات حالت سکوت کاربران</code>
*<b>[/#!]silentuser</b> @username|reply|user-id <code>--افزودن کاربر به لیست سکوت با یوزرنیم|ریپلی|شناسه -فرد</code>
*<b>[/#!]unsilentuser</b> @username|reply|user-id <code>--افزودن کاربر به لیست سکوت با یوزرنیم|ریپلی|شناسه -فرد</code>
*<b>[/#!]silentlist</b> <code>--دریافت لیست کاربران حالت سکوت</code>
<b>-------------------------------</b>
<code>>راهنمای بخش فیلتر-کلمات</code>
*<b>[/#!]filter word</b> <code>--افزودن عبارت جدید به لیست کلمات فیلتر شده</code>
*<b>[/#!]unfilter word</b> <code>--حذف عبارت جدید از لیست کلمات فیلتر شده</code>
*<b>[/#!]filterlist</b> <code>--دریافت لیست کلمات فیلتر شده</code>
<b>-------------------------------</b>
<code>>راهنمای دستورات تنظیمات ابر-گروه[فیلترها]</code>
*<b>[/#!]lock|unlock link</b> --<code>(فعال سازی/غیرفعال سازی ارسال تبلیغات)</code>
*<b>[/#!]lock|unlock username</b> --<code>(فعال سازی/غیرفعال سازی ارسال یوزرنیم)</code>
*<b>[/#!]lock|unlock hashtag</b> --<code>(فعال سازی/غیرفعال سازی ارسال هشتگ)</code>
*<b>[/#!]lock|unlock sticker</b> --<code>(فعال سازی/غیرفعال سازی ارسال برچسب)</code>
*<b>[/#!]lock|unlock contact</b> --<code>(فعال سازی/غیرفعال سازی فیتلر  مخاطبین)</code>
*<b>[/#!]lock|unlock english</b> --<code>(فعال سازی/غیرفعال سازی فیتلر  گفتمان(انگلیسی))</code>
*<b>[/#!]lock|unlock persian</b> --<code>(فعال سازی/غیرفعال سازی فیتلر  گفتمان(فارسی))</code>
*<b>[/#!]lock|unlock forward</b> --<code>(فعال سازی/غیرفعال سازی فیتلر  فوروارد)</code>
*<b>[/#!]lock|unlock photo</b> --<code>(فعال سازی/غیرفعال سازی فیتلر  تصاویر)</code>
*<b>[/#!]lock|unlock video</b> --<code>(فعال سازی/غیرفعال سازی فیلتر ویدئو)</code>
*<b>[/#!]lock|unlock gif</b> --<code>(فعال سازی/غیرفعال سازی فیلتر تصاویر-متحرک)</code>
*<b>[/#!]lock|unlock music</b> --<code>(فعال سازی/غیرفعال سازی فیلتر آهنگ(MP3))</code>
*<b>[/#!]lock|unlock audio</b> --<code>(فعال سازی/غیرفعال سازی فیلتر صدا(Voice-Audio))</code>
*<b>[/#!]lock|unlock text</b> --<code>(فعال سازی/غیرفعال سازی فیلتر متن)</code>
*<b>[/#!]lock|unlock keyboard</b> --<code>(فعال سازی/غیرفعال سازی فیتلر  درون-خطی(کیبرد شیشه))</code>
*<b>[/#!]lock|unlock tgservice</b> --<code>(فعال سازی/غیرفعال سازی فیتلر  پیام ورود-خروج افراد)</code>
*<b>[/#!]lock|unlock pin</b> --<code>(مجاز/غیرمجاز کردن پین پیام توسط عضو عادی)</code>
*<b>[/#!]lock|unlock number(h|m|s)</b> --<code>(مجاز/غیرمجاز کردن ارسال پیغام مکرر)</code>
<b>-------------------------------</b>
<code>>راهنمای بخش تنظیم پیغام مکرر</code>
*<b>[/#!]setfloodmax number</b> --<code>تنظیم حساسیت نسبت به ارسال پیام مکرر</code>
*<b>[/#!]setfloodtime</b> --<code>تنظیم حساسیت نسبت به ارسال پیام مکرر برحسب زمان</code>
<b>-------------------------------</b>
<code>>راهنمای بخش اضافه</code>
*<b>[/#!]delete blocklist</b> --<code>حذف کاربران موجود در لیست سیاه گروه</code>
*<b>[/#!]delete deleted</b> --<code>حذف کاربران حذف حساب کاربری شده گروه</code>
]]

  elseif is_owner(msg) then
    help = [[
	<code>>راهنمای مالکین گروه(اصلی-فرعی)</code>

*<b>[/#!]settings</b> --<code>دریافت تنظیمات گروه</code>
*<b>[/#!]setrules</b> --<code>تنظیم قوانین گروه</code>
*<b>[/#!]modset</b> @username|reply|user-id --<code>تنظیم مالک فرعی جدید برای گروه با یوزرنیم|ریپلی|شناسه -فرد</code>
*<b>[/#!]moddem</b> @username|reply|user-id --<code>حذف مالک فرعی از گروه با یوزرنیم|ریپلی|شناسه -فرد</code>
*<b>[/#!]ownerlist</b> --<code>دریافت لیست مدیران اصلی</code>
*<b>[/#!]managers</b> --<code>دریافت لیست مدیران فرعی گروه</code>
*<b>[/#!]setlink</b> <code>link</code> <code>{لینک-گروه} --تنظیم لینک گروه</code>
*<b>[/#!]link</b> <code>دریافت لینک گروه</code>
*<b>[/#!]kick</b> @username|reply|user-id <code>اخراج کاربر با ریپلی|یوزرنیم|شناسه</code>
<b>-------------------------------</b>
<code>>راهنمای بخش حذف ها</code>
*<b>[/#!]delete managers</b> <code>{حذف تمامی مدیران فرعی تنظیم شده برای گروه}</code>
*<b>[/#!]delete welcome</b> <code>{حذف پیغام خوش آمدگویی تنظیم شده برای گروه}</code>
*<b>[/#!]delete bots</b> <code>{حذف تمامی ربات های موجود در ابرگروه}</code>
*<b>[/#!]delete silentlist</b> <code>{حذف لیست سکوت کاربران}</code>
*<b>[/#!]delete filterlist</b> <code>{حذف لیست کلمات فیلتر شده در گروه}</code>
<b>-------------------------------</b>
<code>>راهنمای بخش خوش آمدگویی</code>
*<b>[/#!]welcome enable</b> --<code>(فعال کردن پیغام خوش آمدگویی در گروه)</code>
*<b>[/#!]welcome disable</b> --<code>(غیرفعال کردن پیغام خوش آمدگویی در گروه)</code>
*<b>[/#!]setwelcome text</b> --<code>(تنظیم پیغام خوش آمدگویی جدید در گروه)</code>
<b>-------------------------------</b>
<code>>راهنمای بخش فیلترگروه</code>
*<b>[/#!]mutechat</b> --<code>فعال کردن فیلتر تمامی گفتگو ها</code>
*<b>[/#!]unmutechat</b> --<code>غیرفعال کردن فیلتر تمامی گفتگو ها</code>
*<b>[/#!]mutechat number(h|m|s)</b> --<code>فیلتر تمامی گفتگو ها بر حسب زمان[ساعت|دقیقه|ثانیه]</code>
<b>-------------------------------</b>
<code>>راهنمای دستورات حالت سکوت کاربران</code>
*<b>[/#!]silentuser</b> @username|reply|user-id <code>--افزودن کاربر به لیست سکوت با یوزرنیم|ریپلی|شناسه -فرد</code>
*<b>[/#!]unsilentuser</b> @username|reply|user-id <code>--افزودن کاربر به لیست سکوت با یوزرنیم|ریپلی|شناسه -فرد</code>
*<b>[/#!]silentlist</b> <code>--دریافت لیست کاربران حالت سکوت</code>
<b>-------------------------------</b>
<code>>راهنمای بخش فیلتر-کلمات</code>
*<b>[/#!]filter word</b> <code>--افزودن عبارت جدید به لیست کلمات فیلتر شده</code>
*<b>[/#!]unfilter word</b> <code>--حذف عبارت جدید از لیست کلمات فیلتر شده</code>
*<b>[/#!]filterlist</b> <code>--دریافت لیست کلمات فیلتر شده</code>
<b>-------------------------------</b>
<code>>راهنمای دستورات تنظیمات ابر-گروه[فیلترها]</code>
*<b>[/#!]lock|unlock link</b> --<code>(فعال سازی/غیرفعال سازی ارسال تبلیغات)</code>
*<b>[/#!]lock|unlock username</b> --<code>(فعال سازی/غیرفعال سازی ارسال یوزرنیم)</code>
*<b>[/#!]lock|unlock hashtag</b> --<code>(فعال سازی/غیرفعال سازی ارسال هشتگ)</code>
*<b>[/#!]lock|unlock sticker</b> --<code>(فعال سازی/غیرفعال سازی ارسال برچسب)</code>
*<b>[/#!]lock|unlock contact</b> --<code>(فعال سازی/غیرفعال سازی فیتلر  مخاطبین)</code>
*<b>[/#!]lock|unlock english</b> --<code>(فعال سازی/غیرفعال سازی فیتلر  گفتمان(انگلیسی))</code>
*<b>[/#!]lock|unlock persian</b> --<code>(فعال سازی/غیرفعال سازی فیتلر  گفتمان(فارسی))</code>
*<b>[/#!]lock|unlock forward</b> --<code>(فعال سازی/غیرفعال سازی فیتلر  فوروارد)</code>
*<b>[/#!]lock|unlock photo</b> --<code>(فعال سازی/غیرفعال سازی فیتلر  تصاویر)</code>
*<b>[/#!]lock|unlock video</b> --<code>(فعال سازی/غیرفعال سازی فیلتر ویدئو)</code>
*<b>[/#!]lock|unlock gif</b> --<code>(فعال سازی/غیرفعال سازی فیلتر تصاویر-متحرک)</code>
*<b>[/#!]lock|unlock music</b> --<code>(فعال سازی/غیرفعال سازی فیلتر آهنگ(MP3))</code>
*<b>[/#!]lock|unlock audio</b> --<code>(فعال سازی/غیرفعال سازی فیلتر صدا(Voice-Audio))</code>
*<b>[/#!]lock|unlock text</b> --<code>(فعال سازی/غیرفعال سازی فیلتر متن)</code>
*<b>[/#!]lock|unlock keyboard</b> --<code>(فعال سازی/غیرفعال سازی فیتلر  درون-خطی(کیبرد شیشه))</code>
*<b>[/#!]lock|unlock tgservice</b> --<code>(فعال سازی/غیرفعال سازی فیتلر  پیام ورود-خروج افراد)</code>
*<b>[/#!]lock|unlock pin</b> --<code>(مجاز/غیرمجاز کردن پین پیام توسط عضو عادی)</code>
*<b>[/#!]lock|unlock number(h|m|s)</b> --<code>(مجاز/غیرمجاز کردن ارسال پیغام مکرر)</code>
<b>-------------------------------</b>
<code>>راهنمای بخش تنظیم پیغام مکرر</code>
*<b>[/#!]setfloodmax number</b> --<code>تنظیم حساسیت نسبت به ارسال پیام مکرر</code>
*<b>[/#!]setfloodtime</b> --<code>تنظیم حساسیت نسبت به ارسال پیام مکرر برحسب زمان</code>
<b>-------------------------------</b>
<code>>راهنمای بخش اضافه</code>
*<b>[/#!]delete blocklist</b> --<code>حذف کاربران موجود در لیست سیاه گروه</code>
*<b>[/#!]delete deleted</b> --<code>حذف کاربران حذف حساب کاربری شده گروه</code>
]]
   elseif is_mod(msg) then
    help = [[از متن راهنمای مالکین گروه استفاده کنید.]]
    elseif not is_mod(msg) then
    help = [[متن راهنما برای کاربران عادی ثبت نشده است.]]
    end
   bot.sendMessage(msg.chat_id_, msg.id_, 1, help, 1, 'html')
  end
  end
function tdcli_update_callback(data)
    if (data.ID == "UpdateNewMessage") then
     run(data.message_,data)
  elseif (data.ID == "UpdateMessageEdited") then
    data = data
    local function edited_cb(extra,result,success)
      run(result,data)
    end
     tdcli_function ({
      ID = "GetMessage",
      chat_id_ = data.chat_id_,
      message_id_ = data.message_id_
    }, edited_cb, nil)
  elseif (data.ID == "UpdateOption" and data.name_ == "my_id") then
    tdcli_function ({
      ID="GetChats",
      offset_order_="9223372036854775807",
      offset_chat_id_=0,
      limit_=20
    }, dl_cb, nil)
  end
end
