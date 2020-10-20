-- Modified from 'https://github.com/Kinematics/GearSwap-Jobs/blob/master/THF.lua'
-- TODO relic feet

-- NOTES
-- mug steals hp
-- despoil steals tp
-- traits provide ta+19 and chd+22
-- conspirator gives acc and can cap subtle blow
-- hide loses enmity from some enemies if you are the target
-- can use TA during hide
-- can SA from the front during hide if not on hate list
-- SA, TA, feint help level up TH
-- for solo SA/TA, double tap the ability
-- use collaborator (40%) regularly; save accomplice (65%) for emergencies only
-- evasion caps: 1200 for omen, ...

-- thf dual wield cheatsheet (550+)
-- haste:   0   15  30  cap
--   +dw:  44   37  26   6

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
    disable('main','sub')
    enable('range','ammo','head','neck','ear1','ear2','body','hands','ring1','ring2','back','waist','legs','feet')
    state.Buff['Sneak Attack'] = buffactive['sneak attack'] or false
    state.Buff['Trick Attack'] = buffactive['trick attack'] or false
    state.Buff['Feint'] = buffactive['feint'] or false
    state.Buff.sleep = buffactive.sleep or false
    state.Buff.doom = buffactive.doom or false

    include('Mote-TreasureHunter')

    windower.raw_register_event('logout', destroy_state_text)
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
    state.OffenseMode:options('Normal','MDef','Acc','None')     -- Cycle with F9, set with !w, @c, !c, !@w
    state.HybridMode:options('Normal','PDef')                   -- Cycle with ^space
    state.WeaponskillMode:options('Normal','PDT')--,'NoDmg')    -- Cycle with @F9
    state.CastingMode:options('TH','MAcc')                      -- Cycle with F10
    state.IdleMode:options('Normal','Eva','Rf','STP')           -- Cycle with F11
    state.PhysicalDefenseMode:options('EvaEng','EvaPDT','Kite') -- Cycle with !z
    state.MagicalDefenseMode:options('MEVA')                    -- Cycle with @z
    state.CombatWeapon = M{['description']='Combat Weapon'}     -- Set with [~]!^q|w|e|r, ^@w
    state.CombatWeapon:options('TwashTern','TwashCent','TwashGand','TwashTern','TaurTwash','TaurShijo','AenSari','AenTwash',
                               'GandSari','GandCent','GandTwash','GandTern','NaegTern','NaegCent')

    state.WSMsg     = M(false, 'WS Message')                    -- Toggle with ^\
    state.THAeolian = M(false, 'TH Aeolian')                    -- Toggle with ^z
    init_state_text()
    hud_update_on_state_change()

    info.magic_ws = S{'Aeolian Edge','Cyclone','Gust Slash','Energy Steal','Energy Drain',
                      'Burning Blade','Red Lotus Blade','Shining Blade','Seraph Blade','Sanguine Blade'}

    -- Augmented items get variables for convenience and specificity
    gear.taeon_head_phlx  = {name="Taeon Chapeau", augments={'Phalanx +3'}}
    gear.taeon_body_phlx  = {name="Taeon Tabard", augments={'Spell interruption rate down -10%','Phalanx +3'}}
    gear.taeon_hands_phlx = {name="Taeon Gloves", augments={'Spell interruption rate down -8%','Phalanx +3'}}
    gear.taeon_legs_phlx  = {name="Taeon Tights", augments={'Phalanx +3'}}
    gear.taeon_feet_phlx  = {name="Taeon Boots", augments={'Spell interruption rate down -9%','Phalanx +3'}}
    gear.herc_head_ma  = {name="Herculean Helm",
        augments={'"Mag.Atk.Bns."+23','Mag. Acc.+16','Accuracy+2 Attack+2','Mag. Acc.+12 "Mag.Atk.Bns."+12'}}
    gear.herc_hands_ma = {name="Herculean Gloves",
        augments={'Mag. Acc.+18 "Mag.Atk.Bns."+18','Magic burst dmg.+3%','Mag. Acc.+12','"Mag.Atk.Bns."+10',}}
    gear.herc_legs_ma  = {name="Herculean Trousers",
        augments={'"Mag.Atk.Bns."+30','Weapon Skill Acc.+5','Accuracy+14 Attack+14','Mag. Acc.+16 "Mag.Atk.Bns."+16'}}
    gear.herc_feet_ma  = {name="Herculean Boots",
        augments={'Mag. Acc.+19 "Mag.Atk.Bns."+19','Enmity-2','MND+4','Mag. Acc.+4','"Mag.Atk.Bns."+15'}}
    gear.herc_head_wsd  = {name="Herculean Helm",
        augments={'"Cure" spellcasting time -10%','Pet: INT+6','Weapon skill damage +9%'}}
    gear.herc_hands_wsd = {name="Herculean Gloves",
        augments={'Accuracy+25 Attack+25','Weapon skill damage +3%','DEX+3','Accuracy+14','Attack+5'}}
    gear.herc_feet_wsd  = {name="Herculean Boots",
        augments={'Accuracy+16 Attack+16','Weapon skill damage +2%','DEX+10','Accuracy+6','Attack+14'}}
    gear.herc_feet_ta  = {name="Herculean Boots", augments={'Rng.Acc.+4','"Triple Atk."+4','Accuracy+14','Attack+12'}}
    gear.herc_hands_dt = {name="Herculean Gloves", augments={'Attack+27','Damage taken-4%','DEX+5','Accuracy+9'}}
    gear.herc_head_rf = {name="Herculean Helm",
        augments={'Accuracy+17','DEX+6','"Refresh"+2','Accuracy+16 Attack+16','Mag. Acc.+20 "Mag.Atk.Bns."+20'}}
    gear.herc_legs_th = {name="Herculean Trousers",
        augments={'Attack+3','"Cure" spellcasting time -2%','"Treasure Hunter"+2','Accuracy+1 Attack+1'}}
    gear.herc_head_fc = {name="Herculean Helm", augments={'"Mag.Atk.Bns."+2','"Fast Cast"+5'}}
    gear.herc_feet_fc = {name="Herculean Boots", augments={'"Mag.Atk.Bns."+17','"Fast Cast"+5'}}
    gear.Lstikini = {name="Stikini Ring +1", bag="wardrobe2"}
    gear.Rstikini = {name="Stikini Ring +1", bag="wardrobe3"}

    gear.IdleCape = {name="Toutatis's Cape",
        augments={'AGI+20','Eva.+20 /Mag. Eva.+20','Evasion+10','"Fast Cast"+10','Phys. dmg. taken-10%'}}
    gear.TPCape   = {name="Toutatis's Cape",
        augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Store TP"+10','Phys. dmg. taken-10%'}}
    gear.DWCape   = {name="Toutatis's Cape",
        augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','"Dual Wield"+10','Phys. dmg. taken-10%'}}
    gear.WSDCape  = {name="Toutatis's Cape",
        augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','Weapon skill damage +10%','Phys. dmg. taken-10%'}}
    gear.EvisCape = {name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','Crit.hit rate+10','Phys. dmg. taken-10%'}}

    info.keybinds = make_keybind_list(job_keybinds())
    info.keybinds:bind()

    info.ws_binds = make_keybind_list(T{
        ['Dagger']=L{
            'bind ^1|%1   input /ws "Evisceration"',
            'bind ^2|%2   input /ws "Rudra\'s Storm"',
            'bind ^3|%3   input /ws "Mandalic Stab"',
            'bind ^4|%4   input /ws "Shark Bite"',
            'bind ^5|%5   input /ws "Exenterator"',
            'bind ^6|%6   input /ws "Aeolian Edge"',
            'bind !^1|%~1 input /ws "Evisceration" <stnpc>',
            'bind !^2|%~2 input /ws "Rudra\'s Storm" <stnpc>',
            'bind !^3|%~3 input /ws "Mandalic Stab" <stnpc>',
            'bind !^4|%~4 input /ws "Shark Bite" <stnpc>',
            'bind !^5|%~5 input /ws "Exenterator" <stnpc>',
            'bind !^6|%~6 input /ws "Cyclone" <stnpc>',
            'bind !^d     input /ws "Shadowstitch"'},
        ['Sword']=L{
            'bind ^1|%1 input /ws "Sanguine Blade"',
            'bind ^2|%2 input /ws "Vorpal Blade"',
            'bind ^3|%3 input /ws "Savage Blade"',
            'bind ^4|%4 input /ws "Red Lotus Blade"',
            'bind ^5|%5 input /ws "Seraph Blade"',
            'bind ^6|%6 input /ws "Circle Blade"',
            'bind !^d   input /ws "Flat Blade"'}},
        {['TwashTern']='Dagger',['TwashCent']='Dagger',['TwashGand']='Dagger',
         ['TaurTwash']='Dagger',['TaurShijo']='Dagger',['AenSari']='Dagger',['AenTwash']='Dagger',
         ['GandSari']='Dagger',['GandCent']='Dagger',['GandTwash']='Dagger',['GandTern']='Dagger',
         ['NaegTern']='Sword',['NaegCent']='Sword'})
    info.ws_binds:bind(state.CombatWeapon)
    send_command('bind %\\\\ gs c ListWS')

    select_default_macro_book()
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
    sets.weapons.TwashTern = {main="Twashtar",sub="Ternion Dagger +1"}
    sets.weapons.TwashCent = {main="Twashtar",sub="Centovente"}
    sets.weapons.TwashGand = {main="Twashtar",sub="Gandring"}
    sets.weapons.GandSari  = {main="Gandring",sub="Taming Sari"}
    sets.weapons.GandCent  = {main="Gandring",sub="Centovente"}
    sets.weapons.GandTwash = {main="Gandring",sub="Twashtar"}
    sets.weapons.GandTern  = {main="Gandring",sub="Ternion Dagger +1"}
    sets.weapons.TaurTwash = {main="Tauret",sub="Twashtar"}
    sets.weapons.TaurShijo = {main="Tauret",sub="Shijo"}
    sets.weapons.AenSari   = {main="Aeneas",sub="Taming Sari"}
    sets.weapons.AenTwash  = {main="Aeneas",sub="Twashtar"}
    sets.weapons.NaegTern  = {main="Naegling",sub="Ternion Dagger +1"}
    sets.weapons.NaegCent  = {main="Naegling",sub="Centovente"}

    sets.TreasureHunter1 = {waist="Chaac Belt"}                                 -- for gandring/sari
    sets.TreasureHunter2 = {hands="Plunderer's Armlets +3"}                     -- for gandring/X
    sets.TreasureHunter4 = {hands="Plunderer's Armlets +3"}                     -- for X/sari
    sets.TreasureHunter5 = {hands="Plunderer's Armlets +3",waist="Chaac Belt"}  -- default
    sets.TreasureHunter  = set_combine(sets.TreasureHunter5, {})
    sets.buff['Sneak Attack'] = {hands="Skulker's Armlets +1"}
    sets.buff['Trick Attack'] = {body="Plunderer's Vest +3"}
    --sets.buff['Trick Attack'] = {body="Plunderer's Vest +3",hands="Pillager's Armlets +3"}
    sets.buff.Feint = {legs="Plunderer's Culottes +3"}

    -- Precast Sets
    sets.Enmity = {ammo="Aqreqaq Bomblet",
        head="Halitus Helm",neck="Unmoving Collar +1",ear1="Cryptic Earring",ear2="Trux Earring",
        body="Plunderer's Vest +3",hands="Kurys Gloves",ring1="Supershear Ring",ring2="Eihwaz Ring",
        back=gear.IdleCape,waist="Kasiri Belt",legs="Zoar Subligar +1",feet="Ahosi Leggings"}
    -- enm+94
    sets.precast.JA.Provoke              = set_combine(sets.Enmity, {})
    sets.precast.JA['Animated Flourish'] = set_combine(sets.Enmity, {})
    sets.precast.JA.Warcry               = set_combine(sets.Enmity, {})
    sets.precast.JA.Vallation            = set_combine(sets.Enmity, {})
    sets.precast.JA.Swordplay            = set_combine(sets.Enmity, {})
    sets.precast.JA.Pflug                = set_combine(sets.Enmity, {})
    sets.precast.JA.Sentinel             = set_combine(sets.Enmity, {})
    sets.precast.JA.Souleater            = set_combine(sets.Enmity, {})
    sets.precast.JA['Last Resort']       = set_combine(sets.Enmity, {})

    sets.precast.JA.Collaborator     = {head="Skulker's Bonnet +1"}
    sets.precast.JA.Accomplice       = {head="Skulker's Bonnet +1"}
    sets.precast.JA.Conspirator      = {body="Skulker's Vest +1"}
    sets.precast.JA['Perfect Dodge'] = {hands="Plunderer's Armlets +3"}
    sets.precast.JA.Flee             = {ammo="Dart",feet="Pillager's Poulaines +3"}
    sets.precast.JA.Hide             = {ammo="Dart",body="Pillager's Vest +3"}
    sets.precast.JA.Steal            = {ammo="Barathrum",head="Plunderer's Bonnet +3",feet="Pillager's Poulaines +3"}
    sets.precast.JA.Despoil          = {ammo="Barathrum",legs="Skulker's Culottes +1",feet="Skulker's Poulaines +1"}
    sets.precast.JA.Mug              = {ammo="Voluspa Tathlum",
        head="Mummu Bonnet +2",neck="Loricate Torque +1",ear1="Odr Earring",ear2="Sherida Earring",
        body="Mummu Jacket +2",hands="Mummu Wrists +2",ring1="Regal Ring",ring2="Ilabrat Ring",
        back=gear.WSDCape,waist="Sveltesse Gouriz +1",legs="Mummu Kecks +2",feet="Mummu Gamashes +2"}

    sets.precast.RA = {ammo="Dart"}
    sets.precast.FC = {ammo="Sapience Orb",
        head=gear.herc_head_fc,neck="Orunmila's Torque",ear1="Loquacious Earring",ear2="Etiolation Earring",
        body="Adhemar Jacket",hands="Leyline Gloves",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.IdleCape,waist="Flume Belt +1",legs="Rawhide Trousers",feet=gear.herc_feet_fc}
    -- fc+57
    sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {neck="Magoraga Beads"})
    sets.precast.Waltz = {ammo="Yamarang",
        head="Mummu Bonnet +2",neck="Loricate Torque +1",ear1="Eabani Earring",ear2="Genmei Earring",
        body="Ashera Harness",hands="Meghanada Gloves +2",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.TPCape,waist="Chaac Belt",legs="Mummu Kecks +2",feet="Mummu Gamashes +2"}
    sets.precast.Step = {ammo="Yamarang",
        head="Malignance Chapeau",neck="Assassin's Gorget +2",ear1="Telos Earring",ear2="Odr Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Cacoethic Ring +1",ring2="Ilabrat Ring",
        back=gear.TPCape,waist="Reiki Yotai",legs="Malignance Tights",feet="Malignance Boots"}
    sets.precast.JA['Violent Flourish'] = set_combine(sets.precast.Step, {ring1="Etana Ring",waist="Eschan Stone"})

    sets.precast.WS = {ammo="Voluspa Tathlum",
        head="Adhemar Bonnet +1",neck="Fotia Gorget",ear1="Moonshade Earring",ear2="Sherida Earring",
        body="Pillager's Vest +3",hands="Meghanada Gloves +2",ring1="Regal Ring",ring2="Ilabrat Ring",
        back=gear.TPCape,waist="Fotia Belt",legs="Pillager's Culottes +3",feet=gear.herc_feet_ta}

    sets.precast.WS.Rudras = {ammo="Voluspa Tathlum",
        head=gear.herc_head_wsd,neck="Assassin's Gorget +2",ear1="Moonshade Earring",ear2="Odr Earring",
        body="Meghanada Cuirie +2",hands="Meghanada Gloves +2",ring1="Regal Ring",ring2="Ilabrat Ring",
        back=gear.WSDCape,waist="Grunfeld Rope",legs="Plunderer's Culottes +3",feet=gear.herc_feet_wsd}
    sets.precast.WS.Rudras.PDT  = set_combine(sets.precast.WS.Rudras, {
        neck="Loricate Torque +1",ring1="Vocane Ring +1",ring2="Defending Ring"})
    sets.precast.WS.Rudras.SA   = set_combine(sets.precast.WS.Rudras, {ammo="Yetshila +1",head="Pillager's Bonnet +3"})
    sets.precast.WS.Rudras.TA   = set_combine(sets.precast.WS.Rudras.SA, {body="Plunderer's Vest +3"})
    sets.precast.WS.Rudras.SATA = set_combine(sets.precast.WS.Rudras.SA, {body="Plunderer's Vest +3"})
    sets.precast.WS['Rudra\'s Storm']      = sets.precast.WS.Rudras
    sets.precast.WS['Rudra\'s Storm'].SA   = sets.precast.WS.Rudras.SA
    sets.precast.WS['Rudra\'s Storm'].TA   = sets.precast.WS.Rudras.TA
    sets.precast.WS['Rudra\'s Storm'].SATA = sets.precast.WS.Rudras.SATA
    sets.precast.WS['Mandalic Stab']       = set_combine(sets.precast.WS.Rudras,      {ear2="Sherida Earring"})
    sets.precast.WS['Mandalic Stab'].SA    = set_combine(sets.precast.WS.Rudras.SA,   {ear2="Sherida Earring"})
    sets.precast.WS['Mandalic Stab'].TA    = set_combine(sets.precast.WS.Rudras.TA,   {ear2="Sherida Earring"})
    sets.precast.WS['Mandalic Stab'].SATA  = set_combine(sets.precast.WS.Rudras.SATA, {ear2="Sherida Earring"})
    sets.precast.WS['Shark Bite']          = set_combine(sets.precast.WS.Rudras,      {ear2="Sherida Earring"})
    sets.precast.WS['Shark Bite'].SA       = set_combine(sets.precast.WS.Rudras.SA,   {ear2="Sherida Earring"})
    sets.precast.WS['Shark Bite'].TA       = set_combine(sets.precast.WS.Rudras.TA,   {ear2="Sherida Earring"})
    sets.precast.WS['Shark Bite'].SATA     = set_combine(sets.precast.WS.Rudras.SATA, {ear2="Sherida Earring"})
    sets.precast.WS['Savage Blade']        = set_combine(sets.precast.WS.Rudras, {
        neck="Caro Necklace",ear2="Sherida Earring",ring2="Gere Ring",waist="Sailfi Belt +1"})
    sets.precast.WS['Savage Blade'].PDT    = set_combine(sets.precast.WS.Rudras.PDT, {ear2="Sherida Earring"})
    sets.precast.WS['Savage Blade'].SA     = set_combine(sets.precast.WS['Savage Blade'], {ammo="Yetshila +1",head="Pillager's Bonnet +3"})
    sets.precast.WS['Savage Blade'].TA     = set_combine(sets.precast.WS['Savage Blade'].SA, {body="Plunderer's Vest +3"})
    sets.precast.WS['Savage Blade'].SATA   = set_combine(sets.precast.WS['Savage Blade'].SA, {body="Plunderer's Vest +3"})

    sets.precast.WS.Exenterator = set_combine(sets.precast.WS, {ear1="Brutal Earring",ring2="Gere Ring"})
    sets.precast.WS['Dancing Edge'] = set_combine(sets.precast.WS.Exenterator, {})
    sets.precast.WS.Evisceration = {ammo="Yetshila +1",
        head="Adhemar Bonnet +1",neck="Fotia Gorget",ear1="Moonshade Earring",ear2="Odr Earring",
        body="Plunderer's Vest +3",hands="Mummu Wrists +2",ring1="Regal Ring",ring2="Gere Ring",
        back=gear.EvisCape,waist="Fotia Belt",legs="Pillager's Culottes +3",feet="Mummu Gamashes +2"}
    sets.precast.WS.Evisceration.Acc  = set_combine(sets.precast.WS.Evisceration, {head="Pillager's Bonnet +3"})
    sets.precast.WS.Evisceration.PDT  = set_combine(sets.precast.WS.Evisceration, {ring1="Vocane Ring +1",ring2="Defending Ring"})
    sets.precast.WS['Vorpal Blade']   = set_combine(sets.precast.WS.Evisceration, {})

    sets.precast.WS.Shadowstitch = {ammo="Yamarang",
        head="Malignance Chapeau",neck="Assassin's Gorget +2",ear1="Telos Earring",ear2="Dignitary's Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Etana Ring",ring2="Cacoethic Ring +1",
        back=gear.TPCape,waist="Eschan Stone",legs="Malignance Tights",feet="Malignance Boots"}
    sets.precast.WS['Flat Blade'] = set_combine(sets.precast.WS.Shadowstitch, {})

    sets.precast.WS['Aeolian Edge'] = {ammo="Pemphredo Tathlum",
        head=gear.herc_head_ma,neck="Sanctity Necklace",ear1="Moonshade Earring",ear2="Friomisi Earring",
        body="Samnuha Coat",hands=gear.herc_hands_ma,ring1="Dingir Ring",ring2="Ilabrat Ring",
        back=gear.WSDCape,waist="Fotia Belt",legs=gear.herc_legs_ma,feet=gear.herc_feet_ma}
    sets.precast.WS.Cyclone            = set_combine(sets.precast.WS['Aeolian Edge'], {})
    sets.precast.WS['Sanguine Blade']  = set_combine(sets.precast.WS['Aeolian Edge'], {head="Pixie Hairpin +1",ring1="Archon Ring"})
    sets.orpheus = {waist="Orpheus's Sash"}
    sets.ele_obi = {waist="Hachirin-no-Obi"}

    sets.precast.WS.NoDmg = set_combine(sets.precast.Step, {})

    -- Midcast Sets
    sets.midcast.RA = {ammo="Dart"}
    sets.midcast.Utsusemi = {ammo="Staunch Tathlum +1",
        head="Malignance Chapeau",neck="Assassin's Gorget +2",ear1="Eabani Earring",ear2="Genmei Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.IdleCape,waist="Sveltesse Gouriz +1",legs="Malignance Tights",feet="Turms Leggings +1"}
    sets.phlx = set_combine(sets.midcast.Utsusemi, {head=gear.taeon_head_phlx,body=gear.taeon_body_phlx,
        hands=gear.taeon_hands_phlx,legs=gear.taeon_legs_phlx,feet=gear.taeon_feet_phlx})
    sets.midcast.BarElement = {neck="Incanter's Torque",ear1="Andoaa Earring",ear2="Mimir Earring",
        ring1=gear.Lstikini,ring2=gear.Rstikini,waist="Olympus Sash"}
    sets.midcast.Phalanx = set_combine(sets.phlx, sets.midcast.BarElement)  -- tiers every 10 skill up to 300
    sets.midcast['Enfeebling Magic'] = {ammo="Yamarang",
        head="Malignance Chapeau",neck="Assassin's Gorget +2",ear1="Gwati Earring",ear2="Dignitary's Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1=gear.Lstikini,ring2=gear.Rstikini,
        back=gear.IdleCape,waist="Eschan Stone",legs="Malignance Tights",feet="Malignance Boots"}
    sets.midcast.Repose = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast.Absorb = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast.Refresh = {waist="Gishdubar Sash"}
    sets.midcast.Flash = set_combine(sets.Enmity, {})
    sets.midcast.Stun  = set_combine(sets.Enmity, {})
    sets.midcast.Sleepga = set_combine(sets.midcast.Utsusemi, sets.TreasureHunter)
    sets.midcast.Sleepga.MAcc = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast.Diaga    = set_combine(sets.midcast.Utsusemi, sets.TreasureHunter)
    sets.midcast.Poisonga = set_combine(sets.midcast.Utsusemi, sets.TreasureHunter)
    info.th_gearsets = T{'Sleepga','Diaga','Poisonga'}

    -- Sets to return to when not performing an action.
    sets.idle = {main="Gandring",sub="Ternion Dagger +1",ammo="Yamarang",
        head="Turms Cap +1",neck="Loricate Torque +1",ear1="Eabani Earring",ear2="Infused Earring",
        body="Malignance Tabard",hands="Turms Mittens +1",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.IdleCape,waist="Engraved Belt",legs="Malignance Tights",feet="Pillager's Poulaines +3"}
    -- pdt-50, mdt-40, rg+14, eva~1253, meva+661
    sets.idle.Eva = {main="Gandring",sub="Ternion Dagger +1",ammo="Yamarang",
        head="Turms Cap +1",neck="Assassin's Gorget +2",ear1="Eabani Earring",ear2="Infused Earring",
        body="Malignance Tabard",hands="Turms Mittens +1",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.IdleCape,waist="Sveltesse Gouriz +1",legs="Malignance Tights",feet="Turms Leggings +1"}
    -- pdt-44, mdt-34, rg+19, eva~1320, meva+689
    sets.idle.Rf = {main="Gandring",sub="Ternion Dagger +1",ammo="Staunch Tathlum +1",
        head=gear.herc_head_rf,neck="Loricate Torque +1",ear1="Eabani Earring",ear2="Infused Earring",
        body="Mekosuchinae Harness",hands="Malignance Gloves",ring1=gear.Lstikini,ring2=gear.Rstikini,
        back=gear.IdleCape,waist="Flume Belt +1",legs="Rawhide Trousers",feet="Malignance Boots"}
    sets.idle.STP = {main="Gandring",sub="Ternion Dagger +1",ammo="Yamarang",
        head="Turms Cap +1",neck="Anu Torque",ear1="Dedition Earring",ear2="Sherida Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Moonlight Ring",ring2="Ilabrat Ring",
        back=gear.TPCape,waist="Reiki Yotai",legs="Malignance Tights",feet="Malignance Boots"}

    sets.defense.EvaPDT = set_combine(sets.idle.Eva, {ammo="Staunch Tathlum +1",waist="Flume Belt +1"})
    -- pdt-50, mdt-37, rg+19, eva~1290, meva+674
    sets.defense.EvaEng = {main="Gandring",sub="Ternion Dagger +1",ammo="Yamarang",
        head="Malignance Chapeau",neck="Assassin's Gorget +2",ear1="Telos Earring",ear2="Sherida Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Moonlight Ring",ring2="Defending Ring",
        back=gear.TPCape,waist="Reiki Yotai",legs="Malignance Tights",feet="Malignance Boots"}
    -- pdt-50, mdt-46, eva~1238, meva+689
    -- TwashCent: acc~1325/1099, haste+26, dw+7, stp+82, da+6, ta+4
    sets.defense.Eva = set_combine(sets.idle.Eva, {})
    sets.defense.Kite = set_combine(sets.idle, {})
    sets.defense.MEVA = {main="Gandring",sub="Ternion Dagger +1",ammo="Yamarang",
        head="Malignance Chapeau",neck="Assassin's Gorget +2",ear1="Eabani Earring",ear2="Sherida Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.IdleCape,waist="Engraved Belt",legs="Malignance Tights",feet="Malignance Boots"}

    sets.Kiting = {feet="Pillager's Poulaines +3"}
    sets.buff.sleep = {head="Frenzy Sallet"}
    sets.buff.doom = {neck="Nicander's Necklace",ring1="Eshmun's Ring",ring2="Defending Ring",waist="Gishdubar Sash"}
    sets.midcast.FastRecast = set_combine(sets.defense.EvaPDT, {})

    -- Engaged sets
    sets.engaged = {main="Tauret",sub="Ternion Dagger +1",ammo="Yamarang",
        head="Adhemar Bonnet +1",neck="Assassin's Gorget +2",ear1="Telos Earring",ear2="Sherida Earring",
        body="Adhemar Jacket +1",hands="Adhemar Wristbands +1",ring1="Hetairoi Ring",ring2="Gere Ring",
        back=gear.TPCape,waist="Windbuffet Belt +1",legs="Samnuha Tights",feet=gear.herc_feet_ta}
    -- TwashCent: acc~1216/990, haste+26, dw+6, stp+33, da+12, ta+32, qa+2, pdt-12, eva~1009, meva+336
    sets.engaged.DW30 = set_combine(sets.engaged, {ear1="Eabani Earring",back=gear.DWCape,waist="Reiki Yotai"})
    sets.engaged.TaurShijo = set_combine(sets.engaged, {body="Pillager's Vest +3"})
    -- TaurShijo: acc~1224/1216, haste+26, dw+5, stp+33, da+12, ta+37, qa+2, pdt-12, eva~1043, meva+361

    sets.engaged.PDef = set_combine(sets.engaged, {ammo="Staunch Tathlum +1",
        head="Malignance Chapeau",body="Malignance Tabard",ring1="Moonlight Ring",waist="Reiki Yotai",legs="Malignance Tights"})
    -- TwashCent: acc~1274/1048, haste+26, dw+7, stp+65, da+6, ta+19, pdt-42, mdt-30, eva~1134, meva+530
    sets.engaged.DW30.PDef = set_combine(sets.engaged.PDef, {ear1="Eabani Earring",body="Adhemar Jacket +1",back=gear.DWCape})
    sets.engaged.TaurShijo.PDef = set_combine(sets.engaged.PDef, {waist="Windbuffet Belt +1"})

    sets.engaged.MDef = set_combine(sets.engaged, {
        head="Malignance Chapeau",body="Malignance Tabard",hands="Malignance Gloves",
        waist="Reiki Yotai",legs="Malignance Tights",feet="Malignance Boots"})
    -- TwashCent: acc~1317/1091, haste+26, dw+7, stp+77, da+6, ta+10, pdt-41, mdt-31, eva~1238, meva+689
    sets.engaged.DW30.MDef = set_combine(sets.engaged.MDef, {ear1="Eabani Earring",back=gear.DWCape})
    sets.engaged.TaurShijo.MDef = set_combine(sets.engaged.MDef, {waist="Windbuffet Belt +1"})

    sets.engaged.Acc = set_combine(sets.engaged, {
        head="Plunderer's Bonnet +3",body="Pillager's Vest +3",waist="Reiki Yotai",legs="Pillager's Culottes +3"})
    -- TwashCent: acc~1312/1086, haste+26, dw+7, stp+30, da+9, ta+35, pdt-12, eva~1075, meva+399
    sets.engaged.DW30.Acc = set_combine(sets.engaged.Acc, {
        ear1="Eabani Earring",body="Adhemar Jacket +1",back=gear.DWCape,waist="Reiki Yotai"})
    sets.engaged.TaurShijo.Acc = set_combine(sets.engaged.Acc, {waist="Windbuffet Belt +1"})

    sets.engaged.Acc.PDef = set_combine(sets.engaged.PDef, {ammo="Yamarang"})
    sets.engaged.DW30.Acc.PDef = set_combine(sets.engaged.Acc.PDef, {ear1="Eabani Earring",back=gear.DWCape})
    sets.engaged.TaurShijo.Acc.PDef = set_combine(sets.engaged.Acc.PDef, {waist="Windbuffet Belt +1"})

end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-- Set eventArgs.handled to true if we don't want any automatic target handling to be done.
function job_pretarget(spell, action, spellMap, eventArgs)
    if S{'Sneak Attack','Trick Attack'}:contains(spell.english) and state.Buff[spell.english] then
        if windower.ffxi.get_ability_recasts()[spell.recast_id] > 30 then
            -- only equip SA/TA gear on a double tap to avoid interfering with rapid SA/TA WS swaps
            eventArgs.cancel = true
            check_buff(spell.english, eventArgs)
        end
    end
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.
function job_precast(spell, action, spellMap, eventArgs)
    if S{'Defender','Souleater','Last Resort'}:contains(spell.english) and buffactive[spell.english] then
        send_command('cancel '..spell.english)
        eventArgs.cancel = true
    end
end

-- Run after the general precast() is done.
function job_post_precast(spell, action, spellMap, eventArgs)
    if spell.type == 'WeaponSkill' then
        if state.WeaponskillMode.value == 'NoDmg' then
            if info.magic_ws:contains(spell.english) then
                equip(sets.naked)
            else
                equip(sets.precast.WS.NoDmg)
            end
        elseif state.WeaponskillMode.value == 'Normal' then
            if state.DefenseMode.value ~= 'None' then
                if not state.Buff['Sneak Attack'] and not state.Buff['Trick Attack']
                and S{'Rudra\'s Storm','Evisceration','Savage Blade'}:contains(spell.english) then
                    equip(sets.precast.WS[spell.english].PDT)
                end
            elseif spell.english == 'Evisceration' and state.OffenseMode.value == 'Acc' then
                equip(sets.precast.WS.Evisceration.Acc)
            end

            if info.magic_ws:contains(spell.english) then
                equip(resolve_ele_belt(spell, sets.ele_obi))
            end

            if buffactive['elvorseal'] then
                if player.inventory["Heidrek Boots"] then equip({feet="Heidrek Boots"}) end
            end
        end

        if state.THAeolian.value and spell.english == 'Aeolian Edge'
        or state.TreasureMode.value == 'Fulltime' then
            equip(sets.TreasureHunter)
        end
    end
end

-- Run after the general midcast() set is constructed.
function job_post_midcast(spell, action, spellMap, eventArgs)
    if state.TreasureMode.value ~= 'None' and spell.action_type == 'Ranged Attack' then
        equip(sets.TreasureHunter)
    end
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_aftercast(spell, action, spellMap, eventArgs)
    if spell.interrupted then
        send_command('wait 0.5;gs c update')
        interrupted_message(spell)
    elseif spell.type == 'WeaponSkill' then
        if state.WSMsg.value then
            send_command('@input /p '..spell.english)
        end
        if spell.english == 'Aeolian Edge' then
            state.THAeolian:unset()
            hud_update_on_state_change('TH Aeolian')
        end
        -- Weaponskills wipe SATA/Feint.  Turn those state vars off before default gearing is attempted.
        state.Buff['Sneak Attack'] = false
        state.Buff['Trick Attack'] = false
        state.Buff['Feint'] = false
    elseif spell.type == 'JobAbility' then
        if not (sets.precast.JA[spell.english] or spell.english == 'Feint') then
            eventArgs.handled = true
        end
    elseif spell.type == 'Rune' then
        eventArgs.handled = true
    end
end

-- Called after the default aftercast handling is complete.
function job_post_aftercast(spell, action, spellMap, eventArgs)
    -- If Feint is active, put that gear set on on top of regular gear.
    -- This includes overlaying SATA gear.
    if player.status == 'Engaged' then
        check_buff('Feint', eventArgs)
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
    if state.DefenseMode.value == 'None' and S{'stun','terror','petrification'}:contains(lbuff) then
        if gain then
            equip(sets.defense.EvaPDT)
        elseif not midaction() then
            handle_equipping_gear(player.status)
        end
    elseif gain and lbuff == 'sleep' then
        equip(sets.buff.sleep)
        send_command('cancel Stoneskin')
    elseif not midaction() then
        if S{'sleep','doom'}:contains(lbuff) then
            handle_equipping_gear(player.status)
        elseif not gain and S{'sneak attack','trick attack','feint'}:contains(lbuff) then
            handle_equipping_gear(player.status)
        end
    end
    if gain then
        add_to_chat(104, 'Gained ['..buff..']')
    end
end

-- Handle notifications of general user state change.
function job_state_change(stateField, newValue, oldValue)
    if stateField == 'Offense Mode' then
        enable('main','sub','range','ammo')
        if newValue ~= 'None' then
            equip(sets.weapons[state.CombatWeapon.value])
            disable('main','sub')
        end
        handle_equipping_gear(player.status)
    elseif stateField == 'Combat Weapon' then
        info.ws_binds:bind(state.CombatWeapon)
        if state.OffenseMode.value ~= 'None' then
            enable('main','sub','range','ammo')
            -- try to handle exchanging mainhand and offhand weapons gracefully
            local new_set = sets.weapons[state.CombatWeapon.value]
            if player.equipment.sub == new_set.main then
                equip({main=empty,sub=empty})
                add_to_chat(123, 'unequipped weapons')
            elseif player.equipment.main == new_set.sub then
                equip({main=new_set.main,sub=empty})
                add_to_chat(123, 'unequipped offhand')
            else
                equip(new_set)
            end
            disable('main','sub')
        end
        if     sets.weapons[state.CombatWeapon.value].main == "Gandring" then
            if sets.weapons[state.CombatWeapon.value].sub == "Taming Sari" then
                sets.TreasureHunter = set_combine(sets.TreasureHunter1, {})
            else
                sets.TreasureHunter = set_combine(sets.TreasureHunter2, {})
            end
        elseif sets.weapons[state.CombatWeapon.value].sub == "Taming Sari" then
            sets.TreasureHunter = set_combine(sets.TreasureHunter4, {})
        else
            sets.TreasureHunter = set_combine(sets.TreasureHunter5, {})
        end
        update_th_sets(sets.TreasureHunter)
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

function get_custom_wsmode(spell, spellMap, defaut_wsmode)
    local wsmode = nil

    if state.Buff['Sneak Attack'] or buffactive['Mighty Strikes'] then
        wsmode = 'SA'
    end
    if state.Buff['Trick Attack'] then
        wsmode = (wsmode or '') .. 'TA'
    end

    return wsmode
end

-- Called any time we attempt to handle automatic gear equips (ie: engaged or idle gear).
function job_handle_equipping_gear(playerStatus, eventArgs)
    -- Check for SATA when equipping gear.  If either is active, equip
    -- that gear specifically, and block equipping default gear.
    if playerStatus == 'Engaged' then
        check_buff('Sneak Attack', eventArgs)
        check_buff('Trick Attack', eventArgs)
        check_buff('Feint', eventArgs)
    end
end

-- Modify the default idle set after it was constructed.
function customize_idle_set(idleSet)
    if has_any_buff_of(S{'petrification','sleep','stun','terror'}) then
        idleSet = set_combine(sets.defense.EvaPDT, {})
    end
    if state.Buff.doom then
        idleSet = set_combine(idleSet, sets.buff.doom)
    end
    return idleSet
end

-- Modify the default defense set after it was constructed.
function customize_defense_set(defenseSet)
    defmode = state[state.DefenseMode.value..'DefenseMode'].value
    if defmode == 'EvaEng' then
        if player.status ~= 'Engaged' then
            defenseSet = sets.defense.Kite
        elseif state.CombatForm.has_value and state.CombatForm.value:startswith('DW') then
            defenseSet = set_combine(defenseSet, {back=gear.DWCape})
        end
    end
    if state.Buff.doom then
        defenseSet = set_combine(defenseSet, sets.buff.doom)
    end
    return defenseSet
end

-- Modify the default melee set after it was constructed.
function customize_melee_set(meleeSet)
    if state.DefenseMode.value == 'None' then
        if state.TreasureMode.value == 'Fulltime' then
            meleeSet = set_combine(meleeSet, sets.TreasureHunter)
        end
        if buffactive['elvorseal'] then
            if player.inventory["Heidrek Gloves"] then meleeSet = set_combine(meleeSet, {hands="Heidrek Gloves"}) end
            if player.inventory["Heidrek Harness"] then meleeSet = set_combine(meleeSet, {body="Heidrek Harness"}) end
        end
    end
    if has_any_buff_of(S{'petrification','sleep','stun','terror'}) then
        meleeSet = set_combine(sets.defense.EvaPDT, {})
    end
    if state.Buff.doom then
        meleeSet = set_combine(meleeSet, sets.buff.doom)
    end
    if state.Buff.sleep then
        meleeSet = set_combine(meleeSet, sets.buff.sleep)
    end
    return meleeSet
end

-- Called by the 'update' self-command.
-- Set eventArgs.handled to true if we don't want automatic equipping of gear.
function job_update(cmdParams, eventArgs)
    if state.th_gear_is_locked and cmdParams[1] == 'user' and player.status ~= 'Engaged' then
        unlock_TH()
    end
    th_update(cmdParams, eventArgs)
    state.Buff['Sneak Attack'] = buffactive['sneak attack'] or false
    state.Buff['Trick Attack'] = buffactive['trick attack'] or false
    if midaction() and cmdParams[1] == 'auto' then
        -- don't break midcast for state changes and such
        eventArgs.handled = true
    end
end

-- Set eventArgs.handled to true if we don't want the automatic display to be run.
function display_current_job_state(eventArgs)
    local msg = ''

    msg = msg .. 'TP[' .. state.OffenseMode.current
    if state.HybridMode.value ~= 'Normal' then
        msg = msg .. '/' .. state.HybridMode.value
    end
    msg = msg .. ':' .. state.CombatWeapon.value
    if state.CombatForm.has_value then
        msg = msg .. '/' .. state.CombatForm.value
    end
    msg = msg .. ']'

    if state.WeaponskillMode.value ~= 'Normal' then
        msg = msg .. ' WS[' .. state.WeaponskillMode.current .. ']'
    end
    msg = msg .. ' Idle[' .. state.IdleMode.current .. ']'
    msg = msg .. ' TH[' .. state.TreasureMode.value .. ']'

    if state.DefenseMode.value ~= 'None' then
        local defMode = state[state.DefenseMode.value ..'DefenseMode'].current
        msg = msg .. ' Def[' .. state.DefenseMode.value .. ':' .. defMode .. ']'
    end
    if state.WSMsg.value then
        msg = msg .. ' WSMsg'
    end
    if state.Kiting.value then
        msg = msg .. ' Kiting'
    end

    add_to_chat(122, msg)

    eventArgs.handled = true
end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements self-commands.
-------------------------------------------------------------------------------------------------------------------

-- Called for custom player commands.
function job_self_command(cmdParams, eventArgs)
    eventArgs.handled = true
    if cmdParams[1] == 'ListWS' then
        info.ws_binds:print('ListWS:')
    elseif cmdParams[1] == 'save' then
        save_self_command(cmdParams)
    elseif cmdParams[1] == 'rebind' then
        info.keybinds:bind()
    elseif cmdParams[1] == 'retag' then
        if state.TreasureMode.value ~= 'None' and player.target and player.target.type == 'MONSTER' then
            add_to_chat(121,'retagging target for TH')
            info.tagged_mobs[player.target.id] = nil
            TH_for_first_hit()
        end
    else
        eventArgs.handled = false
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------

-- State buff checks that will equip buff gear and mark the event as handled.
function check_buff(buff_name, eventArgs)
    if state.Buff[buff_name] then
        equip_gear_by_status(player.status)
        equip(sets.buff[buff_name] or {})
        if S{'SATA','Fulltime'}:contains(state.TreasureMode.value) then
            if buff_name ~= 'Feint' then
                equip(sets.TreasureHunter)
            end
        end
        eventArgs.handled = true
    end
end

-- update sets that use sets.TreasureHunter as it changes with weapon swaps
function update_th_sets(treasure_set)
    for spell in info.th_gearsets:it() do
        sets.midcast[spell] = set_combine(sets.midcast.Utsusemi, treasure_set)
    end
end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    set_macro_page(1,8)
    send_command('bind !^l input /lockstyleset 8')
end

-- returns a list for use with make_keybind_list
function job_keybinds()
    local bind_command_list = L{
        'bind %`|F12 gs c update user',
        'bind F9   gs c cycle OffenseMode',
        'bind @F9  gs c cycle WeaponskillMode',
        'bind !F9  gs c reset OffenseMode',
        'bind F10  gs c cycle CastingMode',
        'bind !F10 gs c reset CastingMode',
        'bind F11  gs c cycle IdleMode',
        'bind !F11 gs c reset IdleMode',
        'bind @F11 gs c toggle Kiting',
        'bind ^F12  gs c set TreasureMode None',
        'bind !F12  gs c set TreasureMode Tag',
        'bind @F12  gs c set TreasureMode SATA',
        'bind !@F12 gs c set TreasureMode Fulltime',
        'bind ^space gs c cycle HybridMode',
        'bind !space gs c set DefenseMode Physical',
        'bind @space gs c set DefenseMode Magical',
        'bind !@space gs c reset DefenseMode',
        'bind !w  gs c reset OffenseMode',
        'bind !@w gs c set   OffenseMode None',
        'bind @c  gs c set OffenseMode MDef',
        'bind !c  gs c set OffenseMode Acc',
        'bind %c  gs c retag',
        'bind !^q  gs c set CombatWeapon TaurTwash',
        'bind ~!^q gs c set CombatWeapon TaurShijo',
        'bind !^w  gs c set CombatWeapon GandCent',
        'bind ~!^w gs c set CombatWeapon GandTern',
        'bind ^@w  gs c set CombatWeapon AenTwash',
        'bind !^e  gs c set CombatWeapon TwashCent',
        'bind ~!^e gs c set CombatWeapon TwashTern',
        'bind !^r  gs c set CombatWeapon NaegCent',
        'bind ~!^r gs c set CombatWeapon NaegTern',
        'bind ^z gs c toggle THAeolian',
        'bind !z gs c cycle PhysicalDefenseMode',
        'bind @z gs c cycle MagicalDefenseMode',
        'bind ^\\\\  gs c toggle WSMsg',

        'bind !^` input /ja "Perfect Dodge" <me>',
        'bind ^@` input /ja Larceny',
        'bind ^` input /ja "Assassin\'s Charge" <me>',
        'bind ^tab input /ja "Sneak Attack" <me>',
        'bind ^q input /ja "Trick Attack" <me>',
        'bind ^@tab input /ja Steal',
        'bind ^@q input /ja Flee <me>',
        'bind !@q input /ja Hide <me>',
        'bind @tab input /ja Mug',
        'bind @q input /ja Despoil',
        'bind !b input //cancel haste',
        'bind @g gs equip phlx',
        'bind @n input /item "Living Key" <t>',

        'bind ^@1  input /ja Collaborator <stpc>',
        'bind ^@2  input /ja Collaborator <p1>',
        'bind ^@3  input /ja Collaborator <p2>',
        'bind ^@4  input /ja Collaborator <p3>',
        'bind ^@5  input /ja Collaborator <p4>',
        'bind ^@6  input /ja Collaborator <p5>',
        'bind ~^@1 input /ja Accomplice <stpc>',
        'bind ~^@2 input /ja Accomplice <p1>',
        'bind ~^@3 input /ja Accomplice <p2>',
        'bind ~^@4 input /ja Accomplice <p3>',
        'bind ~^@5 input /ja Accomplice <p4>',
        'bind ~^@6 input /ja Accomplice <p5>',

        'bind !1 input /ja Feint',
        'bind !2 input /ja Bully',
        'bind !3 input /ja Conspirator <me>',

        'bind !9 gs c set CombatForm DW30',
        'bind !0 gs c reset CombatForm',

        'bind @1 input /ra <stnpc>'}

    if     player.sub_job == 'WAR' then
        bind_command_list:extend(L{
            'bind !4  input /ja Berserk <me>',
            'bind !5  input /ja Aggressor <me>',
            'bind !6  input /ja Warcry <me>',
            'bind !d  input /ja Provoke',
            'bind @d  input /ja Provoke <stnpc>',
            'bind !@d input /ja Defender <me>'})
    elseif player.sub_job == 'DRK' then
        bind_command_list:extend(L{
            'bind !4  input /ja "Last Resort" <me>',
            'bind !5  input /ja Souleater <me>',
            'bind !6  input /ja "Arcane Circle" <me>',
            'bind !e  input /ma Absorb-TP',
            'bind !d  input /ma Stun',
            'bind @d  input /ma Stun <stnpc>',
            'bind !@d input /ma Poisonga <stnpc>'})
    elseif player.sub_job == 'DRG' then
        bind_command_list:extend(L{
            'bind !4  input /ja "High Jump"',
            'bind !6  input /ja "Ancient Circle" <me>',
            'bind !e  input /ja "High Jump"',
            'bind !@e input /ja Jump'})
    elseif player.sub_job == 'NIN' then
        bind_command_list:extend(L{
            'bind !e  input /ma "Utsusemi: Ni" <me>',
            'bind !@e input /ma "Utsusemi: Ichi" <me>'})
    elseif player.sub_job == 'DNC' then
        bind_command_list:extend(L{
            'bind !4  input /recast "Curing Waltz III"; input /ja "Curing Waltz III" <stpc>',
            'bind !5  input /recast "Healing Waltz"; input /ja "Healing Waltz" <stpc>',
            'bind !6  input /ja "Divine Waltz" <me>',
            'bind !v  input /ja "Spectral Jig" <me>',
            'bind !d  input /ja "Animated Flourish"',
            'bind @d  input /ja "Animated Flourish" <stnpc>',
            'bind !@d input /ja "Violent Flourish"',
            'bind !f  input /ja "Haste Samba" <me>',
            'bind !@f input /ja "Reverse Flourish" <me>',
            'bind !e  input /ja "Box Step"',
            'bind !@e input /ja Quickstep'})
    elseif player.sub_job == 'RUN' then
        bind_command_list:extend(L{
            'bind @1 input /ja Ignis <me>',    -- fire up,    ice down
            'bind @2 input /ja Gelus <me>',    -- ice up,     wind down
            'bind @3 input /ja Flabra <me>',   -- wind up,    earth down
            'bind @4 input /ja Tellus <me>',   -- earth up,   thunder down
            'bind @5 input /ja Sulpor <me>',   -- thunder up, water down
            'bind @6 input /ja Unda <me>',     -- water up,   fire down
            'bind @7 input /ja Lux <me>',      -- light up,   dark down
            'bind @8 input /ja Tenebrae <me>', -- dark up,    light down
            'bind !4 input /ja Swordplay <me>',
            'bind !5 input /ja Vallation <me>',
            'bind !6 input /ja Pflug <me>',
            'bind !d input /ma Flash',
            'bind @d input /ma Flash <stnpc>',
            'bind !^v input /ma Aquaveil <me>'})
    elseif player.sub_job == 'SAM' then
        bind_command_list:extend(L{
            'bind !4 input /ja Meditate <me>',
            'bind !5 input /ja Sekkanoki <me>',
            'bind !6 input /ja "Warding Circle" <me>',
            'bind !d input /ja "Third Eye" <me>'})
    elseif player.sub_job == 'BLM' then
        bind_command_list:extend(L{
            'bind !e  input /ma Sleepga',
            'bind @e  input /ma Sleepga <stnpc>',
            'bind !@e input /ja "Elemental Seal" <me>',
            'bind !d  input /ma Stun',
            'bind @d  input /ma Stun <stnpc>'})
    elseif player.sub_job == 'RDM' then
        bind_command_list:extend(L{
            'bind !d  input /ma Dispel',
            'bind @d  input /ma Diaga <stnpc>',
            'bind !f  input /ma Haste <me>',
            'bind @f  input /ma Refresh <me>',
            'bind @v  input /ma Aquaveil <me>',
            'bind !g  input /ma Phalanx <me>',
            'bind !@g input /ma Stoneskin <me>'})
    end

    return bind_command_list
end

function init_state_text()
    if hud then return end

    local thae_text_settings = {flags={draggable=false},bg={alpha=150}}
    local hyb_text_settings  = {pos={x=130,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local def_text_settings  = {pos={x=172,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local off_text_settings  = {pos={x=172,y=697},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local dw_text_settings   = {pos={x=130,y=697},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}

    hud = {texts=T{}}
    hud.texts.thae_text = texts.new('THAE',           thae_text_settings)
    hud.texts.hyb_text  = texts.new('initializing..', hyb_text_settings)
    hud.texts.def_text  = texts.new('initializing..', def_text_settings)
    hud.texts.off_text  = texts.new('initializing..', off_text_settings)
    hud.texts.dw_text   = texts.new('initializing..', dw_text_settings)

    -- update infrequently changing text boxes in job_state_change or where they are changed
    function hud_update_on_state_change(stateField)
        if not hud then init_state_text() end

        if not stateField or stateField == 'TH Aeolian' then
            hud.texts.thae_text:visible(state.THAeolian.value)
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

        if not stateField or stateField == 'Offense Mode' then
            if state.OffenseMode.value ~= 'Normal' then
                hud.texts.off_text:text(state.OffenseMode.value)
                hud.texts.off_text:show()
            else hud.texts.off_text:hide() end
        end

        if not stateField or stateField == 'Combat Form' then
            if state.CombatForm.has_value then
                hud.texts.dw_text:text(state.CombatForm.value)
                hud.texts.dw_text:show()
            else hud.texts.dw_text:hide() end
        end
    end
end
