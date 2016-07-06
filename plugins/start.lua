local function do_keyboard_robot()
    local keyboard = {}
    keyboard.inline_keyboard = {
		{
    					{text = 'Sphero Number(c)', callback_data = '!share'},
    					},
    					{
    		    		{text = 'Best Antispam Ch', callback_data = '!buygroup'},
text = 'FreeGroup📦🔮', callback_data = '/chat'},
    		    		{text = 'Sphero Support', url = 'https://telegram.me/joinchat/C67c0D-5QEEIerZWKv1G9g'},
	    },
	    {
	    {text = '🔙Back', callback_data = '!home'}
        }
    }
    return keyboard
end
local function do_keyboard_buygroup()
    local keyboard = {}
    keyboard.inline_keyboard = {
{
    		    		{text = 'AntiSpam Training📦', url = 'http://telegram.me/create_antispam_bot'},
    		    		{text = 'More training', url = 'https://telegram.me/spheroch'},
	    },
	    {
	    {text = '🔙Back', callback_data = '!robot'}
        }
    }
    return keyboard
end
local function do_keyboard_private()
    local keyboard = {}
    keyboard.inline_keyboard = {
    	{
    		{text = 'Bl/Sp Channel - کانال', callback_data = '!channel'},
	    },
		{
	        {text = '🔩پیام رسان - Private🔥', callback_data = '/chat'},
        },
		{
	        {text = '🔮About - درباره', callback_data = '!aboutus'},
        },
	    {
	        {text = '🔮Sphero Ab - درباره اسفرو', callback_data = '!robot'},
        }
    }
    return keyboard
end

local function do_keyboard_startme()
    local keyboard = {}
    keyboard.inline_keyboard = {
    	{
    		{text = '📥click', url = 'https://telegram.me/'..bot.username}
	    }
    }
    return keyboard
end
local function do_keyboard_channel()
    local keyboard = {}
    keyboard.inline_keyboard = {
    	{
    		{text = 'Fa/En Sp Channel 🇬🇧🇮🇷', url = 'https://telegram.me/SpheroCh'},
	    },
	{
	        		{text = 'BlackLife Channel ', url = 'https://telegram.me/BlackLifeCh'},

    },
		{
	    {text = '🔙Back', callback_data = '!home'},
        }
    
    }
    return keyboard
end

local action = function(msg, blocks, ln)
    if blocks[1] == 'start' or blocks[1] == 'help' then
        db:hset('bot:users', msg.from.id, 'xx')
        db:hincrby('bot:general', 'users', 1)
        if msg.chat.type == 'private' then
            local message = [[*📍Hi and Welcome*
_Use one_ :D]]
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
            local text = '*Sphero/Bl Channel*'
            local keyboard = do_keyboard_channel()
        api.editMessageText(msg.chat.id, msg_id, text, keyboard, true)
end
if query == 'robot' then
            local text = [[اسفرو رباتی امن برای گروه های شما است
بصورت کاملا رایگان فقط کافیست از همین بخش گزینه
freegroup
را لمس کرده و لینک گروه خود را بفرستید
دیگر امکانات ربات👇]]
            local keyboard = do_keyboard_robot()
        api.editMessageText(msg.chat.id, msg_id, text, keyboard, true)
end
if query == 'buygroup' then
            local text = [[_Best AntiSpam Channels📺_]]
            local keyboard = do_keyboard_buygroup()
        api.editMessageText(msg.chat.id, msg_id, text, keyboard, true)
end
if query == 'home' then
            local text = [[📍*Hi And Welcome*
Sphero Official 🔥
🔧Use One By One🔧]]
            local keyboard = do_keyboard_private()
        api.editMessageText(msg.chat.id, msg_id, text, keyboard, true)
end
        if query == 'share' then
     api.sendContact(msg.from.id, '+639080452513', '🔸Sphero')
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
		'^###cb:!(buygroup)',
	    '^###cb:!(channel)',
	    '^###cb:!(robot)',
	    '^###cb:!(share)',

    }
}
