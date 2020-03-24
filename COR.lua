-- Modified from 'https://github.com/Kinematics/GearSwap-Jobs/blob/master/COR.lua'
-- For Luzaf's Ring toggle, hit the keybind !z.
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

    -- auto translates (defines at_stuff())
    include('at-stuff.lua')

    -- ws properties (sets info.ws_props)
    include('ws-props.lua')
end

-- Setup vars that are user-independent.  state.Buff vars initialized here will automatically be tracked.
function job_setup()
    enable('main','sub','range','ammo','head','neck','ear1','ear2','body','hands','ring1','ring2','back','waist','legs','feet')
    state.Buff.doom = buffactive.doom or false
    state.LuzafRing = M(true, "Luzaf's Ring")

    state.Buff['Triple Shot'] = buffactive['Triple Shot'] or false

    include('Mote-TreasureHunter')
    state.texts_event_id = nil
    state.aeonic_aftermath_precast = false
    define_roll_values()
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
    state.MeleeWeapon = M{['description']='Melee Weapon'}                   -- Set with ^-, ^@-, !@-, ^=
    state.RangedWeapon = M{['description']='Ranged Weapon'}                 -- Set with !-, !=, !backspace
    state.MeleeWeapon:options('Naegling','Rostam','NaegBlur','NaegTaur','RosBlur','RosTaur','Aeolian','TaurBlur')--,'JoyMerc','MercJoy')
    state.RangedWeapon:options('Fomalhaut','DeathPen','Ataktos')
    state.WSMsg = M(false, 'WS Message')                                    -- Toggle with ^\
    state.NoFlurry = M(false, 'no flurry plz')

    gear.RAbullet = "Chrono Bullet"
    gear.WSbullet = "Chrono Bullet"
    gear.MAbullet = "Living Bullet"
    gear.QDbullet = "Living Bullet"
    state.FullTP = 2250

    init_state_text()

    -- Mote-libs handle obis, gorgets, and other elemental things.
    -- These are default fallbacks if situationally appropriate gear is not available.
    gear.default.weaponskill_neck = "Combatant's Torque"    -- used in sets.precast.WS and friends
    gear.default.weaponskill_waist = "Windbuffet Belt +1"   -- used in sets.precast.WS and friends
    gear.default.obi_waist = "Eschan Stone"                 -- used in ws sets
    gear.default.obi_ring = "Acumen Ring"                   -- used in qd sets

    -- Augmented items get variables for convenience and specificity
    gear.MAWSCape = {name="Camulus's Mantle", augments={'AGI+20','Mag. Acc+20 /Mag. Dmg.+20','AGI+10','Weapon skill damage +10%','Damage taken-5%'}}
    gear.RATPCape = {name="Camulus's Mantle", augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','Rng.Acc.+10','"Store TP"+10','Damage taken-5%'}}
    gear.RAWSCape = {name="Camulus's Mantle", augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','AGI+10','Weapon skill damage +10%','Damage taken-5%'}}
    gear.METPCape = {name="Camulus's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Dbl.Atk."+10','Damage taken-5%'}}
    gear.MEWSCape = {name="Camulus's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%','Phys. dmg. taken-10%'}}
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
    gear.herc_legs_macc = {name="Herculean Trousers",
        augments={'Mag. Acc.+20 "Mag.Atk.Bns."+20','"Fast Cast"+2','INT+8','Mag. Acc.+11','"Mag.Atk.Bns."+14'}}
    gear.herc_feet_ma   = {name="Herculean Boots",
        augments={'Mag. Acc.+19 "Mag.Atk.Bns."+19','Enmity-2','MND+4','Mag. Acc.+4','"Mag.Atk.Bns."+15'}}
    gear.herc_head_wsd  = {name="Herculean Helm",
        augments={'"Cure" spellcasting time -10%','Pet: INT+6','Weapon skill damage +9%'}}
    gear.herc_hands_ta  = {name="Herculean Gloves", augments={'Accuracy+24 Attack+24','"Triple Atk."+2','AGI+4','Accuracy+13','Attack+14'}}
    gear.herc_feet_ta   = {name="Herculean Boots", augments={'Rng.Acc.+4','"Triple Atk."+4','Accuracy+14','Attack+12'}}
    gear.herc_head_rf   = {name="Herculean Helm",
        augments={'Accuracy+17','DEX+6','"Refresh"+2','Accuracy+16 Attack+16','Mag. Acc.+20 "Mag.Atk.Bns."+20'}}
    gear.herc_hands_dt  = {name="Herculean Gloves", augments={'Attack+27','Damage taken-4%','DEX+5','Accuracy+9'}}
    gear.herc_legs_th   = {name="Herculean Trousers",
        augments={'Attack+3','"Cure" spellcasting time -2%','"Treasure Hunter"+2','Accuracy+1 Attack+1'}}
    gear.herc_head_fc = {name="Herculean Helm", augments={'"Mag.Atk.Bns."+2','"Fast Cast"+5'}}

    -- Binds overriding Mote defaults
    send_command('unbind ^F10')
    send_command('unbind ^F11')
    send_command('bind F10  gs c cycle CastingMode')
    send_command('bind !F10 gs c reset CastingMode')
    send_command('bind F11  gs c cycle IdleMode')
    send_command('bind !F11 gs c reset IdleMode')
    send_command('bind @F11 gs c toggle Kiting')
    send_command('bind !F12 gs c cycle TreasureMode')
    send_command('bind ^-  gs c set MeleeWeapon Naegling')
    send_command('bind ^@- gs c set MeleeWeapon NaegBlur')
    send_command('bind !@- gs c set MeleeWeapon NaegTaur')
    send_command('bind ^=  gs c set MeleeWeapon Rostam')
    send_command('bind ^@= gs c set MeleeWeapon RosBlur')
    send_command('bind !@= gs c set MeleeWeapon RosTaur')
    --send_command('bind ^backspace  gs c set MeleeWeapon JoyMerc')
    --send_command('bind @backspace  gs c set MeleeWeapon MercJoy')
    send_command('bind !-         gs c set RangedWeapon Fomalhaut')
    send_command('bind !=         gs c set RangedWeapon DeathPen')
    send_command('bind !backspace gs c set RangedWeapon Ataktos')
    send_command('bind !^0         gs c preset aeolian')
    send_command('bind !^-         gs c preset lstand')
    send_command('bind !^=         gs c preset leaden')
    send_command('bind !^backspace gs c preset savage')
    send_command('bind ^space gs c cycle HybridMode')
    send_command('bind ^@space gs c reset HybridMode')
    send_command('bind !space gs c set DefenseMode Physical')
    send_command('bind @space gs c set DefenseMode Magical')
    send_command('bind !@space gs c reset DefenseMode')

    send_command('bind ^` input /ja "Crooked Cards" <me>')
    send_command('bind ^@` input /ja "Random Deal" <me>')
    send_command('bind ^@tab input /ja Fold <me>')
    send_command('bind !^` input /ja "Wild Card" <me>')
    send_command('bind ^tab input /ja "Snake Eye" <me>')
    send_command('bind @tab input /ja "Dark Shot"')
    send_command('bind @` input /ja "Bolter\'s Roll" <me>')
    send_command('bind !@` input /ja "Cutting Cards" <t>')

    send_command('bind !^1 input /ws Wildfire')
    send_command('bind !^2 input /ws "Leaden Salute"')
    send_command('bind !^3 input /ws "Last Stand"')
    send_command('bind !^4 input /ws "Savage Blade"')
    send_command('bind !^5 input /ws Requiescat')
    send_command('bind !^6 input /ws "Aeolian Edge"')

    send_command('bind !b input //savageblade')
    send_command('bind @b input //savageblade <stnpc>')
    send_command('bind !^d input //flatblade')

    send_command('bind ^1 input /ja Double-Up <me>')
    send_command('bind ^2 input /ja "Hunter\'s Roll" <me>')
    send_command('bind ^3 input /ja "Chaos Roll" <me>')
    send_command('bind ^4 input /ja "Samurai Roll" <me>')
    send_command('bind ^5 input /ja "Tactician\'s Roll" <me>')
    send_command('bind ^6 input /ja "Fighter\'s Roll" <me>')
    send_command('bind ^7 input /ja "Rogue\'s Roll" <me>')

    send_command('bind ^@1 input /ja "Naturalist\'s Roll" <me>')
    send_command('bind ^@2 input /ja "Warlock\'s Roll" <me>')
    send_command('bind ^@3 input /ja "Wizard\'s Roll" <me>')
    send_command('bind ^@4 input /ja "Caster\'s Roll" <me>')
    send_command('bind ^@5 input /ja "Evoker\'s Roll" <me>')
    send_command('bind ^@6 input /ja "Allies\' Roll" <me>')

    send_command('bind !1 input /ra <t>')
    send_command('bind @1 input /ra <stnpc>')
    send_command('bind !2 input /ja "Light Shot" <t>')
    send_command('bind @2 input /ja "Light Shot" <stnpc>')
    send_command('bind !3 input /ja "Triple Shot" <me>')
    send_command('bind !8 gs equip phlx')

    send_command('bind !@1 input /ja "Fire Shot"')
    send_command('bind !@2 input /ja "Ice Shot"')
    send_command('bind !@3 input /ja "Wind Shot"')
    send_command('bind !@4 input /ja "Earth Shot"')
    send_command('bind !@5 input /ja "Thunder Shot"')
    send_command('bind !@6 input /ja "Water Shot"')

    send_command('bind !z gs c toggle LuzafRing')
    send_command('bind !c  gs c set OffenseMode Acc')
    send_command('bind @c  gs c set OffenseMode MEVA')
    send_command('bind !w  gs c set OffenseMode Normal')
    send_command('bind !@w gs c set OffenseMode None')
    send_command('bind ^\\\\ gs c toggle WSMsg')

    if     player.sub_job == 'WAR' then
        send_command('bind !4 input /ja Berserk <me>')
        send_command('bind !5 input /ja Aggressor <me>')
        send_command('bind !6 input /ja Warcry <me>')
        send_command('bind !d input /ja Provoke')
        send_command('bind !e input /ja Defender <me>')
    elseif player.sub_job == 'DNC' then
        send_command('bind !4 input /recast "Curing Waltz III"; input /ja "Curing Waltz III" <stpc>')
        send_command('bind !5 input /recast "Healing Waltz"; input /ja "Healing Waltz" <stpc>')
        send_command('bind @F1 input /ja "Healing Waltz" <stpc>')
        send_command('bind !v input /ja "Spectral Jig" <me>')
        send_command('bind !d input /ja "Violent Flourish"')
        send_command('bind !@d input /ja "Animated Flourish"')
        send_command('bind !f input /ja "Haste Samba" <me>')
        send_command('bind !@f input /ja "Reverse Flourish" <me>')
        send_command('bind !e input /ja "Box Step"')
        send_command('bind !@e input /ja Quickstep')
    elseif player.sub_job == 'NIN' then
        send_command('bind !e input /ma "Utsusemi: Ni" <me>')
        send_command('bind !@e input /ma "Utsusemi: Ichi" <me>')
    elseif player.sub_job == 'THF' then
        send_command('bind !4 input /ma "Sneak Attack" <me>')
        send_command('bind !5 input /ma "Trick Attack" <me>')
    elseif player.sub_job == 'DRG' then
        send_command('bind !4 input /ja "High Jump"')
        send_command('bind !6 input /ja "Ancient Circle" <me>')
    elseif player.sub_job == 'RDM' then
        send_command('bind !e input /ma "Cure III"')
        send_command('bind !@e input /ma "Cure IV"')
        send_command('bind !f input /ma Haste')
        send_command('bind !@f input /ma Flurry')
        send_command('bind !g input /ma Phalanx')
        send_command('bind !@g input /ma Stoneskin')
        send_command('bind @c input /ma Blink')
        send_command('bind !v input /ma Aquaveil')
        send_command('bind !b input /ma Refresh')
    elseif player.sub_job == 'WHM' then
        -- Status cure binds (never want to fumble these)
        send_command('bind @1 input /ma Poisona')
        send_command('bind @2 input /ma Paralyna')
        send_command('bind @3 input /ma Blindna')
        send_command('bind @4 input /ma Silena')
        send_command('bind @5 input /ma Stona')
        send_command('bind @6 input /ma Viruna')
        send_command('bind @7 input /ma Cursna')
        send_command('bind @F1 input /ma Erase')
        send_command('bind !e input /ma "Cure III"')
        send_command('bind !@e input /ma "Cure IV"')
        send_command('bind !d input /ma Flash')
        send_command('bind !f input /ma Haste')
        send_command('bind !@g input /ma Stoneskin')
        send_command('bind @c input /ma Blink')
        send_command('bind !v input /ma Aquaveil')
    elseif player.sub_job == 'SMN' then
        send_command('bind !v input //mewinglullaby')
        send_command('bind !b input //caitsith')
        send_command('bind !@b input //release')
        send_command('bind !n input //retreat')
    end

    update_combat_form()
    select_default_macro_book()
end

-- Called when this job file is unloaded (eg: job change)
function user_unload()
    send_command('unbind ^backspace')
    send_command('unbind @backspace')
    send_command('unbind !-')
    send_command('unbind !=')
    send_command('unbind !backspace')
    send_command('unbind ^@-')
    send_command('unbind ^@backspace')
    send_command('unbind ^-')
    send_command('unbind !@-')
    send_command('unbind !^-')
    send_command('unbind ^=')
    send_command('unbind ^@=')
    send_command('unbind !@=')
    send_command('unbind !^=')
    send_command('unbind !^backspace')
    send_command('unbind ^space')
    send_command('unbind !space')
    send_command('unbind @space')
    send_command('unbind !@space')

    send_command('unbind ^`')
    send_command('unbind ^@`')
    send_command('unbind ^@tab')
    send_command('unbind !^`')
    send_command('unbind ^tab')
    send_command('unbind @tab')
    send_command('unbind @`')
    send_command('unbind !@`')

    send_command('unbind !^1')
    send_command('unbind !^2')
    send_command('unbind !^3')
    send_command('unbind !^4')
    send_command('unbind !^5')
    send_command('unbind !^6')

    send_command('unbind !b')
    send_command('unbind @b')
    send_command('unbind !^d')

    send_command('unbind ^1')
    send_command('unbind ^2')
    send_command('unbind ^3')
    send_command('unbind ^4')
    send_command('unbind ^5')
    send_command('unbind ^6')
    send_command('unbind ^7')

    send_command('unbind ^@1')
    send_command('unbind ^@2')
    send_command('unbind ^@3')
    send_command('unbind ^@4')
    send_command('unbind ^@5')
    send_command('unbind ^@6')

    send_command('unbind !1')
    send_command('unbind @1')
    send_command('unbind !2')
    send_command('unbind @2')
    send_command('unbind !3')
    send_command('unbind !8')

    send_command('unbind !@1')
    send_command('unbind !@2')
    send_command('unbind !@3')
    send_command('unbind !@4')
    send_command('unbind !@5')
    send_command('unbind !@6')

    send_command('unbind !z')
    send_command('unbind !c')
    send_command('unbind @c')
    send_command('unbind !w')
    send_command('unbind !@w')
    send_command('unbind ^\\\\')

    send_command('unbind !4')
    send_command('unbind !5')
    send_command('unbind !6')
    send_command('unbind !@b')
    send_command('unbind !@d')
    send_command('unbind !@e')
    send_command('unbind !@f')
    send_command('unbind !@g')
    send_command('unbind !b')
    send_command('unbind !d')
    send_command('unbind !e')
    send_command('unbind !f')
    send_command('unbind !g')
    send_command('unbind !n')
    send_command('unbind !v')
    send_command('unbind @1')
    send_command('unbind @2')
    send_command('unbind @3')
    send_command('unbind @4')
    send_command('unbind @5')
    send_command('unbind @6')
    send_command('unbind @7')
    send_command('unbind @F1')
    send_command('unbind @c')

    destroy_state_text()
end

-- Define sets and vars used by this job file.
function init_gear_sets()

    sets.weapons = {}
    sets.weapons.None = {}
    sets.weapons.Naegling  = {main="Naegling",sub="Nusku Shield"}
    sets.weapons.Tauret    = {main="Tauret",sub="Nusku Shield"}
    sets.weapons.Rostam    = {main="Rostam",sub="Nusku Shield"}
    --sets.weapons.JoyMerc   = {main="Joyeuse",sub="Mercurial Kris"}    -- omen objs
    --sets.weapons.MercJoy   = {main="Mercurial Kris",sub="Joyeuse"}    -- omen objs
    sets.weapons.NaegBlur  = {main="Naegling",sub="Blurred Knife +1"}
    sets.weapons.NaegTaur  = {main="Naegling",sub="Tauret"}
    sets.weapons.RosBlur   = {main="Rostam",sub="Blurred Knife +1"}
    sets.weapons.RosTaur   = {main="Rostam",sub="Tauret"}
    sets.weapons.Aeolian   = {main="Tauret",sub="Naegling"}
    sets.weapons.TaurBlur  = {main="Tauret",sub="Blurred Knife +1"}
    sets.weapons.Fomalhaut = {range="Fomalhaut"}
    sets.weapons.DeathPen  = {range="Death Penalty"}
    sets.weapons.Ataktos   = {range="Ataktos"}

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
    sets.precast.CorsairShot = {range="Death Penalty",ammo=gear.QDbullet}

    sets.precast.FC = {head=gear.herc_head_fc,neck="Orunmila's Torque",ear1="Loquacious Earring",ear2="Etiolation Earring",
        body="Adhemar Jacket",hands="Leyline Gloves",ring2="Kishar Ring",
        back=gear.FastCape,legs="Rawhide Trousers",feet="Carmine Greaves +1"}
    -- fastcast+62%
    sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {neck="Magoraga Bead Necklace"})

    sets.precast.WS = {ammo=gear.WSbullet,  -- assume ranged weaponskills, eg, Last Stand
        head=gear.herc_head_wsd,neck="Fotia Gorget",ear1="Telos Earring",ear2="Moonshade Earring",
        body="Laksamana's Frac +3",hands="Meghanada Gloves +2",ring1="Dingir Ring",ring2="Regal Ring",
        back=gear.RAWSCape,waist="Fotia Belt",legs="Malignance Tights",feet="Lanun Bottes +3"}
    sets.precast.WS.Acc = set_combine(sets.precast.WS, {head="Meghanada Visor +2",neck="Iskur Gorget"})
    sets.precast.WS.FullTP = set_combine(sets.precast.WS, {ear2="Enervating Earring"})
    sets.precast.WS.FullTPAcc = set_combine(sets.precast.WS.Acc, {ear2="Enervating Earring"})
    sets.precast.WS.Enmity = set_combine(sets.precast.WS, {
        ear1="Novia Earring",ring1="Persis Ring",legs="Laksamana's Trews +3",feet="Oshosi Leggings +1"})
    sets.precast.WS.Enmity.Ambu = set_combine(sets.precast.Enmity, {ear1="Cytherea Pearl"})
    --sets.precast.WS.NoDmg = set_combine(sets.precast.WS, {ammo="Bronze Bullet"})

    sets.precast.WS.Wildfire = {ammo=gear.MAbullet,
        head=gear.herc_head_ma,neck="Baetyl Pendant",ear1="Friomisi Earring",ear2="Hecate's Earring",
        body="Lanun Frac +3",hands="Carmine Finger Gauntlets +1",ring1="Dingir Ring",ring2="Regal Ring",
        back=gear.MAWSCape,waist=gear.ElementalObi,legs=gear.herc_legs_ma,feet="Lanun Bottes +3"}
    --sets.precast.WS.Wildfire.NoDmg = set_combine(sets.naked, {ammo="Bronze Bullet"})
    sets.precast.WS['Leaden Salute'] = set_combine(sets.precast.WS.Wildfire, {
        head="Pixie Hairpin +1",ear2="Moonshade Earring",ring2="Archon Ring"})
    sets.precast.WS['Leaden Salute'].FullTP = set_combine(sets.precast.WS['Leaden Salute'], {ear2="Hecate's Earring"})
    sets.precast.WS['Leaden Salute'].Acc = set_combine(sets.precast.WS['Leaden Salute'], {
        neck="Sanctity Necklace",ear1="Hermetic Earring",hands=gear.herc_hands_ma,waist="Kwahu Kachina Belt",legs=gear.herc_legs_macc})
    sets.precast.WS['Leaden Salute'].FullTPAcc = set_combine(sets.precast.WS['Leaden Salute'].Acc, {ear2="Dignitary's Earring"})
    sets.precast.WS['Leaden Salute'].Enmity = set_combine(sets.precast.WS['Leaden Salute'], {
        ear1="Novia Earring",legs="Laksamana's Trews +3"})
    sets.precast.WS['Leaden Salute'].FullTPEnmity = set_combine(sets.precast.WS['Leaden Salute'].Enmity, {ear2="Hecate's Earring"})
    sets.precast.WS['Sanguine Blade'] = set_combine(sets.precast.WS['Leaden Salute'].FullTP, {})
    sets.precast.WS['Aeolian Edge'] = set_combine(sets.precast.WS.Wildfire, {ear2="Moonshade Earring"})
    sets.precast.WS['Aeolian Edge'].FullTP = set_combine(sets.precast.WS.Wildfire, {})

    sets.precast.WS['Hot Shot'] = {ammo=gear.MAbullet,
        head=gear.herc_head_wsd,neck="Fotia Gorget",ear1="Friomisi Earring",ear2="Moonshade Earring",
        body="Laksamana's Frac +3",hands="Carmine Finger Gauntlets +1",ring1="Dingir Ring",ring2="Regal Ring",
        back=gear.MAWSCape,waist="Fotia Belt",legs=gear.herc_legs_ma,feet="Lanun Bottes +3"}
    sets.precast.WS['Hot Shot'].FullTP = set_combine(sets.precast.WS['Hot Shot'], {ear2="Hecate's Earring"})
    sets.precast.WS['Hot Shot'].Acc = {ammo=gear.WSbullet,
        head="Meghanada Visor +2",neck="Fotia Gorget",ear1="Telos Earring",ear2="Moonshade Earring",
        body="Laksamana's Frac +3",hands="Meghanada Gloves +2",ring1="Dingir Ring",ring2="Regal Ring",
        back=gear.RAWSCape,waist="Fotia Belt",legs="Adhemar Kecks",feet="Meghanada Jambeaux +2"}
    sets.precast.WS['Hot Shot'].FullTPAcc = set_combine(sets.precast.WS['Hot Shot'].Acc, {ear2="Friomisi Earring"})

    sets.precast.WS['Savage Blade'] = {
        head=gear.herc_head_wsd,neck="Caro Necklace",ear1="Ishvara Earring",ear2="Moonshade Earring",
        body="Laksamana's Frac +3",hands="Meghanada Gloves +2",ring1="Rufescent Ring",ring2="Regal Ring",
        back=gear.MEWSCape,waist="Grunfeld Rope",legs="Meghanada Chausses +2",feet="Lanun Bottes +3"}
    sets.precast.WS['Savage Blade'].FullTP = set_combine(sets.precast.WS['Savage Blade'], {ear1="Telos Earring",ear2="Ishvara Earring"})
    sets.precast.WS['Savage Blade'].Acc = set_combine(sets.precast.WS['Savage Blade'], {neck="Fotia Gorget",ear1="Telos Earring",
        head="Meghanada Visor +2",body="Meghanada Cuirie +2"})
    sets.precast.WS['Savage Blade'].FullTPAcc = set_combine(sets.precast.WS['Savage Blade'].Acc, {ear2="Dignitary's Earring"})
    sets.precast.WS.Requiescat = {
        head="Meghanada Visor +2",neck="Fotia Gorget",ear1="Telos Earring",ear2="Dignitary's Earring",
        body="Meghanada Cuirie +2",hands=gear.herc_hands_ta,ring1="Epona's Ring",ring2="Regal Ring",
        back=gear.METPCape,waist="Fotia Belt",legs="Meghanada Chausses +2",feet="Meghanada Jambeaux +2"}
    sets.precast.WS.Evisceration = {
        head="Adhemar Bonnet +1",neck="Fotia Gorget",ear1="Telos Earring",ear2="Odr Earring",
        body="Mummu Jacket +2",hands="Mummu Wrists +2",ring1="Epona's Ring",ring2="Ilabrat Ring",
        back=gear.METPCape,waist="Fotia Belt",legs="Mummu Kecks +2",feet="Oshosi Leggings +1"}
    sets.precast.WS['Swift Blade'] = set_combine(sets.precast.WS.Requiescat, {})
    sets.precast.WS['Flat Blade'] = {ammo=gear.QDbullet,
        head="Mummu Bonnet +2",neck="Sanctity Necklace",ear1="Telos Earring",ear2="Dignitary's Earring",
        body="Lanun Frac +3",hands="Leyline Gloves",ring1="Stikini Ring +1",ring2="Etana Ring",
        back=gear.METPCape,waist="Eschan Stone",legs="Meghanada Chausses +2",feet="Lanun Bottes +3"}
    sets.precast.WS.Shadowstitch = set_combine(sets.precast.WS['Flat Blade'], {})

    sets.precast.RA = {ammo=gear.RAbullet,
        head="Taeon Chapeau",body="Oshosi Vest",hands="Carmine Finger Gauntlets +1",
        back=gear.SnapCape,waist="Yemaya Belt",legs="Laksamana's Trews +3",feet="Meghanada Jambeaux +2"}
    -- +62% snapshot (+10% base), +16 rapid shot
    sets.precast.RA.Flurry = set_combine(sets.precast.RA, {body="Laksamana's Frac +3"})
    -- +50% snapshot (+10% base), +36 rapid shot

    sets.precast.Waltz = {head="Mummu Bonnet +2"}
    sets.precast.Step = {
        head="Meghanada Visor +2",neck="Combatant's Torque",ear1="Telos Earring",ear2="Odr Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Cacoethic Ring +1",ring2="Etana Ring",
        back=gear.METPCape,waist="Grunfeld Rope",legs="Malignance Tights",feet="Malignance Boots"}
    sets.precast.JA['Violent Flourish'] = {
        head="Mummu Bonnet +2",neck="Sanctity Necklace",ear1="Telos Earring",ear2="Dignitary's Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Cacoethic Ring +1",ring2="Etana Ring",
        back=gear.METPCape,waist="Eschan Stone",legs="Malignance Tights",feet="Malignance Boots"}

    -- Midcast Sets
    sets.midcast.Cure = {main="Chatoyant Staff",sub="Niobid Strap",
        neck="Incanter's Torque",ear1="Novia Earring",ear2="Mendicant's Earring",back="Solemnity Cape"}
    sets.midcast.Curaga = set_combine(sets.midcast.Cure, {})
    sets.midcast.Cursna = {neck="Malison Medallion",ring1="Haoma's Ring",ring2="Haoma's Ring",waist="Goading Belt"}
    -- healing skill 168, cursna +40 (est. 22% success)
    sets.midcast['Enfeebling Magic'] = {main="Naegling",range="Fomalhaut",ammo=gear.MAbullet,
        head="Mummu Bonnet +2",neck="Sanctity Necklace",ear1="Gwati Earring",ear2="Dignitary's Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1=gear.Lstikini,ring2=gear.Rstikini,
        back=gear.MAWSCape,waist="Kwahu Kachina Belt",legs="Malignance Tights",feet="Malignance Boots"}
    sets.midcast.Repose = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast['Enhancing Magic'] = {neck="Incanter's Torque",ear1="Andoaa Earring",ear2="Mimir Earring",
        ring1=gear.Lstikini,ring2=gear.Rstikini,waist="Olympus Sash"}
    sets.phlx = {head=gear.taeon_head_phlx,
        body=gear.taeon_body_phlx,hands=gear.taeon_hands_phlx,legs=gear.taeon_legs_phlx,feet=gear.taeon_feet_phlx}
    sets.midcast.Phalanx = set_combine(sets.midcast['Enhancing Magic'], sets.phlx)

    sets.midcast.CorsairShot = {main="Naegling",range="Death Penalty",ammo=gear.QDbullet,
        head=gear.herc_head_ma,neck="Baetyl Pendant",ear1="Friomisi Earring",ear2="Hecate's Earring",
        body="Lanun Frac +3",hands="Carmine Finger Gauntlets +1",ring1="Dingir Ring",ring2=gear.ElementalRing,
        back=gear.MAWSCape,waist=gear.ElementalObi,legs=gear.herc_legs_ma,feet="Chasseur's Bottes +1"}
    sets.midcast.CorsairShot.STP = {ammo=gear.QDbullet,
        head="Blood Mask",neck="Iskur Gorget",ear1="Telos Earring",ear2="Dedition Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Petrov Ring",ring2="Ilabrat Ring",
        back=gear.RATPCape,waist="Goading Belt",legs="Malignance Tights",feet="Chasseur's Bottes +1"}
    sets.midcast.CorsairShot.Acc = set_combine(sets.midcast.CorsairShot, {
        head="Mummu Bonnet +2",neck="Sanctity Necklace",ear1="Gwati Earring",ear2="Dignitary's Earring",
        ring2="Stikini Ring +1",waist="Kwahu Kachina Belt"})
    sets.midcast.CorsairShot['Light Shot'] = set_combine(sets.midcast.CorsairShot.Acc, {
        head="Blood Mask",neck="Combatant's Torque",body="Malignance Tabard",hands="Malignance Gloves",legs="Malignance Tights"})
    sets.midcast.CorsairShot['Dark Shot'] = set_combine(sets.midcast.CorsairShot['Light Shot'], {})
    sets.midcast.CorsairShot['Light Shot'].Acc = set_combine(sets.midcast.CorsairShot['Light Shot'], {head="Mummu Bonnet +2"})
    sets.midcast.CorsairShot['Dark Shot'].Acc = set_combine(sets.midcast.CorsairShot['Light Shot'].Acc, {})

    sets.midcast.RA = {ammo=gear.RAbullet,
        head="Meghanada Visor +2",neck="Iskur Gorget",ear1="Telos Earring",ear2="Enervating Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Dingir Ring",ring2="Ilabrat Ring",
        back=gear.RATPCape,waist="Yemaya Belt",legs="Adhemar Kecks",feet="Malignance Boots"}
    sets.midcast.RA.Acc = set_combine(sets.midcast.RA, {ring1="Cacoethic Ring +1",legs="Malignance Tights"})
    sets.midcast.RA.HighAcc = set_combine(sets.midcast.RA.Acc, {})
    sets.midcast.RA.Crit = set_combine(sets.midcast.RA, {
        ear2="Odr Earring",body="Nisroch Jerkin",hands="Mummu Wrists +2",
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
        head="Volte Cap",neck="Loricate Torque +1",ear1="Novia Earring",ear2="Etiolation Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.RATPCape,waist="Flume Belt +1",legs="Carmine Cuisses +1",feet="Malignance Boots"}
    -- pdt-50, mdt-50, meva+583
    sets.idle.PDT = set_combine(sets.idle, {legs="Malignance Tights"})
    sets.idle.MEVA = set_combine(sets.idle.PDT, {ear1="Eabani Earring"})
    sets.idle.Rf = set_combine(sets.idle, {
        head=gear.herc_head_rf,ear1="Genmei Earring",
        body="Mekosuchinae Harness",ring1=gear.Lstikini,ring2=gear.Rstikini,
        legs="Rawhide Trousers"})
    sets.buff.doom = {neck="Nicander's Necklace",ring1="Saida Ring",waist="Gishdubar Sash"}

    sets.defense.PDT = set_combine(sets.idle.PDT, {})
    sets.defense.MEVA = set_combine(sets.idle.MEVA, {})
    sets.Kiting = {legs="Carmine Cuisses +1"}

    -- Normal melee group
    sets.engaged = {
        head="Adhemar Bonnet +1",neck="Combatant's Torque",ear1="Telos Earring",ear2="Brutal Earring",
        body="Adhemar Jacket +1",hands="Adhemar Wristbands +1",ring1="Epona's Ring",ring2="Hetairoi Ring",
        back=gear.METPCape,waist="Reiki Yotai",legs="Samnuha Tights",feet=gear.herc_feet_ta}
    sets.engaged.MEVA = set_combine(sets.engaged, {
        body="Malignance Tabard",hands="Malignance Gloves",legs="Malignance Tights",feet="Malignance Boots"})
    sets.engaged.Acc = set_combine(sets.engaged, {
        head="Mummu Bonnet +2",ear2="Dignitary's Earring",ring2="Ilabrat Ring",legs="Malignance Tights"})
    --sets.engaged.Crit = set_combine(sets.engaged, {head="Mummu Bonnet +2", -- for mamool ambu
    --    body="Mummu Jacket +2",hands="Mummu Wrists +2",waist="Reiki Yotai",legs="Mummu Kecks +2"})

    sets.engaged.PDef = set_combine(sets.engaged, {
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Vocane Ring +1",ring2="Defending Ring",
        legs="Malignance Tights",feet="Malignance Boots"})
    sets.engaged.MEVA.PDef = set_combine(sets.engaged.PDef, {})
    sets.engaged.Acc.PDef = set_combine(sets.engaged.PDef, {head="Mummu Bonnet +2",ear2="Dignitary's Earring"})

    -- Sets that depend upon idle sets
    sets.resting = set_combine(sets.idle, {main="Chatoyant Staff",sub="Niobid Strap"})
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

    if spell.type == 'WeaponSkill' then
        state.aeonic_aftermath_precast = (buffactive["Aftermath: Lv.1"] or buffactive["Aftermath: Lv.2"] or buffactive["Aftermath: Lv.3"])
        custom_aftermath_timers_precast(spell)
        if world.area == 'Maquette Abdhaljs-Legion' and spell.english == 'Last Stand' and state.WeaponskillMode.value == 'Enmity' then
            equip(sets.precast.WS.Enmity.Ambu)
            eventArgs.handled = true
        end
    end
end

-- Run after the general precast() is done.
function job_post_precast(spell, action, spellMap, eventArgs)
    if (spell.type == 'CorsairRoll' or spell.english == "Double-Up") and state.LuzafRing.value then
        equip(sets.precast.LuzafRing)
    end
end

-- Run after the default midcast() is done.
-- eventArgs is the same one used in job_midcast, in case information needs to be persisted.
function job_post_midcast(spell, action, spellMap, eventArgs)
    if spell.type == 'CorsairShot' then
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
        if S{'Cure','Curaga','Refresh'}:contains(spellMap) then
            equip({waist="Gishdubar Sash"})
        elseif spell.english == 'Cursna' then
            equip(sets.buff.doom)
        end
    end
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_aftercast(spell, action, spellMap, eventArgs)
    if spell.interrupted then
        send_command('wait 0.5;gs c update')
        if buffactive.Amnesia and S{'JobAbility','WeaponSkill','CorsairRoll','CorsairShot'}:contains(spell.type) then
            add_to_chat(123, 'Amnesia prevents using '..spell.english)
        elseif buffactive.Silence and S{'WhiteMagic','Ninjutsu'}:contains(spell.type) then
            add_to_chat(123, 'Silence prevents using '..spell.english)
        elseif has_any_buff_of(S{'petrification','sleep','stun','terror'}) then
            add_to_chat(123, 'Status prevents using '..spell.english)
        end
    else
        if spell.type == 'CorsairShot' then
            if gear.QDbullet == 'Animikii Bullet' then equip({ammo=empty}) end  -- extra layer of protection
            if spell.english == 'Light Shot' then
                send_command('@timers c "'..spell.english..' ['..spell.target.name..']" 60 down spells/00220.png')
            elseif spell.english ~= 'Dark Shot' and state.CastingMode.value ~= 'STP' then
                eventArgs.handled = true
            end
        elseif spell.type == 'JobAbility' then
            if not sets.precast.JA[spell.english] then
                eventArgs.handled = true
            end
        elseif spell.english == 'Dia II' then
            send_command('@timers c "'..spell.english..' ['..spell.target.name..']" 120 down spells/00220.png')
        elseif spell.type == 'WeaponSkill' then
            if state.WSMsg.value then
                ws_msg(spell)
            end
            custom_aftermath_timers_aftercast(spell)
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
        handle_equipping_gear(player.status)
        if newValue ~= 'None' then
            equip(sets.weapons[state.MeleeWeapon.value])
            equip(sets.weapons[state.RangedWeapon.value])
            disable('main','sub','range')
            if     state.RangedWeapon.value == 'DeathPen'  then state.CastingMode:set('Normal')
            else                                                state.CastingMode:set('STP')
            end
        else
            state.CastingMode:set('Normal')
        end
    elseif stateField == 'Melee Weapon' then
        if state.OffenseMode.value ~= 'None' then
            enable('main','sub')
            handle_equipping_gear(player.status)
            equip(sets.weapons[newValue])
            if state.MeleeWeapon.value ~= 'None' then
                disable('main','sub')
            end
        end
    elseif stateField == 'Ranged Weapon' then
        if state.OffenseMode.value ~= 'None' then
            enable('range')
            handle_equipping_gear(player.status)
            equip(sets.weapons[newValue])
            if state.RangedWeapon.value ~= 'None' then
                disable('range')
            end
        end
        if     state.RangedWeapon.value == 'Ataktos'   then state.FullTP = 1750
        elseif state.RangedWeapon.value == 'Fomalhaut' then state.FullTP = 2250
        else                                                state.FullTP = 2750
        end
        if player.sub_job == 'WAR' then                     state.FullTP = state.FullTP - 200
        end
        if     state.RangedWeapon.value == 'DeathPen'  then state.CastingMode:set('Normal')
        else                                                state.CastingMode:set('STP')
        end
    end
end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements standard library decisions.
-------------------------------------------------------------------------------------------------------------------

-- Return a customized weaponskill mode to use for weaponskill sets.
-- Don't return anything if you're not overriding the default value.
function get_custom_wsmode(spell, spellMap, default_wsmode)
    if player.tp >= state.FullTP+75 then
        local new_wsmode
        if default_wsmode == 'Normal' then
            new_wsmode = 'FullTP'
        else
            new_wsmode = 'FullTP'..default_wsmode
        end

        if sets.precast.WS[spell.english] then
            if sets.precast.WS[spell.english][new_wsmode] then
                return new_wsmode
            end
        elseif sets.precast.WS[new_wsmode] then
            return new_wsmode
        else
            return 'FullTP'
        end
    end
end

-- Modify the default idle set after it was constructed.
function customize_idle_set(idleSet)
    if state.Buff.doom then
        idleSet = set_combine(idleSet, sets.buff.doom)
    end
    return idleSet
end

-- Modify the default melee set after it was constructed.
function customize_melee_set(meleeSet)
    if state.Buff.doom then
        meleeSet = set_combine(meleeSet, sets.buff.doom)
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
    msg = msg .. ':' .. state.MeleeWeapon.value .. ']'
    msg = msg .. ' RA[' .. state.RangedMode.current .. ':' .. state.RangedWeapon.value .. ']'
    msg = msg .. ' WS[' .. state.WeaponskillMode.current .. ']'
    msg = msg .. ' QD[' .. state.CastingMode.current .. ']'
    msg = msg .. ' Idle[' .. state.IdleMode.current .. ']'

    if state.DefenseMode.value ~= 'None' then
        local defMode = state[state.DefenseMode.value ..'DefenseMode'].current
        msg = msg .. ' Def[' .. state.DefenseMode.value .. ':' .. defMode .. ']'
    end
    if state.TreasureMode.value ~= 'None' then
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

    if state.PCTargetMode.value ~= 'default' then
        msg = msg .. ', Target PC: ' .. state.PCTargetMode.value
    end

    if state.SelectNPCTargets.value then
        msg = msg .. ', Target NPCs'
    end

    add_to_chat(122, msg)

    eventArgs.handled = true
end

-- Called by the 'update' self-command, for common needs.
-- Set eventArgs.handled to true if we don't want automatic equipping of gear.
function job_update(cmdParams, eventArgs)
    update_combat_form()
    if     player.equipment.range == 'Ataktos'   then state.FullTP = 1750
    elseif player.equipment.range == 'Fomalhaut' then state.FullTP = 2250
    else                                              state.FullTP = 2750
    end
end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements self-commands.
-------------------------------------------------------------------------------------------------------------------

-- Called for custom player commands.
function job_self_command(cmdParams, eventArgs)
    if     cmdParams[1] == 'preset' then
        if     cmdParams[2] == 'aeolian' then
            state.MeleeWeapon:set('Aeolian')
            state.RangedWeapon:set('Fomalhaut')
        elseif cmdParams[2] == 'lstand' then
            state.MeleeWeapon:set('Rostam')
            state.RangedWeapon:set('Fomalhaut')
        elseif cmdParams[2] == 'leaden' then
            state.MeleeWeapon:set('NaegTaur')
            state.RangedWeapon:set('DeathPen')
        elseif cmdParams[2] == 'savage' then
            state.MeleeWeapon:set('NaegBlur')
            state.RangedWeapon:set('Ataktos')
        end
        enable('main','sub','range')
        equip(sets.weapons[state.MeleeWeapon.value])
        equip(sets.weapons[state.RangedWeapon.value])
        disable('main','sub','range')
        add_to_chat(122,'Using weapon preset \'' .. cmdParams[2] .. '\'')
    --elseif cmdParams[1] == 'mamools' then
    --    state.OffenseMode:set('Crit')
    --    state.WeaponskillMode:set('NoDmg')
    --    state.MeleeWeapon:set('TaurBlur')
    --    job_state_change('MeleeWeapon', 'TaurBlur', state.MeleeWeapon.value)
    --    state.LuzafRing:set()
    --    add_to_chat(122, 'Mammols mode set.')
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------

function update_combat_form()
    if state.OffenseMode.value == 'None' then
        enable('main','sub','range')
    else
        disable('main','sub','range')
    end
end

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

function ws_msg(spell)
    -- optional party chat messages for weaponskills
    local at_ws
    local good_ats = true
    local props = info.ws_props[spell.english].props
    local at_props = {}
    local aeonic = state.aeonic_aftermath_precast and info.ws_props[spell.english].aeonic
        and player.equipment.range == info.ws_props[spell.english].aeonic.weapon

    at_ws = at_stuff(spell.english) -- shift-jis
    good_ats = (at_ws ~= nil)
    if props then
        if aeonic then
            local prop = info.ws_props[spell.english].aeonic.sc
            local at_prop = at_stuff(prop)
            table.insert(at_props, at_prop)
            good_ats = (good_ats and at_prop)
        end
        for i, prop in ipairs(props) do
            local at_prop = at_stuff(prop)
            table.insert(at_props, at_prop)
            good_ats = (good_ats and at_prop)
        end
    end

    if good_ats then
        if props then
            windower.chat.input('/p used '..at_ws..' ('..table.concat(at_props,'')..')')
        else
            windower.chat.input('/p used '..at_ws)
        end
    else
        windower.chat.input('/p used '..spell.english)
    end
end

function init_state_text()
    destroy_state_text()
    local luzafs_text_settings = {pos={y=0},flags={draggable=false},bg={alpha=150}}
    local hyb_text_settings    = {pos={x=130,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local def_text_settings    = {pos={x=172,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local off_text_settings    = {pos={x=172,y=697},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}

    state.luzafs_text = texts.new('NoLuzaf', luzafs_text_settings)
    state.hyb_text    = texts.new('/${hybrid}', hyb_text_settings)
    state.def_text    = texts.new('(${defense})', def_text_settings)
    state.off_text    = texts.new('${offense}', off_text_settings)

    local last_count = 0
    state.texts_event_id = windower.register_event('prerender', function()
        state.luzafs_text:visible((not state.LuzafRing.value))

        if state.HybridMode.value ~= 'Normal' then
            state.hyb_text:visible(true)
            state.hyb_text:update({['hybrid']=state.HybridMode.value})
        else
            state.hyb_text:visible(false)
        end

        if state.DefenseMode.value ~= 'None' then
            state.def_text:visible(true)
            local defMode = state[state.DefenseMode.value ..'DefenseMode'].current
            state.def_text:update({['defense']=defMode})
        else
            state.def_text:visible(false)
        end

        if state.OffenseMode.value ~= 'Normal' then
            state.off_text:visible(true)
            state.off_text:update({['offense']=state.OffenseMode.value})
        else
            state.off_text:visible(false)
        end
    end)
end

function destroy_state_text()
    if state.texts_event_id then
        windower.unregister_event(state.texts_event_id)
        state.luzafs_text:visible(false)
        state.hyb_text:visible(false)
        state.def_text:visible(false)
        state.off_text:visible(false)
        texts.destroy(state.luzafs_text)
        texts.destroy(state.hyb_text)
        texts.destroy(state.def_text)
        texts.destroy(state.off_text)
    end
end
