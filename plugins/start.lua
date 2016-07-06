local function do_keyboard_robot()
    local keyboard = {}
    keyboard.inline_keyboard = {
		{
    					{text = 'Share Sphero Number', callback_data = '!share'},
    					},
    					{
    		    		{text = 'Free Groups', callback_data = '/chat'},
    		    		{text = 'Support Sphero', url = 'https://telegram.me/joinchat/C67c0D-5QEEIerZWKv1G9g'},
	    },
	    {
	    {text = 'Back to Home', callback_data = '!home'}
        }
    }
    return keyboard
end
local function do_keyboard_private()    local keyboard = {}
    keyboard.inline_keyboard = {
    	{
    		{text = 'Spheroes Dev', url = 'http://telegram.me/mrblacklife'},
},
		{
    		{text = 'کانال و اموزش - ch and training', callback_data = '!channel'},
	    },
		{
	        {text = ' پیام رسانی - Private', callback_data = '/chat'},
        },
		{
	        {text = 'درباره ما - about us', callback_data = '!aboutus'},
        },
	    {
	        {text = 'اطلاعاتی در مورد اسفرو - more information Sphero', callback_data = '!robot'},
        }
    }
    return keyboard
end

local function do_keyboard_startme()
    local keyboard = {}
    keyboard.inline_keyboard = {
    	{
    		{text = 'Click👑', url = 'https://telegram.me/'..bot.username}
	    }
    }
    return keyboard
end
local function do_keyboard_channel()
    local keyboard = {}
    keyboard.inline_keyboard = {
    	{
    		{text = 'Fa / En Channel 🇬🇧🇮🇷', url = 'https://telegram.me/spheroch'},
	    },

    },
		{
	    {text = '🔙Back to Home', callback_data = '!home'},
        }
    
    }
    return keyboard
end

local action = function(msg, blocks, ln)
    if blocks[1] == 'start' or blocks[1] == 'help' then
        db:hset('bot:users', msg.from.id, 'xx')
        db:hincrby('bot:general', 'users', 1)
        if msg.chat.type == 'private' then
            local message = [[_Hi_ *And* _Welcome _
*Please Use one by one :D*]]
            local keyboard = do_keyboard_private()
            api.sendKeyboard(msg.from.id, message, keyboard, true)
            end
			if msg.chat.type == 'group' or msg.chat.type == 'supergroup' then
          api.sendKeyboard(msg.chat.id, 'Start Me To Private For Help You :D📧' ,do_keyboard_startme(), true)
        end
        return
    end

    if msg.cb then
        local query = blocks[1]
        local msg_id = msg.message_id
        local text
        if query == 'channel' then
            local text = '*Channel And Training*'
            local keyboard = do_keyboard_channel()
        api.editMessageText(msg.chat.id, msg_id, text, keyboard, true)
end
if query == 'robot' then
            local text = [[اسفرو رباتی امن برای مدیریت گروه شما است 
که ما به صورت اینلاین کیبورد بعضی از امکانات و راه های ارتباط رو به شما معرفی کردیم
موفق باشید]]
            local keyboard = do_keyboard_robot()
        api.editMessageText(msg.chat.id, msg_id, text, keyboard, true)
end
if query == 'home' then
            local text = [[*📍Welcome Back*
*Use Cmds*]]
            local keyboard = do_keyboard_private()
        api.editMessageText(msg.chat.id, msg_id, text, keyboard, true)
end
        if query == 'share' then
     api.sendContact(msg.from.id, '+639080452513', '🔸Sphero AntiSpam ]')
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
	    '^###cb:!(channel)',
	    '^###cb:!(robot)',
	    '^###cb:!(share)',

    }
}
