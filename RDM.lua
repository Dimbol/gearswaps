-- Modified from 'https://github.com/Kinematics/GearSwap-Jobs/blob/master/RDM.lua'
-- Defines gearsets and job keybinds for RDM.

-- distract3 formula:
-- floor((6/21)*(enf.skill-190))+floor(dmnd/5) where dmnd/5 is between 0 and 10

-- /nin dual wield cheatsheet
-- haste:   0   15  30  cap
--   +dw:  49   42  31   11

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
    state.Buff.Saboteur = buffactive.Saboteur or false
    state.Buff.Stymie = buffactive.Stymie or false
    state.Buff['Elemental Seal']  = buffactive['Elemental Seal'] or false
    state.Buff['Light Arts']      = buffactive['Light Arts'] or false
    state.Buff['Dark Arts']       = buffactive['Dark Arts'] or false
    state.Buff['Addendum: White'] = buffactive['Addendum: White'] or false
    state.Buff['Addendum: Black'] = buffactive['Addendum: Black'] or false
    state.Buff.doom = buffactive.doom or false

    include('Mote-TreasureHunter')
    state.texts_event_id = nil
    state.aeonic_aftermath_precast = false
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
    state.OffenseMode:options('None','STP','Normal','Acc')              -- Cycle with F9, set with !w, !@w
    state.HybridMode:options('Normal','PDef')                           -- Cycle with ^F9
    state.WeaponskillMode:options('Normal','NoDmg')
    state.CastingMode:options('Normal','Resistant','FullPot','Enmity')  -- Cycle with F10
    state.IdleMode:options('Normal','PDT')                              -- Cycle with F11
    state.CombatWeapon = M{['description']='Combat Weapon'}             -- Cycle with @F9
    if S{'DNC','NIN'}:contains(player.sub_job) then
        state.CombatWeapon:options('SeqTern','SeqTernBow','NaegThib','NaegThiBow',
                                   'MaxThib','MaxThiBow','TaurTern','TaMalev','None')--,'trials')
		state.CombatForm:set('DW')
    else
        state.CombatWeapon:options('Sequence','NaegAmmu','NaegBow','Tauret','None')
		state.CombatForm:reset()
    end
    state.WSBinds = M{['description']='WS Binds',['string']=''}

    state.Seidr      = M(false, 'Seidr Nukes')                          -- Toggle with !@z
    state.MagicBurst = M(false, 'Magic Burst')                          -- Toggle with !z
    state.WSMsg      = M(false, 'WS Message')                           -- Toggle with ^\
    state.DiaMsg     = M(false, 'Dia Message')                          -- Toggle with ^@\
    init_state_text()

    -- Augmented items get variables for convenience and specificity
    gear.arrow = {name="Chapuli Arrow"}
    gear.taeon_head_phlx  = {name="Taeon Chapeau", augments={'Phalanx +3'}}
    gear.taeon_body_phlx  = {name="Taeon Tabard", augments={'Spell interruption rate down -10%','Phalanx +3'}}
    gear.taeon_hands_phlx = {name="Taeon Gloves", augments={'Spell interruption rate down -8%','Phalanx +3'}}
    gear.taeon_legs_phlx  = {name="Taeon Tights", augments={'Phalanx +3'}}
    gear.taeon_feet_phlx  = {name="Taeon Boots", augments={'Spell interruption rate down -9%','Phalanx +3'}}
    gear.colada_enh  = {name="Colada", augments={'Enh. Mag. eff. dur. +4','STR+7','Mag. Acc.+2','"Mag.Atk.Bns."+20','DMG:+5'}}
    gear.colada_rf   = {name="Colada", augments={'"Refresh"+2','INT+1','Mag. Acc.+12','"Mag.Atk.Bns."+4'}}
    gear.mer_head_mb = {name="Merlinic Hood", augments={'"Mag.Atk.Bns."+27','Magic burst dmg.+10%','Mag. Acc.+15'}}
    gear.mer_head_fc = {name="Merlinic Hood", augments={'Mag. Acc.+19 "Mag.Atk.Bns."+19','"Fast Cast"+6','MND+3'}}
    gear.mer_body_ma = {name="Merlinic Jubbah", 
        augments={'Mag. Acc.+22 "Mag.Atk.Bns."+22','"Fast Cast"+3','MND+10','Mag. Acc.+15','"Mag.Atk.Bns."+9'}}
    gear.mer_body_mb = {name="Merlinic Jubbah", augments={'Mag. Acc.+21 "Mag.Atk.Bns."+21','Magic burst dmg.+9%'}}
    gear.mer_legs_ma = {name="Merlinic Shalwar",
        augments={'Mag. Acc.+22 "Mag.Atk.Bns."+22','Damage taken-1%','MND+5','Mag. Acc.+14','"Mag.Atk.Bns."+14'}}
    gear.mer_feet_fc = {name="Merlinic Crackows", augments={'Mag. Acc.+5','"Fast Cast"+5','"Mag.Atk.Bns."+6'}}
    gear.chir_feet_ma = {name="Chironic Slippers", augments={'"Mag.Atk.Bns."+30','DEX+10','Mag. Acc.+14 "Mag.Atk.Bns."+14'}}
    gear.chir_feet_th = {name="Chironic Slippers",
        augments={'"Mag.Atk.Bns."+13','Accuracy+7','"Treasure Hunter"+1','Accuracy+19 Attack+19','Mag. Acc.+19 "Mag.Atk.Bns."+19'}}
    gear.GrioMB  = {name="Grioavolr", augments={'Magic burst dmg.+8%','INT+2','Mag. Acc.+10','"Mag.Atk.Bns."+16','Magic Damage +7'}}
    gear.GrioEnf = {name="Grioavolr", augments={'Enfb.mag. skill +12','Mag. Acc.+30','"Mag.Atk.Bns."+20','Magic Damage +4'}}
    gear.Lstikini = {name="Stikini Ring +1", bag="wardrobe2"}
    gear.Rstikini = {name="Stikini Ring +1", bag="wardrobe3"}
    gear.IdleCape = {name="Sucellos's Cape",
        augments={'MND+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Enmity+10','Phys. dmg. taken-10%'}}
    gear.EnfCape  = {name="Sucellos's Cape",
        augments={'MND+20','Mag. Acc+20 /Mag. Dmg.+20','MND+10','"Fast Cast"+10','Phys. dmg. taken-10%'}}
    gear.IntCape = {name="Sucellos's Cape",
        augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','INT+10','"Mag.Atk.Bns."+10','Phys. dmg. taken-10%'}}
    gear.TPCape   = {name="Sucellos's Cape",
        augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Store TP"+10','Phys. dmg. taken-10%'}}
    gear.WSCape   = {name="Sucellos's Cape",
        augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%','Phys. dmg. taken-10%'}}
    gear.CDCCape  = {name="Sucellos's Cape", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','Crit.hit rate+10'}}

    -- Mote-libs handle obis, gorgets, and other elemental things.
    -- These are default fallbacks if situationally appropriate gear is not available.
    gear.default.weaponskill_neck = "Combatant's Torque"    -- used in sets.precast.WS and friends
    gear.default.weaponskill_waist = "Windbuffet Belt +1"   -- used in sets.precast.WS and friends
    gear.default.obi_waist = "Refoccilation Stone"          -- used in nuke sets (cures overriden in job_post_midcast)
    gear.default.obi_ring = gear.Lstikini                   -- used in nuke sets

    -- Binds overriding Mote defaults
    send_command('unbind ^F10')
    send_command('unbind ^F11')
    send_command('bind F9   gs c cycle OffenseMode')
    send_command('bind !F9  gs c reset OffenseMode')
    send_command('bind @F9  gs c cycle CombatWeapon')
    send_command('bind !@F9 gs c cycleback CombatWeapon')
    send_command('bind F10  gs c cycle CastingMode')
    send_command('bind !F10 gs c reset CastingMode')
    send_command('bind F11  gs c cycle IdleMode')
    send_command('bind !F11 gs c reset IdleMode')
    send_command('bind @F11 gs c toggle Kiting')
    send_command('bind !F12 gs c cycle TreasureMode')
    send_command('bind ^space gs c cycle HybridMode')
    send_command('bind !space gs c set DefenseMode Physical')
    send_command('bind @space gs c set DefenseMode Magical')
    send_command('bind !@space gs c reset DefenseMode')
    send_command('bind !^q gs c set CombatWeapon TaurTern')
    send_command('bind !^w gs c set CombatWeapon SeqTern')
    send_command('bind !^e gs c set CombatWeapon NaegThib')
    send_command('bind !^r gs c set CombatWeapon MaxThib')
    send_command('bind !w  gs c   set OffenseMode STP')
    send_command('bind !@w gs c reset OffenseMode')
    send_command('bind !@z gs c toggle Seidr')
    send_command('bind !z  gs c toggle MagicBurst')
    send_command('bind ^\\\\  gs c toggle WSMsg')
    send_command('bind ^@\\\\ gs c toggle DiaMsg')
    send_command('bind ^@backspace gs c ListWS')

    -- JA binds
    send_command('bind ^` input /ja Stymie <me>')
    send_command('bind !` input /ja Spontaneity')
    send_command('bind @` input /ja Saboteur <me>')
    send_command('bind ^@tab input /ja Composure <me>')
    send_command('bind !^` input /ja Chainspell <me>')

    -- Spell binds
    send_command('bind ^tab input /ma Dispel')
    send_command('bind ^q input /ma Dispelga')
    send_command('bind ^1 input /ma "Dia III"')
    send_command('bind ^@1 input /ma Inundation')
    send_command('bind ^2 input /ma "Slow II"')
    send_command('bind ^@2 input /ma "Gravity II" <stnpc>')
    send_command('bind ^3 input /ma "Paralyze II"')
    send_command('bind ^@3 input /ma Bind <stnpc>')
    send_command('bind ^4 input /ma Addle II')
    send_command('bind ^@4 input /ma Silence')
    send_command('bind ^5 input /ma "Sleep II" <stnpc>')
    send_command('bind ^@5 input /ma Sleep <stnpc>')    -- becomes sleepga <t> /blm
    send_command('bind ^6 input /ma Break <stnpc>')
    send_command('bind ^@6 input /ma Gravity <stnpc>')
    send_command('bind ^7 input /ma "Blind II"')
    send_command('bind ^backspace input /ma Impact')

    send_command('bind !1 input /ma "Cure III" <stpc>')
    send_command('bind !2 input /ma "Cure IV" <stpc>')
    send_command('bind !3 input /ma "Distract III"')
    send_command('bind !@3 input /ma "Distract II"')
    send_command('bind !4 input /ma "Frazzle III"')
    send_command('bind !@4 input /ma "Frazzle II"')
    send_command('bind !5 input /ma "Haste II" <stpc>')
    send_command('bind !6 input /ma "Refresh III" <stpc>')
    send_command('bind !7 input /ma "Flurry II" <stpc>')

    send_command('bind !8 input /ma "Fire IV"')
    send_command('bind !9 input /ma "Blizzard IV"')
    send_command('bind !0 input /ma "Thunder IV"')
    send_command('bind @8 input /ma "Fire III"')
    send_command('bind @9 input /ma "Blizzard III"')
    send_command('bind @0 input /ma "Thunder III"')
    send_command('bind !@8 input /ma "Fire V"')
    send_command('bind !@9 input /ma "Blizzard V"')
    send_command('bind !@0 input /ma "Thunder V"')

    info.weapon_type = {['Sequence']='Sword',['SeqTern']='Sword',['SeqTernBow']='Sword',
                        ['NaegAmmu']='Sword',['NaegBow']='Sword',['NaegThib']='Sword',['NaegThiBow']='Sword',
                        ['Tauret']='Dagger',['TaurTern']='Dagger',['TaMalev']='Dagger',
                        --['trials']='trials',
                        ['MaxAmmu']='Club',['MaxThib']='Club',['MaxThiBow']='Club'}
    info.ws_binds = {
        ['Sword']={
        [1]={bind='!^1',ws='"Sanguine Blade"'},
        [2]={bind='!^2',ws='"Chant du Cygne"'},
        [3]={bind='!^3',ws='"Savage Blade"'},
        [4]={bind='!^4',ws='"Death Blossom"'},
        [5]={bind='!^5',ws='"Requiescat"'},
        [6]={bind='!^6',ws='"Circle Blade"'},
        [7]={bind='!^7',ws='"Empyreal Arrow"'},
        [8]={bind='!^d',ws='"Flat Blade"'}},
        --['trials']={
        --[1]={bind='!^1',ws='"Burning Blade"'},
        --[2]={bind='!^2',ws='"Shining Blade"'},
        --[3]={bind='!^3',ws='"Savage Blade"'},
        --[4]={bind='!^4',ws='"Circle Blade"'},
        --[5]={bind='!^d',ws='"Flat Blade"'}},
        ['Dagger']={
        [1]={bind='!^1',ws='"Engergy Drain"'},
        [2]={bind='!^2',ws='"Evisceration"'},
        [3]={bind='!^3',ws='"Wasp Sting"'},
        [4]={bind='!^4',ws='"Gust Slash"'},
        [5]={bind='!^5',ws='"Exenterator"'},
        [6]={bind='!^6',ws='"Aeolian Edge"'},
        [7]={bind='!^7',ws='"Cyclone"'},
        [8]={bind='!^d',ws='"Shadowstitch"'}},
        ['Club']={
        [1]={bind='!^1',ws='"Starlight"'},
        [2]={bind='!^2',ws='"Black Halo"'},
        [3]={bind='!^d',ws='"Brainshaker"'}}}
    set_weaponskill_keybinds()

    send_command('bind !c input /ma Bind')
    send_command('bind @c input /ma Blink <me>')
    send_command('bind @v input /ma Aquaveil <me>')
    send_command('bind @g input /ma "Phalanx II" <t>')
    send_command('bind !g input /ma "Phalanx II" <me>') -- phalanx2 lasts longer
    send_command('bind !@g input /ma Stoneskin <me>')
    send_command('bind !b input /ma "Temper II" <me>')
    send_command('bind @b input /ma "Ice Spikes" <me>')

    -- Subjob binds
    if     player.sub_job == 'WHM' then
        send_command('bind @tab input /ja "Divine Seal" <me>')
        send_command('bind !@1 input /ma "Curaga"')
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
    elseif player.sub_job == 'SCH' then
        send_command('bind @tab gs c penuparsi')
        send_command('bind @q gs c celeralac')
        send_command('bind ^@q gs c accemani')
        send_command('bind ^- input /ja "Light Arts" <me>') -- use twice for addendum
        send_command('bind ^= input /ja "Dark Arts" <me>')
        send_command('bind !- input /ma Drain')
        send_command('bind @- input /ma Drain')
        send_command('bind != input /ma Aspir')
        send_command('bind @= input /ma Aspir')
        send_command('bind !^4 input /ma Klimaform <me>')
        send_command('bind !^5 input /ma Sandstorm')
        send_command('bind !^6 input /ma Rainstorm')
        send_command('bind !^7 input /ma Windstorm')
        send_command('bind !^8 input /ma Firestorm')
        send_command('bind !^9 input /ma Hailstorm')
        send_command('bind !^0 input /ma Thunderstorm')
        send_command('bind !^- input /ma Aurorastorm')
        send_command('bind !^= input /ma Voidstorm')
        -- Status cure binds (never want to fumble these)
        send_command('bind @1 input /ma Poisona')
        send_command('bind @2 input /ma Paralyna')
        send_command('bind @3 input /ma Blindna')
        send_command('bind @4 input /ma Silena')
        send_command('bind @5 input /ma Stona')
        send_command('bind @6 input /ma Viruna')
        send_command('bind @7 input /ma Cursna')
        send_command('bind @F1 input /ma Erase')
    elseif player.sub_job == 'BLM' then
        send_command('bind !d input /ma Stun')
        send_command('bind ^@` input /ja "Elemental Seal" <me>')
        send_command('bind ^@5 input /ma Sleepga')
        send_command('bind !- input /ma Drain')
        send_command('bind @- input /ma Drain')
        send_command('bind != input /ma Aspir')
        send_command('bind @= input /ma Aspir')
        send_command('bind !n input /ma "Stonega II"')
        send_command('bind !m input /ma "Waterga II"')
    elseif player.sub_job == 'DNC' then
        send_command('bind @F1 input /ja "Healing Waltz" <stpc>')
        send_command('bind @F2 input /ja "Divine Waltz" <me>')
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
    elseif player.sub_job == 'SMN' then
        send_command('bind !v input //mewinglullaby')
        send_command('bind !b input //caitsith')
        send_command('bind !@b input //release')
        send_command('bind !n input //retreat')
    end

    select_default_macro_book()
end

-- Called when this job file is unloaded (eg: job change)
-- Unset job keybinds here.
function user_unload()
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
    send_command('unbind ^tab')
    send_command('unbind ^q')
    send_command('unbind ^`')
    send_command('unbind !`')
    send_command('unbind @`')
    send_command('unbind ^@tab')
    send_command('unbind !^`')
    send_command('unbind ^1')
    send_command('unbind ^2')
    send_command('unbind ^3')
    send_command('unbind ^4')
    send_command('unbind ^5')
    send_command('unbind ^6')
    send_command('unbind ^7')
    send_command('unbind ^backspace')
    send_command('unbind ^@1')
    send_command('unbind ^@2')
    send_command('unbind ^@3')
    send_command('unbind ^@4')
    send_command('unbind ^@5')
    send_command('unbind ^@6')
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
    send_command('unbind @8')
    send_command('unbind @9')
    send_command('unbind @0')
    send_command('unbind !@8')
    send_command('unbind !@9')
    send_command('unbind !@0')
    send_command('unbind @tab')
    send_command('unbind @1')
    send_command('unbind @2')
    send_command('unbind @3')
    send_command('unbind @4')
    send_command('unbind @5')
    send_command('unbind @6')
    send_command('unbind @7')
    send_command('unbind @F1')
    send_command('unbind @q')
    send_command('unbind ^@q')
    send_command('unbind ^-')
    send_command('unbind ^=')
    send_command('unbind !-')
    send_command('unbind @-')
    send_command('unbind !=')
    send_command('unbind @=')
    send_command('unbind !^1')
    send_command('unbind !^2')
    send_command('unbind !^3')
    send_command('unbind !^4')
    send_command('unbind !^5')
    send_command('unbind !^6')
    send_command('unbind !^7')
    send_command('unbind !^8')
    send_command('unbind !^9')
    send_command('unbind !^0')
    send_command('unbind !^-')
    send_command('unbind !^=')
    send_command('unbind ^@`')
    send_command('unbind @F2')
    send_command('unbind !c')
    send_command('unbind @c')
    send_command('unbind @v')
    send_command('unbind @g')
    send_command('unbind !g')
    send_command('unbind !@g')
    send_command('unbind !b')
    send_command('unbind @b')
    send_command('unbind !v')
    send_command('unbind !d')
    send_command('unbind !@d')
    send_command('unbind !^d')
    send_command('unbind !f')
    send_command('unbind !@f')
    send_command('unbind !e')
    send_command('unbind !@e')
    send_command('unbind !@z')
    send_command('unbind !z')
    send_command('unbind ^\\\\')
    send_command('unbind ^@\\\\')
    send_command('unbind ^@backspace')

    destroy_state_text()
end

-- Define sets and vars used by this job file.
function init_gear_sets()

    sets.weapons = {}
    sets.weapons.None = {}
    sets.weapons.Sequence   = {main="Sequence",sub="Genmei Shield"}
    sets.weapons.SeqTern    = {main="Sequence",sub="Ternion Dagger +1"}
    sets.weapons.SeqTernBow = {main="Sequence",sub="Ternion Dagger +1",range="Ullr",ammo=gear.arrow}
    sets.weapons.NaegAmmu   = {main="Naegling",sub="Ammurapi Shield"}
    sets.weapons.NaegBow    = {main="Naegling",sub="Ammurapi Shield",range="Ullr",ammo=gear.arrow}
    sets.weapons.NaegThib   = {main="Naegling",sub="Machaera +3"}
    --sets.weapons.NaegThiBow = {main="Naegling",sub="Thibron",range="Ullr",ammo=gear.arrow}
    sets.weapons.Tauret     = {main="Tauret",sub="Genmei Shield"}
    sets.weapons.TaurTern   = {main="Tauret",sub="Ternion Dagger +1"}
    sets.weapons.TaMalev    = {main="Tauret",sub="Malevolence"}
    sets.weapons.MaxAmmu    = {main="Maxentius",sub="Ammurapi Shield"}
    sets.weapons.MaxThib    = {main="Maxentius",sub="Machaera +3"}
    --sets.weapons.MaxThiBow  = {main="Maxentius",sub="Thibron",range="Ullr",ammo=gear.arrow}
    --sets.weapons.trials     = {main="Machaera +3",sub="Joyeuse"}
    sets.TreasureHunter = {head="Volte Cap",waist="Chaac Belt",feet=gear.chir_feet_th}

    -- Precast Sets

    sets.precast.JA.Chainspell = {body="Vitiation Tabard +3"}

    sets.precast.FC = {
        head="Atrophy Chapeau +3",neck="Orunmila's Torque",ear1="Loquacious Earring",ear2="Etiolation Earring",
        body="Vitiation Tabard +3",hands="Leyline Gloves",ring2="Kishar Ring",
        back=gear.EnfCape,waist="Embla Sash",legs="Psycloth Lappas",feet=gear.mer_feet_fc}
    sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {waist="Siegel Sash"})
    sets.impact = {head=empty,body="Twilight Cloak"}
    sets.precast.FC.Impact = set_combine(sets.precast.FC, sets.impact)
    sets.dispelga = {main="Daybreak",sub="Ammurapi Shield"}
    sets.precast.FC.Dispelga = set_combine(sets.precast.FC, sets.dispelga)

    sets.precast.WS = {ammo="Voluspa Tathlum",
        head="Jhakri Coronal +2",neck=gear.ElementalGorget,ear1="Moonshade Earring",ear2="Sherida Earring",
        body="Ayanmo Corazza +2",hands="Jhakri Cuffs +2",ring1="Ilabrat Ring",ring2="Rufescent Ring",
        back=gear.WSCape,waist=gear.ElementalBelt,legs="Jhakri Slops +2",feet="Jhakri Pigaches +2"}
    sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {neck="Caro Necklace",body="Jhakri Robe +2",waist="Grunfeld Rope"})
    sets.precast.WS['Chant du Cygne'] = set_combine(sets.precast.WS, {ammo="Yetshila +1",
        ring1="Ilabrat Ring",ring2="Begrudging Ring",back=gear.CDCCape,feet="Ayanmo Gambieras +2"})
    sets.precast.WS['Death Blossom'] = set_combine(sets.precast.WS, {neck="Duelist's Torque +2",ear1="Regal Earring",waist="Grunfeld Rope"})
    sets.precast.WS['Vorpal Blade'] = set_combine(sets.precast.WS['Chant du Cygne'], {ear1="Telos Earring"})
    sets.precast.WS['Circle Blade'] = set_combine(sets.precast.WS, {})
    sets.precast.WS['Evisceration'] = set_combine(sets.precast.WS['Vorpal Blade'], {})
    sets.precast.WS['Evisceration'].WSMod = set_combine(sets.precast.WS['Evisceration'], {
        head="Ayanmo Zucchetto +2",hands="Ayanmo Manopolas +2",legs="Ayanmo Cosciales +2"})
    sets.precast.WS['Aeolian Edge'] = {ammo="Pemphredo Tathlum",
        head="Jhakri Coronal +2",neck="Sanctity Necklace",ear1="Moonshade Earring",ear2="Malignance Earring",
        body=gear.mer_body_ma,hands="Chironic Gloves",ring1="Freke Ring",ring2="Sangoma Ring",
        back=gear.WSCape,waist=gear.ElementalBelt,legs="Jhakri Slops +2",feet=gear.chir_feet_ma}
    sets.precast.WS['Sanguine Blade'] = set_combine(sets.precast.WS['Aeolian Edge'], {
        head="Pixie Hairpin +1",ear2="Friomisi Earring",ring2="Archon Ring",waist="Refoccilation Stone"})
    sets.precast.WS['Energy Drain'] = set_combine(sets.precast.WS['Sanguine Blade'], {})
    sets.precast.WS['Empyreal Arrow'] = {ammo=gear.arrow,
        head="Atrophy Chapeau +3",neck="Combatant's Torque",ear1="Telos Earring",ear2="Regal Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Ilabrat Ring",ring2="Cacoethic Ring +1",
        back=gear.WSCape,waist=gear.ElementalBelt,legs="Malignance Tights",feet="Malignance Boots"}
    sets.precast.WS['Black Halo'] = set_combine(sets.precast.WS['Savage Blade'], {})

    sets.precast.Step = {ammo="Voluspa Tathlum",
        head="Ayanmo Zucchetto +2",neck="Combatant's Torque",ear1="Telos Earring",ear2="Dignitary's Earring",
        body="Malignance Tights",hands="Malignance Gloves",ring1="Ilabrat Ring",ring2="Cacoethic Ring +1",
        back=gear.TPCape,waist="Grunfeld Rope",legs="Malignance Tights",feet="Malignance Boots"}
    sets.precast.JA['Violent Flourish'] = set_combine(sets.precast.Step, {
        neck="Sanctity Necklace",ring1="Etana Ring",waist="Eschan Stone"})

    sets.precast.RA = {range="Ullr",ammo=gear.arrow}
    -- Midcast Sets
    sets.midcast.RA = {range="Ullr",ammo=gear.arrow}

    sets.midcast.FastRecast = {ammo="Staunch Tathlum +1",
        head="Nahtirah Hat",neck="Loricate Torque +1",ear1="Loquacious Earring",ear2="Malignance Earring",
        body="Vitiation Tabard +3",hands="Chironic Gloves",ring1="Vocane Ring +1",ring2="Defending Ring",
        back="Perimede Cape",waist="Goading Belt",legs="Chironic Hose",feet=gear.mer_feet_fc}

    sets.midcast.Cure = {main="Rubicundity",sub="Genmei Shield",ammo="Staunch Tathlum +1",
        head="Vanya Hood",neck="Loricate Torque +1",ear1="Genmei Earring",ear2="Novia Earring",
        body="Chironic Doublet",hands="Kaykaus Cuffs +1",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.EnfCape,waist=gear.ElementalObi,legs="Malignance Tights",feet="Lethargy Houseaux +1"}
    -- cure+50, cmp+18, enm-28, pdt-50
    sets.midcast.Curaga = set_combine(sets.midcast.Cure, {})
    --sets.midcast.Cure.Enmity = {main="Mafic Cudgel",sub="Genmei Shield",ammo="Staunch Tathlum +1",
    --    head="Halitus Helm",neck="Unmoving Collar +1",ear1="Mendicant's Earring",ear2="Trux Earring",
    --    body="Chironic Doublet",hands="Telchine Gloves",ring1="Vocane Ring +1",ring2="Defending Ring",
    --    back=gear.IdleCape,waist="Goading Belt",legs="Atrophy Tights +2",feet="Medium's Sabots"}
    ---- cure+50, cmp+8, enm+42 pdt-50
    sets.midcast.StatusRemoval = {}
    sets.midcast.Cursna = {neck="Malison Medallion",
        body="Vitiation Tabard +3",ring1="Haoma's Ring",ring2="Haoma's Ring",feet="Vanya Clogs"}
    -- healing skill 459, cursna +45 (est. 37% success)

    sets.midcast.EnhancingDuration = {main=gear.colada_enh,sub="Ammurapi Shield",ammo="Staunch Tathlum +1",
        head="Telchine Cap",neck="Duelist's Torque +2",ear1="Mendicant's Earring",ear2="Etiolation Earring",
        body="Vitiation Tabard +3",hands="Atrophy Gloves +3",ring1="Vocane Ring +1",ring2="Defending Ring",
        back="Ghostfyre Cape",waist="Embla Sash",legs="Telchine Braconi",feet="Lethargy Houseaux +1"}
    sets.midcast['Enhancing Magic'] = {main="Pukulatmuj +1",sub="Ammurapi Shield",ammo="Staunch Tathlum +1",
        head="Befouled Crown",neck="Incanter's Torque",ear1="Andoaa Earring",ear2="Mimir Earring",
        body="Vitiation Tabard +3",hands="Vitiation Gloves +3",ring1=gear.Lstikini,ring2=gear.Rstikini,
        back="Ghostfyre Cape",waist="Olympus Sash",legs="Atrophy Tights +2",feet="Lethargy Houseaux +1"}
    -- enhancing skill 630 (temper2 ta+33)
    sets.midcast['Enhancing Magic'].DW = set_combine(sets.midcast['Enhancing Magic'], {sub="Pukulatmuj"})
    sets.midcast['Phalanx II'] = {main=gear.colada_enh,sub="Ammurapi Shield",ammo="Staunch Tathlum +1",
        head="Telchine Cap",neck="Duelist's Torque +2",ear1="Genmei Earring",ear2="Etiolation Earring",
        body="Vitiation Tabard +3",hands="Vitiation Gloves +3",ring1="Vocane Ring +1",ring2="Defending Ring",
        back="Ghostfyre Cape",waist="Embla Sash",legs="Telchine Braconi",feet="Lethargy Houseaux +1"}
    sets.midcast.Phalanx = set_combine(sets.midcast['Enhancing Magic'], {main=gear.colada_enh,sub="Ammurapi Shield",
        head=gear.taeon_head_phlx,neck="Duelist's Torque +2",
        body=gear.taeon_body_phlx,hands=gear.taeon_hands_phlx,
        legs=gear.taeon_legs_phlx,feet=gear.taeon_feet_phlx})
    sets.midcast.Aquaveil = set_combine(sets.midcast.EnhancingDuration, {head="Amalric Coif +1"})
    sets.midcast.Regen = set_combine(sets.midcast.EnhancingDuration, {main="Bolelabunga",sub="Ammurapi Shield",body="Telchine Chasuble"})
    sets.midcast.Refresh = set_combine(sets.midcast.EnhancingDuration, {
        head="Amalric Coif +1",body="Atrophy Tabard +3",legs="Lethargy Fuseau +1"})
    sets.midcast.Stoneskin = set_combine(sets.midcast.EnhancingDuration, {neck="Nodens Gorget",waist="Siegel Sash"})
    sets.midcast.Blink     = set_combine(sets.midcast.EnhancingDuration, {main="Mafic Cudgel",sub="Genmei Shield",back=gear.IdleCape})
    sets.midcast.StatBoost = set_combine(sets.midcast.EnhancingDuration, {hands="Vitiation Gloves +3"})
    sets.midcast.Klimaform = set_combine(sets.midcast.EnhancingDuration, {})
    sets.midcast.FixedPotencyEnhancing = set_combine(sets.midcast.EnhancingDuration, {})
    sets.buff.ComposureOther = {head="Lethargy Chappel +1",body="Lethargy Sayon +1",legs="Lethargy Fuseau +1",feet="Lethargy Houseaux +1"}
    -- haste2: ~9:37 w/o, ~10:30 w/ composure

    sets.midcast['Enfeebling Magic'] = {main="Maxentius",sub="Ammurapi Shield",range="Ullr",ammo=empty,
        head="Atrophy Chapeau +3",neck="Duelist's Torque +2",ear1="Regal Earring",ear2="Snotra Earring",
        body="Atrophy Tabard +3",hands="Kaykaus Cuffs +1",ring1=gear.Lstikini,ring2=gear.Rstikini,
        back=gear.EnfCape,waist="Luminary Sash",legs="Chironic Hose",feet="Vitiation Boots +3"}
    -- enf.skill=558, m.acc+720 (sum:1278), mnd+297, effect+40, dur+10
    sets.midcast.Dispel = set_combine(sets.midcast['Enfeebling Magic'], {neck="Duelist's Torque +2"})
    sets.midcast.Dispelga = set_combine(sets.midcast.Dispel, sets.dispelga)
    sets.midcast.Sleep = set_combine(sets.midcast['Enfeebling Magic'], {ring2="Kishar Ring"})   -- dur+20
    sets.midcast.Break   = set_combine(sets.midcast.Sleep, {})
    sets.midcast.Bind    = set_combine(sets.midcast.Sleep, {})
    sets.midcast.Gravity = set_combine(sets.midcast.Sleep, {})
    sets.midcast.Silence = set_combine(sets.midcast.Sleep, {})
    sets.midcast.Silence.Resistant = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast.MndEnfeebles = set_combine(sets.midcast['Enfeebling Magic'], {
        main="Daybreak",sub="Ammurapi Shield",range=empty,ammo="Regal Gem",body="Lethargy Sayon +1"})
    -- enf.skill=549, m.acc+658 (sum:1207), mnd+288, effect+54, dur+10 FIXME
    sets.midcast.IntEnfeebles = set_combine(sets.midcast.MndEnfeebles, {main=gear.GrioEnf,sub="Enki Strap"})
    sets.midcast.SkillEnfeebles = set_combine(sets.midcast['Enfeebling Magic'], {
        main=gear.GrioEnf,sub="Mephitis Grip",range=empty,ammo="Regal Gem",
        head="Vitiation Chapeau +1",hands="Lethargy Gantherots +1",waist="Rumination Sash"})
    -- enf.skill=607, m.acc+577 (sum:1185), mnd+267, effect+40, dur+10 ==> -166~180 evasion
    sets.midcast.MndEnfeebles.FullPot = set_combine(sets.midcast.MndEnfeebles, {})
    sets.midcast.IntEnfeebles.FullPot = set_combine(sets.midcast.MndEnfeebles.FullPot, {})
    sets.midcast.SkillEnfeebles.FullPot = set_combine(sets.midcast.SkillEnfeebles, {body="Lethargy Sayon +1"})
    -- enf.skill=586, m.acc+534 (sum:1120), mnd+259, effect+54, dur+10 ==> -174~189 evasion
    sets.midcast.MndEnfeebles.Resistant = set_combine(sets.midcast['Enfeebling Magic'], {range=empty,ammo="Regal Gem"})
    sets.midcast.IntEnfeebles.Resistant = set_combine(sets.midcast['Enfeebling Magic'], {range=empty,ammo="Regal Gem"})
    sets.midcast.SkillEnfeebles.Resistant = set_combine(sets.midcast['Enfeebling Magic'], {range=empty,ammo="Regal Gem",
        waist="Rumination Sash"})
    -- enf.skill=565, m.acc+713 (sum:1278), mnd+291, effect+40, dur+10 ==> -149~163 evasion
    sets.buff.Saboteur = {hands="Lethargy Gantherots +1"}

    sets.midcast['Elemental Magic'] = {main="Daybreak",sub="Ammurapi Shield",range=empty,ammo="Pemphredo Tathlum",
        head="Ea Hat +1",neck="Sanctity Necklace",ear1="Regal Earring",ear2="Malignance Earring",
        body=gear.mer_body_ma,hands="Chironic Gloves",ring1=gear.ElementalRing,ring2="Freke Ring",
        back=gear.IntCape,waist=gear.ElementalObi,legs=gear.mer_legs_ma,feet=gear.chir_feet_ma}
    sets.midcast['Elemental Magic'].Resistant = {main="Daybreak",sub="Ammurapi Shield",range="Ullr",ammo=empty,
        head="Atrophy Chapeau +3",neck="Duelist's Torque +2",ear1="Regal Earring",ear2="Malignance Earring",
        body=gear.mer_body_ma,hands="Amalric Gages +1",ring1=gear.Lstikini,ring2=gear.Rstikini,
        back=gear.IntCape,waist=gear.ElementalObi,legs=gear.mer_legs_ma,feet="Vitiation Boots +3"}
    sets.midcast.Impact = set_combine(sets.midcast['Elemental Magic'].Resistant, {waist="Luminary Sash"}, sets.impact)
    sets.magicburst = {main="Daybreak",sub="Ammurapi Shield",range=empty,ammo="Pemphredo Tathlum",
        head="Ea Hat +1",neck="Mizukage-no-Kubikazari",ear1="Regal Earring",ear2="Malignance Earring",
        body="Ea Houppelande +1",hands="Amalric Gages +1",ring1="Mujin Band",ring2="Freke Ring",
        back=gear.IntCape,waist=gear.ElementalObi,legs="Ea Slops +1",feet="Jhakri Pigaches +2"}
    sets.magicburst.Resistant = set_combine(sets.magicburst, {range="Ullr",ammo=empty})
    sets.seidr   = {body="Seidr Cotehardie"}
    sets.seidrmb = {body="Seidr Cotehardie"}
    sets.submalev = {sub="Malevolence"}

    sets.midcast['Dark Magic'] = {main="Rubicundity",sub="Ammurapi Shield",range="Ullr",ammo=empty,
        head="Atrophy Chapeau +3",neck="Erra Pendant",ear1="Regal Earring",ear2="Malignance Earring",
        body="Atrophy Tabard +3",hands="Jhakri Cuffs +2",ring1=gear.Lstikini,ring2=gear.Rstikini,
        back=gear.IntCape,waist=gear.ElementalObi,legs="Chironic Hose",feet="Jhakri Pigaches +2"}
    sets.midcast.Drain = set_combine(sets.midcast['Dark Magic'], {main="Rubicundity",sub="Ammurapi Shield",
        head="Pixie Hairpin +1",ring1="Evanescence Ring",ring2="Archon Ring",waist="Fucho-no-Obi",feet=gear.mer_feet_fc})
    sets.midcast.Aspir = set_combine(sets.midcast.Drain, {})
    sets.midcast.Aspir.Resistant = set_combine(sets.midcast.Aspir, {head="Atrophy Chapeau +3",feet="Jhakri Pigaches +2"})
    sets.midcast.Stun = set_combine(sets.midcast['Dark Magic'], {waist="Goading Belt"})

    sets.midcast.Repose = set_combine(sets.midcast['Enfeebling Magic'], {hands="Jhakri Cuffs +2"})
    sets.midcast.Flash = set_combine(sets.midcast.Repose, {})
    sets.midcast.Jettatura = set_combine(sets.midcast.Flash, {})

    sets.midcast.Flash.Enmity = {main="Mafic Cudgel",sub="Evalach +1",ammo="Sapience Orb",
        head="Halitus Helm",neck="Unmoving Collar +1",ear1="Cryptic Earring",ear2="Trux Earring",
        body="Emet Harness +1",hands="Ayanmo Manopolas +2",ring1="Supershear Ring",ring2="Eihwaz Ring",
        back=gear.IdleCape,waist="Goading Belt",legs="Zoar Subligar +1",feet="Rager Ledelsens +1"}
    sets.midcast.Stun.Enmity = set_combine(sets.midcast.Flash.Enmity, {})
    sets.midcast.Jettatura.Enmity = set_combine(sets.midcast.Flash.Enmity, {})
    sets.midcast.Utsusemi = {main="Mafic Cudgel",sub="Genmei Shield",ammo="Staunch Tathlum +1",
        head="Ayanmo Zucchetto +2",neck="Loricate Torque +1",ear1="Genmei Earring",ear2="Etiolation Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.IdleCape,waist="Flume Belt +1",legs="Malignance Tights",feet="Malignance Boots"}

    -- Sets to return to when not performing an action.

    sets.idle = {main=gear.colada_rf,sub="Genmei Shield",ammo="Homiliary",
        head="Vitiation Chapeau +1",neck="Loricate Torque +1",ear1="Genmei Earring",ear2="Etiolation Earring",
        body="Jhakri Robe +2",hands="Volte Gloves",ring1=gear.Lstikini,ring2="Defending Ring",
        back=gear.IdleCape,waist="Flume Belt +1",legs="Carmine Cuisses +1",feet="Atrophy Boots +3"}
    -- refresh+11~12, pdt-42, mdt-19, meva+461
    sets.idle.PDT = set_combine(sets.idle, {main="Mafic Cudgel",sub="Genmei Shield",ammo="Staunch Tathlum +1",
        body="Atrophy Tabard +3",neck="Warder's Charm +1",ear1="Thureous Earring",
        ring1="Vocane Ring +1",waist="Slipor Sash",legs="Lengo Pants",feet="Atrophy Boots +3"})
    -- refresh+6, pdt-50, mdt-27, meva+557
    sets.idle.MEVA = set_combine(sets.idle.PDT, {
        head="Ea Hat +1",body="Malignance Tabard",legs="Malignance Tights",feet="Malignance Boots"})
    -- refresh+1, pdt-50, mdt-27, meva+657 FIXME
    sets.latent_refresh = {waist="Fucho-no-obi"}
    sets.buff.doom = {neck="Nicander's Necklace",ring1="Saida Ring",waist="Gishdubar Sash"}

    sets.defense.PDT = set_combine(sets.idle.PDT, {})
    sets.defense.MDT = set_combine(sets.idle.MEVA, {})
    sets.Kiting = {ring1="Carmine Cuisses +1"}

    sets.engaged = {ammo="Ginsen",
        head="Ayanmo Zucchetto +2",neck="Combatant's Torque",ear1="Telos Earring",ear2="Sherida Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Ilabrat Ring",ring2="Hetairoi Ring",
        back=gear.TPCape,waist="Windbuffet Belt +1",legs="Malignance Tights",feet="Malignance Boots"}
    sets.engaged.STP = set_combine(sets.engaged, {neck="Anu Torque",ear1="Dedition Earring",feet="Malignance Boots"})
    sets.engaged.Acc = set_combine(sets.engaged, {ammo="Voluspa Tathlum",ear2="Dignitary's Earring",ring2="Cacoethic Ring +1"})

    sets.engaged.PDef     = set_combine(sets.engaged,     {ring1="Vocane Ring +1",ring2="Defending Ring"})
    sets.engaged.STP.PDef = set_combine(sets.engaged.STP, {ring1="Vocane Ring +1",ring2="Defending Ring"})
    sets.engaged.Acc.PDef = set_combine(sets.engaged.Acc, {ring1="Vocane Ring +1",ring2="Defending Ring"})
    sets.dualwield = {ear1="Suppanomimi",waist="Reiki Yotai"} -- applied inside customize_melee_set

    sets.resting = set_combine(sets.idle, {main="Boonwell Staff",sub="Niobid Strap",waist="Shinjutsu-no-obi +1"})

    -- Sets that depend upon idle sets
    sets.midcast['Dia II'] = set_combine(sets.idle, sets.TreasureHunter, {ammo="Regal Gem",
        neck="Duelist's Torque +2",body="Lethargy Sayon +1",ring2="Kishar Ring",back=gear.EnfCape})
    sets.midcast['Dia III'] = set_combine(sets.midcast['Dia II'], {})
    sets.midcast['Bio II'] = set_combine(sets.midcast['Dia II'], {})
    sets.midcast['Bio III'] = set_combine(sets.midcast['Dia II'], {})
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_precast(spell, action, spellMap, eventArgs)
    if spell.english == "Composure" and buffactive.Composure then
        send_command('cancel composure')
        eventArgs.cancel = true
    elseif spell.english == "Light Arts" then
        send_command('input /ja "Addendum: White" <me>')
    elseif S{'BarElement','Protect','Shell'}:contains(spellMap)
    or S{'Poison II','Flash','Stun'}:contains(spell.english) then
        -- some spells cast too quickly for precast/midcast swaps to work reliably
        eventArgs.handled = true
    elseif spell.type == 'WeaponSkill' then
        state.aeonic_aftermath_precast = (buffactive["Aftermath: Lv.1"] or buffactive["Aftermath: Lv.2"] or buffactive["Aftermath: Lv.3"])
        if state.WeaponskillMode.value == 'NoDmg' then
            equip(sets.naked)
            eventArgs.handled = true
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

-- Run after the default midcast() is done.
-- eventArgs is the same one used in job_midcast, in case information needs to be persisted.
function job_post_midcast(spell, action, spellMap, eventArgs)
    if spell.skill == 'Enfeebling Magic' then
        if state.Buff.Saboteur and S{'MndEnfeebles','IntEnfeebles','SkillEnfeebles'}:contains(spellMap) then
            equip(sets.buff.Saboteur)
        end
    elseif spell.skill == 'Enhancing Magic' then
        if buffactive.Composure and S{'PLAYER','NPC'}:contains(spell.target.type) then
            if     spellMap == 'FixedPotencyEnhancing' then
                equip(sets.midcast.FixedPotencyEnhancing, sets.buff.ComposureOther)
            elseif spellMap == 'Regen' then
                equip(sets.midcast.Regen, sets.buff.ComposureOther, {body="Telchine Chasuble"})
            elseif spell.english == 'Phalanx II' then
                equip(sets.midcast['Phalanx II'], sets.buff.ComposureOther)
            end
        end
        if spell.english == 'Phalanx II' and spell.target.type == 'SELF' then
            equip(sets.midcast.Phalanx)
        end
        if (spell.english == 'Temper II' or spellMap == 'EnSpell') and state.CombatForm.has_value and state.CombatForm.value == 'DW' then
            equip(sets.midcast['Enhancing Magic'].DW)
        end
    elseif S{'Cure','Curaga'}:contains(spellMap) then
        if gear.ElementalObi.name == gear.default.obi_waist then
            equip({waist="Slipor Sash"})
        end
    end
    if spell.target.type == 'SELF' then
        if S{'Cure','Curaga','Refresh'}:contains(spellMap) then
            equip({waist="Gishdubar Sash"})
        elseif spell.english == 'Cursna' then
            equip(sets.buff.doom)
        end
    end
    if spell.skill == 'Elemental Magic' then
        if state.MagicBurst.value and spell.english ~= 'Impact' then
            if state.CastingMode.value == 'Resistant' then
                equip(sets.magicburst.Resistant)
            else
                equip(sets.magicburst)
            end
            if state.Seidr.value then
                equip(sets.seidrmb)
            end
        elseif state.Seidr.value then
            equip(sets.seidr)
        end
        if state.CombatForm.has_value and state.CombatForm.value == 'DW' then
            equip(sets.submalev)
        end
    elseif spell.skill == 'Enfeebling Magic' and (state.Buff.Stymie or state.Buff['Elemental Seal']) then
        if state.CastingMode.value == 'Resistant'
        and S{'Frazzle III','Distract III','Slow II','Addle II','Paralyze II'}:contains(spell.english) then
            equip(sets.midcast[spellMap].FullPot)
        end
    end
    if state.OffenseMode.value ~= 'None' then
        if     spell.skill == 'Enfeebling Magic' then
            equip({range=empty,ammo="Regal Gem"})
        elseif spell.skill == 'Elemental Magic' then
            equip({range=empty,ammo="Pemphredo Tathlum"})
        elseif spell.skill == 'Dark Magic' then
            equip({range=empty,ammo="Pemphredo Tathlum"})
        end
    end
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_aftercast(spell, action, spellMap, eventArgs)
    if spell.interrupted then
        send_command('wait 0.5;gs c update')
        if buffactive.Amnesia and S{'JobAbility','WeaponSkill'}:contains(spell.type) then
            add_to_chat(123, 'Amnesia prevents using '..spell.english)
        elseif buffactive.Silence and S{'WhiteMagic','BlackMagic','Ninjutsu'}:contains(spell.type) then
            add_to_chat(123, 'Silence prevents using '..spell.english)
        elseif has_any_buff_of(S{'Petrification','Sleep','Stun','Terror'}) then
            add_to_chat(123, 'Status prevents using '..spell.english)
        end
    elseif spell.type == 'JobAbility' then
        eventArgs.handled = true
    elseif spell.english == 'Dia III' and state.DiaMsg.value then
        if spell.target.name and spell.target.type == 'MONSTER' then
            send_command('@input /p '..spell.english..' /')
        end
    elseif spell.type == 'WeaponSkill' and state.WSMsg.value then
        ws_msg(spell)
    elseif S{'Break','Sleep','Sleep II','Sleepga'}:contains(spell.english) then
        local dur = 0
        if spell.english == 'Break' then
            dur = dur + 30
        elseif spell.english == 'Sleep' or spell.english == 'Sleepga' then
            dur = dur + 60
        elseif spell.english == 'Sleep II' then
            dur = dur + 90
        end
        if state.Buff.Saboteur then
            dur = math.floor(dur * 1.25) -- 1.25 for (bc)nms, 2.00 for normal monsters
        end
        if state.Buff.Stymie then
            dur = dur + 20
        end
        dur = dur + 20
        dur = math.floor(dur * 1.10) -- kishar ring
        send_command('@timers c "'..spell.english..' ['..spell.target.name..']" '..tostring(dur)..' down')
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
            equip(sets.idle.PDT)
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
        enable('main','sub','range','ammo')
        handle_equipping_gear(player.status)
        set_weaponskill_keybinds()
        if newValue ~= 'None' then
            equip(sets.weapons[state.CombatWeapon.value])
            if newValue:endswith('Bow') then
                disable('main','sub','range','ammo')
            else
                disable('main','sub')
            end
        end
    elseif stateField == 'Combat Weapon' then
        enable('main','sub','range','ammo')
        set_weaponskill_keybinds()
        if state.OffenseMode.value ~= 'None' then
            equip(sets.weapons[state.CombatWeapon.value])
            if state.CombatWeapon.value ~= 'None' then
                if state.CombatWeapon.value:endswith('Bow') then
                    disable('main','sub','range','ammo')
                else
                    disable('main','sub')
                end
            end
        end
    end
end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements standard library decisions.
-------------------------------------------------------------------------------------------------------------------

-- Custom spell mapping.
function job_get_spell_map(spell, default_spell_map)
    if spell.skill == 'Enfeebling Magic' then
        -- Spells with variable potencies, divided into dINT and dMND spells.
        -- These spells also benefit from RDM gear and WKR shoes.
        if S{'Slow II','Paralyze II','Addle II'}:contains(spell.english) then
            -- lower tiers are excluded, since higher tiers can overwrite them for potency
            return 'MndEnfeebles'
        elseif S{'Blind II','Gravity II'}:contains(spell.english) then
            -- blind is excluded, since the status is more important than its potency
            return 'IntEnfeebles'
        elseif S{'Poison II','Distract III','Frazzle III'}:contains(spell.english) then
            return 'SkillEnfeebles'
        end
    elseif spell.skill == 'Enhancing Magic' then
        if  not S{'Erase','Phalanx','Phalanx II','Stoneskin','Aquaveil','Temper','Temper II'}:contains(spell.english)
        and not S{'Regen','Refresh','BarElement','BarStatus','EnSpell','StatBoost','Teleport'}:contains(default_spell_map) then
            return 'FixedPotencyEnhancing'
        end
    end
end

-- Modify the default idle set after it was constructed.
function customize_idle_set(idleSet)
    if player.mpp < 51 and state.IdleMode.value ~= 'PDT' and state.DefenseMode.value == 'None' then
        idleSet = set_combine(idleSet, sets.latent_refresh)
    end
    if state.Buff.doom then
        idleSet = set_combine(idleSet, sets.buff.doom)
    end
    return idleSet
end

-- Modify the default melee set after it was constructed.
function customize_melee_set(meleeSet)
    if state.CombatWeapon.value == 'None' then
        meleeSet = sets.idle[state.IdleMode.value] or sets.idle
        if player.mpp < 51 then
            meleeSet = set_combine(meleeSet, sets.latent_refresh)
        end
    else
        meleeSet = set_combine(meleeSet, sets.weapons[state.CombatWeapon.value])
    end
    if state.CombatForm.has_value and state.CombatForm.value == 'DW' then
        meleeSet = set_combine(meleeSet, sets.dualwield)
    end
    if state.Buff.doom then
        meleeSet = set_combine(meleeSet, sets.buff.doom)
    end
    return meleeSet
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
    if state.Seidr.value then
        msg = msg .. ' Seidr'
    end
    if state.MagicBurst.value then
        msg = msg .. ' MB+'
    end
    if state.WSMsg.value then
        msg = msg .. ' WSMsg'
    end
    if state.DiaMsg.value then
        msg = msg .. ' DiaMsg'
    end

    if state.DefenseMode.value ~= 'None' then
        msg = msg .. ' Defense: ' .. state.DefenseMode.value .. ' (' .. state[state.DefenseMode.value .. 'DefenseMode'].value .. ')'
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
    if player.sub_job == 'SCH' then
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
    end
    if cmdParams[1] == 'thnuke' then
        equip(sets.TreasureHunter)
        disable('waist','feet')
    --elseif cmdParams[1] == 'trials' then
    --    send_command('bind !c gs c set CombatWeapon trials')
    --    state.CombatWeapon:set('trials')
    --    state.WeaponskillMode:set('NoDmg')
    elseif cmdParams[1] == 'ListWS' then
        add_to_chat(122, 'ListWS:')
        for _,ws in ipairs(info.ws_binds[info.weapon_type[state.CombatWeapon.value]]) do
            add_to_chat(122, "%3s : %s":format(ws.bind,ws.ws))
        end
    elseif cmdParams[1] == 'save' then
        local setname = "temp"
        if cmdParams[2] then
            setname = cmdParams[2]
        end
        add_to_chat(122,'saving current gear to sets['..setname..'].')

        for slot,item in pairs(player.equipment) do
            if item == 'empty' then
                sets[setname][slot] = empty
            else
                sets[setname][slot] = item
            end
        end
    end
end

-- Handle auto-targetting based on local setup.
function job_auto_change_target(spell, action, spellMap, eventArgs)
    if spell.target.raw == ('<stpc>') then
        if S{'SELF','PLAYER'}:contains(player.target.type)
        or 'NPC' == player.target.type and npcs.Trust:contains(player.target.name) then
            if S{'Cure','Curaga','Regen'}:contains(spellMap)
            or spell.targets.Party and spell.skill == 'Enhancing Magic' then
                -- Change some spells to use <t> instead of <stpc> when already targetting a player.
                -- <stpc> macros are convenient while engaged, but add delay in backline situations.
                change_target('<t>')
                eventArgs.handled = true
            end
        elseif 'NPC' == player.target.type and player.target.name ~= 'Luopan' then
            add_to_chat(122,'Is this a trust? ['..player.target.name..']')
        end
    elseif spell.target.raw == ('<t>') and spell.targets.Enemy then
        if not player.target.name
        or S{'SELF','PLAYER'}:contains(player.target.type)
        or 'NPC' == player.target.type and (npcs.Trust:contains(player.target.name) or player.target.name == 'Luopan') then
            if spell.skill ~= 'Healing Magic' then
                -- Change some enfeebles to fall back to <bt> when watching a player.
                change_target('<bt>')
                eventArgs.handled = true
            end
        elseif 'NPC' == player.target.type then
            add_to_chat(122,'Is this a trust? ['..player.target.name..']')
        end
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    set_macro_page(1,2)
    send_command('bind !^l input /lockstyleset 2')
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
    local mb_text_settings = {flags={draggable=false},bg={alpha=150}}
    local seidr_text_settings = {pos={y=18},flags={draggable=false},bg={alpha=150}}
    local hyb_text_settings = {pos={x=130,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local def_text_settings = {pos={x=172,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    state.mb_text = texts.new('MBurst', mb_text_settings)
    state.seidr_text = texts.new('Seidr', seidr_text_settings)
    state.hyb_text = texts.new('/${hybrid}', hyb_text_settings)
    state.def_text = texts.new('(${defense})', def_text_settings)

    state.texts_event_id = windower.register_event('prerender', function()
        state.mb_text:visible(state.MagicBurst.value)
        state.seidr_text:visible(state.Seidr.value)
        state.hyb_text:visible((state.HybridMode.value ~= 'Normal'))
        state.def_text:visible((state.DefenseMode.value ~= 'None'))

        state.hyb_text:update({['hybrid']=state.HybridMode.value})

        local defMode = '---'
        if state.DefenseMode.value ~= 'None' then
            defMode = state[state.DefenseMode.value ..'DefenseMode'].current
        end
        state.def_text:update({['defense']=defMode})
    end)
end

function destroy_state_text()
    if state.texts_event_id then
        windower.unregister_event(state.texts_event_id)
        state.mb_text:visible(false)
        state.seidr_text:visible(false)
        state.hyb_text:visible(false)
        state.def_text:visible(false)
        texts.destroy(state.mb_text)
        texts.destroy(state.seidr_text)
        texts.destroy(state.hyb_text)
        texts.destroy(state.def_text)
    end
end
