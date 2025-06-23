-- Modified from 'https://github.com/Kinematics/GearSwap-Jobs/blob/master/BLM.lua'
-- TODO more ambu capes (melee, phys.ws, ma.ws)

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
    enable('main','sub','range','ammo','head','neck','ear1','ear2','body','hands','ring1','ring2','back','waist','legs','feet')
    state.Buff['Mana Wall'] = buffactive['Mana Wall'] or false
    state.Buff['Manawell'] = buffactive['Manawell'] or false
    state.Buff['Manafont'] = buffactive['Manafont'] or false
    state.Buff['Elemental Seal'] = buffactive['Elemental Seal'] or false
    state.Buff['Light Arts']      = buffactive['Light Arts'] or false
    state.Buff['Addendum: White'] = buffactive['Addendum: White'] or false
    state.Buff['Dark Arts']       = buffactive['Dark Arts'] or false
    state.Buff['Addendum: Black'] = buffactive['Addendum: Black'] or false
    state.Buff['Sublimation: Activated'] = buffactive['Sublimation: Activated'] or false
    state.Buff.doom = buffactive.doom or false
    state.Buff.sleep = buffactive.sleep or false

    logout_event_id = windower.raw_register_event('logout', destroy_state_text)
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
    state.OffenseMode:options('None','Normal')                      -- Cycle with F9, locks current weapon
    state.HybridMode:options('Normal','PDef')                       -- Cycle with ^F9
    state.CastingMode:options('Normal','MAcc')                      -- Cycle with F10, set with !c, ^c
    state.IdleMode:options('Normal','MRf')                          -- Cycle with F11
    state.MagicalDefenseMode:options('MaxMP','MDT')                 -- Cycle with @z
    state.CombatWeapon = M{['description']='Combat Weapon'}
    state.CombatWeapon:options('Laev','LaevK','Marin','MarinK','Pole','Dagger')

    state.MWLock     = M(true,  'Mana Wall Locks') -- Toggle with ~^c
    state.SphereIdle = M(false, 'Sphere Idle')     -- Toggle with ^z
    state.MagicBurst = M(false, 'MB Mode')         -- Toggle with !z, %z
    state.MBSingle   = M(false, 'MB (1)')          -- Toggle with %c (precasts without quick magic)
    state.OANuke     = M(false, 'OA Mode')         -- Toggle with ~^z
    state.OASingle   = M(false, 'OA (1)')          -- Toggle with %~z
    state.Spaekona   = M(false, 'Spaekona')        -- Toggle with !@z
    state.AutoSpaek  = M(true,  'Spaekona Auto')   -- Toggle with ~!@z
    state.AutoSpaek.low_mp = 750
    state.cumulative_magic_status = T{}
    init_state_text()
    hud_update_on_state_change()

    -- Augmented items get variables for convenience and specificity
    gear.NukeCape  = {name="Taranus's Cape", augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','"Mag.Atk.Bns."+10'}}
    gear.DeathCape = {name="Taranus's Cape", augments={'MP+60','Mag. Acc+20 /Mag. Dmg.+20','"Fast Cast"+10'}, priority=60}
    gear.FCCape    = {name="Taranus's Cape", augments={'MP+60','Eva.+20 /Mag. Eva.+20','"Fast Cast"+10'}, priority=80}

    gear.mer_head_rf   = {name="Merlinic Hood", augments={'"Refresh"+2'}, priority=56}
    gear.mer_body_oa   = {name="Merlinic Jubbah", augments={'"Occult Acumen"+11'}}
    gear.mer_hand_rf   = {name="Merlinic Dastanas", augments={'"Refresh"+2'}}
    gear.mer_hand_oa   = {name="Merlinic Dastanas", augments={'"Occult Acumen"+11'}}
    gear.mer_hand_phlx = {name="Merlinic Dastanas", augments={'Phalanx +3'}}
    gear.mer_legs_rf   = {name="Merlinic Shalwar", augments={'"Refresh"+2'}, priority=44}
    gear.mer_legs_th   = {name="Merlinic Shalwar", augments={'"Treasure Hunter"+2'}, priority=44}
    gear.mer_feet_rf   = {name="Merlinic Crackows", augments={'"Refresh"+2'}}
    gear.mer_feet_oa   = {name="Merlinic Crackows", augments={'"Occult Acumen"+11'}}
    gear.mer_feet_fc   = {name="Merlinic Crackows", augments={'"Fast Cast"+7'}}
    gear.tel_head_enh  = {name="Telchine Cap", augments={'Enh. Mag. eff. dur. +10'}, priority=32}
    gear.tel_body_enh  = {name="Telchine Chas.", augments={'Enh. Mag. eff. dur. +10'}, priority=59}
    gear.tel_hand_enh  = {name="Telchine Gloves", augments={'Enh. Mag. eff. dur. +10'}, priority=44}
    gear.tel_legs_enh  = {name="Telchine Braconi", augments={'Enh. Mag. eff. dur. +10'}}
    gear.tel_feet_enh  = {name="Telchine Pigaches", augments={'Enh. Mag. eff. dur. +10'}, priority=44}

    -- High MP items get tagged with priorities
    gear.mp = {}
    gear.mp["Acuity Belt +1"] = 35
    gear.mp["Agwu's Gages"] = 73
    gear.mp["Agwu's Pigaches"] = 44
    gear.mp["Amalric Coif +1"] = 141
    gear.mp["Amalric Gages +1"] = 26
    gear.mp["Amalric Nails +1"] = 105
    gear.mp["Amalric Slops +1"] = 185
    gear.mp["Andoaa Earring"] = 30
    gear.mp["Archmage's Coat +3"] = 79
    gear.mp["Archmage's Gloves +2"] = 34
    gear.mp["Archmage's Petasos +3"] = 52
    gear.mp["Archmage's Sabots +2"] = 34
    gear.mp["Archmage's Tonban +3"] = 85
    gear.mp["Aurist's Cape +1"] = 45
    gear.mp["Bane Cape"] = 90
    gear.mp["Barkarole Earring"] = 25
    gear.mp["Calamitous Earring"] = 15
    gear.mp["Chrysopoeia Torque"] = 30
    gear.mp["Ea Hat +1"] = 65
    gear.mp["Ea Houppelande +1"] = 109
    gear.mp["Ea Slops +1"] = 100
    gear.mp["Etana Ring"] = 60
    gear.mp["Etiolation Earring"] = 50
    gear.mp["Fi Follet Cape"] = 40
    gear.mp["Fucho-no-Obi"] = 30
    gear.mp["Ghastly Tathlum +1"] = 35
    gear.mp["Gifted Earring"] = 45
    gear.mp["Gyve Doublet"] = 129
    gear.mp["Hike Khat +1"] = 50
    gear.mp["Izdubar Mantle"] = 25
    gear.mp["Kuchekula Ring"] = 15
    gear.mp["Lebeche Ring"] = 40
    gear.mp["Luminary Sash"] = 45
    gear.mp["Mallquis Saio +2"] = 53
    gear.mp["Mediator's Ring"] = 25
    gear.mp["Medium's Sabots"] = 30
    gear.mp["Mendicant's Earring"] = 30
    gear.mp["Mephitas's Ring"] = 110
    gear.mp["Metamorph Ring +1"] = 60
    gear.mp["Nahtirah Hood"] = 70
    gear.mp["Nodens Gorget"] = 25
    gear.mp["Nodens Gorget"] = 25
    gear.mp["Null Masque"] = 70
    gear.mp["Nyame Flanchard"] = 59
    gear.mp["Nyame Gauntlets"] = 73
    gear.mp["Nyame Helm"] = 59
    gear.mp["Nyame Mail"] = 88
    gear.mp["Nyame Sollerets"] = 44
    gear.mp["Odnowa Earring +1"] = -110
    gear.mp["Perdition Slops"] = 59
    gear.mp["Persis Ring"] = 80
    gear.mp["Pixie Hairpin +1"] = 120
    gear.mp["Porous Rope"] = 20
    gear.mp["Psilomene"] = 45
    gear.mp["Psycloth Lappas"] = 109
    gear.mp["Regal Earring"] = 20
    gear.mp["Regal Pumps +1"] = 39
    gear.mp["Sanctity Necklace"] = 35
    gear.mp["Sangoma Ring"] = 70
    gear.mp["Shamash Robe"] = 88
    gear.mp["Shinjutsu-no-Obi +1"] = 85
    gear.mp["Shrieker's Cuffs"] = 59
    gear.mp["Spaekona's Coat +3"] = 98
    gear.mp["Spaekona's Gloves +3"] = 106
    gear.mp["Spaekona's Petasos +2"] = 48
    gear.mp["Spaekona's Sabots +3"] = 43
    gear.mp["Spaekona's Tonban +3"] = 158
    gear.mp["Supershear Ring"] = 30
    gear.mp["Tantalic Cape"] = 50
    gear.mp["Thaumaturge's Cape"] = 25
    gear.mp["Twilight Cape"] = 25
    gear.mp["Vanya Hood"] = 82
    gear.mp["Vanya Robe"] = 109
    gear.mp["Volte Bracers"] = 59
    gear.mp["Orunmila's Torque"] = 30
    gear.mp["Wicce Chausses +3"] = 119
    gear.mp["Wicce Coat +3"] = 132
    gear.mp["Wicce Gloves +3"] = 50
    gear.mp["Wicce Petasos +3"] = 86
    gear.mp["Wicce Sabots +3"] = 50
    gear.mp["Zendik Robe"] = 61
    gear.mp["Zodiac Ring"] = 25
    for k, v in pairs(gear.mp) do
        gear.mp[k] = {name = k, priority = v}
    end

    gear.slots = S{'main','sub','range','ammo','head','neck','ear1','ear2','body','hands','ring1','ring2','back','waist','legs','feet'}

    function prioritize(set)
        for k, v in pairs(set) do
            if gear.slots[k] and gear.mp[v] then
                set[k] = gear.mp[v]
            end
        end
        return set
    end

    info.keybinds = make_keybind_list(job_keybinds())
    info.keybinds:bind()

    info.ws_binds = make_keybind_list(T{
        ['Staff']=L{
            'bind %1 input /ws "Shell Crusher"',
            'bind %2 input /ws "Vidohunir"',
            'bind %3 input /ws "Shattersoul"',
            'bind !^1 input /ws "Shell Crusher"',
            'bind !^2 input /ws "Vidohunir"',
            'bind !^3 input /ws "Shattersoul"',
            'bind !^4 input /ws "Rock Crusher"',
            'bind !^5 input /ws "Starburst"',
            'bind !^6 input /ws "Cataclysm"',
            'bind !@e input /ws "Myrkr"'},
        ['Dagger']=L{
            'bind %1 input /ws "Energy Drain"',
            'bind %2 input /ws "Wasp Sting"',
            'bind %3 input /ws "Gust Slash"',
            'bind !^1 input /ws "Energy Drain"',
            'bind !^2 input /ws "Wasp Sting"',
            'bind !^3 input /ws "Gust Slash"',
            'bind !^4 input /ws "Shadowstitch"',
            'bind !^6 input /ws "Aeolian Edge"'}},
        {['Marin']='Staff',['MarinK']='Staff',['Laev']='Staff',['LaevK']='Staff',['Pole']='Staff',['Dagger']='Dagger'})
    info.ws_binds:bind(state.CombatWeapon)
    send_command('bind %\\\\ gs c ListWS')

    info.recast_ids = L{{name="Mana Wall",id=39},{name="Douse",id=34},{name="MWell",id=35}}
    if     player.sub_job == 'RDM' then
        info.recast_ids:append({name="Convert",id=49})
    elseif player.sub_job == 'WHM' then
        info.recast_ids:append({name="D.Seal",id=26})
    elseif player.sub_job == 'SCH' then
        info.recast_ids:append({name="Strats",id=231})
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
    sets.weapons.Laev   = {main="Laevateinn",sub="Enki Strap"}
    sets.weapons.LaevK  = {main="Laevateinn",sub="Khonsu"}
    sets.weapons.Marin  = {main="Marin Staff +1",sub="Enki Strap"}
    sets.weapons.MarinK = {main="Marin Staff +1",sub="Khonsu"}
    sets.weapons.Pole   = {main="Malignance Pole",sub="Khonsu"}
    sets.weapons.Dagger = {main="Malevolence",sub="Ammurapi Shield"}

    sets.manawall = prioritize({feet="Wicce Sabots +3"})
    sets.TreasureHunter = {ammo="Perfect Lucky Egg",waist="Chaac Belt",legs=gear.mer_legs_th}

    ---- Precast Sets ----
    sets.precast.JA['Mana Wall'] = sets.manawall

    sets.precast.FC = prioritize({main="Oranyan",sub="Clerisy Strap",ammo="Impatiens",
        head="Amalric Coif +1",neck="Orunmila's Torque",ear1="Malignance Earring",ear2="Etiolation Earring",
        body="Zendik Robe",hands="Agwu's Gages",ring1="Lebeche Ring",ring2="Medada's Ring",
        back=gear.FCCape,waist="Witful Belt",legs="Psycloth Lappas",feet=gear.mer_feet_fc})
    -- ML10/sch: 1871 mp, qm+7
    sets.precast.FC.MaxMP = prioritize({ammo="Psilomene",
        head="Amalric Coif +1",neck="Orunmila's Torque",ear1="Malignance Earring",ear2="Etiolation Earring",
        body="Zendik Robe",hands="Agwu's Gages",ring1="Kishar Ring",ring2="Medada's Ring",
        back=gear.FCCape,waist="Shinjutsu-no-Obi +1",legs="Psycloth Lappas",feet="Amalric Nails +1"})
    -- ML10/sch: 2047 mp, qm removed
    sets.precast.FC['Elemental Magic'] = prioritize({ammo="Impatiens",
        head="Amalric Coif +1",neck="Orunmila's Torque",ear1="Malignance Earring",ear2="Etiolation Earring",
        body="Zendik Robe",hands="Agwu's Gages",ring1="Lebeche Ring",ring2="Medada's Ring",
        back="Perimede Cape",waist="Witful Belt",legs="Psycloth Lappas",feet="Amalric Nails +1"})
    -- ML10/sch: 1877 mp, qm+10
    sets.precast.FC['Elemental Magic'].MaxMP = set_combine(sets.precast.FC['Elemental Magic'].MaxMP,
        prioritize({ammo="Psilomene",ring1="Etana Ring",back=gear.FCCape,waist="Shinjutsu-no-Obi +1"}))
    -- ML10/sch: 2022 mp, qm removed
    sets.impact = {head=empty,body="Twilight Cloak"}
    sets.precast.FC.Impact = set_combine(sets.precast.FC['Elemental Magic'],
        prioritize({waist="Shinjutsu-no-Obi +1"}), sets.impact)
    -- ML10/sch: 1835 mp, qm+8
    sets.precast.FC.Impact.MaxMP = set_combine(sets.precast.FC['Elemental Magic'].MaxMP,
        prioritize({ring1="Mephitas's Ring +1"}), sets.impact)
    -- ML10/sch: 2030 mp, qm removed
    sets.precast.FC.Death = set_combine(sets.precast.FC, {})
    sets.precast.FC.Death.MaxMP = set_combine(sets.precast.FC.MaxMP, {})
    sets.dispelga = {main="Daybreak",sub="Culminus"}
    sets.precast.FC.Dispelga = set_combine(sets.precast.FC, sets.dispelga)

    sets.precast.WS = prioritize({ammo="Oshasha's Treatise",
        head="Blistering Sallet +1",neck="Fotia Gorget",ear1="Telos Earring",ear2="Dignitary's Earring",
        body="Wicce Coat +3",hands="Jhakri Cuffs +2",ring1="Chirich Ring +1",ring2="Rufescent Ring",
        back="Null Shawl",waist="Fotia Belt",legs="Wicce Chausses +3",feet="Wicce Sabots +3"})

    sets.precast.WS['Rock Crusher'] = prioritize({ammo="Oshasha's Treatise",
        head="Wicce Petasos +3",neck="Sibyl Scarf",ear1="Malignance Earring",ear2="Wicce Earring +2",
        body="Wicce Coat +3",hands="Wicce Gloves +3",ring1="Freke Ring",ring2="Medada's Ring",
        back=gear.NukeCape,waist="Orpheus's Sash",legs="Wicce Chausses +3",feet="Wicce Sabots +3"})
    sets.precast.WS['Earth Crusher'] = set_combine(sets.precast.WS['Rock Crusher'],  {ear1="Moonshade Earring"})
    sets.precast.WS.Starburst        = set_combine(sets.precast.WS['Earth Crusher'], {})
    sets.precast.WS.Sunburst         = set_combine(sets.precast.WS.Starburst,        {})
    sets.precast.WS.Vidohunir        = set_combine(sets.precast.WS['Rock Crusher'],  prioritize({head="Pixie Hairpin +1",ring1="Archon Ring"}))
    sets.precast.WS.Vidohunir.MaxMP  = prioritize({ammo="Psilomene",
        head="Pixie Hairpin +1",neck="Sanctity Necklace",ear1="Regal Earring",ear2="Wicce Earring +2",
        body="Wicce Coat +3",hands="Amalric Gages +1",ring1="Mephitas's Ring +1",ring2="Archon Ring",
        back=gear.DeathCape,waist="Shinjutsu-no-Obi +1",legs="Amalric Slops +1",feet="Amalric Nails +1"})
    sets.precast.WS.Cataclysm        = set_combine(sets.precast.WS.Vidohunir,        {ear2="Moonshade Earring"})
    sets.precast.WS['Aeolian Edge']  = set_combine(sets.precast.WS['Earth Crusher'], {})

    sets.precast.WS['Shell Crusher'] = prioritize({ammo="Amar Cluster",
        head="Blistering Sallet +1",neck="Null Loop",ear1="Dignitary's Earring",ear2="Crepuscular Earring",
        body="Wicce Coat +3",hands="Gazu Bracelets +1",ring1="Chirich Ring +1",ring2="Medada's Ring",
        back="Null Shawl",waist="Null Belt",legs="Wicce Chausses +3",feet="Wicce Sabots +3"})
    sets.precast.WS.Brainshaker = set_combine(sets.precast.WS['Shell Crusher'], {})

    sets.precast.WS.Myrkr = prioritize({ammo="Psilomene",
        head="Amalric Coif +1",neck="Sanctity Necklace",ear1="Moonshade Earring",ear2="Etiolation Earring",
        body="Wicce Coat +3",hands="Spaekona's Gloves +3",ring1="Mephitas's Ring +1",ring2="Persis Ring",
        back="Bane Cape",waist="Shinjutsu-no-Obi +1",legs="Amalric Slops +1",feet="Amalric Nails +1"})

    ---- Midcast Sets ----
    sets.midcast.Cure = prioritize({main="Malignance Pole",sub="Khonsu",ammo="Pemphredo Tathlum",
        head="Vanya Hood",neck="Loricate Torque +1",ear1="Calamitous Earring",ear2="Etiolation Earring",
        body="Nyame Mail",hands=gear.tel_hand_enh,ring1="Shneddick Ring +1",ring2="Defending Ring",
        back="Solemnity Cape",waist="Shinjutsu-no-Obi +1",legs="Gyve Trousers",feet="Vanya Clogs"})
    sets.midcast.Curaga = sets.midcast.Cure
    sets.midcast.Cursna = prioritize({main="Malignance Pole",sub="Khonsu",ammo="Sapience Orb",
        head="Hike Khat +1",neck="Malison Medallion",ear1="Lugalbanda Earring",ear2="Etiolation Earring",
        body="Zendik Robe",hands="Gazu Bracelets +1",ring1="Ephedra Ring",ring2="Menelaus's Ring",
        back=gear.DeathCape,waist="Embla Sash",legs="Gyve Trousers",feet="Vanya Clogs"})
    sets.cmp_belt  = prioritize({waist="Shinjutsu-no-Obi +1"})
    sets.gishdubar = prioritize({waist="Gishdubar Sash"})

    sets.midcast.EnhancingDuration = prioritize({main="Gada",sub="Ammurapi Shield",ammo="Psilomene",
        head=gear.tel_head_enh,neck="Sanctity Necklace",ear1="Gifted Earring",ear2="Etiolation Earring",
        body=gear.tel_body_enh,hands=gear.tel_hand_enh,ring1="Mephitas's Ring +1",ring2="Persis Ring",
        back=gear.FCCape,waist="Embla Sash",legs=gear.tel_legs_enh,feet=gear.tel_feet_enh})
    sets.midcast['Enhancing Magic'] = set_combine(sets.midcast.EnhancingDuration, prioritize({
        head="Befouled Crown",neck="Incanter's Torque",ear1="Mimir Earring",ear2="Andoaa Earring",
        body=gear.tel_body_enh,hands="Ayao's Gages",ring1="Stikini Ring +1",
        back="Fi Follet Cape",waist="Olympus Sash",feet="Regal Pumps +1"}))
    sets.midcast.Phalanx = set_combine(sets.midcast['Enhancing Magic'], {hands=gear.mer_hand_phlx})
    sets.midcast.Stoneskin = set_combine(sets.midcast.EnhancingDuration, {
        neck="Nodens Gorget",ear2="Earthcry Earring",waist="Siegel Sash",legs="Shedir Seraweels"})
    sets.midcast.Aquaveil  = set_combine(sets.midcast.EnhancingDuration, {main="Vadose Rod",sub="Ammurapi Shield",
        head="Amalric Coif +1",waist="Emphatikos Rope",legs="Shedir Seraweels"})
    sets.midcast.Regen   = set_combine(sets.midcast.EnhancingDuration, {main="Bolelabunga",sub="Ammurapi Shield"})
    sets.midcast.Refresh = set_combine(sets.midcast.EnhancingDuration, prioritize({head="Amalric Coif +1"}))
    sets.self_refresh = prioritize({back="Grapevine Cape",waist="Gishdubar Sash",feet="Inspirited Boots"})
    sets.midcast.FixedPotencyEnhancing = sets.midcast.EnhancingDuration
    -- ML10/sch: 1920 mp
    sets.midcast.Klimaform = {}

    sets.midcast['Elemental Magic'] = prioritize({main="Marin Staff +1",sub="Enki Strap",ammo="Ghastly Tathlum +1",
        head="Wicce Petasos +3",neck="Sorcerer's Stole +2",ear1="Malignance Earring",ear2="Wicce Earring +2",
        body="Wicce Coat +3",hands="Wicce Gloves +3",ring1="Freke Ring",ring2="Medada's Ring",
        back=gear.NukeCape,waist="Sacro Cord",legs="Wicce Chausses +3",feet="Wicce Sabots +3"})
    sets.midcast['Elemental Magic'].MAcc  = set_combine(sets.midcast['Elemental Magic'], prioritize({
        ring1="Metamorph Ring +1",waist="Acuity Belt +1"}))
    sets.midcast['Elemental Magic'].LowMP = set_combine(sets.midcast['Elemental Magic'], prioritize({body="Spaekona's Coat +3"}))
    sets.midcast['Elemental Magic'].OA = prioritize({ammo="Seraphic Ampulla",
        head="Mallquis Chapeau +2",neck="Sorcerer's Stole +2",ear1="Telos Earring",ear2="Crepuscular Earring",
        body="Spaekona's Coat +3",hands=gear.mer_hand_oa,ring1="Chirich Ring +1",ring2="Medada's Ring",
        back=gear.NukeCape,waist="Oneiros Rope",legs="Perdition Slops",feet=gear.mer_feet_oa})

    sets.midcast['Elemental Magic'].MB = prioritize({main="Marin Staff +1",sub="Enki Strap",ammo="Ghastly Tathlum +1",
        head="Ea Hat +1",neck="Sorcerer's Stole +2",ear1="Malignance Earring",ear2="Wicce Earring +2",
        body="Ea Houppelande +1",hands="Amalric Gages +1",ring1="Mujin Band",ring2="Medada's Ring",
        back=gear.NukeCape,waist="Sacro Cord",legs="Ea Slops +1",feet="Wicce Sabots +3"})
    sets.midcast['Elemental Magic'].MAcc.MB  = set_combine(sets.midcast['Elemental Magic'].MB, prioritize({
        sub="Khonsu",ear1="Regal Earring",hands="Spaekona's Gloves +3",ring1="Metamorph Ring +1",waist="Acuity Belt +1"}))
    sets.midcast['Elemental Magic'].LowMP.MB = set_combine(sets.midcast['Elemental Magic'].MB, prioritize({
        body="Spaekona's Coat +3",hands="Archmage's Gloves +3"}))

    sets.midcast.LowTierNuke = prioritize({main="Bunzi's Rod",sub="Culminus",ammo="Ghastly Tathlum +1",
        head="Wicce Petasos +3",neck="Sorcerer's Stole +2",ear1="Malignance Earring",ear2="Wicce Earring +2",
        body="Wicce Coat +3",hands="Wicce Gloves +3",ring1="Freke Ring",ring2="Medada's Ring",
        back=gear.NukeCape,waist="Sacro Cord",legs="Wicce Chausses +3",feet="Wicce Sabots +3"})
    sets.midcast.LowTierNuke.MAcc    = set_combine(sets.midcast.LowTierNuke, {})
    sets.midcast.LowTierNuke.MB      = set_combine(sets.midcast['Elemental Magic'].MB, {})
    sets.midcast.LowTierNuke.MAcc.MB = set_combine(sets.midcast['Elemental Magic'].MAcc.MB, {})

    sets.midcast.CumulativeMagic          = set_combine(sets.midcast['Elemental Magic'],          prioritize({legs="Wicce Chausses +3"}))
    sets.midcast.CumulativeMagic.MAcc     = set_combine(sets.midcast['Elemental Magic'].MAcc,     prioritize({legs="Wicce Chausses +3"}))
    sets.midcast.CumulativeMagic.LowMP    = set_combine(sets.midcast['Elemental Magic'].LowMP,    prioritize({legs="Wicce Chausses +3"}))
    sets.midcast.CumulativeMagic.OA       = set_combine(sets.midcast['Elemental Magic'].OA,       prioritize({legs="Wicce Chausses +3"}))
    sets.midcast.CumulativeMagic.MB       = set_combine(sets.midcast['Elemental Magic'].MB,       prioritize({legs="Wicce Chausses +3"}))
    sets.midcast.CumulativeMagic.MAcc.MB  = set_combine(sets.midcast['Elemental Magic'].MAcc.MB,  prioritize({legs="Wicce Chausses +3"}))
    sets.midcast.CumulativeMagic.LowMP.MB = set_combine(sets.midcast['Elemental Magic'].LowMP.MB, prioritize({legs="Wicce Chausses +3"}))

    sets.midcast.Comet          = set_combine(sets.midcast.CumulativeMagic,          prioritize({head="Pixie Hairpin +1",ring1="Archon Ring"}))
    sets.midcast.Comet.MAcc     = set_combine(sets.midcast.CumulativeMagic.MAcc,     prioritize({head="Pixie Hairpin +1",ring1="Archon Ring"}))
    sets.midcast.Comet.LowMP    = set_combine(sets.midcast.CumulativeMagic.LowMP,    prioritize({head="Pixie Hairpin +1",ring1="Archon Ring"}))
    sets.midcast.Comet.OA       = set_combine(sets.midcast.CumulativeMagic.OA,       prioritize({head="Pixie Hairpin +1"}))
    sets.midcast.Comet.MB       = set_combine(sets.midcast.CumulativeMagic.MB,       prioritize({
        head="Pixie Hairpin +1",ring2="Archon Ring"}))
    sets.midcast.Comet.MAcc.MB  = set_combine(sets.midcast.CumulativeMagic.MAcc.MB,  prioritize({ring1="Archon Ring"}))
    sets.midcast.Comet.LowMP.MB = set_combine(sets.midcast.CumulativeMagic.LowMP.MB, prioritize({head="Pixie Hairpin +1",ring2="Archon Ring"}))

    sets.midcast.Impact = prioritize({main="Laevateinn",sub="Enki Strap",ammo="Ghastly Tathlum +1",
        head=empty,neck="Sorcerer's Stole +2",ear1="Malignance Earring",ear2="Wicce Earring +2",
        body="Twilight Cloak",hands="Spaekona's Gloves +3",ring1="Metamorph Ring +1",ring2="Medada's Ring",
        back=gear.NukeCape,waist="Acuity Belt +1",legs="Wicce Chausses +3",feet="Wicce Sabots +3"})
    sets.midcast.Impact.OA = set_combine(sets.midcast['Elemental Magic'].OA, sets.impact)
    sets.midcast.Impact.MB = set_combine(sets.midcast.Impact, prioritize({hands="Archmage's Gloves +3"}))

    sets.midcast.Death = prioritize({main="Laevateinn",sub="Khonsu",ammo="Psilomene",
        head="Pixie Hairpin +1",neck="Sorcerer's Stole +2",ear1="Malignance Earring",ear2="Static Earring",
        body="Ea Houppelande +1",hands="Archmage's Gloves +3",ring1="Archon Ring",ring2="Medada's Ring",
        back=gear.DeathCape,waist="Shinjutsu-no-Obi +1",legs="Amalric Slops +1",feet="Amalric Nails +1"})
    -- ML10/sch: 2021 mp
    sets.midcast.Death.OA = set_combine(sets.midcast['Elemental Magic'].OA, {body=gear.mer_body_oa})
    sets.midcast.Death.MAcc = set_combine(sets.midcast.Death, prioritize({
        ear2="Wicce Earring +2",ring1="Metamorph Ring +1",waist="Acuity Belt +1",feet="Wicce Sabots +3"}))

    sets.midcast.Meteor = set_combine(sets.midcast['Elemental Magic'], {main="Laevateinn",sub="Enki Strap"})

    sets.orpheus   = {waist="Orpheus's Sash"}
    sets.ele_obi   = {waist="Hachirin-no-Obi"}
    sets.nuke_belt = {waist="Sacro Cord"}
    sets.macc_belt = prioritize({waist="Acuity Belt +1"})

    sets.midcast.Drain = prioritize({main="Rubicundity",sub="Ammurapi Shield",ammo="Psilomene",
        head="Pixie Hairpin +1",neck="Erra Pendant",ear1="Regal Earring",ear2="Etiolation Earring",
        body="Spaekona's Coat +3",hands="Spaekona's Gloves +3",ring1="Archon Ring",ring2="Evanescence Ring",
        back=gear.DeathCape,waist="Fucho-no-Obi",legs="Spaekona's Tonban +3",feet="Agwu's Pigaches"})
    sets.midcast.Aspir = sets.midcast.Drain
    sets.midcast.Aspir.MAcc = set_combine(sets.midcast.Aspir, prioritize({
        head="Amalric Coif +1",ring1="Evanescence Ring",ring2="Medada's Ring",feet="Wicce Sabots +3"}))
    sets.drain_belt = prioritize({waist="Fucho-no-Obi"})

    sets.midcast['Enfeebling Magic'] = prioritize({main="Bunzi's Rod",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
        head="Wicce Petasos +3",neck="Null Loop",ear1="Regal Earring",ear2="Wicce Earring +2",
        body="Spaekona's Coat +3",hands="Spaekona's Gloves +3",ring1="Stikini Ring +1",ring2="Medada's Ring",
        back="Null Shawl",waist="Null Belt",legs="Wicce Chausses +3",feet="Wicce Sabots +3"})
    sets.midcast.Dispelga = set_combine(sets.midcast['Enfeebling Magic'], sets.dispelga)
    sets.midcast.Silence  = set_combine(sets.midcast['Enfeebling Magic'], {main="Daybreak",ring1="Kishar Ring"})
    sets.midcast.Slow     = set_combine(sets.midcast.Silence, {head="Null Masque",back="Aurist's Cape +1"})
    sets.midcast.Paralyze = sets.midcast.Slow

    sets.midcast.Sleep    = set_combine(sets.midcast['Enfeebling Magic'], {ring1="Kishar Ring"})
    sets.midcast.Repose   = sets.midcast.Silence
    sets.midcast.Break    = sets.midcast.Sleep
    sets.midcast.Bind     = sets.midcast.Sleep
    sets.midcast.Gravity  = sets.midcast.Sleep

    sets.midcast.Stun = set_combine(sets.midcast['Enfeebling Magic'], prioritize({
        head="Amalric Coif +1",body="Zendik Robe",back=gear.DeathCape,waist="Cornelia's Belt"}))
    sets.midcast.ElementalEnfeeble = prioritize({main="Bunzi's Rod",sub="Ammurapi Shield",ammo="Ghastly Tathlum +1",
        head="Wicce Petasos +3",neck="Sorcerer's Stole +2",ear1="Regal Earring",ear2="Wicce Earring +2",
        body="Spaekona's Coat +3",hands="Spaekona's Gloves +3",ring1="Metamorph Ring +1",ring2="Medada's Ring",
        back="Aurist's Cape +1",waist="Acuity Belt +1",legs="Archmage's Tonban +3",feet="Archmage's Sabots +3"})
    sets.midcast['Dark Magic'] = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast['Divine Magic'] = set_combine(sets.midcast['Enfeebling Magic'], {})

    ---- Sets to return to when not performing an action ----
    sets.idle = prioritize({main="Malignance Pole",sub="Khonsu",ammo="Crepuscular Pebble",
        head=gear.mer_head_rf,neck="Sibyl Scarf",ear1="Lugalbanda Earring",ear2="Etiolation Earring",
        body="Wicce Coat +3",hands=gear.mer_hand_rf,ring1="Shneddick Ring +1",ring2="Defending Ring",
        back=gear.FCCape,waist="Shinjutsu-no-Obi +1",legs=gear.mer_legs_rf,feet=gear.mer_feet_rf})
    -- ML10/sch: 1754 mp
	sets.idle.MRf  = set_combine(sets.idle, {ring1="Stikini Ring +1"})
    sets.idle.PDT = set_combine(sets.idle, prioritize({main="Laevateinn",sub="Oneiros Grip",
        head="Null Masque",neck="Loricate Torque +1",feet="Wicce Sabots +3"}))
    -- ML10/sch: 1814 mp
    sets.idle.MaxMP = prioritize({main="Malignance Pole",sub="Khonsu",ammo="Psilomene",
        head="Amalric Coif +1",neck="Sibyl Scarf",ear1="Gifted Earring",ear2="Etiolation Earring",
        body="Wicce Coat +3",hands=gear.mer_hand_rf,ring1="Mephitas's Ring +1",ring2="Persis Ring",
        back=gear.FCCape,waist="Shinjutsu-no-Obi +1",legs=gear.mer_legs_rf,feet=gear.mer_feet_rf})
    -- ML10/sch: 2109 mp
    sets.idle.MDT = prioritize({main="Malignance Pole",sub="Khonsu",ammo="Crepuscular Pebble",
        head="Wicce Petasos +3",neck="Warder's Charm +1",ear1="Lugalbanda Earring",ear2="Eabani Earring",
        body="Wicce Coat +3",hands="Wicce Gloves +3",ring1="Shadow Ring",ring2="Defending Ring",
        back=gear.FCCape,waist="Platinum Moogle Belt",legs="Wicce Chausses +3",feet="Wicce Sabots +3"})
    -- ML10/sch: 1784 mp
    sets.latent_refresh   = prioritize({waist="Fucho-no-obi"})
    sets.regain           = prioritize({head="Null Masque"})
    sets.sphere           = prioritize({body="Gyve Doublet"})
    sets.buff.Sublimation = {waist="Embla Sash"}
    sets.chrys_torque     = prioritize({neck="Chrysopoeia Torque"})
    sets.buff.doom        = {neck="Nicander's Necklace",ring1="Saida Ring",ring2="Defending Ring",waist="Gishdubar Sash"}
    sets.buff.sleep       = {main="Opashoro",sub="Khonsu"}

    -- Defense sets
    sets.defense.PDT   = sets.idle.PDT
    sets.defense.MDT   = sets.idle.MDT
    sets.defense.MaxMP = sets.idle.MaxMP
    sets.Kiting = {ring1="Shneddick Ring +1"}

    -- Engaged sets
    sets.engaged = prioritize({main="Malignance Pole",sub="Khonsu",ammo="Amar Cluster",
        head="Blistering Sallet +1",neck="Null Loop",ear1="Telos Earring",ear2="Crepuscular Earring",
        body="Nyame Mail",hands="Gazu Bracelets +1",ring1="Chirich Ring +1",ring2="Defending Ring",
        back="Null Shawl",waist="Null Loop",legs="Jhakri Slops +2",feet="Nyame Sollerets"})
    sets.engaged.PDef = set_combine(sets.engaged, {head="Null Masque",ring2="Defending Ring",legs="Nyame Flanchard"})

    -- Sets depending upon idle sets
    sets.midcast.FastRecast = set_combine(sets.defense.MaxMP, {})
    sets.midcast.Dia = set_combine(sets.idle.PDT, sets.TreasureHunter)
    sets.midcast.Bio = set_combine(sets.midcast.Dia, {})
    sets.midcast.Stonega = set_combine(sets.midcast.LowTierNuke, sets.TreasureHunter)
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-- Run after the general precast() is done.
function job_post_precast(spell, action, spellMap, eventArgs)
    if player.mpp > 80 and state.DefenseMode.value == 'Magical' and state.MagicalDefenseMode.value == 'MaxMP'
    or state.MBSingle.value and spell.skill == 'Elemental Magic' and spellMap ~= 'ElementalEnfeeble'
    and not (state.OASingle.value or state.OANuke.value) then
        -- no quick magic for precasted MBs
        if S{'Death','Impact'}:contains(spell.english) then
            equip(sets.precast.FC[spell.english].MaxMP)
        elseif spell.skill == 'Elemental Magic' then
            equip(sets.precast.FC['Elemental Magic'].MaxMP)
        else
            equip(sets.precast.FC.MaxMP)
        end
    end
end

-- Run after the default midcast() is done.
-- eventArgs is the same one used in job_midcast, in case information needs to be persisted.
function job_post_midcast(spell, action, spellMap, eventArgs)
    if spell.skill == 'Elemental Magic' and spellMap ~= 'ElementalEnfeeble' and spell.english ~= 'Meteor'
    or spell.english == 'Death' then
        local spell_set

        if S{'Death','Impact','Comet'}:contains(spell.english) then
            spell_set = sets.midcast[spell.english]
        elseif S{'LowTierNuke','CumulativeMagic'}:contains(spellMap) then
            spell_set = sets.midcast[spellMap]
        else
            spell_set = sets.midcast[spell.skill]
        end

        if (state.OANuke.value or state.OASingle.value)
        and spell_set.OA then
            spell_set = spell_set.OA
        elseif state.Spaekona.value and not state.Buff['Manawell'] and not state.Buff['Manafont']
        and spell_set.LowMP then
            spell_set = spell_set.LowMP
        elseif state.CastingMode.value == 'MAcc'
        and spell_set.MAcc then
            spell_set = spell_set.MAcc
        elseif state.AutoSpaek.value and not state.Buff['Manawell'] and not state.Buff['Manafont']
        and player.mp - spell.mp_cost < state.AutoSpaek.low_mp
        and spell_set.LowMP then
            spell_set = spell_set.LowMP
        end

        if (state.MagicBurst.value or state.MBSingle.value)
        and spell_set.MB then
            spell_set = spell_set.MB
        end

        equip(spell_set)

        if not state.OANuke.value and not state.OASingle.value then
            if spell.english == 'Death' then
                equip(resolve_ele_belt(spell, sets.ele_obi, sets.cmp_belt, 5))
            elseif state.CastingMode.value == 'MAcc' then
                equip(resolve_ele_belt(spell, sets.ele_obi, sets.macc_belt, 9))
            else
                equip(resolve_ele_belt(spell, sets.ele_obi, sets.nuke_belt, 3))
            end
        end
    elseif S{'Drain','Aspir'}:contains(spellMap) then
        equip(resolve_ele_belt(spell, sets.ele_obi, sets.drain_belt, 5))
    elseif S{'Cure','Curaga'}:contains(spellMap) then
        if spell.target.type == 'SELF' then
            equip(resolve_ele_belt(spell, sets.ele_obi, sets.gishdubar, 9))
        elseif spell.target.type == 'MONSTER' then
            equip(resolve_ele_belt(spell, sets.ele_obi, sets.nuke_belt, 3))
        else
            equip(resolve_ele_belt(spell, sets.ele_obi, sets.cmp_belt, 2))
        end
    elseif spell.target.type == 'SELF' then
        if spell.english == 'Refresh' then
            equip(sets.self_refresh)
        elseif spell.english == 'Cursna' then
            equip(sets.buff.doom)
        end
    end

    if (state.MWLock.value or spell.skill == 'Elemental Magic')
    and state.Buff['Mana Wall'] and spell.english ~= 'Death' then
        equip(sets.manawall)
    end
end

function job_aftercast(spell, action, spellMap, eventArgs)
    if spell.interrupted then
        --send_command('wait 0.5;gs c update')
        interrupted_message(spell)
    else
        if S{'JobAbility','Scholar'}:contains(spell.type) then
            eventArgs.handled = true
        elseif spellMap == 'CumulativeMagic' then
            cumulative_magic_timer(spell, 110)
        elseif spell.english == 'Impact' then
            debuff_timer(spell, 180)
        elseif spell.english == 'Break' or spell.english == 'Breakga' then
            debuff_timer(spell, 33)
        elseif spell.english == 'Sleep' or spell.english == 'Sleepga' then
            debuff_timer(spell, 66)
        elseif spell.english == 'Sleep II' or spell.english == 'Sleepga II' then
            debuff_timer(spell, 99)
        elseif spell.english == 'Repose' then
            debuff_timer(spell, 90)
        end

        if spell.skill == 'Elemental Magic' and spellMap ~= 'ElementalEnfeeble' and spell.english ~= 'Meteor'
        or spell.english == 'Death' then
            if state.OASingle.value then
                state.OASingle:reset()
                hud_update_on_state_change('OA (1)')
            elseif state.MBSingle.value then
                state.MBSingle:reset()
                hud_update_on_state_change('MB (1)')
            end
        end
    end
end

windower.raw_register_event('zone change', function(new_zone, old_zone)
    state.cumulative_magic_status:clear()
end)

function cumulative_magic_timer(spell, dur)
    if state.cumulative_magic_status[spell.target.id] == nil
    or state.cumulative_magic_status[spell.target.id].element ~= spell.element
    or os.time() - state.cumulative_magic_status[spell.target.id].time > dur then
        -- fresh cumulative magic application
        state.cumulative_magic_status[spell.target.id] = {element = spell.element, time = os.time()}
        debuff_timer({english='CMagic',target=spell.target}, dur)
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
    if lbuff == 'doom' and not midaction() then
        handle_equipping_gear(player.status)
    end
    if gain then
        if lbuff == 'sleep' then
            if not buffactive["Sublimation: Activated"] then
                equip(sets.buff.sleep)
            end
            if buffactive.Stoneskin then
                add_to_chat(123, 'cancelling stoneskin')
                send_command('cancel stoneskin')
            end
        end
        if info.chat_notice_buffs:contains(lbuff) then
            add_to_chat(104, 'Gained ['..buff..']')
        end
    end
end

-- Handle notifications of general user state change.
function job_state_change(stateField, newValue, oldValue)
    if stateField == 'Offense Mode' then
        enable('main','sub')
        if newValue ~= 'None' then
            equip(sets.weapons[state.CombatWeapon.value])
            disable('main','sub')
        end
        handle_equipping_gear(player.status)
    elseif stateField == 'Combat Weapon' then
        info.ws_binds:bind(state.CombatWeapon)
        if state.OffenseMode.value ~= 'None' then
            enable('main','sub')
            equip(sets.weapons[state.CombatWeapon.value])
            disable('main','sub')
        end
    elseif stateField == 'Defense Mode' then
        if newValue ~= 'None' then
            handle_equipping_gear(player.status)
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
    if spell.skill == 'Enhancing Magic' then
        if not S{'Regen','BarElement','BarStatus','StatusRemoval','EnSpell','Teleport'}:contains(default_spell_map) then
            return "FixedPotencyEnhancing"
        end
    elseif spell.skill == 'Elemental Magic' then
        if S{'Stone','Stone II','Stonega','Water','Water II','Waterga',
             'Aero','Aero II','Aeroga','Fire','Fire II','Firaga',
             'Blizzard','Blizzard II','Blizzaga','Thunder','Thunder II','Thundaga'}:contains(spell.english) then
            return "LowTierNuke"
        end
    end
end

-- Modify the default idle set after it was constructed.
function customize_idle_set(idleSet)
    if state.SphereIdle.value and state.DefenseMode.value == 'None' then
        idleSet = set_combine(idleSet, sets.sphere)
    end
    if state.Buff['Sublimation: Activated'] then
        idleSet = set_combine(idleSet, sets.buff.Sublimation)
    elseif player.mpp < 60 and state.DefenseMode.value == 'None' then
        idleSet = set_combine(idleSet, sets.latent_refresh)
    end
    if S{'Western Adoulin','Eastern Adoulin'}:contains(world.area) then
        if player.wardrobe4["Councilor's Garb"]   then idleSet = set_combine(idleSet, {body="Councilor's Garb"}) end
    end
    if buffactive['Reive Mark'] then
        if player.wardrobe4["Arciela's Grace +1"] then idleSet = set_combine(idleSet, {neck="Arciela's Grace +1"}) end
    end
    if player.equipment.main == 'Laevateinn' then
        if player.tp > 2970 then
            idleSet = set_combine(idleSet, sets.chrys_torque)
        elseif not (state.DefenseMode.value == 'Magical' and state.MagicalDefenseMode.value == 'MaxMP') then
            idleSet = set_combine(idleSet, sets.regain)
        end
    end
    if state.Buff.doom then
        idleSet = set_combine(idleSet, sets.buff.doom)
    end
    if state.Buff.sleep and not buffactive["Sublimation: Activated"] then
        idleSet = set_combine(idleSet, sets.buff.sleep)
    end
    if state.Buff['Mana Wall'] then
        idleSet = set_combine(idleSet, sets.manawall)
    end
    return idleSet
end

-- Modify the default defense set after it was constructed.
function customize_defense_set(defenseSet)
    if player.equipment.main == 'Laevateinn' then
        if player.tp > 2970 then
            defenseSet = set_combine(defenseSet, sets.chrys_torque)
        elseif not (state.DefenseMode.value == 'Magical' and state.MagicalDefenseMode.value == 'MaxMP') then
            defenseSet = set_combine(defenseSet, sets.regain)
        end
    end
    if state.Buff.doom then
        defenseSet = set_combine(defenseSet, sets.buff.doom)
    end
    if state.Buff.sleep and not buffactive["Sublimation: Activated"] then
        defenseSet = set_combine(defenseSet, sets.buff.sleep)
    end
    if state.Buff['Mana Wall'] then
        defenseSet = set_combine(defenseSet, sets.manawall)
    end
    return defenseSet
end

-- Modify the default engaged set after it was constructed.
function customize_melee_set(meleeSet)
    if state.DefenseMode.value == 'None' then
        if state.CombatWeapon.value ~= 'None' then
            meleeSet = set_combine(meleeSet, sets.weapons[state.CombatWeapon.value])
        end
        if buffactive['Reive Mark'] then
            meleeSet = set_combine(meleeSet, {neck="Arciela's Grace +1"})
        end
        if buffactive['elvorseal'] then
            meleeSet = set_combine(meleeSet, {body="Angantyr Robe",hands="Angantyr Mittens",legs="Angantyr Tights"})
        end
    end
    if state.Buff.doom then
        meleeSet = set_combine(meleeSet, sets.buff.doom)
    end
    if state.Buff.sleep and not buffactive["Sublimation: Activated"] then
        meleeSet = set_combine(meleeSet, sets.buff.sleep)
    end
    if state.Buff['Mana Wall'] then
        meleeSet = set_combine(meleeSet, sets.manawall)
    end
    return meleeSet
end

-- Called by the 'update' self-command.
-- Set eventArgs.handled to true if we don't want automatic equipping of gear.
function job_update(cmdParams, eventArgs)
    if midaction() and cmdParams[1] == 'auto' then
        -- don't break midcast for state changes and such
        eventArgs.handled = true
    end
end

-- Function to display the current relevant user state when doing an update.
function display_current_job_state(eventArgs)
    local msg = ''

    if state.OffenseMode.value ~= 'None' and state.CombatWeapon.value ~= 'None' then
        msg = 'TP['
        msg = msg .. state.CombatWeapon.value
        if state.OffenseMode.value ~= 'Normal' then
            msg = msg .. '-' .. state.OffenseMode.value
        end
        if state.HybridMode.value ~= 'Normal' then
            msg = msg .. '/' .. state.HybridMode.value
        end
        msg = msg .. '] '
    end

    msg = msg .. 'Cast['..state.CastingMode.value..']'
    msg = msg .. ' Idle['..state.IdleMode.value..']'
    if player.sub_job == 'SCH' then
        if buffactive['Light Arts'] or buffactive['Addendum: White'] then
            msg = msg .. ' Light Arts'
        elseif buffactive['Dark Arts'] or buffactive['Addendum: Black'] then
            msg = msg .. ' Dark Arts'
        else
            msg = msg .. ' *No Grimoire*'
        end
    end
    if state.SphereIdle.value then
        msg = msg .. ' Sphere'
    end
    if state.MWLock.value then
        msg = msg .. ' MWLock'
    end

    if state.DefenseMode.value ~= 'None' then
        local defMode = state[state.DefenseMode.value ..'DefenseMode'].current
        msg = msg .. ' Def[' .. state.DefenseMode.value .. ':' .. defMode .. ']'
    end
    if state.Kiting.value == true then
        msg = msg .. ' Kiting'
    end

    add_to_chat(122, msg)
    report_ja_recasts(info.recast_ids, false)
    eventArgs.handled = true
end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements self-commands.
-------------------------------------------------------------------------------------------------------------------

-- Called for custom player commands.
function job_self_command(cmdParams, eventArgs)
    eventArgs.handled = true
    if cmdParams[1] == 'scholar' then
        handle_stratagems(cmdParams)
    elseif cmdParams[1] == 'ListWS' then
        info.ws_binds:print('ListWS:')
    elseif cmdParams[1] == 'save' then
        save_self_command(cmdParams)
    elseif cmdParams[1] == 'rebind' then
        info.keybinds:bind()
    else
        eventArgs.handled = false
    end
end

function job_auto_change_target(spell, action, spellMap, eventArgs)
    custom_auto_change_target(spell, action, spellMap, eventArgs)
end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------

-- Select default macro book on initial load or subjob change.
--function select_default_macro_book()
--    set_macro_page(1,4)
--end

-- returns a list for use with make_keybind_list
function job_keybinds()
    local bind_command_list = L{
        'bind !^l input /lockstyleset 3',
        'bind %`   gs c update user',
        'bind F9   gs c cycle OffenseMode',
        'bind !F9  gs c reset OffenseMode',
        'bind @F9  gs c cycle CombatWeapon',
        'bind !@F9 gs c cycleback CombatWeapon',
        'bind F10  gs c cycle CastingMode',
        'bind !F10 gs c reset CastingMode',
        'bind F11  gs c cycle IdleMode',
        'bind !F11 gs c reset IdleMode',
        'bind @F11 gs c toggle Kiting',
        'bind ^space gs c cycle HybridMode',
        'bind !space gs c set DefenseMode Physical',
        'bind @space gs c set DefenseMode Magical',
        'bind !@space gs c reset DefenseMode',
        'bind @z gs c cycle MagicalDefenseMode',
        'bind !w   gs c set OffenseMode Normal',
        'bind !@w  gs c set OffenseMode None',
        'bind ~!^q gs c set CombatWeapon Dagger',
        'bind !^q  gs c set CombatWeapon Pole',
        'bind !^w  gs c set CombatWeapon Laev',
        'bind ~!^w gs c set CombatWeapon LaevK',
        'bind !^e  gs c set CombatWeapon Marin',
        'bind ~!^e gs c set CombatWeapon MarinK',

        'bind ^z   gs c toggle SphereIdle',
        'bind !z gs c toggle MagicBurst',
        'bind %z gs c toggle MagicBurst',
        'bind %c   gs c toggle MBSingle',
        'bind !c   gs c set CastingMode MAcc',
        'bind ^c   gs c reset CastingMode',
        'bind ~^z  gs c toggle OANuke',
        'bind %~z  gs c toggle OASingle',
        'bind !@z  gs c toggle Spaekona',
        'bind ~!@z gs c toggle AutoSpaek',
        'bind ~^c  gs c toggle MWLock',

        'bind ^` input /ja "Elemental Seal" <me>',
        'bind !` input /ja "Enmity Douse"',
        'bind !^` input /ja Manafont <me>',
        'bind !@` input /ja "Subtle Sorcery" <me>',
        'bind ^@` input /ja Manawell',
        'bind ^@tab input /ja "Mana Wall" <me>',
        'bind !@q input /ja Cascade <me>',

        'bind ^1  input /ma Breakga <stnpc>',
        'bind ~^1 input /ma Break <stnpc>',
        'bind ^2  input /ma Sleepga <stnpc>',
        'bind ~^2 input /ma Sleep <stnpc>',
        'bind ^3  input /ma "Sleepga II" <stnpc>',
        'bind ~^3 input /ma "Sleep II" <stnpc>',

        'bind  ^backspace input /ma Comet',
        'bind ~^backspace input /ma Impact',
        'bind !^backspace input /ma Meteor',
        'bind  !backspace input /ma Death',

        'bind !1 input /ma "Cure III" <stpc>',
        'bind !2 input /ma "Cure IV" <stpc>',

        'bind ~^5 input /ma Rasp',     -- dex
        'bind ~^6 input /ma Drown',    -- str
        'bind ~^7 input /ma Choke',    -- vit
        'bind ~^8 input /ma Burn',     -- int
        'bind ~^9 input /ma Frost',    -- agi
        'bind ~^0 input /ma Shock',    -- mnd

        'bind @5 input /ma "Stone III"',
        'bind @6 input /ma "Water III"',
        'bind @7 input /ma "Aero III"',
        'bind @8 input /ma "Fire III"',
        'bind @9 input /ma "Blizzard III"',
        'bind @0 input /ma "Thunder III"',

        'bind ~@5 input /ma "Stone IV"',
        'bind ~@6 input /ma "Water IV"',
        'bind ~@7 input /ma "Aero IV"',
        'bind ~@8 input /ma "Fire IV"',
        'bind ~@9 input /ma "Blizzard IV"',
        'bind ~@0 input /ma "Thunder IV"',

        'bind !5 input /ma "Stone V"',
        'bind !6 input /ma "Water V"',
        'bind !7 input /ma "Aero V"',
        'bind !8 input /ma "Fire V"',
        'bind !9 input /ma "Blizzard V"',
        'bind !0 input /ma "Thunder V"',

        'bind ~!5 input /ma "Stone VI"',
        'bind ~!6 input /ma "Water VI"',
        'bind ~!7 input /ma "Aero VI"',
        'bind ~!8 input /ma "Fire VI"',
        'bind ~!9 input /ma "Blizzard VI"',
        'bind ~!0 input /ma "Thunder VI"',

        'bind %5 input /ma "Stone VI"',
        'bind %6 input /ma "Water VI"',
        'bind %7 input /ma "Aero VI"',
        'bind %8 input /ma "Fire VI"',
        'bind %9 input /ma "Blizzard VI"',
        'bind %0 input /ma "Thunder VI"',

        'bind !@5 input /ma "Quake II"',
        'bind !@6 input /ma "Flood II"',
        'bind !@7 input /ma "Tornado II"',
        'bind !@8 input /ma "Flare II"',
        'bind !@9 input /ma "Freeze II"',
        'bind !@0 input /ma "Burst II"',

        'bind ^@5 input /ma "Stonega III"',
        'bind ^@6 input /ma "Waterga III"',
        'bind ^@7 input /ma "Aeroga III"',
        'bind ^@8 input /ma "Firaga III"',
        'bind ^@9 input /ma "Blizzaga III"',
        'bind ^@0 input /ma "Thundaga III"',

        'bind ^5 input /ma Stoneja',
        'bind ^6 input /ma Waterja',
        'bind ^7 input /ma Aeroja',
        'bind ^8 input /ma Firaja',
        'bind ^9 input /ma Blizzaja',
        'bind ^0 input /ma Thundaja',

        'bind @g  input /ma "Ice Spikes" <me>',
        'bind !@g input /ma Stoneskin <me>',
        'bind @c  input /ma Blink     <me>',
        'bind @v  input /ma Aquaveil  <me>',
        'bind ~^x  input /ma Sneak     <me>',
        'bind ~!^x input /ma Invisible <me>',

        'bind ^q input /ma Dispelga',
        'bind !d input /ma Stun',
        'bind !^d input /ma Bind <stnpc>',

        'bind @d  input /ma "Aspir III"',
        'bind !@d input /ma "Aspir II"',
        'bind ~!@d input /ma Aspir',
        'bind ~^@d input /ma Drain',

        'bind @b input /ma Stonega'}

    if     player.sub_job == 'RDM' then
        bind_command_list:extend(L{
            'bind ~^@tab input /ja Convert <me>',
            'bind ^tab input /ma Dispel',
            'bind  ^@1 input /ma "Dia II"',
            'bind ~^@1 input /ma Diaga <stnpc>',
            'bind ^4  input /ma Silence <stnpc>',
            'bind !3  input /ma Distract',
            'bind !4  input /ma Frazzle',
            'bind !f  input /ma Haste <me>',
            'bind !g  input /ma Phalanx <me>',
            'bind !b  input /ma Refresh <me>',
            'bind ~!^d input /ma Gravity <stnpc>'})
    elseif player.sub_job == 'WHM' then
        bind_command_list:extend(L{
            'bind ^tab input /ja "Divine Seal" <me>',
            'bind  ^@1 input /ma "Dia II"',
            'bind ~^@1 input /ma Diaga <stnpc>',
            'bind ^4  input /ma Silence',
            'bind !3  input /ma Slow',
            'bind !4  input /ma Paralyze',
            'bind !@1 input /ma Curaga',
            'bind !@2 input /ma "Curaga II"',
            'bind !@3 input /ma "Curaga III"',
            'bind @F1 input /ma Erase',
            'bind @1  input /ma Poisona',
            'bind @2  input /ma Paralyna',
            'bind @3  input /ma Blindna',
            'bind @4  input /ma Silena',
            'bind !f  input /ma Haste <me>'})
    elseif player.sub_job == 'SCH' then
        bind_command_list:extend(L{
            'bind @`    gs c scholar power',
            'bind @tab  gs c scholar cost',
            'bind @q    gs c scholar speed',
            'bind ^@q   gs c scholar aoe',
            'bind ~^tab gs c scholar light',
            'bind ~^q   gs c scholar dark',
            'bind ^tab input /ma Dispel',
            'bind !e  input /ja Sublimation <me>',
            'bind !b  input /ma Klimaform <me>',
            'bind @F1 input /ma Erase',
            'bind @1  input /ma Poisona',
            'bind @2  input /ma Paralyna',
            'bind @3  input /ma Blindna',
            'bind @4  input /ma Silena'})
    end

    return bind_command_list
end

function init_state_text()
    if hud then return end

    local mb_text_settings    = {flags={draggable=false,bold=true},text={stroke={width=2}}}
    local oa_text_settings    = {pos={y=18},flags={draggable=false,bold=true},text={stroke={width=2}}}
    local sk_text_settings    = {pos={y=36},flags={draggable=false,bold=true},text={stroke={width=2}}}
    local cmode_text_settings = {pos={y=54},flags={draggable=false,bold=true},bg={red=0,green=220,blue=220,alpha=150},text={stroke={width=2}}}
    local hyb_text_settings   = {pos={x=130,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local def_text_settings   = {pos={x=172,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local off_text_settings   = {pos={x=172,y=697},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}

    hud = {texts=T{}}
    hud.texts.mb_text    = texts.new('MBurst',         mb_text_settings)
    hud.texts.oa_text    = texts.new('OA Nuke',        oa_text_settings)
    hud.texts.sk_text    = texts.new('Spaekona',       sk_text_settings)
    hud.texts.cmode_text = texts.new('initializing..', cmode_text_settings)
    hud.texts.hyb_text   = texts.new('initializing..', hyb_text_settings)
    hud.texts.def_text   = texts.new('initializing..', def_text_settings)
    hud.texts.off_text   = texts.new('initializing..', off_text_settings)

    -- update infrequently changing text boxes in job_state_change or where they are changed
    function hud_update_on_state_change(stateField)
        if not hud then init_state_text() end

        if not stateField or stateField == 'MB Mode' or stateField == 'MB (1)' then
            hud.texts.mb_text:visible(state.MagicBurst.value or state.MBSingle.value)
            if state.MBSingle.value then
                hud.texts.mb_text:bg_color(250, 200, 0)
            else
                hud.texts.mb_text:bg_color(200, 150, 150)
            end
        end

        if not stateField or stateField == 'OA Mode' or stateField == 'OA (1)' then
            hud.texts.oa_text:visible(state.OANuke.value or state.OASingle.value)
            if state.OANuke.value then
                hud.texts.oa_text:bg_color(150, 200, 150)
            else
                hud.texts.oa_text:bg_color(0, 250, 200)
            end
        end

        if not stateField or stateField == 'Spaekona' or stateField == 'Spaekona Auto' then
            hud.texts.sk_text:visible(state.Spaekona.value or state.AutoSpaek.value)
            if state.Spaekona.value then
                hud.texts.sk_text:bg_color(50, 50, 200)
            else
                hud.texts.sk_text:bg_color(0, 150, 0)
            end
        end

        if not stateField or stateField == 'Casting Mode' then
            if state.CastingMode.value ~= 'Normal' then
                hud.texts.cmode_text:text(state.CastingMode.value)
                hud.texts.cmode_text:show()
            else hud.texts.cmode_text:hide() end
        end

        if not stateField or stateField == 'Hybrid Mode' then
            if state.HybridMode.value ~= 'Normal' then
                hud.texts.hyb_text:text('/%s':format(state.HybridMode.value))
                hud.texts.hyb_text:show()
            else hud.texts.hyb_text:hide() end
        end

        if not stateField or stateField:endswith('Defense Mode') then
            if state.DefenseMode.value ~= 'None' then
                hud.texts.def_text:text('(%s)':format(state[state.DefenseMode.value..'DefenseMode'].current))
                hud.texts.def_text:show()
            else hud.texts.def_text:hide() end
        end

        if not stateField or stateField == 'Offense Mode' or stateField == 'Combat Weapon' then
            if state.OffenseMode.value ~= 'None' then
                hud.texts.off_text:text(state.CombatWeapon.value)
                hud.texts.off_text:show()
            else hud.texts.off_text:hide() end
        end
    end
end
