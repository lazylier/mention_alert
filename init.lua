local storage = core.get_mod_storage()
if storage:get_string("alert") ~= "off" then
    storage:set_string("alert", "on")
end
local colors = {on = "#55AA00", off = "#AA0000", other = "#FFFF00"}

minetest.register_chatcommand("alert_reset", {
    params = "",
    description = "Reset lists.",
    func = function()
        storage:set_string("nicknames", nil)
        storage:set_string("accept", nil)
        storage:set_string("reject", nil)
        storage:set_string("friends", nil)
    end})

minetest.register_chatcommand("alert_test", {
    params = "",
    description = "Play alert sound.",
    func = function()
        minetest.sound_play("mention_sound")
    end})
    
local function get_list(list)
    local new_table = {}
    for n in string.gmatch(storage:get_string(list), "%S+") do
        table.insert(new_table, n)
    end
    return new_table
end

local function set_list(list, names)
    local new_list = ""
    for i, n in pairs(names) do
        if i == 1 then
            new_list = new_list .. n
        else
            new_list = new_list .. " " .. n
        end
    end
    storage:set_string(list, new_list)
    if #new_list > 0 then
        print(minetest.colorize(colors["other"], "List " .. list .. " includes: " .. new_list))
    end
end

local function modify_list(list, item, prefix)
    local modified_list = get_list(list)
    if string.match(item, "^" .. prefix .. "%-%*") then
        modified_list = {}
    elseif string.match(item, "^" .. prefix .. "%+") then
        table.insert(modified_list, string.sub(item, 2 + #prefix))
    elseif string.match(item, "^" .. prefix .. "%-") then
        for i, b in pairs(modified_list) do
            if b == string.sub(item, 2 + #prefix) then
                modified_list[i] = nil
            end
        end
    end
    return modified_list
end

minetest.register_chatcommand("alert", {
    params = "[<on/off>] [+/-<name>]…",
    description = "Use on or off to enable or disable message alerts. Otherwise, alert status will be indicated.",
    func = function(params)
        local args = {}
        for a in string.gmatch(params, "%S+") do
            table.insert(args, a)
        end
        local status = args[1]
        if status == "on" or status == "off" then
            table.remove(args, 1)
            storage:set_string("alert", status)
            print(minetest.colorize(colors[status], "Alerts are now " .. status .. "."))
        end
        local nicknames = get_list("nicknames")
        local accept = get_list("accept")
        local reject = get_list("reject")
        local friends = get_list("friends")
        for _, a in pairs(args) do
            nicknames = modify_list("nicknames", a, "")
            accept = modify_list("accept", a, "a")
            reject = modify_list("reject", a, "r")
            friends = modify_list("friends", a, "f")
        end
        set_list("nicknames", nicknames)
        set_list("accept", accept)
        set_list("reject", reject)
        set_list("friends", friends)
    end})
    
local function match_list(list, message)
    for _, a in pairs(list) do
        if string.match(message, "[^%w%-_]"..a.."[^%w%-_]*") then
            return true
        end
    end
    return false
end

local function match_name(name, message)
    local from = string.match(message, "^<([%w%-_]+)>")
    local me = string.match(message, "^%*%s([%w%-_]+)")
    local sender = name
    local acceptable = match_list(get_list("accept"), message)
    local rejectable = match_list(get_list("reject"), message)
    
    if from then
        sender = from
    elseif me then
        sender = me
    end 
    local valid = ((sender ~= name) or acceptable) and not rejectable
    if valid and string.match(message, name) then
        return true
    elseif valid and match_list(get_list("nicknames"), message) then
        return true
    elseif string.match(message, "^PM from") then
        return true
    elseif match_list(get_list("friends"), message) and string.match(message, "^%*%*%*%s[%w%-_]+%sjoined%sthe%sgame") then
        return true
    else
        return false
    end
end

minetest.register_on_receiving_chat_message(function(message)
    if minetest.localplayer and storage:get_string("alert") == "on" then
        local name = minetest.localplayer:get_name()
        if match_name(name, minetest.strip_colors(message)) then
            minetest.sound_play("mention_sound")
        end
    end
end)
