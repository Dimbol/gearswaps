-- Modified from 'https://github.com/Kinematics/GearSwap-Jobs/blob/master/SCH.lua'
-- TODO test each skillchain and refine timing, particularly 6step and 30k
-- TODO better helix sets
-- TODO klimaform mb sets?
-- TODO check hp stability for sublimation

-- notes:
-- shattersoul has mdef-10 like vidohunir
-- aeolian edge can be used /rdm, or cataclysm /whm
-- maxentius has 4 mb bonus for a two step skillchain

-- skillchains
-- wind    > dark    = gravitation      (earth/dark)
-- light   > stone   = distortion       (water/ice)
-- fire    > thunder = fusion           (light/fire)
-- ice     > water   = fragmentation    (wind/thunder)
-- fire    > stone   = scission         (stone)
-- wind    > stone   = scission         (stone)
-- stone   > water   = reverberation    (water)
-- light   > water   = reverberation    (water)
-- stone   > wind    = detonation       (wind)
-- thunder > wind    = detonation       (wind)
-- dark    > wind    = detonation       (wind)
-- stone   > fire    = liquefaction     (fire)
-- thunder > fire    = liquefaction     (fire)
-- water   > ice     = induration       (ice)
-- water   > thunder = impaction        (thunder)
-- ice     > thunder = impaction        (thunder)
-- dark    > light   = transfixion      (light)
-- ice     > dark    = compression      (dark)
-- light   > dark    = compression      (dark)

-- staff weaponskill properties
-- heavy swing:         impaction
-- rock crusher:        impaction
-- earth crusher:       detonation, impaction
-- starburst/sunburst:  compression, reverberation
-- shell crusher:       detonation
-- full swing:          liquefaction, impaction
-- retribution:         gravitation, reverberation
-- shattersoul:         gravitation, induration
-- omniscience:         gravitation, tranxfixion

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

    state.Buff['Light Arts']      = buffactive['Light Arts'] or false
    state.Buff['Addendum: White'] = buffactive['Addendum: White'] or false
    state.Buff['Dark Arts']       = buffactive['Dark Arts'] or false
    state.Buff['Addendum: Black'] = buffactive['Addendum: Black'] or false
    state.Buff['Enlightenment']   = buffactive['Enlightenment'] or false
    state.Buff['Ebullience']      = buffactive['Ebullience'] or false
    state.Buff['Rapture']         = buffactive['Rapture'] or false
    state.Buff['Perpetuance']     = buffactive['Perpetuance'] or false
    state.Buff['Immanence']       = buffactive['Immanence'] or false
    state.Buff['Penury']          = buffactive['Penury'] or false
    state.Buff['Parsimony']       = buffactive['Parsimony'] or false
    state.Buff['Celerity']        = buffactive['Celerity'] or false
    state.Buff['Alacrity']        = buffactive['Alacrity'] or false

    state.Buff['Klimaform']       = buffactive['Klimaform'] or false
    state.Buff['Sublimation: Activated'] = buffactive['Sublimation: Activated'] or false
    state.Buff['Elemental Seal']  = buffactive['Elemental Seal'] or false
    state.Buff.doom = buffactive.doom or false

    windower.raw_register_event('logout', destroy_state_text)
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
    state.OffenseMode:options('None','Normal')                              -- Cycle with F9, set with !w, unset with !@w
    state.HybridMode:options('Normal','PDef')                               -- Cycle with ^space
    state.CastingMode:options('Normal','MAcc','LowMP','OA')                 -- Cycle with F10, set with !@z, ~^z
    state.IdleMode:options('Normal','MRf')                                  -- Cycle with F11
    state.MagicalDefenseMode:options('MEVA','MRf')                          -- Cycle with @z
    state.CombatWeapon = M{['description']='Combat Weapon'}
    state.CombatWeapon:options('Marin','Akademos','Musa','Pole','Khat','Dagger')   -- Cycle with @F9

    state.AutoSeidr  = M(true,  'Seidr Sometimes')      -- Toggle with ~!@z
    state.AutoSeidr.low_mp = 750
    state.MagicBurst = M(false, 'Magic Burst')          -- Toggle with !z
    state.ZendikIdle = M(false, 'Zendik Sphere')        -- Toggle with ^z
    state.AllyBinds  = M(false, 'Ally Cure Keybinds')   -- Toggle with !^numpad0
    state.DiaMsg     = M(false, 'Dia Message')          -- Toggle with ^\

    state.SCMode     = M('Manual','Auto')               -- Set with !c or !^c
    state.SCDmg      = M(true, 'Damaging Skillchains')  -- Toggle with !\
    state.SCHUD      = M(true, 'Skillchain HUD')        -- Toggle with !^\
    info.skillchains = T{
        ['grav']       = {name='Gravitation',   list=L{{action='Aero'},          {action='Noctohelix'}}},
        ['grav-ws']    = {name='Gravitation',   list=L{{action='Aero'},          {action='Starburst'}}},
        ['dist']       = {name='Distortion',    list=L{{action='Luminohelix'},   {action='Stone'}}},
        ['dist-ws']    = {name='Distortion',    list=L{{action='Omniscience'},   {action='Stone'}}},
        ['fusion']     = {name='Fusion',        list=L{{action='Fire'},          {action='Thunder'}}},
        ['fusion-ws']  = {name='Fusion',        list=L{{action='Fire'},          {action='Rock Crusher'}}},
        ['fusion-dag'] = {name='Fusion',        list=L{{action='Fire'},          {action='Cyclone'}}},
        ['frag']       = {name='Fragmentation', list=L{{action='Blizzard'},      {action='Water'}}},
        ['frag-ws']    = {name='Fragmentation', list=L{{action='Shattersoul'},   {action='Water'}}},
        ['earth']      = {name='Scission',      list=L{{action='Aero'},          {action='Stone'}}},
        ['earth-ws']   = {name='Scission',      list=L{{action='Shell Crusher'}, {action='Stone'}}},
        ['water']      = {name='Reverberation', list=L{{action='Stone'},         {action='Water'}}},
        ['water-ws']   = {name='Reverberation', list=L{{action='Omniscience'},   {action='Water'}}},
        ['wind']       = {name='Detonation',    list=L{{action='Stone'},         {action='Aero'}}},
        ['wind-ws']    = {name='Detonation',    list=L{{action='Rock Crusher'},  {action='Aero'}}},
        ['fire']       = {name='Liquefaction',  list=L{{action='Stone'},         {action='Fire'}}},
        ['fire-ws']    = {name='Liquefaction',  list=L{{action='Rock Crusher'},  {action='Fire'}}},
        ['ice']        = {name='Induration',    list=L{{action='Water'},         {action='Blizzard'}}},
        ['ice-ws']     = {name='Induration',    list=L{{action='Water'},         {action='Shattersoul'}}},
        ['thunder']    = {name='Impaction',     list=L{{action='Water'},         {action='Thunder'}}},
        ['thunder-ws'] = {name='Impaction',     list=L{{action='Shattersoul'},   {action='Thunder'}}},
        ['light']      = {name='Transfixion',   list=L{{action='Noctohelix'},    {action='Luminohelix'}}},
        ['light-ws']   = {name='Transfixion',   list=L{{action='Starburst'},     {action='Luminohelix'}}},
        ['dark']       = {name='Compression',   list=L{{action='Blizzard'},      {action='Noctohelix'}}},
        ['dark-ws']    = {name='Compression',   list=L{{action='Omniscience'},   {action='Noctohelix'}}},
        ['30k']        = {name='30k Combo',     list=L{{action='Luminohelix'}, {action='Stone'}, {action='Omniscience'}}},
        ['6step']      = {name='Six Step?',     list=L{{action='Stone'}, {action='Aero'}, {action='Stone'},
                                                       {action='Aero'}, {action='Stone'}, {action='Aero'},
                                                       {action='Starburst'}}}}
    info.sc_step_waits = T{} -- TODO test for and place exceptions to default wait times here
    skillchain_state_updates(nil, 'init')
    init_state_text()
    hud_update_on_state_change()

    info.addendum_spells = T{'Poisona','Paralyna','Blindna','Silena','Stona','Viruna','Cursna','Erase',
                             'Raise II','Raise III','Reraise','Reraise II','Reraise III',
                             'Stone IV','Water IV','Aero IV','Fire IV','Blizzard IV','Thunder IV',
                             'Stone V','Water V','Aero V','Fire V','Blizzard V','Thunder V',
                             'Sleep','Sleep II','Dispel'}

    -- Augmented items get variables for convenience and specificity
    gear.MACape   = {name="Lugh's Cape", augments={'MND+20','Mag. Acc+20 /Mag. Dmg.+20','"Fast Cast"+10','Phys. dmg. taken-10%'}}
    gear.NukeCape = {name="Lugh's Cape",
        augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','Magic Damage +10','"Mag.Atk.Bns."+10','Phys. dmg. taken-10%'}}
    gear.IdleCape = {name="Lugh's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Enmity-10','Phys. dmg. taken-10%'}}
    gear.TPCape   = {name="Lugh's Cape", augments={'DEX+20','Accuracy+20 Attack+20','"Dbl.Atk."+10','Phys. dmg. taken-10%'}}
    gear.HDurCape  = {name="Bookworm's Cape", augments={'INT+3','Helix eff. dur. +20'}}
    gear.RegenCape = {name="Bookworm's Cape", augments={'INT+4','MND+5','"Regen" potency+10'}}

    gear.chir_hand_ma  = {name="Chironic Gloves", augments={'Mag. Acc.+23 "Mag.Atk.Bns."+23','Enmity-2','Mag. Acc.+10','"Mag.Atk.Bns."+13'}}
    gear.chir_legs_ma  = {name="Chironic Hose", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25','Haste+1','CHR+13','Mag. Acc.+13'}}
    gear.chir_feet_ma  = {name="Chironic Slippers", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25','Spell interruption rate down -10%','MND+11'}}
    gear.mer_head_rf   = {name="Merlinic Hood", augments={'"Refresh"+2'}}
    gear.mer_head_fc   = {name="Merlinic Hood", augments={'Mag. Acc.+19 "Mag.Atk.Bns."+19','"Fast Cast"+6','MND+3'}}
    gear.mer_head_mb   = {name="Merlinic Hood", augments={'"Mag.Atk.Bns."+27','Magic burst dmg.+10%','Mag. Acc.+15'}}
    gear.mer_body_mb9  = {name="Merlinic Jubbah", augments={'Mag. Acc.+21 "Mag.Atk.Bns."+21','Magic burst dmg.+9%'}}
    gear.mer_body_mb5  = {name="Merlinic Jubbah",
        augments={'Mag. Acc.+23 "Mag.Atk.Bns."+23','Magic burst dmg.+5%','CHR+10','Mag. Acc.+10','"Mag.Atk.Bns."+11'}}
    gear.mer_hand_rf   = {name="Merlinic Dastanas", augments={'"Refresh"+2'}}
    gear.mer_hand_phlx = {name="Merlinic Dastanas", augments={'Phalanx +3'}}
    gear.mer_legs_rf   = {name="Merlinic Shalwar", augments={'"Refresh"+2'}}
    gear.mer_legs_th   = {name="Merlinic Shalwar", augments={'"Treasure Hunter"+2'}}
    gear.mer_feet_rf   = {name="Merlinic Crackows", augments={'"Refresh"+2'}}
    gear.mer_feet_fc   = {name="Merlinic Crackows", augments={'Mag. Acc.+11','"Fast Cast"+6'}}
    gear.mer_feet_dr   = {name="Merlinic Crackows", augments={'Mag. Acc.+28','"Drain" and "Aspir" potency +11','"Mag.Atk.Bns."+7'}}
    gear.mer_feet_ws   = {name="Merlinic Crackows",
        augments={'DEX+9','Enmity+1','Weapon skill damage +6%','Accuracy+16 Attack+16','Mag. Acc.+19 "Mag.Atk.Bns."+19'}}
    gear.tel_head_enh  = {name="Telchine Cap", augments={'Mag. Evasion+22','"Conserve MP"+5','Enh. Mag. eff. dur. +10'}}
    gear.tel_body_enh  = {name="Telchine Chas.", augments={'Mag. Evasion+19','"Conserve MP"+5','Enh. Mag. eff. dur. +10'}}
    gear.tel_hand_enh  = {name="Telchine Gloves", augments={'Mag. Evasion+19','"Fast Cast"+5','Enh. Mag. eff. dur. +10'}}
    gear.tel_legs_enh  = {name="Telchine Braconi", augments={'Mag. Evasion+19','"Conserve MP"+3','Enh. Mag. eff. dur. +10'}}
    gear.tel_feet_enh  = {name="Telchine Pigaches", augments={'Mag. Evasion+17','"Conserve MP"+5','Enh. Mag. eff. dur. +10'}}

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
        'bind ^numpad7 input /ma Paralyna  <a10>',
        'bind ^numpad8 input /ma Silena    <a10>',
        'bind ^numpad9 input /ma Cursna    <a10>',
        'bind !numpad7 input /ma Paralyna  <a20>',
        'bind !numpad8 input /ma Silena    <a20>',
        'bind !numpad9 input /ma Cursna    <a20>'})
    send_command('bind !^numpad0 gs c toggle AllyBinds')

    info.ws_binds = make_keybind_list(T{
        ['Staff']=L{
            'bind !^1 input /ws "Shell Crusher"',
            'bind !^2 input /ws "Omniscience"',
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
        {['Akademos']='Staff',['Marin']='Staff',['Musa']='Staff',['Pole']='Staff',['Khat']='Staff',['Dagger']='Dagger'})
    info.ws_binds:bind(state.CombatWeapon)
    send_command('bind %\\\\ gs c ListWS')

    info.recast_ids = L{{name="Strats",id=231}}
    if     player.sub_job == 'RDM' then
        info.recast_ids:append({name="Convert",id=49})
    elseif player.sub_job == 'WHM' then
        info.recast_ids:append({name="D.Seal",id=26})
    elseif player.sub_job == 'BLM' then
        info.recast_ids:append({name="E.Seal",id=38})
    end

    select_default_macro_book()

    -- give monkey_check_spell access to the gearswap environment, plus our state vars
    local monkey_env = {state=state}
    setmetatable(monkey_env, {__index = gearswap})
    gearswap.setfenv(monkey_check_spell, monkey_env)

    -- monkey patch gearswap.check_spell
    gearswap_check_spell = gearswap_check_spell or gearswap.check_spell
    gearswap.check_spell = monkey_check_spell
end

-- Called when this job file is unloaded (eg: job change)
function user_unload()
    info.keybinds:unbind()

    if state.AllyBinds.value then info.ally_keybinds:unbind() end
    send_command('unbind !^numpad0')

    info.ws_binds:unbind()
    send_command('unbind %\\\\')

    destroy_state_text()

    if gearswap.check_spell == monkey_check_spell then
        gearswap.check_spell = gearswap_check_spell
    end
end

-- Define sets and vars used by this job file.
function init_gear_sets()

    sets.weapons = {}
    sets.weapons.Akademos = {main="Akademos",sub="Enki Strap"}
    sets.weapons.Marin    = {main="Marin Staff +1",sub="Enki Strap"}
    sets.weapons.Musa     = {main="Musa",sub="Khonsu"}
    sets.weapons.Pole     = {main="Malignance Pole",sub="Khonsu"}
    sets.weapons.Khat     = {main="Khatvanga",sub="Khonsu"}
    sets.weapons.Dagger   = {main="Malevolence",sub="Ammurapi Shield"}

    sets.TreasureHunter = {head="White Rarab Cap +1",waist="Chaac Belt",legs=gear.mer_legs_th}

    sets.buff['Perpetuance'] = {hands="Arbatel Bracers +1"} -- duration x2.55
    sets.buff['Penury']      = {legs="Arbatel Pants +1"}    -- caps conserve mp
    sets.buff['Parsimony']   = {legs="Arbatel Pants +1"}    -- caps conserve mp
    sets.buff['Celerity']    = {feet="Pedagogy Loafers +3"} -- cap breaking recast reduction
    sets.buff['Alacrity']    = {feet="Pedagogy Loafers +3"} -- cap breaking recast reduction
    sets.buff['Addendum']    = {body="Arbatel Gown +1"}     -- cap breaking enmity-22 for addendum spells
    sets.buff['Klimaform']   = {feet="Arbatel Loafers +1"}  -- damage x1.15

    ---- Precast Sets ----
    sets.precast.JA['Tabula Rasa'] = {legs="Pedagogy Pants +3"}

    sets.precast.FC = {main="Musa",sub="Clerisy Strap",ammo="Sapience Orb",
        head=gear.mer_head_fc,neck="Voltsurge Torque",ear1="Malignance Earring",ear2="Etiolation Earring",
        body="Zendik Robe",hands="Academic's Bracers +3",ring1="Etana Ring",ring2="Kishar Ring",
        back=gear.MACape,waist="Shinjutsu-no-Obi +1",legs="Pinga Pants +1",feet=gear.mer_feet_fc}
    sets.precast.FC['Elemental Magic'] = set_combine(sets.precast.FC, {ear2="Barkarole Earring"})
    sets.precast.FC.Cure = set_combine(sets.precast.FC, {ear2="Mendicant's Earring",feet="Vanya Clogs"})
    sets.precast.FC.Curaga = sets.precast.FC.Cure
    sets.precast.FC.CureCheat = set_combine(sets.precast.FC.Cure, {main="Oranyan",sub="Clerisy Strap",
        body="Jhakri Robe +2",hands="Jhakri Cuffs +2",ring1="Stikini Ring +1",legs=empty})
    sets.grim_fc_rdm = {head="Pedagogy Mortarboard +1",feet="Academic's Loafers +3"}
    sets.grim_fc_other = {feet="Academic's Loafers +3"}
    sets.impact = {head=empty,body="Twilight Cloak"}
    sets.precast.FC.Impact = set_combine(sets.precast.FC['Elemental Magic'], sets.impact)
    --sets.dispelga = {main="Daybreak",sub="Ammurapi Shield"}
    --sets.precast.FC.Dispelga = set_combine(sets.precast.FC, sets.dispelga)

    sets.precast.WS = {ammo="Amar Cluster",
        head="Blistering Sallet +1",neck="Fotia Gorget",ear1="Telos Earring",ear2="Dignitary's Earring",
        body="Jhakri Robe +2",hands="Gazu Bracelet +1",ring1="Chirich Ring +1",ring2="Rufescent Ring",
        back=gear.TPCape,waist="Fotia Belt",legs="Jhakri Slops +2",feet="Jhakri Pigaches +2"}

    sets.precast.WS['Rock Crusher'] = {ammo="Ghastly Tathlum +1",
        head=empty,neck="Sanctity Necklace",ear1="Malignance Earring",ear2="Regal Earring",
        body="Cohort Cloak +1",hands="Amalric Gages +1",ring1="Metamorph Ring +1",ring2="Freke Ring",
        back=gear.NukeCape,waist="Orpheus's Sash",legs="Pedagogy Pants +3",feet="Pedagogy Loafers +3"}
    sets.precast.WS['Earth Crusher'] = set_combine(sets.precast.WS['Rock Crusher'],  {ear2="Moonshade Earring"})
    sets.precast.WS.Starburst        = set_combine(sets.precast.WS['Earth Crusher'], {})
    sets.precast.WS.Sunburst         = sets.precast.WS.Starburst
    sets.precast.WS.Omniscience      = set_combine(sets.precast.WS['Rock Crusher'],
        {head="Pixie Hairpin +1",body="Jhakri Robe +2",ring1="Archon Ring"})
    sets.precast.WS.Cataclysm        = set_combine(sets.precast.WS.Omniscience,      {ear2="Moonshade Earring"})
    sets.precast.WS['Aeolian Edge']  = set_combine(sets.precast.WS['Earth Crusher'], {})
    sets.precast.WS.Cyclone          = sets.precast.WS['Aeolian Edge']

    sets.precast.WS['Shell Crusher'] = set_combine(sets.precast.WS, {neck="Sanctity Necklace",ring2="Etana Ring",waist="Acuity Belt +1"})
    sets.precast.WS.Shattersoul      = set_combine(sets.precast.WS['Shell Crusher'], {})
    sets.precast.WS.Brainshaker      = set_combine(sets.precast.WS['Shell Crusher'], {})

    sets.precast.WS.Myrkr = {ammo="Ghastly Tathlum +1",
        head="Amalric Coif +1",neck="Sanctity Necklace",ear1="Moonshade Earring",ear2="Etiolation Earring",
        body="Academic's Gown +3",hands="Pedagogy Bracers +3",ring1="Mephitas's Ring +1",ring2="Sangoma Ring",
        back="Tantalic Cape",waist="Shinjutsu-no-Obi +1",legs="Psycloth Lappas",feet="Arbatel Loafers +1"}

    ---- Midcast Sets ----
    sets.midcast.Cure = {main="Malignance Pole",sub="Khonsu",ammo="Pemphredo Tathlum",
        head="Vanya Hood",neck="Incanter's Torque",ear1="Calamitous Earring",ear2="Mendicant's Earring",
        body="Zendik Robe",hands="Academic's Bracers +3",ring1="Vocane Ring +1",ring2="Defending Ring",
        back="Solemnity Cape",waist="Shinjutsu-no-Obi +1",legs="Academic's Pants +3",feet="Vanya Clogs"}
    sets.midcast.Curaga = sets.midcast.Cure
    sets.midcast.Cure.Chatoyant = {main="Chatoyant Staff",sub="Khonsu",ammo="Pemphredo Tathlum",
        head="Hike Khat +1",neck="Loricate Torque +1",ear1="Calamitous Earring",ear2="Mendicant's Earring",
        body="Vanya Robe",hands="Pedagogy Bracers +3",ring1="Vocane Ring +1",ring2="Defending Ring",
        back="Solemnity Cape",waist="Hachirin-no-Obi",legs="Academic's Pants +3",feet="Vanya Clogs"}
    sets.midcast.CureCheat = {main="Septoptic",sub="Culminus",ammo="Pemphredo Tathlum",
        head="Vanya Hood",neck="Sanctity Necklace",ear1="Eabani Earring",ear2="Etiolation Earring",
        body="Vanya Robe",hands=gear.tel_hand_enh,ring1="Etana Ring",ring2="Meridian Ring",
        back="Tantalic Cape",waist="Gishdubar Sash",legs="Academic's Pants +3",feet="Vanya Clogs"}
    sets.cmp_belt  = {waist="Shinjutsu-no-Obi +1"}
    sets.gishdubar = {waist="Gishdubar Sash"}

    sets.midcast.Raise = {main="Malignance Pole",sub="Khonsu",ammo="Pemphredo Tathlum",
        head=gear.tel_head_enh,neck="Incanter's Torque",ear1="Calamitous Earring",ear2="Gifted Earring",
        body="Zendik Robe",hands="Academic's Bracers +3",ring1="Vocane Ring +1",ring2="Defending Ring",
        back="Solemnity Cape",waist="Shinjutsu-no-Obi +1",legs="Gyve Trousers",feet=gear.mer_feet_fc}
    sets.midcast.StatusRemoval = set_combine(sets.midcast.Raise, {})
    sets.midcast.Erase         = set_combine(sets.midcast.StatusRemoval, {waist="Goading Belt"})
    sets.midcast.Cursna = {main="Malignance Pole",sub="Khonsu",ammo="Sapience Orb",
        head="Hike Khat +1",neck="Malison Medallion",ear1="Malignance Earring",ear2="Lugalbanda Earring",
        body="Pedagogy Gown +3",hands="Gazu Bracelet +1",ring1="Ephedra Ring",ring2="Menelaus's Ring",
        back=gear.MACape,waist="Embla Sash",legs="Academic's Pants +3",feet="Vanya Clogs"}

    sets.midcast.EnhancingDuration = {main="Musa",sub="Khonsu",ammo="Pemphredo Tathlum",
        head=gear.tel_head_enh,neck="Loricate Torque +1",ear1="Calamitous Earring",ear2="Etiolation Earring",
        body="Pedagogy Gown +3",hands=gear.tel_hand_enh,ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.IdleCape,waist="Embla Sash",legs=gear.tel_legs_enh,feet=gear.tel_feet_enh}
    sets.midcast['Enhancing Magic'] = {main="Musa",sub="Khonsu",ammo="Pemphredo Tathlum",
        head="Befouled Crown",neck="Incanter's Torque",ear1="Andoaa Earring",ear2="Mimir Earring",
        body="Pedagogy Gown +3",hands="Chironic Gloves",ring1="Stikini Ring +1",ring2="Defending Ring",
        back="Fi Follet Cape",waist="Olympus Sash",legs="Shedir Seraweels",feet="Regal Pumps +1"}
    sets.midcast.Phalanx = {main="Musa",sub="Khonsu",ammo="Pemphredo Tathlum",
        head=gear.tel_head_enh,neck="Incanter's Torque",ear1="Calamitous Earring",ear2="Mimir Earring",
        body="Pedagogy Gown +3",hands=gear.mer_hand_phlx,ring1="Stikini Ring +1",ring2="Defending Ring",
        back=gear.IdleCape,waist="Embla Sash",legs=gear.tel_legs_enh,feet=gear.tel_feet_enh}
    sets.midcast.Phalanx.AoE = set_combine(sets.midcast.Phalanx,     {hands=gear.tel_hand_enh})
    sets.midcast.Embrava     = set_combine(sets.midcast.Phalanx.AoE, {})
    sets.midcast.BarElement  = set_combine(sets.midcast.EnhancingDuration, {ear2="Mimir Earring",legs="Shedir Seraweels"})
    sets.midcast.BarStatus   = set_combine(sets.midcast.EnhancingDuration, {ear2="Mimir Earring"})
    sets.midcast.Storm       = set_combine(sets.midcast.EnhancingDuration, {feet="Pedagogy Loafers +3"})
    sets.midcast.Refresh     = set_combine(sets.midcast.EnhancingDuration, {head="Amalric Coif +1"})
    sets.midcast.Stoneskin   = set_combine(sets.midcast.EnhancingDuration, {neck="Nodens Gorget",legs="Shedir Seraweels"})
    sets.midcast.Aquaveil    = set_combine(sets.midcast.EnhancingDuration, {main="Vadose Rod",sub="Ammurapi Shield",
        head="Amalric Coif +1",legs="Shedir Seraweels"})
    sets.midcast.Regen = {main="Musa",sub="Khonsu",ammo="Pemphredo Tathlum",
        head="Arbatel Bonnet +1",neck="Loricate Torque +1",ear1="Calamitous Earring",ear2="Gifted Earring",
        body=gear.tel_body_enh,hands=gear.tel_hand_enh,ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.RegenCape,waist="Embla Sash",legs=gear.tel_legs_enh,feet=gear.tel_feet_enh}
    sets.midcast.FixedPotencyEnhancing = sets.midcast.EnhancingDuration
    sets.midcast.Klimaform = set_combine(sets.midcast.Raise, {})

    sets.midcast['Elemental Magic'] = {main="Marin Staff +1",sub="Enki Strap",ammo="Ghastly Tathlum +1",
        head=empty,neck="Argute Stole +2",ear1="Malignance Earring",ear2="Regal Earring",
        body="Cohort Cloak +1",hands="Amalric Gages +1",ring1="Metamorph Ring +1",ring2="Freke Ring",
        back=gear.NukeCape,waist="Refoccilation Stone",legs="Pedagogy Pants +3",feet="Pedagogy Loafers +3"}
    sets.midcast['Elemental Magic'].MAcc  = set_combine(sets.midcast['Elemental Magic'], {sub="Khonsu",
        ring1="Stikini Ring +1",ring2="Metamorph Ring +1"})
    sets.midcast['Elemental Magic'].LowMP = set_combine(sets.midcast['Elemental Magic'], {head="Jhakri Coronal +2",body="Seidr Cotehardie"})
    sets.midcast['Elemental Magic'].OA = {ammo="Seraphic Ampulla",
        head="Mallquis Chapeau +2",neck="Sanctity Necklace",ear1="Malignance Earring",ear2="Telos Earring",
        body="Seidr Cotehardie",hands="Amalric Gages +1",ring1="Chirich Ring +1",ring2="Freke Ring",
        back=gear.NukeCape,waist="Oneiros Rope",legs="Perdition Slops",feet="Pedagogy Loafers +3"}
    sets.midcast['Elemental Magic'].MB = {main="Marin Staff +1",sub="Enki Strap",ammo="Ghastly Tathlum +1",
        head=gear.mer_head_mb,neck="Argute Stole +2",ear1="Malignance Earring",ear2="Static Earring",
        body=gear.mer_body_mb5,hands="Amalric Gages +1",ring1="Mujin Band",ring2="Locus Ring",
        back=gear.NukeCape,waist="Refoccilation Stone",legs="Pedagogy Pants +3",feet="Jhakri Pigaches +2"}
    sets.midcast['Elemental Magic'].MAcc.MB        = set_combine(sets.midcast['Elemental Magic'].MB, {sub="Khonsu"})
    sets.midcast['Elemental Magic'].LowMP.MB       = set_combine(sets.midcast['Elemental Magic'].MB, {body="Seidr Cotehardie"})

    sets.midcast['Elemental Magic'].MB.Marin       = set_combine(sets.midcast['Elemental Magic'].MB,       {main="Marin Staff +1"})
    sets.midcast['Elemental Magic'].MAcc.MB.Marin  = set_combine(sets.midcast['Elemental Magic'].MAcc.MB,  {main="Marin Staff +1"})
    sets.midcast['Elemental Magic'].LowMP.MB.Marin = set_combine(sets.midcast['Elemental Magic'].LowMP.MB, {main="Marin Staff +1"})

    sets.midcast.Helix = {main="Maxentius",sub="Culminus",ammo="Ghastly Tathlum +1",
        head=empty,neck="Argute Stole +2",ear1="Malignance Earring",ear2="Barkarole Earring",
        body="Cohort Cloak +1",hands="Mallquis Cuffs +2",ring1="Mallquis Ring",ring2="Freke Ring",
        back=gear.NukeCape,waist="Refoccilation Stone",legs="Mallquis Trews +2",feet="Mallquis Clogs +2"}
    sets.midcast.Helix.MAcc = set_combine(sets.midcast.Helix, {main="Marin Staff +1",sub="Khonsu"})
    sets.midcast.Helix.MB   = set_combine(sets.midcast.Helix, {
        head="Mallquis Chapeau +2",ear2="Static Earring",
        body=gear.mer_body_mb5,hands="Amalric Gages +1",ring1="Mujin Band",ring2="Locus Ring",feet="Jhakri Pigaches +2"})
    sets.midcast.Helix.MAcc.MB       = set_combine(sets.midcast.Helix.MB,      {main="Marin Staff +1",sub="Khonsu"})
    sets.midcast.Helix.MB.Marin      = set_combine(sets.midcast.Helix.MB,      {main="Marin Staff +1",sub="Alber Strap",
        head=gear.mer_head_mb,ear2="Barkarole Earring"})
    sets.midcast.Helix.MAcc.MB.Marin = set_combine(sets.midcast.Helix.MAcc.MB, {main="Marin Staff +1",sub="Khonsu"})
    sets.midcast.Helix.NoDmg = set_combine(sets.naked, {main="Malignance Pole",sub="Khonsu",ammo="Sapience Orb",
        neck="Voltsurge Torque",ear2="Etiolation Earring",ring1="Vocane Ring +1",ring2="Defending Ring",
        hands="Gazu Bracelet +1",back=gear.MACape,waist="Goading Belt"})

    sets.midcast.LowTierNuke = sets.midcast.Helix

    sets.midcast['Anemohelix']         = set_combine(sets.midcast.Helix,      {main="Marin Staff +1",sub="Alber Strap"})
    sets.midcast['Anemohelix'].MAcc    = set_combine(sets.midcast.Helix.MAcc, {main="Marin Staff +1",sub="Khonsu"})
    sets.midcast['Anemohelix'].MB      = sets.midcast.Helix.MB.Marin
    sets.midcast['Anemohelix'].MAcc.MB = sets.midcast.Helix.MAcc.MB.Marin
    sets.midcast['Anemohelix II'] = sets.midcast['Anemohelix']

    sets.midcast['Luminohelix']         = set_combine(sets.midcast.Helix,         {})
    sets.midcast['Luminohelix'].MAcc    = set_combine(sets.midcast.Helix.MAcc,    {})
    sets.midcast['Luminohelix'].MB      = set_combine(sets.midcast.Helix.MB,      {})
    sets.midcast['Luminohelix'].MAcc.MB = set_combine(sets.midcast.Helix.MAcc.MB, {})
    sets.midcast['Luminohelix II'] = sets.midcast['Luminohelix']

    sets.darkdmg = {head="Pixie Hairpin +1",ring1="Archon Ring"}
    sets.midcast['Noctohelix']         = set_combine(sets.midcast.Helix,         sets.darkdmg, {body="Jhakri Robe +2"})
    sets.midcast['Noctohelix'].MAcc    = set_combine(sets.midcast.Helix.MAcc,    sets.darkdmg, {body="Jhakri Robe +2"})
    sets.midcast['Noctohelix'].MB      = set_combine(sets.midcast.Helix.MB,      sets.darkdmg, {body=gear.mer_body_mb9})
    sets.midcast['Noctohelix'].MAcc.MB = set_combine(sets.midcast.Helix.MAcc.MB, sets.darkdmg, {body=gear.mer_body_mb9})
    sets.midcast['Noctohelix II'] = sets.midcast['Noctohelix']

    sets.midcast.Kaustra         = set_combine(sets.midcast['Elemental Magic'],  sets.darkdmg, {body="Jhakri Robe +2"})
    sets.midcast.Kaustra.MAcc    = set_combine(sets.midcast.Kaustra, {sub="Khonsu"})
    sets.midcast.Kaustra.MB      = sets.midcast['Noctohelix'].MB
    sets.midcast.Kaustra.MAcc.MB = sets.midcast['Noctohelix'].MAcc.MB

    sets.midcast.Impact    = set_combine(sets.midcast['Elemental Magic'].MAcc, {ring1="Archon Ring"}, sets.impact)
    sets.midcast.Impact.OA = set_combine(sets.midcast['Elemental Magic'].OA,   {ring2="Archon Ring"}, sets.impact)
    sets.midcast.Impact.MB = set_combine(sets.midcast.Impact, {})

    sets.orpheus   = {waist="Orpheus's Sash"}
    sets.ele_obi   = {waist="Hachirin-no-Obi"}
    sets.nuke_belt = {waist="Refoccilation Stone"}

    sets.midcast.Drain = {main="Rubicundity",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
        head="Pixie Hairpin +1",neck="Erra Pendant",ear1="Malignance Earring",ear2="Barkarole Earring",
        body="Zendik Robe",hands="Gazu Bracelet +1",ring1="Archon Ring",ring2="Evanescence Ring",
        back=gear.MACape,waist="Fucho-no-Obi",legs="Pedagogy Pants +3",feet=gear.mer_feet_dr}
    sets.midcast.Drain.MAcc = set_combine(sets.midcast.Drain, {
        head="Academic's Mortarboard +3",ear2="Regal Earring",body="Academic's Gown +3",hands="Academic's Bracers +3"})
    sets.midcast.Aspir = sets.midcast.Drain
    sets.drain_belt = {waist="Fucho-no-Obi"}

    sets.midcast['Enfeebling Magic'] = {main="Musa",sub="Khonsu",ammo="Pemphredo Tathlum",
        head=empty,neck="Argute Stole +2",ear1="Malignance Earring",ear2="Regal Earring",
        body="Cohort Cloak +1",hands="Academic's Bracers +3",ring1="Metamorph Ring +1",ring2="Stikini Ring +1",
        back="Aurist's Cape +1",waist="Acuity Belt +1",legs="Academic's Pants +3",feet="Academic's Loafers +3"}
    sets.midcast.Dispel      = set_combine(sets.midcast['Enfeebling Magic'], {hands="Gazu Bracelet +1",waist="Shinjutsu-no-Obi +1"})
    sets.midcast.Dispel.MAcc = set_combine(sets.midcast['Enfeebling Magic'], {})
    --sets.midcast.Dispelga = set_combine(sets.midcast.Dispel, sets.dispelga)
    sets.midcast.Silence  = set_combine(sets.midcast['Enfeebling Magic'], {waist="Luminary Sash",legs=gear.chir_legs_ma})
    sets.midcast.Slow     = set_combine(sets.midcast['Enfeebling Magic'], {main="Maxentius",sub="Ammurapi Shield",waist="Luminary Sash"})
    sets.midcast.Paralyze = set_combine(sets.midcast.Slow, {legs=gear.chir_legs_ma})

    sets.midcast.Sleep    = set_combine(sets.midcast['Enfeebling Magic'], {ring2="Kishar Ring"})
    sets.midcast.Repose   = sets.midcast.Sleep
    sets.midcast.Break    = sets.midcast.Sleep
    sets.midcast.Bind     = sets.midcast.Sleep
    sets.midcast.Gravity  = sets.midcast.Sleep

    sets.midcast.ElementalEnfeeble = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast['Dark Magic']     = set_combine(sets.midcast['Enfeebling Magic'], {
        head="Academic's Mortarboard +3",body="Academic's Gown +3",legs="Pedagogy Pants +3"})
    sets.midcast['Divine Magic']   = set_combine(sets.midcast['Dark Magic'], {})

    sets.midcast.Stun = set_combine(sets.midcast['Dark Magic'], {back=gear.MACape,waist="Goading Belt"})

    ---- Sets to return to when not performing an action ----
    sets.idle = {main="Malignance Pole",sub="Khonsu",ammo="Homiliary",
        head=gear.mer_head_rf,neck="Loricate Torque +1",ear1="Eabani Earring",ear2="Lugalbanda Earring",
        body="Jhakri Robe +2",hands=gear.mer_hand_rf,ring1="Stikini Ring +1",ring2="Defending Ring",
        back=gear.IdleCape,waist="Porous Rope",legs=gear.mer_legs_rf,feet="Herald's Gaiters"}
    sets.idle.PDT = set_combine(sets.idle, {main="Malignance Pole",sub="Oneiros Grip",
        head="Hike Khat +1",body="Mallquis Saio +2",ring1="Vocane Ring +1",feet=gear.mer_feet_rf})
	sets.idle.MRf  = set_combine(sets.idle, {feet=gear.mer_feet_rf})
    sets.idle.MEVA = set_combine(sets.idle.PDT, {head="Academic's Mortarboard +3",body="Pedagogy Gown +3",legs="Pinga Pants +1"})
    sets.zendik           = {body="Zendik Robe"}
    sets.latent_refresh   = {waist="Fucho-no-obi"}
    sets.buff.Sublimation = {head="Academic's Mortarboard +3",body="Pedagogy Gown +3",waist="Embla Sash"}
    sets.buff.doom        = {neck="Nicander's Necklace",ring1="Saida Ring",ring2="Defending Ring",waist="Gishdubar Sash"}

    sets.defense.PDT  = sets.idle.PDT
    sets.defense.MEVA = sets.idle.MEVA
    sets.defense.MRf  = sets.idle.MRf
    sets.Kiting = {feet="Herald's Gaiters"}

    sets.engaged = {main="Malignance Pole",sub="Khonsu",ammo="Amar Cluster",
        head="Blistering Sallet +1",neck="Sanctity Necklace",ear1="Telos Earring",ear2="Dignitary's Earring",
        body="Jhakri Robe +2",hands="Gazu Bracelet +1",ring1="Chirich Ring +1",ring2="Pernicious Ring",
        back=gear.TPCape,waist="Goading Belt",legs="Jhakri Slops +2",feet="Jhakri Pigaches +2"}
    sets.engaged.PDef = set_combine(sets.engaged, {body="Mallquis Saio +2",ring1="Vocane Ring +1",ring2="Defending Ring"})

    sets.cp = {back="Mecistopins Mantle"}

    ---- Misc sets depending upon other sets ----
    sets.midcast.FastRecast = set_combine(sets.idle.PDT, {})
    sets.midcast.Dia        = set_combine(sets.idle.PDT, sets.TreasureHunter)
    sets.midcast.Bio        = set_combine(sets.midcast.Dia, {})
    sets.midcast.Stonega    = set_combine(sets.midcast.LowTierNuke, sets.TreasureHunter)
    sets.midcast.Stone      = set_combine(sets.midcast.LowTierNuke, sets.TreasureHunter)
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.
function job_precast(spell, action, spellMap, eventArgs)
    if spell.skill == 'Elemental Magic' and spell.english ~= 'Impact' then
        if state.AutoSeidr.value and S{'Normal','LowMP'}:contains(state.CastingMode.value) then
            local convert_recast_id = 49
            if S{'Helix','LowTierNuke','ElementalEnfeeble'}:contains(spellMap)
            or player.mp - spell.mp_cost >= state.AutoSeidr.low_mp
            or state.Buff['Parsimony'] then
                -- cheap enough for freenukes
                state.CastingMode:set('Normal')
            elseif state.MagicBurst.value and (buffactive['Sublimation: Complete']
            or player.sub_job == 'RDM' and windower.ffxi.get_ability_recasts()[convert_recast_id] == 0) then
                -- cheap enough for magic bursts
                state.CastingMode:set('Normal')
            else
                -- make it free
                state.CastingMode:set('LowMP')
            end
            hud_update_on_state_change('Casting Mode')
        end
    end

    if     spell.english == 'Light Arts' then
        state.Buff['Dark Arts']       = false
        state.Buff['Addendum: Black'] = false
    elseif spell.english == 'Dark Arts' then
        state.Buff['Light Arts']      = false
        state.Buff['Addendum: White'] = false
    elseif classes.CustomClass == 'CureCheat' then
        if not (spell.target.type == 'SELF' and spell.english == 'Cure IV') then
            classes.CustomClass = nil
        end
    end
end

-- Run after the general precast() is done.
function job_post_precast(spell, action, spellMap, eventArgs)
    if spell.type == 'WeaponSkill' then
        if state.skillchain.name == '6step' and state.skillchain.trying == spell.english then
            equip(sets.naked)
        end
    elseif spell.action_type == 'Magic' and spell.english ~= 'Impact' then
        if spell.type == 'WhiteMagic' and (state.Buff['Light Arts'] or state.Buff['Addendum: White'])
        or spell.type == 'BlackMagic' and (state.Buff['Dark Arts']  or state.Buff['Addendum: Black']) then
            -- cap breaking fastcast
            if player.sub_job == 'RDM' then equip(sets.grim_fc_rdm) else equip(sets.grim_fc_other) end
        end
    end
end

-- Run after the default midcast() is done.
-- eventArgs is the same one used in job_midcast, in case information needs to be persisted.
function job_post_midcast(spell, action, spellMap, eventArgs)
    if spell.skill == 'Elemental Magic' and spellMap ~= 'ElementalEnfeeble' or spell.english == 'Kaustra' then
        if state.Buff.Immanence and not state.SCDmg.value then
            -- do minimal damage for immanence spells
            if spellMap == 'Helix' then
                equip(sets.midcast.Helix.NoDmg)
            else
                equip(sets.naked)
            end
        else
            if     spell.english == 'Kaustra' then
                if state.MagicBurst.value and not state.Buff.Immanence then
                    if state.CastingMode.value == 'MAcc' then
                        equip(sets.midcast.Kaustra.MAcc.MB)
                    else
                        equip(sets.midcast.Kaustra.MB)
                    end
                    -- TODO klima mb?
                elseif state.Buff.Klimaform and spell.element == world.weather_element then
                    if state.CastingMode.value ~= 'MAcc' then
                        equip(sets.buff['Klimaform'])
                    end
                end
            elseif spell.english == 'Impact' then
                if state.MagicBurst.value and not state.Buff.Immanence and state.CastingMode.value ~= 'OA' then
                    equip(sets.midcast.Impact.MB)
                end
                if state.Buff.Parsimony then
                    equip(sets.buff['Parsimony'])
                end
            elseif spellMap == 'Helix' or spellMap == 'LowTierNuke' then
                if state.MagicBurst.value and not state.Buff.Immanence then
                    if spell.element == 'Light' or spell.element == 'Dark' then
                        if state.CastingMode.value == 'MAcc' then
                            equip(sets.midcast[spell.english].MAcc.MB)
                        else
                            equip(sets.midcast[spell.english].MB)
                        end
                    elseif spell.element == 'Wind' or state.OffenseMode.value ~= 'None' and state.CombatWeapon.value ~= 'Akademos' then
                        if state.CastingMode.value == 'MAcc' then
                            equip(sets.midcast[spellMap].MAcc.MB.Marin)
                        else
                            equip(sets.midcast[spellMap].MB.Marin)
                        end
                    else
                        if state.CastingMode.value == 'MAcc' then
                            equip(sets.midcast[spellMap].MAcc.MB)
                        else
                            equip(sets.midcast[spellMap].MB)
                        end
                    end
                end
            else
                if state.MagicBurst.value and not state.Buff.Immanence then
                    local base_set = sets.midcast['Elemental Magic']
                    if state.CastingMode.value ~= 'OA' then base_set = base_set[state.CastingMode.value] or base_set end

                    if spell.element == 'Wind' or state.OffenseMode.value ~= 'None' and state.CombatWeapon.value ~= 'Akademos' then
                        equip(base_set.MB.Marin or base_set.MB)
                    else
                        equip(base_set.MB)
                    end
                    -- TODO klima mb?
                elseif state.Buff.Klimaform and spell.element == world.weather_element then
                    if state.CastingMode.value ~= 'MAcc' then
                        equip(sets.buff['Klimaform'])
                    end
                end
            end

            if spellMap == 'Helix' then
                equip(resolve_ele_belt(spell, nil,          sets.nuke_belt, 3))
            elseif state.CastingMode.value ~= 'OA' then
                equip(resolve_ele_belt(spell, sets.ele_obi, sets.nuke_belt, 3))
            end
        end
    elseif spell.skill == 'Dark Magic' then
        if S{'Drain','Aspir'}:contains(spellMap) then
            equip(resolve_ele_belt(spell, sets.ele_obi, sets.drain_belt, 5))
        elseif spell.english == 'Stun' and state.Buff['Alacrity'] and world.weather_element == spell.element then
            equip(sets.buff['Alacrity'])
        end
    elseif classes.CustomClass ~= 'CureCheat' and (spell.english:startswith('Cure') or spell.english:startswith('Curaga')) then
        if spell.target.type == 'MONSTER' then
            equip(sets.midcast.LowTierNuke, resolve_ele_belt(spell, sets.ele_obi, sets.nuke_belt, 3))
        else
            if world.weather_element == 'Light' and state.OffenseMode.value == 'None' then
                equip(sets.midcast.Cure.Chatoyant)
            elseif spell.target.type == 'SELF' then
                equip(resolve_ele_belt(spell, sets.ele_obi, sets.gishdubar, 9))
            else
                equip(resolve_ele_belt(spell, sets.ele_obi, sets.cmp_belt, 2))
            end
        end
    elseif spell.skill == 'Enhancing Magic' then
        if state.Buff.Accession and spell.english == 'Phalanx' then
            equip(sets.midcast.Phalanx.AoE)
        end
        if state.Buff.Perpetuance then
            equip(sets.buff['Perpetuance'])
        end
    elseif spellMap == 'Raise' and state.Buff.Penury then
        equip(sets.buff['Penury'], {waist="Goading Belt"})
    elseif spell.target.type == 'SELF' and spell.english == 'Cursna' then
        equip(sets.buff.doom)
    end
end

function job_aftercast(spell, action, spellMap, eventArgs)
    skillchain_state_updates(spell, action)
    if spell.interrupted then
        send_command('wait 0.5;gs c update')
        interrupted_message(spell)
    else
        if S{'JobAbility','Scholar'}:contains(spell.type) then
            -- prevent stratagem aftercast from clobbering the next spell, unless activating sublimation
            if spell.english == 'Sublimation'
            and not buffactive['Sublimation: Activated']
            and player.hpp > 51 then
                state.Buff['Sublimation: Activated'] = true
            else
                eventArgs.handled = true
            end
        elseif spell.english == 'Dia II' and state.DiaMsg.value then
            if spell.target.name and spell.target.type == 'MONSTER' then
                send_command('input /p Dia II /')
            end
        elseif spell.english == 'Break' or spell.english == 'Breakga' then
            send_command('timers c "'..spell.english..' ['..spell.target.name..']" 33 down')
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
    if state.DefenseMode.value == 'None' and S{'sleep','stun','terror','petrification'}:contains(lbuff) then
        if gain then
            if lbuff == 'sleep' then send_command('cancel stoneskin') end
        elseif not midaction() then
            handle_equipping_gear(player.status)
        end
    elseif not midaction() then
        if lbuff == 'doom' then
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
    if spell.skill == 'Enhancing Magic' then
        if not S{'Regen','BarElement','BarStatus','StatusRemoval','Storm','EnSpell','Teleport'}:contains(default_spell_map) then
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
    if state.Buff['Sublimation: Activated'] and state.DefenseMode.value == 'None' then
        idleSet = set_combine(idleSet, sets.buff.Sublimation)
    elseif player.mpp < 51 then
        idleSet = set_combine(idleSet, sets.latent_refresh)
    end
    if state.ZendikIdle.value and state.DefenseMode.value == 'None' then
        idleSet = set_combine(idleSet, sets.zendik)
    end
    if has_any_buff_of(S{'petrification','sleep','stun','terror'}) then
        idleSet = set_combine(sets.defense.PDT, {})
        if buffactive.Sleep then send_command('cancel stoneskin') end
    end
    if S{'Western Adoulin','Eastern Adoulin'}:contains(world.area) then
        if player.wardrobe4["Councilor's Garb"]   then idleSet = set_combine(idleSet, {body="Councilor's Garb"}) end
    end
    if buffactive['Reive Mark'] then
        if player.wardrobe4["Arciela's Grace +1"] then idleSet = set_combine(idleSet, {neck="Arciela's Grace +1"}) end
    end
    if state.Buff.doom then
        idleSet = set_combine(idleSet, sets.buff.doom)
    end
    return idleSet
end

-- Modify the default defense set after it was constructed.
function customize_defense_set(defenseSet)
    if state.DefenseMode.value == 'Magical' and state.MagicalDefenseMode.value == 'MRf' then
        if state.Buff['Sublimation: Activated'] then
            defenseSet = set_combine(defenseSet, sets.buff.Sublimation)
        elseif player.mpp < 51 then
            defenseSet = set_combine(defenseSet, sets.latent_refresh)
        end
        if state.ZendikIdle.value then
            defenseSet = set_combine(defenseSet, sets.zendik)
        end
    end
    if state.Buff.doom then
        defenseSet = set_combine(defenseSet, sets.buff.doom)
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
    if has_any_buff_of(S{'petrification','sleep','stun','terror'}) then
        meleeSet = set_combine(sets.defense.MEVA, {})
        if buffactive.Sleep then send_command('cancel stoneskin') end
    end
    if state.Buff.doom then
        meleeSet = set_combine(meleeSet, sets.buff.doom)
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
    if state.AutoSeidr.value then
        msg = msg .. ' AutoSeidr'
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
    report_ja_recasts(info.recast_ids, true)
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
    elseif cmdParams[1] == 'sc' then
        skillchain_handle_command(cmdParams[2])
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
function select_default_macro_book()
    set_macro_page(1,4)
    send_command('bind !^l input /lockstyleset 4')
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
        'bind !F11 gs c reset IdleMode',
        'bind @F11 gs c toggle Kiting',
        'bind ^space  gs c cycle HybridMode',
        'bind !space  gs c set DefenseMode Physical',
        'bind @space  gs c set DefenseMode Magical',
        'bind !@space gs c reset DefenseMode',
        'bind @z      gs c cycle MagicalDefenseMode',
        'bind !w   gs c set OffenseMode Normal',
        'bind !@w  gs c set OffenseMode None',
        'bind ~!^q gs c set CombatWeapon Dagger',
        'bind !^q  gs c set CombatWeapon Marin',
        'bind !^w  gs c set CombatWeapon Musa',
        'bind !^e  gs c set CombatWeapon Pole',
        'bind ^z   gs c toggle ZendikIdle',
        'bind !z   gs c toggle MagicBurst',
        'bind ^c   gs c reset CastingMode',
        'bind ~^c  gs c set CastingMode MAcc',
        'bind ~^z  gs c set CastingMode OA',
        'bind !@z  gs c set CastingMode LowMP',
        'bind  !^z gs c set   AutoSeidr',
        'bind ~!^z gs c unset AutoSeidr',
        'bind !^c  gs c set SCMode Auto',
        'bind ~!^c gs c set SCMode Manual',
        'bind ^@c  gs c sc reset',
        'bind !@c  gs c sc restart',
        'bind !c|%c gs c sc next', -- also sets SCMode to Manual
        'bind ^\\\\  gs c toggle DiaMsg',
        'bind !\\\\  gs c toggle SCDmg',
        'bind !^\\\\ gs c toggle SCHUD',

        'bind !^`   input /ja "Tabula Rasa <me>',
        'bind !@`   input /ja "Caper Emissarius" <t>',
        'bind !`    input /ja Libra',
        'bind ^@`   input /ja Enlightenment <me>',
        'bind !e    input /ja Sublimation <me>',
        'bind @tab  gs c scholar cost',
        'bind @q    gs c scholar speed',
        'bind ^@q   gs c scholar aoe',
        'bind ^@tab gs c scholar specialty',
        'bind @`    gs c scholar power',
        'bind ~^tab gs c scholar light',
        'bind ~^q   gs c scholar dark',

        'bind ^1  input /ma "Dia II"',
        'bind ^2  input /ma Slow',
        'bind ^3  input /ma Paralyze',
        'bind ^4  input /ma Silence',
        'bind ~^1 input /ma Break      <stnpc>',
        'bind ~^2 input /ma Sleep      <stnpc>',
        'bind ~^3 input /ma "Sleep II" <stnpc>',
        'bind ~^4 input /ma Silence    <stnpc>',

        'bind !1 input /ma "Cure III" <stpc>',
        'bind !2 input /ma "Cure IV"  <stpc>',
        'bind !3 input /ma "Regen V"',
        'bind !4 input /ma Adloquium',
        'bind ~!^2 gs c CureCheat',

        'bind @F1 input /ma Erase',
        'bind @1  input /ma Poisona',
        'bind @2  input /ma Paralyna',
        'bind @3  input /ma Blindna',
        'bind @4  input /ma Silena',
        'bind @5  input /ma Stona',
        'bind @6  input /ma Viruna',
        'bind @7  input /ma Cursna',

        'bind !f  input /ma Haste <me>',
        'bind @f  input /ma "Animus Augeo"',
        'bind !@f input /ma "Animus Minuo"',
        'bind !b  input /ma Klimaform <me>',
        'bind @g  input /ma "Ice Spikes" <me>',
        'bind !@g input /ma Stoneskin <me>',
        'bind @c  input /ma Blink <me>',
        'bind @v  input /ma Aquaveil <me>',

        'bind ^tab input /ma Dispel',
        'bind ^q   input /ma Dispelga',

        'bind @d  input /ma "Aspir II"',
        'bind !@d input /ma "Aspir"',

        'bind ^backspace  input /ma Impact',
        'bind ~^backspace input /ma Kaustra',
        'bind !backspace  input /ma Embrava',

        'bind ^5 input /ma "Sandstorm II"',
        'bind ^6 input /ma "Rainstorm II"',
        'bind ^7 input /ma "Windstorm II"',
        'bind ^8 input /ma "Firestorm II"',
        'bind ^9 input /ma "Hailstorm II"',
        'bind ^0 input /ma "Thunderstorm II"',
        'bind ^- input /ma "Aurorastorm II"',
        'bind ^= input /ma "Voidstorm II"',

        'bind ^@1 gs c sc grav',
        'bind ^@2 gs c sc dist',
        'bind ^@3 gs c sc fusion',
        'bind ^@4 gs c sc frag',
        'bind ^@5 gs c sc earth',
        'bind ^@6 gs c sc water',
        'bind ^@7 gs c sc wind',
        'bind ^@8 gs c sc fire',
        'bind ^@9 gs c sc ice',
        'bind ^@0 gs c sc thunder',
        'bind ^@- gs c sc light',
        'bind ^@= gs c sc dark',

        'bind ~^@1 gs c sc grav-ws',
        'bind ~^@2 gs c sc dist-ws',
        'bind ~^@3 gs c sc fusion-ws',
        'bind ~^@4 gs c sc frag-ws',
        'bind ~^@5 gs c sc earth-ws',
        'bind ~^@6 gs c sc water-ws',
        'bind ~^@7 gs c sc wind-ws',
        'bind ~^@8 gs c sc fire-ws',
        'bind ~^@9 gs c sc ice-ws',
        'bind ~^@0 gs c sc thunder-ws',
        'bind ~^@- gs c sc light-ws',
        'bind ~^@= gs c sc dark-ws',

        'bind ~!^8 input /ma "Geohelix II"',
        'bind ~!^9 input /ma "Hydrohelix II"',
        'bind ~!^0 input /ma "Anemohelix II"',
        'bind ~^8  input /ma "Pyrohelix II"',
        'bind ~^9  input /ma "Cryohelix II"',
        'bind ~^0  input /ma "Ionohelix II"',
        'bind ~^-  input /ma "Luminohelix II"',
        'bind ~^=  input /ma "Noctohelix II"',

        'bind ~@8 input /ma "Stone III"',
        'bind ~@9 input /ma "Water III"',
        'bind ~@0 input /ma "Aero III"',
        'bind @8  input /ma "Fire III"',
        'bind @9  input /ma "Blizzard III"',
        'bind @0  input /ma "Thunder III"',

        'bind ~!8 input /ma "Stone IV"',
        'bind ~!9 input /ma "Water IV"',
        'bind ~!0 input /ma "Aero IV"',
        'bind  !8 input /ma "Fire IV"',
        'bind  !9 input /ma "Blizzard IV"',
        'bind  !0 input /ma "Thunder IV"',

        'bind ~!@8|%~8 input /ma "Stone V"',
        'bind ~!@9|%~9 input /ma "Water V"',
        'bind ~!@0|%~0 input /ma "Aero V"',
        'bind  !@8|%8  input /ma "Fire V"',
        'bind  !@9|%9  input /ma "Blizzard V"',
        'bind  !@0|%0  input /ma "Thunder V"'}

    if     player.sub_job == 'RDM' then
        bind_command_list:extend(L{
            'bind ~^@tab input /ja Convert <me>',
            'bind !@3 input /ma Distract',
            'bind !@4 input /ma Frazzle',
            'bind !5  input /ma Haste   <stpc>',
            'bind !6  input /ma Refresh <stpc>',
            'bind !7  input /ma Flurry  <stpc>',
            'bind !g  input /ma Phalanx',
            'bind !^d  input /ma Bind    <stnpc>',
            'bind ~!^d input /ma Gravity <stnpc>'})
    elseif player.sub_job == 'WHM' then
        bind_command_list:extend(L{
            'bind ^`  input /ja "Divine Seal" <me>',
            'bind !@1 input /ma Curaga',
            'bind !@2 input /ma "Curaga II"',
            'bind !5  input /ma Haste <stpc>',
            'bind !d  input /ma Flash',
            'bind !^d input /ma Repose <stnpc>'})
    elseif player.sub_job == 'BLM' then
        bind_command_list:extend(L{
            'bind ^`   input /ja "Elemental Seal" <me>',
            'bind !d   input /ma Stun',
            'bind !^d  input /ma Bind    <stnpc>',
            'bind ~!^d input /ma Sleepga <stnpc>'})
    elseif player.sub_job == 'DRK' then
        bind_command_list:extend(L{
            'bind !d  input /ma Stun',
            'bind !^d input /ma "Absorb-TP"'})
    end

    return bind_command_list
end

-- waiting for buffactive to update sucks
-- let's monkey patch a gearswap function to use state.Buff vars for enlightenment and addendums
-- (a similar approach may be feasible for quickly using stratagems after swapping arts)
function monkey_check_spell(available_spells,spell)
    -- Filter for spells that you do not know. Exclude Impact / Dispelga.
    local spell_jobs = copy_entry(res.spells[spell.id].levels)
    if not available_spells[spell.id] and not (spell.id == 503 or spell.id == 417 or spell.id == 360) then
        return false,"Unable to execute command. You do not know that spell ("..(res.spells[spell.id][language] or spell.id)..")"
    -- Filter for spells that you know, but do not currently have access to
    elseif (not spell_jobs[player.main_job_id] or not (spell_jobs[player.main_job_id] <= player.main_job_level or
        (spell_jobs[player.main_job_id] >= 100 and number_of_jps(player.job_points[__raw.lower(res.jobs[player.main_job_id].ens)]) >= spell_jobs[player.main_job_id]) ) ) and
        (not spell_jobs[player.sub_job_id] or not (spell_jobs[player.sub_job_id] <= player.sub_job_level)) and not (player.main_job_id == 23) then
        return false,"Unable to execute command. You do not have access to that spell ("..(res.spells[spell.id][language] or spell.id)..")"
    -- At this point, we know that it is technically castable by this job combination if the right conditions are met.
    elseif player.main_job_id == 20 and ((addendum_white[spell.id] and not state.Buff['Addendum: White'] and not state.Buff['Enlightenment']) or
        (addendum_black[spell.id] and not state.Buff['Addendum: Black'] and not state.Buff['Enlightenment'])) and
        not (spell_jobs[player.sub_job_id] and spell_jobs[player.sub_job_id] <= player.sub_job_level) then
        return false,"Unable to execute command. Addendum required for that spell ("..(res.spells[spell.id][language] or spell.id)..")"
    elseif player.sub_job_id == 20 and ((addendum_white[spell.id] and not state.Buff['Addendum: White'] and not state.Buff['Enlightenment']) or
        (addendum_black[spell.id] and not state.Buff['Addendum: Black'] and not state.Buff['Enlightenment'])) and
        not (spell_jobs[player.main_job_id] and (spell_jobs[player.main_job_id] <= player.main_job_level or
        (spell_jobs[player.main_job_id] >= 100 and number_of_jps(player.job_points[__raw.lower(res.jobs[player.main_job_id].ens)]) >= spell_jobs[player.main_job_id]) ) ) then
        return false,"Unable to execute command. Addendum required for that spell ("..(res.spells[spell.id][language] or spell.id)..")"
    elseif spell.type == 'BlueMagic' and not ((player.main_job_id == 16 and table.contains(windower.ffxi.get_mjob_data().spells,spell.id))
        or unbridled_learning_set[spell.english]) and
        not (player.sub_job_id == 16 and table.contains(windower.ffxi.get_sjob_data().spells,spell.id)) then
        -- This code isn't hurting anything, but it doesn't need to be here either.
        return false,"Unable to execute command. Blue magic must be set to cast that spell ("..(res.spells[spell.id][language] or spell.id)..")"
    elseif spell.type == 'Ninjutsu'  then
        if player.main_job_id ~= 13 and player.sub_job_id ~= 13 then
            return false,"Unable to make action packet. You do not have access to that spell ("..(spell[language] or spell.id)..")"
        elseif not player.inventory[tool_map[spell.english][language]] and not (player.main_job_id == 13 and player.inventory[universal_tool_map[spell.english][language]]) then
            return false,"Unable to make action packet. You do not have the proper tools."
        end
    end
    return true
end

-- update state.skillchain with skillchain step and hud information
-- initialize state by calling with no arguments
-- call from job_aftercast to do updates
function skillchain_state_updates(spell, action)
    if action == 'init' or action == 'reset' then
        state.skillchain = {}
        state.skillchain.name = nil
        state.skillchain.list = nil
        state.skillchain.cur_step = 0
        state.skillchain.trying = nil
        state.skillchain.window_timer = nil
        if action == 'init' then
            -- set type and wait attributes for skillchain steps
            local weaponskills = gearswap.res.weapon_skills:rekey('en')
            for sc in info.skillchains:it() do
                local len = sc.list:length()
                for i = 1, len do
                    if weaponskills[sc.list[i].action] then
                        if sc.list[i].action == 'Starburst' and player.sub_job == 'WHM' then
                            sc.list[i].action = 'Sunburst'
                        end
                        sc.list[i].type = 'ws'
                        if i ~= len then
                            sc.list[i].wait = info.sc_step_waits[sc.list[i].action] or 5
                        end
                    else -- a spell
                        sc.list[i].type = 'ma'
                        if i ~= len then
                            if info.sc_step_waits[sc.list[i].action] then
                                sc.list[i].wait = info.sc_step_waits[sc.list[i].action]
                            elseif sc.list[i].action:contains('helix') then
                                sc.list[i].wait = 4.5
                            else
                                sc.list[i].wait = 4
                            end
                        end
                    end

                    -- wait longer before stone or a ws
                    if i < len then
                        if     sc.list[i+1].type == 'ws' then
                            sc.list[i].wait = sc.list[i].wait + 1
                        elseif sc.list[i+1].action == 'Stone' then
                            sc.list[i].wait = sc.list[i].wait + 1
                        end
                    end
                end
            end
        end
    elseif action == 'start' then
        state.skillchain.name = spell
        state.skillchain.list = info.skillchains[spell].list
        state.skillchain.cur_step = 1
        state.skillchain.trying = nil
        state.skillchain.window_timer = nil
    elseif action == 'step' then
        if not state.skillchain.name or not state.skillchain.list or state.skillchain.trying == 'DONE' then return end
        local step = state.skillchain.list[state.skillchain.cur_step]
        if state.skillchain.trying == step.action then
            -- attempt next step
            if state.skillchain.cur_step < state.skillchain.list:length() then
                state.skillchain.cur_step = state.skillchain.cur_step + 1
                step = state.skillchain.list[state.skillchain.cur_step]
                state.skillchain.trying = (state.Buff.Immanence or step.type == 'ws') and step.action or 'Immanence'
            else
                state.skillchain.trying = 'DONE'
            end
        else
            -- first step, retry, or magic action after immanence
            state.skillchain.trying = (state.Buff.Immanence or step.type == 'ws') and step.action or 'Immanence'
        end

        if state.skillchain.trying ~= 'Immanence' then
            -- expired skillchains should be timed out, and window information is made available to the hud
            local window_length = 11 - state.skillchain.cur_step
            if state.skillchain.trying:contains('helix') then window_length = window_length + 1 end
            if state.skillchain.cur_step > 2             then window_length = window_length * 2 end  -- in case of missed aftercast
            state.skillchain.window_timer = os.time() + window_length
        end
    elseif action == 'aftercast' then
        if spell.english == state.skillchain.trying then
            if spell.interrupted then
                state.skillchain.trying = 'retry'
                state.SCMode:set('Manual')
                add_to_chat(121,'[%s] interrupted.':format(spell.english))
            elseif spell.english ~= 'Immanence' then
                local window_length = 11 - state.skillchain.cur_step
                if spell.english:contains('helix') then window_length = window_length + 1 end
                state.skillchain.window_timer = os.time() + window_length
                if state.skillchain.cur_step == state.skillchain.list:length() then
                    state.skillchain.trying = 'DONE'
                end
            end
        end
    end
end

-- called from job_self_command, eg, by //gs c sc autonext
function skillchain_handle_command(cmd)
    if cmd == 'next' then
        if state.SCMode.value == 'Manual' then
            if not state.skillchain.name then
                add_to_chat(123,'No skillchain queued.')
            elseif state.skillchain.trying == 'DONE' then
                add_to_chat(123,'Skillchain has completed.')
            elseif state.Buff['Dark Arts'] or state.Buff['Addendum: Black'] then
                if state.skillchain.window_timer and state.skillchain.window_timer + 5 < os.time() then
                    add_to_chat(123,'Skillchain window expired.')
                else
                    skillchain_step()
                end
            else
                add_to_chat(123,'Dark Arts not active.')
            end
        else
            state.SCMode:set('Manual')
        end
    elseif cmd == 'autonext' then
        if state.Buff['Dark Arts'] or state.Buff['Addendum: Black'] then
            if state.SCMode.value == 'Auto' and state.skillchain.trying ~= 'retry' then
                skillchain_step()
            end
        else
            state.SCMode:set('Manual')
            add_to_chat(123,'Dark Arts not active.')
        end
    elseif cmd == 'list' then
        add_to_chat(122,'Listing Skillchains:')
        for sc, name in info.skillchains:it() do
            local col = sc.list:with('type','ws') and 123 or 122
            add_to_chat(col,'[%s]: %s':format(name, sc.list:map(skillchain_step_to_string):concat(' ')))
        end
    elseif cmd == 'reset' then
        add_to_chat(121,'skillchain reset')
        skillchain_state_updates(nil, 'reset')
    elseif cmd == 'restart' then
        if state.skillchain.name then
            skillchain_handle_command(state.skillchain.name)
        else
            add_to_chat(123,'no skillchain to restart')
        end
    elseif info.skillchains[cmd] then
        if state.Buff['Dark Arts'] or state.Buff['Addendum: Black'] then
            if cmd == '6step' then
                state.SCDmg:unset()
            elseif cmd:endswith('-ws') then
                if state.CombatWeapon.value == 'Dagger' then
                    cmd = cmd:gsub('-ws$','-dag')
                end
            end
            state.MagicBurst:set()
            hud_update_on_state_change('Magic Burst')
            skillchain_state_updates(cmd, 'start')
            add_to_chat(121,'queuing [%s]: %s':format(cmd, state.skillchain.list:map(skillchain_step_to_string):concat(' ')))

            if state.SCMode.value == 'Auto' then
                if state.skillchain.list:with('type','ws') and (state.OffenseMode.value == 'None' or player.tp < 1000) then
                    add_to_chat(123,'aborting [%s]; need tp':format(cmd))
                else
                    skillchain_step()
                end
            end
        else
            add_to_chat(123,'Dark Arts not active.')
        end
    else
        add_to_chat(123,'Error: Unknown skillchain ['..cmd..']')
    end
end

-- attempts to take a skillchain step, controlled by values in state.skillchain
function skillchain_step()
    if state.skillchain.name and 1 <= state.skillchain.cur_step and state.skillchain.cur_step <= state.skillchain.list:length() then
        skillchain_state_updates(nil, 'step')
        if state.skillchain.trying == 'DONE' then return end
        local step = state.skillchain.list[state.skillchain.cur_step]
        local action_type = state.skillchain.trying == 'Immanence' and 'ja' or step.type or 'ma'
        send_command('input /%s "%s"':format(action_type, state.skillchain.trying))

        if state.skillchain.list:length() == 2 and state.skillchain.trying ~= 'Immanence' then
            local skillchain_logname = info.skillchains[state.skillchain.name].name
            if state.skillchain.cur_step == 1 then
                send_command('input /p Opening %s, please hold.':format(skillchain_logname))
            else
                send_command('input /p %s! MB':format(skillchain_logname))
            end
        end

        if state.SCMode.value == 'Auto' then
            if state.skillchain.trying == 'Immanence' then
                send_command('wait %.1f; gs c sc autonext':format(0.9))
            elseif step.wait then
                send_command('wait %.1f; gs c sc autonext':format(step.wait))
            end
        end
    end
end

function skillchain_step_to_string(step)
    if step.wait then
        return '"%s" (wait %.1f)':format(step.action, step.wait)
    else
        return '"%s"':format(step.action)
    end
end

function init_state_text()
    if hud then return end

    local mb_text_settings    = {flags={draggable=false,bold=true},bg={red=250,green=200,blue=0,alpha=150},text={stroke={width=2}}}
    local ally_text_settings  = {pos={x=-178},flags={draggable=false,right=true,bold=true},bg={alpha=200},text={font='Courier New',size=10}}
    local cmode_text_settings = {pos={y=18},flags={draggable=false,bold=true},bg={red=0,green=220,blue=220,alpha=150},
                                 text={stroke={width=2}}}
    local hyb_text_settings   = {pos={x=130,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local def_text_settings   = {pos={x=172,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local off_text_settings   = {pos={x=172,y=697},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local sc_text_settings    = {pos={x=1000,y=697},flags={draggable=false,bold=true},
                                 bg={alpha=150},padding=1,text={font='Courier New',size=10,stroke={width=2}}}

    hud = {texts=T{}}
    hud.texts.mb_text    = texts.new('MBurst',         mb_text_settings)
    hud.texts.ally_text  = texts.new('AllyCure',       ally_text_settings)
    hud.texts.cmode_text = texts.new('initializing..', cmode_text_settings)
    hud.texts.hyb_text   = texts.new('initializing..', hyb_text_settings)
    hud.texts.def_text   = texts.new('initializing..', def_text_settings)
    hud.texts.off_text   = texts.new('initializing..', off_text_settings)
    hud.texts.sc_text    = texts.new('initializing..', sc_text_settings)

    -- update infrequently changing text boxes in job_state_change or where they are changed
    function hud_update_on_state_change(stateField)
        if not hud then init_state_text() end

        if not stateField or stateField == 'Magic Burst' then
            hud.texts.mb_text:visible(state.MagicBurst.value)
        end

        if not stateField or stateField == 'Ally Cure Keybinds' then
            hud.texts.ally_text:visible(state.AllyBinds.value)
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

    -- update continuously changing text boxes with a prerender event
    local counter, interval = 15, 15 -- only update skillchain text every <interval> frames
    function hud_update_on_prerender()
        counter = counter + 1
        if counter >= interval and state.SCHUD.value then
            counter = 0
            if not areas.Cities:contains(world.area) and (state.Buff['Dark Arts'] or state.Buff['Addendum: Black']) then
                local text = "(%s Mode)":format(state.SCMode.value)
                if not state.SCDmg.value then text = text .. " [NODMG]" end

                local open = true
                local time_remaining = nil
                if not state.skillchain.name then
                    open = false
                elseif state.skillchain.window_timer then
                    time_remaining = state.skillchain.window_timer - os.time()
                    if time_remaining < -5 then
                        open = false
                    end
                -- else just starting
                end

                if not open then
                    hud.texts.sc_text:bg_color(0,0,0)
                else
                    local time_str = ""
                    local try_str = ""

                    if state.skillchain.trying == 'DONE' then
                        hud.texts.sc_text:bg_color(0,0,150)
                        try_str = "MB!"
                    else
                        if state.SCMode.value == 'Auto'   then
                            hud.texts.sc_text:bg_color(0,200,0)
                        elseif state.SCMode.value == 'Manual' then
                            hud.texts.sc_text:bg_color(200,200,0)
                        end

                        if state.skillchain.trying then
                            local next_str = ""

                            if state.skillchain.trying == 'retry' or state.skillchain.trying == 'Immanence' then
                                next_str = " (next: %s)":format(state.skillchain.list[state.skillchain.cur_step].action)
                            elseif state.skillchain.cur_step < state.skillchain.list:length() then
                                next_str = " (next: %s)":format(state.skillchain.list[state.skillchain.cur_step+1].action)
                            end

                            try_str = "try: %s [%d/%d]%s":format(
                                state.skillchain.trying, state.skillchain.cur_step, state.skillchain.list:length(), next_str)
                        elseif state.skillchain.cur_step == 1 then
                            try_str = "first: %s [1/%d] (next: %s)":format(
                                state.skillchain.list[1].action, state.skillchain.list:length(), state.skillchain.list[2].action)
                        end
                    end

                    if time_remaining then
                        if time_remaining >= 0 then
                            time_str = "[0:%02d]":format(time_remaining)
                        else
                            time_str = "[closed]"
                            hud.texts.sc_text:bg_color(255,0,0)
                        end
                    end

                    text = "[%s] %s\n%-8s %s":format(state.skillchain.name, text, time_str, try_str)
                end

                hud.texts.sc_text:text(text)
                hud.texts.sc_text:show()
            else
                hud.texts.sc_text:hide()
            end
        elseif not state.SCHUD.value then
            hud.texts.sc_text:hide()
        end
    end

    hud.prerender_event_id = windower.raw_register_event('prerender', hud_update_on_prerender)
end
