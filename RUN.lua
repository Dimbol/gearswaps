-- Modified from 'https://github.com/Kinematics/GearSwap-Jobs/blob/master/Template.lua'

-- NOTES
-- sylvie does indi-haste!
-- herculean slash closes fusion from liquefaction
-- resolution closes distortion from transfixion (eg, power slash)
-- shell5 is mdt-29
-- consider only using SIRD for aquaveil
-- changing runes after using a ward is okay
-- valiance and one for all can be cycled for strong party protection
-- arcane circle is +5/-5% vs omen bosses
-- barstone for terror? who knows
-- escha vorseals give dt-3
-- notable phalanx tiers are 416, 443, 472 and 500 enhancing skill
-- use gambit before rayke for its longer duration
-- be ready to react fast to full dispels
-- rayke halves the repeat mb damage wall
-- mdt probably helps with drains
-- use vivacious pulse often
-- liement works on breath attacks. bad breath is earth, sweet breath is dark, interference is dark
-- add items to the gear.hp table in user_setup() to prioritize swap order by hp so less max hp is lost
-- in Tank casting mode, only non-shockwave weaponskills should leave you open to damage

-- KYOU
-- odyllic at start to build hate without hassle
-- battuta for hundred fists
-- lux for curse

-- OU
-- back to healer
-- pre absorb buffs: protect, shell, crusade
-- dont use buffing JAs for hate before 95% (stick to flash/blank gaze/geist wall, foil if cancelled)
-- full dispel > battuta > shell > crusade > liement > foil > flash > cocoon > valiance > foil > flash
-- or battuta > sforzo > aquaveil > cocoon > crusade > valiance > shell
-- use sforzo if too many buffs are taken somehow
-- pre chainspell/bravado do odyllic subterfuge
-- have 2600+ hp and be ready to run at 60%
-- hate reset at 45%, have stuff ready
-- target at 30%, don't have too much hate

-- VINIPATA
-- protect/shell/battuta only (tp moves are magical in raksha stance, physical in yaksha stance)
-- use battuta if yaksha gets scary. use foil for hate, but cancel it
-- can cancel shell during yaksha
-- avoid hate moves that give buffs (valiance/liement/vallation/pflug)
-- battuta/gambit/rayke revit, repeat

-- ODIN
-- helm > ort > grim > walt > schwert > others
-- lux for fomors, tenebrae for alex and odin
-- flash odin after a death

-- ULTIMA/OMEGA
-- flash/rayke/gambit on omega
-- steps on ultima
-- valiance blm, vallation when down (in case of citadel buster)
-- herculean slash omega as needed
-- battuta for mighty strikes 89, 79, 69, ...
-- single target full hate reset at 50% (each)
-- switch targets to omega below 30% to avoid citadel busters

-- AMBUSCADE (headless horseman)
-- pull with foil, engage, valiance, battuta, positioning,
-- tenebrae runes for scintilating lance, try to not get caught
-- died? crusade, lux liement/valiance, flash/foil/jettatura,
-- battuta, cocoon, phalanx, aquaveil, refresh, regen
-- turn for boiling while weakened
-- use one for all more

-- LILITH
-- prepull lux valiance
-- wear knockback resist +6 if possible
-- buff with embolden phalanx, stoneskin and one for all
-- thunder gambit first form
-- ice rayke second form
-- ambuscade hate rules, so foil if an add pops
-- try to tag with treasure hunter

-- /BLU SPELLSET
-- jettatura, geist wall, blank gaze,
-- sheep song, cocoon, frightful roar,
-- healing breeze, wild carrot, refueling
-- pollen, wild oats, power attack
-- mandibular bite, sprout smack

texts = require('texts')

-------------------------------------------------------------------------------------------------------------------
-- Setup functions for this job.  Generally should not be modified.
-------------------------------------------------------------------------------------------------------------------

-- Initialization function for this job file.
function get_sets()
    mote_include_version = 2

    -- Load and initialize the include file.
    include('Mote-Include.lua')
end

-- Setup vars that are user-independent.  state.Buff vars initialized here will automatically be tracked.
function job_setup()
    enable('range','ammo','head','neck','ear1','ear2','body','hands','ring1','ring2','back','waist','legs','feet')
    disable('main','sub')
    state.Buff.Valiance = buffactive.Valiance or false
    state.Buff.Vallation = buffactive.Vallation or false
    state.Buff.Liement = buffactive.Liement or false
    state.Buff.Embolden = buffactive.Embolden or false
    state.Buff.Battuta = buffactive.Battuta or false
    state.Buff['Light Arts']      = buffactive['Light Arts'] or false
    state.Buff['Addendum: White'] = buffactive['Addendum: White'] or false
    state.Buff['Dark Arts']       = buffactive['Dark Arts'] or false
    state.Buff['Addendum: Black'] = buffactive['Addendum: Black'] or false
    state.Buff.sleep = buffactive.sleep or false
    state.Buff.doom  = buffactive.doom or false

    logout_event_id = windower.raw_register_event('logout', destroy_state_text)
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
    state.OffenseMode:options('Normal','None')              -- Cycle with F9, set with !w, !@w
    state.HybridMode:options('Normal','PDef','PDef2')       -- Cycle with ^space
    state.WeaponskillMode:options('Tank','Normal')          -- Cycle with @F9
    state.CastingMode:options('Tank','MAcc')                -- Cycle with F10, reset with !F10, set with ^c, !@c
    state.IdleMode:options('Normal','Refresh','Kite')       -- Cycle with F11, reset with !F11
    state.PhysicalDefenseMode:options('Parry','VParry','Eva','Kite') -- Cycle with !z, reset with !@z
    state.MagicalDefenseMode:options('MEVA','MDT','MDB')    -- Cycle with @z
    state.StatusDefenseMode = M{['description']='Status Defense Mode'}
    state.StatusDefenseMode:options('None','Knockback','Charm','Death','Stun')  -- Set with !7..!-
    state.CombatWeapon = M{['description']='Combat Weapon'}
    if S{'DNC','NIN'}:contains(player.sub_job) then
        state.CombatWeapon:options('Epeo','Lionheart','GreatAxe','Hepatizon','SwordDW','AxeDW')
    else
        state.CombatWeapon:options('Epeo','Lionheart','GreatAxe','Hepatizon','Sword','Axe')
    end
    state.HybridMode:set('PDef')
    state.DefenseMode:set('Physical')

    state.WSMsg = M(false, 'WS Message')                        -- Toggle with ^\ (also chat for JAs)
    state.SIRD  = M(false, 'SIRD Casting')                      -- Toggle with !c
    state.TParry = M(false, 'Tactical Parry')                   -- Toggle with ~^z
    state.LowEnmRG = M(false, 'Low Enmity R/G')
    init_state_text()
    hud_update_on_state_change()

    info.sird_spells = S{'Aquaveil','Crusade','Foil',
        'Cocoon','Healing Breeze','Wild Carrot','Sheep Song','Frightful Roar','Geist Wall'}

    -- Augmented items get variables for convenience and specificity
    gear.TPCape    = {name="Ogma's cape", augments={'DEX+20','Accuracy+20 Attack+20','"Dbl.Atk."+10'}}
    gear.ResoCape  = {name="Ogma's cape", augments={'STR+20','Accuracy+20 Attack+20','"Dbl.Atk."+10'}}
    gear.DimiCape  = {name="Ogma's cape", augments={'DEX+20','Accuracy+20 Attack+20','Weapon skill damage +10%'}}
    gear.MEVACape  = {name="Ogma's cape", augments={'HP+60','Enmity+10','Phys. dmg. taken-10%'}, priority=60}
    gear.IntCape   = {name="Ogma's cape", augments={'INT+20','INT+10'}}
    gear.ParryCape = {name="Ogma's cape", augments={'HP+60','Enmity+10','Parrying rate+5%'}, priority=60}
    gear.FCCape    = {name="Ogma's cape", augments={'HP+60','HP+20','"Fast Cast"+10'}, priority=80}
    gear.taeon_head_phlx  = {name="Taeon Chapeau", augments={'Phalanx +3'}}
    gear.taeon_body_phlx  = {name="Taeon Tabard", augments={'Phalanx +3'}}
    gear.taeon_hands_phlx = {name="Taeon Gloves", augments={'Phalanx +3'}}
    gear.taeon_legs_phlx  = {name="Taeon Tights", augments={'Phalanx +3'}}
    gear.taeon_feet_phlx  = {name="Taeon Boots", augments={'Phalanx +3'}}
    gear.adh_body_ta = {name="Adhemar Jacket +1", augments={'Accuracy+20'}, priority=63}
    gear.adh_body_fc = {name="Adhemar Jacket +1", augments={'"Fast Cast"+10'}, priority=168}
    gear.herc_feet_ta  = {name="Herculean Boots", augments={'"Triple Atk."+4'}}
    gear.herc_hands_rf = {name="Herculean Gloves", augments={'"Refresh"+2'}}
    gear.herc_legs_rf  = {name="Herculean Trousers", augments={'"Refresh"+2'}}
    gear.herc_legs_th  = {name="Herculean Trousers", augments={'"Treasure Hunter"+2'}}
    gear.herc_body_phlx  = {name="Herculean Vest", augments={'Phalanx +5'}}
    gear.herc_hands_phlx = {name="Herculean Gloves", augments={'Phalanx +5'}}
    gear.herc_legs_phlx  = {name="Herculean Trousers", augments={'Phalanx +4'}}
    gear.herc_feet_phlx  = {name="Herculean Boots", augments={'Phalanx +5'}}
    gear.Lstikini = {name="Stikini Ring +1", bag="wardrobe2"}
    gear.Rstikini = {name="Stikini Ring +1", bag="wardrobe3"}

    -- High HP items get tagged with priorities
    gear.hp = {}
    gear.hp["Epeolatry"] = 900
    gear.hp["Lionheart"] = 900
    gear.hp["Hepatizon Axe +1"] = 900
    gear.hp["Lycurgos"] = 900
    gear.hp["Aqreqaq Bomblet"] = 20
    gear.hp["Ashera Harness"] = 182
    gear.hp["Balarama Grip"] = 50
    gear.hp["Bathy Choker +1"] = 35
    gear.hp["Carmine Cuisses +1"] = 130
    gear.hp["Carmine Greaves +1"] = 95
    gear.hp["Cryptic Earring"] = 40
    gear.hp["Eabani Earring"] = 45
    gear.hp["Eihwaz Ring"] = 70
    gear.hp["Emet Harness +1"] = 61
    gear.hp["Erilaz Galea +2"] = 101
    gear.hp["Erilaz Gauntlets +2"] = 49
    gear.hp["Erilaz Greaves +2"] = 38
    gear.hp["Erilaz Leg Guards +2"] = 90
    gear.hp["Erilaz Surcoat +2"] = 133
    gear.hp["Etana Ring"] = 60
    gear.hp["Ethereal Earring"] = 15
    gear.hp["Etiolation Earring"] = 50
    gear.hp["Futhark Bandeau +3"] = 56
    gear.hp["Futhark Boots +3"] = 33
    gear.hp["Futhark Coat +3"] = 119
    gear.hp["Futhark Mitons +3"] = 45
    gear.hp["Futhark Torque +2"] = 60
    gear.hp["Futhark Trousers +3"] = 107
    gear.hp["Gelatinous Ring +1"] = 120
    gear.hp["Halitus Helm"] = 88
    gear.hp["Ilabrat Ring"] = 60
    gear.hp["Kasiri Belt"] = 30
    gear.hp["Moonbeam Cape"] = 250
    gear.hp["Moonlight Ring"] = 110
    gear.hp["Null Masque"] = 100
    gear.hp["Null Loop"] = 50
    gear.hp["Nyame Helm"] = 91
    gear.hp["Nyame Mail"] = 136
    gear.hp["Nyame Gauntlets"] = 91
    gear.hp["Nyame Flanchard"] = 169
    gear.hp["Nyame Sollerets"] = 68
    gear.hp["Odnowa Earring +1"] = 110
    gear.hp["Pixie Hairpin +1"] = -35
    gear.hp["Platinum Moogle Belt"] = 300
    gear.hp["Rawhide Gloves"] = 75
    gear.hp["Regal Ring"] = 50
    gear.hp["Runeist Bandeau +3"] = 109
    gear.hp["Runeist Bottes +3"] = 74
    gear.hp["Runeist Coat +3"] = 218
    gear.hp["Runeist Mitons +3"] = 85
    gear.hp["Runeist Trousers +3"] = 80
    gear.hp["Sacro Gorget"] = 50
    gear.hp["Supershear Ring"] = 30
    gear.hp["Turms Cap +1"] = 94
    gear.hp["Turms Leggings +1"] = 76
    gear.hp["Turms Mittens +1"] = 74
    gear.hp["Unmoving Collar +1"] = 200
    gear.hp["Utu Grip"] = 70
    gear.hp["Volte Cap"] = 57
    for k, v in pairs(gear.hp) do
        gear.hp[k] = {name = k, priority = v}
    end

    gear.slots = S{'main','sub','range','ammo','head','neck','ear1','ear2','body','hands','ring1','ring2','back','waist','legs','feet'}

    function prioritize(set)
        for k, v in pairs(set) do
            if gear.slots[k] and gear.hp[v] then
                set[k] = gear.hp[v]
            end
        end
        return set
    end

    info.keybinds = make_keybind_list(job_keybinds())
    info.keybinds:bind()

    info.ws_binds = make_keybind_list(T{
        ['Great Sword']=L{
            'bind !^1|%1 input /ws "Herculean Slash"',
            'bind !^2|%2 input /ws "Resolution"',
            'bind !^3|%3 input /ws "Dimidiation"',
            'bind !^4|%4 input /ws "Ground Strike"',
            'bind !^5|%5 input /ws "Power Slash"',
            'bind !^6|%6 input /ws "Shockwave"',
            'bind ~!^1|%~1 input /ws "Herculean Slash" <stnpc>',
            'bind ~!^2|%~2 input /ws "Resolution"      <stnpc>',
            'bind ~!^3|%~3 input /ws "Dimidiation"     <stnpc>',
            'bind ~!^4|%~4 input /ws "Ground Strike"   <stnpc>',
            'bind ~!^5|%~5 input /ws "Power Slash"     <stnpc>',
            'bind ~!^6|%~6 input /ws "Shockwave"       <stnpc>'},
        ['Sword']=L{
            'bind !^1|%1 input /ws "Sanguine Blade"',
            'bind !^2|%2 input /ws "Seraph Blade"',
            'bind !^3|%3 input /ws "Savage Blade"',
            'bind !^4|%4 input /ws "Flat Blade"',
            'bind !^5|%5 input /ws "Swift Blade"',
            'bind !^6|%6 input /ws "Circle Blade"',
            'bind ~!^1|%~1 input /ws "Sanguine Blade" <stnpc>',
            'bind ~!^2|%~2 input /ws "Seraph Blade"   <stnpc>',
            'bind ~!^3|%~3 input /ws "Savage Blade"   <stnpc>',
            'bind ~!^4|%~4 input /ws "Flat Blade"     <stnpc>',
            'bind ~!^5|%~5 input /ws "Swift Blade"    <stnpc>',
            'bind ~!^6|%~6 input /ws "Circle Blade"   <stnpc>'},
        ['Great Axe']=L{
            'bind !^1|%1 input /ws "Armor Break"',
            'bind !^2|%2 input /ws "Upheaval"',
            'bind !^3|%3 input /ws "Steel Cyclone"',
            'bind !^4|%4 input /ws "Weapon Break"',
            'bind !^5|%5 input /ws "Shield Break"',
            'bind !^6|%6 input /ws "Fell Cleave"',
            'bind ~!^1|%~1 input /ws "Armor Break"   <stnpc>',
            'bind ~!^2|%~2 input /ws "Upheaval"      <stnpc>',
            'bind ~!^3|%~3 input /ws "Steel Cyclone" <stnpc>',
            'bind ~!^4|%~4 input /ws "Weapon Break"  <stnpc>',
            'bind ~!^5|%~5 input /ws "Shield Break"  <stnpc>',
            'bind ~!^6|%~6 input /ws "Fell Cleave"   <stnpc>'},
        ['Axe']=L{
            'bind !^1|%1 input /ws "Bora Axe"',
            'bind !^2|%2 input /ws "Decimation"',
            'bind !^3|%3 input /ws "Ruinator"',
            'bind !^4|%4 input /ws "Smash Axe"',
            'bind !^5|%5 input /ws "Rampage"',
            'bind ~!^1|%~1 input /ws "Bora Axe"   <stnpc>',
            'bind ~!^2|%~2 input /ws "Decimation" <stnpc>',
            'bind ~!^3|%~3 input /ws "Ruinator"   <stnpc>',
            'bind ~!^4|%~4 input /ws "Smash Axe"  <stnpc>',
            'bind ~!^5|%~5 input /ws "Rampage"    <stnpc>'}},
        {['Epeo']='Great Sword',['Lionheart']='Great Sword',
         ['Axe']='Axe',['AxeDW']='Axe',['Sword']='Sword',['SwordDW']='Sword',['GreatAxe']='Great Axe',['Hepatizon']='Great Axe'})
    info.ws_binds:bind(state.CombatWeapon)
    send_command('bind %\\\\ gs c ListWS')

    info.recast_ids = L{{name="Battuta",id=120},{name="Vallation",id=23},{name="Liement",id=117},{name="Valiance",id=113},
                        {name="One for All",id=118},{name="Gambit",id=116},{name="Rayke",id=119}}
    if     player.sub_job == 'DRK' then
        info.recast_ids:extend(L{{name='Last Resort',id=87},{name='Souleater',id=85}})
    elseif player.sub_job == 'WAR' then
        info.recast_ids:extend(L{{name='Provoke',id=5},{name='Warcry',id=2}})
    end

    --select_default_macro_book()
end

-- Called when this job file is unloaded (eg: job change)
function user_unload()
    info.keybinds:unbind()

    info.ws_binds:unbind()
    send_command('unbind %\\\\')

    destroy_state_text()
end

-- Define sets and vars used by this job file.
function init_gear_sets()

    sets.weapons = {}
    sets.weapons.Epeo      = {main="Epeolatry",sub="Utu Grip"}
    sets.weapons.Lionheart = {main="Lionheart",sub="Utu Grip"}
    sets.weapons.Hepatizon = {main="Hepatizon Axe +1",sub="Utu Grip"}
    sets.weapons.GreatAxe  = {main="Lycurgos",sub="Utu Grip"}
    sets.weapons.Axe       = {main="Dolichenus",sub="Chanter's Shield"}
    sets.weapons.AxeDW     = {main="Dolichenus",sub="Reikiko"}
    --sets.weapons.Sword     = {main="Naegling",sub="Chanter's Shield"}
    sets.weapons.Sword     = {main="Reikiko",sub="Chanter's Shield"}
    sets.weapons.SwordDW   = {main="Naegling",sub="Reikiko"}

    -- Precast Sets
    sets.Enmity = prioritize({main="Epeolatry",sub="Utu Grip",ammo="Aqreqaq Bomblet",
        head="Halitus Helm",neck="Futhark Torque +2",ear1="Trux Earring",ear2="Cryptic Earring",
        body="Emet Harness +1",hands="Kurys Gloves",ring1="Eihwaz Ring",ring2="Supershear Ring",
        back=gear.MEVACape,waist="Platinum Moogle Belt",legs="Erilaz Leg Guards +2",feet="Erilaz Greaves +2"})
    -- enm+85, pdt-40, inqu+5, mdt-12,  bdt-12,  meva+478, 2696 hp /drk
    sets.Enmity.Tank = prioritize({main="Epeolatry",sub="Utu Grip",ammo="Staunch Tathlum +1",
        head="Halitus Helm",neck="Unmoving Collar +1",ear1="Odnowa Earring +1",ear2="Cryptic Earring",
        body="Emet Harness +1",hands="Kurys Gloves",ring1="Moonlight Ring",ring2="Defending Ring",
        back=gear.MEVACape,waist="Platinum Moogle Belt",legs="Erilaz Leg Guards +2",feet="Erilaz Greaves +2"})
    -- enm+68, pdt-50, inqu+5, mdt-28, bdt-26, meva+423, 2911 hp /drk

    -- combined with and Enmity set in job_precast
    sets.precast.JA.Warcry = {}
    sets.precast.JA.Provoke = {}
    sets.precast.JA.Souleater = {}
    sets.precast.JA['Last Resort'] = {}
    sets.precast.JA['Weapon Bash'] = {}
    sets.precast.JA['Elemental Sforzo'] = prioritize({body="Futhark Coat +3"})
    sets.precast.JA['Odyllic Subterfuge'] = {}
    sets.precast.JA['One for All'] = prioritize({neck="Unmoving Collar +1",body="Runeist Coat +3",back="Moonbeam Cape"})
    sets.precast.JA.Vallation = prioritize({body="Runeist Coat +3",back=gear.MEVACape})
    sets.precast.JA.Valiance = sets.precast.JA.Vallation
    sets.precast.JA.Liement = prioritize({body="Futhark Coat +3"})
    sets.precast.JA.Battuta = prioritize({head="Futhark Bandeau +3"})
    sets.precast.JA.Pflug = prioritize({feet="Runeist Bottes +3"})
    sets.precast.JA.Swordplay = prioritize({hands="Futhark Mitons +3"})
    sets.precast.JA.Gambit = prioritize({hands="Runeist Mitons +3"})
    sets.precast.JA.Rayke = prioritize({feet="Futhark Boots +3"})

    sets.precast.JA['Vivacious Pulse'] = prioritize({main="Epeolatry",sub="Utu Grip",ammo="Staunch Tathlum +1",
        head="Erilaz Galea +2",neck="Futhark Torque +2",ear1="Odnowa Earring +1",ear2="Cryptic Earring",
        body="Ashera Harness",hands="Turms Mittens +1",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.ParryCape,waist="Platinum Moogle Belt",legs="Nyame Flanchard",feet="Turms Leggings +1"})
    -- pdt-50, mdt-50, bdt-49, 3375 hp /drk

    sets.precast.JA.Lunge = prioritize({main="Epeolatry",sub="Utu Grip",ammo="Seething Bomblet +1",
        head="Nyame Helm",neck="Warder's Charm +1",ear1="Friomisi Earring",ear2="Hecate's Earring",
        body="Nyame Mail",hands="Nyame Gauntlets",ring1="Mujin Band",ring2="Locus Ring",
        back="Evasionist's Cape",waist="Orpheus's Sash",legs="Nyame Flanchard",feet="Nyame Sollerets"})
    sets.precast.JA.Swipe = sets.precast.JA.Lunge
    sets.dark_dmg  = prioritize({head="Pixie Hairpin +1",ring2="Archon Ring"})
    sets.orpheus   = {waist="Orpheus's Sash"}
    sets.ele_obi   = {waist="Hachirin-no-Obi"}
    sets.nuke_belt = {waist="Null Belt"}

    sets.precast.Step = prioritize({ammo="Yamarang",
        head="Erilaz Galea +2",neck="Unmoving Collar +1",ear1="Odr Earring",ear2="Telos Earring",
        body="Erilaz Surcoat +2",hands="Erilaz Gauntlets +2",ring1="Moonlight Ring",ring2="Ephramad's Ring",
        back=gear.TPCape,waist="Platinum Moogle Belt",legs="Erilaz Leg Guards +2",feet="Erilaz Greaves +2"})
    sets.precast.JA['Violent Flourish'] = prioritize(set_combine(sets.precast.Step, {ear1="Dignitary's Earring",back="Null Shawl"}))

    sets.precast.WS = prioritize({ammo="Knobkierrie",
        head="Adhemar Bonnet +1",neck="Fotia Gorget",ear1="Sherida Earring",ear2="Moonshade Earring",
        body="Nyame Mail",hands="Adhemar Wristbands +1",ring1="Ephramad's Ring",ring2="Niqmaddu Ring",
        back=gear.ResoCape,waist="Fotia Belt",legs="Meghanada Chausses +2",feet=gear.herc_feet_ta})
    sets.precast.WS.Tank = prioritize(set_combine(sets.precast.WS, {ammo="Yamarang",
        head="Nyame Helm",body="Nyame Mail",hands="Nyame Gauntlets",
        legs="Nyame Flanchard",feet="Nyame Sollerets"}))
    sets.precast.WS.Resolution = prioritize(set_combine(sets.precast.WS, {ammo="Seething Bomblet +1",body=gear.adh_body_ta}))
    sets.precast.WS.Resolution.Tank = prioritize(set_combine(sets.precast.WS.Resolution, {
        head="Nyame Helm",ring1="Moonlight Ring",ring2="Regal Ring"}))
    sets.precast.WS.Decimation     = set_combine(sets.precast.WS.Resolution, {ear2="Brutal Earring"})
    sets.precast.WS.Ruinator       = set_combine(sets.precast.WS.Resolution, {ear2="Brutal Earring"})
    sets.precast.WS.Ruinator.Tank  = set_combine(sets.precast.WS.Resolution.Tank, {})

    sets.precast.WS.OneHit = prioritize({ammo="Knobkierrie",
        head="Nyame Helm",neck="Futhark Torque +2",ear1="Sherida Earring",ear2="Moonshade Earring",
        body="Nyame Mail",hands="Nyame Gauntlets",ring1="Ephramad's Ring",ring2="Epaminondas's Ring",
        back=gear.DimiCape,waist="Sailfi Belt +1",legs="Nyame Flanchard",feet="Nyame Sollerets"})
    sets.precast.WS.Dimidiation = set_combine(sets.precast.WS.OneHit, {waist="Fotia Belt"})
    sets.precast.WS['Steel Cyclone'] = set_combine(sets.precast.WS.OneHit, {})
    sets.precast.WS['Fell Cleave']   = set_combine(sets.precast.WS.OneHit, {})
    sets.precast.WS['Ground Strike'] = set_combine(sets.precast.WS.OneHit, {})
    sets.precast.WS['Savage Blade']  = set_combine(sets.precast.WS.OneHit, {})
    sets.precast.WS['Bora Axe']      = set_combine(sets.precast.WS.Dimidiation, {})

    sets.precast.WS.Crit = set_combine(sets.precast.WS, {ammo="Yetshila +1",ear2="Odr Earring",feet="Ayanmo Gambieras +2"})
    sets.precast.WS['Vorpal Blade'] = set_combine(sets.precast.WS.Crit, {})
    sets.precast.WS.Rampage = set_combine(sets.precast.WS.Crit, {})

    sets.precast.WS.Magical = set_combine(sets.precast.JA.Lunge, {ring1="Metamorph Ring +1",ring2="Regal Ring"})
    sets.precast.WS['Sanguine Blade'] = set_combine(sets.precast.WS.Magical, sets.dark_dmg)

    sets.precast.WS.AddEffect = prioritize({ammo="Yamarang",
        head="Nyame Helm",neck="Null Loop",ear1="Moonshade Earring",ear2="Erilaz Earring +1",
        body="Nyame Mail",hands="Nyame Gauntlets",ring1="Moonlight Ring",ring2="Ephramad's Ring",
        back="Null Shawl",waist="Null Belt",legs="Nyame Flanchard",feet="Nyame Sollerets"})
    sets.precast.WS.Shockwave = prioritize({ammo="Yamarang",
        head="Nyame Helm",neck="Unmoving Collar +1",ear1="Dignitary's Earring",ear2="Erilaz Earring +1",
        body="Nyame Mail",hands="Nyame Gauntlets",ring1="Moonlight Ring",ring2="Defending Ring",
        back=gear.ParryCape,waist="Platinum Moogle Belt",legs="Nyame Flanchard",feet="Nyame Sollerets"})
    sets.precast.WS['Herculean Slash'] = set_combine(sets.precast.WS.AddEffect, {})
    sets.precast.WS['Full Break']      = set_combine(sets.precast.WS.AddEffect, {})
    sets.precast.WS['Shield Break']    = set_combine(sets.precast.WS.AddEffect, {})
    sets.precast.WS['Armor Break']     = set_combine(sets.precast.WS.AddEffect, {})
    sets.precast.WS['Weapon Break']    = set_combine(sets.precast.WS.AddEffect, {})
    sets.precast.WS['Flat Blade']      = set_combine(sets.precast.WS.AddEffect, {})
    sets.precast.WS['Smash Axe']      = set_combine(sets.precast.WS.AddEffect, {})

    sets.precast.RA = {ammo=empty}
    sets.precast.FC = prioritize({main="Epeolatry",sub="Utu Grip",ammo="Sapience Orb",
        head="Runeist Bandeau +3",neck="Unmoving Collar +1",ear1="Odnowa Earring +1",ear2="Etiolation Earring",
        body=gear.adh_body_fc,hands="Leyline Gloves",ring1="Moonlight Ring",ring2="Kishar Ring",
        back=gear.FCCape,waist="Platinum Moogle Belt",legs="Ayanmo Cosciales +2",feet="Carmine Greaves +1"})
    -- fc+60 (+30 val), 3579 hp /drk
    sets.precast.FC['Enhancing Magic'] = prioritize(set_combine(sets.precast.FC, {legs="Futhark Trousers +3"}))
    --sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {neck="Magoraga Beads"})

    -- Midcast Sets
    sets.SIRD = prioritize({main="Epeolatry",sub="Utu Grip",ammo="Staunch Tathlum +1",
        head="Erilaz Galea +2",neck="Moonlight Necklace",ear1="Odnowa Earring +1",ear2="Halasz Earring",
        body=gear.taeon_body_phlx,hands="Rawhide Gloves",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.MEVACape,waist="Audumbla Sash",legs="Carmine Cuisses +1",feet=gear.taeon_feet_phlx})
    -- sir-102, pdt-38, mdt-26, bdt-24, enm+26, 2755 hp /drk FIXME DT feet after galea+3
    sets.SIRD.Choral = prioritize({main="Epeolatry",sub="Utu Grip",ammo="Staunch Tathlum +1",
        head="Erilaz Galea +2",neck="Moonlight Necklace",ear1="Odnowa Earring +1",ear2="Etiolation Earring",
        body="Futhark Coat +3",hands="Nyame Gauntlets",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.MEVACape,waist="Audumbla Sash",legs="Carmine Cuisses +1",feet="Erilaz Greaves +2"})

    sets.midcast['Enhancing Magic'] = prioritize({main="Epeolatry",sub="Utu Grip",ammo="Staunch Tathlum +1",
        head="Erilaz Galea +2",neck="Incanter's Torque",ear1="Andoaa Earring",ear2="Mimir Earring",
        body="Futhark Coat +3",hands="Runeist Mitons +3",ring1=gear.Lstikini,ring2=gear.Rstikini,
        back=gear.MEVACape,waist="Olympus Sash",legs="Carmine Cuisses +1",feet="Erilaz Greaves +2"})
    sets.midcast.Temper = set_combine(sets.midcast['Enhancing Magic'], {})
    -- skill=523, dur+40, pdt-21, mdt-5, bdt-5, 2785 hp /drk (risky spell)
    sets.midcast.Temper.Tank = prioritize({main="Epeolatry",sub="Utu Grip",ammo="Staunch Tathlum +1",
        head="Erilaz Galea +2",neck="Futhark Torque +2",ear1="Andoaa Earring",ear2="Mimir Earring",
        body="Nyame Mail",hands="Runeist Mitons +3",ring1=gear.Lstikini,ring2="Defending Ring",
        back=gear.MEVACape,waist="Platinum Moogle Belt",legs="Carmine Cuisses +1",feet="Erilaz Greaves +2"})
    -- skill=522, dur+40, pdt-50, mdt-42, bdt-42, 3181 hp /drk FIXME
    sets.midcast.Phalanx = prioritize({main="Deacon Sword",sub=empty,ammo="Staunch Tathlum +1",
        head="Futhark Bandeau +3",neck="Futhark Torque +2",ear1="Odnowa Earring +1",ear2="Mimir Earring",
        body=gear.herc_body_phlx,hands=gear.herc_hands_phlx,ring1="Moonlight Ring",ring2="Defending Ring",
        back=gear.MEVACape,waist="Platinum Moogle Belt",legs=gear.herc_legs_phlx,feet=gear.herc_feet_phlx})
    -- phalanx+17~21, skill=472, dur+0, pdt-47, mdt-33, bdt-31, 3082 hp /drk (tiers at 443, 472, 500 skill)
    sets.PhalanxIncoming = prioritize({main="Deacon Sword",sub=empty,ammo="Staunch Tathlum +1",
        head="Futhark Bandeau +3",neck="Futhark Torque +2",ear1="Odnowa Earring +1",ear2="Erilaz Earring +1",
        body=gear.herc_body_phlx,hands=gear.herc_hands_phlx,ring1="Vocane Ring +1",ring2="Defending Ring",
        back="Evasionist's Cape",waist="Platinum Moogle Belt",legs=gear.herc_legs_phlx,feet=gear.herc_feet_phlx})

    sets.midcast.FixedPotencyEnhancing = prioritize({main="Epeolatry",sub="Utu Grip",ammo="Staunch Tathlum +1",
        head="Erilaz Galea +2",neck="Futhark Torque +2",ear1="Odnowa Earring +1",ear2="Etiolation Earring",
        body="Nyame Mail",hands="Turms Mittens +1",ring1="Moonlight Ring",ring2="Defending Ring",
        back=gear.MEVACape,waist="Platinum Moogle Belt",legs="Futhark Trousers +3",feet="Turms Leggings +1"})
    sets.midcast.Refresh = set_combine(sets.midcast.FixedPotencyEnhancing, {})
    sets.midcast['Regen IV'] = prioritize(set_combine(sets.midcast.FixedPotencyEnhancing, {
        head="Runeist Bandeau +3",neck="Sacro Gorget",ear2="Erilaz Earring +1",feet="Nyame Sollerets"}))
    sets.midcast.Stoneskin = prioritize({main="Epeolatry",sub="Utu Grip",ammo="Seething Bomblet +1",
        head="Runeist Bandeau +3",neck="Stone Gorget",ear1="Odnowa Earring +1",ear2="Etiolation Earring",
        body="Erilaz Surcoat +2",hands="Erilaz Gauntlets +2",ring1="Moonlight Ring",ring2="Defending Ring",
        back=gear.ParryCape,waist="Platinum Moogle Belt",legs="Erilaz Leg Guards +2",feet="Turms Leggings +1"})
    sets.midcast.Stoneskin.Potency = prioritize({main="Epeolatry",sub="Utu Grip",ammo="Seething Bomblet +1",
        head="Runeist Bandeau +3",neck="Stone Gorget",ear1="Odnowa Earring +1",ear2="Erilaz Earring +1",
        body="Erilaz Surcoat +2",hands="Erilaz Gauntlets +2",ring1="Moonlight Ring",ring2="Defending Ring",
        back=gear.FCCape,waist="Siegel Sash",legs="Haven Hose",feet="Erilaz Greaves +2"})
    sets.midcast.Blink = {}

    sets.midcast['Enfeebling Magic'] = prioritize({main="Epeolatry",sub="Kaja Grip",ammo="Yamarang",
        head="Erilaz Galea +2",neck="Null Loop",ear1="Dignitary's Earring",ear2="Erilaz Earring +1",
        body="Nyame Mail",hands="Erilaz Gauntlets +2",ring1=gear.Lstikini,ring2=gear.Rstikini,
        back="Null Shawl",waist="Null Belt",legs="Erilaz Leg Guards +2",feet="Erilaz Greaves +2"})
    sets.midcast.Poisonga = prioritize({main="Epeolatry",sub="Utu Grip",ammo="Perfect Lucky Egg",
        head="Volte Cap",neck="Futhark Torque +2",ear1="Odnowa Earring +1",ear2="Etiolation Earring",
        body="Nyame Mail",hands="Turms Mittens +1",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.MEVACape,waist="Platinum Moogle Belt",legs=gear.herc_legs_th,feet="Turms Leggings +1"})
    sets.midcast.Repose = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast.Absorb = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast.Aspir = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast.Drain = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast.Utsusemi = {}
    sets.midcast['Blue Magic'] = {}

    sets.midcast.Cure = prioritize({main="Epeolatry",sub="Utu Grip",ammo="Staunch Tathlum +1",
        head="Null Masque",neck="Sacro Gorget",ear1="Odnowa Earring +1",ear2="Erilaz Earring +1",
        body="Erilaz Surcoat +2",hands="Turms Mittens +1",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.ParryCape,waist="Gishdubar Sash",legs="Erilaz Leg Guards +2",feet="Turms Leggings +1"})

    sets.midcast.Foil              = set_combine(sets.Enmity, {})
    sets.midcast.Flash             = set_combine(sets.Enmity, {})
    sets.midcast.Stun              = set_combine(sets.Enmity, {})
    sets.midcast['Frightful Roar'] = set_combine(sets.Enmity, {})
    sets.midcast['Sheep Song']     = set_combine(sets.Enmity, {})
    sets.midcast['Geist Wall']     = set_combine(sets.Enmity, {})
    sets.midcast['Blank Gaze']     = set_combine(sets.Enmity, {})
    sets.midcast.Soporific         = set_combine(sets.Enmity, {})
    sets.midcast.Jettatura         = set_combine(sets.Enmity, {})

    sets.midcast.Foil.Tank              = set_combine(sets.Enmity.Tank, {})
    sets.midcast.Flash.Tank             = set_combine(sets.Enmity.Tank, {})
    sets.midcast.Stun.Tank              = set_combine(sets.Enmity.Tank, {})
    sets.midcast['Frightful Roar'].Tank = set_combine(sets.Enmity.Tank, {})
    sets.midcast['Sheep Song'].Tank     = set_combine(sets.Enmity.Tank, {})
    sets.midcast['Geist Wall'].Tank     = set_combine(sets.Enmity.Tank, {})
    sets.midcast['Blank Gaze'].Tank     = set_combine(sets.Enmity.Tank, {})
    sets.midcast.Soporific.Tank         = set_combine(sets.Enmity.Tank, {})
    sets.midcast.Jettatura.Tank         = set_combine(sets.Enmity.Tank, {})

    sets.midcast.Stun.MAcc              = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast['Frightful Roar'].MAcc = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast['Sheep Song'].MAcc     = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast['Geist Wall'].MAcc     = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast['Blank Gaze'].MAcc     = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast.Soporific.MAcc         = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast.Jettatura.MAcc         = set_combine(sets.midcast['Enfeebling Magic'], {})

    sets.buff.doom = prioritize({main="Epeolatry",sub="Utu Grip",ammo="Staunch Tathlum +1",
        head="Null Masque",neck="Nicander's Necklace",ear1="Odnowa Earring +1",ear2="Etiolation Earring",
        body="Nyame Mail",hands="Erilaz Gauntlets +2",ring1="Eshmun's Ring",ring2="Purity Ring",
        back=gear.MEVACape,waist="Gishdubar Sash",legs="Erilaz Leg Guards +2",feet="Erilaz Greaves +2"})
    sets.buff.sleep = {head="Frenzy Sallet"}
    sets.buff.Embolden = {back="Evasionist's Cape"}
    sets.buff.Battuta = {feet="Futhark Boots +3"}

    -- Idle and tanking sets
    sets.idle = prioritize({main="Epeolatry",sub="Utu Grip",ammo="Staunch Tathlum +1",
        head="Turms Cap +1",neck="Futhark Torque +2",ear1="Odnowa Earring +1",ear2="Etiolation Earring",
        body="Runeist Coat +3",hands="Nyame Gauntlets",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.MEVACape,waist="Platinum Moogle Belt",legs="Carmine Cuisses +1",feet="Erilaz Greaves +2"})
    sets.idle.Refresh = prioritize({main="Epeolatry",sub="Utu Grip",ammo="Homiliary",
        head="Null Masque",neck="Futhark Torque +2",ear1="Odnowa Earring +1",ear2="Etiolation Earring",
        body="Runeist Coat +3",hands=gear.herc_hands_rf,ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.MEVACape,waist="Platinum Moogle Belt",legs=gear.herc_legs_rf,feet="Erilaz Greaves +2"})
    sets.idle.Kite = prioritize({main="Epeolatry",sub="Utu Grip",ammo="Homiliary",
        head="Turms Cap +1",neck="Futhark Torque +2",ear1="Odnowa Earring +1",ear2="Etiolation Earring",
        body="Runeist Coat +3",hands="Nyame Gauntlets",ring1="Moonlight Ring",ring2="Defending Ring",
        back=gear.MEVACape,waist="Platinum Moogle Belt",legs="Carmine Cuisses +1",feet="Erilaz Greaves +2"})
    sets.latent_refresh = {ammo="Homiliary",waist="Fucho-no-obi"}
    sets.defense.Kite = set_combine(sets.idle.Kite, {})

    sets.defense.Parry = prioritize({main="Epeolatry",sub="Utu Grip",ammo="Staunch Tathlum +1",
        head="Null Masque",neck="Futhark Torque +2",ear1="Odnowa Earring +1",ear2="Cryptic Earring",
        body="Erilaz Surcoat +2",hands="Turms Mittens +1",ring1="Moonlight Ring",ring2="Defending Ring",
        back=gear.ParryCape,waist="Platinum Moogle Belt",legs="Erilaz Leg Guards +2",feet="Turms Leggings +1"})
    sets.defense.VParry = set_combine(sets.defense.Parry, {ring1="Vocane Ring +1"})
    --sets.defense.RGParry = set_combine(sets.defense.Parry, prioritize({head="Turms Cap +1",body="Nyame Mail"}))
    sets.defense.Eva = prioritize({main="Epeolatry",sub="Utu Grip",ammo="Yamarang",
        head="Null Masque",neck="Bathy Choker +1",ear1="Eabani Earring",ear2="Infused Earring",
        body="Nyame Mail",hands="Turms Mittens +1",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.MEVACape,waist="Null Belt",legs="Nyame Flanchard",feet="Hippomenes Socks +1"})

    sets.defense.HPdown = {main="Epeolatry",sub="Kaja Grip",ammo="Staunch Tathlum +1",
        head="Ayanmo Zucchetto +2",neck="Loricate Torque +1",ear1="Sherida Earring",ear2="Telos Earring",
        body="Ayanmo Corazza +2",hands="Ayanmo Manopolas +2",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.TPCape,waist="Gishdubar Sash",legs="Ayanmo Cosciales +2",feet="Ayanmo Gambieras +2"}
    sets.defense.HPup = prioritize({main="Epeolatry",sub="Utu Grip",ammo="Staunch Tathlum +1",
        head="Erilaz Galea +2",neck="Futhark Torque +2",ear1="Odnowa Earring +1",ear2="Etiolation Earring",
        body="Ashera Harness",hands="Runeist Mitons +3",ring1="Moonlight Ring",ring2="Defending Ring",
        back="Moonbeam Cape",waist="Platinum Moogle Belt",legs="Erilaz Leg Guards +2",feet="Turms Leggings +1"})

    sets.defense.MEVA = prioritize({main="Epeolatry",sub="Utu Grip",ammo="Yamarang",
        head="Turms Cap +1",neck="Futhark Torque +2",ear1="Eabani Earring",ear2="Erilaz Earring +1",
        body="Nyame Mail",hands="Nyame Gauntlets",ring1="Vocane Ring +1",ring2="Shadow Ring",
        back=gear.ParryCape,waist="Platinum Moogle Belt",legs="Nyame Flanchard",feet="Erilaz Greaves +2"})

    sets.defense.MDT = prioritize({main="Epeolatry",sub="Utu Grip",ammo="Staunch Tathlum +1",
        head="Turms Cap +1",neck="Warder's Charm +1",ear1="Odnowa Earring +1",ear2="Erilaz Earring +1",
        body="Erilaz Surcoat +2",hands="Erilaz Gauntlets +2",ring1="Vocane Ring +1",ring2="Shadow Ring",
        --back="Repulse Mantle",waist="Platinum Moogle Belt",legs="Erilaz Leg Guards +2",feet="Erilaz Greaves +2"})
        back=gear.ParryCape,waist="Platinum Moogle Belt",legs="Erilaz Leg Guards +2",feet="Erilaz Greaves +2"})
    sets.defense.MT = set_combine(sets.defense.MDT, prioritize({body="Erilaz Surcoat +2",back=gear.ParryCape}))

    sets.defense.MDB = prioritize({main="Epeolatry",sub="Utu Grip",ammo="Pemphredo Tathlum",
        head="Null Masque",neck="Sibyl Scarf",ear1="Odnowa Earring +1",ear2="Erilaz Earring +1",
        body="Nyame Mail",hands="Futhark Mitons +3",ring1="Metamorph Ring +1",ring2="Shadow Ring",
        back=gear.IntCape,waist="Platinum Moogle Belt",legs="Nyame Flanchard",feet="Nyame Sollerets"})

    sets.defense.Knockback = {ring1="Vocane Ring +1",back="Repulse Mantle"}
    sets.defense.Charm     = prioritize({main="Epeolatry",sub="Utu Grip",ammo="Staunch Tathlum +1",
        head="Null Masque",neck="Unmoving Collar +1",ear1="Hearty Earring",ear2="Arete del Luna +1",
        body="Erilaz Surcoat +2",hands="Erilaz Gauntlets +2",ring1="Moonlight Ring",ring2="Defending Ring",
        back=gear.ParryCape,waist="Platinum Moogle Belt",legs="Erilaz Leg Guards +2",feet="Runeist Bottes +3"})
    sets.defense.Death = prioritize({main="Epeolatry",sub="Utu Grip",ammo="Staunch Tathlum +1",
        head="Null Masque",neck="Futhark Torque +2",ear1="Odnowa Earring +1",ear2="Erilaz Earring +1",
        body="Samnuha Coat",hands="Erilaz Gauntlets +2",ring1="Eihwaz Ring",ring2="Shadow Ring",
        back=gear.ParryCape,waist="Platinum Moogle Belt",legs="Erilaz Leg Guards +2",feet="Runeist Bottes +3"})
    sets.defense.Stun = prioritize({main="Epeolatry",sub="Utu Grip",ammo="Staunch Tathlum +1",
        head="Volte Cap",neck="Anu Torque",ear1="Arete del Luna",ear2="Arete del Luna +1",
        body="Nyame Mail",hands="Erilaz Gauntlets +2",ring1="Vocane Ring +1",ring2="Shadow Ring",
        back="Repulse Mantle",waist="Platinum Moogle Belt",legs="Erilaz Leg Guards +2",feet="Erilaz Greaves +2"})
    sets.Kiting = {legs="Carmine Cuisses +1"}

    -- Engaged (DD) sets
    sets.engaged = prioritize({main="Epeolatry",sub="Utu Grip",ammo="Yamarang",
        head="Adhemar Bonnet +1",neck="Anu Torque",ear1="Sherida Earring",ear2="Telos Earring",
        body=gear.adh_body_ta,hands="Adhemar Wristbands +1",ring1="Epona's Ring",ring2="Niqmaddu Ring",
        back=gear.TPCape,waist="Windbuffet Belt +1",legs="Samnuha Tights",feet=gear.herc_feet_ta})
    sets.engaged.PDef = prioritize({main="Epeolatry",sub="Utu Grip",ammo="Yamarang",
        head="Ayanmo Zucchetto +2",neck="Futhark Torque +2",ear1="Sherida Earring",ear2="Telos Earring",
        body="Ashera Harness",hands="Adhemar Wristbands +1",ring1="Moonlight Ring",ring2="Defending Ring",
        back=gear.TPCape,waist="Sailfi Belt +1",legs="Meghanada Chausses +2",feet=gear.herc_feet_ta})
    sets.engaged.PDef2 = prioritize(set_combine(sets.engaged.PDef, {ammo="Staunch Tathlum +1",
        hands="Turms Mittens +1",feet="Turms Leggings +1"}))

    sets.engaged.AxeDW         = set_combine(sets.engaged,       {ear2="Suppanomimi",waist="Reiki Yotai"})
    sets.engaged.AxeDW.PDef    = set_combine(sets.engaged.PDef,  {ear2="Suppanomimi",waist="Reiki Yotai",legs="Samnuha Tights"})
    sets.engaged.AxeDW.PDef2   = set_combine(sets.engaged.PDef2, {ear2="Suppanomimi"})
    sets.engaged.SwordDW       = set_combine(sets.engaged,       {ear2="Suppanomimi",waist="Reiki Yotai"})
    sets.engaged.SwordDW.PDef  = set_combine(sets.engaged.PDef,  {ear2="Suppanomimi",waist="Reiki Yotai",legs="Samnuha Tights"})
    sets.engaged.SwordDW.PDef2 = set_combine(sets.engaged.PDef2, {ear2="Suppanomimi"})

    -- Spells default to a midcast of FastRecast, which is altered to match current the DefenseMode in job_precast
    sets.midcast.FastRecast = set_combine(sets.defense.Parry, {})
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.
function job_precast(spell, action, spellMap, eventArgs)
    if S{'Souleater','Last Resort','Berserk','Defender'}:contains(spell.english) and buffactive[spell.english] then
        send_command('cancel '..spell.english)
        eventArgs.cancel = true
    elseif spell.english == 'Vallation' then
        if state.Buff.Liement then send_command('cancel Liement') end
    elseif spell.english == 'Valiance' then
        if state.Buff.Liement then send_command('cancel Liement')
        elseif state.Buff.Vallation then send_command('cancel Vallation') end
    elseif spell.english == 'Light Arts' or spell.english == 'Addendum: White' then
        state.Buff['Dark Arts']       = false
        state.Buff['Addendum: Black'] = false
    elseif spell.english == 'Dark Arts'  or spell.english == 'Addendum: Black' then
        state.Buff['Light Arts']      = false
        state.Buff['Addendum: White'] = false
    end
    if S{'Ward','Effusion','JobAbility'}:contains(spell.type) then
        if sets.precast.JA[spell.english] then
            eventArgs.handled = true
            if state.LowEnmRG.value and S{'Rayke','Gambit'}:contains(spell.english) then
                send_command('cancel Crusade')
                equip(sets.defense.MEVA, sets.weapons.Lionheart, sets.precast.JA[spell.english])
            elseif state.CastingMode.value == 'Tank' then
                equip(sets.Enmity.Tank,     sets.precast.JA[spell.english])
            else
                equip(sets.Enmity,          sets.precast.JA[spell.english])
            end
        end
    end
end

-- Run after the general precast() is done.
function job_post_precast(spell, action, spellMap, eventArgs)
    if spell.type == 'Effusion' then
        if S{'Swipe','Lunge'}:contains(spell.english) then
            spell.element = triple_rune_string() or ''
            equip(resolve_ele_belt(spell, sets.ele_obi, sets.nuke_belt, 3))
            if buffactive.Tenebrae then
                equip(sets.dark_dmg)
            end
        end
    elseif spell.type == 'WeaponSkill' then
        if spell.english == 'Sanguine Blade' then equip(resolve_ele_belt(spell, sets.ele_obi, sets.nuke_belt, 3)) end
        if buffactive['elvorseal'] and player.inventory["Heidrek Boots"] then equip({feet="Heidrek Boots"}) end
    end
end

-- Run after the default midcast() is done.
-- eventArgs is the same one used in job_midcast, in case information needs to be persisted.
function job_post_midcast(spell, action, spellMap, eventArgs)
    if state.SIRD.value and info.sird_spells:contains(spell.english) then
        if buffactive['Choral Roll'] then
            equip(sets.SIRD.Choral)
        else
            equip(sets.SIRD)
            if spell.english == 'Aquaveil' then
                -- auto unset SIRD; i forget to do so manually too often
                state.SIRD:unset()
                hud_update_on_state_change('SIRD Casting')
            end
        end
    end
    if spell.target.type == 'SELF' then
        if spell.english == 'Cursna' then
            equip(sets.buff.doom)
        elseif spell.english == 'Stoneskin' then
            if player.hp < 3100
            or (state.DefenseMode.value == 'Magical' and state.MagicalDefenseMode.value == 'MDB') then
                -- better stoneskins for Aminon
                equip(sets.midcast.Stoneskin.Potency)
            end
        end
        if state.Buff.Embolden and spell.skill == 'Enhancing Magic' and spell.english ~= 'Erase' then
            equip(sets.buff.Embolden)
        end
    elseif spell.skill == 'Elemental Magic' then
        if spell.target.name == 'Aminon' then
            equip(sets.defense.Death)
        else
            equip(sets.precast.JA.Lunge)
        end
    end
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_aftercast(spell, action, spellMap, eventArgs)
    if spell.interrupted then
        equip(sets.defense.Parry)
        send_command('wait 0.5;gs c update')
        interrupted_message(spell)
    else
        if state.WSMsg.value then
            if spell.type == 'WeaponSkill' then
                send_command('input /p '..spell.english)
            elseif spell.english == 'Embolden' then
                send_command('input /p Used '..spell.english)
            elseif S{'Gambit','Rayke'}:contains(spell.english) then
                local msg = 'Used '..spell.english
                local triple_rune = triple_rune_string()
                if triple_rune then
                    msg = msg..' ('..triple_rune..')'
                end
                send_command('input /p '..msg)
            end
        end
        if spell.type == 'Rune' or spell.type == 'JobAbility' and not sets.precast.JA[spell.english] then
            -- aftercast can get in the way. skip it when able
            eventArgs.handled = true
        end
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for non-casting events.
-------------------------------------------------------------------------------------------------------------------

-- Called when the player's status changes.
function job_status_change(newStatus, oldStatus, eventArgs)
    if newStatus == 'Engaged' or oldStatus == 'Engaged' then
        -- Don't break midcast for a state change
        if midaction() then
            eventArgs.handled = true
        end
    end
end

-- Called when a player gains or loses a buff.
-- buff == buff gained or lost
-- gain == true if the buff was gained, false if it was lost.
function job_buff_change(buff, gain)
    local lbuff = buff:lower()
    if lbuff == 'sleep' then
        if gain then
            if player.hp > 100 and player.status == 'Engaged' then
                equip(sets.buff.sleep)
            end
            add_to_chat(123, 'cancelling stoneskin')
            send_command('cancel stoneskin')
        elseif not midaction() then
            handle_equipping_gear(player.status)
        end
    elseif lbuff == 'doom' and not midaction() then
        handle_equipping_gear(player.status)
    end
    if gain and info.chat_notice_buffs:contains(lbuff) then
        add_to_chat(104, 'Gained ['..buff..']')
    end
end

-- Handle notifications of general user state change.
function job_state_change(stateField, newValue, oldValue)
    if stateField == 'Offense Mode' then
        enable('main','sub')
        handle_equipping_gear(player.status)
        equip(sets.weapons[state.CombatWeapon.value])
        if state.OffenseMode.value ~= 'None' then
            disable('main','sub')
        end
    elseif stateField == 'Combat Weapon' then
        info.ws_binds:bind(state.CombatWeapon)
        enable('main','sub')
        handle_equipping_gear(player.status)
        equip(sets.weapons[newValue])
        if state.OffenseMode.value ~= 'None' then
            disable('main','sub')
        end
    elseif stateField:endswith('Defense Mode') then
        if state.DefenseMode.value ~= 'None' then
            local defMode = state[state.DefenseMode.value..'DefenseMode'].current
            sets.midcast.FastRecast = set_combine(sets.defense[defMode], {})
            handle_equipping_gear(player.status)
        else
            sets.midcast.FastRecast = set_combine(sets.defense.Parry, {})
        end
    end

    if hud_update_on_state_change then
        hud_update_on_state_change(stateField)
    end
end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements standard library decisions.
-------------------------------------------------------------------------------------------------------------------

-- Custom spell mapping.
function job_get_spell_map(spell, default_spell_map)
    if spell.action_type == 'Magic' then
        if spell.skill == 'Enhancing Magic' then
            if  not S{'Temper','Phalanx','Refresh'}:contains(spell.english)
            and not S{'Regen','BarElement','BarStatus'}:contains(default_spell_map) then
                return "FixedPotencyEnhancing"
            end
        end
    end
end

-- Modify the default idle set after it was constructed.
function customize_idle_set(idleSet)
    if player.mpp < 51 and state.DefenseMode.value == 'None' then
        idleSet = set_combine(idleSet, sets.latent_refresh)
    end
    if state.StatusDefenseMode.value ~= 'None' then
        idleSet = set_combine(idleSet, sets.defense[state.StatusDefenseMode.value])
        if state.StatusDefenseMode.value == 'Knockback' then
            if player.inventory["Dashing Subligar"] then idleSet = set_combine(idleSet, {legs="Dashing Subligar"}) end
        end
    end
    if state.Buff.doom then
        idleSet = set_combine(sets.buff.doom, {})
    end
    if state.Buff.Embolden then
        idleSet = set_combine(idleSet, sets.buff.Embolden)
    end
    return idleSet
end

-- Modify the default defense set after it was constructed.
function customize_defense_set(defenseSet)
    if player.status ~= 'Engaged'
    and state.DefenseMode.value == 'Physical' and state.PhysicalDefenseMode.value:endswith('Parry') then
        defenseSet = sets.defense.Kite
    elseif state.TParry.value and state.Buff.Battuta and player.status == 'Engaged'
    and (state.DefenseMode.value == 'Physical' and state.PhysicalDefenseMode.value:endswith('Parry')
    or   state.DefenseMode.value == 'None') then
        defenseSet = set_combine(defenseSet, sets.buff.Battuta)
    end
    if state.Buff.doom then
        defenseSet = set_combine(defenseSet, sets.buff.doom)
    end
    if state.Buff.Embolden then
        defenseSet = set_combine(defenseSet, sets.buff.Embolden)
    end
    return defenseSet
end

-- Modify the default melee set after it was constructed.
function customize_melee_set(meleeSet)
    if buffactive['elvorseal'] and state.DefenseMode.value == 'None' then
        if player.inventory["Heidrek Gloves"] then meleeSet = set_combine(meleeSet, {hands="Heidrek Gloves"}) end
        if state.HybridMode.value == 'Normal' then
            if player.inventory["Heidrek Harness"] then meleeSet = set_combine(meleeSet, {body="Heidrek Harness"}) end
        end
    end
    if state.StatusDefenseMode.value ~= 'None' then
        meleeSet = set_combine(meleeSet, sets.defense[state.StatusDefenseMode.value])
        if state.StatusDefenseMode.value == 'Knockback' then
            if player.inventory["Dashing Subligar"] then meleeSet = set_combine(meleeSet, {legs="Dashing Subligar"}) end
        end
    end
    if state.TParry.value and state.Buff.Battuta then
        meleeSet = set_combine(meleeSet, sets.buff.Battuta)
    end
    if state.Buff.doom then
        meleeSet = set_combine(sets.buff.doom, {})
    end
    if state.Buff.Embolden then
        meleeSet = set_combine(meleeSet, sets.buff.Embolden)
    end
    if state.Buff.sleep then
        meleeSet = set_combine(meleeSet, sets.buff.sleep)
    end
    return meleeSet
end

-- Set eventArgs.handled to true if we don't want the automatic display to be run.
function display_current_job_state(eventArgs)
    local msg = ''

    msg = msg .. 'ME[' .. state.OffenseMode.current
    if state.HybridMode.value ~= 'Normal' then
        msg = msg .. '/' .. state.HybridMode.value
    end
    msg = msg .. ':' .. state.CombatWeapon.value .. ']'
    msg = msg .. ' WS[' .. state.WeaponskillMode.current .. ']'
    if state.SelectNPCTargets.value then
        msg = msg .. '<stnpc>'
    end
    msg = msg .. ' Idle[' .. state.IdleMode.current .. ']'
    msg = msg .. ' Cast[' .. state.CastingMode.current .. ']'

    if state.DefenseMode.value ~= 'None' then
        local defMode = state[state.DefenseMode.value..'DefenseMode'].current
        msg = msg .. ' Def[' .. state.DefenseMode.value .. ':' .. defMode .. ']'
    end
    if state.StatusDefenseMode.value ~= 'None' then
        msg = msg .. ' ST[' .. state.StatusDefenseMode.value .. ']'
    end
    if state.TParry.value then
        msg = msg .. ' TParry'
    end
    if state.SIRD.value then
        msg = msg .. ' SIRD'
    end
    if state.LowEnmRG.value then
        msg = msg .. ' LowRG'
    end

    if state.WSMsg.value then
        msg = msg .. ' WSMsg'
    end

    if state.Kiting.value then
        msg = msg .. ' Kiting'
    end

    add_to_chat(122, msg)
    report_ja_recasts(info.recast_ids, true, 5)
    eventArgs.handled = true
end

-- Called by the 'update' self-command, for common needs.
-- Set eventArgs.handled to true if we don't want automatic equipping of gear.
function job_update(cmdParams, eventArgs)
    if midaction() and cmdParams[1] == 'auto' then
        -- don't break midcast for state changes and such
        eventArgs.handled = true
    end
end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements self-commands.
-------------------------------------------------------------------------------------------------------------------

-- Called for custom player commands.
function job_self_command(cmdParams, eventArgs)
    eventArgs.handled = true
    if     cmdParams[1] == 'scholar' then
        handle_stratagems(cmdParams)
    elseif cmdParams[1] == 'ListWS' then
        info.ws_binds:print('ListWS:')
    elseif cmdParams[1] == 'weap' then
        weap_self_command(cmdParams, 'CombatWeapon')
    elseif cmdParams[1] == 'save' then
        save_self_command(cmdParams)
    elseif cmdParams[1] == 'rebind' then
        info.keybinds:bind()
    else
        eventArgs.handled = false
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------

-- Select default macro book on initial load or subjob change.
--function select_default_macro_book()
--    set_macro_page(1,12)
--end

-- returns a list for use with make_keybind_list
function job_keybinds()
    local bind_command_list = L{
        'bind !^l input /lockstyleset 7',
        'bind %`   gs c update user',
        'bind F9   gs c cycle OffenseMode',
        'bind @F9  gs c cycle WeaponskillMode',
        'bind !F9  gs c reset OffenseMode',
        'bind F10  gs c cycle CastingMode',
        'bind !F10 gs c reset CastingMode',
        'bind F11  gs c cycle IdleMode',
        'bind !F11 gs c reset IdleMode',
        'bind @F11 gs c toggle Kiting',
        'bind ^space  gs c cycle HybridMode',
        'bind ^@space gs c reset HybridMode',
        'bind !space gs c set DefenseMode Physical',
        'bind @space gs c set DefenseMode Magical',
        'bind !@space gs c reset DefenseMode',
        'bind  !^w gs c set CombatWeapon Epeo',
        'bind ~!^w gs c set CombatWeapon Lionheart',
        'bind  !^q gs c set CombatWeapon GreatAxe',
        'bind ~!^q gs c set CombatWeapon Hepatizon',
        'bind  !^e gs c weap Axe',
        'bind ~!^e gs c weap Sword',
        'bind ^z gs c set HybridMode PDef2',
        'bind ~^z gs c toggle TParry',
        'bind !z gs c cycle PhysicalDefenseMode',
        'bind @z gs c cycle MagicalDefenseMode',
        'bind !@z gs c reset PhysicalDefenseMode',
        'bind %~z gs c toggle Kiting',
        'bind !c  gs c toggle SIRD',
        'bind ^c  gs c set CastingMode Tank',

        'bind ^@- gs equip defense.HPdown',
        'bind ^@= gs equip defense.HPup',

        'bind !7 gs c set StatusDefenseMode Knockback',
        'bind !8 gs c set StatusDefenseMode Charm',
        'bind !9 gs c set StatusDefenseMode Death',
        'bind !0 gs c reset StatusDefenseMode',
        'bind !- gs c set StatusDefenseMode Stun',

        'bind !^` input /ja "Elemental Sforzo" <me>',  -- (1800/7200)
        'bind !@` input /ja "Odyllic Subterfuge"',
        'bind ^@` input /ja "One for All" <me>',       -- (160/320 per)
        'bind @tab input /ja Liement <me>',            -- (450/900 per)
        'bind ^@tab input /ja Battuta <me>',           -- (450/900)
        'bind @q input /ja "Vivacious Pulse" <me>',
        'bind ^@q input /ja Embolden <me>',            -- (160/320)
        'bind ^tab input /ja Vallation <me>',          -- (450/900)
        'bind ^` input /ja Valiance <me>',             -- (450/900 per)
        'bind @` input /ja Pflug <me>',                -- (450/900)

        'bind ^4 input /ja Gambit',                    -- (640/1280)
        'bind ^5 input /ja Rayke',                     -- (640/1260)
        'bind ^6 input /ja Swipe',
        'bind ^7 input /ja Lunge',

        'bind @1 input /ja Ignis <me>',    -- fire up,    ice down
        'bind @2 input /ja Gelus <me>',    -- ice up,     wind down
        'bind @3 input /ja Flabra <me>',   -- wind up,    earth down
        'bind @4 input /ja Tellus <me>',   -- earth up,   thunder down
        'bind @5 input /ja Sulpor <me>',   -- thunder up, water down
        'bind @6 input /ja Unda <me>',     -- water up,   fire down
        'bind @7 input /ja Lux <me>',      -- light up,   dark down
        'bind @8 input /ja Tenebrae <me>', -- dark up,    light down

        'bind ^@1 input /ja Barfire <me>',
        'bind ^@2 input /ja Barblizzard <me>',
        'bind ^@3 input /ja Baraero <me>',
        'bind ^@4 input /ja Barstone <me>',
        'bind ^@5 input /ja Barthunder <me>',
        'bind ^@6 input /ja Barwater <me>',

        'bind !@1 input /ja Baramnesia <me>',
        'bind !@2 input /ja Barparalyze <me>',
        'bind !@3 input /ja Barsilence <me>',
        'bind !@4 input /ja Barpetrify <me>',
        'bind !@5 input /ja Barvirus <me>',
        'bind !@6 input /ja Barpoison <me>',
        'bind !@7 input /ja Barsleep <me>',
        'bind !@8 input /ja Barblind <me>',

        'bind !1 input /ma Flash',             -- (180/1280)
        'bind !2 input /ma Flash <stnpc>',     -- (180/1280)
        'bind !3 input /ja Swordplay <me>',    -- (160/320)
        'bind !d input /ma Foil <me>',         -- (320/880)
        'bind @d cancel Foil',
        'bind !@d cancel Foil,Valiance,Vallation,Fast Cast,Liement,Pflug', -- for vinipata

        'bind !f input /ma Refresh <me>',
        'bind @f input /ma Crusade <me>',      -- enm+30
        'bind !g input /ma Phalanx <me>',
        'bind @g gs equip PhalanxIncoming',
        'bind !@g input /ma Stoneskin <me>',
        'bind @c input /ma Blink <me>',
        'bind @v input /ma Aquaveil <me>',
        'bind !b input /ma Temper <me>',

        'bind !w  gs c reset OffenseMode',
        'bind !@w gs c set   OffenseMode None',
        'bind ^\\\\ gs c toggle WSMsg'}

    if     player.sub_job == 'DRK' then
        bind_command_list:extend(L{
            'bind ^1 input /ma Stun',                          -- (180/1280)
            'bind ^2 input /ma Stun <stnpc>',                  -- (180/1280)
            'bind ^3 input /ma Poisonga',                      -- (1/320)
            'bind ~^3 input /ma Poisonga <stnpc>',
            'bind !e  input /ma Absorb-TP',
            'bind !^d input /ja "Weapon Bash"',                -- (1/900)
            'bind !4 input /ja "Last Resort" <me>',            -- (1/1300)
            'bind !5 input /ja Souleater <me>',                -- (1/1300)
            'bind !6 input /ja "Arcane Circle" <me>'})
    elseif player.sub_job == 'WAR' then
        bind_command_list:extend(L{
            'bind ^1 input /ja Provoke',                       -- (1/1800)
            'bind ^2 input /ja Provoke <stnpc>',               -- (1/1800)
            'bind ^3 input /ja Defender <me>',
            'bind !4 input /ja Berserk <me>',
            'bind !5 input /ja Aggressor <me>',
            'bind !6 input /ja Warcry <me>'})                   -- (1/300 per)
    elseif player.sub_job == 'SAM' then
        bind_command_list:extend(L{
            'bind ^1 input /ja Hasso <me>',
            'bind ^2 input /ja Seigan <me>',
            'bind ^3 input /ja "Third Eye" <me>',
            'bind !4 input /ja Meditate <me>',
            'bind !5 input /ja Sekkanoki <me>',
            'bind !6 input /ja "Warding Circle" <me>'})
    elseif player.sub_job == 'NIN' then
        bind_command_list:extend(L{
            'bind !e input /ma "Utsusemi: Ni" <me>',
            'bind !@e input /ma "Utsusemi: Ichi" <me>'})
    elseif player.sub_job == 'RDM' then
        bind_command_list:extend(L{
            'bind ^1  input /ma Sneak',
            'bind ~^1 input /ma Invisible',
            'bind ^2  input /ma Dispel',
            'bind ~^2 input /ma Dispel <stnpc>',
            'bind ^3  input /ma Sleep',
            'bind ~^3 input /ma Sleep <stnpc>'})
    elseif player.sub_job == 'SCH' then
        bind_command_list:extend(L{
            'bind ^1  input /ma Sneak',
            'bind ~^1 input /ma Invisible',
            'bind ^2  input /ma Dispel',
            'bind ~^2 input /ma Dispel <stnpc>',
            'bind ^3  input /ma Sleep',
            'bind ~^3 input /ma Sleep <stnpc>',
            'bind !4  input /ma "Cure III" <stpc>', -- Cure IV at ML30
            'bind !5  input /ma Erase <me>',
            'bind !6  input /ja Sublimation <me>',
            'bind @e   gs c scholar light',
            'bind !e   gs c scholar dark',
            'bind !@q  gs c scholar speed',
            'bind ~!@q gs c scholar cost',
            'bind !@e  gs c scholar aoe',
            'bind ~!@e gs c scholar power'})
    elseif player.sub_job == 'DNC' then
        bind_command_list:extend(L{
            'bind ^1 input /ja "Animated Flourish"',           -- (1/1000-1500)
            'bind ^2 input /ja "Animated Flourish" <stnpc>',   -- (1/1000-1500)
            'bind ^3 input /ja "Reverse Flourish" <me>',
            'bind !4 input /ja "Curing Waltz III" <me>',
            'bind !5 input /ja "Haste Samba" <me>',
            'bind !6 input /ja "Divine Waltz" <me>',
            'bind !^d input /ja "Violent Flourish"',
            'bind !v input /ja "Spectral Jig" <me>',
            'bind !e input /ja "Box Step"',
            'bind !@e input /ja Quickstep'})
    elseif player.sub_job == 'BLU' then
        bind_command_list:extend(L{
            'bind ^1 input /ma "Frightful Roar"',              -- (320/320), 6', 2s
            'bind ^2 input /ma "Geist Wall"',                  -- (320/320), 6', 3s
            'bind ^3 input /ma "Sheep Song"',                  -- (320/320), 6', 3s
            'bind !4 input /ma Cocoon <me>',
            'bind !5 input /ma Refueling <me>',
            -- wild carrot aliased to //wc
            'bind !6 input /ma "Healing Breeze" <me>',
            'bind !e input /ma "Blank Gaze"',                  -- (320/320), 12'
            'bind !@e input /ma Jettatura'})                   -- (180/1020), 9'
    end

    return bind_command_list
end

function triple_rune_string(spell)
    -- returns '<Element>' if three like runes are active, else nil
    for rune in runes:it() do
        if buffactive[rune] == 3 then
            return elements.rune_element_of[rune]
        end
    end
    return nil
end

function init_state_text()
    if hud then return end

    local sird_text_settings  = {flags={draggable=false},bg={blue=150,green=150,alpha=150},text={stroke={width=2}}}
    local hyb_text_settings   = {pos={x=130,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local def_text_settings   = {pos={x=172,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local off_text_settings   = {pos={x=172,y=697},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}

    hud = {texts=T{}}
    hud.texts.sird_text = texts.new('SIRD',           sird_text_settings)
    hud.texts.hyb_text  = texts.new('initializing..', hyb_text_settings)
    hud.texts.def_text  = texts.new('initializing..', def_text_settings)
    hud.texts.off_text  = texts.new('initializing..', off_text_settings)

    -- update infrequently changing text boxes in job_state_change or where they are changed
    function hud_update_on_state_change(stateField)
        if not hud then init_state_text() end

        if not stateField or stateField == 'SIRD Casting' then
            hud.texts.sird_text:visible(state.SIRD.value)
        end

        if not stateField or stateField == 'Hybrid Mode' then
            if state.HybridMode.value ~= 'Normal' then
                hud.texts.hyb_text:text('/%s':format(state.HybridMode.value))
                hud.texts.hyb_text:show()
            else hud.texts.hyb_text:hide() end
        end

        if not stateField or stateField:endswith('Defense Mode') then
            if state.DefenseMode.value ~= 'None' then
                local defMode = state[state.DefenseMode.value..'DefenseMode'].current
                if state.StatusDefenseMode.value == 'None' then
                    hud.texts.def_text:text('(%s)':format(defMode))
                else
                    hud.texts.def_text:text('(%s/%s)':format(defMode, state.StatusDefenseMode.value))
                end
                hud.texts.def_text:show()
            elseif state.StatusDefenseMode.value ~= 'None' then
                hud.texts.def_text:text('(/%s)':format(state.StatusDefenseMode.value))
                hud.texts.def_text:show()
            else hud.texts.def_text:hide() end
        end

        if not stateField or stateField == 'Offense Mode' or stateField == 'Combat Weapon' then
            if state.OffenseMode.value == 'None' then
                hud.texts.off_text:text('NoTP')
                hud.texts.off_text:show()
            elseif not state.CombatWeapon.value:startswith('Epeo') then
                hud.texts.off_text:text(state.CombatWeapon.value)
                hud.texts.off_text:show()
            else hud.texts.off_text:hide() end
        end
    end
end
