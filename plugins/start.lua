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
    		    		{text = 'گروه پشتیبانی', url = 'https://telegram.me/joinchat/D_AGYD6x5zITTyGy0Y2xuQ'},
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
    }
    return keyboard
end
local function do_keyboard_shop()
    local keyboard = {}
    keyboard.inline_keyboard = {
{
	    {text = '🔙بازگشت', callback_data = '!home'},
 }      
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
        },
		{
	        {text = '📍شرایط ربات ضدلینک📍', callback_data = '!shop'},
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
    		{text = 'Fa/En Sphero Channel 🇬🇧🇮🇷', url = 'https://telegram.me/Sphero_Ch'},
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
            local text = [[*sphero behtarin robot zed link baraye shoma
            khadamat 7 rooz aval kamelan rayegan 
            sharzh gp et tamom shode?
            dokme tamdid gp !*]]
            local keyboard = do_keyboard_robot()
        api.editMessageText(msg.chat.id, msg_id, text, keyboard, true)
end
if query == 'antisch' then
            local text = [[📌_BeSt Training and Antispam Channel📍_]]
            local keyboard = do_keyboard_buygroup()
        api.editMessageText(msg.chat.id, msg_id, text, keyboard, true)
end
		if query == 'shop' then
            local text = [[⚜✅ربات ضدلینک⚜✅
رباتی هست که تبلیغات و فحش های داخل گروه شمارو پاک میکنه🔰 گروه رو به دلخواه شما و به مدت زمانی که دوست دارید تعطیل میکنه تا هیچ پستی نباشه🔰 کلمه ای که میخواین رو ممنوع میکنه🔰 پیام هارو فقط با فرستادن یک دستور به تعداد دلخواه پاک میکنه🔰 و.....
‼️بسیار امکانات دیگر♻️
بعضی از امکانات:
☑️پاک کردن پیام به تعداد دلخواه
🔳ممنوع کردم یک کلمه
🔴ضد فحش
⚫️ضد لینک
🔘ضد اسپم
⚪️انتی فروارد با قابلیت تنظیم
🔵شناسایی لینک ها حتی در عکس و فایل
🔴شناسایی ادمین ها و پاک نکردن پست ها و لینک های اونها
⚫️قفل استیکر
ـــــــــــــــــــــــــــــــــــــــــــــــ ـــــــــــــــــــــــــــــــــــــــــــــــ ـــــــــــــــــــــــــــــــــــــــــــــــ ـــــــــــــــــــــــــــــــــــــــــــــــ
🅰پشتیبانی 24 ساعت انلاین با ادمینی خوش برخورد و قابل اعتماد.
قابلیت بازگشت وجه در صورت هرگونه نارضایتی و ادم انلاین بودن ربات برای 8 ساعت
ـــــــــــــــــــــــــــــــــــــــــــــــ ـــــــــــــــــــــــــــــــــــــــــــــــ ـــــــــــــــــــــــــــــــــــــــــــــــ ـــــــــــــــــــــــــــــــــــــــــــــــ
🅱با قیمتی بسیار مناسب و ناچیز همین حالا گروه خودتون رو ضد لینک کنید.
تحویل انی و نصب سریع
همراه با اموزش مخصوص برای مدیر گروه.
ـــــــــــــــــــــــــــــــــــــــــــــــ ـــــــــــــــــــــــــــــــــــــــــــــــ ـــــــــــــــــــــــــــــــــــــــــــــــ ـــــــــــــــــــــــــــــــــــــــــــــــ
اطلاعات و تعرفه ها:

🆎دوتا ربات همزمان : (کاربرد صد درصدی اگر یکی پاک نکرد ینی خطایی رخ داد اون یکی حتما پاک میکنه😊)

ماهانه 8 💠
دو ماهه 12💠
سه ماهه 15💠
دائمی 20💠

🆑یک ربات :
ماهانه 5 💠
دو ماهه 8 💠
سه ماهه 12💠
دائمی 16💠
ـــــــــــــــــــــــــــــــــــــــــــــــ ـــــــــــــــــــــــــــــــــــــــــــــــ ـــــــــــــــــــــــــــــــــــــــــــــــ ـــــــــــــــــــــــــــــــــــــــــــــــ
🅾شماره حساب و ادمین و نصاب ربات:
6221 0611 0351 8553
مجتبی صالحی بانک پارسیان 
 شارژ پذیرفته نمیشود مگر در موارد استثنا.
ایدی نصب کننده : @MrBlackLife 🆔]]
            local keyboard = do_keyboard_shop()
        api.editMessageText(msg.chat.id, msg_id, text, keyboard, true)
end
if query == 'home' then
            local text = [[📍Welcome back📍
📌Use One🔥
]]
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
	    '^/(ver)$',
	    '^###cb:!(home)',
		'^###cb:!(antisch)',
	    '^###cb:!(channel)',
	    '^###cb:!(robot)',
            '^###cb:!(shop)',
	    '^###cb:!(share)',

    }
}
