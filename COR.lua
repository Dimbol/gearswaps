-- Modified from 'https://github.com/Kinematics/GearSwap-Jobs/blob/master/COR.lua'
-- TODO subtle blow sets
-- TODO true shot sets
-- TODO better dual wield sets (/dnc or low haste)
-- TODO ambu capes (RA-enm, DW)
-- TODO new TH+4 actions (special /ra or castingmode for lightshot?)

-- /nin dual wield cheatsheet
-- haste:   0   15  30  cap
--   +dw:  49   42  31   11
-- add 10 for /dnc

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
    state.Buff['Triple Shot'] = buffactive['Triple Shot'] or false
    state.Buff.doom = buffactive.doom or false

    define_roll_values()

    logout_event_id = windower.raw_register_event('logout', destroy_state_text)
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
    state.OffenseMode:options('None','Normal','EXP','Acc','Crit')                           -- Cycle with F9, set with !w, @w. !@w, !c
    state.HybridMode:options('Normal','PDef')                                               -- Cycle with ^F9, ^space
    state.RangedMode:options('Normal','Acc','HighAcc','Crit','CritAcc','Enmity','Recycle')  -- Cycle with !F9, set with mod+z
    state.WeaponskillMode:options('Normal','Acc','Enmity','NoDmg')                          -- Cycle with @F9, set with @x, !@x, ~!@x
    state.CastingMode:options('STP','Normal','Acc')                                         -- Cycle with F10, set with ^c, ~^c, ~!^c
    state.IdleMode:options('Normal','PDT','Rf')                                             -- Cycle with F11
    state.MagicalDefenseMode:options('MDT')
    state.MeleeWeapon = M{['description']='Melee Weapon'}
    state.RangedWeapon = M{['description']='Ranged Weapon'}
    state.RangedWeapon:options('Fomal','Arma','DPen','TP')
    if S{'DNC','NIN'}:contains(player.sub_job) then
        state.MeleeWeapon:options('NaegDW','NaegTaur','TaurDW','TaurNaeg','GletiRA','RosARA','RosATaur','RosCRA','RosCTaur')
        classes.CustomMeleeGroups:append(player.sub_job)
    else
        state.MeleeWeapon:options('RosA1h','RosC1h','Naeg1h','Taur1h','Gleti1h')
    end
    state.WSMsg     = M(false, 'WS Message')                                -- Toggle with ^\
    state.LuzafRing = M(true,  "Luzaf's Ring")                              -- Toggle with !z
    state.DUEnmity  = M(true,  'Double-Up Enmity')                          -- Toggle with @\\
    state.NoFlurry  = M(false, 'no flurry plz')                             -- anti-koru-moru

    init_state_text()
    hud_update_on_state_change()

    info.magic_ws = S{'Hot Shot','Wildfire','Leaden Salute','Gust Slash','Cyclone','Aeolian Edge',
                      'Burning Blade','Red Lotus Blade','Shining Blade','Seraph Blade','Sanguine Blade'}

    -- Augmented items get variables for convenience and specificity
    gear.RostamA = {name="Rostam", augments={'Path: A'}}
    gear.RostamC = {name="Rostam", augments={'Path: C'}}
    gear.MAWSCape = {name="Camulus's Mantle", augments={'AGI+20','Mag. Acc+20 /Mag. Dmg.+20','Weapon skill damage +10%'}}
    gear.RATPCape = {name="Camulus's Mantle", augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','"Store TP"+10'}}
    gear.RACRCape = {name="Camulus's Mantle", augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','Crit.hit rate+10'}}
    gear.RAWSCape = {name="Camulus's Mantle", augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','Weapon skill damage +10%'}}
    gear.METPCape = {name="Camulus's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','"Dbl.Atk."+10'}}
    gear.DWCape   = {name="Camulus's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','"Dual Wield"+10'}}
    gear.MEWSCape = {name="Camulus's Mantle", augments={'STR+20','Accuracy+20 Attack+20','Weapon skill damage +10%'}}
    gear.SnapCape = {name="Camulus's Mantle", augments={'"Snapshot"+10'}}
    gear.FastCape = {name="Camulus's Mantle", augments={'"Fast Cast"+10'}}
    gear.Lstikini = {name="Stikini Ring +1", bag="wardrobe2"}
    gear.Rstikini = {name="Stikini Ring +1", bag="wardrobe3"}
    gear.taeon_head_snap  = {name="Taeon Chapeau", augments={'"Snapshot"+5'}}
    gear.taeon_body_snap  = {name="Taeon Tabard", augments={'"Snapshot"+5'}}
    gear.taeon_hands_snap = {name="Taeon Gloves", augments={'"Snapshot"+5'}}
    gear.taeon_feet_snap  = {name="Taeon Boots", augments={'"Snapshot"+5'}}
    gear.taeon_head_phlx  = {name="Taeon Chapeau", augments={'Phalanx +3'}}
    gear.adh_body_ta = {name="Adhemar Jacket +1", augments={'Accuracy+20'}}
    gear.adh_body_fc = {name="Adhemar Jacket +1", augments={'"Fast Cast"+10'}}
    gear.herc_head_ma  = {name="Herculean Helm", augments={'"Mag.Atk.Bns."+23','Mag. Acc.+16','Mag. Acc.+12 "Mag.Atk.Bns."+12'}}
    gear.herc_legs_ma  = {name="Herculean Trousers", augments={'"Mag.Atk.Bns."+30','Mag. Acc.+16 "Mag.Atk.Bns."+16'}}
    gear.herc_legs_fc  = {name="Herculean Trousers", augments={'"Fast Cast"+7'}}
    gear.herc_feet_ta  = {name="Herculean Boots", augments={'"Triple Atk."+4'}}
    gear.herc_hands_rf = {name="Herculean Gloves", augments={'"Refresh"+2'}}
    gear.herc_legs_rf  = {name="Herculean Trousers", augments={'"Refresh"+2'}}
    gear.herc_legs_th  = {name="Herculean Trousers", augments={'"Treasure Hunter"+2'}}
    gear.herc_head_fc  = {name="Herculean Helm", augments={'"Fast Cast"+6'}}
    gear.herc_body_phlx  = {name="Herculean Vest", augments={'Phalanx +5'}}
    gear.herc_hands_phlx = {name="Herculean Gloves", augments={'Phalanx +5'}}
    gear.herc_legs_phlx  = {name="Herculean Trousers", augments={'Phalanx +4'}}
    gear.herc_feet_phlx  = {name="Herculean Boots", augments={'Phalanx +5'}}

    info.keybinds = make_keybind_list(job_keybinds())
    info.keybinds:bind()

    info.ws_binds = make_keybind_list(T{
        ['Sword']=L{
            'bind !^1|%1 input /ws Wildfire',
            'bind !^2|%2 input /ws "Leaden Salute"',
            'bind !^3 input /ws "Last Stand"',
            'bind !^4 input /ws "Hot Shot"',
            'bind !^5 input /ws "Sniper Shot"',
            'bind %3 input /ws "Savage Blade"',
            'bind %4 input /ws Requiescat',
            'bind %5 input /ws "Shining Blade"',
            'bind %6 input /ws "Circle Blade"',
            'bind ~!^1|~%1 input /ws Wildfire <stnpc>',
            'bind ~!^2|~%2 input /ws "Leaden Salute" <stnpc>',
            'bind ~!^3 input /ws "Last Stand" <stnpc>',
            'bind ~!^4 input /ws "Hot Shot" <stnpc>',
            'bind ~!^5 input /ws "Sniper Shot" <stnpc>',
            'bind ~%3 input /ws "Savage Blade" <stnpc>',
            'bind ~%4 input /ws Requiescat <stnpc>',
            'bind ~%5 input /ws "Shining Blade" <stnpc>',
            'bind ~%6 input /ws "Circle Blade" <stnpc>',
            'bind !^d input /ws "Flat Blade"'},
        ['Dagger']=L{
            'bind !^1|%1 input /ws Wildfire',
            'bind !^2|%2 input /ws "Leaden Salute"',
            'bind !^3 input /ws "Last Stand"',
            'bind !^4 input /ws "Hot Shot"',
            'bind !^5 input /ws "Sniper Shot"',
            'bind %3 input /ws Evisceration',
            'bind %4 input /ws Exenterator',
            'bind %5 input /ws "Wasp Sting"',
            'bind %6 input /ws "Aeolian Edge"',
            'bind %7 input /ws Cyclone',
            'bind ~!^1|~%1 input /ws Wildfire <stnpc>',
            'bind ~!^2|~%2 input /ws "Leaden Salute" <stnpc>',
            'bind ~!^3 input /ws "Last Stand" <stnpc>',
            'bind ~!^4 input /ws "Hot Shot" <stnpc>',
            'bind ~!^5 input /ws "Sniper Shot" <stnpc>',
            'bind ~%3 input /ws Evisceration <stnpc>',
            'bind ~%4 input /ws Exenterator <stnpc>',
            'bind ~%5 input /ws "Wasp Sting" <stnpc>',
            'bind ~%6 input /ws "Aeolian Edge" <stnpc>',
            'bind ~%7 input /ws Cyclone <stnpc>',
            'bind !^d input /ws Shadowstitch'}},
        {['Naeg1h']='Sword',['NaegDW']='Sword',['NaegTaur']='Sword',
         ['Taur1h']='Dagger',['TaurDW']='Dagger',['TaurNaeg']='Dagger',
         ['Gleti1h']='Dagger',['GletiRA']='Dagger',
         ['RosA1h']='Dagger',['RosARA']='Dagger',['RosATaur']='Dagger',
         ['RosC1h']='Dagger',['RosCRA']='Dagger',['RosCTaur']='Dagger'})
    info.ws_binds:bind(state.MeleeWeapon)
    send_command('bind %\\\\ gs c ListWS')

    info.roll_binds = make_keybind_list(L{
        'bind @`   input /ja "Bolter\'s Roll" <me>',
        'bind ^1   input /ja Double-Up <me>',
        'bind ^2   input /ja "Hunter\'s Roll" <me>',
        'bind ^3   input /ja "Chaos Roll" <me>',
        'bind ^4   input /ja "Samurai Roll" <me>',
        'bind ^5   input /ja "Tactician\'s Roll" <me>',
        'bind ^6   input /ja "Courser\'s Roll" <me>',
        'bind ^@1  input /ja "Naturalist\'s Roll" <me>',
        'bind ^@2  input /ja "Warlock\'s Roll" <me>',
        'bind ^@3  input /ja "Wizard\'s Roll" <me>',
        'bind ^@4  input /ja "Caster\'s Roll" <me>',
        'bind ^@5  input /ja "Evoker\'s Roll" <me>',
        'bind ~^1  input /ja "Corsair\'s Roll" <me>',
        'bind ~^2  input /ja "Rogue\'s Roll" <me>',
        'bind ~^3  input /ja "Fighter\'s Roll" <me>',
        'bind ~^4  input /ja "Allies\' Roll" <me>',
        'bind ~^5  input /ja "Dancer\'s Roll" <me>',
        'bind ~^@1 input /ja "Magus\'s Roll" <me>',
        'bind ~^@2 input /ja "Runeist\'s Roll" <me>',
        'bind ~^@3 input /ja "Gallant\'s Roll" <me>',
        'bind ~^@4 input /ja "Monk\'s Roll" <me>'})
    info.roll_binds:bind()
    send_command('bind @backspace gs c ListRolls')

    info.recast_ids = L{{name='Random Deal',id=196}}
    if     player.sub_job == 'WAR' then
        info.recast_ids:extend(L{{name='Provoke',id=5},{name='Warcry',id=2}})
    elseif player.sub_job == 'DRG' then
        info.recast_ids:extend(L{{name='High Jump',id=159},{name='Super Jump',id=160}})
    end

    --select_default_macro_book()
end

-- Called when this job file is unloaded (eg: job change)
function user_unload()
    info.keybinds:unbind()

    info.ws_binds:unbind()
    send_command('unbind %\\\\')

    info.roll_binds:unbind()
    send_command('unbind @backspace')

    destroy_state_text()
end

-- Define sets and vars used by this job file.
function init_gear_sets()

    sets.weapons = {}
    sets.weapons.Naeg1h   = {main="Naegling",sub="Nusku Shield"}
    sets.weapons.Taur1h   = {main="Tauret",sub="Nusku Shield"}
    sets.weapons.Gleti1h  = {main="Gleti's Knife",sub="Nusku Shield"}
    sets.weapons.RosA1h   = {main=gear.RostamA,sub="Nusku Shield"}
    sets.weapons.RosC1h   = {main=gear.RostamC,sub="Nusku Shield"}
    sets.weapons.NaegDW   = {main="Naegling",sub="Demersal Degen +1"}
    sets.weapons.NaegTaur = {main="Naegling",sub="Tauret"}
    sets.weapons.RosARA   = {main=gear.RostamA,sub="Kustawi +1"}
    sets.weapons.RosATaur = {main=gear.RostamA,sub="Tauret"}
    sets.weapons.RosCRA   = {main=gear.RostamC,sub="Kustawi +1"}
    sets.weapons.RosCTaur = {main=gear.RostamC,sub="Tauret"}
    sets.weapons.TaurDW   = {main="Tauret",sub="Demersal Degen +1"}
    sets.weapons.TaurNaeg = {main="Tauret",sub="Naegling"}
    sets.weapons.GletiRA  = {main="Gleti's Knife",sub="Kustawi +1"}
    sets.weapons.Fomal = {range="Fomalhaut"}
    sets.weapons.Arma  = {range="Armageddon"}
    sets.weapons.DPen  = {range="Death Penalty"}
    sets.weapons.TP    = {range="Ataktos"}

    sets.TreasureHunter = {head="Volte Cap",waist="Chaac Belt",legs=gear.herc_legs_th}

    -- Precast Sets
    sets.precast.JA['Snake Eye'] = {legs="Lanun Trews"}
    sets.precast.JA['Wild Card'] = {feet="Lanun Bottes +3"}
    sets.precast.JA['Random Deal'] = {body="Lanun Frac +3"}
    sets.precast.FoldDoubleBust = {hands="Lanun Gants +3"}

    sets.precast.CorsairRoll = {main=gear.RostamC,sub="Nusku Shield",range="Compensator",
        head="Lanun Tricorne",neck="Regal Necklace",ear1="Beyla Earring",ear2="Chasseur's Earring +1",
        body="Chasseur's Frac +2",hands="Chasseur's Gants +2",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.RATPCape,waist="Platinum Moogle Belt",legs="Desultor Tassets",feet="Oshosi Leggings +1"}
    sets.precast.CorsairRoll["Caster's Roll"] = set_combine(sets.precast.CorsairRoll, {legs="Chasseur's Culottes +2"})
    sets.precast.CorsairRoll["Courser's Roll"] = set_combine(sets.precast.CorsairRoll, {feet="Chasseur's Bottes +2"})
    sets.precast.CorsairRoll["Blitzer's Roll"] = set_combine(sets.precast.CorsairRoll, {head="Chasseur's Tricorne +2"})
    sets.precast.CorsairRoll["Tactician's Roll"] = set_combine(sets.precast.CorsairRoll, {body="Chasseur's Frac +2"})
    sets.precast.CorsairRoll["Allies' Roll"] = set_combine(sets.precast.CorsairRoll, {hands="Chasseur's Gants +2"})
    sets.precast.JA['Double-Up'] = {main=gear.RostamC,
        head="Null Masque",neck="Warder's Charm +1",ear1="Beyla Earring",ear2="Chasseur's Earring +1",
        body=gear.adh_body_ta,hands="Nyame Gauntlets",ring1="Lebeche Ring",ring2="Defending Ring",
        back=gear.RATPCape,waist="Platinum Moogle Belt",legs="Laksamana's Trews +3",feet="Oshosi Leggings +1"}
    sets.luzaf_ring = {ring1="Luzaf's Ring"}
    sets.precast.CorsairShot = {range="Death Penalty",ammo="Living Bullet"}

    sets.precast.FC = {head=gear.herc_head_fc,neck="Orunmila's Torque",ear1="Etiolation Earring",ear2="Loquacious Earring",
        body=gear.adh_body_fc,hands="Leyline Gloves",ring1="Lebeche Ring",ring2="Kishar Ring",
        back=gear.FastCape,legs=gear.herc_legs_fc,feet="Carmine Greaves +1"}
    sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {neck="Magoraga Bead Necklace"})

    sets.precast.WS = {ammo="Chrono Bullet",
        head="Nyame Helm",neck="Fotia Gorget",ear1="Telos Earring",ear2="Moonshade Earring",
        body="Nyame Mail",hands="Nyame Gauntlets",ring1="Epaminondas's Ring",ring2="Ephramad's Ring",
        back=gear.MEWSCape,waist="Fotia Belt",legs="Nyame Flanchard",feet="Nyame Sollerets"}

    sets.precast.WS['Marksmanship'] = {ammo="Chrono Bullet",
        head="Nyame Helm",neck="Fotia Gorget",ear1="Telos Earring",ear2="Crepuscular Earring",
        body="Laksamana's Frac +3",hands="Nyame Gauntlets",ring1="Dingir Ring",ring2="Ephramad's Ring",
        back=gear.RAWSCape,waist="Fotia Belt",legs="Nyame Flanchard",feet="Nyame Sollerets"}
    sets.precast.WS['Marksmanship'].Acc = {ammo="Devastating Bullet",
        head="Chasseur's Tricorne +2",neck="Iskur Gorget",ear1="Beyla Earring",ear2="Crepuscular Earring",
        body="Laksamana's Frac +3",hands="Malignance Gloves",ring1="Regal Ring",ring2="Ephramad's Ring",
        back=gear.RAWSCape,waist="Kwahu Kachina Belt +1",legs="Laksamana's Trews +3",feet="Chasseur's Bottes +2"}
    sets.precast.WS['Last Stand'] = set_combine(sets.precast.WS['Marksmanship'], {body="Ikenga's Vest",ear2="Moonshade Earring"})
    sets.precast.WS['Last Stand'].Acc = set_combine(sets.precast.WS['Last Stand'], {neck="Null Loop",ear1="Beyla Earring",
        body="Laksamana's Frac +3",hands="Chasseur's Gants +2",ring1="Regal Ring",waist="Null Belt"})
    sets.precast.WS['Last Stand'].Enmity = {ammo="Chrono Bullet",
        head="Nyame Helm",neck="Fotia Gorget",ear1="Beyla Earring",ear2="Chasseur's Earring +1",
        body="Ikenga's Vest",hands="Ikenga's Gloves",ring1="Dingir Ring",ring2="Ephramad's Ring",
        back=gear.RAWSCape,waist="Fotia Belt",legs="Nyame Flanchard",feet="Oshosi Leggings +1"}
    sets.precast.WS['Sniper Shot'] = set_combine(sets.precast.WS['Marksmanship'].Acc, {})

    sets.precast.WS['Wildfire'] = {ammo="Living Bullet",
        head="Nyame Helm",neck="Baetyl Pendant",ear1="Friomisi Earring",ear2="Hecate's Earring",
        body="Lanun Frac +3",hands="Nyame Gauntlets",ring1="Dingir Ring",ring2="Epaminondas's Ring",
        back=gear.MAWSCape,waist="Eschan Stone",legs="Nyame Flanchard",feet="Lanun Bottes +3"}
    --sets.precast.WS['Wildfire'].NoDmg = set_combine(sets.naked, {ammo="Bronze Bullet"})
    sets.precast.WS['Leaden Salute'] = set_combine(sets.precast.WS['Wildfire'], {
        head="Pixie Hairpin +1",ear2="Moonshade Earring",ring1="Archon Ring"})
    sets.precast.WS['Leaden Salute'].Acc = set_combine(sets.precast.WS['Leaden Salute'], {
        head="Nyame Helm",neck="Null Loop",ear1="Crepuscular Earring",waist="Null Belt"})
    sets.precast.WS['Leaden Salute'].Enmity = set_combine(sets.precast.WS['Leaden Salute'], {ear1="Moonshade Earring",ear2="Chasseur's Earring +1"})
    sets.precast.WS['Sanguine Blade'] = set_combine(sets.precast.WS['Leaden Salute'], {ear2="Hecate's Earring"})
    sets.precast.WS['Aeolian Edge'] = set_combine(sets.precast.WS['Wildfire'], {ear2="Moonshade Earring"})
    sets.precast.WS['Cyclone'] = sets.precast.WS['Aeolian Edge']
    sets.precast.WS['Shining Blade'] = sets.precast.WS['Aeolian Edge']
    sets.precast.WS['Seraph Blade'] = sets.precast.WS['Aeolian Edge']
    sets.precast.WS['Red Lotus Blade'] = sets.precast.WS['Aeolian Edge']
    sets.precast.WS['Burning Blade'] = sets.precast.WS['Aeolian Edge']
    sets.orpheus   = {waist="Orpheus's Sash"}
    sets.ele_obi   = {waist="Hachirin-no-Obi"}
    sets.nuke_belt = {waist="Eschan Stone"}

    sets.precast.WS['Hot Shot'] = {ammo="Living Bullet",
        head="Nyame Helm",neck="Fotia Gorget",ear1="Friomisi Earring",ear2="Moonshade Earring",
        body="Nyame Mail",hands="Nyame Gauntlets",ring1="Dingir Ring",ring2="Epaminondas's Ring",
        back=gear.MAWSCape,waist="Fotia Belt",legs="Nyame Flanchard",feet="Lanun Bottes +3"}
    sets.precast.WS['Hot Shot'].Acc = set_combine(sets.precast.WS['Hot Shot'], {
        ear1="Telos Earring",back=gear.RAWSCape,feet="Nyame Sollerets"})

    sets.precast.WS['Savage Blade'] = {
        head="Nyame Helm",neck="Republican Platinum Medal",ear1="Ishvara Earring",ear2="Moonshade Earring",
        body="Nyame Mail",hands="Nyame Gauntlets",ring1="Epaminondas's Ring",ring2="Ephramad's Ring",
        back=gear.MEWSCape,waist="Sailfi Belt +1",legs="Nyame Flanchard",feet="Nyame Sollerets"}
    sets.precast.WS['Savage Blade'].Acc = set_combine(sets.precast.WS['Savage Blade'], {
        neck="Null Loop",ear1="Telos Earring",waist="Null Belt"})
    sets.precast.WS['Requiescat'] = {
        head="Nyame Helm",neck="Fotia Gorget",ear1="Telos Earring",ear2="Crepuscular Earring",
        body="Nyame Mail",hands="Nyame Gauntlets",ring1="Epona's Ring",ring2="Ephramad's Ring",
        back=gear.METPCape,waist="Fotia Belt",legs="Nyame Flanchard",feet="Nyame Sollerets"}
    sets.precast.WS['Evisceration'] = {
        head="Adhemar Bonnet +1",neck="Fotia Gorget",ear1="Odr Earring",ear2="Chasseur's Earring +1",
        body="Mummu Jacket +2",hands="Mummu Wrists +2",ring1="Epona's Ring",ring2="Ephramad's Ring",
        back=gear.METPCape,waist="Fotia Belt",legs="Mummu Kecks +2",feet="Oshosi Leggings +1"}
    sets.precast.WS['Exenterator'] = {
        head="Malignance Chapeau",neck="Fotia Gorget",ear1="Telos Earring",ear2="Crepuscular Earring",
        body=gear.adh_body_ta,hands="Malignance Gloves",ring1="Epona's Ring",ring2="Ephramad's Ring",
        back=gear.METPCape,waist="Fotia Belt",legs="Malignance Tights",feet="Malignance Boots"}
    sets.precast.WS['Swift Blade'] = set_combine(sets.precast.WS['Requiescat'], {})
    sets.precast.WS['Flat Blade'] = {ammo="Devastating Bullet",
        head="Malignance Chapeau",neck="Null Loop",ear1="Telos Earring",ear2="Dignitary's Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Epona's Ring",ring2="Ephramad's Ring",
        back="Null Shawl",waist="Null Belt",legs="Malignance Tights",feet="Malignance Boots"}
    sets.precast.WS['Shadowstitch'] = set_combine(sets.precast.WS['Flat Blade'], {})

    sets.precast.RA = {ammo="Chrono Bullet",
        head=gear.taeon_head_snap,body="Oshosi Vest",hands="Carmine Finger Gauntlets +1",ring2="Crepuscular Ring",
        back=gear.SnapCape,waist="Yemaya Belt",legs="Adhemar Kecks +1",feet=gear.taeon_feet_snap}
    sets.precast.RA.Flurry = set_combine(sets.precast.RA, {head="Chasseur's Tricorne +2",body="Laksamana's Frac +3"})
    sets.chrono_bullet = {ammo="Chrono Bullet"}
    sets.devast_bullet = {ammo="Devastating Bullet"}
    sets.living_bullet = {ammo="Living Bullet"}

    sets.precast.Waltz = {head="Mummu Bonnet +2"}
    sets.precast.Step = {
        head="Malignance Chapeau",neck="Null Loop",ear1="Odr Earring",ear2="Chasseur's Earring +1",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Etana Ring",ring2="Ephramad's Ring",
        back="Null Shawl",waist="Null Belt",legs="Malignance Tights",feet="Malignance Boots"}
    sets.precast.JA['Violent Flourish'] = {
        head="Malignance Chapeau",neck="Null Loop",ear1="Telos Earring",ear2="Dignitary's Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Etana Ring",ring2="Ephramad's Ring",
        back="Null Shawl",waist="Null Belt",legs="Malignance Tights",feet="Malignance Boots"}

    -- Midcast Sets
    sets.midcast.Cure = {main="Chatoyant Staff",sub="Bloodrain Strap",neck="Incanter's Torque",ear1="Mendicant's Earring",ear2="Chasseur's Earring +1"}
    sets.midcast.Curaga = set_combine(sets.midcast.Cure, {})
    sets.midcast.Cursna = {neck="Debilis Medallion",ring1="Haoma's Ring",ring2="Haoma's Ring",waist="Cornelia's Belt"}
    sets.gishdubar = {waist="Gishdubar Sash"}
    sets.midcast['Enfeebling Magic'] = {main=gear.RostamC,range="Fomalhaut",ammo="Devastating Bullet",
        head="Chasseur's Tricorne +2",neck="Null Loop",ear1="Crepuscular Earring",ear2="Chasseur's Earring +1",
        body="Chasseur's Frac +2",hands="Chasseur's Gants +2",ring1=gear.Lstikini,ring2=gear.Rstikini,
        back="Null Shawl",waist="Null Belt",legs="Chasseur's Culottes +2",feet="Chasseur's Bottes +2"}
    sets.midcast.Repose = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast['Dark Magic'] = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast['Enhancing Magic'] = {neck="Incanter's Torque",ear1="Andoaa Earring",ear2="Mimir Earring",
        ring1=gear.Lstikini,ring2=gear.Rstikini,waist="Olympus Sash"}
    sets.phlx = {head=gear.taeon_head_phlx,
        body=gear.herc_body_phlx,hands=gear.herc_hands_phlx,legs=gear.herc_legs_phlx,feet=gear.herc_feet_phlx}
    sets.midcast.Phalanx = set_combine(sets.midcast['Enhancing Magic'], sets.phlx)

    sets.midcast.CorsairShot = {main="Naegling",sub="Tauret",range="Death Penalty",ammo="Hauksbok Bullet",
        head="Blood Mask",neck="Baetyl Pendant",ear1="Friomisi Earring",ear2="Hecate's Earring",
        body="Lanun Frac +3",hands="Carmine Finger Gauntlets +1",ring1="Dingir Ring",ring2="Metamorph Ring +1",
        back="Null Shawl",waist="Eschan Stone",legs=gear.herc_legs_ma,feet="Chasseur's Bottes +2"}
    sets.midcast.CorsairShot.STP = {ammo="Living Bullet",
        head="Blood Mask",neck="Iskur Gorget",ear1="Telos Earring",ear2="Crepuscular Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Chirich Ring +1",ring2="Crepuscular Ring",
        back=gear.RATPCape,waist="Yemaya Belt",legs="Chasseur's Culottes +2",feet="Chasseur's Bottes +2"}
    sets.midcast.CorsairShot.Acc = set_combine(sets.midcast.CorsairShot, {ammo="Living Bullet",
        head="Chasseur's Tricorne +2",neck="Null Loop",ear1="Crepuscular Earring",ear2="Dignitary's Earring",
        hands="Chasseur's Gants +2",ring2="Stikini Ring +1",waist="Null Belt"})
    sets.midcast.CorsairShot['Light Shot'] = set_combine(sets.midcast.CorsairShot.Acc, {ammo="Devastating Bullet",
        head="Blood Mask",neck="Null Loop",body="Chasseur's Frac +2",legs="Malignance Tights"})
    sets.midcast.CorsairShot['Dark Shot'] = set_combine(sets.midcast.CorsairShot['Light Shot'], {})
    sets.midcast.CorsairShot['Light Shot'].Acc = set_combine(sets.midcast.CorsairShot['Light Shot'], {head="Chasseur's Tricorne +2"})
    sets.midcast.CorsairShot['Dark Shot'].Acc = set_combine(sets.midcast.CorsairShot['Light Shot'].Acc, {})

    sets.midcast.RA = {ammo="Chrono Bullet",
        head="Ikenga's Hat",neck="Iskur Gorget",ear1="Telos Earring",ear2="Crepuscular Earring",
        body="Ikenga's Vest",hands="Malignance Gloves",ring1="Ilabrat Ring",ring2="Crepuscular Ring",
        back=gear.RATPCape,waist="Yemaya Belt",legs="Adhemar Kecks +1",feet="Ikenga's Clogs"}
    sets.midcast.RA.Acc = {ammo="Chrono Bullet",
        head="Malignance Chapeau",neck="Iskur Gorget",ear1="Telos Earring",ear2="Crepuscular Earring",
        body="Ikenga's Vest",hands="Malignance Gloves",ring1="Ilabrat Ring",ring2="Ephramad's Ring",
        back=gear.RATPCape,waist="Null Belt",legs="Adhemar Kecks +1",feet="Malignance Boots"}
    sets.midcast.RA.HighAcc = set_combine(sets.midcast.RA.Acc, {ammo="Devastating Bullet",
        neck="Null Loop",ear1="Beyla Earring",legs="Malignance Tights"})
    sets.midcast.RA.Crit = {ammo="Chrono Bullet",
        head="Meghanada Visor +2",neck="Iskur Gorget",ear1="Odr Earring",ear2="Chasseur's Earring +1",
        body="Meghanada Cuirie +2",hands="Chasseur's Gants +2",ring1="Ilabrat Ring",ring2="Ephramad's Ring",
        back=gear.RACRCape,waist="Kwahu Kachina Belt +1",legs="Darraigner's Brais",feet="Oshosi Leggings +1"}
    sets.midcast.RA.CritAcc = set_combine(sets.midcast.RA.Crit, {body="Nisroch Jerkin",legs="Mummu Kecks +2"})
    sets.midcast.RA.Recycle = set_combine(sets.midcast.RA, {
        ear2="Chasseur's Earring +1",body="Laksamana's Frac +3",ring1="Dingir Ring",legs="Adhemar Kecks +1"})
    sets.midcast.RA.Enmity = set_combine(sets.midcast.RA, {ear1="Beyla Earring",ear2="Chasseur's Earring +1",feet="Oshosi Leggings +1"})

    sets.midcast.RA.TripleShot = set_combine(sets.midcast.RA, {
        head="Oshosi Mask +1",body="Chasseur's Frac +2",hands="Lanun Gants +3",legs="Oshosi Trousers +1",feet="Oshosi Leggings +1"})
    sets.midcast.RA.TripleShot.Acc = set_combine(sets.midcast.RA.TripleShot, {ring2="Ephramad's Ring"})
    sets.midcast.RA.TripleShot.HighAcc = set_combine(sets.midcast.RA.TripleShot.Acc, {ammo="Devastating Bullet",ear1="Beyla Earring"})
    sets.midcast.RA.TripleShot.Crit = set_combine(sets.midcast.RA.Crit, {body="Chasseur's Frac +2",legs="Oshosi Trousers +1",feet="Oshosi Leggings +1"})
    sets.midcast.RA.TripleShot.CritAcc = set_combine(sets.midcast.RA.TripleShot.Crit, {hands="Chasseur's Gants +2"})
    sets.midcast.RA.TripleShot.Recycle = set_combine(sets.midcast.RA.TripleShot, {
        ear2="Chasseur's Earring +1",ring1="Dingir Ring",legs="Adhemar Kecks +1"})
    sets.midcast.RA.TripleShot.Enmity = set_combine(sets.midcast.RA.TripleShot, {
        ear1="Beyla Earring",ear2="Chasseur's Earring +1",ring1="Lebeche Ring"})

    -- Sets to return to when not performing an action.

    sets.idle = {main=gear.RostamC,sub="Nusku Shield",range="Death Penalty",ammo="Living Bullet",
        head="Null Masque",neck="Warder's Charm +1",ear1="Infused Earring",ear2="Eabani Earring",
        body="Malignance Tabard",hands="Nyame Gauntlets",ring1="Shadow Ring",ring2="Defending Ring",
        back=gear.RATPCape,waist="Null Belt",legs="Carmine Cuisses +1",feet="Nyame Sollerets"}
    sets.idle.Rf = set_combine(sets.idle, {
        neck="Sibyl Scarf",ear1="Genmei Earring",
        body="Mekosuchinae Harness",hands=gear.herc_hands_rf,ring1=gear.Lstikini,ring2=gear.Rstikini,
        legs=gear.herc_legs_rf})
    sets.buff.doom = {neck="Nicander's Necklace",ring1="Eshmun's Ring",waist="Gishdubar Sash"}

    sets.defense.PDT = set_combine(sets.idle, {})
    sets.defense.MDT = set_combine(sets.idle, {legs="Malignance Tights"})
    sets.Kiting = {legs="Carmine Cuisses +1"}

    -- Normal melee group
    sets.engaged = {ammo="Living Bullet",
        head="Adhemar Bonnet +1",neck="Null Loop",ear1="Telos Earring",ear2="Brutal Earring",
        body=gear.adh_body_ta,hands="Adhemar Wristbands +1",ring1="Epona's Ring",ring2="Hetairoi Ring",
        back=gear.METPCape,waist="Windbuffet Belt +1",legs="Samnuha Tights",feet=gear.herc_feet_ta}
    sets.engaged.EXP = set_combine(sets.engaged, {head="Malignance Chapeau",
        body="Malignance Tabard",hands="Malignance Gloves",legs="Malignance Tights",feet="Malignance Boots"})
    sets.engaged.Acc = {ammo="Living Bullet",
        head="Malignance Chapeau",neck="Null Loop",ear1="Telos Earring",ear2="Dignitary's Earring",
        body=gear.adh_body_ta,hands="Adhemar Wristbands +1",ring1="Epona's Ring",ring2="Ephramad's Ring",
        back=gear.METPCape,waist="Null Belt",legs="Malignance Tights",feet="Malignance Boots"}
    --sets.engaged.Crit = set_combine(sets.engaged, {head="Mummu Bonnet +2", -- for mamool ambu
    --    body="Mummu Jacket +2",hands="Mummu Wrists +2",waist="Reiki Yotai",legs="Mummu Kecks +2"})

    sets.engaged.PDef = {ammo="Living Bullet",
        head="Malignance Chapeau",neck="Null Loop",ear1="Telos Earring",ear2="Brutal Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Epona's Ring",ring2="Defending Ring",
        back=gear.METPCape,waist="Windbuffet Belt +1",legs="Malignance Tights",feet="Malignance Boots"}
    sets.engaged.EXP.PDef = set_combine(sets.engaged.PDef, {})
    sets.engaged.Acc.PDef = set_combine(sets.engaged.PDef, {})

    sets.engaged.NIN = set_combine(sets.engaged, {waist="Reiki Yotai"})
    sets.engaged.EXP.NIN = set_combine(sets.engaged.EXP, {back=gear.DWCape})
    sets.engaged.Acc.NIN = set_combine(sets.engaged.Acc, {ear2="Eabani Earring"})
    sets.engaged.PDef.NIN = set_combine(sets.engaged.PDef, {back=gear.DWCape})
    sets.engaged.EXP.PDef.NIN = set_combine(sets.engaged.PDef.NIN, {})
    sets.engaged.Acc.PDef.NIN = set_combine(sets.engaged.PDef.NIN, {})

    sets.engaged.DNC = set_combine(sets.engaged, {back=gear.DWCape,ear2="Eabani Earring"})
    sets.engaged.EXP.DNC = set_combine(sets.engaged.EXP, {back=gear.DWCape,ear2="Eabani Earring",waist="Reiki Yotai"})
    sets.engaged.Acc.DNC = set_combine(sets.engaged.Acc, {back=gear.DWCape,ear2="Eabani Earring"})
    sets.engaged.PDef.DNC = set_combine(sets.engaged.PDef, {back=gear.DWCape,ear2="Eabani Earring",waist="Reiki Yotai"})
    sets.engaged.EXP.PDef.DNC = set_combine(sets.engaged.PDef.DNC, {})
    sets.engaged.Acc.PDef.DNC = set_combine(sets.engaged.PDef.DNC, {})

    sets.engaged.DW30 = {ammo="Living Bullet",
        head="Malignance Chapeau",neck="Null Loop",ear1="Suppanomimi",ear2="Eabani Earring",
        body=gear.adh_body_ta,hands="Malignance Gloves",ring1="Epona's Ring",ring2="Ephramad's Ring",
        back=gear.DWCape,waist="Reiki Yotai",legs="Malignance Tights",feet="Malignance Boots"}
    sets.engaged.DW30.PDef = set_combine(sets.engaged.DW30, {body="Malignance Tabard",ring2="Defending Ring"})

    -- Sets that depend upon idle sets
    sets.midcast['Dia II']  = set_combine(sets.idle, sets.TreasureHunter)
    sets.midcast.FastRecast = set_combine(sets.idle, {legs="Malignance Tights"})
    sets.midcast.Utsusemi   = set_combine(sets.idle, {legs="Malignance Tights"})
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.
function job_precast(spell, action, spellMap, eventArgs)
    -- show reminder for  lucky/unlucky numbers
    if spell.type == 'CorsairRoll' then
        display_roll_info(spell)
    elseif not state.DUEnmity.value and spell.english == 'Double-Up' then
        eventArgs.handled = true
    elseif spell.type == 'CorsairShot' then
        classes.CustomClass = state.CastingMode.value
    elseif spell.english == 'Fold' and buffactive['Bust'] == 2 then
        if sets.precast.FoldDoubleBust then
            equip(sets.precast.FoldDoubleBust)
            eventArgs.handled = true
        end
    elseif spell.action_type == 'Ranged Attack' and buffactive.Flurry then
        -- Use an alternate snapshot set with flurry up.
        equip(sets.precast.RA.Flurry)
        eventArgs.handled = true
    end
end

-- Run after the general precast() is done.
function job_post_precast(spell, action, spellMap, eventArgs)
    if (spell.type == 'CorsairRoll' or spell.english == "Double-Up") and state.LuzafRing.value then
        equip(sets.luzaf_ring)
    elseif spell.type == 'WeaponSkill' then
        if info.magic_ws:contains(spell.english) then equip(resolve_ele_belt(spell, sets.ele_obi, sets.nuke_belt, 2.5)) end
        if buffactive['elvorseal'] and player.inventory["Heidrek Boots"] then equip({feet="Heidrek Boots"}) end
    elseif spell.action_type == 'Ranged Attack' then
        -- preshot and midshot ammo must match
        if state.RangedMode.value == 'HighAcc' then
            equip(sets.devast_bullet)
        end
    end
end

-- Run after the default midcast() is done.
-- eventArgs is the same one used in job_midcast, in case information needs to be persisted.
function job_post_midcast(spell, action, spellMap, eventArgs)
    if spell.type == 'CorsairShot' then
        if state.CastingMode.value ~= 'STP' then
            equip(resolve_ele_belt(spell, sets.ele_obi, sets.nuke_belt, 2.5))
        end
    elseif state.Buff['Triple Shot'] and spell.action_type == 'Ranged Attack' then
        equip(sets.midcast.RA.TripleShot[state.RangedMode.value] or sets.midcast.RA.TripleShot)
    elseif spell.type == 'WhiteMagic' and spell.target.type == 'SELF' then
        if S{'Cure','Refresh'}:contains(spellMap) then
            equip(sets.gishdubar)
        elseif spell.english == 'Cursna' then
            equip(sets.buff.doom)
        end
    end
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_aftercast(spell, action, spellMap, eventArgs)
    if spell.interrupted then
        --send_command('wait 0.5;gs c update')
        interrupted_message(spell)
    else
        if spell.type == 'CorsairShot' then
            if spell.english == 'Light Shot' then
                debuff_timer(spell, 60)
            --elseif spell.english ~= 'Dark Shot' and state.CastingMode.value ~= 'STP' then
            elseif player.tp >= 1000 then
                -- avoid aftercast swaps to not clobber rapid corsairshot -> ws
                eventArgs.handled = true
                add_to_chat(104, 'manual aftercast')
            end
        elseif spell.type == 'CorsairRoll' and buffactive[spell.english] then
            if not state.DUEnmity.value and player.tp >= 1000 then
                -- avoid aftercast swaps to not clobber rapid double-up -> ws
                eventArgs.handled = true
                add_to_chat(104, 'manual aftercast')
            end
        elseif spell.type == 'JobAbility' then
            if not sets.precast.JA[spell.english] then
                eventArgs.handled = true
            end
        elseif spell.type == 'WeaponSkill' then
            if state.WSMsg.value then
                send_command('input /p '..spell.english)
            end
        end
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for non-casting events.
-------------------------------------------------------------------------------------------------------------------

-- Called when the player's status changes.
function job_status_change(newStatus, oldStatus, eventArgs)
    if newStatus == 'Engaged' or oldStatus == 'Engaged' then
        -- Don't swap gear mid song if the engaged target dies
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
        if state.NoFlurry.value and lbuff == 'flurry' then
            add_to_chat(123, 'cancelling flurry')
            send_command('cancel flurry')
        end
        if buffactive.Stoneskin and lbuff == 'sleep' then
            add_to_chat(123, 'cancelling stoneskin')
            send_command('cancel stoneskin')
        end
        if info.chat_notice_buffs:contains(lbuff) then
            add_to_chat(104, 'Gained ['..buff..']')
        end
    end
end

-- Handle notifications of general user state change.
function job_state_change(stateField, newValue, oldValue)
    if S{'Offense Mode','Melee Weapon','Ranged Weapon'}:contains(stateField) then
        enable('main','sub','range')
        if state.OffenseMode.value ~= 'None' then
            -- try to handle exchanging mainhand and offhand weapons gracefully
            local new_melee = sets.weapons[state.MeleeWeapon.value]
            if player.equipment.sub == new_melee.main then
                equip({main=empty,sub=empty})
                add_to_chat(123, 'unequipped weapons')
            elseif player.equipment.main == new_melee.sub then
                equip({main=new_melee.main,sub=empty})
                add_to_chat(123, 'unequipped offhand')
            else
                equip(new_melee)
            end
            equip(sets.weapons[state.RangedWeapon.value])
            disable('main','sub','range')
            state.CastingMode:set('STP')
        else
            state.CastingMode:set('Normal')
        end
        if stateField == 'Melee Weapon' then
            info.ws_binds:bind(state.MeleeWeapon)
        elseif stateField == 'Offense Mode' then
            handle_equipping_gear(player.status)
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

-- Modify the default idle set after it was constructed.
function customize_idle_set(idleSet)
    if state.Buff.doom then
        idleSet = set_combine(idleSet, sets.buff.doom)
    end
    return idleSet
end

-- Modify the default melee set after it was constructed.
function customize_melee_set(meleeSet)
    if buffactive['elvorseal'] and state.DefenseMode.value == 'None' then
        if player.inventory["Heidrek Gloves"] then meleeSet = set_combine(meleeSet, {hands="Heidrek Gloves"}) end
        if player.inventory["Heidrek Harness"] then meleeSet = set_combine(meleeSet, {body="Heidrek Harness"}) end
    end
    if state.Buff.doom then
        meleeSet = set_combine(meleeSet, sets.buff.doom)
    end
    return meleeSet
end

-- Called by the 'update' self-command.
-- Set eventArgs.handled to true if we don't want automatic equipping of gear.
function job_update(cmdParams, eventArgs)
    if state.th_gear_is_locked and cmdParams[1] == 'user' and player.status ~= 'Engaged' then
        unlock_TH()
    end
end

-- Set eventArgs.handled to true if we don't want the automatic display to be run.
function display_current_job_state(eventArgs)
    local msg = ''

    msg = msg .. 'TP[' .. state.OffenseMode.current
    if state.HybridMode.value ~= 'Normal' then
        msg = msg .. '/' .. state.HybridMode.value
    end
    msg = msg .. ':' .. state.MeleeWeapon.value
    msg = msg .. '+' .. state.RangedWeapon.value
    if state.CombatForm.has_value then
        msg = msg .. '/' .. state.CombatForm.value
    end
    msg = msg .. ' RA[' .. state.RangedMode.current .. ']'
    msg = msg .. ' WS[' .. state.WeaponskillMode.current .. ']'
    msg = msg .. ' QD[' .. state.CastingMode.current .. ']'
    msg = msg .. ' Idle[' .. state.IdleMode.current .. ']'

    if state.DefenseMode.value ~= 'None' then
        local defMode = state[state.DefenseMode.value ..'DefenseMode'].current
        msg = msg .. ' Def[' .. state.DefenseMode.value .. ':' .. defMode .. ']'
    end
    if state.TreasureMode and state.TreasureMode.value ~= 'None' then
        msg = msg .. ' TH+4'
    end
    if state.WSMsg.value then
        msg = msg .. ' WSMsg'
    end
    if state.LuzafRing.value then
        msg = msg .. ' Luzaf'
    end
    if state.NoFlurry.value then
        msg = msg .. ' NoFlurry'
    end
    if state.Kiting.value then
        msg = msg .. ' Kiting'
    end

    add_to_chat(122, msg)
    report_ammo_and_tools()
    report_ja_recasts(info.recast_ids, true)

    eventArgs.handled = true
end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements self-commands.
-------------------------------------------------------------------------------------------------------------------

-- Called for custom player commands.
function job_self_command(cmdParams, eventArgs)
    eventArgs.handled = true
    if     cmdParams[1] == 'ListRolls' then
        info.roll_binds:print('ListRolls:')
    elseif cmdParams[1] == 'ListWS' then
        info.ws_binds:print('ListWS:')
    elseif cmdParams[1] == 'weap' then
        weap_self_command(cmdParams, 'MeleeWeapon')
    elseif cmdParams[1] == 'save' then
        save_self_command(cmdParams)
    elseif cmdParams[1] == 'rebind' then
        info.keybinds:bind()
    --elseif cmdParams[1] == 'mamools' then
    --    state.OffenseMode:set('Crit')
    --    state.WeaponskillMode:set('NoDmg')
    --    state.MeleeWeapon:set('TaurDW')
    --    job_state_change('MeleeWeapon', 'TaurDW', state.MeleeWeapon.value)
    --    state.LuzafRing:set()
    --    add_to_chat(122, 'Mammols mode set.')
    else
        eventArgs.handled = false
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------

function define_roll_values()
    rolls = {
        ["Corsair's Roll"]   = {lucky=5, unlucky=9, bonus="Experience Points"},
        ["Ninja Roll"]       = {lucky=4, unlucky=8, bonus="Evasion"},
        ["Hunter's Roll"]    = {lucky=4, unlucky=8, bonus="Accuracy"},
        ["Chaos Roll"]       = {lucky=4, unlucky=8, bonus="Attack"},
        ["Magus's Roll"]     = {lucky=2, unlucky=6, bonus="Magic Defense"},
        ["Healer's Roll"]    = {lucky=3, unlucky=7, bonus="Cure Potency Received"},
        ["Drachen Roll"]     = {lucky=3, unlucky=7, bonus="Pet Accuracy"},
        ["Choral Roll"]      = {lucky=2, unlucky=6, bonus="Spell Interruption Rate"},
        ["Monk's Roll"]      = {lucky=3, unlucky=7, bonus="Subtle Blow"},
        ["Beast Roll"]       = {lucky=4, unlucky=8, bonus="Pet Attack"},
        ["Samurai Roll"]     = {lucky=2, unlucky=6, bonus="Store TP"},
        ["Evoker's Roll"]    = {lucky=5, unlucky=9, bonus="Refresh"},
        ["Rogue's Roll"]     = {lucky=5, unlucky=9, bonus="Critical Hit Rate"},
        ["Warlock's Roll"]   = {lucky=4, unlucky=8, bonus="Magic Accuracy"},
        ["Fighter's Roll"]   = {lucky=5, unlucky=9, bonus="Double Attack Rate"},
        ["Puppet Roll"]      = {lucky=4, unlucky=8, bonus="Pet Magic Accuracy/Attack"},
        ["Gallant's Roll"]   = {lucky=3, unlucky=7, bonus="Defense"},
        ["Wizard's Roll"]    = {lucky=5, unlucky=9, bonus="Magic Attack"},
        ["Dancer's Roll"]    = {lucky=3, unlucky=7, bonus="Regen"},
        ["Scholar's Roll"]   = {lucky=2, unlucky=6, bonus="Conserve MP"},
        ["Naturalist's Roll"]= {lucky=3, unlucky=7, bonus="Enhancing Duration"},
        ["Runeist's Roll"]   = {lucky=4, unlucky=8, bonus="Magic Evasion"},
        ["Bolter's Roll"]    = {lucky=3, unlucky=9, bonus="Movement Speed"},
        ["Caster's Roll"]    = {lucky=2, unlucky=7, bonus="Fast Cast"},
        ["Courser's Roll"]   = {lucky=3, unlucky=9, bonus="Snapshot"},
        ["Blitzer's Roll"]   = {lucky=4, unlucky=9, bonus="Attack Delay"},
        ["Tactician's Roll"] = {lucky=5, unlucky=8, bonus="Regain"},
        ["Allies' Roll"]     = {lucky=3, unlucky=10, bonus="Skillchain Damage"},
        ["Miser's Roll"]     = {lucky=5, unlucky=7, bonus="Save TP"},
        ["Companion's Roll"] = {lucky=2, unlucky=10, bonus="Pet Regain and Regen"},
        ["Avenger's Roll"]   = {lucky=4, unlucky=8, bonus="Counter Rate"},
    }
end

function display_roll_info(spell)
    local rollinfo = rolls[spell.english]
    if rollinfo then
        add_to_chat(104, spell.english..': Lucky '..tostring(rollinfo.lucky)..', Unlucky '..tostring(rollinfo.unlucky)..'.')
    end
end

-- Select default macro book on initial load or subjob change.
--function select_default_macro_book()
--    set_macro_page(1,7)
--end

-- returns a list for use with make_keybind_list
function job_keybinds()
    local bind_command_list = L{
        'bind !^l input /lockstyleset 5',
        'bind %`   gs c update user',
        'bind F9   gs c cycle OffenseMode',
        'bind @F9  gs c cycle WeaponskillMode',
        'bind !F9  gs c cycle RangedMode',
        'bind F10  gs c cycle CastingMode',
        'bind !F10 gs c reset CastingMode',
        'bind F11  gs c cycle IdleMode',
        'bind !F11 gs c reset IdleMode',
        'bind @F11 gs c toggle Kiting',
        'bind !F12 gs c cycle TreasureMode',
        'bind  !^q gs c weap Taur',
        'bind ~!^q gs c weap Taur Naeg',
        'bind  ^@q gs c weap Gleti',
        'bind ~^@q gs c weap Gleti DW',
        'bind  !^w gs c weap Naeg',
        'bind ~!^w gs c weap Naeg Taur',
        'bind  !^e gs c weap RosA',
        'bind ~!^e gs c weap RosA Taur',
        'bind  !^r gs c weap RosC',
        'bind ~!^r gs c weap RosC Taur',
        'bind !0 gs c set RangedWeapon Fomal',
        'bind !- gs c set RangedWeapon Arma',
        'bind != gs c set RangedWeapon DPen',
        'bind !7 gs c set CombatForm DW30',
        'bind !8 gs c reset CombatForm',
        'bind !backspace gs c set RangedWeapon TP',
        'bind ^space gs c cycle HybridMode',
        'bind ^@space gs c reset HybridMode',
        'bind !space gs c set DefenseMode Physical',
        'bind @space gs c set DefenseMode Magical',
        'bind !@space gs c reset DefenseMode',

        'bind ^`    input /ja "Crooked Cards" <me>',
        'bind ^@`   input /ja "Random Deal" <me>',
        'bind ^@tab input /ja Fold <me>',
        'bind !^`   input /ja "Wild Card" <me>',
        'bind ^tab  input /ja "Snake Eye" <me>',
        'bind @tab  input /ja "Dark Shot"',
        'bind !@`   input /ja "Cutting Cards" <t>',

        'bind !1 input /ra <t>',
        'bind @1 input /ra <stnpc>',
        'bind !2 input /ja "Light Shot" <t>',
        'bind @2 input /ja "Light Shot" <stnpc>',
        'bind !3 input /ja "Triple Shot" <me>',

        'bind @g gs equip phlx',

        'bind !@1 input /ja "Fire Shot"',
        'bind !@2 input /ja "Ice Shot"',
        'bind !@3 input /ja "Wind Shot"',
        'bind !@4 input /ja "Earth Shot"',
        'bind !@5 input /ja "Thunder Shot"',
        'bind !@6 input /ja "Water Shot"',

        'bind  @w  gs c set OffenseMode EXP',
        'bind  !w  gs c set OffenseMode Normal',
        'bind !@w  gs c set OffenseMode None',
        'bind  ^c  gs c set CastingMode Acc',
        'bind ~^c  gs c set CastingMode STP',
        'bind ~!^c gs c set CastingMode Normal',
        'bind  !c  gs c set OffenseMode Acc',
        'bind  ^z  gs c set RangedMode Acc',
        'bind ~^z  gs c set RangedMode HighAcc',
        'bind  @z  gs c set RangedMode Crit',
        'bind !@z  gs c set RangedMode CritAcc',
        'bind ^@z  gs c set RangedMode Normal',
        'bind ~!^z  gs c set RangedMode Enmity',
        'bind ~^@z  gs c set RangedMode Recycle',
        'bind  @x  gs c set WeaponskillMode Acc',
        'bind !@x  gs c set WeaponskillMode Normal',
        'bind ~!@x  gs c set WeaponskillMode Enmity',

        'bind  !z  gs c toggle LuzafRing',
        'bind ^\\\\ gs c toggle WSMsg',
        'bind @\\\\ gs c toggle DUEnmity'}

    if     player.sub_job == 'WAR' then
        bind_command_list:extend(L{
            'bind !4 input /ja Berserk <me>',
            'bind !5 input /ja Aggressor <me>',
            'bind !6 input /ja Warcry <me>',
            'bind !d input /ja Provoke',
            'bind !e input /ja Defender <me>'})
    elseif player.sub_job == 'DNC' then
        bind_command_list:extend(L{
            'bind !4 input /recast "Curing Waltz III"; input /ja "Curing Waltz III" <stpc>',
            'bind !5 input /recast "Healing Waltz"; input /ja "Healing Waltz" <stpc>',
            'bind @F1 input /ja "Healing Waltz" <stpc>',
            'bind !v input /ja "Spectral Jig" <me>',
            'bind !d input /ja "Violent Flourish"',
            'bind !@d input /ja "Animated Flourish"',
            'bind !f input /ja "Haste Samba" <me>',
            'bind !@f input /ja "Reverse Flourish" <me>',
            'bind !e input /ja "Box Step"',
            'bind !@e input /ja Quickstep'})
    elseif player.sub_job == 'NIN' then
        bind_command_list:extend(L{
            'bind !e input /ma "Utsusemi: Ni" <me>',
            'bind !@e input /ma "Utsusemi: Ichi" <me>',
            'bind ~^x  input /ma "Monomi: Ichi" <me>',
            'bind ~!^x input /ma "Tonko: Ni" <me>'})
    elseif player.sub_job == 'THF' then
        bind_command_list:extend(L{
            'bind !4 input /ma "Sneak Attack" <me>',
            'bind !5 input /ma "Trick Attack" <me>'})
    elseif player.sub_job == 'DRG' then
        bind_command_list:extend(L{
            'bind !4 input /ja "High Jump"',
            'bind !5 input /ja "Super Jump"',
            'bind !6 input /ja "Ancient Circle" <me>'})
    elseif player.sub_job == 'RDM' then
        bind_command_list:extend(L{
            'bind !e input /ma "Cure III"',
            'bind !@e input /ma "Cure IV"',
            'bind !f input /ma Haste',
            'bind !@f input /ma Flurry',
            'bind !g input /ma Phalanx',
            'bind !@g input /ma Stoneskin',
            'bind @c input /ma Blink',
            'bind @v input /ma Aquaveil',
            'bind !b input /ma Refresh'})
    elseif player.sub_job == 'WHM' then
        bind_command_list:extend(L{
            'bind @1 input /ma Poisona',
            'bind @2 input /ma Paralyna',
            'bind @3 input /ma Blindna',
            'bind @4 input /ma Silena',
            'bind @5 input /ma Stona',
            'bind @6 input /ma Viruna',
            'bind @7 input /ma Cursna',
            'bind @F1 input /ma Erase',
            'bind !e input /ma "Cure III"',
            'bind !@e input /ma "Cure IV"',
            'bind !d input /ma Flash',
            'bind !f input /ma Haste',
            'bind !@g input /ma Stoneskin',
            'bind @c input /ma Blink',
            'bind !v input /ma Aquaveil'})
    elseif player.sub_job == 'SMN' then
        bind_command_list:extend(L{
            'bind !v input //mewinglullaby',
            'bind !b input //caitsith',
            'bind !@b input //release',
            'bind !n input //retreat'})
    end

    return bind_command_list
end

-- prints a message with counts of some ammo types
function report_ammo_and_tools()
    local bag_ids = T{['Inventory']=0,['Wardrobe']=8,['Wardrobe 2']=10,['Wardrobe 3']=11,['Wardrobe 4']=12,['Wardrobe 5']=13}
    local item_list = L{{name='chrono',id=21296},{name='devas.',id=21325},{name='living',id=21326},{name='cards',id=2974}}
    if player.sub_job == 'NIN' then item_list:append({name='shihei',id=1179}) end
    local counts = T{}
    for item in item_list:it() do counts[item.id] = 0 end

    for bag in S{'Inventory','Wardrobe','Wardrobe 5'}:it() do
        for _,item in ipairs(windower.ffxi.get_items(bag_ids[bag])) do
            if type(item) == 'table' then
                if counts:containskey(item.id) then
                    counts[item.id] = counts[item.id] + item.count
                end
            end
        end
    end

    add_to_chat(122, item_list:map(function(item) return "%s(%d)":format(item.name,counts[item.id]) end):concat(' '))
end

function init_state_text()
    if hud then return end

    local luzafs_text_settings = {pos={y=0},flags={draggable=false,bold=true},text={stroke={width=2}}}
    local rmode_text_settings  = {pos={y=27},flags={draggable=false,bold=true},bg={red=0,green=220,blue=220,alpha=150},text={stroke={width=2}}}
    local wmode_text_settings  = {pos={y=54},flags={draggable=false,bold=true},bg={red=220,green=0,blue=220,alpha=150},text={stroke={width=2}}}
    local hyb_text_settings    = {pos={x=130,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local def_text_settings    = {pos={x=172,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local off_text_settings    = {pos={x=172,y=697},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local weap_text_settings   = {pos={x=200,y=697},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local dw_text_settings     = {pos={x=130,y=697},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}

    hud = {texts=T{}}
    hud.texts.luzafs_text = texts.new('NoLuzaf',        luzafs_text_settings)
    hud.texts.rmode_text  = texts.new('initializing..', rmode_text_settings)
    hud.texts.wmode_text  = texts.new('initializing..', wmode_text_settings)
    hud.texts.hyb_text    = texts.new('initializing..', hyb_text_settings)
    hud.texts.def_text    = texts.new('initializing..', def_text_settings)
    hud.texts.off_text    = texts.new('initializing..', off_text_settings)
    hud.texts.weap_text   = texts.new('initializing..', weap_text_settings)
    hud.texts.dw_text     = texts.new('initializing..', dw_text_settings)

    -- update infrequently changing text boxes in job_state_change or where they are changed
    function hud_update_on_state_change(stateField)
        if not hud then init_state_text() end

        if not stateField or stateField == 'Luzaf\'s Ring' then
            hud.texts.luzafs_text:visible((not state.LuzafRing.value))
        end

        if not stateField or stateField == 'Ranged Mode' then
            if state.RangedMode.value ~= 'Normal' then
                hud.texts.rmode_text:text(state.RangedMode.value)
                hud.texts.rmode_text:show()
            else hud.texts.rmode_text:hide() end
        end

        if not stateField or stateField == 'Weaponskill Mode' then
            if state.WeaponskillMode.value ~= 'Normal' then
                hud.texts.wmode_text:text(state.WeaponskillMode.value)
                hud.texts.wmode_text:show()
            else hud.texts.wmode_text:hide() end
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

        if not stateField or S{'Offense Mode','Melee Weapon','Ranged Weapon'}:contains(stateField) then
            if state.OffenseMode.value ~= 'None' then
                hud.texts.weap_text:text(state.MeleeWeapon.value..'+'..state.RangedWeapon.value)
                hud.texts.weap_text:show()
            else hud.texts.weap_text:hide() end
        end

        if not stateField or stateField == 'Combat Form' then
            if state.CombatForm.has_value then
                hud.texts.dw_text:text(state.CombatForm.value)
                hud.texts.dw_text:show()
            else hud.texts.dw_text:hide() end
        end
    end
end
