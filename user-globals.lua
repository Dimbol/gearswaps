-- user-globals.lua
-- contains common functions for use across job files

-- sometimes windower updates Mote-Mappings.lua, which can break my code
do
    if not my_mote_mappings then
        add_to_chat(123, 'Mote-Mappings.lua is broken.')
    end
end

-- make simple objects from lists of bind commands, for easier handling
-- no error checking is done
function make_keybind_list(binds, weapon_types)
    if weapon_types then
        local ws_keybind_list = {}
        ws_keybind_list.table = binds   -- should be a table of lists, keyed by weapon_types
        ws_keybind_list.current_weapon_binds = nil
        ws_keybind_list.weapon_types = weapon_types
        function ws_keybind_list:bind(weapon_statevar)
            if weapon_statevar.value == 'None' then return end
            local needed_weapon_binds = self.weapon_types[weapon_statevar.value]
            if self.current_weapon_binds ~= needed_weapon_binds then
                for bind_cmd in self.table[needed_weapon_binds]:it() do send_command(bind_cmd) end
                self.current_weapon_binds = needed_weapon_binds
            end
        end
        function ws_keybind_list:unbind()
            if self.current_weapon_binds then
                for bind_cmd in self.table[self.current_weapon_binds]:it() do send_command(bind_cmd:gsub('^(bind [^ ]+)','un%1')) end
                self.current_weapon_binds = nil
            end
        end
        function ws_keybind_list:print(header)
            if self.current_weapon_binds then
                if header then add_to_chat(122, header) end
                for bind_cmd in self.table[self.current_weapon_binds]:it() do
                    local _, _, bind, cmd = bind_cmd:find('bind +([^ ]+) +input +(.*)')
                    add_to_chat(122, '%4s : %s':format(bind, cmd))
                end
            else
                if header then add_to_chat(122, header) end
                add_to_chat(121, 'No binds to print.')
            end
        end
        return ws_keybind_list
    else
        local keybind_list = {}
        keybind_list.list = binds
        function keybind_list:bind()   for bind_cmd in self.list:it() do send_command(bind_cmd) end end
        function keybind_list:unbind() for bind_cmd in self.list:it() do send_command(bind_cmd:gsub('^(bind [^ ]+)','un%1')) end end
        function keybind_list:print(header)
            if header then add_to_chat(122, header) end
            for bind_cmd in self.list:it() do
                local _, _, bind, cmd = bind_cmd:find('bind +([^ ]+) +input +(.*)')
                add_to_chat(122, '%4s : %s':format(bind, cmd))
            end
        end
        return keybind_list
    end
end

-- adds a chat message explaining, in limited cases, why an action was prevented
function interrupted_message(spell)
    if buffactive.Amnesia
    and S{'JobAbility','WeaponSkill','Ward','Effusion','CorsairRoll','CorsairShot'}:contains(spell.type) then
        add_to_chat(123, 'Amnesia prevents using '..spell.english)
    elseif buffactive.Silence
    and S{'Geomancy','WhiteMagic','BlackMagic','Ninjutsu','BardSong','BlueMagic','SummonerPact'}:contains(spell.type) then
        add_to_chat(123, 'Silence prevents using '..spell.english)
    elseif has_any_buff_of(S{'petrification','sleep','stun','terror'}) then
        add_to_chat(123, 'Status prevents using '..spell.english)
    elseif pet.isvalid and (spell.english:startswith('Geo-') or spell.type == 'SummonerPact') then
        add_to_chat(123, 'Existing pet prevents using '..spell.english)
    elseif spell.english == 'Arise' and state.AriseTold then
        if spell.target.isallymember and spell.target.distance < 20.5 and spell.target.hpp < 2 then
            if not (state.AriseTold.has_value and state.AriseTold.value == spell.target.name) then
                state.AriseTold:set(spell.target.name)
                send_command('input /t '..spell.target.name..' cancel rr')
            end
        end
    end
end

-- sets CombatWeapon to the first matching value by prefix and optional suffix
function weap_self_command(cmdParams, state_name)
    if #cmdParams < 2 then return end
    local prefix = cmdParams[2] or nil
    local suffix = cmdParams[3] or nil
    local weapons = L{}
    for i,v in ipairs(state[state_name]) do
        if type(v) == 'string' then weapons:append(v) end
    end

    weapons = weapons:filter(function(w) return w:startswith(prefix) end)
    if suffix then
        local weapons_with_suffix = weapons:filter(function(w) return w:endswith(suffix) end)
        if not weapons_with_suffix:empty() then weapons = weapons_with_suffix end
    end

    if weapons:empty() then
        add_to_chat(123, 'no matching weapon for '..prefix..''..(suffix and '..'..suffix or ''))
    else
        handle_set({state_name, weapons[1]})
    end
end

-- create new sets or tweak existing ones on the fly
function save_self_command(cmdParams)
    if cmdParams[2] then
        local set_name = cmdParams:slice(2):concat(' ')
        local key_list = gearswap.parse_set_to_keys(set_name)
        local set_parent = gearswap.get_set_from_keys(key_list:slice(1,-2)) or (key_list:length() == 1 and sets or nil)

        if set_parent then
            if not set_parent[key_list:last()] then set_parent[key_list:last()] = {} end
            for slot,item in pairs(player.equipment) do
                if item == 'empty' then
                    set_parent[key_list:last()][slot] = empty
                else
                    set_parent[key_list:last()][slot] = item
                end
            end
            add_to_chat(122, 'current gear saved to {%s}':format(set_name))
        else
            add_to_chat(104, 'bad set name: {%s}':format(set_name))
        end
    end
end

function report_ja_recasts(recast_ids, n)
    local all_ja_recasts = windower.ffxi.get_ability_recasts()
    local available_list = L{}
    local unavailable_list = L{}
    n = n or 6

    for ability in recast_ids:it() do
        local r = all_ja_recasts[ability.id]
        if r > 0 then
            unavailable_list:append({text="[%s](%d:%02d)":format(ability.name, math.floor(r/60), r%60), r=r})
        else
            available_list:append("[%s]":format(ability.name))
        end
    end

    if not available_list:empty() then
        add_to_chat(121, "OK: " .. available_list:concat(' '))
    end
    if not unavailable_list:empty() then
        unavailable_list:sort(function(a,b) return a.r < b.r end)
        if unavailable_list:length() <= n then
            add_to_chat(123, "XX: " .. unavailable_list:map(table.get-{'text'}):concat(' '))
        else
            add_to_chat(123, "XX: " .. unavailable_list:slice(1,n):map(table.get-{'text'}):concat(' '))
            add_to_chat(123, "XX: " .. unavailable_list:slice(n+1):map(table.get-{'text'}):concat(' '))
        end
    end
end

-- returns a set containing an appropriate belt for magic damage
-- example usage: equip(resolve_ele_belt(spell, sets.ele_obi, sets.nuke_belt, 3))
function resolve_ele_belt(spell, obi, alt_belt, alt_threshold)
    local belts = L{}
    if spell.target.type == 'MONSTER' then
        if player.wardrobe3["Orpheus's Sash"] or player.wardrobe4["Orpheus's Sash"] or player.wardrobe["Orpheus's Sash"]
        or player.wardrobe2["Orpheus's Sash"] or player.inventory["Orpheus's Sash"] then
            local orph_mag = math.min(math.max(1, math.floor(15 + 2 - spell.target.distance)), 15)
            belts:append({belt={waist="Orpheus's Sash"}, mag=orph_mag})
        end
    end

    if type(obi) == 'table' then
        local day_weather_mag = 0
        if     spell.element == world.day_element then
            day_weather_mag = day_weather_mag + 10
        elseif spell.element == elements.weak_to[world.day_element] then
            day_weather_mag = day_weather_mag - 10
        end
        if     spell.element == world.weather_element then
            day_weather_mag = day_weather_mag + (get_weather_intensity() == 2 and 25 or 10)
        elseif spell.element == elements.weak_to[world.weather_element] then
            day_weather_mag = day_weather_mag - (get_weather_intensity() == 2 and 25 or 10)
        end
        belts:append({belt=obi, mag=day_weather_mag})
    end

    if type(alt_belt) == 'table' and type(alt_threshold) == 'number' then
        belts:append({belt=alt_belt, mag=alt_threshold})
    end

    belts:sort(function(a,b) return a.mag > b.mag end)
    return belts[1].belt
end

-- call from job_auto_change_target to use
function custom_auto_change_target(spell, action, spellMap, eventArgs)
    if spell.target.raw == '<stpc>' then
        -- only use <stpc> while engaged and for Entrust or Pianissimo
        if spell.type == 'Geomancy' then
            if state.Buff.Entrust then
                if player.target and player.target.isallymember then
                    if player.target.type == 'PLAYER'
                    or player.target.type == 'NPC' and npcs.Trust:contains(player.target.name) then
                        change_target('<t>')
                        eventArgs.handled = true
                    end
                end
            else
                change_target('<me>')
                eventArgs.handled = true
            end
        elseif spell.type == 'BardSong' then
            if state.Buff.Pianissimo then
                if player.target and player.target.isallymember then
                    if player.target.type == 'PLAYER'
                    or player.target.type == 'NPC' and npcs.Trust:contains(player.target.name) then
                        change_target('<t>')
                        eventArgs.handled = true
                    elseif player.target.type == 'SELF' then
                        change_target('<me>')
                        eventArgs.handled = true
                    end
                end
            else
                change_target('<me>')
                eventArgs.handled = true
            end
        elseif player.status ~= 'Engaged' then
            if spell.target.type == 'MONSTER' then
                change_target('<me>')
                eventArgs.handled = true
            else
                change_target('<t>')
                eventArgs.handled = true
            end
        end
    elseif spell.target.raw == '<stnpc>' and player.status ~= 'Engaged' then
        if 'MONSTER' == player.target.type
        or 'PLAYER'  == player.target.type and windower.ffxi.get_mob_by_index(player.target.index).charmed then
            change_target('<t>')
            eventArgs.handled = true
        end
    elseif spell.target.raw == '<t>' and spell.targets.Enemy and player.target.type ~= 'MONSTER' then
        if not player.target.name
        or 'SELF'   == player.target.type
        or 'PLAYER' == player.target.type and not windower.ffxi.get_mob_by_index(player.target.index).charmed
        or 'NPC'    == player.target.type and (npcs.Trust:contains(player.target.name) or player.target.name == 'Luopan') then
            if not spellMap or not spellMap:startswith('Cure') then
                -- Change enfeebles and such to fall back to <bt> when watching a player.
                change_target('<bt>')
                eventArgs.handled = true
            end
        elseif 'NPC' == player.target.type then
            add_to_chat(122,'Is this a trust? ['..player.target.name..']')
        end
    --elseif spell.target.raw == ('<t>') and spell.english == 'Goddess\'s Hymnus' then TODO re-test pian hymnus
    --    -- Hymnus seems to not target correctly under pianissimo, unlike other songs.
    --    if not (player.target and player.target.name and state.Buff.Pianissimo and 'PLAYER' == player.target.type) then
    --        change_target('<me>')
    --        eventArgs.handled = true
    --    end
    end
end
