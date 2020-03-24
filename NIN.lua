-- Modified from 'https://github.com/Kinematics/GearSwap-Jobs/'
-- TODO better dual wield sets, gotokai regain

-- nin dual wield cheatsheet
-- haste:   0   15  30  cap
--   +dw:  39   32  21   1

-- NOTES
-- innin boosts ninjutsu damage
-- retsu has a 30% paralysis
-- subtle blow is easy to cap (trait 27, ochu 8, adh.bonnet 8, herc.boots 6, kenda 8/12/8/10/8)
-- when zerging, use chi with bolster malaise and savage otherwise

-- SKILLCHAINS
-- to teki shun shun
-- shun ten kamu shun shun
-- teki to chi to yu to
-- teki to chi to ei/kamu kamu
-- hi hi
-- ku retsu ten hi
-- frag: to teki
-- dist: chi/rin retsu
-- grav: jin ei
-- impa: yu chi
-- 7stp: wasp gust wasp gust ...

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
    enable('ammo','head','neck','ear1','ear2','body','hands','ring1','ring2','back','waist','legs','feet')
    disable('main','sub','range')
    state.Buff.doom = buffactive.doom or false

    state.Buff.Sange = buffactive['sange'] or false
    state.Buff.Futae = buffactive['futae'] or false
    state.Buff.Yonin = buffactive['yonin'] or false
    state.Buff.Innin = buffactive['innin'] or false
    state.Buff.Migawari = buffactive['migawari'] or false

    include('Mote-TreasureHunter')
    state.aeonic_aftermath_precast = false
    state.texts_event_id = nil
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
    state.OffenseMode:options('Normal','MEVA','Acc')            -- Cycle with F9 or @c
    state.HybridMode:options('Normal','PDef')                   -- Cycle with ^F9
    state.RangedMode:options('Blink','Shuriken','Tathlum')      -- Cycle with !F9, set with ^-, ^=, ^backspace
    state.WeaponskillMode:options('Normal','NoDmg')             -- Cycle with @F9
    state.CastingMode:options('Enmity','Normal')                -- Cycle with F10
    state.IdleMode:options('Normal','PDT','Rf','EvaPDT')        -- Cycle with F11, reset with !F11
    state.PhysicalDefenseMode:options('EvaPDT')                 -- Cycle with !z
    state.MagicalDefenseMode:options('MEVA')                    -- Cycle with @z, also switched by AutoHybrid
    state.CombatWeapon = M{['description']='Combat Weapon'}     -- Set with !^q through !^r and others
    state.CombatWeapon:options('Heishi','HeiShu','HeiBlur','HeiMalev','HeiTP','Kikoku','KiBlur','KiTP',
                               'AEDagger','SCDagger','GKatana','NaegBlur','NaegTP','None')
    state.WSBinds = M{['description']='WS Binds',['string']=''}

    state.MagicBurst = M(false, 'Magic Burst')                  -- Toggle with ^z
    state.WSMsg      = M(false, 'WS Message')                   -- Toggle with ^\
    state.SIRDUtsu   = M(false, 'SIRD Utsu')                    -- Set with !@c
    state.LastUtsu   = M{['description']='Utsu Tier',3,2,1}     -- determines when to cancel
    state.AutoHybrid = M{['description']='Auto Hybrid','off','Utsu','Miga'}
    state.Fishing    = M(false, 'Fishing Gear')
    state.Cooking    = M(false, 'Cooking Gear')
    state.HELM       = M(false, 'HELM Gear')
    init_state_text()

    info.magic_ws  = S{'Blade: Ei','Blade: Yu',
                       'Aeolian Edge','Cyclone','Gust Slash','Energy Steal','Energy Drain',
                       'Burning Blade','Red Lotus Blade','Shining Blade','Seraph Blade','Sanguine Blade'}
    info.hybrid_ws = S{'Blade: To','Blade: Teki','Blade: Chi',
                       'Tachi: Goten','Tachi: Kagero','Tachi: Jinpu','Tachi: Koki'}
    info.obi_ws    = S{}:union(info.magic_ws):union(info.hybrid_ws)

    -- Mote-libs handle obis, gorgets, and other elemental things.
    -- These are default fallbacks if situationally appropriate gear is not available.
    gear.default.obi_waist = "Eschan Stone"                 -- used in nuke sets
    gear.default.obi_ring = "Stikini Ring +1"               -- used in nuke sets

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
        augments={'Mag. Acc.+20 "Mag.Atk.Bns."+20','"Fast Cast"+2','INT+8','Mag. Acc.+11','"Mag.Atk.Bns."+14'}}
    gear.herc_legs_ma2 = {name="Herculean Trousers",
        augments={'"Mag.Atk.Bns."+30','Weapon Skill Acc.+5','Accuracy+14 Attack+14','Mag. Acc.+16 "Mag.Atk.Bns."+16'}}
    gear.herc_feet_ma  = {name="Herculean Boots",
        augments={'Mag. Acc.+19 "Mag.Atk.Bns."+19','Enmity-2','MND+4','Mag. Acc.+4','"Mag.Atk.Bns."+15'}}
    gear.herc_head_wsd  = {name="Herculean Helm",
        augments={'"Cure" spellcasting time -10%','Pet: INT+6','Weapon skill damage +9%'}}
    gear.herc_body_wsd  = {name="Herculean Vest", augments={'INT+7','CHR+2','Weapon skill damage +5%','Accuracy+8 Attack+8'}}
    gear.herc_hands_wsd = {name="Herculean Gloves",
        augments={'Accuracy+25 Attack+25','Weapon skill damage +3%','DEX+3','Accuracy+14','Attack+5'}}
    gear.herc_feet_wsd  = {name="Herculean Boots",
        augments={'Accuracy+16 Attack+16','Weapon skill damage +2%','DEX+10','Accuracy+6','Attack+14'}}
    gear.herc_hands_ta = {name="Herculean Gloves", augments={'Accuracy+24 Attack+24','"Triple Atk."+2','AGI+4','Accuracy+13','Attack+14'}}
    gear.herc_feet_ta  = {name="Herculean Boots", augments={'Rng.Acc.+4','"Triple Atk."+4','Accuracy+14','Attack+12'}}
    gear.herc_head_rf = {name="Herculean Helm",
        augments={'Accuracy+17','DEX+6','"Refresh"+2','Accuracy+16 Attack+16','Mag. Acc.+20 "Mag.Atk.Bns."+20'}}
    gear.herc_hands_dt = {name="Herculean Gloves", augments={'Attack+27','Damage taken-4%','DEX+5','Accuracy+9'}}
    gear.herc_legs_th = {name="Herculean Trousers",
        augments={'Attack+3','"Cure" spellcasting time -2%','"Treasure Hunter"+2','Accuracy+1 Attack+1'}}
    gear.herc_head_fc = {name="Herculean Helm", augments={'"Mag.Atk.Bns."+2','"Fast Cast"+5'}}
    gear.herc_feet_fc = {name="Herculean Boots", augments={'"Mag.Atk.Bns."+17','"Fast Cast"+5'}}
    gear.Lstikini = {name="Stikini Ring +1", bag="wardrobe2"}
    gear.Rstikini = {name="Stikini Ring +1", bag="wardrobe3"}

    gear.TPCape   = {name="Andartia's Mantle",
        augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Store TP"+10','Phys. dmg. taken-10%'}}
    gear.ShunCape = {name="Andartia's Mantle",
        augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','"Dbl.Atk."+10','Damage taken-5%'}}
    gear.TenCape  = {name="Andartia's Mantle",
        augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','Weapon skill damage +10%','Damage taken-5%'}}
    gear.SavCape  = {name="Andartia's Mantle",
        augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%','Damage taken-5%'}}
    --gear.HiCape   = -- TODO
    --gear.EvisCape = -- TODO
    gear.EnmCape  = {name="Andartia's Mantle",
        augments={'HP+60','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Enmity+10','Phys. dmg. taken-10%'}}
    gear.MACape =  {name="Andartia's Mantle",
        augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+10','"Mag.Atk.Bns."+10','Damage taken-5%'}}
    gear.FCCape =  {name="Andartia's Mantle", augments={'"Fast Cast"+10'}}

    -- Additional local binds
    send_command('unbind ^F10')
    send_command('unbind ^F12')
    send_command('unbind !F12')
    send_command('bind F9   gs c cycle OffenseMode')
    send_command('bind !F9  gs c cycle RangedMode')
    send_command('bind F10  gs c cycle CastingMode')
    send_command('bind !F10 gs c reset CastingMode')
    send_command('bind F11  gs c cycle IdleMode')
    send_command('bind ^F11 gs c set IdleMode PDT')
    send_command('bind !F11 gs c reset IdleMode')
    send_command('bind @F11 gs c toggle Kiting')
    send_command('bind !F12 gs c cycle TreasureMode')
    send_command('bind ^space  gs c cycle HybridMode')
    send_command('bind !space  gs c set DefenseMode Physical')
    send_command('bind @space  gs c set DefenseMode Magical')
    send_command('bind !@space gs c reset DefenseMode')
    send_command('bind ^@space gs c set AutoHybrid Utsu')
    send_command('bind !^space gs c set AutoHybrid Miga')
    send_command('bind ^\\\\ gs c toggle WSMsg')
    send_command('bind ^@\\\\ gs c ListWS')
    send_command('bind ^z  gs c toggle MagicBurst')
    send_command('bind !z  gs c cycle PhysicalDefenseMode')
    send_command('bind @z  gs c cycle MagicalDefenseMode')
    send_command('bind !w  gs c reset OffenseMode')
    send_command('bind !@w gs c set CombatWeapon None')
    send_command('bind !^q gs c set CombatWeapon AEDagger')
    send_command('bind ^@q gs c set CombatWeapon SCDagger')
    send_command('bind !^w gs c set CombatWeapon Heishi')
    send_command('bind ^@w gs c set CombatWeapon GKatana')
    send_command('bind !^e gs c set CombatWeapon Kikoku')
    send_command('bind ^@e gs c set CombatWeapon HeiShu')
    send_command('bind !^r gs c set CombatWeapon NaegTP')
    send_command('bind ^-         gs c set RangedMode Tathlum')
    send_command('bind ^=         gs c set RangedMode Shuriken')
    send_command('bind ^backspace gs c set RangedMode Blink')
    send_command('bind !c  gs c set OffenseMode Acc')
    send_command('bind @c  gs c set OffenseMode MEVA')
    send_command('bind !@c gs c toggle SIRDUtsu')

    send_command('bind !^` input /ja "Mijin Gakure" <t>')
    send_command('bind ^@` input /ja Mikage')
    send_command('bind @` input /ja Futae')
    send_command('bind ^@tab input /ja Issekigan')

    send_command('bind !1 input /ja Yonin')
    send_command('bind !2 input /ja Innin')
    send_command('bind !3 input /ja Sange')

    send_command('bind !8 gs c set CombatForm DW15')
    send_command('bind !9 gs c set CombatForm DW30')
    send_command('bind !0 gs c reset CombatForm')

    info.weapon_type = {['Heishi']='Katana',['HeiShu']='Katana',['HeiBlur']='Katana',['HeiMalev']='Katana',['HeiTP']='Katana',
                        ['Kikoku']='RKatana',['KiBlur']='RKatana',['KiTP']='RKatana',
                        ['Gokotai']='Katana',
                        ['AEDagger']='Dagger',['SCDagger']='Dagger',
                        ['GKatana']='GKatana',
                        ['Clubs']='Club',
                        ['NaegBlur']='Sword',['NaegTP']='Sword'}
    info.ws_binds = {
        ['Katana']={
        [1]={bind='^1',ws='"Blade: Hi"'},
        [2]={bind='^2',ws='"Blade: Shun"'},
        [3]={bind='^3',ws='"Blade: Ten"'},
        [4]={bind='^4',ws='"Blade: Kamu"'},
        [5]={bind='^5',ws='"Blade: Jin"'},
        [6]={bind='^6',ws='"Blade: Ku"'},
        [7]={bind='!^1',ws='"Blade: Retsu"'},
        [8]={bind='!^2',ws='"Blade: To"'},
        [9]={bind='!^3',ws='"Blade: Teki"'},
        [10]={bind='!^4',ws='"Blade: Chi"'},
        [11]={bind='!^5',ws='"Blade: Ei"'},
        [12]={bind='!^6',ws='"Blade: Yu"'},
        [13]={bind='@b',ws='"Blade: Shun" <stnpc>'}},
        ['RKatana']={
        [1]={bind='^1',ws='"Blade: Hi"'},
        [2]={bind='^2',ws='"Blade: Shun"'},
        [3]={bind='^3',ws='"Blade: Ten"'},
        [4]={bind='^4',ws='"Blade: Metsu"'},
        [5]={bind='^5',ws='"Blade: Jin"'},
        [6]={bind='^6',ws='"Blade: Ku"'},
        [7]={bind='!^1',ws='"Blade: Retsu"'},
        [8]={bind='!^2',ws='"Blade: To"'},
        [9]={bind='!^3',ws='"Blade: Teki"'},
        [10]={bind='!^4',ws='"Blade: Chi"'},
        [11]={bind='!^5',ws='"Blade: Ei"'},
        [12]={bind='!^6',ws='"Blade: Yu"'},
        [13]={bind='@b',ws='"Blade: Metsu" <stnpc>'}},
        ['Dagger']={
        [1]={bind='^1',ws='"Engergy Drain"'},
        [2]={bind='^2',ws='"Evisceration"'},
        [3]={bind='^3',ws='"Wasp Sting"'},
        [4]={bind='^4',ws='"Gust Slash"'},
        [5]={bind='^5',ws='"Exenterator"'},
        [6]={bind='^6',ws='"Aeolian Edge"'},
        [7]={bind='^7',ws='"Cyclone"'}},
        ['GKatana']={
        [1]={bind='^1',ws='"Tachi: Ageha"'},
        [2]={bind='^2',ws='"Tachi: Kasha"'},
        [3]={bind='^3',ws='"Tachi: Jinpu"'},
        [4]={bind='^4',ws='"Tachi: Kagero"'},
        [5]={bind='^5',ws='"Tachi: Koki"'},
        [6]={bind='!^d',ws='"Tachi: Hobaku"'}},
        ['Sword']={
        [1]={bind='^1',ws='"Sanguine Blade"'},
        [2]={bind='^2',ws='"Vorpal Blade"'},
        [3]={bind='^3',ws='"Savage Blade"'},
        [4]={bind='^4',ws='"Red Lotus Blade"'},
        [5]={bind='^5',ws='"Seraph Blade"'},
        [6]={bind='^6',ws='"Circle Blade"'},
        [7]={bind='!^d',ws='"Flat Blade"'},
        [8]={bind='@b',ws='"Savage Blade" <stnpc>'}},
        ['Club']={
        [1]={bind='^1',ws='"Flash Nova"'},
        [2]={bind='^2',ws='"Judgement"'},
        [3]={bind='^3',ws='"True Strike"'},
        [4]={bind='!^d',ws='"Brainshaker"'}}}
    set_weaponskill_keybinds()

    send_command('bind ^@1 input /ma "Katon: San"')
    send_command('bind ^@2 input /ma "Hyoton: San"')
    send_command('bind ^@3 input /ma "Huton: San"')
    send_command('bind ^@4 input /ma "Doton: San"')
    send_command('bind ^@5 input /ma "Raiton: San"')
    send_command('bind ^@6 input /ma "Suiton: San"')

    send_command('bind !@1 input /ma "Kurayami: Ni"')   -- acc-30
    send_command('bind !@2 input /ma "Hojo: Ni"')       -- 20% slow
    send_command('bind !@3 input /ma "Jubaku: Ichi"')   -- 20% para
    send_command('bind !@4 input /ma "Aisha: Ichi"')    -- 15% att down
    send_command('bind !@5 input /ma "Yurin: Ichi"')    -- 10% inhibit tp
    send_command('bind !@6 input /ma "Dokumori: Ichi"') -- 3/tick poison

    send_command('bind @1 input /ma "Kurayami: Ni" <stnpc>')
    send_command('bind @2 input /ma "Hojo: Ni" <stnpc>')
    send_command('bind @3 input /ma "Jubaku: Ichi" <stnpc>')
    send_command('bind @4 input /ma "Aisha: Ichi" <stnpc>')
    send_command('bind @5 input /ma "Yurin: Ichi" <stnpc>')
    send_command('bind @6 input /ma "Dokumori: Ichi" <stnpc>')

    send_command('bind !e input /ma "Utsusemi: Ni"')    -- 0/160 (160/480 yonin)
    send_command('bind @e input /ma "Utsusemi: San"')   -- ditto
    send_command('bind !@e input /ma "Utsusemi: Ichi"') -- ditto
    send_command('bind !g input /ma "Migawari: Ichi"')
    send_command('bind !@g gs equip phlx')              -- phalanx+15
    send_command('bind @f input /ma "Gekka: Ichi"')     -- enm+30
    send_command('bind !@f input /ma "Yain: Ichi"')     -- enm-15
    send_command('bind !f input /ma "Kakka: Ichi"')     -- stp+10
    send_command('bind !b input /ma "Myoshu: Ichi"')    -- sb+10
    send_command('bind !v input /ma "Tonko: Ni"')
    send_command('bind @v input /ma "Monomi: Ichi"')

    if     player.sub_job == 'WAR' then
        send_command('bind !4 input /ja Berserk <me>')
        send_command('bind !5 input /ja Aggressor <me>')
        send_command('bind !6 input /ja Warcry <me>')   -- 1/300 per target
        send_command('bind !d input /ja Provoke')       -- 0/1800
        send_command('bind @d input /ja Provoke <stnpc>')
        send_command('bind !@d input /ja Defender <me>')
    elseif player.sub_job == 'DRK' then
        send_command('bind !4 input /ja "Last Resort" <me>')
        send_command('bind !5 input /ja Souleater <me>')
        send_command('bind !6 input /ja "Arcane Circle" <me>')
        send_command('bind !d input /ma Stun')
        send_command('bind @d input /ma Stun <stnpc>')
        send_command('bind !@d input /ma Poisonga')
    elseif player.sub_job == 'PLD' then
        send_command('bind !5 input /ja Sentinel <me>')
        send_command('bind !6 input /ja "Holy Circle" <me>')
        send_command('bind !d input /ma Flash')
        send_command('bind @d input /ma Flash <stnpc>')
    elseif player.sub_job == 'RUN' then
        send_command('bind @1 input /ja Ignis <me>')        -- fire up,    ice down
        send_command('bind @2 input /ja Gelus <me>')        -- ice up,     wind down
        send_command('bind @3 input /ja Flabra <me>')       -- wind up,    earth down
        send_command('bind @4 input /ja Tellus <me>')       -- earth up,   thunder down
        send_command('bind @5 input /ja Sulpor <me>')       -- thunder up, water down
        send_command('bind @6 input /ja Unda <me>')         -- water up,   fire down
        send_command('bind @7 input /ja Lux <me>')          -- light up,   dark down
        send_command('bind @8 input /ja Tenebrae <me>')     -- dark up,    light down
        send_command('bind !4 input /ja Swordplay <me>')    -- 160/320, +3 acc/eva per tick
        send_command('bind !5 input /ja Pflug <me>')        -- 450/900, +10 resist per rune
        send_command('bind ^tab input /ja Vallation <me>')  -- 450/900, -15% damage per rune
        send_command('bind !d input /ma Flash')             -- 180/1280
        send_command('bind @d input /ma Flash <stnpc>')
        send_command('bind !^v input /ma Aquaveil <me>')
        send_command('bind !6 input /ma Protect <stpc>')
    elseif player.sub_job == 'BLU' then
        send_command('bind @1 input /ma "Sheep Song"')                  -- (320/320), 6'
        send_command('bind @2 input /ma "Geist Wall"')                  -- (320/320), 6'
        send_command('bind @3 input /ma "Stinking Gas"')                -- (320/320), 6'
        send_command('bind !4 input /ma Cocoon <me>')
        send_command('bind !5 input /ma Refueling <me>')
        -- wild carrot aliased to //wc
        send_command('bind !6 input /ma "Healing Breeze" <me>')
        send_command('bind !d input /ma "Blank Gaze"')                  -- (320/320), 12'
        send_command('bind !@d input /ma Jettatura')                    -- (180/1020), 9'
    elseif player.sub_job == 'DRG' then
        send_command('bind !4 input /ja "High Jump"')
        send_command('bind !6 input /ja "Ancient Circle" <me>')
    elseif player.sub_job == 'DNC' then
        send_command('bind !` input /ja "Curing Waltz III" <stpc>')
        send_command('bind @F1 input /ja "Healing Waltz" <stpc>')
        send_command('bind !4 input /ja "Box Step" <t>')
        send_command('bind !5 input /ja "Haste Samba" <me>')
        send_command('bind !6 input /ja "Divine Waltz" <me>')
        send_command('bind !@f input /ja "Reverse Flourish" <me>')
        send_command('bind !d input /ja "Animated Flourish"')
        send_command('bind @d input /ja "Animated Flourish" <stnpc>')
        send_command('bind !@d input /ja "Violent Flourish" <stnpc>')
    elseif player.sub_job == 'SAM' then
        send_command('bind !4 input /ja Meditate <me>')
        send_command('bind !5 input /ja Sekkanoki <me>')
        send_command('bind !6 input /ja "Warding Circle" <me>')
        send_command('bind !d input /ja "Third Eye" <me>')
    elseif player.sub_job == 'WHM' then
        send_command('bind !5 input /ma Haste <me>')
        send_command('bind !6 input /ma Cura <me>')
        send_command('bind !d input /ma Flash')
        send_command('bind @d input /ma Flash <stnpc>')
        send_command('bind !@d input /ma Banishga')
        send_command('bind !^g input /ma Stoneskin <me>')
        send_command('bind !^v input /ma Aquaveil <me>')
    elseif player.sub_job == 'RDM' then
        send_command('bind !4 input /ma Phalanx <me>')
        send_command('bind !5 input /ma Haste <me>')
        send_command('bind !6 input /ma Refresh <me>')
        send_command('bind ^tab input /ma Dispel')
        send_command('bind !@d input /ma Diaga')
        send_command('bind !^g input /ma Stoneskin <me>')
        send_command('bind !^v input /ma Aquaveil <me>')
    elseif player.sub_job == 'BLM' then
        send_command('bind !4 input /ma "Sleep II" <stnpc>')
        send_command('bind !5 input /ma Sleep <stnpc>')
        send_command('bind !6 input /ma Sleepga')
        send_command('bind !d input /ma Stun')
        send_command('bind @d input /ma Stun <stnpc>')
        send_command('bind !@d input /ma Poisonga')
    elseif player.sub_job == 'SMN' then
        send_command('bind !4 input /ma Diabolos <me>')
        send_command('bind !5 input /pet Somnolence <t>')
        send_command('bind !6 input /pet Release <me>')
        send_command('bind !d input /pet Assault <t>')
        send_command('bind @d input /pet Retreat <me>')
    end

    select_default_macro_book()
end

-- Called when this job file is unloaded (eg: job change)
function user_unload()
    send_command('unbind ^-')
    send_command('unbind ^=')
    send_command('unbind ^backspace')
    send_command('unbind ^space')
    send_command('unbind !space')
    send_command('unbind @space')
    send_command('unbind !@space')
    send_command('unbind ^@space')
    send_command('unbind !^space')
    send_command('unbind ^\\\\')
    send_command('unbind ^@\\\\')
    send_command('unbind ^z')
    send_command('unbind !z')
    send_command('unbind @z')
    send_command('unbind !w')
    send_command('unbind !@w')
    send_command('unbind !^q')
    send_command('unbind ^@q')
    send_command('unbind !^w')
    send_command('unbind ^@w')
    send_command('unbind !^e')
    send_command('unbind ^@e')
    send_command('unbind !^r')
    send_command('unbind !c')
    send_command('unbind @c')
    send_command('unbind !@c')

    send_command('unbind !^`')
    send_command('unbind ^@`')
    send_command('unbind @`')
    send_command('unbind ^tab')
    send_command('unbind ^@tab')

    send_command('unbind !1')
    send_command('unbind !2')
    send_command('unbind !3')

    send_command('unbind ^1')
    send_command('unbind ^2')
    send_command('unbind ^3')
    send_command('unbind ^4')
    send_command('unbind ^5')
    send_command('unbind ^6')
    send_command('unbind !^1')
    send_command('unbind !^2')
    send_command('unbind !^3')
    send_command('unbind !^4')
    send_command('unbind !^5')
    send_command('unbind !^6')

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

    send_command('unbind @1')
    send_command('unbind @2')
    send_command('unbind @3')
    send_command('unbind @4')
    send_command('unbind @5')
    send_command('unbind @6')
    send_command('unbind @7')
    send_command('unbind @8')

    send_command('unbind !e')
    send_command('unbind @e')
    send_command('unbind !@e')
    send_command('unbind !g')
    send_command('unbind !@g')
    send_command('unbind @f')
    send_command('unbind !@f')
    send_command('unbind !^f')
    send_command('unbind !f')
    send_command('unbind !b')
    send_command('unbind !v')
    send_command('unbind @v')

    send_command('unbind !4')
    send_command('unbind !5')
    send_command('unbind !6')
    send_command('unbind !d')
    send_command('unbind @d')
    send_command('unbind !^d')
    send_command('unbind !@d')
    send_command('unbind !^g')
    send_command('unbind !^v')
    send_command('unbind !`')
    send_command('unbind @F1')

    destroy_state_text()
end

-- Define sets and vars used by this job file.
function init_gear_sets()

    sets.weapons = {}
    sets.weapons.None = {}
    sets.weapons.Heishi   = {main="Heishi Shorinken",sub="Ochu"}
    sets.weapons.HeiShu   = {main="Heishi Shorinken",sub="Shuhansadamune"}
    sets.weapons.HeiBlur  = {main="Heishi Shorinken",sub="Blurred Knife +1"}
    sets.weapons.HeiMalev = {main="Heishi Shorinken",sub="Malevolence"}
    sets.weapons.HeiTP    = {main="Heishi Shorinken",sub="Hitaki"}
    sets.weapons.Kikoku   = {main="Kikoku",sub="Ochu"}
    sets.weapons.KiBlur   = {main="Kikoku",sub="Blurred Knife +1"}
    sets.weapons.KiTP     = {main="Kikoku",sub="Hitaki"}
    --sets.weapons.Gokotai  = {main="Gokotai",sub="Ochu"}
    sets.weapons.AEDagger = {main="Tauret",sub="Malevolence"}
    sets.weapons.SCDagger = {main="Tauret",sub="Blurred Knife +1"}
    sets.weapons.GKatana  = {main="Hachimonji",sub="Bloodrain Strap"}
    sets.weapons.NaegBlur = {main="Naegling",sub="Blurred Knife +1"}
    sets.weapons.NaegTP = {main="Naegling",sub="Hitaki"}
    sets.weapons.Clubs  = {main="Mafic Cudgel",sub="Hitaki"}
    sets.weapons.empty = {main=empty,sub=empty}
    sets.weapons.Daken       = {ammo="Date Shuriken"}
    sets.weapons.TPTathlum   = {ammo="Yamarang"}
    sets.weapons.DTTathlum   = {ammo="Staunch Tathlum +1"}

    sets.TreasureHunter = {head="Volte Cap",waist="Chaac Belt",legs=gear.herc_legs_th}

    -- Precast Sets
    sets.Enmity = {main="Heishi Shorinken",sub="Shuhansadamune",ammo="Date Shuriken",
        head="Genmei Kabuto",neck="Moonlight Necklace",ear1="Cryptic Earring",ear2="Trux Earring",
        body="Emet Harness +1",hands="Kurys Gloves",ring1="Supershear Ring",ring2="Eihwaz Ring",
        back=gear.EnmCape,waist="Goading Belt",legs="Zoar Subligar +1",feet="Ahosi Leggings"}
    -- enm+84~94
    sets.precast.JA.Yonin = set_combine(sets.Enmity, {})
    sets.precast.JA.Provoke = set_combine(sets.Enmity, {})
    sets.precast.JA.Warcry = set_combine(sets.Enmity, {})
    sets.precast.JA.Vallation = set_combine(sets.Enmity, {})
    sets.precast.JA.Swordplay = set_combine(sets.Enmity, {})
    sets.precast.JA.Pflug = set_combine(sets.Enmity, {})
    sets.precast.JA.Sentinel = set_combine(sets.Enmity, {})
    sets.precast.JA.Souleater = set_combine(sets.Enmity, {})
    sets.precast.JA['Last Resort'] = set_combine(sets.Enmity, {})

    sets.lugra = {ear1="Lugra Earring +1"} -- combined in job_post_precast
    sets.gavialis = {head="Gavialis Helm"} -- combined in job_post_precast
    sets.precast.WS = {ammo="Voluspa Tathlum",
        head="Adhemar Bonnet +1",neck="Fotia Gorget",ear1="Trux Earring",ear2="Moonshade Earring",
        body="Kendatsuba Samue +1",hands="Adhemar Wristbands +1",ring1="Ilabrat Ring",ring2="Regal Ring",
        back=gear.ShunCape,waist="Fotia Belt",legs="Samnuha Tights",feet=gear.herc_feet_ta}
    sets.precast.WS['Blade: Shun'] = {ammo="Date Shuriken",
        head="Kendatsuba Jinpachi +1",neck="Fotia Gorget",ear1="Moonshade Earring",ear2="Odr Earring",
        body="Kendatsuba Samue +1",hands="Kendatsuba Tekko +1",ring1="Ilabrat Ring",ring2="Regal Ring",
        back=gear.ShunCape,waist="Fotia Belt",legs="Jokushu Haidate",feet="Kendatsuba Sune-Ate +1"}
    sets.precast.WS['Blade: Ten'] = {ammo="Voluspa Tathlum",
        head="Hachiya Hatsuburi +3",neck="Ninja Nodowa +2",ear1="Ishvara Earring",ear2="Moonshade Earring",
        body=gear.herc_body_wsd,hands=gear.herc_hands_wsd,ring1="Gere Ring",ring2="Regal Ring",
        back=gear.TenCape,waist="Grunfeld Rope",legs="Hizamaru Hizayoroi +2",feet="Hizamaru Sune-Ate +2"}
    sets.precast.WS['Blade: Metsu'] = {ammo="Date Shuriken",
        head="Hachiya Hatsuburi +3",neck="Ninja Nodowa +2",ear1="Ishvara Earring",ear2="Odr Earring",
        body=gear.herc_body_wsd,hands=gear.herc_hands_wsd,ring1="Ilabrat Ring",ring2="Regal Ring",
        back=gear.TenCape,waist="Grunfeld Rope",legs="Jokushu Haidate",feet=gear.herc_feet_wsd}
    sets.precast.WS['Blade: Kamu'] = set_combine(sets.precast.WS['Blade: Ten'], {
        ear1="Brutal Earring",ear2="Ishvara Earring",waist="Fotia Belt"})
    sets.precast.WS['Blade: Hi'] = {ammo="Yetshila +1",
        head="Hachiya Hatsuburi +3",neck="Ninja Nodowa +2",ear1="Odr Earring",ear2="Ishvara Earring",
        body="Mummu Jacket +2",hands="Mummu Wrists +2",ring1="Ilabrat Ring",ring2="Regal Ring",
        back=gear.TenCape,waist="Windbuffet Belt +1",legs="Mummu Kecks +2",feet="Mummu Gamashes +2"}
    sets.precast.WS['Blade: Jin'] = set_combine(sets.precast.WS['Blade: Hi'], {
        head="Mummu Bonnet +2",ear2="Moonshade Earring",body="Kendatsuba Samue +1",
        back=gear.TPCape,waist="Fotia Belt"})
    sets.precast.WS.Evisceration = set_combine(sets.precast.WS['Blade: Jin'], {})
    sets.precast.WS['Vorpal Blade'] = set_combine(sets.precast.WS['Blade: Jin'], {})
    sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS['Blade: Ten'], {back=gear.SavCape})
    sets.precast.WS['Tachi: Kasha'] = set_combine(sets.precast.WS['Savage Blade'], {})
    sets.precast.WS['Judgement']   = set_combine(sets.precast.WS['Savage Blade'], {})
    sets.precast.WS['True Strike'] = set_combine(sets.precast.WS['Savage Blade'], {})

    sets.precast.WS['Aeolian Edge'] = {ammo="Seething Bomblet +1",
        head="Mochizuki Hatsuburi +3",neck="Fotia Gorget",ear1="Moonshade Earring",ear2="Friomisi Earring",
        body="Samnuha Coat",hands=gear.herc_hands_ma,ring1="Dingir Ring",ring2="Acumen Ring",
        back=gear.TenCape,waist="Fotia Belt",legs=gear.herc_legs_ma2,feet=gear.herc_feet_ma}
    sets.precast.WS.Cyclone = set_combine(sets.precast.WS['Aeolian Edge'], {})
    sets.precast.WS['Blade: Yu'] = set_combine(sets.precast.WS['Aeolian Edge'], {ear1="Hecate's Earring"})
    sets.precast.WS['Blade: Ei'] = set_combine(sets.precast.WS['Aeolian Edge'], {head="Pixie Hairpin +1",ring2="Archon Ring"})
    sets.precast.WS['Sanguine Blade']  = set_combine(sets.precast.WS['Blade: Ei'], {})
    sets.precast.WS['Red Lotus Blade'] = set_combine(sets.precast.WS['Aeolian Edge'], {})
    sets.precast.WS['Seraph Blade']    = set_combine(sets.precast.WS['Aeolian Edge'], {})
    sets.precast.WS['Flash Nova']      = set_combine(sets.precast.WS['Aeolian Edge'], {})

    sets.precast.WS['Blade: To'] = {ammo="Seething Bomblet +1",
        head="Mochizuki Hatsuburi +3",neck="Fotia Gorget",ear1="Moonshade Earring",ear2="Friomisi Earring",
        body="Samnuha Coat",hands=gear.herc_hands_ma,ring1="Dingir Ring",ring2="Epona's Ring",
        back=gear.TenCape,waist="Fotia Belt",legs=gear.herc_legs_ma2,feet=gear.herc_feet_ma}
    sets.precast.WS['Blade: Teki']  = set_combine(sets.precast.WS['Blade: To'], {})
    sets.precast.WS['Blade: Chi']   = set_combine(sets.precast.WS['Blade: To'], {})
    sets.precast.WS['Tachi: Jinpu'] = set_combine(sets.precast.WS['Blade: To'], {})

    sets.precast.WS['Blade: Retsu'] = {ammo="Yetshila +1",
        head="Mummu Bonnet +2",neck="Sanctity Necklace",ear1="Dignitary's Earring",ear2="Telos Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Etana Ring",ring2="Regal Ring",
        back=gear.TPCape,waist="Eschan Stone",legs="Malignance Tights",feet="Malignance Boots"}
    sets.precast.WS['Tachi: Ageha']  = set_combine(sets.precast.WS['Blade: Retsu'], {})
    sets.precast.WS['Tachi: Hobaku'] = set_combine(sets.precast.WS['Blade: Retsu'], {})
    sets.precast.WS['Flat Blade']    = set_combine(sets.precast.WS['Blade: Retsu'], {})

    sets.precast.WS.NoDmg = set_combine(sets.precast.Step, {neck="Combatant's Torque"})

    sets.precast.RA = {ammo=empty} -- don't /ra
    sets.precast.FC = {main="Heishi Shorinken",sub="Shuhansadamune",ammo="Sapience Orb",
        head=gear.herc_head_fc,neck="Orunmila's Torque",ear1="Loquacious Earring",ear2="Etiolation Earring",
        body="Adhemar Jacket",hands="Leyline Gloves",ring1="Kishar Ring",ring2="Defending Ring",
        back=gear.FCCape,waist="Flume Belt +1",legs="Rawhide Trousers",feet=gear.herc_feet_fc}
    -- fc+59~66
    sets.precast.FC.Ninjutsu = set_combine(sets.precast.FC, {main="Kikoku",sub="Shuhansadamune"})
    sets.precast.FC.Utsusemi = set_combine(sets.precast.FC.Ninjutsu, {neck="Magoraga Beads"})

    sets.precast.Waltz = {ammo="Yamarang",
        head="Mummu Bonnet +2",body="Mummu Jacket +2",hands="Mummu Wrists +2",
        waist="Chaac Belt",legs="Mummu Kecks +2",feet="Mummu Gamashes +2"}
    sets.precast.Step = {ammo="Yamarang",
        head="Mummu Bonnet +2",neck="Ninja Nodowa +2",ear1="Odr Earring",ear2="Telos Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Ilabrat Ring",ring2="Cacoethic Ring +1",
        back=gear.TPCape,waist="Eschan Stone",legs="Malignance Tights",feet="Mummu Gamashes +2"}
    sets.precast.JA['Violent Flourish'] = set_combine(sets.precast.Step, {
        neck="Sanctity Necklace",ear1="Dignitary's Earring",ring1="Etana Ring"})
    sets.precast.JA['Animated Flourish'] = set_combine(sets.Enmity, {})

    -- Midcast Sets
    sets.midcast.RA = {ammo=empty}

    sets.midcast.Utsusemi = {hands="Mochizuki Tekko +1",back=gear.EnmCape,feet="Hattori Kyahan +1"}
    sets.midcast.Utsusemi.Enmity = {main="Heishi Shorinken",sub="Shuhansadamune",ammo="Date Shuriken",
        head="Genmei Kabuto",neck="Moonlight Necklace",ear1="Cryptic Earring",ear2="Trux Earring",
        body="Emet Harness +1",hands="Kurys Gloves",ring1="Supershear Ring",ring2="Eihwaz Ring",
        back=gear.EnmCape,waist="Goading Belt",legs="Zoar Subligar +1",feet="Hattori Kyahan +1"}
    -- enm+76~86, pdt-23
    sets.midcast.Utsusemi.SIRD = {main="Tancho +1",sub="Tancho",ammo="Staunch Tathlum +1",
        head="Genmei Kabuto",neck="Moonlight Necklace",ear1="Genmei Earring",ear2="Trux Earring",
        body="Emet Harness +1",hands="Rawhide Gloves",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.EnmCape,waist="Goading Belt",legs="Malignance Tights",feet="Hattori Kyahan +1"}
    -- enm+45, pdt-49, sird+106

    sets.midcast.ElementalNinjutsu = {main="Tauret",sub="Malevolence",ammo="Pemphredo Tathlum",
        head="Mochizuki Hatsuburi +3",neck="Sanctity Necklace",ear1="Hecate's Earring",ear2="Friomisi Earring",
        body="Samnuha Coat",hands="Leyline Gloves",ring1=gear.Lstikini,ring2="Dingir Ring",
        back=gear.MACape,waist=gear.ElementalObi,legs=gear.herc_legs_ma,feet=gear.herc_feet_ma}
    sets.midcast.ElementalNinjutsu.MB = set_combine(sets.midcast.ElementalNinjutsu, {sub="Ochu",
        hands=gear.herc_hands_ma,ring1="Locus Ring",ring2="Mujin Band",legs=gear.herc_legs_ma2,feet="Hachiya Kyahan +3"})
    sets.donargun = {range="Donar Gun",ammo=empty}
    sets.kajabow  = {range="Ullr",ammo=empty}
    sets.buff.Futae = {hands="Hattori Tekko +1"}
    sets.midcast.EnfeeblingNinjutsu = {main="Tauret",sub="Malevolence",ammo="Yamarang",
        head="Hachiya Hatsuburi +3",neck="Moonlight Necklace",ear1="Dignitary's Earring",ear2="Gwati Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1=gear.Lstikini,ring2=gear.Rstikini,
        back=gear.MACape,waist="Eschan Stone",legs="Malignance Tights",feet="Hachiya Kyahan +3"}
    sets.midcast.Ninjutsu = {hands="Mochizuki Tekko +1"}

    sets.midcast['Enfeebling Magic'] = set_combine(sets.midcast.EnfeeblingNinjutsu, {})
    sets.midcast.Repose = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast['Enhancing Magic'] = {neck="Incanter's Torque",ear1="Andoaa Earring",ear2="Mimir Earring",
        ring1=gear.Lstikini,ring2=gear.Rstikini,waist="Olympus Sash"}
    sets.phlx = {head=gear.taeon_head_phlx,body=gear.taeon_body_phlx,
        hands=gear.taeon_hands_phlx,legs=gear.taeon_legs_phlx,feet=gear.taeon_feet_phlx}
    sets.midcast.Phalanx = set_combine(sets.midcast['Enhancing Magic'], sets.phlx)
    sets.midcast.Refresh = {waist="Gishdubar Sash"}
    sets.midcast.Haste = {}
    sets.midcast.Stoneskin = {}
    sets.midcast.Aquaveil = {}
    sets.midcast.Poisonga = {}
    sets.midcast.Diaga = {}
    sets.midcast.Banishga = {}
    sets.midcast.Flash = set_combine(sets.Enmity, {})
    sets.midcast.Stun  = set_combine(sets.Enmity, {})
    sets.midcast['Blue Magic'] = {}
    sets.midcast['Stinking Gas'] = set_combine(sets.Enmity, {})
    sets.midcast['Sheep Song']   = set_combine(sets.Enmity, {})
    sets.midcast['Geist Wall']   = set_combine(sets.Enmity, {})
    sets.midcast['Blank Gaze']   = set_combine(sets.Enmity, {})
    sets.midcast.Soporific       = set_combine(sets.Enmity, {})
    sets.midcast.Jettatura       = set_combine(sets.Enmity, {})

    -- Sets to return to when not performing an action.
    sets.idle = {main="Heishi Shorinken",sub="Shuhansadamune",ammo="Yamarang",
        head="Genmei Kabuto",neck="Loricate Torque +1",ear1="Eabani Earring",ear2="Etiolation Earring",
        body="Hizamaru Haramaki +2",hands="Malignance Gloves",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.EnmCape,waist="Engraved Belt",legs="Malignance Tights",feet="Hachiya Kyahan +3"}
    -- pdt-50, dt-36, eva~1054, meva+536, rg+12
    sets.idle.PDT = set_combine(sets.idle, {feet="Malignance Boots"})
    sets.idle.Rf  = set_combine(sets.idle, {
        head=gear.herc_head_rf,body="Mekosuchinae Harness",ring1=gear.Lstikini,ring2=gear.Rstikini,
        waist="Flume Belt +1",legs="Rawhide Trousers"})
    sets.idle.Eva = {main="Tancho +1",sub="Shuhansadamune",ammo="Yamarang",
        head="Hizamaru Somen +2",neck="Ninja Nodowa +2",ear1="Eabani Earring",ear2="Infused Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.EnmCape,waist="Sveltesse Gouriz +1",legs="Malignance Tights",feet="Malignance Boots"}
    sets.idle.EvaPDT = set_combine(sets.idle.Eva, {})

    sets.defense.EvaPDT = set_combine(sets.idle.EvaPDT, {})
    -- pdt-50, dt-43, eva~1181, meva+663, rg+1
    sets.defense.MEVA = {main="Tancho +1",sub="Shuhansadamune",ammo="Yamarang",
        head="Kendatsuba Jinpachi +1",neck="Ninja Nodowa +2",ear1="Eabani Earring",ear2="Telos Earring",
        body="Kendatsuba Samue +1",hands="Kendatsuba Tekko +1",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.EnmCape,waist="Engraved Belt",legs="Malignance Tights",feet="Kendatsuba Sune-Ate +1"}
    -- Heishi/Shuriken: pdt-35, dt-25, eva~1009, meva+655, acc~1283/1258/1185

    sets.danzo   = {feet="Danzo Sune-Ate"}
    sets.hachiya = {feet="Hachiya Kyahan +3"}
    sets.Kiting = sets.hachiya
    sets.buff.doom = {neck="Nicander's Necklace",ring1="Saida Ring",waist="Gishdubar Sash"}

    -- Engaged sets
    sets.engaged = {main="Heishi Shorinken",sub="Shuhansadamune",ammo="Date Shuriken",
        head="Adhemar Bonnet +1",neck="Ninja Nodowa +2",ear1="Brutal Earring",ear2="Telos Earring",
        body="Kendatsuba Samue +1",hands="Adhemar Wristbands +1",ring1="Gere Ring",ring2="Epona's Ring",
        back=gear.TPCape,waist="Windbuffet Belt +1",legs="Samnuha Tights",feet=gear.herc_feet_ta}
    -- Heishi/Shuriken: acc~1216/1191/1062, haste+26, stp+47, da+12, ta+33, qa+2, pdt-12, meva+369
    sets.engaged.DW30 = set_combine(sets.engaged, {ear2="Suppanomimi",body="Adhemar Jacket +1",waist="Reiki Yotai"})
    sets.engaged.DW15 = set_combine(sets.engaged.DW30, {ear1="Eabani Earring",feet="Hizamaru Sune-Ate +2"})

    sets.engaged.PDef = set_combine(sets.engaged, {
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Vocane Ring +1",ring2="Defending Ring",
        legs="Malignance Tights",feet="Malignance Boots"})
    -- Heishi/Shuriken: acc~1321/1296/1223, haste+26, stp+75, da+6, ta+6, qa+2, pdt-50, dt-43, sb=43, eva~1089, meva+652
    sets.engaged.DW30.PDef = set_combine(sets.engaged.PDef, {ear2="Suppanomimi",body="Adhemar Jacket +1",waist="Reiki Yotai"})
    sets.engaged.DW15.PDef = set_combine(sets.engaged.DW30.PDef, {ear1="Eabani Earring",feet="Hizamaru Sune-Ate +2"})

    sets.engaged.MEVA = {main="Heishi Shorinken",sub="Shuhansadamune",ammo="Date Shuriken",
        head="Kendatsuba Jinpachi +1",neck="Ninja Nodowa +2",ear1="Brutal Earring",ear2="Telos Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Gere Ring",ring2="Epona's Ring",
        back=gear.TPCape,waist="Engraved Belt",legs="Malignance Tights",feet="Malignance Boots"}
    -- Heishi/Shuriken: acc~1329/1304/1223, haste+26, stp+75, da+9, ta+12, pdt-35, dt-25, sb=43, eva~1089, meva+672
    sets.engaged.DW30.MEVA = set_combine(sets.engaged.MEVA, {ear1="Eabani Earring",waist="Reiki Yotai"})
    sets.engaged.DW15.MEVA = set_combine(sets.engaged.DW30.MEVA, {})

    sets.engaged.MEVA.PDef = set_combine(sets.engaged.MEVA, {ring1="Vocane Ring +1",ring2="Defending Ring"})
    sets.engaged.DW30.MEVA.PDef = set_combine(sets.engaged.MEVA.PDef, {ear1="Eabani Earring",waist="Reiki Yotai"})
    sets.engaged.DW15.MEVA.PDef = set_combine(sets.engaged.DW30.MEVA.PDef, {})

    sets.engaged.Acc = set_combine(sets.engaged, {head="Kendatsuba Jinpachi +1",legs="Kendatsuba Hakama +1",feet="Kendatsuba Sune-Ate +1"})
    -- Heishi/Shuriken: acc~1323/1298/1173, haste+26, stp+40, da+9, ta+30, qa+2, pdt-10, meva+539
    sets.engaged.DW30.Acc = set_combine(sets.engaged.Acc, {body="Adhemar Jacket +1",waist="Reiki Yotai"})
    sets.engaged.DW15.Acc = set_combine(sets.engaged.DW30.Acc, {feet="Hizamaru Sune-Ate +2"})

    sets.engaged.Acc.PDef = set_combine(sets.engaged.Acc, {
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Vocane Ring +1",ring2="Defending Ring",
        legs="Malignance Tights",feet="Malignance Boots"})
    sets.engaged.DW30.Acc.PDef = set_combine(sets.engaged.Acc.PDef, {waist="Reiki Yotai"})
    sets.engaged.DW15.Acc.PDef = set_combine(sets.engaged.DW30.Acc.PDef, {feet="Hizamaru Sune-Ate +2"})

    -- Spells default to a midcast of FastRecast before layering on the above sets
    sets.midcast.FastRecast = set_combine(sets.defense.EvaPDT, {})
    sets.hpup = {
        head="Genmei Kabuto",neck="Unmoving Collar +1",ear1="Odnowa Earring +1",ear2="Etiolation Earring",
        body="Adhemar Jacket",hands="Malignance Gloves",ring1="Etana Ring",ring2="Regal Ring",
        back="Moonbeam Cape",waist="Oneiros Belt",legs="Kendatsuba Hakama +1",feet="Kendatsuba Sune-Ate +1"}
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.
function job_precast(spell, action, spellMap, eventArgs)
    if S{'Defender','Souleater','Last Resort'}:contains(spell.english) and buffactive[spell.english] then
        send_command('cancel '..spell.english)
        eventArgs.cancel = true
    elseif spell.type == 'WeaponSkill' then
        state.aeonic_aftermath_precast = (buffactive["Aftermath: Lv.1"] or buffactive["Aftermath: Lv.2"] or buffactive["Aftermath: Lv.3"])
    elseif state.SIRDUtsu.value and spellMap == 'Utsusemi' then
        enable('main','sub')
        state.CombatWeapon:set('None')
    end
end

-- Run after the general precast() is done.
function job_post_precast(spell, action, spellMap, eventArgs)
    if spell.type == 'WeaponSkill' then
        if buffactive['elvorseal'] then
            if player.inventory["Heidrek Boots"] then equip({feet="Heidrek Boots"}) end
        end
        if state.WeaponskillMode.value == 'NoDmg' then
            if info.magic_ws:contains(spell.english) then
                equip(sets.naked)
            else
                equip(sets.precast.WS.NoDmg)
            end
        elseif info.obi_ws:contains(spell.english) and S{world.day_element,world.weather_element}:contains(spell.element) then
            equip({waist="Hachirin-no-Obi"})
        elseif S{'Blade: Shun','Blade: Ten','Blade: Metsu','Blade: Kamu'}:contains(spell.english) then
            if world.time < 7*60 or 17*60 <= world.time then
                equip(sets.lugra)
            end
            if     spell.english == 'Blade: Shun' and S{'Fire','Light','Lightning'}:contains(world.day_element) then
                equip(sets.gavialis)
            elseif spell.english == 'Blade: Kamu' and S{'Wind','Lightning','Dark'}:contains(world.day_element) then
                equip(sets.gavialis)
            elseif spell.english == 'Evisceration' and S{'Earth','Dark','Light'}:contains(world.day_element) then
                equip(sets.gavialis)
            end
        end
    end
    if state.RangedMode.value == 'Shuriken' then
        equip(sets.weapons.Daken)
    end
end

-- Run after the default midcast() is done.
-- eventArgs is the same one used in job_midcast, in case information needs to be persisted.
function job_post_midcast(spell, action, spellMap, eventArgs)
    if spellMap == 'ElementalNinjutsu' then
        if state.MagicBurst.value then
            equip(sets.midcast.ElementalNinjutsu.MB)
        end
        if state.CombatWeapon.value == 'None' and state.RangedMode.value == 'Blink' and spell.english:startswith('Raiton') then
            equip(sets.donargun)
        end
        if state.Buff.Futae then
            equip(sets.buff.Futae)
        end
    elseif spellMap == 'EnfeeblingNinjutsu' then
        if state.CombatWeapon.value == 'None' and state.RangedMode.value == 'Blink' then
            equip(sets.kajabow)
        end
    elseif spellMap == 'Utsusemi' then
        if     spell.english:endswith('Ichi') and state.LastUtsu.value > 1 then
            send_command('cancel copy image,copy image (2),copy image (3)')
        elseif spell.english:endswith('Ni')   and state.LastUtsu.value > 2 then
            send_command('cancel copy image,copy image (2),copy image (3),copy image (4+)')
        end
        if not state.Buff.Yonin and state.CastingMode.value == 'Enmity' then
            -- always cast utsusemi in dt gear without yonin
            equip(sets.midcast.FastRecast, sets.midcast.Utsusemi)
        end
        if state.SIRDUtsu.value then
            equip(sets.midcast.Utsusemi.SIRD)
        end
    end
    if state.RangedMode.value == 'Shuriken' then
        equip(sets.weapons.Daken)
    end
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_aftercast(spell, action, spellMap, eventArgs)
    if spell.interrupted then
        send_command('wait 0.5;gs c update')
        if buffactive.Amnesia and S{'JobAbility','WeaponSkill'}:contains(spell.type) then
            add_to_chat(123, 'Amnesia prevents using '..spell.english)
        elseif buffactive.Silence and S{'Ninjutsu'}:contains(spell.type) then
            add_to_chat(123, 'Silence prevents using '..spell.english)
        elseif has_any_buff_of(S{'Petrification','Sleep','Stun','Terror'}) then
            add_to_chat(123, 'Status prevents using '..spell.english)
        end
    elseif spell.type == 'WeaponSkill' then
        if state.WSMsg.value then
            if spell.target.name ~= 'Bozzetto Mine' then
                ws_msg(spell)
            end
        end
    elseif spell.english == 'Migawari: Ichi' then
        if state.AutoHybrid.value == 'Miga' and player_has_shadows() then
            state.HybridMode:set('Normal')
        end
    elseif spellMap == 'Utsusemi' then
        if     spell.english:endswith('Ichi') then
            state.LastUtsu:set(1)
        elseif spell.english:endswith('Ni') then
            state.LastUtsu:set(2)
        elseif spell.english:endswith('San') then
            state.LastUtsu:set(3)
        end
        if     state.AutoHybrid.value == 'Utsu' then
            state.HybridMode:set('Normal')
        elseif state.AutoHybrid.value == 'Miga' and state.Buff.Migawari then
            state.HybridMode:set('Normal')
        end
        if state.SIRDUtsu.value then
            state.SIRDUtsu:unset()
        end
    elseif spell.type == 'JobAbility' then
        if not sets.precast.JA[spell.english] then
            eventArgs.handled = true
        end
    elseif spell.type == 'Rune' then
        eventArgs.handled = true
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for non-casting events.
-------------------------------------------------------------------------------------------------------------------

-- Called when a player gains or loses a buff.
-- buff == buff gained or lost
-- gain == true if the buff was gained, false if it was lost.
function job_buff_change(buff, gain)
    local lbuff = buff:lower()
    if state.DefenseMode.value == 'None' and S{'stun','terror','petrification'}:contains(lbuff) then
        if gain then
            if state.RangedMode.value == 'Tathlum' then
                equip(sets.engaged.PDef, sets.weapons.DTTathlum)
            else
                equip(sets.engaged.PDef)
            end
        elseif not midaction() then
            handle_equipping_gear(player.status)
        end
    elseif state.AutoHybrid.value ~= 'off' and lbuff:startswith('copy ') then
        if gain or player_has_shadows() then
            if state.AutoHybrid.value == 'Utsu' or state.Buff.Migawari then
                state.HybridMode:set('Normal')
            end
        else
            state.HybridMode:set('PDef')
            if not midaction() then
                handle_equipping_gear(player.status)
            end
        end
    elseif state.AutoHybrid.value == 'Miga' and lbuff == 'migawari' then
        if gain and player_has_shadows() then
            state.HybridMode:set('Normal')
        else
            state.HybridMode:set('PDef')
            if not midaction() then
                handle_equipping_gear(player.status)
            end
        end
    elseif not midaction() then
        if lbuff == 'doom' then
            handle_equipping_gear(player.status)
        elseif lbuff == 'phalanx' then
            if gain then
                handle_equipping_gear(player.status)
            end
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
        handle_equipping_gear(player.status)
        if newValue ~= 'None' then
            equip(sets.weapons[state.CombatWeapon.value])
            disable('main','sub','range')
        end
    elseif stateField == 'Combat Weapon' then
        enable('main','sub','range','ammo')
        if state.OffenseMode.value ~= 'None' then
            equip(sets.weapons[state.CombatWeapon.value])
            if state.CombatWeapon.value ~= 'None' then
                disable('main','sub','range')
            end
            set_weaponskill_keybinds()
        end
    elseif stateField == 'Hybrid Mode' then
        if state.AutoHybrid.value ~= 'off' then
            state.AutoHybrid:reset()
            add_to_chat(104,state.AutoHybrid.description .. ' is now ' .. state.AutoHybrid.current .. '.')
        end
    elseif stateField == 'Auto Hybrid' and newValue ~= 'off' then
        if player_has_shadows() and (newValue == 'Utsu' or state.Buff.Migawari) then
            state.HybridMode:set('Normal')
        else
            state.HybridMode:set('PDef')
        end
    elseif stateField == 'Ranged Mode' then
        if not midaction() then
            handle_equipping_gear(player.status)
        end
    elseif stateField:endswith('Defense Mode') then
        if newValue == 'MDT50' then
            state.DefenseMode:set('Magical')
        end
    elseif stateField == 'Fishing Gear' then
        if newValue then
            state.Cooking:unset()
            sets.Fishing = {range="Ebisu Fishing Rod +1",ammo=empty,
                head="Tlahtlamah Glasses",neck="Fisher's Torque",
                body="Fisherman's Smock",hands="Angler's Gloves",ring1="Noddy Ring",ring2="Puffin Ring",
                waist="Fisher's Rope",legs="Angler's Hose",feet="Waders"}
            enable('range')
            equip(sets.Fishing)
            disable('range','ammo','ring1','ring2')
            send_command('bind ^numpad0 input /fish')
        else
            enable('ammo','ring1','ring2')
        end
    elseif stateField == 'Cooking Gear' then
        if newValue then
            state.Fishing:unset()
            sets.Cooking = {main="Hocho",sub="Chef's Shield",
                head="Chef's Hat",neck="Culinarian's Torque",
                body="Culinarian's Smock",ring1="Craftmaster's Ring",ring2="Artificer's Ring"}
            equip(sets.Cooking)
            enable('main','sub')
            send_command('bind ^numpad0 input /lastsynth')
        else
            equip(sets.weapons[state.CombatWeapon.value])
            disable('main','sub')
        end
    elseif stateField == 'HELM Gear' then
        if newValue then
            sets.HELM = {body="Trench Tunic",hands="Treefeller Gloves",
                waist="Field Rope",legs="Dredger Hose",feet="Agrarian Boots"}
            equip(sets.idle, sets.HELM)
            send_command('alias sickle  input /item "Sickle"<t>')
            send_command('alias tsickle input /item "Trbl. Sickle"<t>')
            send_command('alias axe     input /item "Hatchet"<t>')
            send_command('alias taxe    input /item "Trbl. Hatchet"<t>')
            send_command('alias pick    input /item "Pickaxe"<t>')
            send_command('alias tpick   input /item "Trbl. Pickaxe"<t>')
        end
    end
end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements standard library decisions.
-------------------------------------------------------------------------------------------------------------------

-- Modify the default idle set after it was constructed.
function customize_idle_set(idleSet)
    if state.DefenseMode.value == 'None' then
        if 7*60 <= world.time and world.time < 17*60 then
            if S{'Normal','Rf'}:contains(state.IdleMode.value) then
                idleSet = set_combine(idleSet, sets.danzo)
            end
            sets.Kiting = sets.danzo
        else
            sets.Kiting = sets.hachiya
        end
        if state.Fishing.value then
            idleSet = set_combine(idleSet, sets.Fishing)
            if state.Kiting.value then
                idleSet = set_combine(idleSet, sets.Kiting)
            end
        end
        if state.Cooking.value then
            idleSet = set_combine(idleSet, sets.Cooking)
            if state.Kiting.value then
                idleSet = set_combine(idleSet, sets.Kiting)
            end
        end
        if state.HELM.value then
            idleSet = set_combine(idleSet, sets.HELM)
            if state.Kiting.value then
                idleSet = set_combine(idleSet, sets.Kiting)
            end
        end
    end
    if state.Buff.doom then
        idleSet = set_combine(idleSet, sets.buff.doom)
    end
    if state.RangedMode.value == 'Shuriken' then
        idleSet = set_combine(idleSet, sets.weapons.Daken)
    end
    return idleSet
end

-- Modify the default melee set after it was constructed.
function customize_melee_set(meleeSet)
    if state.Buff.doom then
        meleeSet = set_combine(meleeSet, sets.buff.doom)
    end
    if buffactive['elvorseal'] then
        if player.inventory["Heidrek Gloves"] then meleeSet = set_combine(meleeSet, {hands="Heidrek Gloves"}) end
    end
    if state.RangedMode.value == 'Shuriken' then
        meleeSet = set_combine(meleeSet, sets.weapons.Daken)
    elseif state.DefenseMode.value == 'None' then
        if state.RangedMode.value == 'Tathlum' then
            meleeSet = set_combine(meleeSet, sets.weapons.TPTathlum)
        else
            meleeSet = set_combine(meleeSet, sets.weapons.Daken)
        end
    end
    return meleeSet
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
    msg = msg .. '] WS[' .. state.WeaponskillMode.current .. ']'
    msg = msg .. ' RA[' .. state.RangedMode.value .. ']'
    msg = msg .. ' Utsu[' .. state.CastingMode.value .. ']'
    msg = msg .. ' Idle[' .. state.IdleMode.current .. ']'

    if state.DefenseMode.value ~= 'None' then
        local defMode = state[state.DefenseMode.value ..'DefenseMode'].current
        msg = msg .. ' Def[' .. state.DefenseMode.value .. ':' .. defMode .. ']'
    end
    if state.MagicBurst.value then
        msg = msg .. ' MB+'
    end
    if state.WSMsg.value then
        msg = msg .. ' WSMsg'
    end
    if state.AutoHybrid.value ~= 'off' then
        msg = msg .. ' AH:' .. state.AutoHybrid.value
    end
    if state.SIRDUtsu.value then
        msg = msg .. ' SIRD'
    end
    if state.TreasureMode.value ~= 'None' then
        msg = msg .. ' TH+4'
    end
    if state.Fishing.value then
        msg = msg .. ' Fishing'
    end
    if state.Cooking.value then
        msg = msg .. ' Cooking'
    end
    if state.HELM.value then
        msg = msg .. ' HELM'
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
    report_ninja_tools()

    eventArgs.handled = true
end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements self-commands.
-------------------------------------------------------------------------------------------------------------------

-- Called for custom player commands.
function job_self_command(cmdParams, eventArgs)
    if     cmdParams[1] == 'CountTools' then
        report_ninja_tools()
    elseif cmdParams[1] == 'ListWS' then
        add_to_chat(122, 'ListWS:')
        for _,ws in ipairs(info.ws_binds[info.weapon_type[state.CombatWeapon.value]]) do
            add_to_chat(122, "%3s : %s":format(ws.bind,ws.ws))
        end
    elseif cmdParams[1] == 'donar' then
        enable('range','ammo')
        equip(sets.donargun)
        disable('range','ammo')
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    set_macro_page(1,13)
    send_command('bind !^l input /lockstyleset 13')
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

-- prints a message with counts of ninja tools
function report_ninja_tools()
    local bag_ids = T{['Inventory']=0,['Wardrobe']=8,['Wardrobe 2']=10,['Wardrobe 3']=11,['Wardrobe 4']=12}
    local ntools = T{}
    local shihei_id = 1179
    local shika_id  = 2972
    local cho_id    = 2973
    local ino_id    = 2971
    local date_id   = 22292
    local id_set = S{shihei_id,shika_id,cho_id,ino_id,date_id}
    ntools[shihei_id] = 0
    ntools[shika_id]  = 0
    ntools[cho_id]    = 0
    ntools[ino_id]    = 0
    ntools[date_id]  = 0

    for bag in T{'Inventory','Wardrobe','Wardrobe 2','Wardrobe 3','Wardrobe 4'}:it() do
        for _,item in ipairs(windower.ffxi.get_items(bag_ids[bag])) do
            if type(item) == 'table' then
                if id_set:contains(item.id) then
                    ntools[item.id] = ntools[item.id] + item.count
                end
            end
        end
    end

    add_to_chat(122, 'shihei(%d) shika(%d) chono(%d) ino(%d) date(%d)':format(
        ntools[shihei_id],ntools[shika_id],ntools[cho_id],ntools[ino_id],ntools[date_id]))
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

-- returns true if player has a copy image buff
function player_has_shadows()
    return buffactive['Copy Image'] or buffactive['Copy Image (2)'] or buffactive['Copy Image (3)'] or buffactive['Copy Image (4+)']
end

function init_state_text()
    destroy_state_text()
    local mb_text_settings   = {flags={draggable=false},bg={alpha=150}}
    local nodmg_text_settings= {pos={x=53},flags={draggable=false},bg={alpha=150}}
    local swap_text_settings = {pos={y=18},flags={draggable=false},bg={alpha=150}}
    local sird_text_settings = {pos={y=36},flags={draggable=false},bg={alpha=150}}
    local hyb_text_settings  = {pos={x=130,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local def_text_settings  = {pos={x=172,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local off_text_settings  = {pos={x=172,y=697},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local dw_text_settings   = {pos={x=130,y=697},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    state.mb_text   = texts.new('MBurst', mb_text_settings)
    state.nodmg_text= texts.new('NoDmg', nodmg_text_settings)
    state.swap_text = texts.new('NoTP', swap_text_settings)
    state.sird_text = texts.new('SIRD', sird_text_settings)
    state.hyb_text  = texts.new('/${hybrid}', hyb_text_settings)
    state.def_text  = texts.new('(${defense})', def_text_settings)
    state.off_text  = texts.new('${offense}', off_text_settings)
    state.dw_text   = texts.new('${dw}', dw_text_settings)

    state.texts_event_id = windower.register_event('prerender', function()
        state.mb_text:visible(state.MagicBurst.value)
        state.nodmg_text:visible((state.WeaponskillMode.value == 'NoDmg'))
        state.swap_text:visible((state.CombatWeapon.value == 'None'))
        state.sird_text:visible(state.SIRDUtsu.value)

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

        if state.CombatForm.has_value then
            state.dw_text:visible(true)
            state.dw_text:update({['dw']=state.CombatForm.value})
        else
            state.dw_text:visible(false)
        end
    end)
end

function destroy_state_text()
    if state.texts_event_id then
        windower.unregister_event(state.texts_event_id)
        state.mb_text:visible(false)
        state.nodmg_text:visible(false)
        state.swap_text:visible(false)
        state.sird_text:visible(false)
        state.hyb_text:visible(false)
        state.def_text:visible(false)
        state.off_text:visible(false)
        state.dw_text:visible(false)
        texts.destroy(state.mb_text)
        texts.destroy(state.nodmg_text)
        texts.destroy(state.swap_text)
        texts.destroy(state.sird_text)
        texts.destroy(state.hyb_text)
        texts.destroy(state.def_text)
        texts.destroy(state.off_text)
        texts.destroy(state.dw_text)
    end
end
