-- Modified from 'https://github.com/Kinematics/GearSwap-Jobs/blob/master/COR.lua'
-- For Luzaf's Ring toggle, hit the keybind !z.
-- TODO enmity toggle for double up
-- TODO recast messages
-- TODO better dual wield sets
-- TODO new TH+4 actions

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

    windower.raw_register_event('logout', destroy_state_text)
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
    state.OffenseMode:options('Normal','MEVA','Acc','None')--,'Crit')        -- Cycle with F9, set with !w, !@w, !c, @c
    state.HybridMode:options('Normal','PDef')                               -- Cycle with ^F9
    state.RangedMode:options('Normal','Acc','HighAcc','Crit')               -- Cycle with !F9
    state.WeaponskillMode:options('Normal','Acc','Enmity')--,'NoDmg')       -- Cycle with @F9
    state.CastingMode:options('STP','Normal','Acc')                         -- Cycle with F10
    state.IdleMode:options('Normal','PDT','Rf')                             -- Cycle with F11
    state.MagicalDefenseMode:options('MEVA')
    state.CombatWeapon = M{['description']='Combat Weapon'}
    if S{'DNC','NIN'}:contains(player.sub_job) then
        state.CombatWeapon:options('NaegBlur','NaegTaur','RosBlur','RosTaur','TaurBlur','Rostam',
                                   'Aeolian','AeolianDP','OmenSword','OmenDagger')
		state.CombatForm:set('DW')
    else
        state.CombatWeapon:options('Rostam','Naegling','Tauret')
		state.CombatForm:reset()
    end
    state.WSMsg = M(false, 'WS Message')                                    -- Toggle with ^\
    state.LuzafRing = M(true, "Luzaf's Ring")                               -- Toggle with !z
    state.NoFlurry = M(false, 'no flurry plz')                              -- anti-koru-moru

    init_state_text()
    hud_update_on_state_change()

    info.magic_ws = S{'Hot Shot','Wildfire','Leaden Salute','Gust Slash','Cyclone','Aeolian Edge',
                      'Burning Blade','Red Lotus Blade','Shining Blade','Seraph Blade','Sanguine Blade'}

    -- Mote-libs handle obis, gorgets, and other elemental things.
    -- These are default fallbacks if situationally appropriate gear is not available.
    gear.default.obi_waist = "Eschan Stone"                 -- used in ws sets
    gear.default.obi_ring = "Metamorph Ring +1"             -- used in qd sets

    -- Augmented items get variables for convenience and specificity
    gear.MAWSCape = {name="Camulus's Mantle",
        augments={'AGI+20','Mag. Acc+20 /Mag. Dmg.+20','AGI+10','Weapon skill damage +10%','Damage taken-5%'}}
    gear.RATPCape = {name="Camulus's Mantle",
        augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','Rng.Acc.+10','"Store TP"+10','Damage taken-5%'}}
    gear.RAWSCape = {name="Camulus's Mantle",
        augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','AGI+10','Weapon skill damage +10%','Damage taken-5%'}}
    gear.METPCape = {name="Camulus's Mantle",
        augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Dbl.Atk."+10','Damage taken-5%'}}
    gear.MEWSCape = {name="Camulus's Mantle",
        augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%','Phys. dmg. taken-10%'}}
    gear.SnapCape = {name="Camulus's Mantle", augments={'"Snapshot"+10'}}
    gear.FastCape = {name="Camulus's Mantle", augments={'"Fast Cast"+10'}}
    gear.Lstikini = {name="Stikini Ring +1", bag="wardrobe2"}
    gear.Rstikini = {name="Stikini Ring +1", bag="wardrobe3"}
    gear.taeon_head_phlx  = {name="Taeon Chapeau", augments={'Phalanx +3'}}
    gear.taeon_body_phlx  = {name="Taeon Tabard", augments={'Spell interruption rate down -10%','Phalanx +3'}}
    gear.taeon_hands_phlx = {name="Taeon Gloves", augments={'Spell interruption rate down -8%','Phalanx +3'}}
    gear.taeon_legs_phlx  = {name="Taeon Tights", augments={'Phalanx +3'}}
    gear.taeon_feet_phlx  = {name="Taeon Boots", augments={'Spell interruption rate down -9%','Phalanx +3'}}
    gear.herc_head_ma   = {name="Herculean Helm",
        augments={'"Mag.Atk.Bns."+23','Mag. Acc.+16','Accuracy+2 Attack+2','Mag. Acc.+12 "Mag.Atk.Bns."+12'}}
    gear.herc_hands_ma  = {name="Herculean Gloves",
        augments={'Mag. Acc.+18 "Mag.Atk.Bns."+18','Magic burst dmg.+3%','Mag. Acc.+12','"Mag.Atk.Bns."+10'}}
    gear.herc_legs_ma   = {name="Herculean Trousers",
        augments={'"Mag.Atk.Bns."+30','Weapon Skill Acc.+5','Accuracy+14 Attack+14','Mag. Acc.+16 "Mag.Atk.Bns."+16'}}
    gear.herc_feet_ma   = {name="Herculean Boots",
        augments={'Mag. Acc.+19 "Mag.Atk.Bns."+19','Enmity-2','MND+4','Mag. Acc.+4','"Mag.Atk.Bns."+15'}}
    gear.herc_head_wsd  = {name="Herculean Helm",
        augments={'"Cure" spellcasting time -10%','Pet: INT+6','Weapon skill damage +9%'}}
    gear.herc_feet_ta   = {name="Herculean Boots", augments={'Rng.Acc.+4','"Triple Atk."+4','Accuracy+14','Attack+12'}}
    gear.herc_head_rf   = {name="Herculean Helm",
        augments={'Accuracy+17','DEX+6','"Refresh"+2','Accuracy+16 Attack+16','Mag. Acc.+20 "Mag.Atk.Bns."+20'}}
    gear.herc_hands_dt  = {name="Herculean Gloves", augments={'Attack+27','Damage taken-4%','DEX+5','Accuracy+9'}}
    gear.herc_legs_th   = {name="Herculean Trousers",
        augments={'Attack+3','"Cure" spellcasting time -2%','"Treasure Hunter"+2','Accuracy+1 Attack+1'}}
    gear.herc_head_fc = {name="Herculean Helm", augments={'"Mag.Atk.Bns."+2','"Fast Cast"+5'}}

    info.keybinds = make_keybind_list(job_keybinds())
    info.keybinds:bind()

    info.ws_binds = make_keybind_list(T{
        ['Sword']=L{
            'bind !^1|%1    input /ws Wildfire',
            'bind !^2|%2    input /ws "Leaden Salute"',
            'bind !^3|%3    input /ws "Last Stand"',
            'bind !^4|%4|!b input /ws "Savage Blade"',
            'bind !^5|%5    input /ws Requiescat',
            'bind !^6|%6    input /ws "Circle Blade"',
            'bind !^d       input /ws "Flat Blade"'},
        ['Dagger']=L{
            'bind !^1|%1 input /ws Wildfire',
            'bind !^2|%2 input /ws "Leaden Salute"',
            'bind !^3|%3 input /ws "Last Stand"',
            'bind !^4|%4 input /ws Evisceration',
            'bind !^5|%5 input /ws Exenterator',
            'bind !^6|%6 input /ws "Aeolian Edge"',
            'bind !^7|%7 input /ws Cyclone',
            'bind !^d    input /ws Shadowstitch'},
        ['OmenSword']=L{
            'bind !^1|%1 input /ws Wildfire',
            'bind !^2|%2 input /ws "Leaden Salute"',
            'bind !^3|%3 input /ws "Burning Blade"',
            'bind !^d|%4 input /ws "Flat Blade"'},
        ['OmenDagger']=L{
            'bind !^1|%1 input /ws Wildfire',
            'bind !^2|%2 input /ws "Leaden Salute"',
            'bind !^3|%3 input /ws "Gust Slash"',
            'bind !^4|%4 input /ws "Wasp Sting"',
            'bind !^d    input /ws Shadowstitch'}},
        {['Naegling']='Sword',['NaegBlur']='Sword',['NaegTaur']='Sword',['JoyMerc']='OmenSword',['MercJoy']='OmenDagger',
         ['Rostam']='Dagger',['RosBlur']='Dagger',['Tauret']='Dagger',['TaurBlur']='Dagger',['Aeolian']='Dagger',['AeolianDP']='Dagger'})
    info.ws_binds:bind(state.CombatWeapon)
    send_command('bind %\\\\ gs c ListWS')

    info.roll_binds = make_keybind_list(L{
        'bind @`   input /ja "Bolter\'s Roll" <me>',
        'bind ^1   input /ja Double-Up <me>',
        'bind ^2   input /ja "Hunter\'s Roll" <me>',
        'bind ^3   input /ja "Chaos Roll" <me>',
        'bind ^4   input /ja "Samurai Roll" <me>',
        'bind ^5   input /ja "Tactician\'s Roll" <me>',
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

    -- TODO recasts

    select_default_macro_book()
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
    sets.weapons.Naegling  = {main="Naegling",sub="Nusku Shield",range="Ataktos"}
    sets.weapons.Tauret    = {main="Tauret",sub="Nusku Shield",range="Death Penalty"}
    sets.weapons.Rostam    = {main="Rostam",sub="Nusku Shield",range="Fomalhaut"}
    sets.weapons.NaegBlur  = {main="Naegling",sub="Blurred Knife +1",range="Ataktos"}
    sets.weapons.NaegTaur  = {main="Naegling",sub="Tauret",range="Death Penalty"}
    sets.weapons.RosBlur   = {main="Rostam",sub="Blurred Knife +1",range="Death Penalty"}
    sets.weapons.RosTaur   = {main="Rostam",sub="Tauret",range="Death Penalty"}
    sets.weapons.Aeolian   = {main="Tauret",sub="Naegling",range="Ataktos"}
    sets.weapons.AeolianDP = {main="Tauret",sub="Naegling",range="Death Penalty"}
    sets.weapons.TaurBlur  = {main="Tauret",sub="Blurred Knife +1",range="Fomalhaut"}
    sets.weapons.JoyMerc   = {main="Joyeuse",sub="Mercurial Kris",range="Fomalhaut"}    -- omen objs
    sets.weapons.MercJoy   = {main="Mercurial Kris",sub="Joyeuse",range="Fomalhaut"}    -- omen objs

    sets.TreasureHunter = {head="Volte Cap",waist="Chaac Belt",legs=gear.herc_legs_th}

    -- Precast Sets
    sets.precast.JA['Snake Eye'] = {legs="Lanun Trews"}
    sets.precast.JA['Wild Card'] = {feet="Lanun Bottes +3"}
    sets.precast.JA['Random Deal'] = {body="Lanun Frac +3"}
    sets.precast.FoldDoubleBust = {hands="Lanun Gants +3"}

    sets.precast.CorsairRoll = {main="Rostam",sub="Nusku Shield",range="Compensator",
        head="Lanun Tricorne",neck="Regal Necklace",ear1="Novia Earring",ear2="Enervating Earring",
        body="Adhemar Jacket +1",hands="Chasseur's Gants +1",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.SnapCape,waist="Flume Belt +1",legs="Desultor Tassets",feet="Oshosi Leggings +1"}
    sets.precast.CorsairRoll["Caster's Roll"] = set_combine(sets.precast.CorsairRoll, {legs="Navarch's Culottes +2"})
    sets.precast.CorsairRoll["Courser's Roll"] = set_combine(sets.precast.CorsairRoll, {feet="Chasseur's Bottes +1"})
    sets.precast.CorsairRoll["Blitzer's Roll"] = set_combine(sets.precast.CorsairRoll, {head="Chasseur's Tricorne"})
    sets.precast.CorsairRoll["Tactician's Roll"] = set_combine(sets.precast.CorsairRoll, {body="Chasseur's Frac +1"})
    sets.precast.CorsairRoll["Allies' Roll"] = set_combine(sets.precast.CorsairRoll, {hands="Chasseur's Gants +1"}) 
    --sets.precast.JA['Double-Up'] = {} -- FIXME -enm and test out with luzafs
    sets.precast.LuzafRing = {ring1="Luzaf's Ring"}
    sets.precast.CorsairShot = {range="Death Penalty",ammo="Living Bullet"}

    sets.precast.FC = {head=gear.herc_head_fc,neck="Orunmila's Torque",ear1="Etiolation Earring",ear2="Loquacious Earring",
        body="Adhemar Jacket",hands="Leyline Gloves",ring2="Kishar Ring",
        back=gear.FastCape,legs="Rawhide Trousers",feet="Carmine Greaves +1"}
    -- fastcast+62%
    sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {neck="Magoraga Bead Necklace"})

    sets.precast.WS = {ammo="Chrono Bullet",  -- assume ranged weaponskills, eg, Last Stand
        head=gear.herc_head_wsd,neck="Fotia Gorget",ear1="Telos Earring",ear2="Moonshade Earring",
        body="Laksamana's Frac +3",hands="Meghanada Gloves +2",ring1="Dingir Ring",ring2="Regal Ring",
        back=gear.RAWSCape,waist="Fotia Belt",legs="Malignance Tights",feet="Lanun Bottes +3"}
    sets.precast.WS.Acc = set_combine(sets.precast.WS, {head="Meghanada Visor +2",neck="Iskur Gorget"})
    sets.precast.WS.Enmity = set_combine(sets.precast.WS, {
        ear1="Novia Earring",ring1="Persis Ring",legs="Laksamana's Trews +3",feet="Oshosi Leggings +1"})
    sets.precast.WS.Enmity.Ambu = set_combine(sets.precast.Enmity, {ear1="Cytherea Pearl"})
    --sets.precast.WS.NoDmg = set_combine(sets.precast.WS, {ammo="Bronze Bullet"})

    sets.precast.WS.Wildfire = {ammo="Living Bullet",
        head=gear.herc_head_ma,neck="Baetyl Pendant",ear1="Friomisi Earring",ear2="Hecate's Earring",
        body="Lanun Frac +3",hands="Carmine Finger Gauntlets +1",ring1="Dingir Ring",ring2="Regal Ring",
        back=gear.MAWSCape,waist=gear.ElementalObi,legs=gear.herc_legs_ma,feet="Lanun Bottes +3"}
    --sets.precast.WS.Wildfire.NoDmg = set_combine(sets.naked, {ammo="Bronze Bullet"})
    sets.precast.WS['Leaden Salute'] = set_combine(sets.precast.WS.Wildfire, {
        head="Pixie Hairpin +1",ear2="Moonshade Earring",ring2="Archon Ring"})
    sets.precast.WS['Leaden Salute'].Acc = set_combine(sets.precast.WS['Leaden Salute'], {
        neck="Sanctity Necklace",ear1="Hermetic Earring",hands=gear.herc_hands_ma,waist="Kwahu Kachina Belt",legs=gear.herc_legs_ma})
    sets.precast.WS['Leaden Salute'].Enmity = set_combine(sets.precast.WS['Leaden Salute'], {
        ear1="Novia Earring",legs="Laksamana's Trews +3"})
    sets.precast.WS['Sanguine Blade'] = set_combine(sets.precast.WS['Leaden Salute'], {ear2="Hecate's Earring"})
    sets.precast.WS['Aeolian Edge'] = set_combine(sets.precast.WS.Wildfire, {ear2="Moonshade Earring"})
    sets.orpheus   = {waist="Orpheus's Sash"}
    sets.ele_obi   = {waist="Hachirin-no-Obi"}
    sets.nuke_belt = {waist="Eschan Stone"}

    sets.precast.WS['Hot Shot'] = {ammo="Living Bullet",
        head=gear.herc_head_wsd,neck="Fotia Gorget",ear1="Friomisi Earring",ear2="Moonshade Earring",
        body="Laksamana's Frac +3",hands="Carmine Finger Gauntlets +1",ring1="Dingir Ring",ring2="Regal Ring",
        back=gear.MAWSCape,waist="Fotia Belt",legs=gear.herc_legs_ma,feet="Lanun Bottes +3"}
    sets.precast.WS['Hot Shot'].Acc = {ammo="Chrono Bullet",
        head="Meghanada Visor +2",neck="Fotia Gorget",ear1="Telos Earring",ear2="Moonshade Earring",
        body="Laksamana's Frac +3",hands="Meghanada Gloves +2",ring1="Dingir Ring",ring2="Regal Ring",
        back=gear.RAWSCape,waist="Fotia Belt",legs="Adhemar Kecks",feet="Meghanada Jambeaux +2"}

    sets.precast.WS['Savage Blade'] = {
        head=gear.herc_head_wsd,neck="Caro Necklace",ear1="Ishvara Earring",ear2="Moonshade Earring",
        body="Laksamana's Frac +3",hands="Meghanada Gloves +2",ring1="Rufescent Ring",ring2="Regal Ring",
        back=gear.MEWSCape,waist="Sailfi Belt +1",legs="Meghanada Chausses +2",feet="Lanun Bottes +3"}
    sets.precast.WS['Savage Blade'].Acc = set_combine(sets.precast.WS['Savage Blade'], {neck="Fotia Gorget",ear1="Telos Earring",
        head="Meghanada Visor +2",body="Meghanada Cuirie +2"})
    sets.precast.WS.Requiescat = {
        head="Meghanada Visor +2",neck="Fotia Gorget",ear1="Telos Earring",ear2="Dignitary's Earring",
        body="Meghanada Cuirie +2",hands="Meghanada Gloves +2",ring1="Epona's Ring",ring2="Regal Ring",
        back=gear.METPCape,waist="Fotia Belt",legs="Meghanada Chausses +2",feet="Meghanada Jambeaux +2"}
    sets.precast.WS.Evisceration = {
        head="Adhemar Bonnet +1",neck="Fotia Gorget",ear1="Telos Earring",ear2="Odr Earring",
        body="Mummu Jacket +2",hands="Mummu Wrists +2",ring1="Epona's Ring",ring2="Ilabrat Ring",
        back=gear.METPCape,waist="Fotia Belt",legs="Mummu Kecks +2",feet="Oshosi Leggings +1"}
    sets.precast.WS.Exenterator    = set_combine(sets.precast.WS.Requiescat, {})
    sets.precast.WS['Swift Blade'] = set_combine(sets.precast.WS.Requiescat, {})
    sets.precast.WS['Flat Blade'] = {ammo="Living Bullet",
        head="Malignance Chapeau",neck="Sanctity Necklace",ear1="Telos Earring",ear2="Dignitary's Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Stikini Ring +1",ring2="Etana Ring",
        back=gear.METPCape,waist="Eschan Stone",legs="Malignance Tights",feet="Malignance Boots"}
    sets.precast.WS.Shadowstitch = set_combine(sets.precast.WS['Flat Blade'], {})

    sets.precast.RA = {ammo="Chrono Bullet",
        head="Taeon Chapeau",body="Oshosi Vest",hands="Carmine Finger Gauntlets +1",
        back=gear.SnapCape,waist="Yemaya Belt",legs="Laksamana's Trews +3",feet="Meghanada Jambeaux +2"}
    -- +62% snapshot (+10% base), +16 rapid shot
    sets.precast.RA.Flurry = set_combine(sets.precast.RA, {body="Laksamana's Frac +3"})
    -- +50% snapshot (+10% base), +36 rapid shot

    sets.precast.Waltz = {head="Mummu Bonnet +2"}
    sets.precast.Step = {
        head="Malignance Chapeau",neck="Combatant's Torque",ear1="Telos Earring",ear2="Odr Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Cacoethic Ring +1",ring2="Etana Ring",
        back=gear.METPCape,waist="Grunfeld Rope",legs="Malignance Tights",feet="Malignance Boots"}
    sets.precast.JA['Violent Flourish'] = {
        head="Malignance Chapeau",neck="Sanctity Necklace",ear1="Telos Earring",ear2="Dignitary's Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Cacoethic Ring +1",ring2="Etana Ring",
        back=gear.METPCape,waist="Eschan Stone",legs="Malignance Tights",feet="Malignance Boots"}

    -- Midcast Sets
    sets.midcast.Cure = {main="Chatoyant Staff",sub="Niobid Strap",neck="Incanter's Torque",ear1="Novia Earring",ear2="Mendicant's Earring"}
    sets.midcast.Curaga = set_combine(sets.midcast.Cure, {})
    sets.midcast.Cursna = {neck="Debilis Medallion",ring1="Haoma's Ring",ring2="Haoma's Ring",waist="Kasiri Belt"}
    sets.gishdubar = {waist="Gishdubar Sash"}
    sets.midcast['Enfeebling Magic'] = {main="Naegling",range="Fomalhaut",ammo="Living Bullet",
        head="Malignance Chapeau",neck="Sanctity Necklace",ear1="Gwati Earring",ear2="Dignitary's Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1=gear.Lstikini,ring2=gear.Rstikini,
        back=gear.MAWSCape,waist="Kwahu Kachina Belt",legs="Malignance Tights",feet="Malignance Boots"}
    sets.midcast.Repose = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast['Enhancing Magic'] = {neck="Incanter's Torque",ear1="Andoaa Earring",ear2="Mimir Earring",
        ring1=gear.Lstikini,ring2=gear.Rstikini,waist="Olympus Sash"}
    sets.phlx = {head=gear.taeon_head_phlx,
        body=gear.taeon_body_phlx,hands=gear.taeon_hands_phlx,legs=gear.taeon_legs_phlx,feet=gear.taeon_feet_phlx}
    sets.midcast.Phalanx = set_combine(sets.midcast['Enhancing Magic'], sets.phlx)

    sets.midcast.CorsairShot = {main="Naegling",range="Death Penalty",ammo="Living Bullet",
        head=gear.herc_head_ma,neck="Baetyl Pendant",ear1="Friomisi Earring",ear2="Hecate's Earring",
        body="Lanun Frac +3",hands="Carmine Finger Gauntlets +1",ring1="Dingir Ring",ring2=gear.ElementalRing,
        back=gear.MAWSCape,waist=gear.ElementalObi,legs=gear.herc_legs_ma,feet="Chasseur's Bottes +1"}
    sets.midcast.CorsairShot.STP = {ammo="Living Bullet",
        head="Blood Mask",neck="Iskur Gorget",ear1="Telos Earring",ear2="Dedition Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Petrov Ring",ring2="Ilabrat Ring",
        back=gear.RATPCape,waist="Kasiri Belt",legs="Malignance Tights",feet="Chasseur's Bottes +1"}
    sets.midcast.CorsairShot.Acc = set_combine(sets.midcast.CorsairShot, {
        head="Malignance Chapeau",neck="Sanctity Necklace",ear1="Gwati Earring",ear2="Dignitary's Earring",
        ring2="Stikini Ring +1",waist="Kwahu Kachina Belt"})
    sets.midcast.CorsairShot['Light Shot'] = set_combine(sets.midcast.CorsairShot.Acc, {
        head="Blood Mask",neck="Combatant's Torque",body="Malignance Tabard",hands="Malignance Gloves",legs="Malignance Tights"})
    sets.midcast.CorsairShot['Dark Shot'] = set_combine(sets.midcast.CorsairShot['Light Shot'], {})
    sets.midcast.CorsairShot['Light Shot'].Acc = set_combine(sets.midcast.CorsairShot['Light Shot'], {head="Malignance Chapeau"})
    sets.midcast.CorsairShot['Dark Shot'].Acc = set_combine(sets.midcast.CorsairShot['Light Shot'].Acc, {})

    sets.midcast.RA = {ammo="Chrono Bullet",
        head="Malignance Chapeau",neck="Iskur Gorget",ear1="Telos Earring",ear2="Enervating Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Dingir Ring",ring2="Ilabrat Ring",
        back=gear.RATPCape,waist="Yemaya Belt",legs="Adhemar Kecks",feet="Malignance Boots"}
    sets.midcast.RA.Acc = set_combine(sets.midcast.RA, {ring1="Cacoethic Ring +1",legs="Malignance Tights"})
    sets.midcast.RA.HighAcc = set_combine(sets.midcast.RA.Acc, {})
    sets.midcast.RA.Crit = set_combine(sets.midcast.RA, {
        head="Meghanada Visor +2",ear2="Odr Earring",body="Nisroch Jerkin",hands="Mummu Wrists +2",
        waist="Kwahu Kachina Belt",legs="Mummu Kecks +2",feet="Oshosi Leggings +1"})
    sets.midcast.RA.Enmity = set_combine(sets.midcast.RA, {ear1="Novia Earring",
        body="Adhemar Jacket +1",ring1="Persis Ring",waist="Reiki Yotai",legs="Laksamana's Trews +3",feet="Oshosi Leggings +1"})
    sets.midcast.RA.TripleShot = set_combine(sets.midcast.RA, {
        body="Chasseur's Frac +1",hands="Lanun Gants +3",legs="Oshosi Trousers",feet="Oshosi Leggings +1"})
    sets.midcast.RA.TripleShot.Acc = set_combine(sets.midcast.RA.Acc, {
        body="Oshosi Vest",hands="Lanun Gants +3",ring1="Cacoethic Ring +1",feet="Oshosi Leggings +1"})
    sets.midcast.RA.TripleShot.HighAcc = set_combine(sets.midcast.RA.HighAcc, {
        hands="Lanun Gants +3",legs="Malignance Tights",feet="Oshosi Leggings +1"})
    sets.midcast.RA.TripleShot.Crit = set_combine(sets.midcast.RA.Crit, {
        hands="Lanun Gants +3",legs="Oshosi Trousers",feet="Oshosi Leggings +1"})

    -- Sets to return to when not performing an action.

    sets.idle = {main="Naegling",sub="Nusku Shield",range="Death Penalty",
        head="Malignance Chapeau",neck="Warder's Charm +1",ear1="Novia Earring",ear2="Eabani Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.RATPCape,waist="Flume Belt +1",legs="Carmine Cuisses +1",feet="Malignance Boots"}
    -- pdt-50, mdt-50, meva+624
    sets.idle.PDT = set_combine(sets.idle, {legs="Malignance Tights"})
    sets.idle.MEVA = set_combine(sets.idle.PDT, {})
    sets.idle.Rf = set_combine(sets.idle, {
        head=gear.herc_head_rf,ear1="Genmei Earring",
        body="Mekosuchinae Harness",ring1=gear.Lstikini,ring2=gear.Rstikini,
        legs="Rawhide Trousers"})
    sets.buff.doom = {neck="Nicander's Necklace",ring1="Eshmun's Ring",waist="Gishdubar Sash"}

    sets.defense.PDT = set_combine(sets.idle.PDT, {})
    sets.defense.MEVA = set_combine(sets.idle.MEVA, {})
    sets.Kiting = {legs="Carmine Cuisses +1"}

    -- Normal melee group
    sets.engaged = {
        head="Adhemar Bonnet +1",neck="Combatant's Torque",ear1="Telos Earring",ear2="Brutal Earring",
        body="Adhemar Jacket +1",hands="Adhemar Wristbands +1",ring1="Epona's Ring",ring2="Hetairoi Ring",
        back=gear.METPCape,waist="Reiki Yotai",legs="Samnuha Tights",feet=gear.herc_feet_ta}
    sets.engaged.MEVA = set_combine(sets.engaged, {head="Malignance Chapeau",ear2="Eabani Earring",
        body="Malignance Tabard",hands="Malignance Gloves",legs="Malignance Tights",feet="Malignance Boots"})
    sets.engaged.Acc = set_combine(sets.engaged, {
        head="Malignance Chapeau",ear2="Dignitary's Earring",ring2="Ilabrat Ring",legs="Malignance Tights"})
    --sets.engaged.Crit = set_combine(sets.engaged, {head="Mummu Bonnet +2", -- for mamool ambu
    --    body="Mummu Jacket +2",hands="Mummu Wrists +2",waist="Reiki Yotai",legs="Mummu Kecks +2"})

    sets.engaged.PDef = set_combine(sets.engaged, {
        head="Malignance Chapeau",ear2="Eabani Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring2="Defending Ring",
        legs="Malignance Tights",feet="Malignance Boots"})
    sets.engaged.MEVA.PDef = set_combine(sets.engaged.PDef, {})
    sets.engaged.Acc.PDef = set_combine(sets.engaged.PDef, {})

    -- Sets that depend upon idle sets
    sets.midcast['Dia II']  = set_combine(sets.idle, sets.TreasureHunter)
    sets.midcast.FastRecast = set_combine(sets.idle.PDT, {hands="Leyline Gloves"})
    sets.midcast.Utsusemi   = set_combine(sets.idle.PDT, {})
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
    end

    if spell.type == 'CorsairShot' then
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
        equip(sets.precast.LuzafRing)
    elseif spell.type == 'WeaponSkill' then
        if info.magic_ws:contains(spell.english) then equip(resolve_ele_belt(spell, sets.ele_obi, sets.nuke_belt, 2.5)) end
        if buffactive['elvorseal'] and player.inventory["Heidrek Boots"] then equip({feet="Heidrek Boots"}) end
        if S{'Maquette Abdhaljs-Legion'}:contains(world.area)
        and state.WeaponskillMode.value == 'Enmity' then
            -- FIXME arent there two ambu zones now?
            equip(sets.precast.WS.Enmity.Ambu)
        end
    end
end

-- Run after the default midcast() is done.
-- eventArgs is the same one used in job_midcast, in case information needs to be persisted.
function job_post_midcast(spell, action, spellMap, eventArgs)
    if spell.type == 'CorsairShot' then
        equip(resolve_ele_belt(spell, sets.ele_obi, sets.nuke_belt, 2.5))
        if state.CastingMode.value == 'TH' then
            state.CastingMode:reset()
        end
    elseif state.Buff['Triple Shot'] and spell.action_type == 'Ranged Attack' then 
        if     state.RangedMode.value == 'Normal'  then equip(sets.midcast.RA.TripleShot)
        elseif state.RangedMode.value == 'Acc'     then equip(sets.midcast.RA.TripleShot.Acc)
        elseif state.RangedMode.value == 'HighAcc' then equip(sets.midcast.RA.TripleShot.HighAcc)
        elseif state.RangedMode.value == 'Crit'    then equip(sets.midcast.RA.TripleShot.Crit)
        end
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
        send_command('wait 0.5;gs c update')
        interrupted_message(spell)
    else
        if spell.type == 'CorsairShot' then
            if spell.english == 'Light Shot' then
                send_command('@timers c "'..spell.english..' ['..spell.target.name..']" 60 down spells/00220.png')
            elseif spell.english ~= 'Dark Shot' and state.CastingMode.value ~= 'STP' then
                eventArgs.handled = true
            end
        elseif spell.type == 'JobAbility' then
            if not sets.precast.JA[spell.english] then
                eventArgs.handled = true
            end
        elseif spell.type == 'WeaponSkill' then
            if state.WSMsg.value then
                send_command('@input /p '..spell.english)
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
    if state.DefenseMode.value == 'None' and S{'stun','terror','petrification'}:contains(buff:lower()) then
        if gain then
            equip(sets.idle.PDT)
        elseif not midaction() then
            handle_equipping_gear(player.status)
        end
    elseif buff:lower() == 'doom' and not midaction() then
        handle_equipping_gear(player.status)
    end
    if gain and state.NoFlurry.value and buff:lower() == 'flurry' then
        send_command('cancel flurry')
    end
end

-- Handle notifications of general user state change.
function job_state_change(stateField, newValue, oldValue)
    if stateField == 'Offense Mode' then
        enable('main','sub','range')
        if newValue ~= 'None' then
            equip(sets.weapons[state.CombatWeapon.value])
            disable('main','sub','range')
            if sets.weapons[state.CombatWeapon.value].range == 'Death Penalty' then
                state.CastingMode:set('Normal')
            else
                state.CastingMode:set('STP')
            end
        else
            state.CastingMode:set('Normal')
        end
        handle_equipping_gear(player.status)
    elseif stateField == 'Combat Weapon' then
        info.ws_binds:bind(state.CombatWeapon)
        enable('main','sub','range')
        if state.OffenseMode.value ~= 'None' then
            equip(sets.weapons[newValue])
            disable('main','sub','range')
            if sets.weapons[state.CombatWeapon.value].range == 'Death Penalty' then
                state.CastingMode:set('Normal')
            else
                state.CastingMode:set('STP')
            end
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
    if has_any_buff_of(S{'petrification','sleep','stun','terror'}) then
        idleSet = set_combine(sets.defense.PDT, {})
    end
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
    if has_any_buff_of(S{'petrification','sleep','stun','terror'}) then
        meleeSet = set_combine(sets.defense.PDT, {})
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
    msg = msg .. ':' .. state.CombatWeapon.value
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
        weap_self_command(cmdParams, 'CombatWeapon')
    elseif cmdParams[1] == 'save' then
        save_self_command(cmdParams)
    elseif cmdParams[1] == 'rebind' then
        info.keybinds:bind()
    --elseif cmdParams[1] == 'mamools' then
    --    state.OffenseMode:set('Crit')
    --    state.WeaponskillMode:set('NoDmg')
    --    state.MeleeWeapon:set('TaurBlur')
    --    job_state_change('MeleeWeapon', 'TaurBlur', state.MeleeWeapon.value)
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
function select_default_macro_book()
    set_macro_page(1,7)
    send_command('bind !^l input /lockstyleset 7')
end

-- returns a list for use with make_keybind_list
function job_keybinds()
    local bind_command_list = L{
        'bind %`|F12 gs c update user',
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
        'bind ~!^q gs c weap Aeolian',
        'bind  !^w gs c weap Rostam',
        'bind ~!^w gs c weap Ros Taur',
        'bind  !^e gs c weap Naeg',
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
        'bind !8 gs equip phlx',

        'bind !@1 input /ja "Fire Shot"',
        'bind !@2 input /ja "Ice Shot"',
        'bind !@3 input /ja "Wind Shot"',
        'bind !@4 input /ja "Earth Shot"',
        'bind !@5 input /ja "Thunder Shot"',
        'bind !@6 input /ja "Water Shot"',

        'bind !z gs c toggle LuzafRing',
        'bind !c  gs c set OffenseMode Acc',
        'bind @c  gs c set OffenseMode MEVA',
        'bind !w  gs c set OffenseMode Normal',
        'bind !@w gs c set OffenseMode None',
        'bind ^\\\\ gs c toggle WSMsg'}

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
            'bind !@e input /ma "Utsusemi: Ichi" <me>'})
    elseif player.sub_job == 'THF' then
        bind_command_list:extend(L{
            'bind !4 input /ma "Sneak Attack" <me>',
            'bind !5 input /ma "Trick Attack" <me>'})
    elseif player.sub_job == 'DRG' then
        bind_command_list:extend(L{
            'bind !4 input /ja "High Jump"',
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
            'bind !v input /ma Aquaveil',
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
    local bag_ids = T{['Inventory']=0,['Wardrobe']=8,['Wardrobe 2']=10,['Wardrobe 3']=11,['Wardrobe 4']=12}
    local item_list = L{{name='chrono',id=21296},{name='living',id=21326},{name='cards',id=2974}}
    if player.sub_job == 'NIN' then item_list:append({name='shihei',id=1179}) end
    local counts = T{}
    for item in item_list:it() do counts[item.id] = 0 end

    for bag in S{'Inventory'}:it() do
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

    local luzafs_text_settings = {pos={y=0},flags={draggable=false},bg={alpha=150}}
    local hyb_text_settings    = {pos={x=130,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local def_text_settings    = {pos={x=172,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local off_text_settings    = {pos={x=172,y=697},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}

    hud = {texts=T{}}
    hud.texts.luzafs_text = texts.new('NoLuzaf',        luzafs_text_settings)
    hud.texts.hyb_text    = texts.new('initializing..', hyb_text_settings)
    hud.texts.def_text    = texts.new('initializing..', def_text_settings)
    hud.texts.off_text    = texts.new('initializing..', off_text_settings)

    -- update infrequently changing text boxes in job_state_change or where they are changed
    function hud_update_on_state_change(stateField)
        if not hud then init_state_text() end

        if not stateField or stateField == 'Luzaf\'s Ring' then
            hud.texts.luzafs_text:visible((not state.LuzafRing.value))
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
    end
end
