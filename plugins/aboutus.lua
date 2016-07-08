local function do_keyboard_aboutus()
    local keyboard = {}
    keyboard.inline_keyboard = {
    	{
    		{text = 'MrBlackLife🔫 Info :)', callback_data = '!owners'},
			},
			{
			{text = '🔮Github Projects📦', callback_data = '!members'},
			},
{
    		{text = 'MrBlackLife Contact🔥🔥', callback_data = '!sharemr'},
			},
			{
	    {text = 'Back', callback_data = '!home'},
	    }
    }
    return keyboard
end
local function do_keyboard_owners()
    local keyboard = {}
    keyboard.inline_keyboard = {
    	{
    		{text = 'Official Github Page', url = 'http://github.com/3pehrdev'},},
			{{text = 'Official instagram Page', url = 'http://instagram.com/mrblacklife'},},
			{{text = 'Official Telegram Acc', url = 'http://telegram.me/MrBlackLife'},},
			{{text = 'Official Bl Channel', url = 'http://telegram.me/BlackLifeCh'},},
			{{text = 'Back', callback_data = '!aboutus'},
	    }
    }
    return keyboard
end
local function do_keyboard_members()
    local keyboard = {}
    keyboard.inline_keyboard = {
    	{
			{text = 'SpammerBot' , url = 'http://github.com/3pehrdev/spammer-bot'},
			{text = 'Sphero Normal Group', url = 'http://github.com/3pehrdev/Sphero'},
			},
			{
	    {text = 'Back', callback_data = '!aboutus'},
        }
    }
    return keyboard
end
local action = function(msg,blocks)
local msg_id = msg.message_id
local chat = msg.chat.id
local query = blocks[1]
    if msg.cb then
	if query == 'aboutus' then
		local keyboard = do_keyboard_aboutus()
		local text = [[_Use One ...
 About BlackLife_]]
		api.editMessageText(chat, msg_id, text, keyboard, true)
    end
	if query == 'owners' then
		local keyboard = do_keyboard_owners()
		local text = [[*BlackLife ForEver* 
*BlackLife EveryWhere . . .*]]
		api.editMessageText(chat, msg_id, text, keyboard, true)
    end
	if query == 'members' then
		local keyboard = do_keyboard_members()
		local text = [[*3pehrdev Github Projects . . .*]]
		api.editMessageText(chat, msg_id, text, keyboard, true)
    end
if query == 'sharemr' then
     api.sendContact(msg.from.id, '+989309649221', '🔸MrBlackLife loop')
end
	end
	end
return {
  action = action,
triggers = {
	    '^###cb:!(aboutus)',
	    '^###cb:!(owners)',
	    '^###cb:!(members)',
'^###cb:!(sharemr)',
    }
}
