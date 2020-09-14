-- Modified from 'https://github.com/Kinematics/GearSwap-Jobs/blob/master/GEO.lua'
-- TODO enmity sets, check pdt in all sets, paranoid casting sets
-- TODO proper melee sets
-- TODO option to do geo bubble at max range between you and target
--      or maybe a toggle to copy and repeat offsets between bubble casts
--      (ie, set toggle, cast at offset from menu, then further casts copy offsets used)

-- notes:
-- pet dt-38 to cap, from 50% base
-- bolster is retroactive for indi, not for geo, and sticky for entrust
-- entrust uses +geomancy gear of target instead of caster. haste is less penalized than most common colures
-- base luopan hp drain 24/tick, EA 30/tick
-- base cmp is 43, so 57 to cap
-- stand in place for trick attacks
-- chug remedies, carry coalition ethers and vile elixirs

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
    state.Buff['Widened Compass']   = buffactive['widened compass'] or false
    state.Buff['Blaze of Glory']    = buffactive['blaze of glory'] or false
    state.Buff.Bolster              = buffactive.bolster or false
    state.Buff.Entrust              = buffactive.entrust or false
    state.Buff['Collimated Fervor'] = buffactive['collimated fervor'] or false
    state.Buff.doom                 = buffactive.doom or false
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
    state.OffenseMode:options('None','Normal')                          -- Cycle with F9, will swap weapon
    state.HybridMode:options('Normal','PDef')                           -- Cycle with ^F9
    state.CastingMode:options('Normal','Resistant')--,'Paranoid')       -- Cycle with F10
    state.IdleMode:options('Normal','PDT','MEVA')                       -- Cycle with F11
    state.MagicalDefenseMode:options('MEVA')
    state.CombatWeapon = M{['description']='Combat Weapon'}
    if S{'DNC','NIN'}:contains(player.sub_job) then
        state.CombatWeapon:options('Club','Staff','Dagger')
		state.CombatForm:set('DW')
    else
        state.CombatWeapon:options('Club','Staff','Dagger')
		state.CombatForm:reset()
    end

    state.Seidr          = M(false, 'Seidr Nukes')                      -- Toggle with !@z
    state.AutoSeidr      = M(true,  'Seidr Sometimes')                  -- Toggle with ~!@z
    state.AutoSeidr.low_mp = 750
    state.MagicBurst     = M(false, 'Magic Burst')                      -- Toggle with !z
    state.ZendikIdle     = M(false, 'Zendik Sphere')                    -- Toggle with ^z
    state.AllyBinds      = M(false, 'Ally Cure Keybinds')               -- Toggle with !^numpad0
    state.CardinalMsg    = M(false, 'Cardinal Chant Message')           -- Toggle with ^\
    state.GeoHUD         = M(true,  'Geomancy HUD')                     -- Toggle with !^\

    -- timer variables set in job_aftercast
    -- 180 base, +40 JP, +20% cape, +12-21 bagua pants, +20 azimuth gaiters, +15 solstice
    info.indi_dur       = math.floor(1.20 * (180 + 40 + 15 + 20 + 15))
    info.indi_dur_melee = math.floor(1.20 * (180 + 40 + 15 + 20))
    geo_state_updates()
    init_state_text()

    -- Augmented items get variables for convenience and specificity
    gear.MACape   = {name="Nantosuelta's Cape",
		augments={'MND+20','Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+10','"Fast Cast"+10','Phys. dmg. taken-10%'}}
    gear.PetCape  = {name="Nantosuelta's Cape",
        augments={'HP+60','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Pet: "Regen"+10','Pet: Damage taken -5%'}}
    gear.NukeCape = {name="Nantosuelta's Cape",
        augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','INT+10','"Mag.Atk.Bns."+10','Phys. dmg. taken-10%'}}
    gear.TPCape   = {name="Nantosuelta's Cape",
        augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Dbl.Atk."+10','Phys. dmg. taken-10%'}}
    --gear.DWCape   = TODO
    gear.WSCape   = {name="Nantosuelta's Cape",
        augments={'MND+20','Accuracy+20 Attack+20','MND+10','Weapon skill damage +10%','Phys. dmg. taken-10%'}}

    gear.mer_head_rf   = {name="Merlinic Hood", augments={'INT+9','Pet: INT+2','"Refresh"+1'}}
    gear.mer_hand_phlx = {name="Merlinic Dastanas",
        augments={'AGI+8','Pet: Attack+17 Pet: Rng.Atk.+17','Phalanx +3','Accuracy+14 Attack+14'}}
    gear.mer_legs_th   = {name="Merlinic Shalwar",
        augments={'DEX+8','"Drain" and "Aspir" potency +4','"Treasure Hunter"+1','Accuracy+20 Attack+20'}}
    gear.mer_feet_fc   = {name="Merlinic Crackows", augments={'Mag. Acc.+11','"Fast Cast"+6'}}
    gear.mer_feet_dr   = {name="Merlinic Crackows", augments={'Mag. Acc.+28','"Drain" and "Aspir" potency +11','"Mag.Atk.Bns."+7'}}
    gear.mer_feet_th   = {name="Merlinic Crackows", augments={'DEX+14','STR+10','"Treasure Hunter"+1','Mag. Acc.+8 "Mag.Atk.Bns."+8'}}
    gear.mer_feet_ws   = {name="Merlinic Crackows",
        augments={'DEX+9','Enmity+1','Weapon skill damage +6%','Accuracy+16 Attack+16','Mag. Acc.+19 "Mag.Atk.Bns."+19'}}
    gear.tel_head_pet  = {name="Telchine Cap", augments={'Mag. Evasion+25','Pet: "Regen"+2','Pet: Damage taken -4%'}}
    gear.tel_head_enh  = {name="Telchine Cap", augments={'Mag. Evasion+22','"Conserve MP"+5','Enh. Mag. eff. dur. +7'}}
    gear.tel_body_enh  = {name="Telchine Chas.", augments={'Mag. Evasion+19','"Conserve MP"+5','Enh. Mag. eff. dur. +7'}}
    gear.tel_hand_enh  = {name="Telchine Gloves", augments={'Mag. Evasion+19','"Fast Cast"+5','Enh. Mag. eff. dur. +9'}}
    gear.tel_legs_enh  = {name="Telchine Braconi", augments={'Mag. Evasion+19','"Conserve MP"+3','Enh. Mag. eff. dur. +9'}}
    gear.tel_feet_enh  = {name="Telchine Pigaches", augments={'Mag. Evasion+17','"Conserve MP"+5','Enh. Mag. eff. dur. +7'}}

    send_command('bind %`|F12 gs c update user')
    send_command('bind F9   gs c cycle OffenseMode')
    send_command('bind !F9  gs c reset OffenseMode')
    send_command('bind @F9  gs c cycle CombatWeapon')
    send_command('bind F10  gs c cycle CastingMode')
    send_command('bind !F10 gs c reset CastingMode')
    send_command('bind F11  gs c cycle IdleMode')
    send_command('bind !F11 gs c reset IdleMode')
    send_command('bind @F11 gs c toggle Kiting')
    send_command('bind ^space gs c cycle HybridMode')
    send_command('bind !space gs c set DefenseMode Physical')
    send_command('bind @space gs c set DefenseMode Magical')
    send_command('bind !@space gs c reset DefenseMode')
    send_command('bind !^q gs c set CombatWeapon Staff')
    send_command('bind !^w gs c weap Club')
    send_command('bind !^e gs c weap Day')
    send_command('bind !^r gs c weap Dagger')
    send_command('bind !w   gs c set   OffenseMode Normal')
    send_command('bind !@w  gs c reset OffenseMode')
    send_command('bind ^z   gs c toggle ZendikIdle')
    send_command('bind !z   gs c toggle MagicBurst')
    send_command('bind !@z  gs c toggle Seidr')
    send_command('bind ~!@z gs c toggle AutoSeidr')
    send_command('bind ^c   gs c CureCheat')
    send_command('bind ^\\\\  gs c toggle CardinalMsg')
    send_command('bind !^\\\\ gs c toggle GeoHUD')
    send_command('bind %~q input /target <pet>')

    send_command('bind !^` input /ja Bolster <me>')
    send_command('bind ^@` input /ja "Widened Compass" <me>')
    send_command('bind ^`  input /ja "Blaze of Glory" <me>')
    send_command('bind @`  input /ja Dematerialize <me>')
    send_command('bind !`  input /ja Entrust <me>')
    send_command('bind  ^@tab input /ja "Ecliptic Attrition" <me>')
    send_command('bind ~^@tab input /ja "Life Cycle" <me>')
    send_command('bind @tab input /ja "Radial Arcana" <me>')
    send_command('bind @q   input /ja "Full Circle" <me>')
    send_command('bind ^@q  input /ja "Concentric Pulse"')

    send_command('bind ^-|^@-|!-|!@-|%- input /ja "Theurgic Focus" <me>')
    send_command('bind ^=|^@=|!=|!@=|%= input /ja "Collimated Fervor" <me>')

    send_command('bind ^1   input /ma "Dia II"')
    send_command('bind ^@1  input /ma "Bio II"')
    send_command('bind ~^@1 input /ma Diaga <stnpc>')
    send_command('bind ^2   input /ma Slow')
    send_command('bind ^@2  input /ma Blind')
    send_command('bind ^3   input /ma Paralyze')
    send_command('bind ^@3  input /ma Bind <stnpc>')
    send_command('bind ^4   input /ma Silence')
    send_command('bind ^@4  input /ma Gravity')
    send_command('bind ^5   input /ma "Sleep II" <stnpc>')
    send_command('bind ^@5  input /ma Sleep <stnpc>')
    send_command('bind ^backspace input /ma Impact')

    send_command('bind !1 input /ma "Cure III" <stpc>')
    send_command('bind !2 input /ma "Cure IV" <stpc>')
    send_command('bind !3 input /ma Distract')
    send_command('bind !4 input /ma Frazzle')
    send_command('bind !5 input /ma Haste <stpc>')
    send_command('bind !6 input /ma Refresh <stpc>')
    send_command('bind !7 input /ma Flurry <stpc>')

    send_command('bind ~@8 input /ma "Stone III"')
    send_command('bind ~@9 input /ma "Water III"')
    send_command('bind ~@0 input /ma "Aero III"')
    send_command('bind  @8 input /ma "Fire III"')
    send_command('bind  @9 input /ma "Blizzard III"')
    send_command('bind  @0 input /ma "Thunder III"')

    send_command('bind ~!8 input /ma "Stone IV"')
    send_command('bind ~!9 input /ma "Water IV"')
    send_command('bind ~!0 input /ma "Aero IV"')
    send_command('bind  !8 input /ma "Fire IV"')
    send_command('bind  !9 input /ma "Blizzard IV"')
    send_command('bind  !0 input /ma "Thunder IV"')

    send_command('bind ~!@8|%~8 input /ma "Stone V"')
    send_command('bind ~!@9|%~9 input /ma "Water V"')
    send_command('bind ~!@0|%~0 input /ma "Aero V"')
    send_command('bind  !@8|%8  input /ma "Fire V"')
    send_command('bind  !@9|%9  input /ma "Blizzard V"')
    send_command('bind  !@0|%0  input /ma "Thunder V"')

    send_command('bind ~^@8 input /ma "Stonera II"')
    send_command('bind ~^@9 input /ma "Watera II"')
    send_command('bind ~^@0 input /ma "Aera II"')
    send_command('bind  ^@8 input /ma "Fira II"')
    send_command('bind  ^@9 input /ma "Blizzara II"')
    send_command('bind  ^@0 input /ma "Thundara II"')

    send_command('bind ~^8 input /ma "Stonera III"')
    send_command('bind ~^9 input /ma "Watera III"')
    send_command('bind ~^0 input /ma "Aera III"')
    send_command('bind  ^8 input /ma "Fira III"')
    send_command('bind  ^9 input /ma "Blizzara III"')
    send_command('bind  ^0 input /ma "Thundara III"')

    send_command('bind !f  input /ma Haste     <me>')
    send_command('bind !g  input /ma Phalanx   <me>')
    send_command('bind !@g input /ma Stoneskin <me>')
    send_command('bind !b  input /ma Refresh   <me>')
    send_command('bind @c  input /ma Blink     <me>')
    send_command('bind @v  input /ma Aquaveil  <me>')

    send_command('bind ^q  input /ma Dispelga')
    send_command('bind @d input /ma "Aspir II"')
    send_command('bind !d  input /ma "Aspir III"')
    send_command('bind !@d input /ma Drain')

    info.ally_keybinds = make_keybind_list(L{
        'bind %~numpad1 input /ma Cure <p0>',
        'bind %~numpad2 input /ma Cure <p1>',
        'bind %~numpad3 input /ma Cure <p2>',
        'bind %~numpad4 input /ma Cure <p3>',
        'bind %~numpad5 input /ma Cure <p4>',
        'bind %~numpad6 input /ma Cure <p5>',
        'bind ^numpad1 input /ma Cure <a10>',
        'bind ^numpad2 input /ma Cure <a11>',
        'bind ^numpad3 input /ma Cure <a12>',
        'bind ^numpad4 input /ma Cure <a13>',
        'bind ^numpad5 input /ma Cure <a14>',
        'bind ^numpad6 input /ma Cure <a15>',
        'bind !numpad1 input /ma Cure <a20>',
        'bind !numpad2 input /ma Cure <a21>',
        'bind !numpad3 input /ma Cure <a22>',
        'bind !numpad4 input /ma Cure <a23>',
        'bind !numpad5 input /ma Cure <a24>',
        'bind !numpad6 input /ma Cure <a25>',
        'bind %~^numpad1 input /ma "Cure IV" <p0>',
        'bind %~^numpad2 input /ma "Cure IV" <p1>',
        'bind %~^numpad3 input /ma "Cure IV" <p2>',
        'bind %~^numpad4 input /ma "Cure IV" <p3>',
        'bind %~^numpad5 input /ma "Cure IV" <p4>',
        'bind %~^numpad6 input /ma "Cure IV" <p5>',
        'bind ^@numpad1 input /ma "Cure IV" <a10>',
        'bind ^@numpad2 input /ma "Cure IV" <a11>',
        'bind ^@numpad3 input /ma "Cure IV" <a12>',
        'bind ^@numpad4 input /ma "Cure IV" <a13>',
        'bind ^@numpad5 input /ma "Cure IV" <a14>',
        'bind ^@numpad6 input /ma "Cure IV" <a15>',
        'bind !@numpad1 input /ma "Cure IV" <a20>',
        'bind !@numpad2 input /ma "Cure IV" <a21>',
        'bind !@numpad3 input /ma "Cure IV" <a22>',
        'bind !@numpad4 input /ma "Cure IV" <a23>',
        'bind !@numpad5 input /ma "Cure IV" <a24>',
        'bind !@numpad6 input /ma "Cure IV" <a25>'})
    send_command('bind !^numpad0 gs c toggle AllyBinds')

    info.ws_binds = make_keybind_list(T{
        ['Club']=L{
            'bind !^1 input /ws "Flash Nova"',
            'bind !^2 input /ws "Hexa Strike"',
            'bind !^3 input /ws "Black Halo"',
            'bind !^4 input /ws "Realmrazer"',
            'bind !^5 input /ws "Judgment"',
            'bind !^6 input /ws "Moonlight"',
            'bind !^d input /ws "Brainshaker"'},
        ['Staff']=L{
            'bind !^1 input /ws "Spirit Taker"',
            'bind !^2 input /ws "Sunburst"',
            'bind !^3 input /ws "Shattersoul"',
            'bind !^4 input /ws "Retribution"',
            'bind !^6 input /ws "Cataclysm"',
            'bind !^d input /ws "Shell Crusher"'},
        ['Dagger']=L{
            'bind !^1 input /ws "Energy Drain"',
            'bind !^2 input /ws "Wasp Sting"',
            'bind !^3 input /ws "Gust Slash"',
            'bind !^4 input /ws "Viper Bite"',
            'bind !^6 input /ws "Aeolian Edge"',
            'bind !^d input /ws "Shadowstitch"'}},
        {['Club']='Club',['Dagger']='Dagger',['Staff']='Staff'})
    info.ws_binds:bind(state.CombatWeapon)
    send_command('bind %\\\\ gs c ListWS')

    send_command('bind %1|~^1 gs c lastgeo')
    send_command('bind %3|~^3 gs c lastindi')
    info.bubble_binds = make_keybind_list(L{
        'bind %2|~^2   input /ma Geo-Frailty',
        'bind %4|~^4   input /ma Geo-Wilt',
        'bind %5|~^5   input /ma Geo-Malaise',
        'bind %6|~^6   input /ma Geo-Fade',
        'bind %7|~^7   input /ma Geo-Vex',
        'bind %~2|~!^2 input /ma Indi-Fury <stpc>',
        'bind %~4|~!^4 input /ma Indi-Wilt <stpc>',
        'bind %~5|~!^5 input /ma Indi-Haste <stpc>',
        'bind %~6|~!^6 input /ma Indi-Malaise <stpc>',
        'bind %~7|~!^7 input /ma Indi-Attunement <stpc>'})
    info.bubble_binds:bind()
    send_command('bind @backspace gs c ListBubs')

    info.recast_ids = L{{name="Entrust",id=93},{name="BoG",id=247},{name="EA",id=244},{name="Demat",id=248},
                        {name="Life Cycle",id=246},{name="Radial Arcana",id=252}}
    if     player.sub_job == 'RDM' then
        send_command('bind !@`  input /ja Convert <me>')
        send_command('bind ^tab input /ma Dispel')
        info.recast_ids:append({name="Convert",id=49})
    elseif player.sub_job == 'WHM' then
        send_command('bind ^tab input /ja "Divine Seal" <me>')
        send_command('bind !@1 input /ma Curaga')
        send_command('bind !@2 input /ma "Curaga II"')
        -- Status cure binds (never want to fumble these)
        send_command('bind @1 input /ma Poisona')
        send_command('bind @2 input /ma Paralyna')
        send_command('bind @3 input /ma Blindna')
        send_command('bind @4 input /ma Silena')
        send_command('bind @5 input /ma Stona')
        send_command('bind @6 input /ma Viruna')
        send_command('bind @7 input /ma Cursna')
        send_command('bind @F1 input /ma Erase')
        info.recast_ids:append({name="D.Seal",id=26})
    elseif player.sub_job == 'BLM' then
        send_command('bind ^tab input /ja "Elemental Seal" <me>')
        send_command('bind ~^@5 input /ma Sleepga')
        send_command('bind !e   input /ma Stun')
        info.recast_ids:append({name="E.Seal",id=38})
    elseif player.sub_job == 'DRK' then
        -- TODO
    elseif player.sub_job == 'DNC' then
        -- TODO
    elseif player.sub_job == 'NIN' then
        send_command('bind !e  input /ma "Utsusemi: Ni" <me>')
        send_command('bind !@e input /ma "Utsusemi: Ichi" <me>')
    end

    select_default_macro_book()
end

-- Called when this job file is unloaded (eg: job change)
-- Unset job keybinds here.
function user_unload()
    send_command('unbind %`|F12')
    send_command('unbind F9')
    send_command('unbind !F9')
    send_command('unbind @F9')
    send_command('unbind F10')
    send_command('unbind !F10')
    send_command('unbind F11')
    send_command('unbind !F11')
    send_command('unbind @F11')
    send_command('unbind ^space')
    send_command('unbind !space')
    send_command('unbind @space')
    send_command('unbind !@space')
    send_command('unbind !^q')
    send_command('unbind !^w')
    send_command('unbind !^e')
    send_command('unbind !^r')
    send_command('unbind !w')
    send_command('unbind !@w')
    send_command('unbind !z')
    send_command('unbind !@z')
    send_command('unbind ~!@z')
    send_command('unbind %\\\\')
    send_command('unbind ^\\\\')
    send_command('unbind !^\\\\')
    send_command('unbind ^c')
    send_command('unbind %~q')

    send_command('unbind !^`')
    send_command('unbind ^@`')
    send_command('unbind ^`')
    send_command('unbind @`')
    send_command('unbind !`')
    send_command('unbind  ^@tab')
    send_command('unbind ~^@tab')
    send_command('unbind @tab')
    send_command('unbind @q')
    send_command('unbind ^@q')

    send_command('unbind ^-|^@-|!-|!@-|%-')
    send_command('unbind ^=|^@=|!=|!@=|%=')

    send_command('unbind %1|~^1')
    send_command('unbind %3|~^3')

    info.bubble_binds:unbind()
    send_command('unbind @backspace')

    send_command('unbind ^1')
    send_command('unbind ^@1')
    send_command('unbind ~^@1')
    send_command('unbind ^2')
    send_command('unbind ^@2')
    send_command('unbind ^3')
    send_command('unbind ^@3')
    send_command('unbind ^4')
    send_command('unbind ^@4')
    send_command('unbind ^5')
    send_command('unbind ~^5')
    send_command('unbind ^@5')
    send_command('unbind ^backspace')

    send_command('unbind !1')
    send_command('unbind !2')
    send_command('unbind !3')
    send_command('unbind !4')
    send_command('unbind !5')
    send_command('unbind !6')
    send_command('unbind !7')

    send_command('unbind ~@8')
    send_command('unbind ~@9')
    send_command('unbind ~@0')
    send_command('unbind  @8')
    send_command('unbind  @9')
    send_command('unbind  @0')

    send_command('unbind ~!8')
    send_command('unbind ~!9')
    send_command('unbind ~!0')
    send_command('unbind  !8')
    send_command('unbind  !9')
    send_command('unbind  !0')

    send_command('unbind ~!@8|%~8')
    send_command('unbind ~!@9|%~9')
    send_command('unbind ~!@0|%~0')
    send_command('unbind  !@8|%8')
    send_command('unbind  !@9|%9')
    send_command('unbind  !@0|%0')

    send_command('unbind ~^@8')
    send_command('unbind ~^@9')
    send_command('unbind ~^@0')
    send_command('unbind  ^@8')
    send_command('unbind  ^@9')
    send_command('unbind  ^@0')

    send_command('unbind ~^8')
    send_command('unbind ~^9')
    send_command('unbind ~^0')
    send_command('unbind  ^8')
    send_command('unbind  ^9')
    send_command('unbind  ^0')

    send_command('unbind !f')
    send_command('unbind !g')
    send_command('unbind !@g')
    send_command('unbind !b')
    send_command('unbind @c')
    send_command('unbind @v')

    send_command('unbind ^q')
    send_command('unbind ~@d')
    send_command('unbind @d')
    send_command('unbind !@d')

    send_command('unbind ^tab')
    send_command('unbind ^tab')
    send_command('unbind !@1')
    send_command('unbind !@2')
    send_command('unbind @1')
    send_command('unbind @2')
    send_command('unbind @3')
    send_command('unbind @4')
    send_command('unbind @5')
    send_command('unbind @6')
    send_command('unbind @7')
    send_command('unbind @F1')
    send_command('unbind ^tab')
    send_command('unbind ^@5')
    send_command('unbind !d')
    send_command('unbind !e')
    send_command('unbind @e')
    send_command('unbind !@e')

    if state.AllyBinds.value then info.ally_keybinds:unbind() end
    info.ws_binds:unbind()

    destroy_state_text()
end

-- Define sets and vars used by this job file.
function init_gear_sets()

    sets.weapons = {}
    sets.weapons.Club   = {main="Maxentius",sub="Genmei Shield",range="Dunna"}
    sets.weapons.Dagger = {main="Malevolence",sub="Genmei Shield",range="Dunna"}
    sets.weapons.Staff  = {main="Malignance Pole",sub="Kaja Grip",range="Dunna"}
    sets.TreasureHunter = {head="White Rarab Cap +1",waist="Chaac Belt",legs=gear.mer_legs_th,feet=gear.mer_feet_th}

    -- Precast Sets

    sets.precast.JA.Bolster             = {body="Bagua Tunic +3"}
    sets.precast.JA['Life Cycle']       = {body="Geomancy Tunic +3",back=gear.PetCape}
    sets.precast.JA['Radial Arcana']    = {feet="Bagua Sandals +1"}
    sets.precast.JA['Mending Halation'] = {feet="Bagua Pants +1"}
    sets.precast.JA['Full Circle']      = {head="Azimuth Hood +1"}

    sets.precast.FC = {main="Sucellus",sub="Chanter's Shield",range="Dunna",
        head="Amalric Coif +1",neck="Voltsurge Torque",ear1="Malignance Earring",ear2="Etiolation Earring",
        body="Zendik Robe",hands=gear.tel_hand_enh,ring2="Kishar Ring",
        back=gear.MACape,waist="Embla Sash",legs="Geomancy Pants +3",feet=gear.mer_feet_fc}
    sets.precast.FC['Elemental Magic'] = set_combine(sets.precast.FC, {ear2="Barkarole Earring",hands="Bagua Mitaines +1"})
    sets.precast.FC.Cure = set_combine(sets.precast.FC, {ear2="Mendicant's Earring",legs="Doyen Pants",feet="Vanya Clogs"})
    sets.precast.FC.Curaga = sets.precast.FC.Cure
    sets.precast.FC.CureCheat = set_combine(sets.precast.FC.Cure, {body="Jhakri Robe +2",ring1="Stikini Ring +1"})
    sets.impact = {head=empty,body="Twilight Cloak"}
    sets.precast.FC.Impact = set_combine(sets.precast.FC['Elemental Magic'], sets.impact)
    --sets.dispelga = {main="Daybreak",sub="Ammurapi Shield"}
    --sets.precast.FC.Dispelga = set_combine(sets.precast.FC, sets.dispelga)

    sets.precast.WS = {
        head="Jhakri Coronal +1",neck="Sanctity Necklace",ear1="Telos Earring",ear2="Zennaroi Earring",
        body="Jhakri Robe +2",hands="Jhakri Cuffs +1",ring1="Patricius Ring",ring2="Rufescent Ring",
        back=gear.WSCape,waist="Latria Sash",legs="Jhakri Slops +2",feet="Jhakri Pigaches +2"}
    sets.precast.WS['Hexa Strike'] = set_combine(sets.precast.WS, {back=gear.TPCape})
    sets.precast.WS['Realmrazer']  = set_combine(sets.precast.WS, {})
    sets.precast.WS['Black Halo']  = set_combine(sets.precast.WS, {ear1="Moonshade Earring",ring1="Metamorph Ring +1"})
    sets.precast.WS['Judgment']    = set_combine(sets.precast.WS, {ear1="Moonshade Earring"})
    sets.precast.WS['Exudation']   = set_combine(sets.precast.WS, {})

    sets.precast.WS['Brainshaker']   = set_combine(sets.precast.WS, {ring1="Etana Ring",ring2="Metamorph Ring +1",back=gear.TPCape})
    sets.precast.WS['Shell Crusher'] = set_combine(sets.precast.WS['Brainshaker'], {})
    sets.precast.WS['Shadowstitch']  = set_combine(sets.precast.WS['Brainshaker'], {})

    sets.precast.WS['Seraph Strike'] = {
        head="Ea Hat +1",neck="Sanctity Necklace",ear1="Moonshade Earring",ear2="Malignance Earring",
        body="Bagua Tunic +3",hands="Jhakri Cuffs +1",ring1="Freke Ring",ring2="Metamorph Ring +1",
        back=gear.MACape,waist="Refoccilation Stone",legs="Ea Slops +1",feet="Jhakri Pigaches +2"}
    sets.precast.WS['Flash Nova'] = set_combine(sets.precast.WS['Seraph Strike'], {ear1="Malignance Earring",ear2="Barkarole Earring"})
    sets.precast.WS['Aeolian Edge']  = set_combine(sets.precast.WS['Seraph Strike'], {back=gear.NukeCape})
    sets.precast.WS['Cyclone']       = set_combine(sets.precast.WS['Seraph Strike'], {back=gear.NukeCape})
    sets.precast.WS['Earth Crusher'] = set_combine(sets.precast.WS['Seraph Strike'], {back=gear.NukeCape})
    sets.precast.WS['Sunburst']      = set_combine(sets.precast.WS['Seraph Strike'], {back=gear.NukeCape})
    sets.precast.WS['Cataclysm']     = set_combine(sets.precast.WS['Seraph Strike'], {back=gear.NukeCape})
    sets.precast.WS['Energy Drain']  = set_combine(sets.precast.WS['Cataclysm'], {})
    sets.precast.WS['Moonlight'] = {}

    -- Midcast sets

    sets.midcast.Cure = {main="Mafic Cudgel",sub="Genmei Shield",range="Dunna",
        head="Vanya Hood",neck="Loricate Torque +1",ear1="Calamitous Earring",ear2="Mendicant's Earring",
        body="Mallquis Saio +2",hands=gear.tel_hand_enh,ring1="Vocane Ring",ring2="Defending Ring",
        back=gear.PetCape,waist="Austerity Belt",legs="Gyve Trousers",feet="Vanya Clogs"}
    sets.midcast.Curaga = sets.midcast.Cure
    sets.midcast.Cursna = {main="Mafic Cudgel",sub="Genmei Shield",ammo="Sapience Orb",
        head="Hike Khat +1",neck="Malison Medallion",ear1="Malignance Earring",ear2="Lugalbanda Earring",
        body="Zendik Robe",hands="Gazu Bracelet +1",ring1="Ephedra Ring",ring2="Menelaus's Ring",
        back=gear.MACape,waist="Embla Sash",legs="Geomancy Pants +3",feet="Vanya Clogs"}
    sets.midcast.CureCheat = {main="Septoptic",sub="Culminus",range="Dunna",
        head="Vanya Hood",neck="Sanctity Necklace",ear1="Eabani Earring",ear2="Mendicant's Earring",
        body="Vanya Robe",hands=gear.tel_hand_enh,ring1="Etana Ring",ring2="Meridian Ring",
        back=gear.PetCape,waist="Gishdubar Sash",legs="Geomancy Pants +3",feet="Vanya Clogs"}
    sets.cmp_belt  = {waist="Austerity Belt"}
    sets.gishdubar = {waist="Gishdubar Sash"}

    sets.midcast.EnhancingDuration = {main="Gada",sub="Genmei Shield",range="Dunna",
        head=gear.tel_head_enh,neck="Loricate Torque +1",ear1="Calamitous Earring",ear2="Etiolation Earring",
        body=gear.tel_body_enh,hands=gear.tel_hand_enh,ring1="Vocane Ring",ring2="Defending Ring",
        back=gear.PetCape,waist="Embla Sash",legs=gear.tel_legs_enh,feet=gear.tel_feet_enh}
    sets.midcast['Enhancing Magic'] = set_combine(sets.midcast.EnhancingDuration, {
        head="Befouled Crown",neck="Incanter's Torque",ear2="Mimir Earring",
        body="Manasa Chasuble",hands="Ayao's Gages",ring1="Stikini Ring +1",
        back="Fi Follet Cape",waist="Olympus Sash",legs="Shedir Seraweels",feet="Regal Pumps +1"})
    sets.midcast.Phalanx = set_combine(sets.midcast['Enhancing Magic'], {hands=gear.mer_hand_phlx})
    sets.midcast.Stoneskin = set_combine(sets.midcast.EnhancingDuration, {neck="Nodens Gorget",legs="Shedir Seraweels"})
    sets.midcast.Aquaveil  = set_combine(sets.midcast.EnhancingDuration, {main="Vadose Rod",sub="Genmei Shield",
        head="Amalric Coif +1",legs="Shedir Seraweels"})
    sets.midcast.Regen     = set_combine(sets.midcast.EnhancingDuration, {main="Bolelabunga",sub="Genmei Shield"})
    sets.midcast.Refresh   = set_combine(sets.midcast.EnhancingDuration, {head="Amalric Coif +1"})
    sets.self_refresh = {back="Grapevine Cape",waist="Gishdubar Sash",feet="Inspirited Boots"}
    sets.midcast.FixedPotencyEnhancing = sets.midcast.EnhancingDuration

    sets.midcast['Elemental Magic'] = {main="Maxentius",sub="Culminus",range="Dunna",
        head="Ea Hat +1",neck="Sanctity Necklace",ear1="Malignance Earring",ear2="Barkarole Earring",
        body="Bagua Tunic +3",hands="Amalric Gages +1",ring1="Freke Ring",ring2="Metamorph Ring +1",
        back=gear.NukeCape,waist="Refoccilation Stone",legs="Ea Slops +1",feet="Jhakri Pigaches +2"}
    sets.midcast['Elemental Magic'].Resistant = set_combine(sets.midcast['Elemental Magic'], {main="Marin Staff +1",sub="Kaja Grip",
        neck="Bagua Charm +2",body="Ea Houppelande +1",ring1="Stikini Ring +1",waist="Acuity Belt +1"})
    sets.midcast.Impact = set_combine(sets.midcast['Elemental Magic'].Resistant, sets.impact)
    sets.magicburst = set_combine(sets.midcast['Elemental Magic'], {
        neck="Mizukage-no-Kubikazari",body="Ea Houppelande +1",ring1="Mujin Band",ring2="Freke Ring",feet="Jhakri Pigaches +2"})
    sets.seidr     = {body="Seidr Cotehardie"}
    sets.seidrmb   = {body="Seidr Cotehardie",ear2="Static Earring"}
    sets.orpheus   = {waist="Orpheus's Sash"}
    sets.ele_obi   = {waist="Hachirin-no-Obi"}
    sets.nuke_belt = {waist="Refoccilation Stone"}
    sets.submalev  = {sub="Malevolence"}
    sets.marin     = {main="Marin Staff +1",sub="Enki Strap"}

    sets.midcast['Enfeebling Magic'] = {main="Maxentius",sub="Chanter's Shield",range="Dunna",
        head="Ea Hat +1",neck="Bagua Charm +2",ear1="Malignance Earring",ear2="Dignitary's Earring",
        body="Geomancy Tunic +3",hands="Geomancy Mitaines +3",ring1="Stikini Ring +1",ring2="Metamorph Ring +1",
        back=gear.MACape,waist="Acuity Belt +1",legs="Geomancy Pants +3",feet="Geomancy Sandals +3"}
    sets.midcast['Enfeebling Magic'].Resistant = set_combine(sets.midcast['Enfeebling Magic'], {main="Marin Staff +1",sub="Kaja Grip"})
	sets.midcast.Silence  = set_combine(sets.midcast['Enfeebling Magic'], {waist="Luminary Sash"})
	sets.midcast.Slow     = set_combine(sets.midcast['Enfeebling Magic'], {waist="Luminary Sash"})
    sets.midcast.Paralyze = set_combine(sets.midcast.Slow, {})
    --sets.midcast.Dispelga = set_combine(sets.midcast['Enfeebling Magic'], sets.dispelga)

    sets.midcast['Dark Magic'] = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast.Drain = {main="Maxentius",sub="Chanter's Shield",range="Dunna",
        head="Pixie Hairpin +1",neck="Erra Pendant",ear1="Malignance Earring",ear2="Dignitary's Earring",
        body="Geomancy Tunic +3",hands="Geomancy Mitaines +3",ring1="Excelsis Ring",ring2="Evanescence Ring",
        back=gear.MACape,waist="Fucho-no-Obi",legs="Geomancy Pants +3",feet=gear.mer_feet_dr}
    sets.midcast.Aspir = set_combine(sets.midcast.Drain, {})
    sets.midcast.Drain.Resistant = set_combine(sets.midcast.Drain, {head="Bagua Galero +1",neck="Bagua Charm +2",ring1="Stikini Ring +1"})
    sets.midcast.Aspir.Resistant = set_combine(sets.midcast.Drain.Resistant, {})
    sets.drain_belt = {waist="Fucho-no-Obi"}

    sets.midcast.Geomancy = {main="Mafic Cudgel",sub="Genmei Shield",range="Dunna",
        head="Ea Hat +1",neck="Bagua Charm +2",ear1="Calamitous Earring",ear2="Etiolation Earring",
        body="Mallquis Saio +2",hands="Geomancy Mitaines +3",ring1="Stikini Ring +1",ring2="Defending Ring",
        back="Solemnity Cape",waist="Austerity Belt",legs="Vanya Slops",feet="Vanya Clogs"}
    sets.midcast.Geomancy.Indi = set_combine(sets.midcast.Geomancy, {main="Solstice",sub="Genmei Shield",range="Dunna",
        back="Lifestream Cape",legs="Bagua Pants +1",feet="Azimuth Gaiters +1"})
    sets.midcast.Geomancy.Entrust = set_combine(sets.midcast.Geomancy.Indi, {main="Solstice",sub="Genmei Shield"})

    -- Idle/resting/defense/etc sets

    sets.idle = {main="Mafic Cudgel",sub="Genmei Shield",range="Dunna",
        head=gear.mer_head_rf,neck="Loricate Torque +1",ear1="Eabani Earring",ear2="Lugalbanda Earring",
        body="Geomancy Tunic +3",hands="Bagua Mitaines +1",ring1="Stikini Ring +1",ring2="Defending Ring",
        back=gear.PetCape,waist="Resolute Belt",legs="Assiduity Pants +1",feet="Geomancy Sandals +3"}
    sets.idle.Pet = {main="Sucellus",sub="Genmei Shield",
        head="Hike Khat +1",neck="Bagua Charm +2",ear1="Rimeice Earring",ear2="Lugalbanda Earring",
        body="Geomancy Tunic +3",hands="Geomancy Mitaines +3",ring1="Stikini Ring +1",ring2="Defending Ring",
		back=gear.PetCape,waist="Isa Belt",legs="Psycloth Lappas",feet="Bagua Sandals +1"}
    sets.idle.PDT = set_combine(sets.idle, {head="Hike Khat +1",ring1="Vocane Ring"})
    sets.idle.PDT.Pet = {main="Sucellus",sub="Genmei Shield",
        head="Hike Khat +1",neck="Bagua Charm +2",ear1="Rimeice Earring",ear2="Lugalbanda Earring",
        body="Mallquis Saio +2",hands="Geomancy Mitaines +3",ring1="Vocane Ring",ring2="Defending Ring",
		back=gear.PetCape,waist="Isa Belt",legs="Psycloth Lappas",feet="Bagua Sandals +1"}
    sets.idle.MEVA = {main="Mafic Cudgel",sub="Genmei Shield",range="Dunna",
        head="Ea Hat +1",neck="Loricate Torque +1",ear1="Eabani Earring",ear2="Lugalbanda Earring",
        body="Ea Houppelande +1",hands="Geomancy Mitaines +3",ring1="Vocane Ring",ring2="Defending Ring",
        back=gear.PetCape,waist="Resolute Belt",legs="Ea Slops +1",feet="Geomancy Sandals +3"}
    sets.idle.MEVA.Pet = set_combine(sets.idle.MEVA, {main="Sucellus",sub="Genmei Shield",
        head=gear.tel_head_pet,neck="Bagua Charm +2",ear1="Rimeice Earring",waist="Isa Belt",legs="Psycloth Lappas"})
    sets.latent_refresh = {waist="Fucho-no-Obi"}
    sets.zendik         = {body="Zendik Robe"}
    sets.buff.doom      = {neck="Nicander's Necklace",ring1="Saida Ring",ring2="Defending Ring",waist="Gishdubar Sash"}

    -- Defense sets
    sets.defense.PDT      = sets.idle.PDT
    sets.defense.PDT.Pet  = sets.idle.PDT.Pet
    sets.defense.MEVA     = sets.idle.MEVA
    sets.defense.MEVA.Pet = sets.idle.MEVA.Pet
    sets.Kiting = {feet="Geomancy Sandals +3"}

    -- Engaged sets
    sets.engaged = {main="Maxentius",sub="Genmei Shield",range="Dunna",
        head="Blistering Sallet +1",neck="Bagua Charm +2",ear1="Telos Earring",ear2="Dignitary's Earring",
        body="Jhakri Robe +2",hands="Gazu Bracelet +1",ring1="Chirich Ring +1",ring2="Defending Ring",
        back=gear.TPCape,waist="Goading Belt",legs="Jhakri Slops +2",feet="Jhakri Pigaches +2"}
    sets.engaged.PDef = set_combine(sets.engaged, {body="Mallquis Saio +2",ring1="Vocane Ring",ring2="Defending Ring"})
    sets.dualwield = {ear1="Eabani Earring"} -- TODO

    -- Sets the depend upon idle sets
    sets.midcast.FastRecast = set_combine(sets.defense.PDT, {})
    sets.midcast.Dia   = set_combine(sets.idle.PDT, sets.TreasureHunter)
    sets.midcast.Bio   = set_combine(sets.midcast.Dia, {})
    sets.midcast.Stone = set_combine(sets.midcast.Dia, {})
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.
function job_precast(spell, action, spellMap, eventArgs)
    if classes.CustomClass == 'CureCheat' then
        if not (spell.target.type == 'SELF' and spell.english == 'Cure IV') then
            classes.CustomClass = nil
        end
    end
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_midcast(spell, action, spellMap, eventArgs)
    geo_state_updates(spell, action)
    -- Let these spells skip midcast sets by replacing it with the default idle set.
    -- This should make the character only blink once (for precast) rather than twice.
    if S{'Warp','Warp II','Escape'}:contains(spell.english)
    or npcs.Trust:contains(spell.english)
    or spellMap == 'Teleport' then
        if sets.idle[state.IdleMode.value] then
            equip(sets.idle[state.IdleMode.value])
        else
            equip(sets.idle)
        end
        eventArgs.handled = true
    end
end

-- Run after the default midcast() is done.
-- eventArgs is the same one used in job_midcast, in case information needs to be persisted.
function job_post_midcast(spell, action, spellMap, eventArgs)
    if spell.type == 'Geomancy' then
        if state.Buff.Entrust and spell.target.type ~= 'SELF' then
            equip(sets.midcast.Geomancy.Entrust)    -- +geomancy not required
        end
    elseif spell.skill == 'Elemental Magic' and spellMap ~= 'ElementalEnfeeble' then
        if spell.english ~= 'Impact' then
            if state.MagicBurst.value then
                equip(sets.magicburst)
                if state.Seidr.value
                or state.AutoSeidr.value and (player.mp - spell.mp_cost) < state.AutoSeidr.low_mp then
                    equip(sets.seidrmb)
                end
            elseif state.Seidr.value
            or state.AutoSeidr.value and (player.mp - spell.mp_cost) < state.AutoSeidr.low_mp then
                equip(sets.seidr)
            end
        end
        if spell.element == 'Wind' then
            equip(sets.marin)
        elseif state.CombatForm.has_value and state.CombatForm.value == 'DW' then
            equip(sets.submalev)
        end
        equip(resolve_ele_belt(spell, sets.ele_obi, sets.nuke_belt, 3))
        if state.CardinalMsg.value then cardinal_chant_message(spell, spellMap, state.Buff['Collimated Fervor'] and 0.5 or 0) end
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
end

function job_aftercast(spell, action, spellMap, eventArgs)
    geo_state_updates(spell, action)
    if spell.interrupted then
        send_command('wait 0.5;gs c update')
        interrupted_message(spell)
    else
        if spell.type == 'JobAbility' then
            -- aftercast can get in the way. skip it to avoid breaking bubbles sometimes.
            eventArgs.handled = true
        elseif spell.english:startswith('Geo-') then
            state.Buff.Pet = true
        elseif spell.english == 'Sleep' or spell.english == 'Sleepga' then
            send_command('@timers c "'..spell.english..' ['..spell.target.name..']" 60 down')
        elseif spell.english == 'Sleep II' then
            send_command('@timers c "'..spell.english..' ['..spell.target.name..']" 90 down')
        end
    end
end

function job_post_aftercast(spell, action, spellMap, eventArgs)
    if not spell.interrupted and spell.english:startswith('Geo-') then
        state.Buff.Pet = nil
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
            equip((pet.isvalid and sets.defense.PDT.Pet or sets.defense.PDT))
            if lbuff == 'sleep' then send_command('cancel stoneskin') end
        elseif not midaction() then
            handle_equipping_gear(player.status)
        end
    elseif not midaction() then
        if lbuff == 'doom' then
            handle_equipping_gear(player.status)
        end
    end
    if gain then
        add_to_chat(104, 'Gained ['..buff..']')
    elseif S{'bolster','widened compass'}:contains(lbuff) then
        geo_state_updates(buff, gain)
    end
end

-- Called when a player gains or loses a pet.
-- pet == pet gained or lost
-- gain == true if the pet was gained, false if it was lost.
function job_pet_change(pet, gain, eventArgs)
    if not gain then
        geo_state_updates('luopan', gain)

        -- don't immediately swap to non-pet idle/melee gear to avoid breaking next bubble
        eventArgs.handled = true

        local full_circle_recast_id = 243
        local all_ja_recasts = windower.ffxi.get_ability_recasts()
        if all_ja_recasts[full_circle_recast_id] == 0 then
            add_to_chat(123, 'Luopan died!')
        end
    end
end

-- Handle notifications of general user state change.
function job_state_change(stateField, newValue, oldValue)
    if stateField == 'Offense Mode' then
        enable('main','sub','range','ammo')
        if newValue ~= 'None' then
            equip(sets.weapons[state.CombatWeapon.value])
            disable('main','sub','range','ammo')
        end
        handle_equipping_gear(player.status)
    elseif stateField == 'Combat Weapon' then
        info.ws_binds:bind(state.CombatWeapon)
        if state.OffenseMode.value ~= 'None' then
            enable('main','sub','range','ammo')
            equip(sets.weapons[state.CombatWeapon.value])
            disable('main','sub','range','ammo')
        end
    elseif stateField == 'Ally Cure Keybinds' then
        if newValue then info.ally_keybinds:bind()
        else             info.ally_keybinds:unbind()
        end
    end
end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements standard library decisions.
-------------------------------------------------------------------------------------------------------------------

-- Custom spell mapping.
function job_get_spell_map(spell, default_spell_map)
    if spell.skill == 'Geomancy' then
        if spell.english:startswith('Indi-') then
            return 'Indi'
        end
    elseif spell.skill == 'Enhancing Magic' then
        if spell.english ~= 'Erase'
        and not S{'Regen','Refresh','BarElement','BarStatus','EnSpell','Teleport'}:contains(default_spell_map) then
            return "FixedPotencyEnhancing"
        end
    end
end

-- Modify the default idle set after it was constructed.
function customize_idle_set(idleSet)
    if state.ZendikIdle.value and state.DefenseMode.value == 'None' then
        idleSet = set_combine(idleSet, sets.zendik)
    end
    if player.mpp < 51 and not pet.isvalid then
        idleSet = set_combine(idleSet, sets.latent_refresh)
    end
    if has_any_buff_of(S{'petrification','sleep','stun','terror'}) then
        idleSet = set_combine((pet.isvalid and sets.defense.PDT.Pet or sets.defense.PDT), {})
        if buffactive.Sleep then send_command('cancel stoneskin') end
    end
    if buffactive['Reive Mark'] then
        idleSet = set_combine(idleSet, {neck="Arciela's Grace +1"})
    end
    if state.Buff.doom then
        idleSet = set_combine(idleSet, sets.buff.doom)
    end
    return idleSet
end

-- Modify the default defense set after it was constructed.
function customize_defense_set(defenseSet)
    if pet.isvalid then
        local set = sets.defense[state[state.DefenseMode.value..'DefenseMode'].value]
        if set.Pet then
            defenseSet = set.Pet
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
        if state.CombatWeapon.value ~= 'None' then
            meleeSet = set_combine(meleeSet, sets.weapons[state.CombatWeapon.value])
        end
        if state.CombatForm.has_value and state.CombatForm.value == 'DW' then
            meleeSet = set_combine(meleeSet, sets.dualwield)
        end
        if buffactive['Reive Mark'] then
            meleeSet = set_combine(meleeSet, {neck="Arciela's Grace +1"})
        end
        if buffactive['elvorseal'] then
            meleeSet = set_combine(meleeSet, {body="Angantyr Robe",hands="Angantyr Mittens",legs="Angantyr Tights"})
        end
    end
    if has_any_buff_of(S{'petrification','sleep','stun','terror'}) then
        meleeSet = set_combine((pet.isvalid and sets.defense.MEVA.Pet or sets.defense.MEVA), {})
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
    if midaction() and cmdParams[1] == 'user' then
        -- don't break midcast by checking recasts
        eventArgs.handled = true
    end
end

-- Function to display the current relevant user state when doing an update.
function display_current_job_state(eventArgs)
    local msg = ''

    if not state.GeoHUD.value then
        msg = msg .. 'G-' .. (state.luopan.last_colure  and state.luopan.last_colure  or '?')
        msg = msg ..' I-' .. (state.indi.last_colure    and state.indi.last_colure    or '?')
        msg = msg ..' E-' .. (state.entrust.last_colure and state.entrust.last_colure or '?')
    end

    if state.OffenseMode.value ~= 'None' then
        msg = msg .. ' TP['
        msg = msg .. state.CombatWeapon.value
        if state.OffenseMode.value ~= 'Normal' then
            msg = msg .. '-' .. state.OffenseMode.value
        end
        if state.HybridMode.value ~= 'Normal' then
            msg = msg .. '/' .. state.HybridMode.value
        end
        msg = msg .. ']'
    end

    msg = msg .. ' MA['..state.CastingMode.value..']'
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

    if state.AllyBinds.value then
        msg = msg .. ' AllyBinds'
    end
    if state.Seidr.value then
        msg = msg .. ' Seidr'
    elseif state.AutoSeidr.value then
        msg = msg .. ' AutoSeidr'
    end
    if state.MagicBurst.value then
        msg = msg .. ' MB+'
    end

    if state.Kiting.value == true then
        msg = msg .. ' Kiting'
    end

    add_to_chat(122, msg)
    report_ja_recasts(info.recast_ids, 6)
    eventArgs.handled = true
end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements self-commands.
-------------------------------------------------------------------------------------------------------------------

-- Called for custom player commands.
function job_self_command(cmdParams, eventArgs)
    if     cmdParams[1] == 'lastgeo' then
        if state.luopan.last_colure then
            send_command('input /ma "Geo-'..state.luopan.last_colure..'"')
        else
            add_to_chat(123, 'no LastGeo value')
        end
    elseif cmdParams[1] == 'lastindi' then
        if state.indi.last_colure then
            send_command('input /ma "Indi-'..state.indi.last_colure..'" <me>')
        else
            add_to_chat(123, 'no LastIndi value')
        end
    elseif cmdParams[1] == 'lastentrust' then
        if state.luopan.last_colure then
            send_command('input /ma "Indi-'..state.entrust.last_colure..'" <stpc>')
        else
            add_to_chat(123, 'no LastEntrust value')
        end
    elseif cmdParams[1] == 'CureCheat' then
        classes.CustomClass = 'CureCheat'
        send_command('input /ma "Cure IV" <me>')
    elseif cmdParams[1] == 'ListWS' then
        info.ws_binds:print('ListWS:')
    elseif cmdParams[1] == 'ListBubs' then
        info.bubble_binds:print('ListBubs:')
    elseif cmdParams[1] == 'weap' then
        weap_self_command(cmdParams, 'CombatWeapon')
    elseif cmdParams[1] == 'save' then
        save_self_command(cmdParams)
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
    set_macro_page(1,1)
    send_command('bind !^l input /lockstyleset 1')
end

-- collimated fervor is +50% and geomancy galero +3 is +100% to this bonus
function cardinal_chant_message(spell, spellMap, bonus)
    local cardinal_chant = {N = {stat='MCrit', nonra=11, ra=16, angle=math.pi/2},
                            E = {stat='MAtt',  nonra=13, ra=17, angle=0},
                            S = {stat='MAcc',  nonra=13, ra=17, angle=-math.pi/2},
                            W = {stat='MB',    nonra=22, ra=28, angle=math.pi}}
    local chant_buffs = L{}

    -- find the angle to the target (0 is east, +pi/2 is north, pi is west, -pi/2 is south)
    local delta_x = spell.target.x - player.x
    local delta_y = spell.target.y - player.y
    local theta = math.atan2(delta_y, delta_x)

    -- buffs are a blend of two determined by enemy angle and quadrant (some are less relevant)
    local buff_dirs
    if 0 <= theta and theta < math.pi/2 then buff_dirs = ''     -- NE
    elseif math.pi/2 <= theta then           buff_dirs = 'W'    -- NW
    elseif theta < -math.pi/2 then           buff_dirs = 'W'    -- SW
    elseif -math.pi/2 <= theta then          buff_dirs = ''     -- SE
    else error('cardinal_chant_message: fix quadrant math') end

    for i = 1, #buff_dirs do
        local dir = buff_dirs:sub(i,i)

        local max_mag
        if spellMap == 'GeoNuke' then max_mag = cardinal_chant[dir].ra
        else                          max_mag = cardinal_chant[dir].nonra
        end

        local r = 1 - math.abs(math.abs(cardinal_chant[dir].angle) - math.abs(theta)) / (math.pi/2)
        if r < 0 or 1 < r then error('cardinal_chant_message: fix ratio calculation') end
        local mag = math.floor(r * max_mag)
        if bonus and bonus > 0 then mag = math.floor((1 + bonus) * mag) end

        if mag > 0 then
            chant_buffs:append("%s+%d":format(cardinal_chant[dir].stat, mag))
        end
    end

    if not chant_buffs:empty() then add_to_chat(122, 'chant: ' .. chant_buffs:concat(' ')) end
end

-- update state.indi, state.lupan and state.entrust
-- call this from get_sets (or job_setup or user_setup with mote-include) with no arguments
-- and from aftercast with (spell, action)
-- (can optionally call this from midcast also to be more resilient against packet loss)
-- and from buff_change with (buff, gain)
-- and from pet_change with ('luopan', gain) (also optional for resiliency)
function geo_state_updates(spell, action)
    if not spell then -- initialize
        if not state then -- for non-mote-includes (TODO needs testing)
            state = {GeoHUD = {value = true}, Buff = buffactive}
            info  = {indi_dur = 285, indi_dur_melee = 270} -- edit to proper values
        end
        state.indi    = T{started = nil, duration = nil, last_colure = nil}
        state.entrust = T{started = nil, duration = nil, last_colure = nil, target = nil, bolster = false, wide = false}
        state.luopan  = T{ea = false, le = false, bog = false, demat = {started = nil, duration = nil},
                          bolster = false, wide = false, last_colure = nil, debuff = false}
        state.saved_indi    = nil
        state.saved_entrust = nil
        state.saved_luopan  = nil
    elseif type(spell) == 'string' then -- call from buff_change or pet_change
        if not action then -- luopan died or effect ended
            if     spell == 'luopan' then
                local last_colure = state.luopan.last_colure
                state.luopan = T{ea = false, le = false, bog = false, demat = {started = nil, duration = nil},
                                 bolster = false, wide = false, last_colure = last_colure, debuff = false}
            elseif spell == 'Bolster' then
                -- entrust retains the effect
                state.luopan.bolster  = false
            elseif spell == 'Widened Compass' then
                -- entrust retains the effect
                state.luopan.wide     = false
            end
        end
    elseif spell.interrupted then -- aftercast corrections for possible early redundant midcast changes
        if     spell.english:startswith('Geo-') then
            -- load saved luopan from midcast, if it exists
            if not pet.isvalid then
                local last_colure = (state.saved_luopan and state.saved_luopan.last_colure or nil)
                state.luopan = T{ea = false, le = false, bog = false, demat = {started = nil, duration = nil},
                                 bolster = false, wide = false, last_colure = last_colure, debuff = false}
            else
                if state.saved_luopan then state.luopan = state.saved_luopan end
            end
        elseif spell.type == 'JobAbility' then -- assume failure is not due to luopan already being buffed
            if     spell.english == 'Ecliptic Attrition' then state.luopan.ea = false
            elseif spell.english == 'Lasting Emanation'  then state.luopan.le = false
            elseif spell.english == 'Dematerialize'      then state.luopan.demat.started = nil
            end
        elseif spell.english:startswith('Indi-') then
            -- load saved entrust or indi from midcast, if it exists
            if state.Buff.Entrust and spell.target.type ~= 'SELF' then
                if state.saved_entrust then state.entrust = state.saved_entrust end
            elseif player.indi then
                if state.saved_indi    then state.indi    = state.saved_indi end
            else
                if state.saved_indi    then state.indi    = state.saved_indi else state.indi.started = nil end
            end
        end
    else -- not interrupted, could be midcast or aftercast
        if     spell.english:startswith('Geo-') then
            if not pet.isvalid then
                if action == 'midcast' then state.saved_luopan = state.luopan:copy()
                else                        state.saved_luopan = nil end
                state.luopan = T{ea = false, le = false, bog = state.Buff['Blaze of Glory'], demat = {started = nil, duration = nil},
                                 bolster = state.Buff.Bolster, wide = state.Buff['Widened Compass'],
                                 last_colure = spell.english:sub(5), debuff = spell.targets.Enemy}
            end
        elseif spell.english == 'Ecliptic Attrition' then state.luopan.ea = true
        elseif spell.english == 'Lasting Emanation'  then state.luopan.le = true
        elseif spell.english == 'Dematerialize'      then state.luopan.demat = {started = os.time(), duration = 70}
        elseif spell.english:startswith('Indi-') then
            local dur = info.indi_dur
            if state.OffenseMode.value ~= 'None' then dur = info.indi_dur_melee end
            if state.Buff.Entrust and spell.target.type ~= 'SELF' then
                if action == 'midcast' then state.saved_entrust = state.entrust:copy()
                else                        state.saved_entrust = nil end
                state.entrust = T{started = os.time(), duration = dur, target = spell.target.name, last_colure = spell.english:sub(6),
                                  bolster = state.Buff.Bolster, wide = state.Buff['Widened Compass']}
            else
                if action == 'midcast' then state.saved_indi    = state.indi:copy()
                else                        state.saved_indi = nil end
                state.indi = T{started = os.time(), duration = dur, last_colure = spell.english:sub(6)}
            end
        end
    end
end

function init_state_text()
    destroy_state_text()
    local mb_text_settings    = {flags={draggable=false},bg={alpha=150}}
    local seidr_text_settings = {pos={y=18},flags={draggable=false},bg={alpha=150}}
    local hyb_text_settings   = {pos={x=130,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local def_text_settings   = {pos={x=172,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local geo_entrust_text_settings = {pos={x=1000,y=676},flags={draggable=false,bold=true},
                                       bg={alpha=150},padding=1,text={font='Courier New',size=10,stroke={width=1}}}
    local geo_luopan_text_settings  = {pos={x=1000,y=697},flags={draggable=false,bold=true},
                                       bg={alpha=150},padding=1,text={font='Courier New',size=10,stroke={width=1}}}
    local geo_indi_text_settings    = {pos={x=1000,y=718},flags={draggable=false,bold=true},
                                       bg={alpha=150},padding=1,text={font='Courier New',size=10,stroke={width=1}}}
    state.mb_text          = texts.new('MBurst',         mb_text_settings)
    state.seidr_text       = texts.new('Seidr',          seidr_text_settings)
    state.hyb_text         = texts.new('initializing..', hyb_text_settings)
    state.def_text         = texts.new('initializing..', def_text_settings)
    state.geo_entrust_text = texts.new('initializing..', geo_entrust_text_settings)
    state.geo_luopan_text  = texts.new('initializing..', geo_luopan_text_settings)
    state.geo_indi_text    = texts.new('initializing..', geo_indi_text_settings)

    local counter, interval = 0, 15 -- only update bubble texts every <interval> frames

    windower.register_event('logout', destroy_state_text)
    state.texts_event_id = windower.register_event('prerender', function()
        state.mb_text:visible(state.MagicBurst.value)
        state.seidr_text:visible(state.Seidr.value)

        counter = counter + 1
        if counter >= interval and state.GeoHUD.value then
            counter = 0
            if not areas.Cities:contains(world.area) then
                local now = os.time()

                -- this only supports a single entrust
                local entrust_time_remaining = (state.entrust.started and state.entrust.started - now + state.entrust.duration or 0)
                local entrust_recast_id = 93
                local entrust_recast = windower.ffxi.get_ability_recasts()[entrust_recast_id] or 0
                if state.entrust.started and entrust_time_remaining > 0 then
                    local min, sec = math.floor(entrust_time_remaining / 60), entrust_time_remaining % 60
                    local green    = math.min(math.max(0, math.floor(255 * entrust_time_remaining / state.entrust.duration)), 255)
                    local text     = 'Entrust-%s (%.4s): %d:%02d':format(state.entrust.last_colure, state.entrust.target, min, sec)
                    if state.entrust.bolster then text = '[BOLSTER]'..text end
                    state.geo_entrust_text:text(text)
                    state.geo_entrust_text:color(255,255,255)
                    state.geo_entrust_text:bg_color(0,green,0)
                elseif entrust_recast > 0 then
                    local min, sec = math.floor(entrust_recast / 60), entrust_recast % 60
                    state.geo_entrust_text:text('Entrust : %d:%02d':format(min, sec)
                        ..(state.entrust.last_colure and     ' (last: '..state.entrust.last_colure..')' or ''))
                    state.geo_entrust_text:color(255,255,255)
                    state.geo_entrust_text:bg_color(0,0,0)
                else
                    state.geo_entrust_text:text('NO ENTRUST'
                        ..(state.entrust.last_colure and '     (last: '..state.entrust.last_colure..')' or ''))
                    state.geo_entrust_text:color(0,0,0)
                    state.geo_entrust_text:bg_color(255,0,0)
                end
                state.geo_entrust_text:show()

                if pet and pet.isvalid and pet.name == 'Luopan' then
                    local luopan = windower.ffxi.get_mob_by_index(pet.index) or {}
                    local hpp  = (luopan.valid_target and luopan.hpp or 0)
                    local dist = (luopan.valid_target and math.sqrt(luopan.distance) or 50)
                    local green = math.min(math.max(0, math.floor(2.55 * hpp)), 255)
                    local tags, text = ''
                    if state.luopan.bolster then tags = '[BOLSTER]'
                    else
                        if state.luopan.le  then tags =  '[LE]'..tags end
                        if state.luopan.ea  then tags =  '[EA]'..tags end
                        if state.luopan.bog then tags = '[BoG]'..tags end
                    end
                    text = '[%d%%]%sGeo-%s':format(hpp, tags, (state.luopan.last_colure and state.luopan.last_colure or '?'))
                    if luopan.valid_target and dist < 25 then
                        if 6.2 < dist then text = text..' (%.1f)':format(dist) end
                        if state.luopan.debuff and player.target and player.target.type == 'MONSTER' then
                            local l_x, l_y, l_z = pet.x, pet.y, pet.z
                            local e_x, e_y, e_z = player.target.x, player.target.y, player.target.z
                            local enemy_dist = math.sqrt((l_x-e_x)^2 + (l_y-e_y)^2 + (l_z-e_z)^2)
                            if enemy_dist - player.target.model_size/2 > (state.luopan.wide and 12 or 6) then
                                text = text..' <OOR>'
                            end
                        end
                    else
                        text = text..' (FAR)'
                    end
                    if state.luopan.demat.started then
                        if (state.luopan.demat.started - now + state.luopan.demat.duration) > 0 then
                            text = '[DEMAT]'..text
                        end
                    end
                    state.geo_luopan_text:text(text)
                    state.geo_luopan_text:color(255,255,255)
                    state.geo_luopan_text:bg_color(0,green,0)
                else
                    state.geo_luopan_text:text('NO LUOPAN'
                        ..(state.luopan.last_colure and '      (last: '..state.luopan.last_colure..')' or ''))
                    state.geo_luopan_text:color(0,0,0)
                    state.geo_luopan_text:bg_color(255,0,0)
                end
                state.geo_luopan_text:show()

                if player.indi then
                    local indi_time_remaining = math.max(0, state.indi.started and state.indi.started - now + state.indi.duration or 0)
					local min, sec = math.floor(indi_time_remaining / 60), indi_time_remaining % 60
					local green    = math.min(math.max(0, math.floor(255 * indi_time_remaining / (state.indi.duration or 1))), 255)
                    local text     = 'Indi-%s : %d:%02d':format((state.indi.last_colure and state.indi.last_colure or '?'), min, sec)
                    if state.Buff.Bolster then text = '[BOLSTER]'..text end
                    state.geo_indi_text:text(text)
                    state.geo_indi_text:color(255,255,255)
                    state.geo_indi_text:bg_color(0,green,0)
                else
                    state.geo_indi_text:text('NO INDICOLURE'
                        ..(state.indi.last_colure and '  (last: '..state.indi.last_colure..')' or ''))
                    state.geo_indi_text:color(0,0,0)
                    state.geo_indi_text:bg_color(255,0,0)
                end
                state.geo_indi_text:show()
            else
                state.geo_entrust_text:hide()
                state.geo_luopan_text:hide()
                state.geo_indi_text:hide()
            end
        elseif not state.GeoHUD.value then
            state.geo_entrust_text:hide()
            state.geo_luopan_text:hide()
            state.geo_indi_text:hide()
        end

        if state.HybridMode.value ~= 'Normal' then
            state.hyb_text:text('/%s':format(state.HybridMode.value))
            state.hyb_text:show()
        else state.hyb_text:hide() end

        if state.DefenseMode.value ~= 'None' then
            state.def_text:text('(%s)':format(state[state.DefenseMode.value..'DefenseMode'].current))
            state.def_text:show()
        else state.def_text:hide() end
    end)
end

function destroy_state_text()
    if state.texts_event_id then
        windower.unregister_event(state.texts_event_id)
        for text in S{state.mb_text, state.seidr_text, state.hyb_text, state.def_text,
                      state.geo_entrust_text, state.geo_luopan_text, state.geo_indi_text}:it() do
            text:hide()
            text:destroy()
        end
    end
    state.texts_event_id = nil
end
