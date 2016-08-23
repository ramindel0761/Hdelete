local function do_keyboard_robot()
    local keyboard = {}
    keyboard.inline_keyboard = {
		{
    					{text = 'شماره ربات برای ادمینی', callback_data = '!share'},
    					},
    					{
    		    		{text = 'چند کانال خوب', callback_data = '!buygroup'},
},
    					{
{text = 'تمدید گروه📦🔮', callback_data = '/chat'},
},
    					{
    		    		{text = 'گروه پشتیبانی', url = 'https://telegram.me/joinchat/C67c0D-5QEEgslXuJEeg2w'},
	    },
	    {
	    {text = '🔙بازگشت به منوی اصلی', callback_data = '!home'}
        }
    }
    return keyboard
end
local function do_keyboard_antisch()
    local keyboard = {}
    keyboard.inline_keyboard = {
{
    		    		{text = 'اموزش های انتی اسپم📦', url = 'http://telegram.me/create_antispam_bot'},
    		    		{text = 'اموزش های بیشتر', url = 'https://telegram.me/spheroch'},
	    },
	    {
	    {text = '🔙بازگشت', callback_data = '!robot'}
       
    }
    return keyboard
end
local function do_keyboard_private()
    local keyboard = {}
    keyboard.inline_keyboard = {
    	{
    		{text = '📍Channels - کانال ها📍', callback_data = '!channel'},
	    },
		{
	        {text = '📍پیام رسان - @MrBlackLife📍', callback_data = '/chat'},
        },
		{
	        {text = '📍we About - درباره ما📍', callback_data = '!aboutus'},
        },
	    {
	        {text = '📍امور ربات اسفرو📍', callback_data = '!robot'},
        }
    }
    return keyboard
end

local function do_keyboard_startme()
    local keyboard = {}
    keyboard.inline_keyboard = {
    	{
    		{text = '📥click For Start Me', url = 'https://telegram.me/'..bot.username}
	    }
    }
    return keyboard
end
local function do_keyboard_channel()
    local keyboard = {}
    keyboard.inline_keyboard = {
    	{
    		{text = 'Fa/En Sphero Channel 🇬🇧🇮🇷', url = 'https://telegram.me/SpheroCh'},
	    },
	{
	        		{text = 'BlackLife Channel ', url = 'https://telegram.me/BlackLifeCh'},

    },
		{
	    {text = '🔙بازگشت به منوی اصلی', callback_data = '!home'},
        }
    
    }
    return keyboard
end

local action = function(msg, blocks, ln)
    if blocks[1] == 'start' or blocks[1] == 'help' then
        db:hset('bot:users', msg.from.id, 'xx')
        db:hincrby('bot:general', 'users', 1)
        if msg.chat.type == 'private' then
            local message = [[*📍Hi and Welcome*📍
*Can i Help You??👇👇*]]
            local keyboard = do_keyboard_private()
            api.sendKeyboard(msg.from.id, message, keyboard, true)
            end
			if msg.chat.type == 'group' or msg.chat.type == 'supergroup' then
          api.sendKeyboard(msg.chat.id, '_Hi _*Send Me Start To Private Message*' ,do_keyboard_startme(), true)
        end
        return
    end

    if msg.cb then
        local query = blocks[1]
        local msg_id = msg.message_id
        local text
        if query == 'channel' then
            local text = '📍*Sphero And BlackLife Channel📍*'
            local keyboard = do_keyboard_channel()
        api.editMessageText(msg.chat.id, msg_id, text, keyboard, true)
end
if query == 'robot' then
            local text = [[اسفرو رباتی امن برای گروه های شما است
خدمات ۷ روز اول کاملا رایگان
تمدید فقط با پنج هزار تومن ب صورت دائمی!!!!
تمدید گپ و دیگر امکانات👇]]
            local keyboard = do_keyboard_robot()
        api.editMessageText(msg.chat.id, msg_id, text, keyboard, true)
end
if query == 'antisch' then
            local text = [[📌_BeSt Training and Antispam Channel📍_]]
            local keyboard = do_keyboard_buygroup()
        api.editMessageText(msg.chat.id, msg_id, text, keyboard, true)
end
if query == 'home' then
            local text = [[📍Welcome back📍
📌Use One🔥
@SpheroCh]]
            local keyboard = do_keyboard_private()
        api.editMessageText(msg.chat.id, msg_id, text, keyboard, true)
end
        if query == 'share' then
     api.sendContact(msg.from.id, '+639080452513', '📍Sphero')
end
    end

end

return {
	action = action,
	triggers = {
	    '^/(start)@Sphero_Bot$',
	    '^/(start)$',
	    '^/(help)$',
	    '^###cb:!(home)',
		'^###cb:!(antisch)',
	    '^###cb:!(channel)',
	    '^###cb:!(robot)',
	    '^###cb:!(share)',

    }
}
