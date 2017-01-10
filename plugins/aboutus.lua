local function do_keyboard_aboutus()
    local keyboard = {}
    keyboard.inline_keyboard = {
    	{
    		{text = 'اکانت های MrBlackLife', callback_data = '!accounts'},
			},
			{
			{text = '🔮اطلاعات شخصی MrBlackLife📦', callback_data = '!about'},
			},
			{
	    {text = 'Back - بازگشت', callback_data = '!home'},
	    }
    }
    return keyboard
end
local function do_keyboard_accounts()
    local keyboard = {}
    keyboard.inline_keyboard = {
    	{
    		{text = 'صفحه گیتهاب اختصاصی', url = 'http://github.com/3pehrdev'},},
			{{text = 'صفحه اینستاگرام اصلی', url = 'http://instagram.com/mrblacklife'},},
			{{text = 'اکانت اصلی تلگرام', url = 'http://telegram.me/MrBlackLife'},},
			{{text = 'کانال تیم من', url = 'http://telegram.me/BlackLife_TM'},},
			{{text = 'بازگشت', callback_data = '!aboutus'},
	    }
    }
    return keyboard
end
local function do_keyboard_about()
    local keyboard = {}
    keyboard.inline_keyboard = {
    	{
	    {text = 'بازگشت', callback_data = '!aboutus'},
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
		local text = [[خوش اومدید اینجا میتونید اطلاعاتی در مورد
			@MrBlackLife
			بدست بیارید و اونو بیشتر بشناسید]]
		api.editMessageText(chat, msg_id, text, keyboard, true)
    end
	if query == 'accounts' then
		local keyboard = do_keyboard_accounts()
		local text = [[اکانت های شخصی من]]
		api.editMessageText(chat, msg_id, text, keyboard, true)
    end
	if query == 'about' then
		local keyboard = do_keyboard_about()
		local text = [[سپهر صالحی 21 ساله از اهواز
			تحصیل در رشته حقوق
			علاقه مند به برنامه نویسی
			شماره : 09309649221
			ایدی تلگرام : @MrBlackLife]]
		api.editMessageText(chat, msg_id, text, keyboard, true)
    end
	end
	end
return {
  action = action,
triggers = {
	    '^###cb:!(aboutus)',
	    '^###cb:!(accounts)',
	    '^###cb:!(about)',
    }
}
