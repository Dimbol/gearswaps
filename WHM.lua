-- Modified from 'https://github.com/Kinematics/GearSwap-Jobs/blob/master/WHM.lua'
-- Defines gearsets and job keybinds for WHM. Macrobar binds are shadowed here.
-- Some auto target changing is done for <stpc> cures and <t> enfeebles.

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
    state.Buff['Light Arts']      = buffactive['Light Arts'] or false
    state.Buff['Dark Arts']       = buffactive['Dark Arts'] or false
    state.Buff['Addendum: White'] = buffactive['Addendum: White'] or false
    state.Buff['Addendum: Black'] = buffactive['Addendum: Black'] or false
    state.Buff['Divine Caress']   = buffactive['Divine Caress'] or false
    state.Buff.doom = buffactive.doom or false
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
-- Set job keybinds here.
function user_setup()
    state.OffenseMode:options('None','Normal','Acc')                    -- Cycle with F9, will swap weapon
    state.HybridMode:options('Normal','PDef')                           -- Cycle with ^F9
    state.WeaponskillMode:options('Normal','Acc','NoDmg')
    state.CastingMode:options('Normal','Enmity')                        -- Cycle with F10
    state.IdleMode:options('Normal','PDT','MEVA','Rf')                  -- Cycle with F11, set to PDT with ^F11, reset with !F11
    state.MagicalDefenseMode:options('MEVA','MRf')                      -- Cycle with @z
    state.CombatWeapon = M{['description']='Combat Weapon'}
    if S{'DNC','NIN'}:contains(player.sub_job) then
        state.CombatWeapon:options('YagTP','MaxTP','DayTP','YagAsc','MaxAsc','DayAsc','Staff')
		state.CombatForm:set('DW')
    else
        state.CombatWeapon:options('Yagrush','Maxentius','Daybreak','Staff')
		state.CombatForm:reset()
    end
    state.WSBinds = M{['description']='WS Binds',['string']=''}

    state.WSMsg  = M(false, 'WS Message')                               -- Toggle with ^\
    state.DiaMsg = M(false, 'Dia Message')                              -- Toggle with ^@\
    state.AriseTold = M{['description']='Arise Tells',['string']=''}    -- Holds name of last person pestered to avoid spamming.
    state.AllyBinds = M(false, 'Ally Cure Keybinds')                    -- Toggle with !^numpad0
    state.MagicBurst = M(false, 'Magic Burst')                          -- Toggle with !z
    init_state_text()

    info.magic_ws = S{'Shining Strike','Seraph Strike','Flash Nova','Rock Crusher','Earth Crusher','Starburst','Sunburst','Cataclysm'}

    -- Mote-libs handle obis, gorgets, and other elemental things.
    -- These are default fallbacks if situationally appropriate gear is not available.
    gear.default.obi_waist = "Sacro Cord"                   -- used in Cure/Divine/Dark sets (overriden for cures in job_post_midcast)

    -- Augmented items get variables for convenience and specificity
    gear.FCCape  = {name="Alaunus's Cape", augments={'"Fast Cast"+10'}}
    gear.ENMCape = {name="Alaunus's Cape", augments={'MND+20','Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+10','Enmity-10','Phys. dmg. taken-10%'}}
    gear.MEVACape= {name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Enmity+10','Phys. dmg. taken-10%'}}
    gear.TPCape  = {name="Alaunus's Cape", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Store TP"+10','Phys. dmg. taken-10%'}}
    gear.TPCapeDW= {name="Alaunus's Cape",
        augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Dual Wield"+10','Phys. dmg. taken-10%'}}
    gear.WSCape  = {name="Alaunus's Cape",
        augments={'MND+20','Accuracy+20 Attack+20','MND+10','Weapon skill damage +10%','Phys. dmg. taken-10%'}}
    gear.GrioEnf = {name="Grioavolr", augments={'Enfb.mag. skill +12','Mag. Acc.+30','"Mag.Atk.Bns."+20','Magic Damage +4'}}
    gear.chir_feet_ma = {name="Chironic Slippers", augments={'"Mag.Atk.Bns."+30','DEX+10','Mag. Acc.+14 "Mag.Atk.Bns."+14'}}
    gear.chir_feet_th = {name="Chironic Slippers",
        augments={'"Mag.Atk.Bns."+13','Accuracy+7','"Treasure Hunter"+1','Accuracy+19 Attack+19','Mag. Acc.+19 "Mag.Atk.Bns."+19'}}
    gear.Lstikini = {name="Stikini Ring +1", bag="wardrobe2"}
    gear.Rstikini = {name="Stikini Ring +1", bag="wardrobe3"}

    -- binds
    send_command('bind %`   gs c update user')
    send_command('bind F9   gs c cycle OffenseMode')
    send_command('bind !F9  gs c reset OffenseMode')
    send_command('bind @F9  gs c cycle CombatWeapon')
    send_command('bind !@F9 gs c cycleback CombatWeapon')
    send_command('bind F10  gs c cycle CastingMode')
    send_command('bind !F10 gs c reset CastingMode')
    send_command('bind F11  gs c cycle IdleMode')
    send_command('bind ^F11 gs c set IdleMode PDT')
    send_command('bind !F11 gs c reset IdleMode')
    send_command('bind @F11 gs c toggle Kiting')
    send_command('bind ^space  gs c cycle HybridMode')
    send_command('bind !space  gs c set DefenseMode Physical')
    send_command('bind @space  gs c set DefenseMode Magical')
    send_command('bind !@space gs c reset DefenseMode')
    send_command('bind @z      gs c cycle MagicalDefenseMode')
    send_command('bind !z      gs c toggle MagicBurst')

    send_command('bind ^`    input /ja "Divine Seal" <me>')
    send_command('bind !`    input /ja Devotion')
    send_command('bind @`    input /ja "Divine Caress" <me>')
    send_command('bind ^@`   input /ja Sacrosanctity <me>')
    send_command('bind ^@tab input /ja Asylum <me>')
    send_command('bind !^`   input /ja Benediction <me>')
    send_command('bind ~^tab input /ja "Afflatus Solace" <me>')
    send_command('bind ~^q   input /ja "Afflatus Misery" <me>')

    send_command('bind ^1  input /ma "Dia II"')
    send_command('bind ^2  input /ma Slow')
    send_command('bind ^3  input /ma Paralyze')
    send_command('bind ^4  input /ma Addle')
    send_command('bind ^5  input /ma Repose <stnpc>')
    send_command('bind ^6  input /ma Silence')
    send_command('bind ^backspace input /ma Impact')
    send_command('bind !1  input /ma "Cure III" <stpc>')
    send_command('bind !2  input /ma "Cure IV" <stpc>')
    send_command('bind !3  input /ma "Cure V" <stpc>')
    send_command('bind !4  input /ma "Cure VI" <stpc>')
    send_command('bind !@1 input /ma "Curaga"')
    send_command('bind !@2 input /ma "Curaga II"')
    send_command('bind !@3 input /ma "Curaga III"')
    send_command('bind !@4 input /ma "Curaga IV"')
    send_command('bind !@5 input /ma "Curaga V"')
    send_command('bind !5  input /ma Haste <stpc>')
    send_command('bind !8  input /ma Auspice <me>')
    send_command('bind !9  input /ma "Regen IV" <stpc>')
    send_command('bind !0  input /ma Flash')

    send_command('bind @1  input /ma Poisona')
    send_command('bind @2  input /ma Paralyna')
    send_command('bind @3  input /ma Blindna')
    send_command('bind @4  input /ma Silena')
    send_command('bind @5  input /ma Stona')
    send_command('bind @6  input /ma Viruna')
    send_command('bind @7  input /ma Cursna')
    send_command('bind @F1 input /ma Erase')
    send_command('bind @F2 input /ma Esuna <me>')
    send_command('bind @F3 input /ma Sacrifice')
    send_command('bind @F4 input /ma "Full Cure" <t>')

    send_command('bind ^@1  input /ma Barfira <me>')
    send_command('bind ^@2  input /ma Barblizzara <me>')
    send_command('bind ^@3  input /ma Baraera <me>')
    send_command('bind ^@4  input /ma Barstonra <me>')
    send_command('bind ^@5  input /ma Barthundra <me>')
    send_command('bind ^@6  input /ma Barwatera <me>')
    send_command('bind ~^@1 input /ma Baramnesra <me>')
    send_command('bind ~^@2 input /ma Barparalyzra <me>')
    send_command('bind ~^@3 input /ma Barsilencera <me>')
    send_command('bind ~^@4 input /ma Barpetra <me>')
    send_command('bind ~^@5 input /ma Barsleepra <me>')
    send_command('bind ~^@6 input /ma Barpoisonra <me>')

    send_command('bind ~^1 input /ma Boost-STR <me>')
    send_command('bind ~^2 input /ma Boost-DEX <me>')
    send_command('bind ~^3 input /ma Boost-INT <me>')
    send_command('bind ~^4 input /ma Boost-MND <me>')
    send_command('bind ~^5 input /ma Boost-VIT <me>')
    send_command('bind ~^6 input /ma Boost-AGI <me>')
    send_command('bind ~^7 input /ma Boost-CHR <me>')

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
        {['Yagrush']='Club',['YagAmmu']='Club',['YagTP']='Club',['YagAsc']='Club',
         ['Maxentius']='Club',['MaxTP']='Club',['MaxAsc']='Club',
         ['Daybreak']='Club',['DayTP']='Club',['DayAsc']='Club',['Staff']='Staff'})
    send_command('bind %\\\\  gs c ListWS')

    send_command('bind !w gs c set OffenseMode Normal')
    send_command('bind !@w gs c reset OffenseMode')
    send_command('bind !^q gs c set CombatWeapon Staff')
    send_command('bind !^w gs c weap Yag')
    send_command('bind !^e gs c weap Max')
    send_command('bind !^r gs c weap Day')
    send_command('bind ^@w gs c weap Yag Asc')
    send_command('bind ^@e gs c weap Max Asc')
    send_command('bind ^\\\\  gs c toggle WSMsg')
    send_command('bind ^@\\\\ gs c toggle DiaMsg')
    send_command('bind ^c gs c CureCheat')
    send_command('bind @c input /ma Blink <me>')
    send_command('bind @v input /ma Aquaveil <me>')
    send_command('bind !@g input /ma Stoneskin <me>')
    send_command('bind !b input /ma Repose <t>')    -- for charmed people
    send_command('bind !n input /ma "Holy II" <t>') -- for charmed people too
    send_command('bind ^q input /ma Dispelga')

    if     player.sub_job == 'SCH' then
        send_command('bind !6   input /ma Aurorastorm <me>')
        send_command('bind !7   input /ma Klimaform <me>')
        send_command('bind ^tab input /ja Sublimation <me>')
        send_command('bind @tab gs c penuparsi')
        send_command('bind @q   gs c celeralac')
        send_command('bind ^@q  gs c accemani')
        send_command('bind @e   input /ja "Light Arts" <me>')
        send_command('bind !@e  input /ja "Dark Arts" <me>') -- use twice for addendum
        send_command('bind !e   input /ma Sleep <stnpc>')
        send_command('bind !d   input /ma Dispel')
        send_command('bind @d   input /ma Aspir')
        send_command('bind !@d  input /ma Drain')
    elseif player.sub_job == 'RDM' then
        send_command('bind !6   input /ma Refresh <stpc>')
        send_command('bind !7   input /ma Flurry <stpc>')
        send_command('bind !@`  input /ja Convert <me>')
        send_command('bind @q   input /ma Bind <stnpc>')
        send_command('bind ^@q  input /ma Gravity <stnpc>')
        send_command('bind ^tab input /ma Dispel')
        send_command('bind !g   input /ma Phalanx <me>')
        send_command('bind !d   input /ma Distract')
        send_command('bind @d   input /ma Frazzle')
        send_command('bind !e   input /ma Sleep <stnpc>')
        send_command('bind !@e  input /ma "Sleep II" <stnpc>')
    elseif player.sub_job == 'BLM' then
        send_command('bind ^tab input /ja "Elemental Seal"')
        send_command('bind @q   input /ma Bind <stnpc>')
        send_command('bind ^@q  input /ma Sleepga <stnpc>')
        send_command('bind !e   input /ma Sleep <stnpc>')
        send_command('bind !@e  input /ma "Sleep II" <stnpc>')
        send_command('bind !d   input /ma Stun')
    elseif player.sub_job == 'DNC' then
        send_command('bind !v  input /ja "Spectral Jig" <me>')
        send_command('bind !d  input /ja "Violent Flourish"')
        send_command('bind !@d input /ja "Animated Flourish"')
        send_command('bind !f  input /ja "Haste Samba" <me>')
        send_command('bind !@f input /ja "Reverse Flourish" <me>')
        send_command('bind !e  input /ja "Box Step"')
        send_command('bind !@e input /ja Quickstep')
    elseif player.sub_job == 'NIN' then
        send_command('bind !e  input /ma "Utsusemi: Ni" <me>')
        send_command('bind !@e input /ma "Utsusemi: Ichi" <me>')
    elseif player.sub_job == 'SMN' then
        send_command('bind !e  input /pet "Mewing Lullaby" <t>')
        send_command('bind @e  input /pet "Aero II" <t>')
        send_command('bind !d  input /pet Assault <t>')
        send_command('bind @d  input /pet Retreat <me>')
        send_command('bind !b  input /ma "Cait Sith" <me>')
        send_command('bind @b  input /ma Garuda <me>')
        send_command('bind !@b input /pet Release <me>')
    end

    select_default_macro_book()
end

-- Called when this job file is unloaded (eg: job change)
-- Unset job keybinds here.
function user_unload()
    send_command('unbind %`')
    send_command('unbind ^-')
    send_command('unbind ^=')
    send_command('unbind ^space')
    send_command('unbind !space')
    send_command('unbind @space')
    send_command('unbind !@space')
    send_command('unbind @z')
    send_command('unbind !z')
    send_command('unbind ^1')
    send_command('unbind ^2')
    send_command('unbind ^3')
    send_command('unbind ^4')
    send_command('unbind ^5')
    send_command('unbind ^6')
    send_command('unbind ^backspace')
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
    send_command('unbind ^`')
    send_command('unbind !`')
    send_command('unbind !@`')
    send_command('unbind @`')
    send_command('unbind ^@`')
    send_command('unbind ^@tab')
    send_command('unbind !^`')
    send_command('unbind !-')
    send_command('unbind !=')
    send_command('unbind ^tab')
    send_command('unbind @tab')
    send_command('unbind @q')
    send_command('unbind ^@q')
    send_command('unbind ^q')
    send_command('unbind ^-')
    send_command('unbind ^=')
    send_command('unbind ^c')
    send_command('unbind @c')
    send_command('unbind @v')
    send_command('unbind !g')
    send_command('unbind !@g')
    send_command('unbind !v')
    send_command('unbind !d')
    send_command('unbind @d')
    send_command('unbind !@d')
    send_command('unbind !^d')
    send_command('unbind !f')
    send_command('unbind !@f')
    send_command('unbind !e')
    send_command('unbind @e')
    send_command('unbind !@e')
    send_command('unbind !b')
    send_command('unbind @b')
    send_command('unbind !@b')
    send_command('unbind !n')
    send_command('unbind @1')
    send_command('unbind @2')
    send_command('unbind @3')
    send_command('unbind @4')
    send_command('unbind @5')
    send_command('unbind @6')
    send_command('unbind @7')
    send_command('unbind @F1')
    send_command('unbind @F2')
    send_command('unbind @F3')
    send_command('unbind @F4')
    send_command('unbind @F5')
    send_command('unbind @F6')
    send_command('unbind @F7')
    send_command('unbind @F8')
    send_command('unbind !w')
    send_command('unbind !^w')
    send_command('unbind !^q')
    send_command('unbind !^e')
    send_command('unbind !^r')
    send_command('unbind !@w')
    send_command('unbind ^@1')
    send_command('unbind ^@2')
    send_command('unbind ^@3')
    send_command('unbind ^@4')
    send_command('unbind ^@5')
    send_command('unbind ^@6')
    send_command('unbind ~^@1')
    send_command('unbind ~^@2')
    send_command('unbind ~^@3')
    send_command('unbind ~^@4')
    send_command('unbind ~^@5')
    send_command('unbind ~^@6')
    send_command('unbind !@1')
    send_command('unbind !@2')
    send_command('unbind !@3')
    send_command('unbind !@4')
    send_command('unbind !@5')
    send_command('unbind ~^1')
    send_command('unbind ~^2')
    send_command('unbind ~^3')
    send_command('unbind ~^4')
    send_command('unbind ~^5')
    send_command('unbind ~^6')
    send_command('unbind ~^7')
    send_command('unbind ^\\\\')
    send_command('unbind ^@\\\\')
    send_command('unbind %\\\\')
    send_command('unbind !^1')
    send_command('unbind !^2')
    send_command('unbind !^3')
    send_command('unbind !^4')
    send_command('unbind !^5')
    send_command('unbind ^numpad1')
    send_command('unbind ^numpad2')
    send_command('unbind ^numpad3')
    send_command('unbind ^numpad4')
    send_command('unbind ^numpad5')
    send_command('unbind ^numpad6')
    send_command('unbind ^numpad7')
    send_command('unbind ^numpad8')
    send_command('unbind ^numpad9')
    send_command('unbind !numpad1')
    send_command('unbind !numpad2')
    send_command('unbind !numpad3')
    send_command('unbind !numpad4')
    send_command('unbind !numpad5')
    send_command('unbind !numpad6')
    send_command('unbind !numpad7')
    send_command('unbind !numpad8')
    send_command('unbind !numpad9')
    send_command('unbind !^numpad0')

    if state.AllyBinds.value then info.ally_keybinds:unbind() end
    info.ws_binds:unbind()

    destroy_state_text()
end

-- Define sets and vars used by this job file.
function init_gear_sets()

    sets.weapons = {}
    sets.weapons.Yagrush   = {main="Yagrush",sub="Genmei Shield"}
    sets.weapons.YagAmmu   = {main="Yagrush",sub="Ammurapi Shield"}
    sets.weapons.YagTP     = {main="Yagrush",sub="Makhila +2"}
    sets.weapons.YagAsc    = {main="Yagrush",sub="Asclepius"}
    sets.weapons.Maxentius = {main="Maxentius",sub="Genmei Shield"}
    sets.weapons.MaxTP     = {main="Maxentius",sub="Makhila +2"}
    sets.weapons.MaxAsc    = {main="Maxentius",sub="Asclepius"}
    sets.weapons.Daybreak  = {main="Daybreak",sub="Genmei Shield"}
    sets.weapons.DayTP     = {main="Daybreak",sub="Makhila +2"}
    sets.weapons.DayAsc    = {main="Daybreak",sub="Asclepius"}
    sets.weapons.Staff     = {main="Xoanon",sub="Niobid Strap"}
    sets.TreasureHunter = {head="Volte Cap",waist="Chaac Belt",feet=gear.chir_feet_th}

    -- Precast Sets

    sets.precast.Step = {ammo="Amar Cluster",
        head="Ayanmo Zucchetto +2",neck="Combatant's Torque",ear1="Dignitary's Earring",ear2="Telos Earring",
        body="Ayanmo Corazza +2",hands="Ayanmo Manopolas +2",ring1="Ilabrat Ring",ring2="Cacoethic Ring +1",
        back=gear.TPCape,waist="Grunfeld Rope",legs="Ayanmo Cosciales +2",feet="Ayanmo Gambieras +2"}
    sets.precast.JA['Violent Flourish'] = set_combine(sets.precast.Step, {
        neck="Sanctity Necklace",ring1="Etana Ring",waist="Eschan Stone"})

    sets.precast.FC = {ammo="Sapience Orb",
        head="Nahtirah Hat",neck="Orunmila's Torque",ear1="Malignance Earring",ear2="Etiolation Earring",
        body="Inyanga Jubbah +2",hands="Fanatic Gloves",ring2="Kishar Ring",
        back=gear.FCCape,waist="Embla Sash",legs="Ayanmo Cosciales +2",feet="Telchine Pigaches"}
    sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {waist="Siegel Sash"})
    sets.precast.FC['Healing Magic'] = set_combine(sets.precast.FC, {legs="Ebers Pantaloons +1"})
    sets.precast.FC.StatusRemoval = set_combine(sets.precast.FC['Healing Magic'], {main="Yagrush",sub="Genmei Shield"})
    sets.precast.FC.Cure = set_combine(sets.precast.FC['Healing Magic'], {body="Heka's Kalasiris",feet="Hygieia Clogs +1"})
    sets.precast.FC.CureSolace = set_combine(sets.precast.FC.Cure, {})
    sets.precast.FC.CureCheat = {main="Yagrush",sub="Genmei Shield",ammo="Sapience Orb",
        head="Piety Cap",neck="Orunmila's Torque",ear1="Malignance Earring",ear2="Mendicant's Earring",
        body="Heka's Kalasiris",hands="Volte Gloves",ring1="Inyanga Ring",ring2="Kishar Ring",
        back=gear.FCCape,waist="Embla Sash",legs=empty,feet="Hygieia Clogs +1"}
    sets.precast.FC.Curaga = set_combine(sets.precast.FC.Cure, {})
    sets.impact = {head=empty,body="Twilight Cloak"}
    sets.precast.FC.Impact = set_combine(sets.precast.FC, sets.impact)
    sets.dispelga = {main="Daybreak",sub="Ammurapi Shield"}
    sets.precast.FC.Dispelga = set_combine(sets.precast.FC, sets.dispelga)

    sets.precast.JA.Devotion = {head="Piety Cap"}
    sets.precast.JA.Benediction = {body="Piety Briault +3"}

    sets.precast.WS = {ammo="Amar Cluster",
        head="Ayanmo Zucchetto +2",neck="Fotia Belt",ear1="Moonshade Earring",ear2="Telos Earring",
        body="Ayanmo Corazza +2",hands="Ayanmo Manopolas +2",ring1="Ilabrat Ring",ring2="Rufescent Ring",
        back=gear.WSCape,waist="Fotia Belt",legs="Ayanmo Cosciales +2",feet="Ayanmo Gambieras +2"}
    sets.precast.WS['Hexa Strike'] = set_combine(sets.precast.WS, {ear1="Dignitary's Earring",ring2="Begrudging Ring",back=gear.TPCape})
    sets.precast.WS['Mystic Boon'] = set_combine(sets.precast.WS, {waist="Grunfeld Rope"})
    sets.precast.WS['Black Halo']  = set_combine(sets.precast.WS, {
        ear2="Regal Earring",ring1="Metamorph Ring +1",waist="Grunfeld Rope",legs="Piety Pantaloons +3"})
    sets.precast.WS['Brainshaker'] = set_combine(sets.precast.WS, {neck="Sanctity Necklace",waist="Eschan Stone"})
    sets.precast.WS['Shell Crusher'] = set_combine(sets.precast.WS['Brainshaker'], {})
    sets.precast.WS['Flash Nova'] = set_combine(sets.precast.WS, {ammo="Pemphredo Tathlum",
        head="Chironic Hat",neck="Sanctity Necklace",ear1="Malignance Earring",ear2="Friomisi Earring",
        body="Witching Robe",hands="Chironic Gloves",ring1="Metamorph Ring +1",ring2="Freke Ring",
        back="Izdubar Mantle",waist=gear.ElementalObi,legs="Chironic Hose",feet=gear.chir_feet_ma})
    sets.precast.WS['Earth Crusher'] = set_combine(sets.precast.WS['Flash Nova'], {ear1="Moonshade Earring"})
    sets.precast.WS['Cataclysm'] = set_combine(sets.precast.WS['Earth Crusher'], {head="Pixie Hairpin +1",ring1="Archon Ring"})

    -- Midcast Sets

    sets.midcast.Cure = {main="Queller Rod",sub="Genmei Shield",ammo="Staunch Tathlum +1",
        head="Theophany Cap +3",neck="Loricate Torque +1",ear1="Glorious Earring",ear2="Mendicant's Earring",
        body="Theophany Briault +3",hands="Kaykaus Cuffs +1",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.ENMCape,waist=gear.ElementalObi,legs="Ebers Pantaloons +1",feet="Medium's Sabots"}
    sets.midcast.Curaga = set_combine(sets.midcast.Cure, {})
    -- cure+58%, enm-48 (and -22 from tranquil heart), pdt-47, mdt-27
    sets.midcast.CureSolace = set_combine(sets.midcast.Cure, {body="Ebers Bliaud +1"})
    -- cure+54%, solace+24%, enm-42 (and -25 from tranquil heart), pdt-47, mdt-27
    sets.midcast.Cure.Melee = set_combine(sets.midcast.Cure, {ear2="Mendicant's Earring",body="Chironic Doublet"})
    sets.midcast.Curaga.Melee = set_combine(sets.midcast.Cure.Melee, {})
    sets.midcast.CureSolace.Melee = set_combine(sets.midcast.Cure.Melee, {neck="Nodens Gorget",
        body="Ebers Bliaud +1",hands="Kaykaus Cuffs +1"})
    sets.midcast.Cure.Enmity = {main="Mafic Cudgel",sub="Genmei Shield",ammo="Staunch Tathlum +1",
        head="Ebers Cap +1",neck="Unmoving Collar +1",ear1="Cryptic Earring",ear2="Trux Earring",
        body="Chironic Doublet",hands="Telchine Gloves",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.MEVACape,waist="Goading Belt",legs="Ebers Pantaloons +1",feet="Inyanga Crackows +2"}
    sets.midcast.Curaga.Enmity = set_combine(sets.midcast.Cure.Enmity, {})
    sets.midcast.CureSolace.Enmity = set_combine(sets.midcast.Cure.Enmity, {})
    -- cure+50%, solace+10%, enm+38 (and -25 from tranquil heart), pdt-50, mdt-21
    sets.midcast.CureCheat = {main="Asclepius",sub="Ammurapi Shield",ammo="Staunch Tathlum +1",
        head="Theophany Cap +3",neck="Nodens Gorget",ear1="Glorious Earring",ear2="Etiolation Earring",
        body="Chironic Doublet",hands="Telchine Gloves",ring1="Vocane Ring +1",ring2="Defending Ring",
        back="Moonbeam Cape",waist="Gishdubar Sash",legs="Ebers Pantaloons +1",feet="Skaoi Boots"}
    sets.midcast.CureCheat.Enmity = set_combine(sets.midcast.CureCheat, {main="Asclepius",sub="Genmei Shield",
        head="Ebers Cap +1",neck="Unmoving Collar +1",ear1="Cryptic Earring",
        waist="Goading Belt",feet="Theophany Duckbills +3"})
    sets.cmp_belt  = {waist="Shinjutsu-no-Obi +1"}
    sets.gishdubar = {waist="Gishdubar Sash"}

    sets.midcast.StatusRemoval = {main="Yagrush",sub="Genmei Shield",head="Ebers Cap +1",legs="Ebers Pantaloons +1"}
    sets.midcast.Erase = set_combine(sets.midcast.StatusRemoval, {neck="Cleric's Torque +2"})
    sets.midcast.Raise = {main="Asclepius",sub="Genmei Shield",ammo="Pemphredo Tathlum",
        head="Vanya Hood",neck="Loricate Torque +1",ear1="Malignance Earring",ear2="Mendicant's Earring",
        body="Witching Robe",hands="Fanatic Gloves",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.MEVACape,waist="Goading Belt",legs="Lengo Pants",feet="Medium's Sabots"}
    sets.midcast.Reraise = set_combine(sets.midcast.Raise, {})
    sets.midcast.Esuna   = set_combine(sets.midcast.Raise, {})
    sets.buff['Divine Caress'] = {hands="Ebers Mitts +1",back="Mending Cape"}
    sets.midcast.Cursna = {main="Yagrush",sub="Genmei Shield",ammo="Staunch Tathlum +1",
        head="Nahtirah Hat",neck="Debilis Medallion",ear1="Glorious Earring",ear2="Novia Earring",
        body="Ebers Bliaud +1",hands="Fanatic Gloves",ring1="Haoma's Ring",ring2="Haoma's Ring",
        back=gear.FCCape,waist="Goading Belt",legs="Theophany Pantaloons +3",feet="Vanya Clogs"}
    -- heal.skill=566, cursna+106 (est. 58% success)

    sets.midcast.EnhancingDuration = {main="Gada",sub="Ammurapi Shield",ammo="Staunch Tathlum +1",
        head="Telchine Cap",body="Telchine Chasuble",hands="Telchine Gloves",
        waist="Embla Sash",legs="Telchine Braconi",feet="Theophany Duckbills +3"}
    sets.midcast['Enhancing Magic'] = set_combine(sets.midcast.EnhancingDuration, {main="Gada",sub="Ammurapi Shield",
        head="Telchine Cap",neck="Incanter's Torque",ear1="Mimir Earring",ear2="Andoaa Earring",
        body="Telchine Chasuble",hands="Inyanga Dastanas +2",ring1=gear.Lstikini,ring2=gear.Rstikini,
        back="Perimede Cape",waist="Olympus Sash",legs="Piety Pantaloons +3",feet="Theophany Duckbills +3"})
    sets.midcast.Stoneskin = set_combine(sets.midcast.EnhancingDuration, {neck="Nodens Gorget",waist="Siegel Sash"})
    sets.midcast.Aquaveil = set_combine(sets.midcast.EnhancingDuration, {main="Vadose Rod",sub="Ammurapi Shield",head="Chironic Hat"})
    sets.midcast.Auspice = set_combine(sets.midcast.EnhancingDuration, {feet="Ebers Duckbills +1"})
    sets.midcast.Shellra = set_combine(sets.midcast.EnhancingDuration, {legs="Piety Pantaloons +3"})
    sets.midcast.BarElement = set_combine(sets.midcast['Enhancing Magic'], {main="Beneficus",sub="Ammurapi Shield",
        head="Ebers Cap +1",body="Ebers Bliaud +1",hands="Ebers Mitts +1",
        back=gear.FCCape,legs="Piety Pantaloons +3",feet="Ebers Duckbills +1"})
    sets.midcast.BarElement.NoGrimoire = set_combine(sets.midcast.BarElement, {hands="Inyanga Dastanas +2"})
    sets.midcast.Regen = set_combine(sets.midcast.EnhancingDuration, {main="Bolelabunga",sub="Ammurapi Shield",
        head="Inyanga Tiara +2",body="Piety Briault +3",hands="Ebers Mitts +1",legs="Theophany Pantaloons +3"})
    sets.midcast.FixedPotencyEnhancing = set_combine(sets.midcast.EnhancingDuration, {})

    sets.midcast['Divine Magic'] = {main="Daybreak",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
        head="Chironic Hat",neck="Sanctity Necklace",ear1="Malignance Earring",ear2="Regal Earring",
        body="Witching Robe",hands="Chironic Gloves",ring1="Metamorph Ring +1",ring2="Freke Ring",
        back=gear.ENMCape,waist=gear.ElementalObi,legs="Chironic Hose",feet=gear.chir_feet_ma}
    sets.midcast['Divine Magic'].MB = set_combine(sets.midcast['Divine Magic'], {
        neck="Mizukage-no-Kubikazari",ring1="Mujin Band",ring2="Locus Ring"})
    sets.midcast.Banish = set_combine(sets.midcast['Divine Magic'], {hands="Fanatic Gloves"})
    sets.orpheus   = {waist="Orpheus's Sash"}
    sets.ele_obi   = {waist="Hachirin-no-Obi"}
    sets.nuke_belt = {waist="Sacro Cord"}

    sets.midcast.Repose = {main="Asclepius",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
        head="Theophany Cap +3",neck="Erra Pendant",ear1="Malignance Earring",ear2="Regal Earring",
        body="Theophany Briault +3",hands="Inyanga Dastanas +2",ring1=gear.Lstikini,ring2="Kishar Ring",
        back=gear.ENMCape,waist="Sacro Cord",legs="Theophany Pantaloons +3",feet="Theophany Duckbills +3"}
    sets.midcast.Flash = {main="Mafic Cudgel",sub="Genmei Shield",ammo="Staunch Tathlum +1",
        head="Inyanga Tiara +2",neck="Unmoving Collar +1",ear1="Cryptic Earring",ear2="Trux Earring",
        body="Inyanga Jubbah +2",hands="Inyanga Dastanas +2",ring1="Supershear Ring",ring2="Eihwaz Ring",
        back=gear.MEVACape,waist="Goading Belt",legs="Inyanga Shalwar +2",feet="Inyanga Crackows +2"}

    sets.midcast.Drain = set_combine(sets.midcast.Repose, {main="Rubicundity",sub="Ammurapi Shield",
        head="Pixie Hairpin +1",ring1="Archon Ring",ring2="Evanescence Ring"})
    sets.midcast.Aspir = set_combine(sets.midcast.Drain, {})
    sets.drain_belt = {waist="Fucho-no-Obi"}

    sets.midcast.Stun = set_combine(sets.midcast.Repose, {})
    sets.midcast['Elemental Magic'] = set_combine(sets.midcast['Divine Magic'], {})
    sets.midcast.Impact = set_combine(sets.midcast.Repose, {waist=gear.ElementalObi}, sets.impact)

    sets.midcast['Enfeebling Magic'] = {main="Asclepius",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
        head="Theophany Cap +3",neck="Erra Pendant",ear1="Malignance Earring",ear2="Regal Earring",
        body="Theophany Briault +3",hands="Kaykaus Cuffs +1",ring1=gear.Lstikini,ring2=gear.Rstikini,
        back=gear.ENMCape,waist="Sacro Cord",legs="Chironic Hose",feet="Theophany Duckbills +3"}
    sets.midcast.Sleep = set_combine(sets.midcast['Enfeebling Magic'], {ring1="Metamorph Ring +1",ring2="Kishar Ring"})
    sets.midcast.Bind = set_combine(sets.midcast.Sleep, {})
    sets.midcast.Gravity = set_combine(sets.midcast.Sleep, {})
    sets.midcast.Dispelga = set_combine(sets.midcast['Enfeebling Magic'], sets.dispelga)
    sets.midcast.MndEnfeebles = set_combine(sets.midcast['Enfeebling Magic'], {main="Daybreak",sub="Ammurapi Shield",
        ring1="Metamorph Ring +1",waist="Luminary Sash"})
    sets.midcast.IntEnfeebles = set_combine(sets.midcast.MndEnfeebles, {main="Maxentius",sub="Ammurapi Shield"})

    sets.midcast.Utsusemi = {waist="Goading Belt"}

    -- Sets to return to when not performing an action.

    sets.idle = {main="Asclepius",sub="Genmei Shield",ammo="Homiliary",
        head="Inyanga Tiara +2",neck="Loricate Torque +1",ear1="Thureous Earring",ear2="Etiolation Earring",
        body="Theophany Briault +3",hands="Volte Gloves",ring1="Inyanga Ring",ring2="Defending Ring",
        back=gear.MEVACape,waist="Slipor Sash",legs="Inyanga Shalwar +2",feet="Herald's Gaiters"}
    sets.idle.PDT = set_combine(sets.idle, {main="Asclepius",sub="Genmei Shield",ammo="Staunch Tathlum +1",
        neck="Warder's Charm +1",ring1="Vocane Ring +1",feet="Inyanga Crackows +2"})
    sets.idle.MEVA = set_combine(sets.idle, {main="Daybreak",sub="Genmei Shield",ammo="Staunch Tathlum +1",
        neck="Warder's Charm +1",body="Inyanga Jubbah +2",ring1="Inyanga Ring",feet="Inyanga Crackows +2"})
    sets.idle.Rf = set_combine(sets.idle, {main="Bolelabunga",sub="Genmei Shield",ammo="Homiliary",
        ear1="Genmei Earring",ring1="Inyanga Ring",ring2=gear.Rstikini,feet="Inyanga Crackows +2"})
    sets.latent_refresh = {ammo="Homiliary",waist="Fucho-no-obi"}
    sets.buff.doom = {neck="Nicander's Necklace",ring1="Eshmun's Ring",waist="Gishdubar Sash"}

    sets.defense.PDT    = set_combine(sets.idle.PDT, {})
    sets.defense.MEVA   = set_combine(sets.idle.MEVA, {})
    sets.defense.MRf    = set_combine(sets.idle.Rf, {main="Asclepius",sub="Genmei Shield"})
    sets.Kiting = {feet="Herald's Gaiters"}

    sets.engaged = {main="Yagrush",sub="Genmei Shield",ammo="Amar Cluster",
        head="Ayanmo Zucchetto +2",neck="Combatant's Torque",ear1="Brutal Earring",ear2="Telos Earring",
        body="Ayanmo Corazza +2",hands="Ayanmo Manopolas +2",ring1="Ilabrat Ring",ring2="Petrov Ring",
        back=gear.TPCape,waist="Windbuffet Belt +1",legs="Ayanmo Cosciales +2",feet="Battlecast Gaiters"}
    sets.engaged.Acc = set_combine(sets.engaged, {ear1="Dignitary's Earring",ring2="Cacoethic Ring +1"})
    sets.engaged.PDef = set_combine(sets.engaged, {ring1="Vocane Ring +1",ring2="Defending Ring"})
    sets.engaged.Acc.PDef = set_combine(sets.engaged.Acc, {ring1="Vocane Ring +1",ring2="Defending Ring"})
    sets.dualwield = {back=gear.TPCapeDW} -- applied inside customize_melee_set

    -- Resting set
    sets.resting = set_combine(sets.idle, {main="Boonwell Staff",sub="Niobid Strap",waist="Shinjutsu-no-obi +1"})

    -- Sets that depend upon idle sets
    sets.midcast.FastRecast = set_combine(sets.idle.PDT, {main="Asclepius",sub="Genmei Shield",waist="Goading Belt"})
    sets.midcast.Dia     = set_combine(sets.idle, sets.TreasureHunter)
    sets.midcast.Bio     = set_combine(sets.idle, sets.TreasureHunter)
    sets.midcast.Stone   = set_combine(sets.idle, sets.TreasureHunter)
    sets.midcast.Stonega = set_combine(sets.idle, sets.TreasureHunter)

    sets.encumber = {ammo="Homiliary",
        head="Theophany Cap +3",neck="Orunmila's Torque",ear1="Glorious Earring",ear2="Novia Earring",
        body="Ebers Bliaud +1",hands="Fanatic Gloves",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.FCCape,waist="Embla Sash",legs="Ebers Pantaloons +1",feet="Medium's Sabots"}
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.
function job_precast(spell, action, spellMap, eventArgs)
    if spell.english == "Dark Arts" then
        send_command('input /ja "Addendum: Black" <me>')
    elseif classes.CustomClass == 'CureCheat' then
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
            equip(resolve_orpheus(spell, sets.ele_obi, sets.nuke_belt, 3))
        end
    end
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_midcast(spell, action, spellMap, eventArgs)
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

function job_post_midcast(spell, action, spellMap, eventArgs)
    -- Apply Divine Caress boosting items as highest priority over other gear, if applicable.
    if state.Buff['Divine Caress'] and spellMap == 'StatusRemoval' and spell.english ~= 'Erase' then
        equip(sets.buff['Divine Caress'])
        if spell.english == 'Cursna' then
            equip({back=gear.MEVACape})
        end
    elseif S{'Cure','CureSolace','Curaga'}:contains(spellMap) and state.CastingMode.value ~= 'Enmity' then
        if gear.ElementalObi.name == gear.default.obi_waist then
            if spell.target.type == 'SELF' and S{'Cure','CureSolace'}:contains(spellMap) then
                equip(sets.gishdubar)
            else
                equip(sets.cmp_belt)
            end
        end
    elseif S{'Drain','Aspir'}:contains(spellMap) then
        equip(resolve_orpheus(spell, sets.ele_obi, sets.drain_belt, 5))
    elseif spell.english == 'Refresh' and spell.target.type == 'SELF' then
        equip(sets.gishdubar)
    elseif spellMap == 'BarElement' and not state.Buff['Light Arts'] then
        equip(sets.midcast.BarElement.NoGrimoire)
    elseif S{'Banish','Holy'}:contains(spellMap) or spell.skill == 'Elemental Magic' then
        if state.MagicBurst.value then equip(sets.midcast['Divine Magic'].MB) end
        equip(resolve_orpheus(spell, sets.ele_obi, sets.nuke_belt, 3))
    end
    if spell.target.type == 'SELF' and spell.english == 'Cursna' and state.Buff.doom then
        equip(sets.buff.doom)
    end
end

function job_aftercast(spell, action, spellMap, eventArgs)
    if spell.interrupted then
        send_command('wait 0.5;gs c update')
        interrupted_message(spell)
    else
        if spell.type == 'JobAbility' then
            eventArgs.handled = true
        elseif spell.english == 'Dia II' and state.DiaMsg.value then
            if spell.target.name and spell.target.type == 'MONSTER' then
                send_command('@input /p '..spell.english..' /')
            end
        elseif spell.type == 'WeaponSkill' and state.WSMsg.value then
            if state.WSMsg.value then
                send_command('@input /p '..spell.english)
            end
        elseif spell.english == 'Sleep' or spell.english == 'Sleepga' then
            send_command('@timers c "'..spell.english..' ['..spell.target.name..']" 66 down')
        elseif spell.english == 'Sleep II' or spell.english == 'Repose' then
            send_command('@timers c "'..spell.english..' ['..spell.target.name..']" 99 down')
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
    if gain then
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
    if spell.action_type == 'Magic' then
        if default_spell_map == 'Cure' and state.Buff['Afflatus Solace'] then
            return "CureSolace"
        elseif spell.skill == 'Enfeebling Magic' then
            -- Spells with variable potencies, divided into dINT and dMND spells.
            -- These spells also benefit from RDM gear and WKR shoes.
            if S{'Slow','Paralyze','Addle','Distract','Frazzle'}:contains(spell.english) then
                return "MndEnfeebles"
            elseif S{'Blind','Gravity'}:contains(spell.english) then
                return "IntEnfeebles"
            end
        elseif spell.skill == 'Enhancing Magic' then
            if  not S{'Erase','Phalanx','Stoneskin','Aquaveil'}:contains(spell.english)
            and not S{'Regen','BarElement','BarStatus','Shellra','EnSpell','StatBoost','Teleport'}:contains(default_spell_map) then
                return "FixedPotencyEnhancing"
            end
        end
    end
end

function customize_idle_set(idleSet)
    if player.mpp < 60 and state.DefenseMode.value == 'None' then
        idleSet = set_combine(idleSet, sets.latent_refresh)
    end
    if has_any_buff_of(S{'petrification','sleep','stun','terror'}) then
        idleSet = set_combine(sets.defense.PDT, {})
    end
    if buffactive['Reive Mark'] then
        if player.inventory["Arciela's Grace +1"] then idleSet = set_combine(idleSet, {neck="Arciela's Grace +1"}) end
    end
    return idleSet
end

function customize_melee_set(meleeSet)
    if state.DefenseMode.value == 'None' then
        if state.CombatForm.has_value and state.CombatForm.value == 'DW' then
            meleeSet = set_combine(meleeSet, sets.dualwield)
        end
    end
    if has_any_buff_of(S{'petrification','sleep','stun','terror'}) then
        meleeSet = set_combine(sets.defense.PDT, {})
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
    eventArgs.handled = true

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
        if state.Buff['Light Arts'] or state.Buff['Addendum: White'] then
            msg = msg .. ' L.Arts'
        elseif state.Buff['Dark Arts'] or state.Buff['Addendum: Black'] then
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

    if state.DefenseMode.value ~= 'None' then
        local defMode = state[state.DefenseMode.value ..'DefenseMode'].current
        msg = msg .. ' Def[' .. state.DefenseMode.value .. ':' .. defMode .. ']'
    end

    if state.Kiting.value == true then
        msg = msg .. ' Kiting'
    end

    if state.PCTargetMode.value ~= 'default' then
        msg = msg .. ', Target PC: '..state.PCTargetMode.value
    end

    if state.SelectNPCTargets.value == true then
        msg = msg .. ', Target NPCs'
    end

    add_to_chat(122, msg)
end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements self-commands.
-------------------------------------------------------------------------------------------------------------------

-- Called for custom player commands.
function job_self_command(cmdParams, eventArgs)
    if     cmdParams[1] == 'CureCheat' then
        classes.CustomClass = 'CureCheat'
        send_command('input /ma "Cure III" <me>')
    elseif cmdParams[1] == 'ListWS' then
        info.ws_binds:print('ListWS:')
    elseif cmdParams[1] == 'weap' then
        weap_self_command(cmdParams, 'CombatWeapon')
    elseif cmdParams[1] == 'save' then
        save_self_command(cmdParams)
    elseif player.sub_job == 'SCH' then
        if cmdParams[1] == 'penuparsi' then
            if state.Buff['Light Arts'] or state.Buff['Addendum: White'] then
                send_command('input /ja Penury <me>')
            end
            if state.Buff['Dark Arts'] or state.Buff['Addendum: Black'] then
                send_command('input /ja Parsimony <me>')
            end
            eventArgs.handled = true
        elseif cmdParams[1] == 'celeralac' then
            if state.Buff['Light Arts'] or state.Buff['Addendum: White'] then
                send_command('input /ja Celerity <me>')
            end
            if state.Buff['Dark Arts'] or state.Buff['Addendum: Black'] then
                send_command('input /ja Alacrity <me>')
            end
            eventArgs.handled = true
        elseif cmdParams[1] == 'accemani' then
            if state.Buff['Light Arts'] or state.Buff['Addendum: White'] then
                send_command('input /ja Accession <me>')
            end
            if state.Buff['Dark Arts'] or state.Buff['Addendum: Black'] then
                send_command('input /ja Manifestation <me>')
            end
            eventArgs.handled = true
        end
    elseif cmdParams[1] == 'encumber' then
        equip(sets.encumber)
        disable('head','neck','ear1','ear2','body','hands','ring1','ring2','back','waist','legs','feet')
    --elseif cmdParams[1] == 'mooglehp' then
    --    equip({neck="Sanctity Necklace",ear1="Thureous Earring",ear2="Etiolation Earring",
    --        ring1="Etana Ring",ring2="Ilabrat Ring",back="Moonbeam Cape"})
    --    disable('neck','ear1','ear2','ring1','ring2','back')
    --    if cmdParams[2] and cmdParams[2] == 'off' then
    --        enable('neck','ear1','ear2','ring1','ring2','back')
    --        handle_equipping_gear(player.status)
    --    end
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

function init_state_text()
    destroy_state_text()
    local mb_text_settings  = {flags={draggable=false},bg={alpha=150}}
    local hyb_text_settings = {pos={x=130,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local def_text_settings = {pos={x=172,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    state.mb_text  = texts.new('MBurst',         mb_text_settings)
    state.hyb_text = texts.new('initializing..', hyb_text_settings)
    state.def_text = texts.new('initializing..', def_text_settings)

    windower.register_event('logout', destroy_state_text)
    state.texts_event_id = windower.register_event('prerender', function()
        state.mb_text:visible(state.MagicBurst.value)

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
        for text in S{state.mb_text, state.hyb_text, state.def_text}:it() do
            text:hide()
            text:destroy()
        end
    end
    state.texts_event_id = nil
end
