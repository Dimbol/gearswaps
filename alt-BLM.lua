-- Modified from 'https://github.com/Kinematics/GearSwap-Jobs/blob/master/BLM.lua'
-- TODO test if manawall pieces must be locked

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
    state.CastingMode:options('Normal','MAcc','LowMP','OA')         -- Cycle with F10, set with ^c, ~^c, !@z, ~^z
    state.IdleMode:options('Normal','MRf','MP')                     -- Cycle with F11
    state.MagicalDefenseMode:options('MEVA','MRf')
    state.CombatWeapon = M{['description']='Combat Weapon'}
    state.CombatWeapon:options('Marin','MarinK','Pole','Dagger')    -- Cycle with @F9

    state.AutoSpaek  = M(true,  'Spaekona Sometimes')   -- Toggle with ~!@z
    state.AutoSpaek.low_mp = 750
    state.MagicBurst = M(false, 'Magic Burst')          -- Toggle with !z
    state.ZendikIdle = M(false, 'Zendik Sphere')        -- Toggle with ^z
    init_state_text()
    hud_update_on_state_change()

    -- Augmented items get variables for convenience and specificity
    gear.MACape   = {name="Taranus's Cape", augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','"Fast Cast"+10'}}
    gear.NukeCape = {name="Taranus's Cape", augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','"Mag.Atk.Bns."+10'}}
    --gear.IdleCape =

    gear.mer_head_rf   = {name="Merlinic Hood", augments={'"Refresh"+2'}}
    gear.mer_head_fc   = {name="Merlinic Hood", augments={'Mag. Acc.+19 "Mag.Atk.Bns."+19','"Fast Cast"+6','MND+3'}}
    gear.mer_head_mb   = {name="Merlinic Hood", augments={'"Mag.Atk.Bns."+27','Magic burst dmg.+10%','Mag. Acc.+15'}}
    gear.mer_body_mb9  = {name="Merlinic Jubbah", augments={'Mag. Acc.+21 "Mag.Atk.Bns."+21','Magic burst dmg.+9%'}}
    gear.mer_body_mb5  = {name="Merlinic Jubbah", augments={'Mag. Acc.+23 "Mag.Atk.Bns."+23','Magic burst dmg.+5%','"Mag.Atk.Bns."+11'}}
    gear.mer_hand_rf   = {name="Merlinic Dastanas", augments={'"Refresh"+2'}}
    gear.mer_hand_phlx = {name="Merlinic Dastanas", augments={'Phalanx +3'}}
    gear.mer_legs_rf   = {name="Merlinic Shalwar", augments={'"Refresh"+2'}}
    gear.mer_legs_th   = {name="Merlinic Shalwar", augments={'"Treasure Hunter"+2'}}
    gear.mer_feet_rf   = {name="Merlinic Crackows", augments={'"Refresh"+2'}}
    gear.mer_feet_fc   = {name="Merlinic Crackows", augments={'Mag. Acc.+11','"Fast Cast"+6'}}
    gear.mer_feet_dr   = {name="Merlinic Crackows", augments={'Mag. Acc.+28','"Drain" and "Aspir" potency +11','"Mag.Atk.Bns."+7'}}
    gear.mer_feet_ws   = {name="Merlinic Crackows", augments={'Weapon skill damage +6%','Accuracy+16 Attack+16','Mag. Acc.+19 "Mag.Atk.Bns."+19'}}
    gear.tel_head_enh  = {name="Telchine Cap", augments={'Mag. Evasion+22','"Conserve MP"+5','Enh. Mag. eff. dur. +10'}}
    gear.tel_body_enh  = {name="Telchine Chas.", augments={'Mag. Evasion+19','"Conserve MP"+5','Enh. Mag. eff. dur. +10'}}
    gear.tel_hand_enh  = {name="Telchine Gloves", augments={'Mag. Evasion+19','"Fast Cast"+5','Enh. Mag. eff. dur. +10'}}
    gear.tel_legs_enh  = {name="Telchine Braconi", augments={'Mag. Evasion+19','"Conserve MP"+3','Enh. Mag. eff. dur. +10'}}
    gear.tel_feet_enh  = {name="Telchine Pigaches", augments={'Mag. Evasion+17','"Conserve MP"+5','Enh. Mag. eff. dur. +10'}}

    info.keybinds = make_keybind_list(job_keybinds())
    info.keybinds:bind()

    info.ws_binds = make_keybind_list(T{
        ['Staff']=L{
            'bind !^1 input /ws "Shell Crusher"',
            'bind !^2 input /ws "Vidohunir"',
            'bind !^3 input /ws "Shattersoul"',
            'bind !^4 input /ws "Rock Crusher"',
            'bind !^5 input /ws "Starburst"',
            'bind !^6 input /ws "Cataclysm"',
            'bind !@e input /ws "Myrkr"'},
        ['Dagger']=L{
            'bind !^1 input /ws "Energy Drain"',
            'bind !^2 input /ws "Wasp Sting"',
            'bind !^3 input /ws "Gust Slash"',
            'bind !^4 input /ws "Shadowstitch"',
            'bind !^6 input /ws "Aeolian Edge"'}},
        {['Marin']='Staff',['MarinK']='Staff',['Pole']='Staff',['Dagger']='Dagger'})
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
    sets.weapons.Marin  = {main="Marin Staff +1",sub="Enki Strap"}
    sets.weapons.MarinK = {main="Marin Staff +1",sub="Khonsu"}
    sets.weapons.Pole   = {main="Malignance Pole",sub="Khonsu"}
    sets.weapons.Dagger = {main="Malevolence",sub="Ammurapi Shield"}

    sets.manawall = {back=gear.NukeCape,feet="Wicce Sabots +1"}
    sets.TreasureHunter = {ammo="Perfect Lucky Egg",waist="Chaac Belt",legs=gear.mer_legs_th}

    ---- Precast Sets ----
    sets.precast.JA['Mana Wall'] = sets.manawall

    sets.precast.FC = {main="Oranyan",sub="Clerisy Strap",ammo="Sapience Orb",
        head="Amalric Coif +1",neck="Voltsurge Torque",ear1="Malignance Earring",ear2="Etiolation Earring",
        body="Zendik Robe",hands=gear.tel_hand_enh,ring1="Etana Ring",ring2="Kishar Ring",
        back=gear.MACape,waist="Shinjutsu-no-Obi +1",legs="Psycloth Lappas",feet=gear.mer_feet_fc}
    sets.precast.FC['Elemental Magic'] = set_combine(sets.precast.FC, {ear2="Barkarole Earring",hands="Mallquis Cuffs +2"})
    sets.precast.FC.Cure = set_combine(sets.precast.FC, {ear2="Mendicant's Earring",feet="Vanya Clogs"})
    sets.precast.FC.Curaga = sets.precast.FC.Cure
    sets.precast.FC.CureCheat = set_combine(sets.precast.FC.Cure, {main="Oranyan",sub="Enki Strap",
        body="Jhakri Robe +2",hands="Jhakri Cuffs +2",ring1="Stikini Ring +1",legs=empty})
    sets.impact = {head=empty,body="Twilight Cloak"}
    sets.precast.FC.Impact = set_combine(sets.precast.FC['Elemental Magic'], sets.impact)
    sets.precast.FC.Death = set_combine(sets.precast.FC['Elemental Magic'], {}) -- TODO swap priorities for mp levels
    sets.dispelga = {main="Daybreak",sub="Ammurapi Shield"}
    sets.precast.FC.Dispelga = set_combine(sets.precast.FC, sets.dispelga)

    sets.precast.WS = {ammo="Amar Cluster",
        head="Blistering Sallet +1",neck="Fotia Gorget",ear1="Telos Earring",ear2="Dignitary's Earring",
        body="Jhakri Robe +2",hands="Gazu Bracelets +1",ring1="Chirich Ring +1",ring2="Rufescent Ring",
        back=gear.MACape,waist="Fotia Belt",legs="Jhakri Slops +2",feet="Jhakri Pigaches +2"}

    sets.precast.WS['Rock Crusher'] = {ammo="Ghastly Tathlum +1",
        head="Jhakri Coronal +2",neck="Sanctity Necklace",ear1="Malignance Earring",ear2="Regal Earring",
        body="Jhakri Robe +2",hands="Amalric Gages +1",ring1="Metamorph Ring +1",ring2="Freke Ring",
        back=gear.NukeCape,waist="Orpheus's Sash",legs="Archmage's Tonban +3",feet="Jhakri Pigaches +2"}
    sets.precast.WS['Earth Crusher'] = set_combine(sets.precast.WS['Rock Crusher'],  {ear2="Moonshade Earring"})
    sets.precast.WS.Starburst        = set_combine(sets.precast.WS['Earth Crusher'], {})
    sets.precast.WS.Sunburst         = set_combine(sets.precast.WS.Starburst,        {})
    sets.precast.WS.Vidohunir        = set_combine(sets.precast.WS['Rock Crusher'],  {head="Pixie Hairpin +1",ring1="Archon Ring"})
    sets.precast.WS.Cataclysm        = set_combine(sets.precast.WS.Vidohunir,        {ear2="Moonshade Earring"})
    sets.precast.WS['Aeolian Edge']  = set_combine(sets.precast.WS['Earth Crusher'], {})

    sets.precast.WS['Shell Crusher'] = set_combine(sets.precast.WS, {hands="Jhakri Cuffs +2",ring2="Etana Ring"})
    sets.precast.WS.Brainshaker = set_combine(sets.precast.WS['Shell Crusher'], {})

    sets.precast.WS.Myrkr = {ammo="Ghastly Tathlum +1",
        head="Amalric Coif +1",neck="Sanctity Necklace",ear1="Moonshade Earring",ear2="Etiolation Earring",
        body="Vanya Robe",hands="Spaekona's Gloves +2",ring1="Mephitas's Ring +1",ring2="Sangoma Ring",
        back="Bane Cape",waist="Shinjutsu-no-Obi +1",legs="Spaekona's Tonban +3",feet="Nyame Sollerets"}

    ---- Midcast Sets ----
    sets.midcast.Cure = {main="Malignance Pole",sub="Khonsu",ammo="Pemphredo Tathlum",
        head="Vanya Hood",neck="Loricate Torque +1",ear1="Calamitous Earring",ear2="Etiolation Earring",
        body="Nyame Mail",hands=gear.tel_hand_enh,ring1="Vocane Ring +1",ring2="Defending Ring",
        back="Solemnity Cape",waist="Shinjutsu-no-Obi +1",legs="Gyve Trousers",feet="Vanya Clogs"}
    sets.midcast.Curaga = sets.midcast.Cure
    sets.midcast.Cursna = {main="Malignance Pole",sub="Khonsu",ammo="Sapience Orb",
        head="Hike Khat +1",neck="Malison Medallion",ear1="Malignance Earring",ear2="Lugalbanda Earring",
        body="Zendik Robe",hands="Gazu Bracelets +1",ring1="Ephedra Ring",ring2="Menelaus's Ring",
        back=gear.MACape,waist="Embla Sash",legs="Gyve Trousers",feet="Vanya Clogs"}
    sets.midcast.CureCheat = {main="Septoptic",sub="Culminus",ammo="Pemphredo Tathlum",
        head="Vanya Hood",neck="Sanctity Necklace",ear1="Eabani Earring",ear2="Etiolation Earring",
        body="Vanya Robe",hands=gear.tel_hand_enh,ring1="Etana Ring",ring2="Meridian Ring",
        back="Tantalic Cape",waist="Gishdubar Sash",legs="Perdition Slops",feet="Vanya Clogs"}
    sets.cmp_belt  = {waist="Shinjutsu-no-Obi +1"}
    sets.gishdubar = {waist="Gishdubar Sash"}

    sets.midcast.EnhancingDuration = {main="Gada",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
        head=gear.tel_head_enh,neck="Loricate Torque +1",ear1="Calamitous Earring",ear2="Etiolation Earring",
        body=gear.tel_body_enh,hands=gear.tel_hand_enh,ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.MACape,waist="Embla Sash",legs=gear.tel_legs_enh,feet=gear.tel_feet_enh}
    sets.midcast['Enhancing Magic'] = set_combine(sets.midcast.EnhancingDuration, {
        head="Befouled Crown",neck="Incanter's Torque",ear1="Mimir Earring",ear2="Andoaa Earring",
        body=gear.tel_body_enh,hands="Ayao's Gages",ring1="Stikini Ring +1",
        back="Fi Follet Cape",waist="Olympus Sash",legs="Shedir Seraweels",feet="Regal Pumps +1"})
    sets.midcast.Phalanx = set_combine(sets.midcast['Enhancing Magic'], {hands=gear.mer_hand_phlx})
    sets.midcast.Stoneskin = set_combine(sets.midcast.EnhancingDuration, {neck="Nodens Gorget",legs="Shedir Seraweels"})
    sets.midcast.Aquaveil  = set_combine(sets.midcast.EnhancingDuration, {main="Vadose Rod",sub="Ammurapi Shield",
        head="Amalric Coif +1",legs="Shedir Seraweels"})
    sets.midcast.Regen   = set_combine(sets.midcast.EnhancingDuration, {main="Bolelabunga",sub="Ammurapi Shield"})
    sets.midcast.Refresh = set_combine(sets.midcast.EnhancingDuration, {head="Amalric Coif +1"})
    sets.self_refresh = {back="Grapevine Cape",waist="Gishdubar Sash",feet="Inspirited Boots"}
    sets.midcast.FixedPotencyEnhancing = sets.midcast.EnhancingDuration
    sets.midcast.Klimaform = {}

    sets.midcast['Elemental Magic'] = {main="Marin Staff +1",sub="Enki Strap",ammo="Ghastly Tathlum +1",
        head="Archmage's Petasos +3",neck="Sorcerer's Stole +2",ear1="Malignance Earring",ear2="Regal Earring",
        body="Archmage's Coat +3",hands="Amalric Gages +1",ring1="Metamorph Ring +1",ring2="Freke Ring",
        back=gear.NukeCape,waist="Sacro Cord",legs="Archmage's Tonban +3",feet="Archmage's Sabots +3"}
    sets.midcast['Elemental Magic'].MAcc  = set_combine(sets.midcast['Elemental Magic'], {sub="Khonsu",
        ring1="Stikini Ring +1",ring2="Metamorph Ring +1"})
    sets.midcast['Elemental Magic'].LowMP = set_combine(sets.midcast['Elemental Magic'], {ear2="Regal Earring",body="Spaekona's Coat +3"})
    sets.midcast['Elemental Magic'].OA = {ammo="Seraphic Ampulla",
        head="Mallquis Chapeau +2",neck="Sorcerer's Stole +2",ear1="Malignance Earring",ear2="Telos Earring",
        body="Spaekona's Coat +3",hands="Amalric Gages +1",ring1="Chirich Ring +1",ring2="Freke Ring",
        back=gear.NukeCape,waist="Oneiros Rope",legs="Perdition Slops",feet="Archmage's Sabots +3"}
    sets.midcast['Elemental Magic'].MB = {main="Marin Staff +1",sub="Enki Strap",ammo="Ghastly Tathlum +1",
        head="Ea Hat +1",neck="Sorcerer's Stole +2",ear1="Malignance Earring",ear2="Regal Earring",
        body="Ea Houppelande +1",hands="Amalric Gages +1",ring1="Mujin Band",ring2="Freke Ring",
        back=gear.NukeCape,waist="Sacro Cord",legs="Ea Slops +1",feet="Archmage's Sabots +3"}
    sets.midcast['Elemental Magic'].MAcc.MB  = set_combine(sets.midcast['Elemental Magic'].MB, {sub="Khonsu"})
    sets.midcast['Elemental Magic'].LowMP.MB = set_combine(sets.midcast['Elemental Magic'].MB, {
        ear2="Static Earring",body="Spaekona's Coat +3",ring2="Locus Ring",feet="Archmage's Sabots +3"})

    sets.midcast.LowTierNuke         = set_combine(sets.midcast['Elemental Magic'], {main="Bunzi's Rod",sub="Culminus",ear2="Barkarole Earring"})
    sets.midcast.LowTierNuke.MAcc    = set_combine(sets.midcast.LowTierNuke, {ring1="Stikini Ring +1",ring2="Metamorph Ring +1"})
    sets.midcast.LowTierNuke.MB      = set_combine(sets.midcast['Elemental Magic'].MB, {ammo="Ghastly Tathlum +1"})
    sets.midcast.LowTierNuke.MAcc.MB = set_combine(sets.midcast.LowTierNuke.MB, {sub="Khonsu"})

    sets.midcast.Comet       = set_combine(sets.midcast['Elemental Magic'], {
        head="Pixie Hairpin +1",body="Archmage's Coat +3",ring1="Archon Ring"})
    sets.midcast.Comet.MAcc  = set_combine(sets.midcast['Elemental Magic'].MAcc, {
        head="Pixie Hairpin +1",body="Archmage's Coat +3",ring1="Archon Ring"})
    sets.midcast.Comet.LowMP = set_combine(sets.midcast['Elemental Magic'].LowMP, {head="Pixie Hairpin +1",ring1="Archon Ring"})
    sets.midcast.Comet.OA    = set_combine(sets.midcast['Elemental Magic'].OA,    {head="Pixie Hairpin +1",ring2="Archon Ring"})
    sets.midcast.Comet.MB    = {main="Marin Staff +1",sub="Enki Strap",ammo="Ghastly Tathlum +1",
        head="Pixie Hairpin +1",neck="Sorcerer's Stole +2",ear1="Malignance Earring",ear2="Barkarole Earring",
        body="Ea Houppelande +1",hands="Amalric Gages +1",ring1="Mujin Band",ring2="Archon Ring",
        back=gear.NukeCape,waist="Sacro Cord",legs="Ea Slops +1",feet="Jhakri Pigaches +2"}
    sets.midcast.Comet.MAcc.MB  = set_combine(sets.midcast.Comet.MB, {sub="Khonsu"})
    sets.midcast.Comet.LowMP.MB = set_combine(sets.midcast.Comet.MB, {ear2="Static Earring",body="Spaekona's Coat +3"})

    sets.midcast.Impact    = set_combine(sets.midcast.Comet.MAcc,    sets.impact)
    sets.midcast.Impact.OA = set_combine(sets.midcast.Comet.OA,      sets.impact)
    sets.midcast.Impact.MB = set_combine(sets.midcast.Comet.MAcc.MB, sets.impact)

    sets.midcast.Death         = set_combine(sets.midcast.Comet,      {})
    sets.midcast.Death.OA      = set_combine(sets.midcast.Comet.OA,   {})
    sets.midcast.Death.MAcc    = set_combine(sets.midcast.Comet.MAcc, {})
    sets.midcast.Death.MB      = {main="Marin Staff +1",sub="Khonsu",ammo="Ghastly Tathlum +1",
        head="Pixie Hairpin +1",neck="Sorcerer's Stole +2",ear1="Malignance Earring",ear2="Barkarole Earring",
        body="Ea Houppelande +1",hands="Amalric Gages +1",ring1="Mujin Band",ring2="Archon Ring",
        back=gear.NukeCape,waist="Shinjutsu-no-Obi +1",legs="Ea Slops +1",feet="Jhakri Pigaches +2"}
    sets.midcast.Death.MAcc.MB = set_combine(sets.midcast.Death.MB, {ear2="Regal Earring",feet="Spaekona's Sabots +2"})
    -- spaekona's gloves? mp cape? path A amalric?

    sets.orpheus   = {waist="Orpheus's Sash"}
    sets.ele_obi   = {waist="Hachirin-no-Obi"}
    sets.nuke_belt = {waist="Sacro Cord"}

    sets.midcast.Drain = {main="Rubicundity",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
        head="Pixie Hairpin +1",neck="Erra Pendant",ear1="Malignance Earring",ear2="Regal Earring",
        body="Zendik Robe",hands="Spaekona's Gloves +2",ring1="Archon Ring",ring2="Evanescence Ring",
        back=gear.MACape,waist="Fucho-no-Obi",legs="Spaekona's Tonban +3",feet=gear.mer_feet_dr}
    sets.midcast.Aspir = sets.midcast.Drain
    sets.midcast.Aspir.MAcc = set_combine(sets.midcast.Aspir, {head="Amalric Coif +1",ring1="Stikini Ring +1"})
    sets.midcast.Aspir.MP   = set_combine(sets.midcast.Aspir, {ammo="Ghastly Tathlum +1"})
    sets.drain_belt = {waist="Fucho-no-Obi"}

    sets.midcast['Enfeebling Magic'] = {main="Bunzi's Rod",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
        head="Spaekona's Petasos +2",neck="Sorcerer's Stole +2",ear1="Malignance Earring",ear2="Regal Earring",
        body="Spaekona's Coat +3",hands="Spaekona's Gloves +2",ring1="Metamorph Ring +1",ring2="Stikini Ring +1",
        back="Aurist's Cape +1",waist="Acuity Belt +1",legs="Spaekona's Tonban +3",feet="Spaekona's Sabots +2"}
    sets.midcast.Dispelga = set_combine(sets.midcast['Enfeebling Magic'], sets.dispelga)
    sets.midcast.Silence  = set_combine(sets.midcast['Enfeebling Magic'], {waist="Luminary Sash"})
    sets.midcast.Slow     = set_combine(sets.midcast['Enfeebling Magic'], {main="Daybreak",sub="Ammurapi Shield",waist="Luminary Sash"})
    sets.midcast.Paralyze = set_combine(sets.midcast.Slow, {})

    sets.midcast.Sleep    = set_combine(sets.midcast['Enfeebling Magic'], {ring2="Kishar Ring"})
    sets.midcast.Repose   = sets.midcast.Sleep
    sets.midcast.Break    = sets.midcast.Sleep
    sets.midcast.Bind     = sets.midcast.Sleep
    sets.midcast.Gravity  = sets.midcast.Sleep

    sets.midcast.Stun = set_combine(sets.midcast['Enfeebling Magic'], {body="Zendik Robe",back=gear.MACape,waist="Goading Belt"})
    sets.midcast.ElementalEnfeeble = set_combine(sets.midcast['Enfeebling Magic'], {
        head=empty,body="Cohort Cloak +1",legs="Archmage's Tonban +3",feet="Archmage's Sabots +3"})
    sets.midcast['Dark Magic'] = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast['Divine Magic'] = set_combine(sets.midcast['Enfeebling Magic'], {})

    ---- Sets to return to when not performing an action ----
    sets.idle = {main="Malignance Pole",sub="Khonsu",ammo="Crepuscular Pebble",
        head=gear.mer_head_rf,neck="Loricate Torque +1",ear1="Eabani Earring",ear2="Lugalbanda Earring",
        body="Archmage's Coat +3",hands=gear.mer_hand_rf,ring1="Stikini Ring +1",ring2="Defending Ring",
        back=gear.NukeCape,waist="Porous Rope",legs=gear.mer_legs_rf,feet="Herald's Gaiters"}
	sets.idle.MRf  = set_combine(sets.idle, {feet=gear.mer_feet_rf})
    sets.idle.PDT = set_combine(sets.idle, {main="Malignance Pole",sub="Oneiros Grip",
        head="Hike Khat +1",body="Nyame Mail",ring1="Vocane Ring +1",feet=gear.mer_feet_rf})
    sets.idle.MEVA = set_combine(sets.idle, {head="Ea Hat +1",body="Ea Houppelande +1",
        ring1="Vocane Ring +1",legs="Ea Slops +1",feet=gear.mer_feet_rf})
    sets.idle.MP = {main="Malignance Pole",sub="Khonsu",ammo="Ghastly Tathlum +1",
        head=gear.mer_head_rf,neck="Loricate Torque +1",ear1="Eabani Earring",ear2="Etiolation Earring",
        body="Archmage's Coat +3",hands="Spaekona's Gloves +2",ring1="Mephitas's Ring +1",ring2="Defending Ring",
        back=gear.NukeCape,waist="Shinjutsu-no-Obi +1",legs="Spaekona's Tonban +3",feet=gear.mer_feet_rf}
    sets.latent_refresh = {waist="Fucho-no-obi"}
    sets.zendik         = {body="Zendik Robe"}
    sets.buff.doom      = {neck="Nicander's Necklace",ring1="Saida Ring",ring2="Defending Ring",waist="Gishdubar Sash"}
    sets.buff.sleep     = {main="Prime Staff",sub="Khonsu"}

    -- Defense sets
    sets.defense.PDT  = sets.idle.PDT
    sets.defense.MEVA = sets.idle.MEVA
    sets.defense.MRf  = sets.idle.MRf
    sets.Kiting = {feet="Herald's Gaiters"}

    -- Engaged sets
    sets.engaged = {main="Malignance Pole",sub="Khonsu",ammo="Amar Cluster",
        head="Blistering Sallet +1",neck="Sanctity Necklace",ear1="Telos Earring",ear2="Dignitary's Earring",
        body="Nyame Mail",hands="Gazu Bracelets +1",ring1="Chirich Ring +1",ring2="Pernicious Ring",
        back="Aurist's Cape +1",waist="Goading Belt",legs="Jhakri Slops +2",feet="Nyame Sollerets"}
    sets.engaged.PDef = set_combine(sets.engaged, {neck="Loricate Torque +1",ring1="Vocane Ring +1",ring2="Defending Ring",legs="Nyame Flanchard"})

    -- Sets depending upon idle sets
    sets.midcast.FastRecast = set_combine(sets.defense.PDT, {})
    sets.midcast.Dia = set_combine(sets.idle.PDT, sets.TreasureHunter)
    sets.midcast.Bio = set_combine(sets.midcast.Dia, {})
    sets.midcast.Stonega = set_combine(sets.midcast['Elemental Magic'], sets.TreasureHunter)
    sets.midcast.Stone   = set_combine(sets.midcast['Elemental Magic'], sets.TreasureHunter)
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.
function job_precast(spell, action, spellMap, eventArgs)
    if spell.skill == 'Elemental Magic' and not S{'Impact','Meteor','Death'}:contains(spell.english) then
        if state.AutoSpaek.value and S{'Normal','LowMP'}:contains(state.CastingMode.value) then
            if not S{'LowTierNuke','ElementalEnfeeble'}:contains(spellMap)
            and player.mp - spell.mp_cost < state.AutoSpaek.low_mp
            and not state.Buff['Manawell'] and not state.Buff['Manafont'] then
                state.CastingMode:set('LowMP')
            else
                state.CastingMode:set('Normal')
            end
            hud_update_on_state_change('Casting Mode')
        end
    elseif spellMap == 'Aspir' and state.IdleMode.value == 'MP' and player.mp > 1300 then
        equip(sets.precast.FC.Death)
    elseif classes.CustomClass == 'CureCheat' then
        if not (spell.target.type == 'SELF' and spell.english == 'Cure IV') then
            classes.CustomClass = nil
        end
    end
end

-- Run after the default midcast() is done.
-- eventArgs is the same one used in job_midcast, in case information needs to be persisted.
function job_post_midcast(spell, action, spellMap, eventArgs)
    if spell.skill == 'Elemental Magic' and spellMap ~= 'ElementalEnfeeble' and spell.english ~= 'Meteor' then
        if state.MagicBurst.value then
            local base_set
            if S{'Comet','Impact','Death'}:contains(spell.english) then
                base_set = sets.midcast[spell.english]
            elseif spellMap == 'LowTierNuke' then
                base_set = sets.midcast.LowTierNuke
            else
                base_set = sets.midcast['Elemental Magic']
            end

            if base_set[state.CastingMode.value] and base_set[state.CastingMode.value].MB then
                equip(base_set[state.CastingMode.value].MB)
            else
                equip(base_set.MB)
            end
        end

        if state.CastingMode.value ~= 'OA' then
            if spell.english == 'Death' then
                equip(resolve_ele_belt(spell, sets.ele_obi, sets.cmp_belt, 3))
            else
                equip(resolve_ele_belt(spell, sets.ele_obi, sets.nuke_belt, 3))
            end
        end
    elseif S{'Drain','Aspir'}:contains(spellMap) then
        equip(resolve_ele_belt(spell, sets.ele_obi, sets.drain_belt, 5))
    elseif classes.CustomClass ~= 'CureCheat' and (spell.english:startswith('Cure') or spell.english:startswith('Curaga')) then
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

    if state.Buff['Mana Wall'] and spell.english ~= 'Death' then
        equip(sets.manawall)
    end
end

function job_aftercast(spell, action, spellMap, eventArgs)
    if spell.interrupted then
        send_command('wait 0.5;gs c update')
        interrupted_message(spell)
    else
        if S{'JobAbility','Scholar'}:contains(spell.type) then
            eventArgs.handled = true
        elseif spell.english == 'Break' or spell.english == 'Breakga' then
            send_command('timers c "'..spell.english..' ['..spell.target.name..']" 33 down')
        elseif spell.english == 'Sleep' or spell.english == 'Sleepga' then
            send_command('timers c "'..spell.english..' ['..spell.target.name..']" 66 down')
        elseif spell.english == 'Sleep II' or spell.english == 'Sleepga II' then
            send_command('timers c "'..spell.english..' ['..spell.target.name..']" 99 down')
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
        if spell.english ~= 'Erase'
        and not S{'Regen','BarElement','BarStatus','EnSpell','StatBoost','Teleport'}:contains(default_spell_map) then
            return "FixedPotencyEnhancing"
        end
    elseif spell.skill == 'Elemental Magic' then
        if S{'Stone','Stone II','Water','Water II','Aero','Aero II',
             'Fire','Fire II','Blizzard','Blizzard II','Thunder','Thunder II'}:contains(spell) then
            return "LowTierNuke"
        end
    end
end

-- Modify the default idle set after it was constructed.
function customize_idle_set(idleSet)
    if state.ZendikIdle.value and state.DefenseMode.value == 'None' then
        idleSet = set_combine(idleSet, sets.zendik)
    end
    if player.mpp < 51 then
        idleSet = set_combine(idleSet, sets.latent_refresh)
    end
    if S{'Western Adoulin','Eastern Adoulin'}:contains(world.area) then
        if player.wardrobe4["Councilor's Garb"]   then idleSet = set_combine(idleSet, {body="Councilor's Garb"}) end
    end
    if buffactive['Reive Mark'] then
        if player.wardrobe4["Arciela's Grace +1"] then idleSet = set_combine(idleSet, {neck="Arciela's Grace +1"}) end
    end
    if state.Buff['Mana Wall'] then
        idleSet = set_combine(idleSet, sets.manawall)
    end
    if state.Buff.doom then
        idleSet = set_combine(idleSet, sets.buff.doom)
    end
    if state.Buff.sleep and not buffactive["Sublimation: Activated"] then
        idleSet = set_combine(idleSet, sets.buff.sleep)
    end
    return idleSet
end

-- Modify the default defense set after it was constructed.
function customize_defense_set(defenseSet)
    if state.Buff['Mana Wall'] then
        defenseSet = set_combine(defenseSet, sets.manawall)
    end
    if state.Buff.doom then
        defenseSet = set_combine(defenseSet, sets.buff.doom)
    end
    if state.Buff.sleep and not buffactive["Sublimation: Activated"] then
        defenseSet = set_combine(defenseSet, sets.buff.sleep)
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
    if state.Buff['Mana Wall'] then
        meleeSet = set_combine(meleeSet, sets.manawall)
    end
    if state.Buff.doom then
        meleeSet = set_combine(meleeSet, sets.buff.doom)
    end
    if state.Buff.sleep and not buffactive["Sublimation: Activated"] then
        meleeSet = set_combine(meleeSet, sets.buff.sleep)
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
    if state.AutoSpaek.value then
        msg = msg .. ' AutoSpaek'
    end
    if state.MagicBurst.value then
        msg = msg .. ' MB+'
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
    elseif cmdParams[1] == 'CureCheat' then
        classes.CustomClass = 'CureCheat'
        send_command('input /ma "Cure IV" <me>')
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
        'bind %`|F12 gs c update user',
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
        'bind @z      gs c cycle MagicalDefenseMode',
        'bind !w   gs c set OffenseMode Normal',
        'bind !@w  gs c set OffenseMode None',
        'bind ~!^q gs c set CombatWeapon Dagger',
        'bind !^q  gs c set CombatWeapon Pole',
        'bind !^w  gs c set CombatWeapon Marin',
        'bind ~!^w gs c set CombatWeapon MarinK',
        'bind ^z   gs c toggle ZendikIdle',
        'bind !z   gs c toggle MagicBurst',
        'bind ^c   gs c reset CastingMode',
        'bind ~^z  gs c set CastingMode OA',
        'bind ~^c  gs c set CastingMode MAcc',
        'bind !@z  gs c set CastingMode LowMP',
        'bind  !^z gs c toggle AutoSpaek',
        'bind ~!^z gs c unset AutoSpaek',
        'bind ~!^2 gs c CureCheat',

        'bind ^` input /ja "Elemental Seal" <me>',
        'bind !` input /ja "Enmity Douse"',
        'bind !^` input /ja Manafont <me>',
        'bind !@` input /ja "Subtle Sorcery" <me>',
        'bind ^@` input /ja Manawell',
        'bind ^@tab input /ja "Mana Wall" <me>',
        'bind !@q input /ja Cascade <me>',

        'bind ^1  input /ma Breakga',
        'bind ~^1 input /ma Break',
        'bind ^2  input /ma Sleepga',
        'bind ~^2 input /ma Sleep',
        'bind ^3  input /ma "Sleepga II"',
        'bind ~^3 input /ma "Sleep II"',

        'bind !^d input /ma Bind <stnpc>',

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

        'bind ~!5|%5 input /ma "Stone VI"',
        'bind ~!6|%6 input /ma "Water VI"',
        'bind ~!7|%7 input /ma "Aero VI"',
        'bind ~!8|%8 input /ma "Fire VI"',
        'bind ~!9|%9 input /ma "Blizzard VI"',
        'bind ~!0|%0 input /ma "Thunder VI"',

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

        'bind ^q input /ma Dispelga',
        'bind !d input /ma Stun',

        'bind @d  input /ma "Aspir III"',
        'bind !@d input /ma "Aspir II"',

        'bind @b input /ma Stonega'}

    if     player.sub_job == 'RDM' then
        bind_command_list:extend(L{
            'bind ~^@tab input /ja Convert <me>',
            'bind ^tab input /ma Dispel',
            'bind ^4  input /ma Silence',
            'bind !3  input /ma Distract',
            'bind !4  input /ma Frazzle',
            'bind !f  input /ma Haste     <me>',
            'bind !g  input /ma Phalanx   <me>',
            'bind !b  input /ma Refresh   <me>',
            'bind ~!^d input /ma Bind <stnpc>'})
    elseif player.sub_job == 'WHM' then
        bind_command_list:extend(L{
            'bind ^tab input /ja "Divine Seal" <me>',
            'bind ^4  input /ma Silence',
            'bind !3  input /ma Slow',
            'bind !4  input /ma Paralyze',
            'bind !@1 input /ma Curaga',
            'bind !@2 input /ma "Curaga II"',
            'bind @F1 input /ma Erase',
            'bind @1  input /ma Poisona',
            'bind @2  input /ma Paralyna',
            'bind @3  input /ma Blindna',
            'bind @4  input /ma Silena',
            'bind !f  input /ma Haste     <me>'})
    elseif player.sub_job == 'SCH' then
        bind_command_list:extend(L{
            'bind @tab  gs c scholar cost',
            'bind @q    gs c scholar speed',
            'bind ^@q   gs c scholar aoe',
            'bind ~^tab gs c scholar light',
            'bind ~^q   gs c scholar dark',
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

    local mb_text_settings    = {flags={draggable=false,bold=true},bg={red=250,green=200,blue=0,alpha=150},text={stroke={width=2}}}
    local cmode_text_settings = {pos={y=18},flags={draggable=false,bold=true},bg={red=0,green=220,blue=220,alpha=150},
                                 text={stroke={width=2}}}
    local hyb_text_settings   = {pos={x=130,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local def_text_settings   = {pos={x=172,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local off_text_settings   = {pos={x=172,y=697},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}

    hud = {texts=T{}}
    hud.texts.mb_text    = texts.new('MBurst',         mb_text_settings)
    hud.texts.cmode_text = texts.new('initializing..', cmode_text_settings)
    hud.texts.hyb_text   = texts.new('initializing..', hyb_text_settings)
    hud.texts.def_text   = texts.new('initializing..', def_text_settings)
    hud.texts.off_text   = texts.new('initializing..', off_text_settings)

    -- update infrequently changing text boxes in job_state_change or where they are changed
    function hud_update_on_state_change(stateField)
        if not hud then init_state_text() end

        if not stateField or stateField == 'Magic Burst' then
            hud.texts.mb_text:visible(state.MagicBurst.value)
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
