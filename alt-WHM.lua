-- Modified from 'https://github.com/Kinematics/GearSwap-Jobs/blob/master/WHM.lua'

texts = require('texts')

------------------------------------------------------------------------------------------------------------------
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
    state.Buff['Afflatus Solace'] = buffactive['Afflatus Solace'] or false
    state.Buff['Afflatus Misery'] = buffactive['Afflatus Misery'] or false
    state.Buff['Divine Caress']   = buffactive['Divine Caress'] or false
    state.Buff.doom = buffactive.doom or false

    windower.raw_register_event('logout', destroy_state_text)
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
    state.OffenseMode:options('None','Normal','Acc')                    -- Cycle with F9, will swap weapon
    state.HybridMode:options('Normal','PDef')                           -- Cycle with ^F9
    state.WeaponskillMode:options('Normal','Acc','NoDmg')
    state.CastingMode:options('Normal')                                 -- Cycle with F10
    state.IdleMode:options('Normal','PDT','MEVA','Rf')                  -- Cycle with F11, set to PDT with ^F11, reset with !F11
    state.MagicalDefenseMode:options('MEVA','MRf')                      -- Cycle with @z
    state.CombatWeapon = M{['description']='Combat Weapon'}
    if S{'DNC','NIN'}:contains(player.sub_job) then
        state.CombatWeapon:options('ClubDW','Staff','StaffMA')
		state.CombatForm:set('DW')
    else
        state.CombatWeapon:options('Club','Staff','StaffMA')
		state.CombatForm:reset()
    end

    state.WSMsg      = M(false, 'WS Message')                           -- Toggle with ^\
    state.DiaMsg     = M(false, 'Dia Message')                          -- Toggle with ^@\
    state.AriseTold  = M{['description']='Arise Tells',['string']=''}   -- Holds name of last person pestered to avoid spamming.
    state.AllyBinds  = M(false, 'Ally Cure Keybinds')                   -- Toggle with !^numpad0
    state.MagicBurst = M(false, 'Magic Burst')                          -- Toggle with !z
    state.CP         = M(false, 'CP Mode')
    init_state_text()
    hud_update_on_state_change()

    info.magic_ws = S{'Shining Strike','Seraph Strike','Flash Nova','Rock Crusher','Earth Crusher','Starburst','Sunburst','Cataclysm'}

    gear.IdleCape = {name="Alaunus's Cape", augments={'HP+60','Eva.+20 /Mag. Eva.+20','Enmity-10','Phys. dmg. taken-10%'}}
    gear.MACape   = {name="Alaunus's Cape", augments={'MND+20','Mag. Acc+20 /Mag. Dmg.+20','"Fast Cast"+10','Phys. dmg. taken-10%'}}
    -- gear.TPCape -- TODO
    -- gear.WSCape -- TODO

    gear.tel_head_enh = {name="Telchine Cap", augments={'Mag. Evasion+22','"Conserve MP"+5','Enh. Mag. eff. dur. +10'}}
    gear.tel_body_enh = {name="Telchine Chas.", augments={'Mag. Evasion+19','"Conserve MP"+5','Enh. Mag. eff. dur. +10'}}
    gear.tel_hand_enh = {name="Telchine Gloves", augments={'Mag. Evasion+19','"Fast Cast"+5','Enh. Mag. eff. dur. +10'}}
    gear.tel_legs_enh = {name="Telchine Braconi", augments={'Mag. Evasion+19','"Conserve MP"+3','Enh. Mag. eff. dur. +10'}}
    gear.tel_feet_enh = {name="Telchine Pigaches", augments={'Mag. Evasion+17','"Conserve MP"+5','Enh. Mag. eff. dur. +10'}}
    gear.chir_hand_ma = {name="Chironic Gloves", augments={'Mag. Acc.+23 "Mag.Atk.Bns."+23','Enmity-2','Mag. Acc.+10','"Mag.Atk.Bns."+13'}}
    gear.chir_legs_ma  = {name="Chironic Hose", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25','Haste+1','CHR+13','Mag. Acc.+13'}}
    gear.chir_feet_ma = {name="Chironic Slippers", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25','Spell interruption rate down -10%','MND+11'}}

    info.keybinds = make_keybind_list(job_keybinds())
    info.keybinds:bind()

    info.ally_keybinds = make_keybind_list(L{
        'bind %~numpad1 input /ma "Cure IV" <p0>',
        'bind %~numpad2 input /ma "Cure IV" <p1>',
        'bind %~numpad3 input /ma "Cure IV" <p2>',
        'bind %~numpad4 input /ma "Cure IV" <p3>',
        'bind %~numpad5 input /ma "Cure IV" <p4>',
        'bind %~numpad6 input /ma "Cure IV" <p5>',
        'bind ^numpad1 input /ma "Cure IV" <a10>',
        'bind ^numpad2 input /ma "Cure IV" <a11>',
        'bind ^numpad3 input /ma "Cure IV" <a12>',
        'bind ^numpad4 input /ma "Cure IV" <a13>',
        'bind ^numpad5 input /ma "Cure IV" <a14>',
        'bind ^numpad6 input /ma "Cure IV" <a15>',
        'bind !numpad1 input /ma "Cure IV" <a20>',
        'bind !numpad2 input /ma "Cure IV" <a21>',
        'bind !numpad3 input /ma "Cure IV" <a22>',
        'bind !numpad4 input /ma "Cure IV" <a23>',
        'bind !numpad5 input /ma "Cure IV" <a24>',
        'bind !numpad6 input /ma "Cure IV" <a25>',
        'bind %~^numpad1 input /ma "Cure V" <p0>',
        'bind %~^numpad2 input /ma "Cure V" <p1>',
        'bind %~^numpad3 input /ma "Cure V" <p2>',
        'bind %~^numpad4 input /ma "Cure V" <p3>',
        'bind %~^numpad5 input /ma "Cure V" <p4>',
        'bind %~^numpad6 input /ma "Cure V" <p5>',
        'bind ^@numpad1 input /ma "Cure V" <a10>',
        'bind ^@numpad2 input /ma "Cure V" <a11>',
        'bind ^@numpad3 input /ma "Cure V" <a12>',
        'bind ^@numpad4 input /ma "Cure V" <a13>',
        'bind ^@numpad5 input /ma "Cure V" <a14>',
        'bind ^@numpad6 input /ma "Cure V" <a15>',
        'bind !@numpad1 input /ma "Cure V" <a20>',
        'bind !@numpad2 input /ma "Cure V" <a21>',
        'bind !@numpad3 input /ma "Cure V" <a22>',
        'bind !@numpad4 input /ma "Cure V" <a23>',
        'bind !@numpad5 input /ma "Cure V" <a24>',
        'bind !@numpad6 input /ma "Cure V" <a25>',
        'bind ^numpad7 input /ma Paralyna  <a10>',
        'bind ^numpad8 input /ma Silena    <a10>',
        'bind ^numpad9 input /ma Cursna    <a10>',
        'bind !numpad7 input /ma Paralyna  <a20>',
        'bind !numpad8 input /ma Silena    <a20>',
        'bind !numpad9 input /ma Cursna    <a20>'})
    send_command('bind !^numpad0 gs c toggle AllyBinds')

    info.ws_binds = make_keybind_list(T{
        ['Club']=L{
            'bind !^1 input /ws "Mystic Boon"',
            'bind !^2 input /ws "Flash Nova"',
            'bind !^3 input /ws "Black Halo"',
            'bind !^4 input /ws "Realmrazer"',
            'bind !^5 input /ws "Dagan"',
            'bind !^6 input /ws "Moonlight"',
            'bind !^d input /ws "Brainshaker"'},
        ['Staff']=L{
            'bind !^1 input /ws "Spirit Taker"',
            'bind !^2 input /ws "Sunburst"',
            'bind !^3 input /ws "Shattersoul"',
            'bind !^4 input /ws "Retribution"',
            'bind !^d input /ws "Shell Crusher"',
            'bind !^6 input /ws "Cataclysm"'}},
        {['Club']='Club',['ClubDW']='Club',['Staff']='Staff',['StaffMA']='Staff'})
    info.ws_binds:bind(state.CombatWeapon)
    send_command('bind %\\\\  gs c ListWS')

    info.recast_ids = L{{name="Sacro",id=33},{name="D.Seal",id=26},{name="Devotion",id=28}}
    if     player.sub_job == 'SCH' then
        info.recast_ids:append({name="Strats",id=231})
    elseif player.sub_job == 'RDM' then
        info.recast_ids:append({name="Convert",id=49})
    elseif player.sub_job == 'BLM' then
        info.recast_ids:append({name="E.Seal",id=38})
    end

    select_default_macro_book()
end

-- Called when this job file is unloaded (eg: job change)
function user_unload()
    info.keybinds:unbind()

    if state.AllyBinds.value then info.ally_keybinds:unbind() end
    send_command('unbind !^numpad0')

    info.ws_binds:unbind()
    send_command('unbind %\\\\')

    destroy_state_text()
end

-- Define sets and vars used by this job file.
function init_gear_sets()

    sets.weapons = {}
    sets.weapons.Club    = {main="Maxentius",sub="Genmei Shield"}
    sets.weapons.ClubDW  = {main="Maxentius",sub="Magesmasher +1"}
    sets.weapons.Staff   = {main="Malignance Pole",sub="Alber Strap"}
    sets.weapons.StaffMA = {main="Marin Staff +1",sub="Alber Strap"}
    sets.TreasureHunter = {head="White Rarab Cap +1",waist="Chaac Belt"}

    -- Precast Sets

    sets.precast.FC = {main="Sucellus",sub="Chanter's Shield",ammo="Sapience Orb",
        head="Nahtirah Hat",neck="Voltsurge Torque",ear1="Malignance Earring",ear2="Etiolation Earring",
        body="Inyanga Jubbah +2",hands=gear.tel_hand_enh,ring2="Kishar Ring",
        back=gear.MACape,waist="Shinjutsu-no-Obi +1",legs="Pinga Pants +1",feet="Regal Pumps +1"}
    sets.precast.FC.StatusRemoval = set_combine(sets.precast.FC, {legs="Ebers Pantaloons +1"})
    sets.precast.FC.Cure = set_combine(sets.precast.FC, {main="Ababinili +1",sub="Umbra Strap",
        head="Theophany Cap +2",ear2="Nourishing Earring +1",feet="Vanya Clogs"})
    sets.precast.FC.CureSolace = sets.precast.FC.Cure
    sets.precast.FC.Curaga     = sets.precast.FC.Cure
    sets.precast.FC.CureCheat = {main="Ababinili +1",sub="Clemency Grip",ammo="Sapience Orb",
        head=empty,neck="Voltsurge Torque",ear1="Malignance Earring",ear2="Nourishing Earring +1",
        body=empty,hands=empty,ring1="Vocane Ring +1",ring2="Kishar Ring",
        back=gear.MACape,waist="Embla Sash",legs=empty,feet="Regal Pumps +1"}
    sets.impact = {head=empty,body="Twilight Cloak"}
    sets.precast.FC.Impact = set_combine(sets.precast.FC, sets.impact)
    --sets.dispelga = {main="Daybreak",sub="Ammurapi Shield"}
    --sets.precast.FC.Dispelga = set_combine(sets.precast.FC, sets.dispelga)

    --sets.precast.JA.Devotion = {head="Piety Cap"}
    --sets.precast.JA.Benediction = {body="Piety Briault +3"}

    sets.precast.WS = {ammo="Amar Cluster",
        head="Blistering Sallet +1",neck="Fotia Gorget",ear1="Telos Earring",ear2="Zennaroi Earring",
        body="Ayanmo Corazza +2",hands="Ayanmo Manopolas +2",ring1="Patricius Ring",ring2="Rufescent Ring",
        back="Tantalic Cape",waist="Fotia Belt",legs="Ayanmo Cosciales +2",feet="Ayanmo Gambieras +2"}
    sets.precast.WS['Hexa Strike'] = set_combine(sets.precast.WS, {})
    sets.precast.WS['Mystic Boon'] = set_combine(sets.precast.WS, {})
    sets.precast.WS['Black Halo']  = set_combine(sets.precast.WS, {})
    sets.precast.WS['Brainshaker'] = set_combine(sets.precast.WS, {})
    sets.precast.WS['Shell Crusher'] = set_combine(sets.precast.WS['Brainshaker'], {})
    sets.precast.WS['Flash Nova'] = {ammo="Pemphredo Tathlum",
        head=empty,neck="Sanctity Necklace",ear1="Malignance Earring",ear2="Crematio Earring",
        body="Cohort Cloak +1",hands="Fanatic Gloves",ring1="Freke Ring",ring2="Metamorph Ring +1",
        back=gear.MACape,waist="Orpheus's Sash",legs="Gyve Trousers",feet="Inspirited Boots"}
    sets.precast.WS['Earth Crusher'] = set_combine(sets.precast.WS['Flash Nova'], {ear2="Moonshade Earring"})
    sets.precast.WS['Cataclysm'] = set_combine(sets.precast.WS['Earth Crusher'], {head="Pixie Hairpin +1",ring2="Archon Ring"})

    -- Midcast Sets

    sets.midcast.Cure = {main="Mafic Cudgel",sub="Genmei Shield",ammo="Pemphredo Tathlum",
        head="Vanya Hood",neck="Loricate Torque +1",ear1="Glorious Earring",ear2="Nourishing Earring +1",
        body="Vanya Robe",hands=gear.tel_hand_enh,ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.IdleCape,waist="Shinjutsu-no-Obi +1",legs="Ebers Pantaloons +1",feet="Vanya Clogs"}
    sets.midcast.Curaga = set_combine(sets.midcast.Cure, {})
    sets.midcast.CureSolace = set_combine(sets.midcast.Cure, {main="Vadose Rod",sub="Genmei Shield",body="Ebers Bliaud +1"})
    sets.midcast.CureCheat = {main="Ababinili +1",sub="Umbra Strap",ammo="Pemphredo Tathlum",
        head="Theophany Cap +2",neck="Sanctity Necklace",ear1="Eabani Earring",ear2="Etiolation Earring",
        body="Theophany Briault +2",hands=gear.tel_hand_enh,ring1="Meridian Ring",ring2="Defending Ring",
        back=gear.IdleCape,waist="Gishdubar Sash",legs="Ebers Pantaloons +1",feet="Theophany Duckbills +2"}
    sets.cmp_belt  = {waist="Shinjutsu-no-Obi +1"}
    sets.gishdubar = {waist="Gishdubar Sash"}

    sets.midcast.StatusRemoval = {head="Ebers Cap +1",legs="Ebers Pantaloons +1"}
    sets.midcast.Erase = set_combine(sets.midcast.StatusRemoval, {neck="Cleric's Torque"})
    sets.midcast.Raise = {main="Mafic Cudgel",sub="Genmei Shield",ammo="Pemphredo Tathlum",
        head="Nahtirah Hat",neck="Loricate Torque +1",ear1="Malignance Earring",ear2="Calamitous Earring",
        body="Inyanga Jubbah +2",hands="Inyanga Dastanas +2",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.MACape,waist="Shinjutsu-no-Obi +1",legs="Inyanga Shalwar +2",feet="Regal Pumps +1"}
    sets.midcast.Reraise = set_combine(sets.midcast.Raise, {})
    sets.midcast.Esuna   = set_combine(sets.midcast.Raise, {})
    sets.buff['Divine Caress'] = {hands="Ebers Mitts +1",back="Mending Cape"}
    sets.midcast.Cursna = {main="Ababinili +1",sub="Clemency Grip",ammo="Sapience Orb",
        head="Ebers Cap +1",neck="Malison Medallion",ear1="Malignance Earring",ear2="Etiolation Earring",
        body="Ebers Bliaud +1",hands="Fanatic Gloves",ring1="Ephedra Ring",ring2="Menelaus's Ring",
        back=gear.MACape,waist="Goading Belt",legs="Theophany Pantaloons +2",feet="Vanya Clogs"}

    sets.midcast.EnhancingDuration = {main="Gada",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
        head=gear.tel_head_enh,body=gear.tel_body_enh,hands=gear.tel_hand_enh,
        waist="Embla Sash",legs=gear.tel_legs_enh,feet=gear.tel_feet_enh}
    sets.midcast['Enhancing Magic'] = set_combine(sets.midcast.EnhancingDuration, {
        head="Befouled Crown",neck="Incanter's Torque",ear1="Mimir Earring",ear2="Andoaa Earring",
        body=gear.tel_body_enh,hands="Inyanga Dastanas +2",ring1="Stikini Ring +1",ring2="Defending Ring",
        back="Fi Follet Cape",waist="Olympus Sash",feet="Theophany Duckbills +2"})
    sets.midcast.Auspice   = set_combine(sets.midcast.EnhancingDuration, {feet="Ebers Duckbills +1"})
    sets.midcast.Stoneskin = set_combine(sets.midcast.EnhancingDuration, {neck="Nodens Gorget",legs="Shedir Seraweels"})
    sets.midcast.Aquaveil  = set_combine(sets.midcast.EnhancingDuration, {main="Vadose Rod",sub="Ammurapi Shield",
        head="Chironic Hat",legs="Shedir Seraweels"})
    sets.midcast.Phalanx   = set_combine(sets.midcast['Enhancing Magic'], {head=gear.tel_head_enh})
    sets.midcast.StatBoost = set_combine(sets.midcast.Phalanx, {hands=gear.tel_hand_enh,waist="Embla Sash"})
    sets.midcast.StatBoost.NoGrimoire = set_combine(sets.midcast.Phalanx, {})
    sets.midcast.BarElement = set_combine(sets.midcast['Enhancing Magic'], {main="Beneficus",sub="Ammurapi Shield",
        head="Ebers Cap +1",body="Ebers Bliaud +1",hands="Ebers Mitts +1",legs="Piety Pantaloons +1",feet="Ebers Duckbills +1"})
    sets.midcast.BarElement.NoGrimoire = set_combine(sets.midcast.BarElement, {body=gear.tel_body_enh,waist="Embla Sash"})
    sets.midcast.Regen = set_combine(sets.midcast.EnhancingDuration, {main="Bolelabunga",sub="Ammurapi Shield",
        head="Inyanga Tiara +2",hands="Ebers Mitts +1",legs="Theophany Pantaloons +2"})
    sets.self_refresh = {back="Grapevine Cape",waist="Gishdubar Sash",feet="Inspirited Boots"}
    sets.midcast.FixedPotencyEnhancing = set_combine(sets.midcast.EnhancingDuration, {})

    sets.midcast['Enfeebling Magic'] = {main="Maxentius",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
        head="Theophany Cap +2",neck="Erra Pendant",ear1="Malignance Earring",ear2="Dignitary's Earring",
        body="Theophany Briault +2",hands="Inyanga Dastanas +2",ring1="Stikini Ring +1",ring2="Metamorph Ring +1",
        back="Aurist's Cape +1",waist="Luminary Sash",legs=gear.chir_legs_ma,feet="Theophany Duckbills +2"}
    --sets.midcast.Dispelga = set_combine(sets.midcast['Enfeebling Magic'], sets.dispelga)
    sets.midcast.MndEnfeebles = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast.IntEnfeebles = set_combine(sets.midcast.MndEnfeebles, {})

    sets.midcast['Divine Magic'] = {main="Marin Staff +1",sub="Enki Strap",ammo="Pemphredo Tathlum",
        head=empty,neck="Sanctity Necklace",ear1="Malignance Earring",ear2="Regal Earring",
        body="Cohort Cloak +1",hands=gear.chir_hand_ma,ring1="Freke Ring",ring2="Metamorph Ring +1",
        back=gear.MACape,waist="Refoccilation Stone",legs="Gyve Trousers",feet=gear.chir_feet_ma}
    sets.midcast['Divine Magic'].MB = set_combine(sets.midcast['Divine Magic'], {
        neck="Mizukage-no-Kubikazari",ear2="Static Earring",ring1="Mujin Band",ring2="Locus Ring"})
    sets.midcast.Banish = set_combine(sets.midcast['Divine Magic'], {hands="Fanatic Gloves"})
    sets.orpheus   = {waist="Orpheus's Sash"}
    sets.ele_obi   = {waist="Hachirin-no-Obi"}
    sets.nuke_belt = {waist="Refoccilation Stone"}

    sets.midcast.Repose = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast.Flash = {}

    sets.midcast.Drain = set_combine(sets.midcast['Enfeebling Magic'], {main="Rubicundity",sub="Ammurapi Shield",
        head="Pixie Hairpin +1",ring1="Archon Ring",ring2="Evanescence Ring",waist="Fucho-no-Obi"})
    sets.midcast.Aspir = sets.midcast.Drain
    sets.drain_belt = {waist="Fucho-no-Obi"}

    sets.midcast.Stun = set_combine(sets.midcast.Repose, {})
    sets.midcast['Elemental Magic'] = set_combine(sets.midcast['Divine Magic'], {main="Marin Staff +1",sub="Enki Strap"})
    sets.midcast.Impact = set_combine(sets.midcast.Repose, sets.impact)

    sets.midcast.Utsusemi = {waist="Goading Belt"}

    -- Sets to return to when not performing an action.

    sets.idle = {main="Mafic Cudgel",sub="Genmei Shield",ammo="Homiliary",
        head="Inyanga Tiara +2",neck="Loricate Torque +1",ear1="Eabani Earring",ear2="Etiolation Earring",
        body="Theophany Briault +2",hands="Inyanga Dastanas +2",ring1="Inyanga Ring",ring2="Defending Ring",
        back=gear.IdleCape,waist="Embla Sash",legs="Inyanga Shalwar +2",feet="Herald's Gaiters"}
    sets.idle.PDT  = set_combine(sets.idle, {ring1="Vocane Ring +1",feet="Inyanga Crackows +2"})
    sets.idle.MEVA = set_combine(sets.idle, {body="Inyanga Jubbah +2",legs="Inyanga Shalwar +2",feet="Inyanga Crackows +2"})
    sets.idle.Rf   = set_combine(sets.idle, {feet="Inyanga Crackows +2"})
    sets.latent_refresh = {waist="Fucho-no-obi"}
    sets.buff.doom = {neck="Nicander's Necklace",ring1="Saida Ring",waist="Gishdubar Sash"}

    sets.defense.PDT  = set_combine(sets.idle.PDT, {})
    sets.defense.MEVA = set_combine(sets.idle.MEVA, {})
    sets.defense.MRf  = set_combine(sets.idle.Rf, {})
    sets.Kiting = {feet="Herald's Gaiters"}

    sets.engaged = {ammo="Homiliary",
        head="Ayanmo Zucchetto +2",neck="Lissome Necklace",ear1="Telos Earring",ear2="Zennaroi Earring",
        body="Ayanmo Corazza +2",hands="Ayanmo Manopolas +2",ring1="Chirich Ring +1",ring2="Pernicious Ring",
        back="Tantalic Cape",waist="Goading Belt",legs="Ayanmo Cosciales +2",feet="Ayanmo Gambieras +2"}
    sets.engaged.Acc      = set_combine(sets.engaged,     {ammo="Amar Cluster",hands="Gazu Bracelet +1"})
    sets.engaged.PDef     = set_combine(sets.engaged,     {ring1="Patricius Ring",ring2="Defending Ring"})
    sets.engaged.Acc.PDef = set_combine(sets.engaged.Acc, {ring1="Patricius Ring",ring2="Defending Ring"})
    --sets.dualwield = {back=gear.TPCapeDW} -- applied inside customize_melee_set

    sets.cp = {back="Mecistopins Mantle"}

    -- Sets that depend upon idle sets
    sets.midcast.FastRecast = set_combine(sets.idle.PDT, {waist="Goading Belt"})
    sets.midcast.Dia     = set_combine(sets.idle.PDT, sets.TreasureHunter)
    sets.midcast.Bio     = set_combine(sets.idle.PDT, sets.TreasureHunter)
    sets.midcast.Stone   = set_combine(sets.idle.PDT, sets.TreasureHunter)
    sets.midcast.Stonega = set_combine(sets.idle.PDT, sets.TreasureHunter)
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.
function job_precast(spell, action, spellMap, eventArgs)
    if classes.CustomClass == 'CureCheat' then
        if not (spell.target.type == 'SELF' and spell.english == 'Cure III') then
            classes.CustomClass = nil
        end
    end
end

-- Run after the general precast() is done.
function job_post_precast(spell, action, spellMap, eventArgs)
    if spell.type == 'WeaponSkill' then
        if state.WeaponskillMode.value == 'NoDmg' then
            equip(sets.naked)
        elseif info.magic_ws:contains(spell.english) then
            equip(resolve_ele_belt(spell, sets.ele_obi, sets.nuke_belt, 3))
        end
    end
end

function job_post_midcast(spell, action, spellMap, eventArgs)
    -- Apply Divine Caress boosting items as highest priority over other gear, if applicable.
    if state.Buff['Divine Caress'] and spellMap == 'StatusRemoval' and spell.english ~= 'Erase' then
        equip(sets.buff['Divine Caress'])
        if spell.english == 'Cursna' then
            equip({back=gear.MEVACape})
        end
    elseif S{'Drain','Aspir'}:contains(spellMap) then
        equip(resolve_ele_belt(spell, sets.ele_obi, sets.drain_belt, 5))
    elseif S{'StatBoost','BarElement'}:contains(spellMap) and not buffactive['Light Arts'] then
        equip(sets.midcast[spellMap].NoGrimoire)
    elseif S{'Banish','Holy'}:contains(spellMap) or spell.skill == 'Elemental Magic' then
        if state.MagicBurst.value then equip(sets.midcast['Divine Magic'].MB) end
        equip(resolve_ele_belt(spell, sets.ele_obi, sets.nuke_belt, 3))
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
            if state.Buff.doom then
                equip(sets.buff.doom)
            end
        end
    end
end

function job_aftercast(spell, action, spellMap, eventArgs)
    if spell.interrupted then
        send_command('wait 0.5;gs c update')
        interrupted_message(spell)
    else
        if S{'JobAbility','Scholar'}:contains(spell.type) then
            eventArgs.handled = true
        elseif spell.english == 'Dia II' and state.DiaMsg.value then
            if spell.target.name and spell.target.type == 'MONSTER' then
                send_command('input /p Dia II /')
            end
        elseif spell.type == 'WeaponSkill' and state.WSMsg.value then
            if state.WSMsg.value then
                send_command('input /p '..spell.english)
            end
        elseif spell.english == 'Sleep' or spell.english == 'Sleepga' then
            send_command('timers c "'..spell.english..' ['..spell.target.name..']" 66 down')
        elseif spell.english == 'Sleep II' or spell.english == 'Repose' then
            send_command('timers c "'..spell.english..' ['..spell.target.name..']" 99 down')
        end
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for non-casting events.
-------------------------------------------------------------------------------------------------------------------

-- Called when a player gains or loses a buff.
-- buff == buff gained or lost
-- gain == true if the buff was gained, false if it was lost.
function job_buff_change(buff, gain)
    if buff:lower() == 'sleep' and gain then
        if buffactive['Stoneskin'] then
            add_to_chat(123, 'cancelling stoneskin')
            send_command('cancel Stoneskin')
        end
    elseif state.DefenseMode.value == 'None' and S{'stun','terror','petrification'}:contains(buff:lower()) then
        if gain then
            if state.IdleMode.value == 'MEVA' then
                equip(sets.idle.MEVA)
            else
                equip(sets.idle.PDT)
            end
        elseif not midaction() then
            handle_equipping_gear(player.status)
        end
    end
    if gain and info.chat_notice_buffs:contains(lbuff) then
        add_to_chat(104, 'Gained ['..buff..']')
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
    elseif stateField == 'Ally Cure Keybinds' then
        if newValue then info.ally_keybinds:bind()
        else             info.ally_keybinds:unbind()
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
        if default_spell_map == 'Cure' and state.Buff['Afflatus Solace'] then
            return "CureSolace"
        elseif spell.skill == 'Enfeebling Magic' then
            -- Spells with variable potencies, divided into dINT and dMND spells.
            -- These spells also benefit from RDM gear and WKR shoes.
            if S{'Slow','Paralyze','Addle'}:contains(spell.english) then
                return "MndEnfeebles"
            elseif S{'Blind','Gravity'}:contains(spell.english) then
                return "IntEnfeebles"
            end
        elseif spell.skill == 'Enhancing Magic' then
            if not S{'Regen','BarElement','BarStatus','EnSpell','StatBoost','Teleport'}:contains(default_spell_map) then
                return "FixedPotencyEnhancing"
            end
        end
    end
end

function customize_idle_set(idleSet)
    if has_any_buff_of(S{'petrification','sleep','stun','terror'}) then
        idleSet = set_combine(sets.defense.PDT, {})
    end
    if player.mpp < 60 then
        idleSet = set_combine(idleSet, sets.latent_refresh)
    end
    if S{'Western Adoulin','Eastern Adoulin'}:contains(world.area) then
        if player.wardrobe4["Councilor's Garb"]   then idleSet = set_combine(idleSet, {body="Councilor's Garb"}) end
    end
    if buffactive['Reive Mark'] then
        if player.wardrobe4["Arciela's Grace +1"] then idleSet = set_combine(idleSet, {neck="Arciela's Grace +1"}) end
    end
    if state.CP.value then
        idleSet = set_combine(idleSet, sets.cp)
    end
    return idleSet
end

function customize_melee_set(meleeSet)
    if state.DefenseMode.value == 'None' then
        if state.CombatWeapon.value ~= 'None' then
            meleeSet = set_combine(meleeSet, sets.weapons[state.CombatWeapon.value])
        end
        if state.CombatForm.has_value and state.CombatForm.value == 'DW' then
            meleeSet = set_combine(meleeSet, sets.dualwield)
        end
        if buffactive['elvorseal'] then
            meleeSet = set_combine(meleeSet, {head="Angantyr Beret",
                body="Angantyr Robe",hands="Angantyr Mittens",legs="Angantyr Tights",feet="Angantyr Boots"})
        end
    end
    if has_any_buff_of(S{'petrification','sleep','stun','terror'}) then
        meleeSet = set_combine(sets.defense.PDT, {})
    end
    if state.CP.value then
        meleeSet = set_combine(meleeSet, sets.cp)
    end
    return meleeSet
end

-- Called by the 'update' self-command.
-- Set eventArgs.handled to true if we don't want automatic equipping of gear.
function job_update(cmdParams, eventArgs)
    if midaction() and cmdParams[1] == 'auto' then
        -- don't break midcast for state changes and such
        eventArgs.handled = true
    elseif cmdParams[1] == 'user' then
        state.AriseTold:reset()
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

    msg = msg .. 'Cast['..state.CastingMode.value..'] Idle['..state.IdleMode.value..']'

    if player.sub_job == 'SCH' then
        if buffactive['Light Arts'] or buffactive['Addendum: White'] then
            msg = msg .. ' L.Arts'
        elseif buffactive['Dark Arts'] or buffactive['Addendum: Black'] then
            msg = msg .. ' D.Arts'
        else
            msg = msg .. ' *NoGrimoire*'
        end
    end
    if state.MagicBurst.value then
        msg = msg .. ' MB+'
    end

    if state.Buff['Afflatus Solace'] then
        msg = msg .. ' Solace'
    elseif state.Buff['Afflatus Misery'] then
        msg = msg .. ' Misery'
    else
        msg = msg .. ' *NoAfflatus*'
    end
    if state.WSMsg.value then
        msg = msg .. ' WSMsg'
    end
    if state.DiaMsg.value then
        msg = msg .. ' DiaMsg'
    end
    if state.CP.value then
        msg = msg .. ' CP'
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
    if     cmdParams[1] == 'scholar' then
        handle_stratagems(cmdParams)
    elseif cmdParams[1] == 'CureCheat' then
        classes.CustomClass = 'CureCheat'
        send_command('input /ma "Cure III" <me>')
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

function job_auto_change_target(spell, action, spellMap, eventArgs)
    custom_auto_change_target(spell, action, spellMap, eventArgs)
end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    set_macro_page(1,2)
    send_command('bind !^l input /lockstyleset 2')
end

-- returns a list for use with make_keybind_list
function job_keybinds()
    local bind_command_list = L{
        'bind %`|F12 gs c update user',
        'bind F9   gs c cycle OffenseMode',
        'bind !F9  gs c reset OffenseMode',
        'bind @F9  gs c cycle CombatWeapon',
        'bind !@F9 gs c cycleback CombatWeapon',
        'bind F10  gs c cycle CastingMode',
        'bind !F10 gs c reset CastingMode',
        'bind F11  gs c cycle IdleMode',
        'bind ^F11 gs c set IdleMode PDT',
        'bind !F11 gs c reset IdleMode',
        'bind @F11 gs c toggle Kiting',
        'bind ^space  gs c cycle HybridMode',
        'bind !space  gs c set DefenseMode Physical',
        'bind @space  gs c set DefenseMode Magical',
        'bind !@space gs c reset DefenseMode',
        'bind !w gs c set OffenseMode Normal',
        'bind !@w gs c reset OffenseMode',
        'bind  !^q gs c set CombatWeapon Staff',
        'bind ~!^q gs c set CombatWeapon StaffMA',
        'bind  !^w gs c weap Club',
        'bind ^\\\\  gs c toggle WSMsg',
        'bind ^@\\\\ gs c toggle DiaMsg',
        'bind @z      gs c cycle MagicalDefenseMode',
        'bind !z      gs c toggle MagicBurst',

        'bind ^`    input /ja "Divine Seal" <me>',
        'bind !`    input /ja Devotion',
        'bind @`    input /ja "Divine Caress" <me>',
        'bind ^@`   input /ja Sacrosanctity <me>',
        'bind ^@tab input /ja Asylum <me>',
        'bind !^`   input /ja Benediction <me>',
        'bind ~^tab input /ja "Afflatus Solace" <me>',
        'bind ~^q   input /ja "Afflatus Misery" <me>',

        'bind ^1  input /ma "Dia II"',
        'bind ^2  input /ma Slow',
        'bind ^3  input /ma Paralyze',
        'bind ^4  input /ma Addle',
        'bind ^5  input /ma Repose <stnpc>',
        'bind ^6  input /ma Silence',
        'bind ^backspace input /ma Impact',
        'bind !1  input /ma "Cure III" <stpc>',
        'bind !2  input /ma "Cure IV" <stpc>',
        'bind !3  input /ma "Cure V" <stpc>',
        'bind !4  input /ma "Cure VI" <stpc>',
        'bind !@1 input /ma "Curaga"',
        'bind !@2 input /ma "Curaga II"',
        'bind !@3 input /ma "Curaga III"',
        'bind !@4 input /ma "Curaga IV"',
        'bind !@5 input /ma "Curaga V"',
        'bind !5  input /ma Haste <stpc>',
        'bind !8  input /ma Auspice <me>',
        'bind !9  input /ma "Regen IV" <stpc>',
        'bind !0  input /ma Flash',

        'bind @1  input /ma Poisona',
        'bind @2  input /ma Paralyna',
        'bind @3  input /ma Blindna',
        'bind @4  input /ma Silena',
        'bind @5  input /ma Stona',
        'bind @6  input /ma Viruna',
        'bind @7  input /ma Cursna',
        'bind @F1 input /ma Erase',
        'bind @F2 input /ma Esuna <me>',
        'bind @F3 input /ma Sacrifice',
        'bind @F4 input /ma "Full Cure" <t>',

        'bind ^@1  input /ma Barfira <me>',
        'bind ^@2  input /ma Barblizzara <me>',
        'bind ^@3  input /ma Baraera <me>',
        'bind ^@4  input /ma Barstonra <me>',
        'bind ^@5  input /ma Barthundra <me>',
        'bind ^@6  input /ma Barwatera <me>',
        'bind ~^@1 input /ma Baramnesra <me>',
        'bind ~^@2 input /ma Barparalyzra <me>',
        'bind ~^@3 input /ma Barsilencera <me>',
        'bind ~^@4 input /ma Barpetra <me>',
        'bind ~^@5 input /ma Barvira <me>',
        'bind ~^@6 input /ma Barpoisonra <me>',

        'bind ~^1 input /ma Boost-STR <me>',
        'bind ~^2 input /ma Boost-DEX <me>',
        'bind ~^3 input /ma Boost-INT <me>',
        'bind ~^4 input /ma Boost-MND <me>',
        'bind ~^5 input /ma Boost-VIT <me>',
        'bind ~^6 input /ma Boost-AGI <me>',
        'bind ~^7 input /ma Boost-CHR <me>',

        'bind ^c gs c CureCheat',
        'bind @c input /ma Blink <me>',
        'bind @v input /ma Aquaveil <me>',
        'bind !@g input /ma Stoneskin <me>',
        'bind !b input /ma Repose <t>',    -- for charmed people
        'bind !n input /ma "Holy II" <t>'} -- for charmed people too
        --'bind ^q input /ma Dispelga',

    if     player.sub_job == 'SCH' then
        bind_command_list:extend(L{
            'bind !6   input /ma Aurorastorm <me>',
            'bind !7   input /ma Klimaform <me>',
            'bind ^tab input /ja Sublimation <me>',
            'bind @tab gs c scholar cost',
            'bind @q   gs c scholar speed',
            'bind ^@q  gs c scholar aoe',
            'bind @e   input /ja "Light Arts" <me>',
            'bind !@e  gs c scholar dark',
            'bind !e   input /ma Sleep <stnpc>',
            'bind !d   input /ma Dispel',
            'bind @d   input /ma Aspir',
            'bind !@d  input /ma Drain'})
    elseif player.sub_job == 'RDM' then
        bind_command_list:extend(L{
            'bind !6   input /ma Refresh <stpc>',
            'bind !7   input /ma Flurry <stpc>',
            'bind !@`  input /ja Convert <me>',
            'bind @q   input /ma Bind <stnpc>',
            'bind ^@q  input /ma Gravity <stnpc>',
            'bind ^tab input /ma Dispel',
            'bind !g   input /ma Phalanx <me>',
            'bind !d   input /ma Distract',
            'bind @d   input /ma Frazzle',
            'bind !e   input /ma Sleep <stnpc>',
            'bind !@e  input /ma "Sleep II" <stnpc>'})
    elseif player.sub_job == 'BLM' then
        bind_command_list:extend(L{
            'bind ^tab input /ja "Elemental Seal"',
            'bind @q   input /ma Bind <stnpc>',
            'bind ^@q  input /ma Sleepga <stnpc>',
            'bind !e   input /ma Sleep <stnpc>',
            'bind !@e  input /ma "Sleep II" <stnpc>',
            'bind !d   input /ma Stun'})
    elseif player.sub_job == 'DNC' then
        bind_command_list:extend(L{
            'bind !v  input /ja "Spectral Jig" <me>',
            'bind !d  input /ja "Violent Flourish"',
            'bind !@d input /ja "Animated Flourish"',
            'bind !f  input /ja "Haste Samba" <me>',
            'bind !@f input /ja "Reverse Flourish" <me>',
            'bind !e  input /ja "Box Step"',
            'bind !@e input /ja Quickstep'})
    elseif player.sub_job == 'NIN' then
        bind_command_list:extend(L{
            'bind !e  input /ma "Utsusemi: Ni" <me>',
            'bind !@e input /ma "Utsusemi: Ichi" <me>'})
    elseif player.sub_job == 'SMN' then
        bind_command_list:extend(L{
            'bind !e  input /pet "Mewing Lullaby" <t>',
            'bind @e  input /pet "Aero II" <t>',
            'bind !d  input /pet Assault <t>',
            'bind @d  input /pet Retreat <me>',
            'bind !b  input /ma "Cait Sith" <me>',
            'bind @b  input /ma Garuda <me>',
            'bind !@b input /pet Release <me>'})
    end

    return bind_command_list
end

function init_state_text()
    if hud then return end

    local mb_text_settings    = {flags={draggable=false,bold=true},bg={red=250,green=200,blue=0,alpha=150},text={stroke={width=2}}}
    local ally_text_settings  = {pos={x=-178},flags={draggable=false,right=true,bold=true},bg={alpha=200},text={font='Courier New',size=10}}
    local hyb_text_settings   = {pos={x=130,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local def_text_settings   = {pos={x=172,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local off_text_settings   = {pos={x=172,y=697},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}

    hud = {texts=T{}}
    hud.texts.mb_text   = texts.new('MBurst',         mb_text_settings)
    hud.texts.ally_text = texts.new('AllyCure',       ally_text_settings)
    hud.texts.hyb_text  = texts.new('initializing..', hyb_text_settings)
    hud.texts.def_text  = texts.new('initializing..', def_text_settings)
    hud.texts.off_text  = texts.new('initializing..', off_text_settings)

    -- update infrequently changing text boxes in job_state_change or where they are changed
    function hud_update_on_state_change(stateField)
        if not hud then init_state_text() end

        if not stateField or stateField == 'Magic Burst' then
            hud.texts.mb_text:visible(state.MagicBurst.value)
        end

        if not stateField or stateField == 'Ally Cure Keybinds' then
            hud.texts.ally_text:visible(state.AllyBinds.value)
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
