-- Modified from 'https://github.com/Kinematics/GearSwap-Jobs/blob/master/Template.lua'
-- TODO weakened hp set (or make higher hp defense modes)
-- TODO fix swaps to not get stuck in enmity gear while stunned/petrified

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
-- consider using the MDT50 tanking set for strong breath attacks, eg, arrogance incarnate
-- add items to the hpgear table in user_setup() to prioritize swap order by hp so less max hp is lost

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
-- use battuta if yaksha gets scary. mdt50 if raksha is bad. use foil for hate, but cancel it
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
-- sheep song, cocoon, stinking gas,
-- healing breeze, wild carrot, refueling
-- pollen, wild oats, power attack

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
    enable('range','ammo','head','neck','ear1','ear2','body','hands','ring1','ring2','back','waist','legs','feet')
    disable('main','sub')
    state.Buff.Valiance = buffactive.Valiance or false
    state.Buff.Vallation = buffactive.Vallation or false
    state.Buff.Embolden = buffactive.Embolden or false
    state.Buff.doom = buffactive.doom or false
    state.texts_event_id = nil
    state.aeonic_aftermath_precast = false
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
    state.OffenseMode:options('Normal','None')                      -- Cycle with F9, set with !w, !@w
    state.HybridMode:options('Normal','PDef','PDef2')               -- Cycle with ^space
    state.WeaponskillMode:options('Normal','Tank','Acc')            -- Cycle with @F9
    state.CastingMode:options('Tank','FullENM','Paranoid','MAcc')   -- Cycle with F10, reset with !F10, set with ^c, !@c
    state.IdleMode:options('Normal','Refresh','Kite')               -- Cycle with F11, reset with !F11
    state.PhysicalDefenseMode:options('Parry','ParryAcc','ParryRf','Kite') -- Cycle with !z
    state.MagicalDefenseMode:options('MEVA','MDT50')                -- Cycle with @z, set to MDT50 with !@z
    state.StatusDefenseMode = M{['description']='Status Defense'}
    state.StatusDefenseMode:options('None','Knockback','Charm','Death')  -- Set with !7..!0
    state.CombatWeapon = M{['description']='Combat Weapon'}         -- Cycle with !-, !=, set with @F1..@F4
    state.WSBinds = M{['description']='WS Binds',['string']=''}
    state.CombatWeapon:options('Epeo','EpeoRef','Lionheart','GreatAxe','Sword','Axe')

    state.WSMsg = M(false, 'WS Message')                        -- Toggle with ^\ (also chat for JAs)
    state.SIRD  = M(false, 'SIRD Casting')                      -- Toggle with !c
    state.OFAhp = M(false, 'OFA++')                             -- Toggle with !`
    state.THtag = M(false, 'TH+4 Poisonga')                     -- Toggle with !F12
    init_state_text()

    info.sird_spells = S{'Aquaveil','Crusade','Foil','Stoneskin',
        'Cocoon','Healing Breeze','Wild Carrot','Sheep Song','Stinking Gas','Geist Wall'}
    info.recast_ids = {["One for All"]=118,["Gambit"]=116,["Rayke"]=119,["Battuta"]=120,
        ["Pflug"]=59,["Vallation"]=23,["Valiance"]=113,["Liement"]=117}

    -- Mote-libs handle obis, gorgets, and other elemental things.
    -- These are default fallbacks if situationally appropriate gear is not available.
    gear.default.weaponskill_neck = "Sanctity Necklace"     -- used in sets.precast.WS and friends
    gear.default.weaponskill_waist = "Windbuffet Belt +1"   -- used in sets.precast.WS and friends
    gear.default.obi_waist = "Eschan Stone"                 -- used in sets.precast.WS.Magical

    -- Augmented items get variables for convenience and specificity
    gear.TPCape   = {name="Ogma's cape", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Dbl.Atk."+10','Phys. dmg. taken-10%'}}
    gear.ResoCape = {name="Ogma's cape", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','Phys. dmg. taken-10%'}}
    gear.DimiCape = {name="Ogma's cape", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','Weapon skill damage +10%','Phys. dmg. taken-10%'}}
    gear.MEVACape = {name="Ogma's cape", augments={'HP+60','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Enmity+10','Phys. dmg. taken-10%'}}
    gear.FCCape   = {name="Ogma's cape", augments={'HP+60','HP+20','"Fast Cast"+10'}}
    gear.taeon_head_sird  = {name="Taeon Chapeau", augments={'Spell interruption rate down -7%'}}
    gear.taeon_body_phlx  = {name="Taeon Tabard", augments={'Spell interruption rate down -10%','Phalanx +3'}}
    gear.taeon_hands_phlx = {name="Taeon Gloves", augments={'Spell interruption rate down -8%','Phalanx +3'}}
    gear.taeon_legs_phlx  = {name="Taeon Tights", augments={'Phalanx +3'}}
    gear.taeon_feet_phlx  = {name="Taeon Boots", augments={'Spell interruption rate down -9%','Phalanx +3'}}
    gear.herc_head_ma  = {name="Herculean Helm",
        augments={'"Mag.Atk.Bns."+23','Mag. Acc.+16','Accuracy+2 Attack+2','Mag. Acc.+12 "Mag.Atk.Bns."+12'}}
    gear.herc_hands_ma = {name="Herculean Gloves",
        augments={'Mag. Acc.+18 "Mag.Atk.Bns."+18','Magic burst dmg.+3%','Mag. Acc.+12','"Mag.Atk.Bns."+10'}}
    gear.herc_legs_ma  = {name="Herculean Trousers",
        augments={'Mag. Acc.+20 "Mag.Atk.Bns."+20','"Fast Cast"+2','INT+8','Mag. Acc.+11','"Mag.Atk.Bns."+14'}}
    gear.herc_feet_ma  = {name="Herculean Boots",
        augments={'Mag. Acc.+19 "Mag.Atk.Bns."+19','Enmity-2','MND+4','Mag. Acc.+4','"Mag.Atk.Bns."+15'}}
    gear.herc_head_wsd = {name="Herculean Helm",
        augments={'"Cure" spellcasting time -10%','Pet: INT+6','Weapon skill damage +9%'}}
    gear.herc_hands_ta = {name="Herculean Gloves", augments={'Accuracy+24 Attack+24','"Triple Atk."+2','AGI+4','Accuracy+13','Attack+14'}}
    gear.herc_feet_ta  = {name="Herculean Boots", augments={'Rng.Acc.+4','"Triple Atk."+4','Accuracy+14','Attack+12'}}
    gear.herc_head_rf = {name="Herculean Helm",
        augments={'Accuracy+17','DEX+6','"Refresh"+2','Accuracy+16 Attack+16','Mag. Acc.+20 "Mag.Atk.Bns."+20'}}
    gear.herc_hands_dt = {name="Herculean Gloves", augments={'Attack+27','Damage taken-4%','DEX+5','Accuracy+9'}}
    gear.herc_legs_th  = {name="Herculean Trousers",
        augments={'Attack+3','"Cure" spellcasting time -2%','"Treasure Hunter"+2','Accuracy+1 Attack+1'}}
    gear.Lstikini = {name="Stikini Ring +1", bag="wardrobe2"}
    gear.Rstikini = {name="Stikini Ring +1", bag="wardrobe3"}

    -- High HP items get tagged with priorities
    hpgear = {}
    hpgear["Epeolatry"]               = {name="Epeolatry",priority=900}
    hpgear["Lionheart"]               = {name="Lionheart",priority=900}
    hpgear["Hepatizon Axe"]           = {name="Hepatizon Axe",priority=900}
    hpgear["Kaja Chopper"]            = {name="Kaja Chopper",priority=900}
    hpgear["Adhemar Jacket"]          = {name="Adhemar Jacket",priority=143}
    hpgear["Aqreaqa Bomblet"]         = {name="Aqreaqa Bomblet",priority=20}
    hpgear["Ashera Harness"]          = {name="Ashera Harness",priority=182}
    hpgear["Balarama Grip"]           = {name="Balarama Grip",priority=50}
    hpgear["Carmine Cuisses +1"]      = {name="Carmine Cuisses +1",priority=130}
    hpgear["Carmine Greaves +1"]      = {name="Carmine Greaves +1",priority=95}
    hpgear["Cryptic Earring"]         = {name="Cryptic Earring",priority=40}
    hpgear["Eabani Earring"]          = {name="Eabani Earring",priority=45}
    hpgear["Eihwaz Ring"]             = {name="Eihwaz Ring",priority=70}
    hpgear["Emet Harness +1"]         = {name="Emet Harness +1",priority=61}
    hpgear["Erilaz Galea +1"]         = {name="Erilaz Galea +1",priority=91}
    hpgear["Erilaz Leg Guards +1"]    = {name="Erilaz Leg Guards +1",priority=80}
    hpgear["Erilaz Surcoat +1"]       = {name="Erilaz Surcoat +1",priority=123}
    hpgear["Etana Ring"]              = {name="Etana Ring",priority=60}
    hpgear["Ethereal Earring"]        = {name="Ethereal Earring",priority=15}
    hpgear["Etiolation Earring"]      = {name="Etiolation Earring",priority=50}
    hpgear["Futhark Bandeau +3"]      = {name="Futhark Bandeau +3",priority=56}
    hpgear["Futhark Coat +3"]         = {name="Futhark Coat +3",priority=119}
    hpgear["Futhark Mitons +3"]       = {name="Futhark Mitons +3",priority=45}
    hpgear["Futhark Torque +2"]       = {name="Futhark Torque +2",priority=60}
    hpgear["Futhark Trousers +3"]     = {name="Futhark Trousers +3",priority=107}
    hpgear["Halitus Helm"]            = {name="Halitus Helm",priority=88}
    hpgear["Ilabrat Ring"]            = {name="Ilabrat Ring",priority=60}
    hpgear["Moonbeam Cape"]           = {name="Moonbeam Cape",priority=250}
    hpgear["Moonlight Ring"]          = {name="Moonlight Ring",priority=110}
    hpgear["Odnowa Earring +1"]       = {name="Odnowa Earring +1",priority=100}
    hpgear["Oneiros Belt"]            = {name="Oneiros Belt",priority=55}
    hpgear["Rawhide Gloves"]          = {name="Rawhide Gloves",priority=75}
    hpgear["Regal Ring"]              = {name="Regal Ring",priority=50}
    hpgear["Runeist's Bandeau +3"]    = {name="Runeist's Bandeau +3",priority=109}
    hpgear["Runeist's Boots +3"]      = {name="Runeist's Boots +3",priority=74}
    hpgear["Runeist's Coat +3"]       = {name="Runeist's Coat +3",priority=218}
    hpgear["Runeist's Mitons +3"]     = {name="Runeist's Mitons +3",priority=85}
    hpgear["Runeist Trousers +1"]     = {name="Runeist Trousers +1",priority=47}
    hpgear["Sanctity Necklace"]       = {name="Sanctity Necklace",priority=35}
    hpgear["Skaoi Boots"]             = {name="Skaoi Boots",priority=65}
    hpgear["Supershear Ring"]         = {name="Supershear Ring",priority=30}
    hpgear["Turms Cap +1"]            = {name="Turms Cap +1",priority=94}
    hpgear["Turms Leggings +1"]       = {name="Turms Leggings +1",priority=76}
    hpgear["Turms Mittens +1"]        = {name="Turms Mittens +1",priority=74}
    hpgear["Utu Grip"]                = {name="Utu Grip",priority=70}
    hpgear["Volte Cap"]               = {name="Volte Cap",priority=57}

    -- have typos to hpgear[] keys return an invalid item so //gs validate catches the issue
    setmetatable(hpgear, {__index = function(t, k)
        if rawget(t, k) == nil then return k
        else return rawget(t, k)
        end
    end})

    -- Binds
    send_command('unbind ^=')
    send_command('unbind ^F9')
    send_command('unbind ^F10')
    send_command('unbind ^F11')
    send_command('unbind ^F12')
    send_command('bind F9   gs c cycle OffenseMode')
    send_command('bind @F9  gs c cycle WeaponskillMode')
    send_command('bind !F9  gs c reset OffenseMode')
    send_command('bind F10  gs c cycle CastingMode')
    send_command('bind !F10 gs c reset CastingMode')
    send_command('bind F11  gs c cycle IdleMode')
    send_command('bind !F11 gs c reset IdleMode')
    send_command('bind @F11 gs c toggle Kiting')
    send_command('bind !F12 gs c toggle THtag')
    send_command('bind ^space  gs c cycle HybridMode')
    send_command('bind ^@space gs c reset HybridMode')
    send_command('bind !space gs c set DefenseMode Physical')
    send_command('bind @space gs c set DefenseMode Magical')
    send_command('bind !@space gs c reset DefenseMode')
    send_command('bind !- gs c cycleback CombatWeapon')
    send_command('bind != gs c cycle     CombatWeapon')
    send_command('bind @F1 gs c set CombatWeapon Epeo')
    send_command('bind @F2 gs c set CombatWeapon EpeoRef')
    send_command('bind @F3 gs c set CombatWeapon Lionheart')
    send_command('bind @F4 gs c set CombatWeapon GreatAxe')
    send_command('bind @F5 gs c set CombatWeapon Axe')
    send_command('bind @F6 gs c set CombatWeapon Sword')
    send_command('bind !` gs c toggle OFAhp')
    send_command('bind ^z gs c set HybridMode PDef2')
    send_command('bind !z gs c cycle PhysicalDefenseMode')
    send_command('bind @z gs c cycle MagicalDefenseMode')
    send_command('bind !@z gs c set  MagicalDefenseMode MDT50')
    send_command('bind !c  gs c toggle SIRD')
    send_command('bind ^c  gs c set CastingMode Tank')
    send_command('bind !^c gs c set CastingMode Paranoid')
    send_command('bind !@c gs c reset CastingMode')

    send_command('bind ^@- gs equip defense.HPdown')
    send_command('bind ^@= gs equip defense.HPup')

    info.weapon_type = {['Epeo']='Great Sword',['EpeoRef']='Great Sword',['Lionheart']='Great Sword',
                        ['Sword']='Sword',['Axe']='Axe',['GreatAxe']='Great Axe',['Hepatizon']='Great Axe'}
    info.ws_binds = {
        ['Great Sword']={
        [1]={bind='!^1',ws='"Herculean Slash"'},
        [2]={bind='!^2',ws='"Resolution"'},
        [3]={bind='!^3',ws='"Dimidiation"'},
        [4]={bind='!^4',ws='"Ground Strike"'},
        [5]={bind='!^5',ws='"Power Slash"'},
        [6]={bind='!^6',ws='"Shockwave"'}},
        ['Sword']={
        [1]={bind='!^1',ws='"Sanguine Blade"'},
        [2]={bind='!^2',ws='"Requiescat"'},
        [3]={bind='!^3',ws='"Savage Blade"'},
        [4]={bind='!^4',ws='"Flat Blade"'},
        [5]={bind='!^5',ws='"Swift Blade"'},
        [6]={bind='!^6',ws='"Circle Blade"'}},
        ['Great Axe']={
        [1]={bind='!^1',ws='"Armor Break"'},
        [2]={bind='!^2',ws='"Upheaval"'},
        [3]={bind='!^3',ws='"Steel Cyclone"'},
        [4]={bind='!^4',ws='"Weapon Break"'},
        [5]={bind='!^5',ws='"Shield Break"'},
        [6]={bind='!^6',ws='"Fell Cleave"'}},
        ['Axe']={
        [1]={bind='!^1',ws='"Bora Axe"'},
        [2]={bind='!^2',ws='"Decimation"'},
        [3]={bind='!^3',ws='"Ruinator"'},
        [4]={bind='!^4',ws='"Smash Axe"'},
        [5]={bind='!^5',ws='"Rampage"'}}}
    set_weaponskill_keybinds()

    send_command('bind !7 gs c set StatusDefenseMode Knockback')
    send_command('bind !8 gs c set StatusDefenseMode Charm')
    send_command('bind !9 gs c set StatusDefenseMode Death')
    send_command('bind !0 gs c reset StatusDefenseMode')

    send_command('bind !^` input /ja "Elemental Sforzo" <me>')  -- (1800/7200)
    send_command('bind !@` input /ja "Odyllic Subterfuge"')
    send_command('bind ^@` input /ja "One for All" <me>')       -- (160/320 per)
    send_command('bind @tab input /ja Liement <me>')            -- (450/900 per)
    send_command('bind ^@tab input /ja Battuta <me>')           -- (450/900)
    send_command('bind @q input /ja "Vivacious Pulse" <me>')
    send_command('bind ^@q input /ja Embolden <me>')            -- (160/320)
    send_command('bind ^tab input /ja Vallation <me>')          -- (450/900)
    send_command('bind ^` input /ja Valiance <me>')             -- (450/900 per)
    send_command('bind @` input /ja Pflug <me>')                -- (450/900)
    send_command('bind !^q cancel Foil,Valiance,Vallation,Fast Cast,Liement,Pflug') -- for vinipata

    send_command('bind ^4 input /ja Gambit')                    -- (640/1280)
    send_command('bind ^5 input /ja Rayke')                     -- (640/1260)
    send_command('bind ^6 input /ja Swipe')
    send_command('bind ^7 input /ja Lunge')

    send_command('bind @1 input /ja Ignis <me>')    -- fire up,    ice down
    send_command('bind @2 input /ja Gelus <me>')    -- ice up,     wind down
    send_command('bind @3 input /ja Flabra <me>')   -- wind up,    earth down
    send_command('bind @4 input /ja Tellus <me>')   -- earth up,   thunder down
    send_command('bind @5 input /ja Sulpor <me>')   -- thunder up, water down
    send_command('bind @6 input /ja Unda <me>')     -- water up,   fire down
    send_command('bind @7 input /ja Lux <me>')      -- light up,   dark down
    send_command('bind @8 input /ja Tenebrae <me>') -- dark up,    light down

    send_command('bind ^@1 input /ja Barfire <me>')
    send_command('bind ^@2 input /ja Barblizzard <me>')
    send_command('bind ^@3 input /ja Baraero <me>')
    send_command('bind ^@4 input /ja Barstone <me>')
    send_command('bind ^@5 input /ja Barthunder <me>')
    send_command('bind ^@6 input /ja Barwater <me>')

    send_command('bind !@1 input /ja Baramnesia <me>')
    send_command('bind !@2 input /ja Barparalyze <me>')
    send_command('bind !@3 input /ja Barsilence <me>')
    send_command('bind !@4 input /ja Barpetrify <me>')
    send_command('bind !@5 input /ja Barvirus <me>')
    send_command('bind !@6 input /ja Barpoison <me>')
    send_command('bind !@7 input /ja Barsleep <me>')
    send_command('bind !@8 input /ja Barblind <me>')

    send_command('bind !1 input /ma Flash')             -- (180/1280)
    send_command('bind !2 input /ma Flash <stnpc>')     -- (180/1280)
    send_command('bind !3 input /ja Swordplay <me>')    -- (160/320)
    send_command('bind !d input /ma Foil <me>')         -- (320/880)
    send_command('bind !@d input /ma Foil <me>')
    send_command('bind @d cancel Foil')

    send_command('bind !f input /ma Refresh <me>')
    send_command('bind @f input /ma Crusade <me>')      -- enm+30
    send_command('bind !g input /ma Phalanx <me>')
    send_command('bind @g gs equip PhalanxIncoming')
    send_command('bind !@g input /ma Stoneskin <me>')
    send_command('bind @c input /ma Blink <me>')
    send_command('bind @v input /ma Aquaveil <me>')
    send_command('bind !b input /ma Temper <me>')

    send_command('bind !w  gs c reset OffenseMode')
    send_command('bind !@w gs c set   OffenseMode None')
    send_command('bind ^\\\\ gs c toggle WSMsg')
    send_command('bind ^@\\\\ gs c ListWS')

    if     player.sub_job == 'DRK' then
        send_command('bind ^1 input /ma Stun')                          -- (180/1280)
        send_command('bind ^2 input /ma Stun <stnpc>')                  -- (180/1280)
        send_command('bind ^3 input /ma Poisonga')                      -- (1/320)
        send_command('bind ^@3 input /ma Poisonga <stnpc>')
        send_command('bind !^d input /ja "Weapon Bash"')                -- (1/900)
        send_command('bind !4 input /ja "Last Resort" <me>')            -- (1/1300)
        send_command('bind !5 input /ja Souleater <me>')                -- (1/1300)
        send_command('bind !6 input /ja "Arcane Circle" <me>')
    elseif player.sub_job == 'WAR' then
        send_command('bind ^1 input /ja Provoke')                       -- (1/1800)
        send_command('bind ^2 input /ja Provoke <stnpc>')               -- (1/1800)
        send_command('bind ^3 input /ja Defender <me>')
        send_command('bind !4 input /ja Berserk <me>')
        send_command('bind !5 input /ja Aggressor <me>')
        send_command('bind !6 input /ja Warcry <me>')                   -- (1/300 per)
    elseif player.sub_job == 'SAM' then
        send_command('bind ^1 input /ja Hasso <me>')
        send_command('bind ^2 input /ja Seigan <me>')
        send_command('bind ^3 input /ja "Third Eye" <me>')
        send_command('bind !4 input /ja Meditate <me>')
        send_command('bind !5 input /ja Sekkanoki <me>')
        send_command('bind !6 input /ja "Warding Circle" <me>')
    elseif player.sub_job == 'NIN' then
        send_command('bind !e input /ma "Utsusemi: Ni" <me>')
        send_command('bind !@e input /ma "Utsusemi: Ichi" <me>')
    elseif player.sub_job == 'DNC' then
        send_command('bind ^1 input /ja "Animated Flourish"')           -- (1/1000-1500)
        send_command('bind ^2 input /ja "Animated Flourish" <stnpc>')   -- (1/1000-1500)
        send_command('bind ^3 input /ja "Reverse Flourish" <me>')
        send_command('bind !4 input /ja "Curing Waltz III" <me>')
        send_command('bind !5 input /ja "Haste Samba" <me>')
        send_command('bind !6 input /ja "Divine Waltz" <me>')
        send_command('bind !^d input /ja "Violent Flourish"')
        send_command('bind !v input /ja "Spectral Jig" <me>')
        send_command('bind !e input /ja "Box Step"')
        send_command('bind !@e input /ja Quickstep')
    elseif player.sub_job == 'BLU' then
        send_command('bind ^1 input /ma "Sheep Song"')                  -- (320/320), 6'
        send_command('bind ^2 input /ma "Geist Wall"')                  -- (320/320), 6'
        send_command('bind ^3 input /ma "Stinking Gas"')                -- (320/320), 6'
        send_command('bind !4 input /ma Cocoon <me>')
        send_command('bind !5 input /ma Refueling <me>')
        -- wild carrot aliased to //wc
        send_command('bind !6 input /ma "Healing Breeze" <me>')
        send_command('bind !e input /ma "Blank Gaze"')                  -- (320/320), 12'
        send_command('bind !@e input /ma Jettatura')                    -- (180/1020), 9'
    end

    update_combat_form()
    select_default_macro_book()
end

-- Called when this job file is unloaded (eg: job change)
function user_unload()
    send_command('unbind ^space')
    send_command('unbind ^@space')
    send_command('unbind !space')
    send_command('unbind @space')
    send_command('unbind !@space')
    send_command('unbind !-')
    send_command('unbind !=')
    send_command('unbind @F1')
    send_command('unbind @F2')
    send_command('unbind @F3')
    send_command('unbind @F4')
    send_command('unbind @F5')
    send_command('unbind @F6')
    send_command('unbind !`')
    send_command('unbind ^z')
    send_command('unbind !z')
    send_command('unbind @z')
    send_command('unbind !@z')
    send_command('unbind ^c')
    send_command('unbind !c')
    send_command('unbind !^c')
    send_command('unbind !@c')

    send_command('unbind ^@-')
    send_command('unbind ^@=')

    send_command('unbind !^`')
    send_command('unbind !@`')
    send_command('unbind ^@`')
    send_command('unbind @tab')
    send_command('unbind ^@tab')
    send_command('unbind @q')
    send_command('unbind ^@q')
    send_command('unbind ^tab')
    send_command('unbind ^`')
    send_command('unbind @`')
    send_command('unbind !^q')

    send_command('unbind ^1')
    send_command('unbind ^2')
    send_command('unbind ^3')
    send_command('unbind ^@3')
    send_command('unbind ^4')
    send_command('unbind ^5')
    send_command('unbind ^6')
    send_command('unbind ^7')

    send_command('unbind !1')
    send_command('unbind !2')
    send_command('unbind !3')
    send_command('unbind !4')
    send_command('unbind !5')
    send_command('unbind !6')

    send_command('unbind !7')
    send_command('unbind !8')
    send_command('unbind !9')
    send_command('unbind !0')

    send_command('unbind @1')
    send_command('unbind @2')
    send_command('unbind @3')
    send_command('unbind @4')
    send_command('unbind @5')
    send_command('unbind @6')
    send_command('unbind @7')
    send_command('unbind @8')

    send_command('unbind ^@1')
    send_command('unbind ^@2')
    send_command('unbind ^@3')
    send_command('unbind ^@4')
    send_command('unbind ^@5')
    send_command('unbind ^@6')

    send_command('unbind !@1')
    send_command('unbind !@2')
    send_command('unbind !@3')
    send_command('unbind !@4')
    send_command('unbind !@5')
    send_command('unbind !@6')
    send_command('unbind !@7')
    send_command('unbind !@8')

    send_command('unbind !d')
    send_command('unbind !@d')
    send_command('unbind @d')
    send_command('unbind !g')
    send_command('unbind !@g')
    send_command('unbind !f')
    send_command('unbind @f')
    send_command('unbind @c')
    send_command('unbind @v')
    send_command('unbind !b')

    send_command('unbind !^1')
    send_command('unbind !^2')
    send_command('unbind !^3')
    send_command('unbind !^4')
    send_command('unbind !^5')
    send_command('unbind !^6')
    send_command('unbind !^d')

    send_command('unbind !w')
    send_command('unbind !@w')
    send_command('unbind ^\\\\')
    send_command('unbind ^@\\\\')

    send_command('unbind !e')
    send_command('unbind !@e')
    send_command('unbind !v')

    destroy_state_text()
end

-- Define sets and vars used by this job file.
function init_gear_sets()

    sets.weapons = {}
    sets.weapons.Epeo        = {main=hpgear["Epeolatry"],sub=hpgear["Utu Grip"]}
    sets.weapons.EpeoRef     = {main=hpgear["Epeolatry"],sub="Refined Grip +1"}
    sets.weapons.Lionheart   = {main=hpgear["Lionheart"],sub=hpgear["Utu Grip"]}
    --sets.weapons.Hepatizon   = {main=hpgear["Hepatizon Axe"],sub=hpgear["Utu Grip"]}    -- for full break
    sets.weapons.GreatAxe    = {main=hpgear["Kaja Chopper"],sub=hpgear["Utu Grip"]}
    sets.weapons.DualSword   = {main="Naegling",sub="Reikiko"}
    sets.weapons.DualAxe     = {main="Kaja Axe",sub="Reikiko"}
    sets.weapons.SingleSword = {main="Naegling",sub=empty}
    sets.weapons.SingleAxe   = {main="Kaja Axe",sub=empty}
    if S{'DNC','NIN'}:contains(player.sub_job) then
        sets.weapons.Sword = set_combine(sets.weapons.DualSword, {})
        sets.weapons.Axe   = set_combine(sets.weapons.DualAxe, {})
    else
        sets.weapons.Sword = set_combine(sets.weapons.SingleSword, {})
        sets.weapons.Axe   = set_combine(sets.weapons.SingleAxe, {})
    end

    -- Precast Sets
    sets.Enmity = {main=hpgear["Epeolatry"],sub=hpgear["Balarama Grip"],ammo=hpgear["Aqreaqa Bomblet"],
        head=hpgear["Halitus Helm"],neck=hpgear["Futhark Torque +2"],ear1=hpgear["Cryptic Earring"],ear2="Trux Earring",
        body=hpgear["Emet Harness +1"],hands="Kurys Gloves",ring1=hpgear["Eihwaz Ring"],ring2=hpgear["Supershear Ring"],
        back=gear.MEVACape,waist=hpgear["Oneiros Belt"],legs=hpgear["Erilaz Leg Guards +1"],feet="Erilaz Greaves +1"}
    -- enm+85, pdt-37, inqu+5, mdt-9,  mdb+20, bdt-9,  meva+463, 2696 hp /drk
    sets.Enmity.Tank = set_combine(sets.Enmity, {ring2="Defending Ring"})
    -- enm+80, pdt-47, inqu+5, mdt-19, mdb+20, bdt-19, meva+463, 2666 hp /drk
    sets.Enmity.Paranoid = set_combine(sets.Enmity, {sub="Refined Grip +1",ammo="Staunch Tathlum +1",ring2="Defending Ring"})
    -- enm+78, pdt-50, inqu+5, mdt-22, mdb+20, bdt-22, meva+463, 2646 hp /drk

    -- combined with and Enmity set in job_precast
    sets.precast.JA.Warcry = {}
    sets.precast.JA.Provoke = {}
    sets.precast.JA.Souleater = {}
    sets.precast.JA['Last Resort'] = {}
    sets.precast.JA['Elemental Sforzo'] = {body=hpgear["Futhark Coat +3"]}
    sets.precast.JA['Odyllic Subterfuge'] = {}
    sets.precast.JA['One for All'] = {}
    sets.precast.JA['One for All'].hp = set_combine(sets.precast.JA['One for All'], {
        body=hpgear["Runeist's Coat +3"],back=hpgear["Moonbeam Cape"]})
    sets.precast.JA.Vallation = {
        body=hpgear["Runeist's Coat +3"],back=gear.MEVACape,legs=hpgear["Futhark Trousers +3"]}
    sets.precast.JA.Valiance = sets.precast.JA.Vallation
    sets.precast.JA.Liement = {}
    sets.precast.JA.Liement.dur = {body=hpgear["Futhark Coat +3"]}
    sets.precast.JA.Battuta = {head=hpgear["Futhark Bandeau +3"]}
    sets.precast.JA.Pflug = {feet=hpgear["Runeist's Boots +3"]}
    sets.precast.JA.Swordplay = {hands=hpgear["Futhark Mitons +3"]}
    sets.precast.JA.Gambit = {hands=hpgear["Runeist's Mitons +3"]}
    sets.precast.JA.Rayke = {feet="Futhark Boots"}

    sets.precast.JA['Vivacious Pulse'] = {main=hpgear["Epeolatry"],sub=hpgear["Utu Grip"],ammo="Staunch Tathlum +1",
        head=hpgear["Erilaz Galea +1"],neck=hpgear["Futhark Torque +2"],ear1=hpgear["Cryptic Earring"],ear2=hpgear["Etiolation Earring"],
        body=hpgear["Futhark Coat +3"],hands="Kurys Gloves",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.MEVACape,waist=hpgear["Oneiros Belt"],legs=hpgear["Runeist Trousers +1"],feet="Erilaz Greaves +1"}
    -- pdt-50, mdt-42, bdt-39, 2654 hp /drk

    sets.precast.JA.Lunge = {main=hpgear["Epeolatry"],sub="Niobid Strap",ammo="Seething Bomblet +1",
        head=gear.herc_head_ma,neck=hpgear["Sanctity Necklace"],ear1="Friomisi Earring",ear2="Hecate's Earring",
        body="Samnuha Coat",hands="Carmine Finger Gauntlets +1",ring1="Mujin Band",ring2="Locus Ring",
        back="Izdubar Mantle",waist="Eschan Stone",legs=gear.herc_legs_ma,feet=gear.herc_feet_ma}
    sets.precast.JA.Swipe = sets.precast.JA.Lunge
    sets.DarkDmg = {head="Pixie Hairpin +1",ring2="Archon Ring"}

    sets.precast.Step = {ammo="Yamarang",
        head=hpgear["Runeist's Bandeau +3"],neck="Combatant's Torque",ear1="Odr Earring",ear2="Telos Earring",
        body=hpgear["Runeist's Coat +3"],hands=hpgear["Runeist's Mitons +3"],ring1=hpgear["Moonlight Ring"],ring2=hpgear["Regal Ring"],
        back=gear.TPCape,waist="Grunfeld Rope",legs="Ayanmo Cosciales +2",feet=hpgear["Runeist's Boots +3"]}
    sets.precast.JA['Violent Flourish'] = {ammo="Yamarang",
        head=hpgear["Runeist's Bandeau +3"],neck=hpgear["Sanctity Necklace"],ear1="Dignitary's Earring",ear2="Telos Earring",
        body=hpgear["Runeist's Coat +3"],hands="Ayanmo Manopolas +2",ring1=hpgear["Etana Ring"],ring2=hpgear["Regal Ring"],
        back=gear.TPCape,waist="Eschan Stone",legs="Ayanmo Cosciales +2",feet="Ayanmo Gambieras +2"}
    sets.precast.JA['Weapon Bash'] = set_combine(sets.precast.JA['Violent Flourish'], {back=hpgear["Moonbeam Cape"]})

    sets.precast.WS = {ammo="Knobkierrie",
        head="Adhemar Bonnet +1",neck=gear.ElementalGorget,ear1="Sherida Earring",ear2="Moonshade Earring",
        body="Ayanmo Corazza +2",hands="Adhemar Wristbands +1",ring1=hpgear["Regal Ring"],ring2="Niqmaddu Ring",
        back=gear.ResoCape,waist=gear.ElementalBelt,legs="Meghanada Chausses +2",feet=gear.herc_feet_ta}
    sets.precast.WS.Acc = set_combine(sets.precast.WS, {ammo="Yamarang",back=gear.TPCape})
    sets.precast.WS.Tank = set_combine(sets.precast.WS, {ammo="Yamarang",
        head=hpgear["Runeist's Bandeau +3"],neck=hpgear["Futhark Torque +2"],
        body=hpgear["Ashera Harness"],ring1=hpgear["Moonlight Ring"],ring2="Defending Ring"})
    sets.precast.WS.Resolution = set_combine(sets.precast.WS, {ammo="Seething Bomblet +1",body="Adhemar Jacket +1"})
    sets.precast.WS.Resolution.Tank = set_combine(sets.precast.WS.Resolution, {
        head=hpgear["Runeist's Bandeau +3"],ring1=hpgear["Moonlight Ring"],ring2=hpgear["Regal Ring"]})
    sets.precast.WS.Resolution.Acc = set_combine(sets.precast.WS.Acc, {})
    sets.precast.WS.Decimation = set_combine(sets.precast.WS.Resolution, {})
    sets.precast.WS.Ruinator = set_combine(sets.precast.WS.Resolution, {})

    sets.precast.WS.OneHit = set_combine(sets.precast.WS, {
        head=gear.herc_head_wsd,hands="Meghanada Gloves +2",ring1=hpgear["Regal Ring"],ring2="Niqmaddu Ring",
        back=gear.DimiCape,feet="Meghanada Jambeaux +2"})
    sets.precast.WS.Dimidiation = set_combine(sets.precast.WS.OneHit, {legs="Lustratio Subligar +1",feet="Lustratio Leggings +1"})
    sets.precast.WS.Dimidiation.Tank = set_combine(sets.precast.WS.Dimidiation, {
        body=hpgear["Ashera Harness"],ring1=hpgear["Moonlight Ring"],ring2="Defending Ring"})
    sets.precast.WS.Dimidiation.Acc = set_combine(sets.precast.WS.Dimidiation, {head="Meghanada Visor +2",feet="Meghanada Jambeaux +2"})
    sets.precast.WS['Steel Cyclone'] = set_combine(sets.precast.WS.OneHit, {})
    sets.precast.WS['Fell Cleave']   = set_combine(sets.precast.WS.OneHit, {ring1="Vocane Ring +1",ring2="Defending Ring"})
    sets.precast.WS['Ground Strike'] = set_combine(sets.precast.WS.OneHit, {})
    sets.precast.WS['Savage Blade']  = set_combine(sets.precast.WS.OneHit, {neck=hpgear["Futhark Torque +2"],waist="Grunfeld Rope"})
    sets.precast.WS['Bora Axe'] = set_combine(sets.precast.WS.Dimidiation, {})

    sets.precast.WS.Crit = set_combine(sets.precast.WS, {ammo="Yetshila +1",ear2="Odr Earring",feet="Ayanmo Gambieras +2"})
    sets.precast.WS['Vorpal Blade'] = set_combine(sets.precast.WS.Crit, {})
    sets.precast.WS.Rampage = set_combine(sets.precast.WS.Crit, {})

    sets.precast.WS.Magical = set_combine(sets.precast.JA.Lunge, {ear2="Hermetic Earring",
        ring1=hpgear["Regal Ring"],ring2="Acumen Ring",waist=gear.ElementalObi})
    sets.precast.WS['Sanguine Blade'] = set_combine(sets.precast.WS.Magical, sets.DarkDmg)

    sets.precast.WS.AddEffect = {ammo="Yamarang",
        head="Ayanmo Zucchetto +2",neck=hpgear["Sanctity Necklace"],ear1="Dignitary's Earring",ear2="Moonshade Earring",
        body="Ayanmo Corazza +2",hands="Ayanmo Manopolas +2",ring1=hpgear["Moonlight Ring"],ring2=hpgear["Etana Ring"],
        back=gear.TPCape,waist="Eschan Stone",legs="Ayanmo Cosciales +2",feet="Ayanmo Gambieras +2"}
    sets.precast.WS.Shockwave = {ammo="Yamarang",
        head=hpgear["Runeist's Bandeau +3"],neck=hpgear["Futhark Torque +2"],ear1="Dignitary's Earring",ear2="Moonshade Earring",
        body=hpgear["Ashera Harness"],hands="Ayanmo Manopolas +2",ring1=hpgear["Moonlight Ring"],ring2="Defending Ring",
        back=gear.DimiCape,waist="Eschan Stone",legs="Ayanmo Cosciales +2",feet="Ayanmo Gambieras +2"}
    sets.precast.WS['Herculean Slash'] = set_combine(sets.precast.WS.AddEffect, {})
    sets.precast.WS['Full Break']      = set_combine(sets.precast.WS.AddEffect, {})
    sets.precast.WS['Shield Break']    = set_combine(sets.precast.WS.AddEffect, {})
    sets.precast.WS['Armor Break']     = set_combine(sets.precast.WS.AddEffect, {})
    sets.precast.WS['Weapon Break']    = set_combine(sets.precast.WS.AddEffect, {})
    sets.precast.WS['Flat Blade']      = set_combine(sets.precast.WS.AddEffect, {})
    sets.precast.WS['Smash Axe']      = set_combine(sets.precast.WS.AddEffect, {})

    sets.precast.RA = {ammo=empty}
    sets.precast.FC = {main=hpgear["Epeolatry"],sub=hpgear["Utu Grip"],ammo="Sapience Orb",
        head=hpgear["Runeist's Bandeau +3"],neck="Orunmila's Torque",ear1="Loquacious Earring",ear2=hpgear["Etiolation Earring"],
        body=hpgear["Adhemar Jacket"],hands="Leyline Gloves",ring1=hpgear["Moonlight Ring"],ring2="Kishar Ring",
        back=gear.FCCape,waist=hpgear["Oneiros Belt"],legs="Ayanmo Cosciales +2",feet=hpgear["Carmine Greaves +1"]}
    -- fc+67 (+36 val), 2801 hp /drk
    sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {waist="Siegel Sash",legs=hpgear["Futhark Trousers +3"]})
    -- fc+80 (+36 val), 2808 hp /drk
    sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {neck="Magoraga Beads"})
    -- fc+72 (+36 val), 2801 hp /drk

    -- Midcast Sets
    sets.SIRD = {main=hpgear["Epeolatry"],sub="Refined Grip +1",ammo="Staunch Tathlum +1",
        head=gear.taeon_head_sird,neck="Moonlight Necklace",ear1=hpgear["Cryptic Earring"],ear2="Halasz Earring",
        body=gear.taeon_body_phlx,hands=hpgear["Rawhide Gloves"],ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.MEVACape,waist="Rumination Sash",legs=hpgear["Carmine Cuisses +1"],feet=gear.taeon_feet_phlx}
    -- sir-102, pdt-31, mdt-21, bdt-21, enm+26, 2502 hp /drk
    sets.SIRD.Choral = {main=hpgear["Epeolatry"],sub="Refined Grip +1",ammo="Staunch Tathlum +1",
        head=hpgear["Futhark Bandeau +3"],neck="Moonlight Necklace",ear1=hpgear["Odnowa Earring +1"],ear2=hpgear["Etiolation Earring"],
        body=hpgear["Futhark Coat +3"],hands=gear.herc_hands_dt,ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.MEVACape,waist="Rumination Sash",legs=hpgear["Carmine Cuisses +1"],feet="Erilaz Greaves +1"}
    -- sir-56, pdt-50, mdt-39, bdt-34, enm+31, 2652 hp /drk

    sets.midcast['Enhancing Magic'] = {main=hpgear["Epeolatry"],sub="Refined Grip +1",ammo="Staunch Tathlum +1",
        head=hpgear["Erilaz Galea +1"],neck="Incanter's Torque",ear1="Andoaa Earring",ear2="Mimir Earring",
        body=hpgear["Futhark Coat +3"],hands=hpgear["Runeist's Mitons +3"],ring1=gear.Lstikini,ring2=gear.Rstikini,
        back=gear.MEVACape,waist="Olympus Sash",legs=hpgear["Carmine Cuisses +1"],feet="Erilaz Greaves +1"}
    sets.midcast.Temper = set_combine(sets.midcast['Enhancing Magic'], {})
    -- skill=523, dur+35, pdt-16, mdt-5, bdt-5, 2592 hp /drk
    sets.midcast.Phalanx = {main="Deacon Sword",sub=empty,ammo="Staunch Tathlum +1",
        head=hpgear["Futhark Bandeau +3"],neck=hpgear["Futhark Torque +2"],ear1=hpgear["Odnowa Earring +1"],ear2="Mimir Earring",
        body=gear.taeon_body_phlx,hands=gear.taeon_hands_phlx,ring1=hpgear["Moonlight Ring"],ring2="Defending Ring",
        back=gear.MEVACape,waist="Flume Belt +1",legs=gear.taeon_legs_phlx,feet=gear.taeon_feet_phlx}
    -- phalanx+17~21, skill=450, dur+0, pdt-45, mdt-25, bdt-25, 2629 hp /drk (tiers at 443, 472, 500 skill)
    sets.midcast.Phalanx.Paranoid = {main=hpgear["Epeolatry"],sub=hpgear["Utu Grip"],ammo="Staunch Tathlum +1",
        head=hpgear["Futhark Bandeau +3"],neck=hpgear["Futhark Torque +2"],ear1=hpgear["Odnowa Earring +1"],ear2=hpgear["Etiolation Earring"],
        body=hpgear["Futhark Coat +3"],hands=gear.taeon_hands_phlx,ring1=hpgear["Moonlight Ring"],ring2="Defending Ring",
        back=gear.MEVACape,waist="Flume Belt +1",legs=gear.taeon_legs_phlx,feet=gear.taeon_feet_phlx}
    -- phalanx+16, skill=440, dur+0, pdt-50, mdt-39, bdt-34, 2739 hp /drk
    sets.PhalanxIncoming = {main="Deacon Sword",sub=empty,ammo="Staunch Tathlum +1",
        head=hpgear["Futhark Bandeau +3"],neck=hpgear["Futhark Torque +2"],ear1=hpgear["Odnowa Earring +1"],ear2=hpgear["Etiolation Earring"],
        body=gear.taeon_body_phlx,hands=gear.taeon_hands_phlx,ring1="Vocane Ring +1",ring2="Defending Ring",
        back="Evasionist's Cape",waist="Flume Belt +1",legs=gear.taeon_legs_phlx,feet=gear.taeon_feet_phlx}

    sets.midcast.FixedPotencyEnhancing = {main=hpgear["Epeolatry"],sub=hpgear["Utu Grip"],ammo="Staunch Tathlum +1",
        head=hpgear["Erilaz Galea +1"],neck=hpgear["Futhark Torque +2"],ear1=hpgear["Odnowa Earring +1"],ear2=hpgear["Etiolation Earring"],
        body=hpgear["Ashera Harness"],hands=gear.herc_hands_dt,ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.MEVACape,waist="Engraved Belt",legs=hpgear["Futhark Trousers +3"],feet=hpgear["Turms Leggings +1"]}
    sets.midcast.Refresh = set_combine(sets.midcast.FixedPotencyEnhancing, {waist="Gishdubar Sash"})
    sets.midcast['Regen IV'] = set_combine(sets.midcast.FixedPotencyEnhancing, {head=hpgear["Runeist's Bandeau +3"]})
    sets.midcast.Blink = {} -- or duration gear?
    sets.midcast.Stoneskin = {}

    sets.midcast['Enfeebling Magic'] = {main=hpgear["Epeolatry"],sub="Kaja Grip",ammo="Yamarang",
        head="Ayanmo Zucchetto +2",neck="Erra Pendant",ear1="Dignitary's Earring",ear2="Gwati Earring",
        body="Ayanmo Corazza +2",hands="Ayanmo Manopolas +2",ring1=gear.Lstikini,ring2=gear.Rstikini,
        back="Izdubar Mantle",waist="Luminary Sash",legs="Ayanmo Cosciales +2",feet="Ayanmo Gambieras +2"}
    sets.midcast.Poisonga = {}
    sets.midcast.Poisonga.TH = {main=hpgear["Epeolatry"],sub=hpgear["Utu Grip"],ammo="Staunch Tathlum +1",
        head=hpgear["Volte Cap"],neck=hpgear["Futhark Torque +2"],ear1=hpgear["Odnowa Earring +1"],ear2=hpgear["Etiolation Earring"],
        body=hpgear["Futhark Coat +3"],hands=hpgear["Turms Mittens +1"],ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.MEVACape,waist="Chaac Belt",legs=gear.herc_legs_th,feet=hpgear["Turms Leggings +1"]}
    sets.midcast.Repose = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast.Utsusemi = {}
    sets.midcast['Blue Magic'] = {}

    sets.midcast.Foil            = set_combine(sets.Enmity, {})
    sets.midcast.Flash           = set_combine(sets.Enmity, {})
    sets.midcast.Stun            = set_combine(sets.Enmity, {})
    sets.midcast['Stinking Gas'] = set_combine(sets.Enmity, {})
    sets.midcast['Sheep Song']   = set_combine(sets.Enmity, {})
    sets.midcast['Geist Wall']   = set_combine(sets.Enmity, {})
    sets.midcast['Blank Gaze']   = set_combine(sets.Enmity, {})
    sets.midcast.Soporific       = set_combine(sets.Enmity, {})
    sets.midcast.Jettatura       = set_combine(sets.Enmity, {})

    sets.midcast.Foil.Tank            = set_combine(sets.Enmity.Tank, {})
    sets.midcast.Flash.Tank           = set_combine(sets.Enmity.Tank, {})
    sets.midcast.Stun.Tank            = set_combine(sets.Enmity.Tank, {})
    sets.midcast['Stinking Gas'].Tank = set_combine(sets.Enmity.Tank, {})
    sets.midcast['Sheep Song'].Tank   = set_combine(sets.Enmity.Tank, {})
    sets.midcast['Geist Wall'].Tank   = set_combine(sets.Enmity.Tank, {})
    sets.midcast['Blank Gaze'].Tank   = set_combine(sets.Enmity.Tank, {})
    sets.midcast.Soporific.Tank       = set_combine(sets.Enmity.Tank, {})
    sets.midcast.Jettatura.Tank       = set_combine(sets.Enmity.Tank, {})

    sets.midcast.Foil.Paranoid            = set_combine(sets.Enmity.Paranoid, {})
    sets.midcast.Flash.Paranoid           = set_combine(sets.Enmity.Paranoid, {})
    sets.midcast.Stun.Paranoid            = set_combine(sets.Enmity.Paranoid, {})
    sets.midcast['Stinking Gas'].Paranoid = set_combine(sets.Enmity.Paranoid, {})
    sets.midcast['Sheep Song'].Paranoid   = set_combine(sets.Enmity.Paranoid, {})
    sets.midcast['Geist Wall'].Paranoid   = set_combine(sets.Enmity.Paranoid, {})
    sets.midcast['Blank Gaze'].Paranoid   = set_combine(sets.Enmity.Paranoid, {})
    sets.midcast.Soporific.Paranoid       = set_combine(sets.Enmity.Paranoid, {})
    sets.midcast.Jettatura.Paranoid       = set_combine(sets.Enmity.Paranoid, {})

    sets.midcast.Stun.MAcc          = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast['Sheep Song'].MAcc = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast['Geist Wall'].MAcc = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast['Blank Gaze'].MAcc = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast.Soporific.MAcc     = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast.Jettatura.MAcc     = set_combine(sets.midcast['Enfeebling Magic'], {})

    sets.buff.doom = {neck="Nicander's Necklace",ring1="Saida Ring",ring2="Defending Ring",waist="Gishdubar Sash"}
    sets.buff.doom.PDef = {main=hpgear["Epeolatry"],sub="Refined Grip +1",ammo="Staunch Tathlum +1",
        head=hpgear["Futhark Bandeau +3"],neck="Nicander's Necklace",ear1="Genmei Earring",ear2=hpgear["Etiolation Earring"],
        body=hpgear["Futhark Coat +3"],hands=gear.herc_hands_dt,ring1="Saida Ring",ring2="Defending Ring",
        back=gear.MEVACape,waist="Gishdubar Sash",legs=hpgear["Erilaz Leg Guards +1"],feet=hpgear["Erilaz Greaves +1"]}
    -- pdt-48, inqu+5, mdt-29, mdb+24, bdt-26, meva+469, r.st+11, enm+27, 2487 hp /drk
    sets.buff.Sleep = {head="Frenzy Sallet"}
    sets.buff.Embolden = {back="Evasionist's Cape"}

    -- Idle and tanking sets
    sets.idle = {main=hpgear["Epeolatry"],sub=hpgear["Utu Grip"],ammo="Staunch Tathlum +1",
        head=hpgear["Turms Cap +1"],neck=hpgear["Futhark Torque +2"],ear1=hpgear["Odnowa Earring +1"],ear2=hpgear["Etiolation Earring"],
        body=hpgear["Runeist's Coat +3"],hands=gear.herc_hands_dt,ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.MEVACape,waist="Flume Belt +1",legs=hpgear["Carmine Cuisses +1"],feet="Erilaz Greaves +1"}
    -- pdt-50, mdt-37, mdb+25, bdt-32, meva+557, r.st+11, rf+3, rg+7, 2% mp conv, 2849 hp /drk
    sets.idle.Refresh = {main=hpgear["Epeolatry"],sub="Refined Grip +1",ammo="Homiliary",
        head=gear.herc_head_rf,neck=hpgear["Futhark Torque +2"],ear1=hpgear["Odnowa Earring +1"],ear2=hpgear["Etiolation Earring"],
        body=hpgear["Runeist's Coat +3"],hands=gear.herc_hands_dt,ring1=gear.Lstikini,ring2="Defending Ring",
        back=gear.MEVACape,waist="Flume Belt +1",legs="Rawhide Trousers",feet="Erilaz Greaves +1"}
    -- pdt-42, mdt-26, mdb+22, bdt-21, meva+496, rf+8, 2% mp conv, 2710 hp /drk
    sets.idle.Kite = {main=hpgear["Epeolatry"],sub="Refined Grip +1",ammo="Staunch Tathlum +1",
        head=hpgear["Turms Cap +1"],neck=hpgear["Futhark Torque +2"],ear1=hpgear["Odnowa Earring +1"],ear2=hpgear["Etiolation Earring"],
        body=hpgear["Futhark Coat +3"],hands=hpgear["Turms Mittens +1"],ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.MEVACape,waist="Flume Belt +1",legs=hpgear["Carmine Cuisses +1"],feet=hpgear["Turms Leggings +1"]}
    -- pdt-50, mdt-42, mdb+31, bdt-37, meva+581, r.st+11, rg+23, 2% mp conv, 2862 hp /drk
    sets.latent_refresh = {ammo="Homiliary",waist="Fucho-no-obi"}
    sets.defense.Kite = set_combine(sets.idle.Kite, {})

    sets.defense.Parry = {main=hpgear["Epeolatry"],sub=hpgear["Utu Grip"],ammo="Staunch Tathlum +1",
        head=hpgear["Turms Cap +1"],neck=hpgear["Futhark Torque +2"],ear1=hpgear["Odnowa Earring +1"],ear2=hpgear["Etiolation Earring"],
        body=hpgear["Ashera Harness"],hands=hpgear["Turms Mittens +1"],ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.MEVACape,waist="Engraved Belt",legs=hpgear["Erilaz Leg Guards +1"],feet=hpgear["Turms Leggings +1"]}
    -- pdt-50, inqu+10, mdt-40, mdb+30, bdt-35, meva+640, r.st+11, enm+31, 2875 hp /drk
    sets.defense.ParryAcc = {main=hpgear["Epeolatry"],sub=hpgear["Utu Grip"],ammo="Staunch Tathlum +1",
        head="Ayanmo Zucchetto +2",neck=hpgear["Futhark Torque +2"],ear1=hpgear["Odnowa Earring +1"],ear2=hpgear["Etiolation Earring"],
        body=hpgear["Ashera Harness"],hands=hpgear["Turms Mittens +1"],ring1=hpgear["Moonlight Ring"],ring2="Defending Ring",
        back=gear.TPCape,waist="Sarissaphoroi Belt",legs=hpgear["Erilaz Leg Guards +1"],feet=hpgear["Turms Leggings +1"]}
    -- acc~1231, haste+26, stp+21, da+12, ta+2
    -- pdt-50, inqu+10, mdt-40, mdb+26, bdt-35, meva+534, r.st+11, enm+21, 2876 hp /drk
    sets.defense.ParryRf = {main=hpgear["Epeolatry"],sub=hpgear["Utu Grip"],ammo="Staunch Tathlum +1",
        head=hpgear["Turms Cap +1"],neck=hpgear["Futhark Torque +2"],ear1=hpgear["Odnowa Earring +1"],ear2=hpgear["Ethereal Earring"],
        body=hpgear["Runeist's Coat +3"],hands=hpgear["Turms Mittens +1"],ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.MEVACape,waist="Flume Belt +1",legs=hpgear["Erilaz Leg Guards +1"],feet=hpgear["Turms Leggings +1"]}
    -- pdt-49, inqu+10, mdt-30, mdb+32, bdt-28, meva+657, r.st+11, rf+3, rg+18, 5% mp conv, enm+31, 2876 hp /drk

    sets.defense.HPdown = {main=hpgear["Epeolatry"],sub="Refined Grip +1",ammo="Staunch Tathlum +1",
        head="Ayanmo Zucchetto +2",neck="Loricate Torque +1",ear1="Hearty Earring",ear2="Telos Earring",
        body="Ayanmo Corazza +2",hands="Ayanmo Manopolas +2",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.TPCape,waist="Flume Belt +1",legs="Ayanmo Cosciales +2",feet="Ayanmo Gambieras +2"}
    sets.defense.HPup = {main=hpgear["Epeolatry"],sub=hpgear["Utu Grip"],ammo="Staunch Tathlum +1",
        head=hpgear["Erilaz Galea +1"],neck=hpgear["Futhark Torque +2"],ear1=hpgear["Odnowa Earring +1"],ear2=hpgear["Etiolation Earring"],
        body=hpgear["Ashera Harness"],hands=hpgear["Runeist's Mitons +3"],ring1=hpgear["Moonlight Ring"],ring2="Defending Ring",
        back=hpgear["Moonbeam Cape"],waist=hpgear["Oneiros Belt"],legs=hpgear["Erilaz Leg Guards +1"],feet=hpgear["Turms Leggings +1"]}

    sets.defense.MEVA = {main=hpgear["Epeolatry"],sub="Refined Grip +1",ammo="Yamarang",
        head=hpgear["Turms Cap +1"],neck=hpgear["Futhark Torque +2"],ear1="Eabani Earring",ear2=hpgear["Etiolation Earring"],
        body=hpgear["Runeist's Coat +3"],hands=hpgear["Turms Mittens +1"],ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.MEVACape,waist="Engraved Belt",legs=hpgear["Erilaz Leg Guards +1"],feet=hpgear["Turms Leggings +1"]}
    -- pdt-42, inqu+10, mdt-28, mdb+32, bdt-25, meva+692, enm+31, 2846 hp /drk
    sets.defense.MDT50 = {main=hpgear["Epeolatry"],sub="Refined Grip +1",ammo="Staunch Tathlum +1",
        head="Ayanmo Zucchetto +2",neck=hpgear["Futhark Torque +2"],ear1=hpgear["Odnowa Earring +1"],ear2=hpgear["Etiolation Earring"],
        body=hpgear["Futhark Coat +3"],hands=gear.herc_hands_dt,ring1="Vocane Ring +1",ring2="Defending Ring",
        back=hpgear["Moonbeam Cape"],waist="Engraved Belt",legs=hpgear["Erilaz Leg Guards +1"],feet="Erilaz Greaves +1"}
    -- pdt-50, inqu+7, mdt-50, mdb+24, bdt-49, meva+426, r.st+11, enm+11, 2841 hp /drk

    --sets.defense.Knockback = {ring1="Vocane Ring +1",back="Repulse Mantle",waist="Flume Belt +1"}
    sets.defense.Knockback = {ring1="Vocane Ring +1",back="Repulse Mantle",waist="Flume Belt +1",legs="Dashing Subligar"}
    sets.defense.Charm     = {ammo="Staunch Tathlum +1",neck="Unmoving Collar +1",ear1="Hearty Earring"}
    sets.defense.Death     = {ammo="Staunch Tathlum +1",ear1="Hearty Earring",
        body="Samnuha Coat",ring1=hpgear["Eihwaz Ring"],ring2="Shadow Ring"}
    sets.Kiting = {legs=hpgear["Carmine Cuisses +1"]}

    -- Engaged (DD) sets
    sets.engaged = {main=hpgear["Epeolatry"],sub="Utu Grip",ammo="Yamarang",
        head="Adhemar Bonnet +1",neck="Anu Torque",ear1="Sherida Earring",ear2="Telos Earring",
        body="Adhemar Jacket +1",hands="Adhemar Wristbands +1",ring1="Epona's Ring",ring2="Niqmaddu Ring",
        back=gear.TPCape,waist="Windbuffet Belt +1",legs="Samnuha Tights",feet=gear.herc_feet_ta}
    -- acc~1235, haste+26, stp+34, da+22, ta+26, qa+5, pdt-12, inqu+3, mdt-0, mdb+21, bdt-0, meva+336, 2265 hp /drk
    sets.engaged.PDef = set_combine(sets.engaged, {
        head="Ayanmo Zucchetto +2",body=hpgear["Ashera Harness"],ring1=hpgear["Moonlight Ring"],ring2="Defending Ring",
        waist="Sarissaphoroi Belt",legs="Meghanada Chausses +2"})
    -- acc~1270, haste+26, stp+48, da+18, ta+17, pdt-43, inqu+3, mdt-25, mdb+20 bdt-25, meva+351, 2492 hp /drk
    sets.engaged.PDef2 = set_combine(sets.engaged.PDef, {ammo="Staunch Tathlum +1",
        head="Ayanmo Zucchetto +2",hands=gear.herc_hands_dt,feet=hpgear["Turms Leggings +1"]})
    -- acc~1251, haste+25, stp+38, da+18, ta+9, pdt-50, inqu+8, mdt-32, mdb+22 bdt-32, meva+408, r.st+11, 2557 hp /drk

    sets.engaged.DualAxe         = set_combine(sets.engaged,       {ear2="Suppanomimi",waist="Reiki Yotai"})
    sets.engaged.DualSword       = set_combine(sets.engaged,       {ear2="Suppanomimi",waist="Reiki Yotai"})
    sets.engaged.DualAxe.PDef    = set_combine(sets.engaged.PDef,  {ear2="Suppanomimi",waist="Reiki Yotai"})
    sets.engaged.DualSword.PDef  = set_combine(sets.engaged.PDef,  {ear2="Suppanomimi",waist="Reiki Yotai"})
    sets.engaged.DualAxe.PDef2   = set_combine(sets.engaged.PDef2, {ear2="Suppanomimi",waist="Reiki Yotai"})
    sets.engaged.DualSword.PDef2 = set_combine(sets.engaged.PDef2, {ear2="Suppanomimi",waist="Reiki Yotai"})

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
    end
    if spell.type == 'WeaponSkill' then
        state.aeonic_aftermath_precast = (buffactive["Aftermath: Lv.1"] or buffactive["Aftermath: Lv.2"] or buffactive["Aftermath: Lv.3"])
    elseif S{'Ward','Effusion','JobAbility'}:contains(spell.type) then
        if sets.precast.JA[spell.english] then
            eventArgs.handled = true
            if     state.CastingMode.value == 'Tank' then
                equip(sets.Enmity.Tank,     sets.precast.JA[spell.english])
            elseif state.CastingMode.value == 'Paranoid' then
                equip(sets.Enmity.Paranoid, sets.precast.JA[spell.english])
            else
                equip(sets.Enmity,          sets.precast.JA[spell.english])
            end
        end
    elseif spell.type == 'Rune'
    and state.IdleMode.value == 'Kite' and state.DefenseMode.value == 'Kite' and state.CastingMode.value == 'Paranoid' then
        -- try to blink JAs
        equip({head=hpgear["Halitus Helm"]})
    end
end

-- Run after the general precast() is done.
function job_post_precast(spell, action, spellMap, eventArgs)
    if spell.type == 'Effusion' then
        if S{'Swipe','Lunge'}:contains(spell.english) then
            spell.element = triple_rune_string() or ''
            if S{world.day_element,world.weather_element}:contains(spell.element) then
                equip({waist="Hachirin-no-Obi"})
            end
            if buffactive.Tenebrae then
                equip(sets.DarkDmg)
            end
        end
    elseif spell.english == 'One for All' then
        if state.OFAhp.value then
            equip(sets.precast.JA['One for All'].hp)
        end
    end
end

-- Run after the default midcast() is done.
-- eventArgs is the same one used in job_midcast, in case information needs to be persisted.
function job_post_midcast(spell, action, spellMap, eventArgs)
    if spell.action_type == 'Magic' and state.CastingMode.value == 'Paranoid' then
        if sets.midcast[spell.english] and sets.midcast[spell.english].Paranoid then
            equip(sets.midcast[spell.english].Paranoid)
        elseif state.DefenseMode.value ~= 'None' then
            local defMode = state[state.DefenseMode.value ..'DefenseMode'].current
            equip(sets.defense[defMode])
        else
            equip(sets.defense.Parry)
        end
    end
    if state.SIRD.value and info.sird_spells:contains(spell.english) then
        if buffactive['Choral Roll'] then
            equip(sets.SIRD.Choral)
        else
            equip(sets.SIRD)
            if spell.english == 'Aquaveil' then
                -- auto unset SIRD; i forget to do so manually too often
                state.SIRD:unset()
            end
        end
    end
    if state.THtag.value and S{'Poisonga','Swipe','Lunge'}:contains(spell.english) then
        equip(sets.midcast.Poisonga.TH)
    end
    if spell.target.type == 'SELF' then
        if spell.english == 'Cursna' then
            equip(sets.buff.doom)
        end
        if state.Buff.Embolden and spell.skill == 'Enhancing Magic' and spell.english ~= 'Erase' then
            equip(sets.buff.Embolden)
        end
    end
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_aftercast(spell, action, spellMap, eventArgs)
    if spell.interrupted then
        if buffactive.Amnesia and S{'JobAbility','WeaponSkill'}:contains(spell.type) then
            add_to_chat(123, 'Amnesia prevents using '..spell.english)
            send_command('wait 0.5;gs c update')
        elseif buffactive.Silence and S{'Ninjutsu'}:contains(spell.type) then
            add_to_chat(123, 'Silence prevents using '..spell.english)
            send_command('wait 0.5;gs c update')
        elseif has_any_buff_of(S{'petrification','sleep','stun','terror'}) then
            add_to_chat(123, 'Status prevents using '..spell.english)
            equip(sets.defense.Parry)
        else
            send_command('wait 0.5;gs c update')
        end
    else
        if state.WSMsg.value then
            if spell.type == 'WeaponSkill' then
                ws_msg(spell)
            elseif spell.english == 'Embolden' then
                send_command('@input /p Used '..spell.english)
            elseif S{'Gambit','Rayke'}:contains(spell.english) then
                local msg = 'Used '..spell.english
                local triple_rune = triple_rune_string()
                if triple_rune then
                    msg = msg..' ('..triple_rune..')'
                end
                send_command('@input /p '..msg)
            end
        end
        if spell.type == 'Rune' or spell.type == 'JobAbility' and not sets.precast.JA[spell.english] then
            -- aftercast can get in the way. skip it when able
            if not (state.IdleMode.value == 'Kite' and state.DefenseMode.value == 'None' and state.CastingMode.value == 'Paranoid') then
                eventArgs.handled = true
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
    if buff:lower() == 'sleep' then
        if gain then
            if player.hp > 100 and player.status == 'Engaged' then
                equip(sets.buff.Sleep)
            end
        elseif not midaction() then
            handle_equipping_gear(player.status)
        end
    elseif buff:lower() == 'doom' then
        if not midaction() then
            handle_equipping_gear(player.status)
        end
    elseif state.DefenseMode.value == 'None' and S{'stun','terror','petrification'}:contains(buff:lower()) then
        if gain then
            equip(sets.defense.Parry)
        elseif not midaction() then
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
        enable('main','sub')
        handle_equipping_gear(player.status)
        equip(sets.weapons[state.CombatWeapon.value])
        if state.OffenseMode.value ~= 'None' then
            disable('main','sub')
        end
        update_combat_form()
    elseif stateField == 'Combat Weapon' then
        enable('main','sub')
        handle_equipping_gear(player.status)
        equip(sets.weapons[newValue])
        if state.OffenseMode.value ~= 'None' then
            disable('main','sub')
        end
        set_weaponskill_keybinds()
        update_combat_form()
    elseif stateField:endswith('Defense Mode') then
        if newValue == 'MDT50' then
            state.DefenseMode:set('Magical')
        end
        if state.DefenseMode.value ~= 'None' then
            local defMode = state[state.DefenseMode.value ..'DefenseMode'].current
            sets.midcast.FastRecast = set_combine(sets.defense[defMode], {})
        else
            sets.midcast.FastRecast = set_combine(sets.defense.Parry, {})
        end
    end
end

-- Called when the player's subjob changes.
function job_sub_job_change(newSubjob, oldSubjob)
    if S{'DNC','NIN'}:contains(newSubjob) then
        sets.weapons.Sword.sub = sets.weapons.DualSword.sub
        sets.weapons.Axe.sub   = sets.weapons.DualAxe.sub
    else
        sets.weapons.Sword.sub = sets.weapons.SingleSword.sub
        sets.weapons.Axe.sub   = sets.weapons.SingleAxe.sub
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
    if state.StatusDefenseMode.value ~= 'None' then
        idleSet = set_combine(idleSet, sets.defense[state.StatusDefenseMode.value])
    end
    if player.mpp < 51 and state.DefenseMode.value == 'None' then
        idleSet = set_combine(idleSet, sets.latent_refresh)
    end
    if state.Buff.Embolden then
        idleSet = set_combine(idleSet, sets.buff.Embolden)
    end
    if state.Buff.doom then
        if state.DefenseMode.value == 'Physical' then
            idleSet = set_combine(idleSet, sets.buff.doom.PDef)
        else
            idleSet = set_combine(idleSet, sets.buff.doom)
        end
    end
    return idleSet
end

-- Modify the default melee set after it was constructed.
function customize_melee_set(meleeSet)
    if state.StatusDefenseMode.value ~= 'None' then
        meleeSet = set_combine(meleeSet, sets.defense[state.StatusDefenseMode.value])
    end
    if state.Buff.Embolden then
        meleeSet = set_combine(meleeSet, sets.buff.Embolden)
    end
    if state.Buff.Sleep then
        meleeSet = set_combine(meleeSet, sets.buff.Sleep)
    end
    if state.Buff.doom then
        if state.DefenseMode.value == 'Physical' then
            meleeSet = set_combine(meleeSet, sets.buff.doom.PDef)
        else
            meleeSet = set_combine(meleeSet, sets.buff.doom)
        end
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
    msg = msg .. ' Idle[' .. state.IdleMode.current .. ']'
    msg = msg .. ' Cast[' .. state.CastingMode.current .. ']'

    if state.DefenseMode.value ~= 'None' then
        local defMode = state[state.DefenseMode.value ..'DefenseMode'].current
        msg = msg .. ' Def[' .. state.DefenseMode.value .. ':' .. defMode .. ']'
    end
    if state.StatusDefenseMode.value ~= 'None' then
        msg = msg .. ' ST[' .. state.StatusDefenseMode.value .. ']'
    end
    if state.OFAhp.valuue then
        msg = msg .. ' OFA++'
    end
    if state.SIRD.value then
        msg = msg .. ' SIRD'
    end
    if state.WSMsg.value then
        msg = msg .. ' WSMsg'
    end
    if state.THtag.value then
        msg = msg .. ' TH+4'
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

    report_ja_recasts()

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
    if cmdParams[1] == 'ListWS' then
        add_to_chat(122, 'ListWS:')
        for _,ws in ipairs(info.ws_binds[info.weapon_type[state.CombatWeapon.value]]) do
            local ws_props = info.ws_props[ws.ws:gsub('"','')].props
            if ws_props then
                add_to_chat(122, "%3s : %s (%s)":format(ws.bind, ws.ws, table.concat(ws_props, ', ')))
            else
                add_to_chat(122, "%3s : %s":format(ws.bind, ws.ws))
            end
        end
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------

function update_combat_form()
    state.CombatForm.value = info.weapon_type[state.CombatWeapon.value]
end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    set_macro_page(1,12)
    send_command('bind !^l input /lockstyleset 12')
end

function ws_msg(spell)
    -- optional party chat messages for weaponskills
    local at_ws
    local good_ats = true
    local props = info.ws_props[spell.english].props
    local at_props = {}
    local aeonic = state.aeonic_aftermath_precast and info.ws_props[spell.english].aeonic
        and player.equipment.main == info.ws_props[spell.english].aeonic.weapon

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

function triple_rune_string(spell)
    -- returns '<Element>' if three like runes are active, else nil
    for rune in runes:it() do
        if buffactive[rune] == 3 then
            return elements.rune_element_of[rune]
        end
    end
    return nil
end

-- prints recast messages using add_to_chat()
function report_ja_recasts()
    local all_ja_recasts = windower.ffxi.get_ability_recasts()
    local available_count = 0
    local available_msg = "OK:"
    local unavailable_count = 0
    local unavailable_msg = "XX:"

    for ability,recast_id in pairs(info.recast_ids) do
        local r = all_ja_recasts[recast_id]
        if r > 0 then
            unavailable_count = unavailable_count + 1
            unavailable_msg = unavailable_msg .. " [%s](%d)":format(ability,r)
        else
            available_count = available_count + 1
            available_msg = available_msg .. " [%s]":format(ability)
        end
    end

    if available_count > 0 then
        add_to_chat(121, available_msg)
    end
    if unavailable_count > 0 then
        add_to_chat(123, unavailable_msg)
    end
end

-- issues send_command()s to set weaponskill keybinds for current value of state.CombatWeapon
-- checks and sets state.WSBinds to determine if send_command()s are needed
-- info.weapon_type and info.ws_binds map state.CombatWeapon to a table of keybinds
function set_weaponskill_keybinds()
    if state.CombatWeapon.value == 'None' then return end
    local cur_weapon_type = info.weapon_type[state.CombatWeapon.value]
    if state.WSBinds.value ~= cur_weapon_type then
        for _,ws in ipairs(info.ws_binds[cur_weapon_type]) do
            --if state.WSBinds.has_value then
            --    add_to_chat(104, "bind %s input /ws %s":format(ws.bind,ws.ws))
            --end
            send_command("bind %s input /ws %s":format(ws.bind,ws.ws))
        end
        state.WSBinds:set(cur_weapon_type)
    end
end

function init_state_text()
    destroy_state_text()
    local sird_text_settings = {flags={draggable=false},bg={alpha=150}}
    local para_text_settings = {pos={x=42},flags={draggable=false},bg={alpha=150}}
    local swap_text_settings = {pos={y=18},flags={draggable=false},bg={alpha=150}}
    local hyb_text_settings    = {pos={x=130,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local def_text_settings    = {pos={x=172,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local status_text_settings = {pos={x=172,y=697},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    state.sird_text   = texts.new('SIRD', sird_text_settings)
    state.para_text   = texts.new('Paranoid', para_text_settings)
    state.swap_text   = texts.new('No TP', swap_text_settings)
    state.hyb_text    = texts.new('/${hybrid}', hyb_text_settings)
    state.def_text    = texts.new('(${defense})', def_text_settings)
    state.status_text = texts.new('{${status}}', status_text_settings)

    state.texts_event_id = windower.register_event('prerender', function()
        state.sird_text:visible(state.SIRD.value)
        state.para_text:visible((state.CastingMode.value == 'Paranoid'))
        state.swap_text:visible((state.OffenseMode.value == 'None'))
        state.hyb_text:visible((state.HybridMode.value ~= 'Normal'))
        state.def_text:visible((state.DefenseMode.value ~= 'None'))
        state.status_text:visible((state.StatusDefenseMode.value ~= 'None'))

        state.hyb_text:update({['hybrid']=state.HybridMode.value})

        local defMode = '---'
        if state.DefenseMode.value ~= 'None' then
            defMode = state[state.DefenseMode.value ..'DefenseMode'].current
        end
        state.def_text:update({['defense']=defMode})
        state.status_text:update({['status']=state.StatusDefenseMode.value})
    end)
end

function destroy_state_text()
    if state.texts_event_id then
        windower.unregister_event(state.texts_event_id)
        state.sird_text:visible(false)
        state.para_text:visible(false)
        state.swap_text:visible(false)
        state.hyb_text:visible(false)
        state.def_text:visible(false)
        state.status_text:visible(false)
        texts.destroy(state.sird_text)
        texts.destroy(state.para_text)
        texts.destroy(state.swap_text)
        texts.destroy(state.hyb_text)
        texts.destroy(state.def_text)
        texts.destroy(state.status_text)
    end
end
