-- Modified from 'https://github.com/Kinematics/GearSwap-Jobs/blob/master/BLM.lua'

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
    state.Buff['Mana Wall'] = buffactive['Mana Wall'] or false
    state.Buff['Manawell'] = buffactive['Manawell'] or false
    state.Buff['Manafont'] = buffactive['Manafont'] or false
    state.Buff['Elemental Seal'] = buffactive['Elemental Seal'] or false
    state.Buff.doom = buffactive.doom or false
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
    state.OffenseMode:options('None','Normal')                              -- Cycle with F9, locks current weapon
    state.CastingMode:options('Normal','Resistant','OA')                    -- Cycle with F10 or !c, reset with !@c
    state.IdleMode:options('Normal','PDT','MEVA','MP')                      -- Cycle with F11
    state.MagicalDefenseMode:options('MEVA')
    state.CombatWeapon = M{['description']='Combat Weapon'}
    state.CombatWeapon:options('Marin','Pole')                              -- Cycle with @F9

    state.Spaekona   = M(false, 'Spaekona Nukes')       -- Toggle with !@z
    state.AutoSpaek  = M(true,  'Spaekona Sometimes')   -- Toggle with ~!@z
    state.AutoSpaek.low_mp = 750
    state.MagicBurst = M(false, 'Magic Burst')          -- Toggle with !z
    state.ZendikIdle = M(false, 'Zendik Sphere')        -- Toggle with ^z
    state.CP         = M(false, 'CP Mode')
    init_state_text()

    -- customize_idle_set, customize_defense_set, customize_melee_set, and job_post_midcast are used
    -- to equip sets.manawall for most spells and sets.magicburst for nukes
    -- table :     idle    | midcast
    -- MB       -  idle    | midcast+MB
    -- MW       -  idle+MW | midcast+MW
    -- MW+MB    -  idle+MW | midcast+MB

    -- Augmented items get variables for convenience and specificity
    gear.MACape   = {name="Taranus's Cape", augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','"Fast Cast"+10','Phys. dmg. taken-10%'}}
    gear.NukeCape = {name="Taranus's Cape",
		augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','INT+10','"Mag.Atk.Bns."+10','Phys. dmg. taken-10%'}}
    --gear.IdleCape = 
    --gear.TPCape = 

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
    gear.tel_head_enh  = {name="Telchine Cap", augments={'Mag. Evasion+22','"Conserve MP"+5','Enh. Mag. eff. dur. +7'}}
    gear.tel_body_enh  = {name="Telchine Chas.", augments={'Mag. Evasion+19','"Conserve MP"+5','Enh. Mag. eff. dur. +7'}}
    gear.tel_hand_enh  = {name="Telchine Gloves", augments={'Mag. Evasion+19','"Fast Cast"+5','Enh. Mag. eff. dur. +9'}}
    gear.tel_legs_enh  = {name="Telchine Braconi", augments={'Mag. Evasion+19','"Conserve MP"+3','Enh. Mag. eff. dur. +9'}}
    gear.tel_feet_enh  = {name="Telchine Pigaches", augments={'Mag. Evasion+17','"Conserve MP"+5','Enh. Mag. eff. dur. +7'}}

    send_command('bind %`|F12 gs c update user')
    send_command('bind F9   gs c cycle OffenseMode')
    send_command('bind !F9  gs c reset OffenseMode')
    send_command('bind @F9  gs c cycle CombatWeapon')
    send_command('bind !@F9 gs c cycleback CombatWeapon')
    send_command('bind F10  gs c cycle CastingMode')
    send_command('bind !F10 gs c reset CastingMode')
    send_command('bind F11  gs c cycle IdleMode')
    send_command('bind !F11 gs c reset IdleMode')
    send_command('bind @F11 gs c toggle Kiting')
    send_command('bind ^space gs c cycle HybridMode')
    send_command('bind !space gs c set DefenseMode Physical')
    send_command('bind @space gs c set DefenseMode Magical')
    send_command('bind !@space gs c reset DefenseMode')
    send_command('bind !w   gs c set OffenseMode Normal')
    send_command('bind !@w  gs c set OffenseMode None')
    send_command('bind ^z   gs c toggle ZendikIdle')
    send_command('bind !z   gs c toggle MagicBurst')
    send_command('bind !c   gs c cycle CastingMode')
    send_command('bind !@c  gs c reset CastingMode')
    send_command('bind !@z  gs c toggle Spaekona')
    send_command('bind ~!@z gs c toggle AutoSpaek')
    send_command('bind ^c   gs c CureCheat')

    send_command('bind ^` input /ja "Elemental Seal" <me>')
    send_command('bind !` input /ja "Enmity Douse"')
    send_command('bind !^` input /ja Manafont <me>')
    send_command('bind !@` input /ja "Subtle Sorcery" <me>')
    send_command('bind ^@` input /ja Manawell')
    send_command('bind ^@tab input /ja "Mana Wall" <me>')
    send_command('bind !@q input /ja Cascade <me>')

    send_command('bind ^1  input /ma Breakga')
    send_command('bind ~^1 input /ma Break')
    send_command('bind ^2  input /ma Sleepga')
    send_command('bind ~^2 input /ma Sleep')
    send_command('bind ^3  input /ma "Sleepga II"')
    send_command('bind ~^3 input /ma "Sleep II"')
    send_command('bind ^4  input /ma Silence')

    send_command('bind  ^backspace input /ma Comet')
    send_command('bind ~^backspace input /ma Impact')
    send_command('bind !^backspace input /ma Meteor')
    send_command('bind  !backspace input /ma Death')

    send_command('bind !1 input /ma "Cure III" <stpc>')
    send_command('bind !2 input /ma "Cure IV" <stpc>')
    send_command('bind !3 input /ma Distract')
    send_command('bind !4 input /ma Frazzle')

    send_command('bind ~^5 input /ma Rasp')     -- dex
    send_command('bind ~^6 input /ma Drown')    -- str
    send_command('bind ~^7 input /ma Choke')    -- vit
    send_command('bind ~^8 input /ma Burn')     -- int
    send_command('bind ~^9 input /ma Frost')    -- agi
    send_command('bind ~^0 input /ma Shock')    -- mnd

    send_command('bind @5 input /ma "Stone III"')
    send_command('bind @6 input /ma "Water III"')
    send_command('bind @7 input /ma "Aero III"')
    send_command('bind @8 input /ma "Fire III"')
    send_command('bind @9 input /ma "Blizzard III"')
    send_command('bind @0 input /ma "Thunder III"')

    send_command('bind ~@5 input /ma "Stone IV"')
    send_command('bind ~@6 input /ma "Water IV"')
    send_command('bind ~@7 input /ma "Aero IV"')
    send_command('bind ~@8 input /ma "Fire IV"')
    send_command('bind ~@9 input /ma "Blizzard IV"')
    send_command('bind ~@0 input /ma "Thunder IV"')

    send_command('bind !5 input /ma "Stone V"')
    send_command('bind !6 input /ma "Water V"')
    send_command('bind !7 input /ma "Aero V"')
    send_command('bind !8 input /ma "Fire V"')
    send_command('bind !9 input /ma "Blizzard V"')
    send_command('bind !0 input /ma "Thunder V"')

    send_command('bind ~!5|%5 input /ma "Stone VI"')
    send_command('bind ~!6|%6 input /ma "Water VI"')
    send_command('bind ~!7|%7 input /ma "Aero VI"')
    send_command('bind ~!8|%8 input /ma "Fire VI"')
    send_command('bind ~!9|%9 input /ma "Blizzard VI"')
    send_command('bind ~!0|%0 input /ma "Thunder VI"')

    send_command('bind !@5 input /ma "Quake II"')
    send_command('bind !@6 input /ma "Flood II"')
    send_command('bind !@7 input /ma "Tornado II"')
    send_command('bind !@8 input /ma "Flare II"')
    send_command('bind !@9 input /ma "Freeze II"')
    send_command('bind !@0 input /ma "Burst II"')

    send_command('bind ^@5 input /ma "Stonega III"')
    send_command('bind ^@6 input /ma "Waterga III"')
    send_command('bind ^@7 input /ma "Aeroga III"')
    send_command('bind ^@8 input /ma "Firaga III"')
    send_command('bind ^@9 input /ma "Blizzaga III"')
    send_command('bind ^@0 input /ma "Thundaga III"')

    send_command('bind ^5 input /ma Stoneja')
    send_command('bind ^6 input /ma Waterja')
    send_command('bind ^7 input /ma Aeroja')
    send_command('bind ^8 input /ma Firaja')
    send_command('bind ^9 input /ma Blizzaja')
    send_command('bind ^0 input /ma Thundaja')

    send_command('bind !f  input /ma Haste     <me>')
    send_command('bind !g  input /ma Phalanx   <me>')
    send_command('bind !@g input /ma Stoneskin <me>')
    send_command('bind !b  input /ma Refresh   <me>')
    send_command('bind @c  input /ma Blink     <me>')
    send_command('bind @v  input /ma Aquaveil  <me>')

    send_command('bind ^tab input /ma Dispel')
    send_command('bind ^q input /ma Dispelga')
    send_command('bind !d input /ma Stun')

    send_command('bind @d  input /ma "Aspir II"')
    send_command('bind !@d input /ma "Aspir"')

    send_command('bind @b input /ma Stonega')

    send_command('bind !@e input /ws Myrkr')
    send_command('bind !^1 input /ws Vidohunir')
    send_command('bind !^2 input /ws "Spirit Taker"')
    send_command('bind !^3 input /ws Shattersoul')
    send_command('bind !^4 input /ws Retribution')
    send_command('bind !^5 input /ws "Shell Crusher"')
    send_command('bind !^6 input /ws Cataclysm')

    select_default_macro_book()
end

-- Called when this job file is unloaded (eg: job change)
function user_unload()
    send_command('unbind %`|F12')
    send_command('unbind F9')
    send_command('unbind !F9')
    send_command('unbind @F9')
    send_command('unbind !@F9')
    send_command('unbind F10')
    send_command('unbind !F10')
    send_command('unbind F11')
    send_command('unbind !F11')
    send_command('unbind @F11')
    send_command('unbind ^space')
    send_command('unbind !space')
    send_command('unbind @space')
    send_command('unbind !@space')

    send_command('unbind !w')
    send_command('unbind !@w')
    send_command('unbind ^z')
    send_command('unbind !z')
    send_command('unbind !c')
    send_command('unbind !@c')
    send_command('unbind !@z')
    send_command('unbind ~!@z')

    send_command('unbind ^`')
    send_command('unbind !`')
    send_command('unbind !^`')
    send_command('unbind !@`')
    send_command('unbind ^@`')
    send_command('unbind ^@tab')
    send_command('unbind !@q')

    send_command('unbind ^1')
    send_command('unbind ~^1')
    send_command('unbind ^2')
    send_command('unbind ~^2')
    send_command('unbind ^3')
    send_command('unbind ~^3')
    send_command('unbind ^4')

    send_command('unbind ^backspace')
    send_command('unbind ~^backspace')
    send_command('unbind !^backspace')
    send_command('unbind !backspace')

    send_command('unbind !1')
    send_command('unbind !2')
    send_command('unbind !3')
    send_command('unbind !4')

    send_command('unbind ~^5')
    send_command('unbind ~^6')
    send_command('unbind ~^7')
    send_command('unbind ~^8')
    send_command('unbind ~^9')
    send_command('unbind ~^0')

    send_command('unbind @5')
    send_command('unbind @6')
    send_command('unbind @7')
    send_command('unbind @8')
    send_command('unbind @9')
    send_command('unbind @0')

    send_command('unbind ~@5')
    send_command('unbind ~@6')
    send_command('unbind ~@7')
    send_command('unbind ~@8')
    send_command('unbind ~@9')
    send_command('unbind ~@0')

    send_command('unbind !5')
    send_command('unbind !6')
    send_command('unbind !7')
    send_command('unbind !8')
    send_command('unbind !9')
    send_command('unbind !0')

    send_command('unbind ~!5|%5')
    send_command('unbind ~!6|%6')
    send_command('unbind ~!7|%7')
    send_command('unbind ~!8|%8')
    send_command('unbind ~!9|%9')
    send_command('unbind ~!0|%0')

    send_command('unbind !@5')
    send_command('unbind !@6')
    send_command('unbind !@7')
    send_command('unbind !@8')
    send_command('unbind !@9')
    send_command('unbind !@0')

    send_command('unbind ^@5')
    send_command('unbind ^@6')
    send_command('unbind ^@7')
    send_command('unbind ^@8')
    send_command('unbind ^@9')
    send_command('unbind ^@0')

    send_command('unbind ^5')
    send_command('unbind ^6')
    send_command('unbind ^7')
    send_command('unbind ^8')
    send_command('unbind ^9')
    send_command('unbind ^0')

    send_command('unbind !f')
    send_command('unbind !g')
    send_command('unbind !@g')
    send_command('unbind !b')
    send_command('unbind @c')
    send_command('unbind @v')

    send_command('unbind ^tab')
    send_command('unbind ^q')
    send_command('unbind !d')

    send_command('unbind @d')
    send_command('unbind !@d')

    send_command('unbind @b')

    send_command('unbind !@e')
    send_command('unbind !^1')
    send_command('unbind !^2')
    send_command('unbind !^3')
    send_command('unbind !^4')
    send_command('unbind !^5')
    send_command('unbind !^6')

    destroy_state_text()
end

-- Define sets and vars used by this job file.
function init_gear_sets()

    sets.weapons = {}
    sets.weapons.Marin = {main="Marin Staff +1",sub="Enki Strap"}
    sets.weapons.Pole  = {main="Malignance Pole",sub="Kaja Grip"}

    sets.manawall = {back=gear.NukeCape,feet="Wicce Sabots +1"}
    sets.TreasureHunter = {head="White Rarab Cap +1",waist="Chaac Belt",legs=gear.mer_legs_th,feet=gear.mer_feet_th}

    ---- Precast Sets ----
    sets.precast.JA['Mana Wall'] = sets.manawall

    sets.precast.FC = {main="Oranyan",sub="Umbra Strap",ammo="Sapience Orb",
        head="Amalric Coif +1",neck="Voltsurge Torque",ear1="Malignance Earring",ear2="Etiolation Earring",
        body="Zendik Robe",hands=gear.tel_hand_enh,ring1="Etana Ring",ring2="Kishar Ring",
        back=gear.MACape,waist="Embla Sash",legs="Psycloth Lappas",feet=gear.mer_feet_fc}
    sets.precast.FC['Elemental Magic'] = set_combine(sets.precast.FC, {ear2="Barkarole Earring",hands="Mallquis Cuffs +2"})
    sets.precast.FC.Cure = set_combine(sets.precast.FC, {ear2="Mendicant's Earring",feet="Vanya Clogs"})
    sets.precast.FC.Curaga = sets.precast.FC.Cure
    sets.precast.FC.CureCheat = set_combine(sets.precast.FC.Cure, {main="Oranyan",sub="Enki Strap",
        body="Jhakri Robe +2",hands="Jhakri Cuffs +1",ring1="Stikini Ring +1",legs=empty})
    sets.impact = {head=empty,body="Twilight Cloak"}
    sets.precast.FC.Impact = set_combine(sets.precast.FC['Elemental Magic'], sets.impact)
    --sets.dispelga = {main="Daybreak",sub="Ammurapi Shield"}
    --sets.precast.FC.Dispelga = set_combine(sets.precast.FC, sets.dispelga)

    sets.precast.WS = {ammo="Pemphredo Tathlum",
        head="Jhakri Coronal +1",neck="Sanctity Necklace",ear1="Malignance Earring",ear2="Barkarole Earring",
        body="Jhakri Robe +2",hands="Amalric Gages +1",ring1="Metamorph Ring +1",ring2="Freke Ring",
        back=gear.NukeCape,waist="Orpheus's Sash",legs="Jhakri Slops +2",feet="Jhakri Pigaches +2"}
    sets.precast.WS.Vidohunir = set_combine(sets.precast.WS, {head="Pixie Hairpin +1"})
    sets.precast.WS.Cataclysm = sets.precast.WS.Vidohunir
    sets.precast.WS.Myrkr = {}

    ---- Midcast Sets ----
    sets.midcast.Cure = {main="Malignance Pole",sub="Kaja Grip",ammo="Pemphredo Tathlum",
        head="Vanya Hood",neck="Loricate Torque +1",ear1="Calamitous Earring",ear2="Etiolation Earring",
        body="Mallquis Saio +2",hands=gear.tel_hand_enh,ring1="Vocane Ring",ring2="Defending Ring",
        back="Solemnity Cape",waist="Austerity Belt",legs="Gyve Trousers",feet="Vanya Clogs"}
    sets.midcast.Curaga = sets.midcast.Cure
    sets.midcast.Cursna = {main="Malignance Pole",sub="Kaja Grip",ammo="Sapience Orb",
        head="Hike Khat +1",neck="Malison Medallion",ear1="Malignance Earring",ear2="Lugalbanda Earring",
        body="Zendik Robe",hands="Gazu Bracelet +1",ring1="Ephedra Ring",ring2="Menelaus's Ring",
        back=gear.MACape,waist="Embla Sash",legs="Gyve Trousers",feet="Vanya Clogs"}
    sets.midcast.CureCheat = {main="Septoptic",sub="Culminus",ammo="Pemphredo Tathlum",
        head="Vanya Hood",neck="Sanctity Necklace",ear1="Eabani Earring",ear2="Etiolation Earring",
        body="Vanya Robe",hands=gear.tel_hand_enh,ring1="Etana Ring",ring2="Meridian Ring",
        back="Tantalic Cape",waist="Gishdubar Sash",legs="Perdition Slops",feet="Vanya Clogs"}
    sets.cmp_belt  = {waist="Austerity Belt"}
    sets.gishdubar = {waist="Gishdubar Sash"}

    sets.midcast.EnhancingDuration = {main="Oranyan",sub="Kaja Grip",ammo="Pemphredo Tathlum",
        head=gear.tel_head_enh,neck="Loricate Torque +1",ear1="Calamitous Earring",ear2="Etiolation Earring",
        body=gear.tel_body_enh,hands=gear.tel_hand_enh,ring1="Vocane Ring",ring2="Defending Ring",
        back=gear.MACape,waist="Embla Sash",legs=gear.tel_legs_enh,feet=gear.tel_feet_enh}
    sets.midcast['Enhancing Magic'] = set_combine(sets.midcast.EnhancingDuration, {
        head="Befouled Crown",neck="Incanter's Torque",ear2="Mimir Earring",
        body="Manasa Chasuble",hands="Ayao's Gages",ring1="Stikini Ring +1",
        back="Fi Follet Cape",waist="Olympus Sash",legs="Shedir Seraweels",feet="Regal Pumps +1"})
    sets.midcast.Phalanx = set_combine(sets.midcast['Enhancing Magic'], {hands=gear.mer_hand_phlx})
    sets.midcast.Stoneskin = set_combine(sets.midcast.EnhancingDuration, {neck="Nodens Gorget",legs="Shedir Seraweels"})
    sets.midcast.Aquaveil  = set_combine(sets.midcast.EnhancingDuration, {main="Vadose Rod",sub="Genmei Shield",
        head="Amalric Coif +1",legs="Shedir Seraweels"})
    sets.midcast.Regen   = set_combine(sets.midcast.EnhancingDuration, {main="Bolelabunga",sub="Genmei Shield"})
    sets.midcast.Refresh = set_combine(sets.midcast.EnhancingDuration, {head="Amalric Coif +1"})
    sets.self_refresh = {back="Grapevine Cape",waist="Gishdubar Sash",feet="Inspirited Boots"}
    sets.midcast.FixedPotencyEnhancing = sets.midcast.EnhancingDuration
    sets.midcast.Klimaform = {}

    sets.occultaccumen = {ammo="Seraphic Ampulla",
        head="Mallquis Chapeau +1",ear1="Dignitary's Earring",ear2="Telos Earring",
        ring1="Pernicious Ring",ring2="Apate Ring",waist="Oneiros Rope",legs="Perdition Slops"}

    sets.midcast['Elemental Magic'] = {main="Marin Staff +1",sub="Enki Strap",ammo="Pemphredo Tathlum",
        head="Jhakri Coronal +1",neck="Sorcerer's Stole +2",ear1="Malignance Earring",ear2="Barkarole Earring",
        body="Jhakri Robe +2",hands="Amalric Gages +1",ring1="Metamorph Ring +1",ring2="Freke Ring",
        back=gear.NukeCape,waist="Refoccilation Stone",legs="Jhakri Slops +2",feet="Jhakri Pigaches +2"}
    sets.midcast['Elemental Magic'].Resistant = set_combine(sets.midcast["Elemental Magic"], {main="Marin Staff +1",sub="Kaja Grip",
        ring1="Stikini Ring +1",ring2="Metamorph Ring +1"})
    sets.midcast['Elemental Magic'].OA = set_combine(sets.midcast['Elemental Magic'], sets.occultaccumen)
    sets.midcast.Stonega = set_combine(sets.midcast['Elemental Magic'], sets.TreasureHunter)
    sets.midcast.Stone   = set_combine(sets.midcast['Elemental Magic'], sets.TreasureHunter)

    sets.darkdmg = {head="Pixie Hairpin +1"}--,ring2="Archon Ring"}
    sets.midcast.Comet = set_combine(sets.midcast['Elemental Magic'], sets.darkdmg)
    sets.midcast.Comet.Resistant = set_combine(sets.midcast['Elemental Magic'].Resistant, sets.darkdmg)
    sets.midcast.Comet.OA = set_combine(sets.midcast.Comet, sets.occultaccumen)
    sets.midcast.Impact = set_combine(sets.midcast.Comet, sets.impact)
    sets.midcast.Impact.OA = set_combine(sets.midcast.Comet.OA, sets.impact)
    sets.midcast.Death = {} -- TODO
    sets.midcast.Death.OA = set_combine(sets.midcast.Death, sets.occultaccumen)
    --sets.midcast.Death.Resistant = sets.midcast.Death -- TODO

    sets.magicburst = {main="Marin Staff +1",sub="Enki Strap",ammo="Pemphredo Tathlum",
        head="Jhakri Coronal +1",neck="Mizukage-no-Kubikazari",ear1="Malignance Earring",ear2="Static Earring",
        body="Jhakri Robe +2",hands="Amalric Gages +1",ring1="Mujin Band",ring2="Locus Ring",
        back=gear.NukeCape,waist="Refoccilation Stone",legs="Jhakri Slops +2",feet="Jhakri Pigaches +2"}
    sets.magicburst.Resistant = set_combine(sets.magicburst, {})    -- TODO

    sets.spaek     = {body="Spaekona's Coat +2"}
    sets.spaekmb   = {body="Spaekona's Coat +2",ring2="Locus Ring"}
    sets.orpheus   = {waist="Orpheus's Sash"}
    sets.ele_obi   = {waist="Hachirin-no-Obi"}
    sets.nuke_belt = {waist="Refoccilation Stone"}

    sets.midcast.Drain = {main="Maxentius",sub="Chanter's Shield",ammo="Pemphredo Tathlum",
        head="Pixie Hairpin +1",neck="Erra Pendant",ear1="Malignance Earring",ear2="Hirudinea Earring",
        body="Zendik Robe",hands="Mallquis Cuffs +2",ring1="Excelsis Ring",ring2="Evanescence Ring",
        back=gear.MACape,waist="Fucho-no-Obi",legs="Spaekona's Tonban +2",feet=gear.mer_feet_dr}
    sets.midcast.Aspir = sets.midcast.Drain
    sets.midcast.Drain.Resistant = set_combine(sets.midcast.Drain, {head="Amalric Coif +1",ring1="Stikini Ring +1"})
    sets.midcast.Aspir.Resistant = set_combine(sets.midcast.Drain.Resistant, {})
    --sets.midcast.Aspir.MP = set_combine(sets.midcast.Aspir, {ear2="Etiolation Earring"}) -- TODO
    sets.drain_belt = {waist="Fucho-no-Obi"}

    sets.midcast['Enfeebling Magic'] = {main="Maxentius",sub="Genmei Shield",ammo="Pemphredo Tathlum",
        head="Amalric Coif +1",neck="Sorcerer's Stole +2",ear1="Malignance Earring",ear2="Dignitary's Earring",
        body="Spaekona's Coat +2",hands="Mallquis Cuffs +2",ring1="Metamorph Ring +1",ring2="Stikini Ring +1",
        back=gear.MACape,waist="Acuity Belt +1",legs="Spaekona's Tonban +2",feet="Mallquis Clogs +2"}
    sets.midcast.Sleep    = set_combine(sets.midcast['Enfeebling Magic'], {ring2="Kishar Ring"})
    sets.midcast.Break    = sets.midcast.Sleep
    sets.midcast.Bind     = sets.midcast.Sleep
    sets.midcast.Gravity  = sets.midcast.Sleep
	sets.midcast.Silence  = set_combine(sets.midcast['Enfeebling Magic'], {waist="Luminary Sash"})
	sets.midcast.Slow     = set_combine(sets.midcast['Enfeebling Magic'], {waist="Luminary Sash"})
    sets.midcast.Paralyze = set_combine(sets.midcast.Slow, {})
    --sets.midcast.Dispelga = set_combine(sets.midcast['Enfeebling Magic'], sets.dispelga)
    sets.midcast.Stun = set_combine(sets.midcast['Enfeebling Magic'], {waist="Goading Belt"})
    sets.midcast.MndEnfeebles = set_combine(sets.midcast['Enfeebling Magic'], {})   -- TODO
    sets.midcast.IntEnfeebles = set_combine(sets.midcast['Enfeebling Magic'], {})   -- TODO
    sets.midcast.ElementalEnfeeble = set_combine(sets.midcast['Enfeebling Magic'], {})  -- TODO

    ---- Sets to return to when not performing an action ----
    sets.idle = {main="Malignance Pole",sub="Kaja Grip",ammo="Iron Gobbet",
        head=gear.mer_head_rf,neck="Loricate Torque +1",ear1="Eabani Earring",ear2="Lugalbanda Earring",
        body="Jhakri Robe +2",hands="Mallquis Cuffs +2",ring1="Stikini Ring +1",ring2="Defending Ring",
        back=gear.NukeCape,waist="Porous Rope",legs="Assiduity Pants +1",feet="Herald's Gaiters"}
    sets.idle.PDT = set_combine(sets.idle, {main="Malignance Pole",sub="Oneiros Grip",
        head="Hike Khat +1",body="Mallquis Saio +2",ring1="Vocane Ring",feet="Mallquis Clogs +2"})
    sets.idle.MEVA = set_combine(sets.idle.PDT, {}) -- TODO
    sets.idle.MP = set_combine(sets.idle.PDT, {})   -- TODO
    sets.latent_refresh = {waist="Fucho-no-obi"}
    sets.zendik         = {body="Zendik Robe"}
    sets.buff.doom      = {neck="Nicander's Necklace",ring1="Saida Ring",ring2="Defending Ring",waist="Gishdubar Sash"}

    -- Defense sets
    sets.defense.PDT  = sets.idle.PDT
    sets.defense.MEVA = sets.idle.MEVA
    sets.Kiting = {feet="Herald's Gaiters"}

    -- Engaged sets
    sets.engaged = {main="Malignance Pole",sub="Kaja Grip",ammo="Amar Cluster",
        head="Blistering Sallet +1",neck="Bagua Charm +2",ear1="Telos Earring",ear2="Dignitary's Earring",
        body="Jhakri Robe +2",hands="Gazu Bracelet +1",ring1="Chirich Ring +1",ring2="Pernicious Ring",
        back=gear.TPCape,waist="Goading Belt",legs="Jhakri Slops +2",feet="Jhakri Pigaches +2"}
    sets.engaged.PDef = set_combine(sets.engaged, {body="Mallquis Saio +2",ring1="Vocane Ring",ring2="Defending Ring"})

    sets.cp = {back="Mecistopins Mantle"}

    -- Sets depending upon idle sets
    sets.midcast.FastRecast = set_combine(sets.defense.PDT, {})
    sets.midcast.Dia = set_combine(sets.idle.PDT, sets.TreasureHunter)
    sets.midcast.Bio = set_combine(sets.midcast.Dia, {})
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.
function job_precast(spell, action, spellMap, eventArgs)
    if spell.english == "Light Arts" and buffactive['Light Arts'] then
        send_command('input /ja "Addendum: White" <me>')
        eventArgs.cancel = true
    elseif spell.english == "Dark Arts" and buffactive['Dark Arts'] then
        send_command('input /ja "Addendum: Black" <me>')
        eventArgs.cancel = true
    elseif classes.CustomClass == 'CureCheat' then
        if not (spell.target.type == 'SELF' and spell.english == 'Cure IV') then
            classes.CustomClass = nil
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
    if spell.skill == 'Elemental Magic' and spellMap ~= 'ElementalEnfeeble' and spell.english ~= 'Meteor' then
        if spell.english ~= 'Impact' then
            if state.MagicBurst.value then
                equip(sets.magicburst)
                if state.Spaekona.value
                or state.OffenseMode.value == 'None'
                and state.AutoSpaek.value and (player.mp - spell.mp_cost) < state.AutoSpaek.low_mp then
                    if not state.Buff['Manawell'] and not state.Buff['Manafont'] then
                        equip(sets.spaekmb)
                    end
                end
                if state.CP.value then
                    equip(sets.cp)
                end
            elseif state.Spaekona.value
            or state.AutoSpaek.value and (player.mp - spell.mp_cost) < state.AutoSpaek.low_mp then
                if not state.Buff['Manawell'] and not state.Buff['Manafont'] then
                    equip(sets.spaek)
                end
            end
        end
        equip(resolve_ele_belt(spell, sets.ele_obi, sets.nuke_belt, 3))
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
    if state.Buff['Mana Wall'] then
        equip(sets.manawall)
    end
end

function job_aftercast(spell, action, spellMap, eventArgs)
    if spell.interrupted then
        send_command('wait 0.5;gs c update')
        interrupted_message(spell)
    else
        if spell.type == 'JobAbility' then
            -- aftercast can get in the way. skip it to avoid breaking bubbles sometimes.
            eventArgs.handled = true
        elseif spell.english == 'Break' or spell.english == 'Breakga' then
            send_command('@timers c "'..spell.english..' ['..spell.target.name..']" 33 down')
        elseif spell.english == 'Sleep' or spell.english == 'Sleepga' then
            send_command('@timers c "'..spell.english..' ['..spell.target.name..']" 66 down')
        elseif spell.english == 'Sleep II' or spell.english == 'Sleepga II' then
            send_command('@timers c "'..spell.english..' ['..spell.target.name..']" 99 down')
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
    if gain then
        add_to_chat(104, 'Gained ['..buff..']')
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
        enable('main','sub')
        if newValue ~= 'None' then
            equip(sets.weapons[state.CombatWeapon.value])
            disable('main','sub')
        end
        handle_equipping_gear(player.status)
    elseif stateField == 'Combat Weapon' then
        if state.OffenseMode.value ~= 'None' then
            enable('main','sub')
            equip(sets.weapons[state.CombatWeapon.value])
            if state.CombatWeapon.value ~= 'None' then
                disable('main','sub')
            end
        end
    end
end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements standard library decisions.
-------------------------------------------------------------------------------------------------------------------

-- Custom spell mapping.
function job_get_spell_map(spell, default_spell_map)
    if spell.skill == 'Enhancing Magic' then
        if spell.english ~= 'Erase'
        and not S{'Regen','BarElement','BarStatus','EnSpell','StatBoost','Teleport'}:contains(default_spell_map) then
            return "FixedPotencyEnhancing"
        end
    end
end

-- Modify the default idle set after it was constructed.
function customize_idle_set(idleSet)
    if state.ZendikIdle.value and state.DefenseMode.value == 'None' then
        idleSet = set_combine(idleSet, sets.zendik)
    end
    if player.mpp < 51 then
        idleSet = set_combine(idleSet, sets.latent_refresh)
    end
    if has_any_buff_of(S{'petrification','sleep','stun','terror'}) then
        idleSet = set_combine((pet.isvalid and sets.defense.PDT.Pet or sets.defense.PDT), {})
        if buffactive.Sleep then send_command('cancel stoneskin') end
    end
    if buffactive['Reive Mark'] then
        idleSet = set_combine(idleSet, {neck="Arciela's Grace +1"})
    end
    if state.Buff['Mana Wall'] then
        idleSet = set_combine(idleSet, sets.manawall)
    end
    if state.CP.value then
        idleSet = set_combine(idleSet, sets.cp)
    end
    if state.Buff.doom then
        idleSet = set_combine(idleSet, sets.buff.doom)
    end
    return idleSet
end

-- Modify the default defense set after it was constructed.
function customize_defense_set(defenseSet)
    if state.Buff['Mana Wall'] then
        defenseSet = set_combine(defenseSet, sets.manawall)
    end
    if state.CP.value then
        defenseSet = set_combine(defenseSet, sets.cp)
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
        meleeSet = set_combine((pet.isvalid and sets.defense.MEVA.Pet or sets.defense.MEVA), {})
        if buffactive.Sleep then send_command('cancel stoneskin') end
    end
    if state.Buff['Mana Wall'] then
        meleeSet = set_combine(meleeSet, sets.manawall)
    end
    if state.CP.value then
        meleeSet = set_combine(meleeSet, sets.cp)
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
    if state.Spaekona.value then
        msg = msg .. ' Spaekona'
    elseif state.AutoSpaek.value then
        msg = msg .. ' AutoSpaek'
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
end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements self-commands.
-------------------------------------------------------------------------------------------------------------------

-- Called for custom player commands.
function job_self_command(cmdParams, eventArgs)
    if cmdParams[1] == 'death' then
        state.CastingMode:set('MP')
        state.IdleMode:set('MP')
        state.OffenseMode:set('Normal')
        job_state_change('Offense Mode', 'Normal', '')
    elseif cmdParams[1] == 'CureCheat' then
        classes.CustomClass = 'CureCheat'
        send_command('input /ma "Cure IV" <me>')
    elseif player.sub_job == 'SCH' then
        if cmdParams[1] == 'penuparsi' then
            if buffactive['Light Arts'] or buffactive['Addendum: White'] then
                send_command('input /ja Penury <me>')
            elseif buffactive['Dark Arts'] or buffactive['Addendum: Black'] then
                send_command('input /ja Parsimony <me>')
            end
            eventArgs.handled = true
        elseif cmdParams[1] == 'celeralac' then
            if buffactive['Light Arts'] or buffactive['Addendum: White'] then
                send_command('input /ja Celerity <me>')
            elseif buffactive['Dark Arts'] or buffactive['Addendum: Black'] then
                send_command('input /ja Alacrity <me>')
            end
            eventArgs.handled = true
        elseif cmdParams[1] == 'accemani' then
            if buffactive['Light Arts'] or buffactive['Addendum: White'] then
                send_command('input /ja Accession <me>')
            elseif buffactive['Dark Arts'] or buffactive['Addendum: Black'] then
                send_command('input /ja Manifestation <me>')
            end
            eventArgs.handled = true
        end
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
    send_command('bind !^l input /lockstyleset 3')
end

function init_state_text()
    destroy_state_text()
    local mb_text_settings = {flags={draggable=false},bg={alpha=150}}
    local spae_text_settings = {pos={y=18},flags={draggable=false},bg={alpha=150}}
    local oa_text_settings   = {pos={y=36},flags={draggable=false},bg={alpha=150}}
    local hyb_text_settings = {pos={x=130,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local def_text_settings = {pos={x=172,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    state.mb_text = texts.new('MBurst', mb_text_settings)
    state.spae_text = texts.new('Spaekona', spae_text_settings)
    state.oa_text = texts.new('OAccumen', oa_text_settings)
    state.hyb_text = texts.new('/${hybrid}', hyb_text_settings)
    state.def_text = texts.new('(${defense})', def_text_settings)

    windower.register_event('logout', destroy_state_text)
    state.texts_event_id = windower.register_event('prerender', function()
        state.mb_text:visible(state.MagicBurst.value)
        state.spae_text:visible(state.Spaekona.value)
        state.oa_text:visible((state.CastingMode.value == 'OA'))

        if state.HybridMode.value ~= 'Normal' then
            state.hyb_text:show()
            state.hyb_text:update({hybrid=state.HybridMode.value})
        else state.hyb_text:hide() end

        if state.DefenseMode.value ~= 'None' then
            state.def_text:show()
            state.def_text:update({defense=state[state.DefenseMode.value..'DefenseMode'].current})
        else state.def_text:hide() end
    end)
end

function destroy_state_text()
    if state.texts_event_id then
        windower.unregister_event(state.texts_event_id)
        for text in S{state.mb_text, state.spae_text, state.oa_text, state.hyb_text, state.def_text}:it() do
            text:hide()
            text:destroy()
        end
    end
    state.texts_event_id = nil
end
