-- Modified from 'https://github.com/Kinematics/GearSwap-Jobs/blob/master/RDM.lua'

-- distract3 formula:  floor((6/21)*(enf.skill-190))+floor(dmnd/5) where dmnd/5 is between 0 and 10
-- blind2 formula: 19 < (3/8)(dINT+130.7) < 94 acc penalty
-- saboteur has reduced effect on NMs (1.37x instead of 2.12x effect)

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
end

-- Setup vars that are user-independent.  state.Buff vars initialized here will automatically be tracked.
function job_setup()
    enable('main','sub','range','ammo','head','neck','ear1','ear2','body','hands','ring1','ring2','back','waist','legs','feet')
    state.Buff.Composure = buffactive.Composure or false
    state.Buff.Saboteur  = buffactive.Saboteur or false
    state.Buff.Stymie    = buffactive.Stymie or false
    state.Buff['Elemental Seal']  = buffactive['Elemental Seal'] or false
    state.Buff['Light Arts']      = buffactive['Light Arts'] or false
    state.Buff['Addendum: White'] = buffactive['Addendum: White'] or false
    state.Buff['Dark Arts']       = buffactive['Dark Arts'] or false
    state.Buff['Addendum: Black'] = buffactive['Addendum: Black'] or false
    state.Buff.doom = buffactive.doom or false

    logout_event_id = windower.raw_register_event('logout', destroy_state_text)
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
    state.OffenseMode:options('None','Normal','Acc')                    -- Cycle with F9, set with !w, !@w
    state.HybridMode:options('Normal','PDef')                           -- Cycle with ^F9
    state.WeaponskillMode:options('Normal','NoDmg')
    state.CastingMode:options('Normal','Resistant','FullPot','Enmity')  -- Cycle with F10
    state.IdleMode:options('Normal','PDT')                              -- Cycle with F11
    state.CombatWeapon = M{['description']='Combat Weapon'}             -- Cycle with @F9
    if S{'DNC','NIN'}:contains(player.sub_job) then
        state.CombatWeapon:options('CrocTaur','CrocDay','NaegTP','NaegTern','NaegDWBow','SeqDWBow','MaxTP','TaurAE','TaurTern','1dmg')
		state.CombatForm:set('EnDW')
    else
        state.CombatWeapon:options('Crocea','CrocShield','Naegling','TPBow','SeqBow','Maxentius','Tauret')
		state.CombatForm:set('En')
    end

    state.Seidr      = M(false, 'Seidr Nukes')                          -- Toggle with !@z
    state.MagicBurst = M(false, 'Magic Burst')                          -- Toggle with !z
    state.AllyBinds  = M(false, 'Ally Cure Keybinds')                   -- Toggle with !^numpad0
    state.WSMsg      = M(false, 'WS Message')                           -- Toggle with ^\
    state.DiaMsg     = M(false, 'Dia Message')                          -- Toggle with ^@\
    state.MAccCast   = M(false, 'MAcc Next Spell')                      -- Toggle with %c
    state.THnuke     = M(false, 'TH Nukes')
    init_state_text()
    hud_update_on_state_change()

    info.magic_ws = S{'Aeolian Edge','Cyclone','Gust Slash','Energy Steal','Energy Drain',
                      'Burning Blade','Red Lotus Blade','Shining Blade','Seraph Blade','Sanguine Blade',
                      'Shining Strike','Seraph Strike','Flash Nova','Flaming Arrow'}

    -- Augmented items get variables for convenience and specificity
    gear.arrow_tp = {name="Chapuli Arrow"}
    gear.arrow_ws = {name="Beryllium Arrow"}
	gear.taeon_head_snap  = {name="Taeon Chapeau", augments={'"Snapshot"+5'}}
	gear.taeon_body_snap  = {name="Taeon Tabard", augments={'"Snapshot"+5'}}
	gear.taeon_hands_snap = {name="Taeon Gloves", augments={'"Snapshot"+5'}}
	gear.taeon_feet_snap  = {name="Taeon Boots", augments={'"Snapshot"+5'}}
    gear.taeon_head_phlx  = {name="Taeon Chapeau", augments={'Phalanx +3'}}
    gear.taeon_body_phlx  = {name="Taeon Tabard", augments={'Spell interruption rate down -10%','Phalanx +3'}}
    gear.taeon_hands_phlx = {name="Taeon Gloves", augments={'Spell interruption rate down -8%','Phalanx +3'}}
    gear.taeon_legs_phlx  = {name="Taeon Tights", augments={'Phalanx +3'}}
    gear.taeon_feet_phlx  = {name="Taeon Boots", augments={'Spell interruption rate down -9%','Phalanx +3'}}
    gear.colada_enh  = {name="Colada", augments={'Enh. Mag. eff. dur. +4','STR+7','Mag. Acc.+2','"Mag.Atk.Bns."+20','DMG:+5'}}
    --gear.colada_rf   = {name="Colada", augments={'"Refresh"+2','INT+1','Mag. Acc.+12','"Mag.Atk.Bns."+4'}}
    gear.mer_body_ma = {name="Merlinic Jubbah",
        augments={'Mag. Acc.+22 "Mag.Atk.Bns."+22','"Fast Cast"+3','MND+10','Mag. Acc.+15','"Mag.Atk.Bns."+9'}}
    gear.mer_legs_ma = {name="Merlinic Shalwar",
        augments={'Mag. Acc.+22 "Mag.Atk.Bns."+22','Damage taken-1%','MND+5','Mag. Acc.+14','"Mag.Atk.Bns."+14'}}
    gear.mer_feet_fc = {name="Merlinic Crackows", augments={'Mag. Acc.+5','"Fast Cast"+5','"Mag.Atk.Bns."+6'}}
    gear.chir_feet_ma = {name="Chironic Slippers", augments={'"Mag.Atk.Bns."+30','DEX+10','Mag. Acc.+14 "Mag.Atk.Bns."+14'}}
    gear.chir_feet_th = {name="Chironic Slippers",
        augments={'"Mag.Atk.Bns."+13','Accuracy+7','"Treasure Hunter"+1','Accuracy+19 Attack+19','Mag. Acc.+19 "Mag.Atk.Bns."+19'}}
    gear.Lstikini = {name="Stikini Ring +1", bag="wardrobe2"}
    gear.Rstikini = {name="Stikini Ring +1", bag="wardrobe3"}
    gear.IdleCape = {name="Sucellos's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','Enmity+10'}}
    gear.EnfCape  = {name="Sucellos's Cape", augments={'MND+20','Mag. Acc+20 /Mag. Dmg.+20','"Fast Cast"+10'}}
    gear.IntCape  = {name="Sucellos's Cape", augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','"Mag.Atk.Bns."+10'}}
    gear.TPCape   = {name="Sucellos's Cape", augments={'DEX+20','Accuracy+20 Attack+20','"Store TP"+10'}}
    gear.WSCape   = {name="Sucellos's Cape", augments={'STR+20','Accuracy+20 Attack+20','Weapon skill damage +10%'}}
    gear.CDCCape  = {name="Sucellos's Cape", augments={'DEX+20','Accuracy+20 Attack+20','Crit.hit rate+10'}}

    info.keybinds = make_keybind_list(job_keybinds())
    info.keybinds:bind()

    info.ws_binds = make_keybind_list(T{
        ['Sword']=L{
            'bind !^1|%1 input /ws "Sanguine Blade"',
            'bind !^2|%2 input /ws "Chant du Cygne"',
            'bind !^3|%3 input /ws "Savage Blade"',
            'bind !^4|%4 input /ws "Death Blossom"',
            'bind !^5|%5 input /ws "Requiescat"',
            'bind !^6|%6 input /ws "Circle Blade"',
            'bind !^7|%7 input /ws "Empyreal Arrow"',
            'bind !^d input /ws "Flat Blade"'},
        ['Dagger']=L{
            'bind !^1|%1 input /ws "Evisceration"',
            'bind !^2|%2 input /ws "Wasp Sting"',
            'bind !^3|%3 input /ws "Gust Slash"',
            'bind !^4|%4 input /ws "Exenterator"',
            'bind !^6|%6 input /ws "Aeolian Edge"',
            'bind !^7|%7 input /ws "Cyclone"',
            'bind !^d input /ws "Shadowstitch"'},
        ['Club']=L{
            'bind !^1|%1 input /ws "Starlight"',
            'bind !^2|%2 input /ws "Black Halo"',
            'bind !^d input /ws "Brainshaker"'}},
        {['Sequence']='Sword',['SeqTern']='Sword',['SeqBow']='Sword',['SeqDWBow']='Sword',
         ['Naegling']='Sword',['NaegTern']='Sword',['NaegTP']='Sword',['TPBow']='Sword',['NaegDWBow']='Sword',
         ['Crocea']='Sword',['CrocShield']='Sword',['CrocTaur']='Sword',['CrocDay']='Sword',['CrocTP']='Sword',
         ['Tauret']='Dagger',['TaurTern']='Dagger',['TaurAE']='Dagger',['1dmg']='Dagger',
         ['Maxentius']='Club',['MaxTP']='Club'})
    info.ws_binds:bind(state.CombatWeapon)
    send_command('bind %\\\\ gs c ListWS')

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
        'bind !numpad6 input /ma "Cure IV" <a25>'})
    send_command('bind !^numpad0 gs c toggle AllyBinds')

    info.recast_ids = L{{name="Saboteur",id=36},{name="Convert",id=49}}
    if     player.sub_job == 'WHM' then
        info.recast_ids:append({name="D.Seal",id=26})
    elseif player.sub_job == 'SCH' then
        info.recast_ids:append({name="Strats",id=231})
    elseif player.sub_job == 'BLM' then
        info.recast_ids:append({name="E.Seal",id=38})
    end

    --select_default_macro_book()
end

-- Called when this job file is unloaded (eg: job change)
function user_unload()
    info.keybinds:unbind()

    if state.AllyBinds.value then info.ally_keybinds:unbind() end
    send_command('unbind !^numpad0')

    info.ws_binds:unbind()
    send_command('unbind %\\\\')

    destroy_state_text()
end

-- Define sets and vars used by this job file.
function init_gear_sets()

    sets.weapons = {}
    sets.weapons.Crocea     = {main="Crocea Mors",sub="Ammurapi Shield"}
    sets.weapons.CrocShield = {main="Crocea Mors",sub="Sacro Bulwark"}
    sets.weapons.CrocTaur   = {main="Crocea Mors",sub="Tauret"}
    sets.weapons.CrocDay    = {main="Crocea Mors",sub="Daybreak"}
    sets.weapons.CrocTP     = {main="Crocea Mors",sub="Machaera +3"}
    sets.weapons.Sequence   = {main="Sequence",sub="Sacro Bulwark"}
    sets.weapons.SeqBow     = {main="Sequence",sub="Sacro Bulwark",range="Ullr",ammo=gear.arrow_tp}
    sets.weapons.SeqTern    = {main="Sequence",sub="Ternion Dagger +1"}
    sets.weapons.SeqDWBow   = {main="Sequence",sub="Ternion Dagger +1",range="Ullr",ammo=gear.arrow_tp}
    sets.weapons.Naegling   = {main="Naegling",sub="Ammurapi Shield"}
    sets.weapons.TPBow      = {main="Machaera +3",sub="Sacro Bulwark",range="Ullr",ammo=gear.arrow_tp}
    sets.weapons.NaegTern   = {main="Naegling",sub="Ternion Dagger +1"}
    sets.weapons.NaegDWBow  = {main="Naegling",sub="Machaera +3",range="Ullr",ammo=gear.arrow_tp}
    sets.weapons.NaegTP     = {main="Naegling",sub="Machaera +3"}
    sets.weapons.Tauret     = {main="Tauret",sub="Ammurapi Shield"}
    sets.weapons.TaurTern   = {main="Tauret",sub="Ternion Dagger +1"}
    sets.weapons.TaurAE     = {main="Tauret",sub="Malevolence"}
    sets.weapons.Maxentius  = {main="Maxentius",sub="Ammurapi Shield"}
    sets.weapons.MaxTP      = {main="Maxentius",sub="Machaera +3"}
    sets.weapons['1dmg']    = {main="Aern Dagger",sub="Esikuva",range="Ullr"}
    sets.enf_ammo       = {range=empty,ammo="Regal Gem"}
    sets.nuke_ammo      = {range=empty,ammo="Pemphredo Tathlum"}
    sets.TreasureHunter = {range=empty,ammo="Perfect Lucky Egg",head="Volte Cap",waist="Chaac Belt",feet=gear.chir_feet_th}

    -- Precast Sets

    sets.precast.JA.Chainspell = {body="Vitiation Tabard +3"}

    sets.precast.FC = {
        head="Atrophy Chapeau +3",neck="Orunmila's Torque",ear1="Loquacious Earring",ear2="Etiolation Earring",
        body="Vitiation Tabard +3",hands="Leyline Gloves",ring2="Kishar Ring",
        back=gear.EnfCape,waist="Embla Sash",legs="Psycloth Lappas",feet=gear.mer_feet_fc}
    sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {waist="Siegel Sash"})
    sets.impact = {head=empty,body="Twilight Cloak"}
    sets.precast.FC.Impact = set_combine(sets.precast.FC, {main="Crocea Mors",sub="Sacro Bulwark"}, sets.impact)
    sets.dispelga = {main="Daybreak",sub="Ammurapi Shield"}
    sets.precast.FC.Dispelga = set_combine(sets.precast.FC, sets.dispelga)

    sets.precast.WS = {ammo="Oshasha's Treatise",
        head="Nyame Helm",neck="Fotia Gorget",ear1="Moonshade Earring",ear2="Sherida Earring",
        body="Nyame Mail",hands="Nyame Gauntlets",ring1="Ilabrat Ring",ring2="Ephramad's Ring",
        back=gear.WSCape,waist="Fotia Belt",legs="Nyame Flanchard",feet="Nyame Sollerets"}
    sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {
        neck="Duelist's Torque +2",ring1="Epaminondas's Ring",waist="Sailfi Belt +1"})
    sets.precast.WS['Chant du Cygne'] = set_combine(sets.precast.WS, {ammo="Yetshila +1",
        ring1="Begrudging Ring",back=gear.CDCCape,feet="Ayanmo Gambieras +2"})
    sets.precast.WS['Death Blossom'] = set_combine(sets.precast.WS['Savage Blade'], {ear1="Regal Earring"})
    sets.precast.WS['Vorpal Blade'] = set_combine(sets.precast.WS['Chant du Cygne'], {ear1="Telos Earring"})
    sets.precast.WS['Circle Blade'] = set_combine(sets.precast.WS, {})
    sets.precast.WS['Evisceration'] = set_combine(sets.precast.WS['Vorpal Blade'], {})
    sets.precast.WS['Aeolian Edge'] = {
        head="Nyame Helm",neck="Sanctity Necklace",ear1="Moonshade Earring",ear2="Malignance Earring",
        body="Nyame Mail",hands="Nyame Gauntlets",ring1="Epaminondas's Ring",ring2="Freke Ring",
        back=gear.WSCape,waist="Fotia Belt",legs="Nyame Flanchard",feet="Nyame Sollerets"}
    sets.precast.WS['Sanguine Blade'] = set_combine(sets.precast.WS['Aeolian Edge'], {
        head="Pixie Hairpin +1",ear2="Friomisi Earring",ring1="Archon Ring",waist="Sacro Cord"})
    sets.precast.WS['Energy Drain'] = set_combine(sets.precast.WS['Sanguine Blade'], {})
    sets.precast.WS['Empyreal Arrow'] = {ammo=gear.arrow_ws,
        head="Nyame Helm",neck="Fotia Gorget",ear1="Telos Earring",ear2="Moonshade Earring",
        body="Nyame Mail",hands="Nyame Gauntlets",ring1="Epaminondas's Ring",ring2="Ephramad's Ring",
        back=gear.WSCape,waist="Fotia Belt",legs="Nyame Flanchard",feet="Nyame Sollerets"}
    sets.precast.WS['Flaming Arrow'] = set_combine(sets.precast.WS['Empyreal Arrow'], {ring2="Freke Ring"})
    sets.precast.WS['Black Halo'] = set_combine(sets.precast.WS['Savage Blade'], {})

    sets.precast.Step = {ammo="Amar Cluster",
        head="Malignance Chapeau",neck="Combatant's Torque",ear1="Telos Earring",ear2="Crepuscular Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Ilabrat Ring",ring2="Ephramad's Ring",
        back=gear.TPCape,waist="Grunfeld Rope",legs="Malignance Tights",feet="Malignance Boots"}
    sets.precast.JA['Violent Flourish'] = set_combine(sets.precast.Step, {
        neck="Sanctity Necklace",ring1="Etana Ring",waist="Eschan Stone"})

    sets.precast.RA = {range="Ullr",ammo=gear.arrow_tp,
        head=gear.taeon_head_snap,body=gear.taeon_body_snap,hands="Carmine Finger Gauntlets +1",
        feet=gear.taeon_feet_snap}
    -- Midcast Sets
    sets.midcast.RA = {range="Ullr",ammo=gear.arrow_tp,
        head="Malignance Chapeau",neck="Combatant's Torque",ear1="Telos Earring",ear2="Crepuscular Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Ilabrat Ring",ring2="Ephramad's Ring",
        back=gear.TPCape,waist="Reiki Yotai",legs="Malignance Tights",feet="Malignance Boots"}

    sets.midcast.Cure = {main="Rubicundity",sub="Sacro Bulwark",ammo="Staunch Tathlum +1",
        head="Vanya Hood",neck="Loricate Torque +1",ear1="Genmei Earring",ear2="Novia Earring",
        body="Chironic Doublet",hands="Kaykaus Cuffs +1",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.EnfCape,waist="Shinjutsu-no-Obi +1",legs="Malignance Tights",feet="Lethargy Houseaux +1"}
    -- cure+50, cmp+18, enm-28, pdt-50
    sets.midcast.Curaga = set_combine(sets.midcast.Cure, {})
    sets.midcast.Cure.Enmity = {main="Mafic Cudgel",sub="Sacro Bulwark",ammo="Staunch Tathlum +1",
        head="Halitus Helm",neck="Unmoving Collar +1",ear1="Mendicant's Earring",ear2="Trux Earring",
        body="Chironic Doublet",hands="Telchine Gloves",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.IdleCape,waist="Kasiri Belt",legs="Atrophy Tights +2",feet="Medium's Sabots"}
    -- cure+50, cmp+8, enm+42 pdt-50
    sets.midcast.StatusRemoval = {}
    sets.midcast.Cursna = {neck="Debilis Medallion",
        body="Vitiation Tabard +3",ring1="Haoma's Ring",ring2="Haoma's Ring",feet="Vanya Clogs"}
    sets.cmp_belt  = {waist="Shinjutsu-no-Obi +1"}
    sets.gishdubar = {waist="Gishdubar Sash"}

    sets.midcast.EnhancingDuration = {main=gear.colada_enh,sub="Ammurapi Shield",ammo="Staunch Tathlum +1",
        head="Telchine Cap",neck="Duelist's Torque +2",ear1="Mendicant's Earring",ear2="Lethargy Earring",
        body="Vitiation Tabard +3",hands="Atrophy Gloves +3",ring1="Vocane Ring +1",ring2="Defending Ring",
        back="Ghostfyre Cape",waist="Embla Sash",legs="Telchine Braconi",feet="Lethargy Houseaux +1"}
    sets.midcast['Enhancing Magic'] = {main="Pukulatmuj +1",sub="Forfend +1",ammo="Staunch Tathlum +1",
        head="Befouled Crown",neck="Incanter's Torque",ear1="Mimir Earring",ear2="Andoaa Earring",
        body="Vitiation Tabard +3",hands="Vitiation Gloves +3",ring1=gear.Lstikini,ring2=gear.Rstikini,
        back="Ghostfyre Cape",waist="Olympus Sash",legs="Atrophy Tights +2",feet="Lethargy Houseaux +1"}
    -- enhancing skill 640+ML (temper2 ta+34)
    sets.midcast['Phalanx II'] = {main=gear.colada_enh,sub="Ammurapi Shield",ammo="Staunch Tathlum +1",
        head="Telchine Cap",neck="Duelist's Torque +2",ear1="Genmei Earring",ear2="Lethargy Earring",
        body="Vitiation Tabard +3",hands="Vitiation Gloves +3",ring1="Vocane Ring +1",ring2="Defending Ring",
        back="Ghostfyre Cape",waist="Embla Sash",legs="Telchine Braconi",feet="Lethargy Houseaux +1"}
    sets.midcast.BarElement = set_combine(sets.midcast['Phalanx II'], {legs="Shedir Seraweels"})
    sets.midcast.BarStatus  = set_combine(sets.midcast['Phalanx II'], {neck="Sroda Necklace"})
    sets.midcast.Phalanx    = set_combine(sets.midcast['Enhancing Magic'], {main="Sakpata's Sword",sub="Ammurapi Shield",
        head=gear.taeon_head_phlx,neck="Duelist's Torque +2",
        body=gear.taeon_body_phlx,hands=gear.taeon_hands_phlx,
        legs=gear.taeon_legs_phlx,feet=gear.taeon_feet_phlx})
    sets.midcast.Aquaveil = set_combine(sets.midcast.EnhancingDuration, {
        head="Amalric Coif +1",hands="Regal Cuffs",legs="Shedir Seraweels"})
    sets.midcast.Regen    = set_combine(sets.midcast.EnhancingDuration, {main="Bolelabunga",sub="Ammurapi Shield",body="Telchine Chasuble"})
    sets.midcast.Refresh  = set_combine(sets.midcast.EnhancingDuration, {
        head="Amalric Coif +1",body="Atrophy Tabard +3",legs="Lethargy Fuseau +1"})
    sets.midcast.Stoneskin = set_combine(sets.midcast.EnhancingDuration, {neck="Nodens Gorget",waist="Siegel Sash",legs="Shedir Seraweels"})
    sets.midcast.Blink     = set_combine(sets.midcast.EnhancingDuration, {main="Mafic Cudgel",sub="Sacro Bulwark",back=gear.IdleCape})
    sets.midcast.StatBoost = set_combine(sets.midcast.EnhancingDuration, {hands="Vitiation Gloves +3"})
    sets.midcast.Klimaform = set_combine(sets.midcast.EnhancingDuration, {})
    sets.midcast.FixedPotencyEnhancing = set_combine(sets.midcast.EnhancingDuration, {})
    sets.buff.ComposureOther = {head="Lethargy Chappel +1",body="Lethargy Sayon +1",legs="Lethargy Fuseau +1",feet="Lethargy Houseaux +1"}

    sets.midcast['Enfeebling Magic'] = {main="Crocea Mors",sub="Ammurapi Shield",range="Ullr",ammo=empty,
        head="Vitiation Chapeau +3",neck="Duelist's Torque +2",ear1="Regal Earring",ear2="Snotra Earring",
        body="Atrophy Tabard +3",hands="Kaykaus Cuffs +1",ring1="Metamorph Ring +1",ring2=gear.Rstikini,
        back=gear.EnfCape,waist="Obstinate Sash",legs="Chironic Hose",feet="Vitiation Boots +3"}
    sets.buff.Saboteur = {hands="Lethargy Gantherots +1"}
    sets.lethargy_enfeeble = {
        body="Lethargy Sayon +1",hands="Lethargy Gantherots +1",
        legs="Lethargy Fuseau +1",feet="Lethargy Houseaux +1"}
    sets.midcast.Dispel = set_combine(sets.midcast['Enfeebling Magic'], {neck="Duelist's Torque +2"})
    sets.midcast.Dispelga = set_combine(sets.midcast.Dispel, sets.dispelga)

    sets.midcast.Sleep = set_combine(sets.midcast['Enfeebling Magic'], {hands="Regal Cuffs",ring2="Kishar Ring"}) -- dur*1.25*1.40
    sets.midcast.Break   = set_combine(sets.midcast.Sleep, {})
    sets.midcast.Bind    = set_combine(sets.midcast.Sleep, {})
    sets.midcast.Gravity = set_combine(sets.midcast.Sleep, {})
    sets.midcast.Silence = set_combine(sets.midcast.Sleep, {})
    sets.midcast.Silence.Resistant = set_combine(sets.midcast['Enfeebling Magic'], {})

    sets.midcast.MndEnfeebles = set_combine(sets.midcast['Enfeebling Magic'], {
        main="Daybreak",sub="Ammurapi Shield",range=empty,ammo="Regal Gem",body="Lethargy Sayon +1"})
    sets.midcast.IntEnfeebles = set_combine(sets.midcast.MndEnfeebles, {main="Naegling",sub="Ammurapi Shield",hands="Jhakri Cuffs +2"})
    sets.midcast.MndEnfeebles.FullPot = set_combine(sets.midcast.MndEnfeebles, {})
    sets.midcast.IntEnfeebles.FullPot = set_combine(sets.midcast.IntEnfeebles, {})
    sets.midcast.MndEnfeebles.Resistant = set_combine(sets.midcast['Enfeebling Magic'], {
        main="Daybreak",sub="Ammurapi Shield",range=empty,ammo="Regal Gem"})
    sets.midcast.IntEnfeebles.Resistant = set_combine(sets.midcast['Enfeebling Magic'], {range=empty,ammo="Regal Gem"})

    sets.midcast.SkillEnfeebles = set_combine(sets.midcast['Enfeebling Magic'], {
        main="Contemplator +1",sub="Mephitis Grip",range=empty,ammo="Regal Gem",
        head="Vitiation Chapeau +3",hands="Lethargy Gantherots +1",ring1=gear.Lstikini,waist="Rumination Sash"})
    sets.midcast.SkillEnfeebles.FullPot   = set_combine(sets.midcast.SkillEnfeebles, {body="Lethargy Sayon +1"})
    sets.midcast.SkillEnfeebles.Resistant = set_combine(sets.midcast.SkillEnfeebles, {hands="Kaykaus Cuffs +1"})

    sets.midcast.Impact = {main="Maxentius",sub="Ammurapi Shield",range="Ullr",ammo=empty,
        head=empty,neck="Duelist's Torque +2",ear1="Regal Earring",ear2="Malignance Earring",
        body="Twilight Cloak",hands="Amalric Gages +1",ring1="Metamorph Ring +1",ring2=gear.Rstikini,
        back=gear.IntCape,waist="Sacro Cord",legs="Ea Slops +1",feet="Vitiation Boots +3"}
    sets.midcast.Impact.Resistant = {main="Crocea Mors",sub=empty,range="Ullr",ammo=empty,
        head=empty,neck="Duelist's Torque +2",ear1="Dignitary's Earring",ear2="Snotra Earring",
        body="Twilight Cloak",hands="Malignance Gloves",ring1=gear.Lstikini,ring2=gear.Rstikini,
        back=gear.IntCape,waist="Obstinate Sash",legs="Malignance Tights",feet="Malignance Boots"}

    sets.midcast['Elemental Magic'] = {main="Daybreak",sub="Ammurapi Shield",range=empty,ammo="Pemphredo Tathlum",
        head="Ea Hat +1",neck="Sanctity Necklace",ear1="Regal Earring",ear2="Malignance Earring",
        body=gear.mer_body_ma,hands="Chironic Gloves",ring1="Metamorph Ring +1",ring2="Freke Ring",
        back=gear.IntCape,waist="Sacro Cord",legs=gear.mer_legs_ma,feet=gear.chir_feet_ma}
    sets.midcast['Elemental Magic'].Resistant = {main="Daybreak",sub="Ammurapi Shield",range="Ullr",ammo=empty,
        head="Atrophy Chapeau +3",neck="Duelist's Torque +2",ear1="Regal Earring",ear2="Malignance Earring",
        body=gear.mer_body_ma,hands="Amalric Gages +1",ring1="Metamorph Ring +1",ring2=gear.Rstikini,
        back=gear.IntCape,waist="Sacro Cord",legs=gear.mer_legs_ma,feet="Vitiation Boots +3"}
    sets.midcast['Elemental Magic'].TH = set_combine(sets.midcast['Elemental Magic'], sets.TreasureHunter)
    sets.magicburst = {main="Daybreak",sub="Ammurapi Shield",range=empty,ammo="Pemphredo Tathlum",
        head="Ea Hat +1",neck="Mizukage-no-Kubikazari",ear1="Regal Earring",ear2="Malignance Earring",
        body="Ea Houppelande +1",hands="Amalric Gages +1",ring1="Mujin Band",ring2="Freke Ring",
        back=gear.IntCape,waist="Sacro Cord",legs="Ea Slops +1",feet="Jhakri Pigaches +2"}
    sets.magicburst.Resistant = set_combine(sets.magicburst, {range="Ullr",ammo=empty})
    sets.seidr     = {body="Seidr Cotehardie"}
    sets.seidrmb   = {body="Seidr Cotehardie"}
    sets.orpheus   = {waist="Orpheus's Sash"}
    sets.ele_obi   = {waist="Hachirin-no-Obi"}
    sets.nuke_belt = {waist="Sacro Cord"}
    sets.submalev  = {sub="Malevolence"}

    sets.midcast['Dark Magic'] = {main="Crocea Mors",sub="Ammurapi Shield",range="Ullr",ammo=empty,
        head="Atrophy Chapeau +3",neck="Erra Pendant",ear1="Regal Earring",ear2="Malignance Earring",
        body="Atrophy Tabard +3",hands="Malignance Gloves",ring1=gear.Lstikini,ring2=gear.Rstikini,
        back=gear.EnfCape,waist="Sacro Cord",legs="Malignance Tights",feet="Malignance Boots"}
    sets.midcast.Drain = set_combine(sets.midcast['Dark Magic'], {main="Rubicundity",sub="Ammurapi Shield",
        head="Pixie Hairpin +1",ring1="Evanescence Ring",ring2="Archon Ring",waist="Fucho-no-Obi",feet=gear.mer_feet_fc})
    sets.midcast.Aspir = sets.midcast.Drain
    sets.midcast.Aspir.Resistant = set_combine(sets.midcast.Aspir, {head="Atrophy Chapeau +3",feet="Malignance Boots"})
    sets.drain_belt = {waist="Fucho-no-Obi"}
    sets.midcast.Stun = set_combine(sets.midcast['Dark Magic'], {})

    sets.midcast.Repose = set_combine(sets.midcast['Enfeebling Magic'], {hands="Malignance Gloves"})
    sets.midcast.BardSong = set_combine(sets.midcast.Repose, {})
    sets.midcast.Flash = set_combine(sets.midcast.Repose, {})
    sets.midcast.Jettatura = set_combine(sets.midcast.Flash, {})

    sets.midcast.Flash.Enmity = {main="Mafic Cudgel",sub="Evalach +1",ammo="Sapience Orb",
        head="Halitus Helm",neck="Unmoving Collar +1",ear1="Cryptic Earring",ear2="Trux Earring",
        body="Emet Harness +1",hands="Malignance Gloves",ring1="Supershear Ring",ring2="Eihwaz Ring",
        back=gear.IdleCape,waist="Kasiri Belt",legs="Zoar Subligar +1",feet="Rager Ledelsens +1"}
    sets.midcast.Stun.Enmity = set_combine(sets.midcast.Flash.Enmity, {})
    sets.midcast.Jettatura.Enmity = set_combine(sets.midcast.Flash.Enmity, {})
    sets.midcast.Utsusemi = {main="Crocea Mors",sub="Sacro Bulwark",ammo="Staunch Tathlum +1",
        head="Malignance Chapeau",neck="Warder's Charm +1",ear1="Genmei Earring",ear2="Etiolation Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.IdleCape,waist="Platinum Moogle Belt",legs="Malignance Tights",feet="Atrophy Boots +3"}

    -- Sets to return to when not performing an action.

    sets.idle = {main="Sakpata's Sword",sub="Sacro Bulwark",ammo="Homiliary",
        head="Vitiation Chapeau +3",neck="Sibyl Scarf",ear1="Genmei Earring",ear2="Etiolation Earring",
        body="Jhakri Robe +2",hands="Volte Gloves",ring1=gear.Lstikini,ring2="Defending Ring",
        back=gear.IdleCape,waist="Platinum Moogle Belt",legs="Carmine Cuisses +1",feet="Atrophy Boots +3"}
    -- refresh+13~14, pdt-36, dt-10, meva+481
    sets.idle.PDT = set_combine(sets.idle, {ammo="Staunch Tathlum +1",
        neck="Loricate Torque +1",body="Atrophy Tabard +3",ring1="Vocane Ring +1",legs="Malignance Tights"})
    -- refresh+8, pdt-50, dt-34, meva+598
    sets.idle.MEVA = set_combine(sets.idle.PDT, {main="Daybreak",sub="Sacro Bulwark",
        head="Ea Hat +1",body="Malignance Tabard",legs="Malignance Tights",feet="Malignance Boots"})
    -- refresh+2, pdt-50, dt-41, meva+724
    sets.latent_refresh = {waist="Fucho-no-obi"}
    sets.buff.doom = {neck="Nicander's Necklace",ring1="Eshmun's Ring",waist="Gishdubar Sash"}

    sets.defense.PDT = set_combine(sets.idle.PDT, {})
    sets.defense.MDT = set_combine(sets.idle.MEVA, {})
    sets.Kiting = {legs="Carmine Cuisses +1"}

    sets.engaged = {ammo="Coiste Bodhar",
        head="Malignance Chapeau",neck="Anu Torque",ear1="Telos Earring",ear2="Sherida Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Chirich Ring +1",ring2="Hetairoi Ring",
        back=gear.TPCape,waist="Windbuffet Belt +1",legs="Malignance Tights",feet="Malignance Boots"}
    sets.engaged.Acc = set_combine(sets.engaged, {ammo="Amar Cluster",neck="Combatant's Torque",ring2="Ephramad's Ring"})

    sets.engaged.PDef     = set_combine(sets.engaged,     {ring2="Defending Ring"})
    sets.engaged.Acc.PDef = set_combine(sets.engaged.Acc, {ring1="Vocane Ring +1"})
    sets.dualwield = {ear1="Eabani Earring",waist="Reiki Yotai"}
    sets.enspell   = {hands="Ayanmo Manopolas +2",waist="Orpheus's Sash"}
    sets.endw = set_combine(sets.dualwield, sets.enspell, {ear2="Suppanomimi"})
    sets.odin = set_combine(sets.engaged, sets.dualwield, {range="Ullr",ammo=empty,
        head="Umuthi Hat",neck="Sanctity Necklace",ear2="Suppanomimi",
        body="Ayanmo Corazza +2",hands="Ayanmo Manopolas +2",ring1=gear.Lstikini,
        back="Ghostfyre Cape",waist="Orpheus's Sash"})

    -- Sets that depend upon idle sets
    sets.midcast.FastRecast = set_combine(sets.idle.PDT, {main="Crocea Mors",sub="Sacro Bulwark"})
    sets.midcast['Dia II'] = set_combine(sets.idle, sets.TreasureHunter, {
        neck="Duelist's Torque +2",body="Lethargy Sayon +1",ring2="Kishar Ring",back=gear.EnfCape})
    sets.midcast['Dia III'] = set_combine(sets.midcast['Dia II'], {ammo="Regal Gem"})
    sets.midcast['Bio II'] = set_combine(sets.midcast['Dia II'],  {ammo="Regal Gem"})
    sets.midcast['Bio III'] = set_combine(sets.midcast['Dia II'], {ammo="Regal Gem"})
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_precast(spell, action, spellMap, eventArgs)
    if spell.english == "Composure" and buffactive.Composure then
        send_command('cancel composure')
        eventArgs.cancel = true
    elseif spell.type == 'WeaponSkill' then
        if state.WeaponskillMode.value == 'NoDmg' then
            equip(sets.naked)
            eventArgs.handled = true
        end
    end
end

-- Run after the general precast() is done.
function job_post_precast(spell, action, spellMap, eventArgs)
    if spell.type == 'WeaponSkill' then
        if info.magic_ws:contains(spell.english) then
            equip(resolve_ele_belt(spell, sets.ele_obi, sets.nuke_belt, 3))
        elseif spell.english == 'Savage Blade' and state.CombatWeapon.value:endswith('Bow') then
            equip({neck="Warder's Charm +1"})
        end
        if buffactive['elvorseal'] then
            if player.inventory["Angantyr Boots"] then equip({feet="Angantyr Boots"}) end
        end
    end
    if state.OffenseMode.value ~= 'None' and state.CombatWeapon.value:endswith('Bow') then
        if spell.type == 'WeaponSkill' then
            equip({ammo=gear.arrow_ws})
        else
            equip({ammo=gear.arrow_tp})
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
        if state.Buff.Stymie or state.Buff['Elemental Seal'] then
            if state.CastingMode.value == 'Resistant'
            and S{'Frazzle III','Distract III','Slow II','Addle II','Paralyze II'}:contains(spell.english) then
                equip(sets.midcast[spellMap].FullPot)
            elseif state.Buff.Composure
            and S{'Sleep','Sleep II','Sleepga','Break','Silence','Bind','Gravity','Gravity II'}:contains(spell.english) then
                equip(sets.lethargy_enfeeble)
            end
        elseif state.MAccCast.value then
            if sets.midcast[spell.english] and sets.midcast[spell.english].Resistant then
                equip(sets.midcast[spell.english].Resistant)
            elseif sets.midcast[spellMap] and sets.midcast[spellMap].Resistant then
                equip(sets.midcast[spellMap].Resistant)
            elseif sets.midcast[spell.skill] and sets.midcast[spell.skill].Resistant then
                equip(sets.midcast[spell.skill].Resistant)
            end
            state.MAccCast:reset()
            hud_update_on_state_change('MAcc Next Spell')
        end
        if state.Buff.Saboteur
        and (S{'MndEnfeebles','IntEnfeebles','SkillEnfeebles','Sleep'}:contains(spellMap) or spell.english == 'Break') then
            equip(sets.buff.Saboteur)
        end
    elseif spell.skill == 'Enhancing Magic' then
        if state.Buff.Composure and S{'PLAYER','NPC'}:contains(spell.target.type) then
            if     spellMap == 'FixedPotencyEnhancing' then
                equip(sets.midcast.FixedPotencyEnhancing, sets.buff.ComposureOther)
            elseif spellMap == 'Regen' then
                equip(sets.midcast.Regen, sets.buff.ComposureOther, {body="Telchine Chasuble"})
            elseif spell.english == 'Phalanx II' then
                equip(sets.midcast['Phalanx II'], sets.buff.ComposureOther)
            end
        elseif spell.target.type == 'SELF' then
            if spell.english == 'Phalanx II' then
                equip(sets.midcast.Phalanx)
            elseif spellMap == 'Refresh' then
                equip(sets.gishdubar)
            end
        end
    elseif spell.skill == 'Healing Magic' then
        if spell.english == 'Cursna' then
            equip(sets.buff.doom)
        elseif spell.english:startswith('Cur') then
            if spell.target.type == 'SELF' and spellMap == 'Cure' then
                equip(resolve_ele_belt(spell, sets.ele_obi, sets.gishdubar, 9))
            elseif spell.target.type == 'MONSTER' then
                equip(resolve_ele_belt(spell, sets.ele_obi, sets.nuke_belt, 3))
            else
                equip(resolve_ele_belt(spell, sets.ele_obi, sets.cmp_belt, 2))
            end
        end
    elseif spell.skill == 'Elemental Magic' and spellMap ~= 'ElementalEnfeeble' then
        if spell.english == 'Impact' then
            if state.MAccCast.value or state.CastingMode.value == 'Resistant' then
                equip(sets.midcast.Impact.Resistant)
            else
                equip(resolve_ele_belt(spell, sets.ele_obi, sets.nuke_belt, 9))
            end
        else
            if state.MagicBurst.value then
                if state.MAccCast.value or state.CastingMode.value == 'Resistant' then
                    equip(sets.magicburst.Resistant)
                else
                    equip(sets.magicburst)
                end
                if state.Seidr.value then
                    equip(sets.seidrmb)
                end
            else
                if state.MAccCast.value then
                    equip(sets.midcast['Elemental Magic'].Resistant)
                elseif state.THnuke.value then
                    equip(sets.midcast['Elemental Magic'].TH)
                end
                if state.Seidr.value then
                    equip(sets.seidr)
                end
            end
            if state.CombatForm.has_value and state.CombatForm.value:endswith('DW') then
                equip(sets.submalev)
            end
            equip(resolve_ele_belt(spell, sets.ele_obi, sets.nuke_belt, 3))
            state.MAccCast:reset()
            hud_update_on_state_change('MAcc Next Spell')
        end
    elseif S{'Drain','Aspir'}:contains(spell.english) then
        equip(resolve_ele_belt(spell, sets.ele_obi, sets.drain_belt, 5))
    end

    if state.OffenseMode.value ~= 'None' then
        -- prevent loss of tp by equipping the wrong range or ammo
        if state.CombatWeapon.value:endswith('Bow') then
            if spell.type == 'WeaponSkill' then
                equip({ammo=gear.arrow_ws})
            else
                equip({ammo=gear.arrow_tp})
            end
        else
            if     spell.skill == 'Enfeebling Magic' then equip(sets.enf_ammo)
            elseif spell.skill == 'Elemental Magic'  then equip(sets.nuke_ammo)
            elseif spell.skill == 'Dark Magic'       then equip(sets.nuke_ammo)
            end
        end
    elseif state.CombatWeapon.value == '1dmg' and state.CombatForm.value == 'odinDW' then
        if S{'Cure','FixedPotencyEnhancing'}:contains(spellMap) then
            equip(sets.weapons['1dmg']) -- reduces dropped aftercast mishaps
        end
    end
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_aftercast(spell, action, spellMap, eventArgs)
    if spell.interrupted then
        send_command('wait 0.5;gs c update')
        interrupted_message(spell)
    elseif S{'JobAbility','Scholar'}:contains(spell.type) then
        eventArgs.handled = true
    elseif spell.english == 'Dia III' and state.DiaMsg.value then
        if spell.target.name and spell.target.type == 'MONSTER' then
            send_command('input /p Dia III /')
        end
    elseif spell.type == 'WeaponSkill' and state.WSMsg.value then
        send_command('input /p '..spell.english)
    elseif S{'Break','Sleep','Sleep II','Sleepga'}:contains(spell.english) then
        local dur, empy_set

        if spell.english == 'Break' then
            dur = 30
        elseif spell.english == 'Sleep' or spell.english == 'Sleepga' then
            dur = 60
        elseif spell.english == 'Sleep II' then
            dur = 90
        end

        if state.Buff.Composure
        and (state.Buff.Stymie or state.Buff['Elemental Seal']) then
            empy_set = 0.35
        else
            empy_set = 0
        end
        if state.Buff.Saboteur then
            dur = dur * 1.375 -- 1.25 for (bc)nms, 2.00 for normal monsters, +0.125 if using empy hands
        end
        if state.Buff.Stymie then
            dur = dur + 20
        end

        dur = dur + 9 * 5   -- merit points w/ vitiation chapeaux
        dur = dur + 20      -- job points

        dur = math.floor(dur * (1 + 0.10 + 0.10)) -- kishar ring, snotra earring
        dur = math.floor(dur * (1 + 0.25))        -- duelist's torque augment
        dur = math.floor(dur * (1 + empy_set))

        send_command('timers c "%s [%s]" %d down':format(spell.english, spell.target.name, dur))
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
    if lbuff == 'doom' and not midaction() then
        handle_equipping_gear(player.status)
    end
    if gain then
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
    if stateField == 'Offense Mode' then
        enable('main','sub','range')
        if newValue ~= 'None' then
            equip(sets.weapons[state.CombatWeapon.value])
            if state.CombatWeapon.value:endswith('Bow') then
                disable('main','sub','range')
            else
                disable('main','sub')
            end
        end
    elseif stateField == 'Combat Weapon' then
        local form = ''
        if newValue:startswith('Croc') then form = 'En' end
        if player.sub_job == 'NIN' then form = form .. 'DW' end
        state.CombatForm:set(form)
        info.ws_binds:bind(state.CombatWeapon)
        if state.OffenseMode.value ~= 'None' then
            enable('main','sub','range')
            equip(sets.weapons[state.CombatWeapon.value])
            if state.CombatWeapon.value:endswith('Bow') then
                disable('main','sub','range')
            else
                disable('main','sub')
            end
        end
    elseif stateField == 'Defense Mode' then
        if newValue ~= 'None' then
            handle_equipping_gear(player.status)
        end
    elseif stateField == 'Ally Cure Keybinds' then
        if newValue then info.ally_keybinds:bind()
        else             info.ally_keybinds:unbind()
        end
    end

    if hud_update_on_state_change then
        hud_update_on_state_change(stateField)
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
            return 'MndEnfeebles'
        elseif 'Blind II' == spell.english then
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
    if buffactive['Reive Mark'] then
        if player.inventory["Arciela's Grace +1"] then idleSet = set_combine(idleSet, {neck="Arciela's Grace +1"}) end
    end
    if state.Buff.doom then
        idleSet = set_combine(idleSet, sets.buff.doom)
    end
    if state.OffenseMode.value ~= 'None' and state.CombatWeapon.value:endswith('Bow') then
        idleSet = set_combine(idleSet, {ammo=gear.arrow_tp})
    end
    return idleSet
end

-- Modify the default melee set after it was constructed.
function customize_melee_set(meleeSet)
    if state.DefenseMode.value == 'None' then
        meleeSet = set_combine(meleeSet, sets.weapons[state.CombatWeapon.value])
        if state.CombatForm.has_value then
            if     state.CombatForm.value == 'En' then
                meleeSet = set_combine(meleeSet, sets.enspell)
            elseif state.CombatForm.value == 'DW' then
                meleeSet = set_combine(meleeSet, sets.dualwield)
            elseif state.CombatForm.value == 'EnDW' then
                meleeSet = set_combine(meleeSet, sets.endw)
            elseif state.CombatForm.value == 'odinDW' then
                meleeSet = set_combine(meleeSet, sets.odin)
            end
        end
    end
    if state.Buff.doom then
        meleeSet = set_combine(meleeSet, sets.buff.doom)
    end
    if state.OffenseMode.value ~= 'None' and state.CombatWeapon.value:endswith('Bow') then
        meleeSet = set_combine(meleeSet, {ammo=gear.arrow_tp})
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

-- Function to display the current relevant user state when doing an update.
function display_current_job_state(eventArgs)
    local msg = ''

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

    if state.DefenseMode.value ~= 'None' then
        local defMode = state[state.DefenseMode.value ..'DefenseMode'].current
        msg = msg .. ' Def[' .. state.DefenseMode.value .. ':' .. defMode .. ']'
    end

    if player.sub_job == 'SCH' then
        if buffactive['Light Arts'] or buffactive['Addendum: White'] then
            msg = msg .. ' L.Arts'
        elseif buffactive['Dark Arts'] or buffactive['Addendum: Black'] then
            msg = msg .. ' D.Arts'
        else
            msg = msg .. ' *NoGrimoire*'
        end
    end
    if state.Seidr.value then
        msg = msg .. ' Seidr'
    end
    if state.MagicBurst.value then
        msg = msg .. ' MB+'
    end
    if state.MAccCast.value then
        msg = msg .. ' MAcc1'
    end
    if state.TreasureMode and state.TreasureMode.value ~= 'None' then
        msg = msg .. ' TH+3'
    end
    if state.THnuke.value then
        msg = msg .. ' THnuke'
    end
    if state.WSMsg.value then
        msg = msg .. ' WSMsg'
    end
    if state.DiaMsg.value then
        msg = msg .. ' DiaMsg'
    end
    if state.Kiting.value == true then
        msg = msg .. ' Kiting'
    end

    add_to_chat(122, msg)
    report_ja_recasts(info.recast_ids, false)
    eventArgs.handled = true
end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements self-commands.
-------------------------------------------------------------------------------------------------------------------

-- Called for custom player commands.
function job_self_command(cmdParams, eventArgs)
    eventArgs.handled = true
    if     cmdParams[1] == 'scholar' then
        handle_stratagems(cmdParams)
    elseif cmdParams[1] == 'ListWS' then
        info.ws_binds:print('ListWS:')
    elseif cmdParams[1] == 'odin' then
        state.CombatWeapon:set('1dmg')
        state.CombatForm:set('odinDW')
    elseif cmdParams[1] == 'weap' then
        weap_self_command(cmdParams, 'CombatWeapon')
    elseif cmdParams[1] == 'save' then
        save_self_command(cmdParams)
    elseif cmdParams[1] == 'rebind' then
        info.keybinds:bind()
    else
        eventArgs.handled = false
    end
end

function job_auto_change_target(spell, action, spellMap, eventArgs)
    custom_auto_change_target(spell, action, spellMap, eventArgs)
end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------

-- Select default macro book on initial load or subjob change.
--function select_default_macro_book()
--    set_macro_page(1,2)
--end

-- returns a list for use with make_keybind_list
function job_keybinds()
    local bind_command_list = L{
        'bind !^l input /lockstyleset 2',
        'bind %`|F12 gs c update user',
        'bind F9   gs c cycle OffenseMode',
        'bind @F9  gs c cycle CombatWeapon',
        'bind !F9  gs c reset OffenseMode',
        'bind F10  gs c cycle CastingMode',
        'bind !F10 gs c reset CastingMode',
        'bind F11  gs c cycle IdleMode',
        'bind !F11 gs c reset IdleMode',
        'bind @F11 gs c toggle Kiting',
        'bind !F12 gs c cycle TreasureMode',
        'bind ^space gs c cycle HybridMode',
        'bind !space gs c set DefenseMode Physical',
        'bind @space gs c set DefenseMode Magical',
        'bind !@space gs c reset DefenseMode',
        'bind !^q gs c weap Taur',
        'bind !^w gs c weap Croc',
        'bind !^e gs c weap Naeg',
        'bind !^r gs c weap Max',
        'bind !w  gs c   set OffenseMode Normal',
        'bind !c  gs c   set OffenseMode Acc',
        'bind %c  gs c toggle MAccCast',
        'bind !@w gs c reset OffenseMode',
        'bind !@z gs c toggle Seidr',
        'bind !z  gs c toggle MagicBurst',
        'bind ^\\\\  gs c toggle WSMsg',
        'bind ^@\\\\ gs c toggle DiaMsg',

        'bind ^`  input /ja Stymie <me>',
        'bind !`  input /ja Spontaneity',
        'bind @`  input /ja Saboteur <me>',
        'bind ^@tab input /ja Composure <me>',
        'bind !^` input /ja Chainspell <me>',

        'bind ^tab input /ma Dispel',
        'bind ^q   input /ma Dispelga',
        'bind ^1  input /ma "Dia III"',
        'bind ^@1 input /ma Inundation',
        'bind ~^1 input /ma "Bio III"',
        'bind ~^@1 input /ma "Poison II"',
        'bind ^2  input /ma "Slow II"',
        'bind ^@2 input /ma "Blind II"',
        'bind ~^2 input /ma Blind',
        'bind ^3  input /ma "Paralyze II"',
        'bind ~^3 input /ma Bind <stnpc>',
        'bind ^4  input /ma Addle II',
        'bind ^@4 input /ma Silence',
        'bind ~^4 input /ma "Gravity II" <stnpc>',
        'bind ^5  input /ma "Sleep II" <stnpc>',
        'bind ^@5 input /ma Sleep <stnpc>',    -- replaced by sleepga /blm
        'bind ~^5 input /ma Break <stnpc>',
        'bind ^backspace input /ma Impact',

        'bind !1  input /ma "Cure III" <stpc>',
        'bind !2  input /ma "Cure IV" <stpc>',
        'bind !3  input /ma "Distract III"',
        'bind !@3 input /ma "Distract II"',
        'bind !4  input /ma "Frazzle III"',
        'bind !@4 input /ma "Frazzle II"',
        'bind !5  input /ma "Haste II" <stpc>',
        'bind !6  input /ma "Refresh III" <stpc>',
        'bind !7  input /ma "Flurry II" <stpc>',

        'bind !8 input /ma "Fire IV"',
        'bind !9 input /ma "Blizzard IV"',
        'bind !0 input /ma "Thunder IV"',
        'bind @8 input /ma "Fire III"',
        'bind @9 input /ma "Blizzard III"',
        'bind @0 input /ma "Thunder III"',
        'bind !@8|%8 input /ma "Fire V"',
        'bind !@9|%9 input /ma "Blizzard V"',
        'bind !@0|%0 input /ma "Thunder V"',
        'bind ~!8 input /ma "Stone IV"',
        'bind ~!9 input /ma "Water IV"',
        'bind ~!0 input /ma "Aero IV"',
        'bind ~@8 input /ma "Stone III"',
        'bind ~@9 input /ma "Water III"',
        'bind ~@0 input /ma "Aero III"',
        'bind ~!@8|~%8 input /ma "Stone V"',
        'bind ~!@9|~%9 input /ma "Water V"',
        'bind ~!@0|~%0 input /ma "Aero V"',

        'bind @c  input /ma Blink <me>',
        'bind @v  input /ma Aquaveil <me>',
        'bind @g  input /ma "Phalanx II" <stpc>',
        'bind !g  input /ma "Phalanx II" <me>', -- phalanx2 lasts longer
        'bind !@g input /ma Stoneskin <me>',
        'bind !b  input /ma "Temper II" <me>',
        'bind @b  input /ma "Gain-MND" <me>',
        'bind !@b input /ma "Gain-INT" <me>',
        'bind !^b input /ma "Gain-STR" <me>'}

    if     player.sub_job == 'WHM' then
        bind_command_list:extend(L{
            'bind ^@` input /ja "Divine Seal" <me>',
            'bind !@1 input /ma "Curaga"',
            'bind !@2 input /ma "Curaga II"',
            'bind !@3 input /ma "Curaga III"',
            'bind @1  input /ma Poisona',
            'bind @2  input /ma Paralyna',
            'bind @3  input /ma Blindna',
            'bind @4  input /ma Silena',
            'bind @5  input /ma Stona',
            'bind @6  input /ma Viruna',
            'bind @7  input /ma Cursna',
            'bind @F1 input /ma Erase',
            'bind !d  input /ma Flash'})
    elseif player.sub_job == 'SCH' then
        bind_command_list:extend(L{
            'bind @tab gs c scholar cost',
            'bind @q   gs c scholar speed',
            'bind ^@q  gs c scholar aoe',
            'bind @e   gs c scholar light',
            'bind !@e input /ja "Dark Arts" <me>',
            'bind @d  input /ma Aspir',
            'bind !@d input /ma Drain',
            'bind ~%4 input /ma Klimaform <me>',
            'bind ~%5 input /ma Sandstorm',
            'bind ~%6 input /ma Rainstorm',
            'bind ~%7 input /ma Windstorm',
            'bind ~%8 input /ma Firestorm',
            'bind ~%9 input /ma Hailstorm',
            'bind ~%0 input /ma Thunderstorm',
            'bind ~%- input /ma Aurorastorm',
            'bind ~%= input /ma Voidstorm',
            'bind @1  input /ma Poisona',
            'bind @2  input /ma Paralyna',
            'bind @3  input /ma Blindna',
            'bind @4  input /ma Silena',
            'bind @5  input /ma Stona',
            'bind @6  input /ma Viruna',
            'bind @7  input /ma Cursna',
            'bind @F1 input /ma Erase'})
    elseif player.sub_job == 'BLM' then
        bind_command_list:extend(L{
            'bind !d  input /ma Stun',
            'bind @e  input /ma "Stonega II"',
            'bind !e  input /ma "Waterga II"',
            'bind !@e input /ma "Aeroga II"',
            'bind ^@` input /ja "Elemental Seal" <me>',
            'bind ^@5 input /ma Sleepga',
            'bind @d  input /ma Aspir',
            'bind !@d input /ma Drain'})
    elseif player.sub_job == 'DNC' then
        bind_command_list:extend(L{
            'bind @F1 input /ja "Healing Waltz" <stpc>',
            'bind @F2 input /ja "Divine Waltz" <me>',
            'bind !v  input /ja "Spectral Jig" <me>',
            'bind !d  input /ja "Violent Flourish"',
            'bind !@d input /ja "Animated Flourish"',
            'bind !f  input /ja "Haste Samba" <me>',
            'bind !@f input /ja "Reverse Flourish" <me>',
            'bind !e  input /ja "Box Step"',
            'bind !@e input /ja Quickstep'})
    elseif player.sub_job == 'NIN' then
        bind_command_list:extend(L{
            'bind !e  input /ma "Utsusemi: Ni" <me>',
            'bind !@e input /ma "Utsusemi: Ichi" <me>'})
    elseif player.sub_job == 'SMN' then
        bind_command_list:extend(L{
            'bind !v  input //mewinglullaby',
            'bind !b  input //caitsith',
            'bind !@b input //release',
            'bind !n  input //retreat'})
    end

    return bind_command_list
end

function init_state_text()
    if hud then return end

    local mb_text_settings    = {flags={draggable=false,bold=true},bg={red=250,green=200,blue=0,alpha=150},text={stroke={width=2}}}
    local seidr_text_settings = {pos={y=18},flags={draggable=false,bold=true},bg={red=0,green=220,blue=220,alpha=150},
                                 text={stroke={width=2}}}
    local macc_text_settings  = {pos={y=36},flags={draggable=false,bold=true},bg={red=0,green=150,blue=150,alpha=150},text={stroke={width=2}}}
    local ally_text_settings  = {pos={x=-178},flags={draggable=false,right=true,bold=true},bg={alpha=200},text={font='Courier New',size=10}}
    local hyb_text_settings   = {pos={x=130,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local def_text_settings   = {pos={x=172,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local off_text_settings   = {pos={x=172,y=697},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}

    hud = {texts=T{}}
    hud.texts.mb_text    = texts.new('MBurst',         mb_text_settings)
    hud.texts.seidr_text = texts.new('Seidr',          seidr_text_settings)
    hud.texts.macc_text  = texts.new('MAcc1',          macc_text_settings)
    hud.texts.ally_text  = texts.new('AllyCure',       ally_text_settings)
    hud.texts.hyb_text   = texts.new('initializing..', hyb_text_settings)
    hud.texts.def_text   = texts.new('initializing..', def_text_settings)
    hud.texts.off_text   = texts.new('initializing..', off_text_settings)

    -- update infrequently changing text boxes in job_state_change or where they are changed
    function hud_update_on_state_change(stateField)
        if not hud then init_state_text() end

        if not stateField or stateField == 'Magic Burst' then
            hud.texts.mb_text:visible(state.MagicBurst.value)
        end

        if not stateField or stateField == 'Seidr Nukes' then
            hud.texts.seidr_text:visible(state.Seidr.value)
        end

        if not stateField or stateField == 'MAcc Next Spell' then
            hud.texts.macc_text:visible(state.MAccCast.value)
        end

        if not stateField or stateField == 'Ally Cure Keybinds' then
            hud.texts.ally_text:visible(state.AllyBinds.value)
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

        if not stateField or stateField == 'Offense Mode' or stateField == 'Combat Weapon' then
            if state.OffenseMode.value ~= 'None' then
                hud.texts.off_text:text(state.CombatWeapon.value)
                hud.texts.off_text:show()
            else hud.texts.off_text:hide() end
        end
    end
end
