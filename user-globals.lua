-------------------------------------------------------------------------------------------------------------------
-- This is for personal globals, as opposed to library globals.
-------------------------------------------------------------------------------------------------------------------

function user_customize_idle_set(idleSet)
    if not my_mote_mappings then
        add_to_chat(123, 'Mote-Mappings.lua is broken.')
    end
    return idleSet
end
