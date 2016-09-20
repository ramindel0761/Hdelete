local function make_menu()
local rw1_texts = {'teSt version'}
local rows ={kmakerow(rw1_texts)}
return kmake(rows)
end
if blocks[1] == 'ver' then
local text_start = "*ver 1.2*"
api.sendMessage(msg.chat.id,text_start, true, true, nil, true, make_menu())
end


return {
	action = action,
	triggers = {
	    '^/(ver)$',
    }
}
