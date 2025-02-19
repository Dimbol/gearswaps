-- Modified from 'https://github.com/Kinematics/GearSwap-Jobs/blob/master/GEO.lua'
-- TODO enmity sets, check pdt in all sets, paranoid casting sets
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
    state.Buff['Light Arts']      = buffactive['Light Arts'] or false
    state.Buff['Addendum: White'] = buffactive['Addendum: White'] or false
    state.Buff['Dark Arts']       = buffactive['Dark Arts'] or false
    state.Buff['Addendum: Black'] = buffactive['Addendum: Black'] or false
    state.Buff.doom                 = buffactive.doom or false
    state.Buff.sleep = buffactive.sleep or false

    logout_event_id = windower.raw_register_event('logout', destroy_state_text)
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
    state.OffenseMode:options('None','Normal')                          -- Cycle with F9, will swap weapon
    state.HybridMode:options('Normal','PDef')                           -- Cycle with ^F9
    state.CastingMode:options('Normal','MAcc')                          -- Cycle with F10
    state.IdleMode:options('Normal','PDT','MEVA')                       -- Cycle with F11
    state.MagicalDefenseMode:options('MEVA')
    state.CombatWeapon = M{['description']='Combat Weapon'}
    if S{'DNC','NIN'}:contains(player.sub_job) then
        state.CombatWeapon:options('IdrisDW','MaxenDW','DayDW','Staff','Dagger')
        state.CombatForm:set('DW')
    else
        state.CombatWeapon:options('Idris','Maxentius','Daybreak','Staff','Dagger')
        state.CombatForm:reset()
    end

    state.Seidr          = M(false, 'Seidr Nukes')                      -- Toggle with !@z
    state.AutoSeidr      = M(true,  'Seidr Sometimes')                  -- Toggle with ~!@z
    state.AutoSeidr.low_mp = 750
    state.MagicBurst     = M(false, 'Magic Burst')                      -- Toggle with !z
    state.SphereIdle     = M(false, 'Sphere Idle')                      -- Toggle with ^z
    state.AllyBinds      = M(false, 'Ally Cure Keybinds')               -- Toggle with !^delete
    state.CardinalMsg    = M(false, 'Cardinal Chant Message')           -- Toggle with ^\
    state.GeoHUD         = M(true,  'Geomancy HUD')                     -- Toggle with !^\

    -- timer variables set in job_aftercast
    -- 180 base, +40 JP, +20% cape, +12-21 bagua pants, +30 azimuth gaiters, +15 solstice
    info.indi_dur    = math.floor(1.20 * (180 + 40 + 21 + 30))
    info.entrust_dur = math.floor(1.20 * (180 + 40 + 21 + 30 + 15))
    geo_state_updates()
    init_state_text()
    hud_update_on_state_change()

    -- Augmented items get variables for convenience and specificity
    gear.MACape   = {name="Nantosuelta's Cape", augments={'MND+20','Mag. Acc+20 /Mag. Dmg.+20','"Fast Cast"+10','Phys. dmg. taken-10%'}}
    gear.PetCape  = {name="Nantosuelta's Cape", augments={'HP+60','Eva.+20 /Mag. Eva.+20','Pet: "Regen"+10'}}
    gear.NukeCape = {name="Nantosuelta's Cape", augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','"Mag.Atk.Bns."+10'}}
    gear.TPCape   = {name="Nantosuelta's Cape", augments={'DEX+20','Accuracy+20 Attack+20','"Dbl.Atk."+10'}}
    gear.DWCape   = {name="Nantosuelta's Cape", augments={'DEX+20','Accuracy+20 Attack+20','"Dual Wield"+10'}}
    gear.WSCape   = {name="Nantosuelta's Cape", augments={'MND+20','Accuracy+20 Attack+20','Weapon skill damage +10%'}}

    gear.mer_head_rf   = {name="Merlinic Hood", augments={'"Refresh"+2'}}
    gear.mer_head_fc   = {name="Merlinic Hood", augments={'"Fast Cast"+7'}}
    gear.mer_hand_rf   = {name="Merlinic Dastanas", augments={'"Refresh"+2'}}
    gear.mer_hand_phlx = {name="Merlinic Dastanas", augments={'Phalanx +3'}}
    gear.mer_legs_rf   = {name="Merlinic Shalwar", augments={'"Refresh"+2'}}
    gear.mer_legs_th   = {name="Merlinic Shalwar", augments={'"Treasure Hunter"+2'}}
    gear.mer_feet_rf   = {name="Merlinic Crackows", augments={'"Refresh"+2'}}
    gear.mer_feet_fc   = {name="Merlinic Crackows", augments={'"Fast Cast"+7'}}
    gear.tel_head_enh  = {name="Telchine Cap", augments={'Enh. Mag. eff. dur. +10'}}
    gear.tel_body_enh  = {name="Telchine Chas.", augments={'Enh. Mag. eff. dur. +10'}}
    gear.tel_hand_enh  = {name="Telchine Gloves", augments={'Enh. Mag. eff. dur. +10'}}
    gear.tel_legs_enh  = {name="Telchine Braconi", augments={'Enh. Mag. eff. dur. +10'}}
    gear.tel_feet_enh  = {name="Telchine Pigaches", augments={'Enh. Mag. eff. dur. +10'}}

    info.keybinds = make_keybind_list(job_keybinds())
    info.keybinds:bind()

    info.ally_keybinds = make_keybind_list(L{
        'bind %~delete   input /ma Cure <p0>',
        'bind %~end      input /ma Cure <p1>',
        'bind %~pagedown input /ma Cure <p2>',
        'bind %~insert   input /ma Cure <p3>',
        'bind %~home     input /ma Cure <p4>',
        'bind %~pageup   input /ma Cure <p5>',
        'bind ^delete    input /ma Cure <a10>',
        'bind ^end       input /ma Cure <a11>',
        'bind ^pagedown  input /ma Cure <a12>',
        'bind ^insert    input /ma Cure <a13>',
        'bind ^home      input /ma Cure <a14>',
        'bind ^pageup    input /ma Cure <a15>',
        'bind !delete    input /ma Cure <a20>',
        'bind !end       input /ma Cure <a21>',
        'bind !pagedown  input /ma Cure <a22>',
        'bind !insert    input /ma Cure <a23>',
        'bind !home      input /ma Cure <a24>',
        'bind !pageup    input /ma Cure <a25>',
        'bind %~^delete   input /ma "Cure IV" <p0>',
        'bind %~^end      input /ma "Cure IV" <p1>',
        'bind %~^pagedown input /ma "Cure IV" <p2>',
        'bind %~^insert   input /ma "Cure IV" <p3>',
        'bind %~^home     input /ma "Cure IV" <p4>',
        'bind %~^pageup   input /ma "Cure IV" <p5>',
        'bind ^@delete    input /ma "Cure IV" <a10>',
        'bind ^@end       input /ma "Cure IV" <a11>',
        'bind ^@pagedown  input /ma "Cure IV" <a12>',
        'bind ^@insert    input /ma "Cure IV" <a13>',
        'bind ^@home      input /ma "Cure IV" <a14>',
        'bind ^@pageup    input /ma "Cure IV" <a15>',
        'bind !@delete    input /ma "Cure IV" <a20>',
        'bind !@end       input /ma "Cure IV" <a21>',
        'bind !@pagedown  input /ma "Cure IV" <a22>',
        'bind !@insert    input /ma "Cure IV" <a23>',
        'bind !@home      input /ma "Cure IV" <a24>',
        'bind !@pageup    input /ma "Cure IV" <a25>'})
    send_command('bind !^delete gs c toggle AllyBinds')

    info.ws_binds = make_keybind_list(T{
        ['Club']=L{
            'bind !^1 input /ws "Exudation"',
            'bind !^2 input /ws "Flash Nova"',
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
        {['Idris']='Club',['IdrisDW']='Club',['Maxentius']='Club',['MaxenDW']='Club',['Daybreak']='Club',['DayDW']='Club',
         ['Dagger']='Dagger',['Staff']='Staff'})
    info.ws_binds:bind(state.CombatWeapon)
    send_command('bind %\\\\ gs c ListWS')

    info.bubble_binds = make_keybind_list(L{
        'bind %1|~^1   gs c lastgeo',
        'bind %2|~^2   input /ma Geo-Frailty',
        'bind %3|~^3   gs c lastindi',
        'bind %4|~^4   input /ma Geo-Wilt',
        'bind %5|~^5   input /ma Geo-Malaise',
        'bind %6|~^6   input /ma Geo-Fade',
        'bind %7|~^7   input /ma Geo-Vex',
        'bind %~2|~!^2 input /ma Indi-Fury <stpc>',
        'bind %~4|~!^4 input /ma Indi-Wilt <stpc>',
        'bind %~5|~!^5 input /ma Indi-Haste <stpc>',
        'bind %~6|~!^6 input /ma Indi-Malaise <stpc>',
        'bind %~7|~!^7 input /ma Indi-Attunement <stpc>',
        'bind @backspace gs c ListBubs'})
    info.bubble_binds:bind()

    info.recast_ids = L{{name="Entrust",id=93},{name="BoG",id=247},{name="EA",id=244},{name="Demat",id=248},
                        {name="Life Cycle",id=246},{name="Radial Arcana",id=252}}
    if     player.sub_job == 'RDM' then
        info.recast_ids:append({name="Convert",id=49})
    elseif player.sub_job == 'WHM' then
        info.recast_ids:append({name="D.Seal",id=26})
    elseif player.sub_job == 'BLM' then
        info.recast_ids:append({name="E.Seal",id=38})
    elseif player.sub_job == 'SCH' then
        info.recast_ids:append({name="Strats",id=231})
    end

    --select_default_macro_book()
end

-- Called when this job file is unloaded (eg: job change)
function user_unload()
    info.keybinds:unbind()

    info.bubble_binds:unbind()

    if state.AllyBinds.value then info.ally_keybinds:unbind() end
    send_command('unbind !^delete')

    info.ws_binds:unbind()
    send_command('unbind %\\\\')

    destroy_state_text()
end

-- Define sets and vars used by this job file.
function init_gear_sets()

    sets.weapons = {}
    sets.weapons.Idris     = {main="Idris",sub="Genmei Shield",range="Dunna"}
    sets.weapons.IdrisDW   = {main="Idris",sub="Magesmasher +1",range="Dunna"}
    sets.weapons.Maxentius = {main="Maxentius",sub="Genmei Shield",range="Dunna"}
    sets.weapons.MaxenDW   = {main="Maxentius",sub="Magesmasher +1",range="Dunna"}
    sets.weapons.Daybreak  = {main="Daybreak",sub="Ammurapi Shield",range="Dunna"}
    sets.weapons.DayDW     = {main="Daybreak",sub="Malevolence",range="Dunna"}
    sets.weapons.Dagger    = {main="Malevolence",sub="Ammurapi Shield",range="Dunna"}
    sets.weapons.Staff     = {main="Malignance Pole",sub="Khonsu",range="Dunna"}
    sets.TreasureHunter    = {waist="Chaac Belt",legs=gear.mer_legs_th}

    -- Precast Sets

    sets.precast.JA.Bolster             = {body="Bagua Tunic +3"}
    sets.precast.JA['Life Cycle']       = {body="Geomancy Tunic +3",back=gear.PetCape}
    sets.precast.JA['Radial Arcana']    = {feet="Bagua Sandals +3"}
    sets.precast.JA['Mending Halation'] = {feet="Bagua Pants +3"}
    sets.precast.JA['Full Circle']      = {head="Azimuth Hood +3"}
    sets.precast.JA['Concentric Pulse'] = {head="Bagua Galero +3"}

    sets.precast.FC = {main="Idris",sub="Chanter's Shield",range="Dunna",
        head=gear.mer_head_fc,neck="Orunmila's Torque",ear1="Malignance Earring",ear2="Etiolation Earring",
        body="Zendik Robe",hands="Agwu's Gages",ring1="Lebeche Ring",ring2="Medada's Ring",
        back="Perimede Cape",waist="Witful Belt",legs="Geomancy Pants +3",feet=gear.mer_feet_fc}
    sets.precast.FC['Elemental Magic'] = set_combine(sets.precast.FC, {hands="Bagua Mitaines +3"})
    sets.impact = {head=empty,body="Twilight Cloak"}
    sets.precast.FC.Impact = set_combine(sets.precast.FC['Elemental Magic'], sets.impact)
    sets.dispelga = {main="Daybreak",sub="Ammurapi Shield"}
    sets.precast.FC.Dispelga = set_combine(sets.precast.FC, sets.dispelga)

    sets.precast.WS = {
        head="Nyame Helm",neck="Fotia Gorget",ear1="Telos Earring",ear2="Zennaroi Earring",
        body="Nyame Mail",hands="Jhakri Cuffs +2",ring1="Patricius Ring",ring2="Rufescent Ring",
        back=gear.WSCape,waist="Fotia Belt",legs="Nyame Flanchard",feet="Azimuth Gaiters +3"}
    sets.precast.WS['Hexa Strike'] = set_combine(sets.precast.WS, {back=gear.TPCape})
    sets.precast.WS['Realmrazer']  = set_combine(sets.precast.WS, {})
    sets.precast.WS['Black Halo']  = set_combine(sets.precast.WS, {ear1="Moonshade Earring",ring1="Metamorph Ring +1"})
    sets.precast.WS['Judgment']    = set_combine(sets.precast.WS, {ear1="Moonshade Earring"})
    sets.precast.WS['Exudation']   = set_combine(sets.precast.WS, {})

    sets.precast.WS['Brainshaker']   = set_combine(sets.precast.WS, {
        neck="Null Loop",ring1="Etana Ring",ring2="Metamorph Ring +1",back="Null Shawl",waist="Null Belt"})
    sets.precast.WS['Shell Crusher'] = set_combine(sets.precast.WS['Brainshaker'], {})
    sets.precast.WS['Shadowstitch']  = set_combine(sets.precast.WS['Brainshaker'], {})

    sets.precast.WS['Seraph Strike'] = {
        head="Ea Hat +1",neck="Sanctity Necklace",ear1="Moonshade Earring",ear2="Malignance Earring",
        body="Bagua Tunic +3",hands="Jhakri Cuffs +2",ring1="Freke Ring",ring2="Medada's Ring",
        back=gear.MACape,waist="Orpheus's Sash",legs="Ea Slops +1",feet="Azimuth Gaiters +3"}
    sets.precast.WS['Flash Nova'] = set_combine(sets.precast.WS['Seraph Strike'], {ear1="Malignance Earring",ear2="Barkarole Earring"})
    sets.precast.WS['Aeolian Edge']  = set_combine(sets.precast.WS['Seraph Strike'], {back=gear.NukeCape})
    sets.precast.WS['Cyclone']       = set_combine(sets.precast.WS['Aeolian Edge'], {})
    sets.precast.WS['Earth Crusher'] = set_combine(sets.precast.WS['Aeolian Edge'], {})
    sets.precast.WS['Sunburst']      = set_combine(sets.precast.WS['Aeolian Edge'], {head="Pixie Hairpin +1",ring1="Archon Ring"})
    sets.precast.WS['Cataclysm']     = set_combine(sets.precast.WS['Sunburst'], {})
    sets.precast.WS['Energy Drain']  = set_combine(sets.precast.WS['Cataclysm'], {})
    sets.precast.WS['Moonlight'] = {}

    -- Midcast sets

    sets.midcast.Cure = {main="Idris",sub="Genmei Shield",range="Dunna",
        head="Vanya Hood",neck="Loricate Torque +1",ear1="Calamitous Earring",ear2="Mendicant's Earring",
        body="Nyame Mail",hands=gear.tel_hand_enh,ring1="Patricius Ring",ring2="Defending Ring",
        back=gear.PetCape,waist="Shinjutsu-no-Obi +1",legs="Gyve Trousers",feet="Vanya Clogs"}
    sets.midcast.Curaga = sets.midcast.Cure
    sets.midcast.Cursna = {main="Mafic Cudgel",sub="Genmei Shield",ammo="Sapience Orb",
        head="Hike Khat +1",neck="Malison Medallion",ear1="Malignance Earring",ear2="Lugalbanda Earring",
        body="Zendik Robe",hands="Gazu Bracelets +1",ring1="Ephedra Ring",ring2="Menelaus's Ring",
        back=gear.MACape,waist="Embla Sash",legs="Geomancy Pants +3",feet="Vanya Clogs"}
    sets.midcast.CureCheat = {main="Septoptic",sub="Culminus",range="Dunna",
        head="Vanya Hood",neck="Sanctity Necklace",ear1="Eabani Earring",ear2="Mendicant's Earring",
        body="Vanya Robe",hands=gear.tel_hand_enh,ring1="Etana Ring",ring2="Meridian Ring",
        back=gear.PetCape,waist="Gishdubar Sash",legs="Geomancy Pants +3",feet="Vanya Clogs"}
    sets.cmp_belt  = {waist="Shinjutsu-no-Obi +1"}
    sets.gishdubar = {waist="Gishdubar Sash"}

    sets.midcast.EnhancingDuration = {main="Gada",sub="Ammurapi Shield",range="Dunna",
        head=gear.tel_head_enh,neck="Loricate Torque +1",ear1="Calamitous Earring",ear2="Etiolation Earring",
        body=gear.tel_body_enh,hands=gear.tel_hand_enh,ring1="Patricius Ring",ring2="Defending Ring",
        back=gear.PetCape,waist="Embla Sash",legs=gear.tel_legs_enh,feet=gear.tel_feet_enh}
    sets.midcast['Enhancing Magic'] = set_combine(sets.midcast.EnhancingDuration, {
        head="Befouled Crown",neck="Incanter's Torque",ear1="Mimir Earring",ear2="Andoaa Earring",
        body=gear.tel_body_enh,hands="Ayao's Gages",ring1="Stikini Ring +1",
        back="Fi Follet Cape",waist="Olympus Sash",legs="Shedir Seraweels",feet="Regal Pumps +1"})
    sets.midcast.Phalanx = set_combine(sets.midcast['Enhancing Magic'], {hands=gear.mer_hand_phlx})
    sets.midcast.Stoneskin = set_combine(sets.midcast.EnhancingDuration, {
        neck="Nodens Gorget",ear2="Earthcry Earring",waist="Siegel Sash",legs="Shedir Seraweels"})
    sets.midcast.Aquaveil  = set_combine(sets.midcast.EnhancingDuration, {main="Vadose Rod",sub="Ammurapi Shield",
        head="Amalric Coif +1",waist="Emphatikos Rope",legs="Shedir Seraweels"})
    sets.midcast.Regen     = set_combine(sets.midcast.EnhancingDuration, {main="Bolelabunga",sub="Ammurapi Shield"})
    sets.midcast.Refresh   = set_combine(sets.midcast.EnhancingDuration, {head="Amalric Coif +1"})
    sets.self_refresh = {back="Grapevine Cape",waist="Gishdubar Sash",feet="Inspirited Boots"}
    sets.midcast.FixedPotencyEnhancing = sets.midcast.EnhancingDuration

    sets.midcast['Elemental Magic'] = {main="Bunzi's Rod",sub="Ammurapi Shield",range="Dunna",
        head="Azimuth Hood +3",neck="Sibyl Scarf",ear1="Malignance Earring",ear2="Barkarole Earring",
        body="Bagua Tunic +3",hands="Amalric Gages +1",ring1="Freke Ring",ring2="Medada's Ring",
        back=gear.NukeCape,waist="Sacro Cord",legs="Ea Slops +1",feet="Azimuth Gaiters +3"}
    sets.midcast['Elemental Magic'].MAcc = set_combine(sets.midcast['Elemental Magic'], {
        neck="Bagua Charm +2",body="Azimuth Coat +2",ring1="Stikini Ring +1",waist="Acuity Belt +1"})
    sets.midcast.Impact = set_combine(sets.midcast['Elemental Magic'].MAcc, sets.impact)
    sets.magicburst = {main="Bunzi's Rod",sub="Ammurapi Shield",range="Dunna",
        head="Ea Hat +1",neck="Mizukage-no-Kubikazari",ear1="Malignance Earring",ear2="Barkarole Earring",
        body="Ea Houppelande +1",hands="Amalric Gages +1",ring1="Mujin Band",ring2="Medada's Ring",
        back=gear.NukeCape,waist="Sacro Cord",legs="Ea Slops +1",feet="Azimuth Gaiters +3"}
    -- TODO magicburst.MAcc
    sets.seidr     = {body="Seidr Cotehardie"}
    sets.seidrmb   = {body="Seidr Cotehardie",ear2="Static Earring"}
    sets.orpheus   = {waist="Orpheus's Sash"}
    sets.ele_obi   = {waist="Hachirin-no-Obi"}
    sets.nuke_belt = {waist="Sacro Cord"}
    sets.submalev  = {sub="Malevolence"}
    sets.marin     = {main="Marin Staff +1",sub="Enki Strap"}

    sets.midcast['Enfeebling Magic'] = {main="Idris",sub="Ammurapi Shield",range="Dunna",
        head="Azimuth Hood +3",neck="Null Loop",ear1="Malignance Earring",ear2="Regal Earring",
        body="Azimuth Coat +2",hands="Azimuth Gloves +2",ring1="Metamorph Ring +1",ring2="Medada's Ring",
        back="Null Shawl",waist="Null Belt",legs="Geomancy Pants +3",feet="Geomancy Sandals +3"}
    sets.midcast.Silence  = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast.Slow     = set_combine(sets.midcast['Enfeebling Magic'], {
        head="Null Masque",back="Aurist's Cape +1",waist="Luminary Sash"})
    sets.midcast.Paralyze = set_combine(sets.midcast.Slow, {})
    sets.midcast.Dispelga = set_combine(sets.midcast['Enfeebling Magic'], sets.dispelga)

    sets.midcast['Dark Magic'] = set_combine(sets.midcast['Enfeebling Magic'], {
        head="Azimuth Hood +3",body="Geomancy Tunic +3",hands="Geomancy Mitaines +3",waist="Cornelia's Belt"})
    sets.midcast.Drain = {main="Rubicundity",sub="Ammurapi Shield",range="Dunna",
        head="Pixie Hairpin +1",neck="Erra Pendant",ear1="Malignance Earring",ear2="Regal Earring",
        body="Geomancy Tunic +3",hands="Geomancy Mitaines +3",ring1="Archon Ring",ring2="Evanescence Ring",
        back=gear.MACape,waist="Fucho-no-Obi",legs="Geomancy Pants +3",feet="Agwu's Pigaches"}
    sets.midcast.Drain.MAcc = set_combine(sets.midcast.Drain, {head="Bagua Galero +3",neck="Bagua Charm +2"})
    sets.midcast.Aspir = sets.midcast.Drain
    sets.drain_belt = {waist="Fucho-no-Obi"}

    sets.midcast.Flash = {main="Idris",sub="Genmei Shield",range="Dunna",
        head="Azimuth Hood +3",neck="Null Loop",ear1="Malignance Earring",ear2="Regal Earring",
        body="Nyame Mail",hands="Geomancy Mitaines +3",ring1="Stikini Ring +1",ring2="Defending Ring",
        back=gear.MACape,waist="Cornelia's Belt",legs="Geomancy Pants +3",feet="Geomancy Sandals +3"}

    sets.midcast.Geomancy = {main="Idris",sub="Genmei Shield",range="Dunna",
        head="Azimuth Hood +3",neck="Bagua Charm +2",ear1="Calamitous Earring",ear2="Gifted Earring",
        body="Nyame Mail",hands="Geomancy Mitaines +3",ring1="Stikini Ring +1",ring2="Defending Ring",
        back="Solemnity Cape",waist="Shinjutsu-no-Obi +1",legs="Vanya Slops",feet="Vanya Clogs"}
    sets.midcast.Geomancy.Indi = set_combine(sets.midcast.Geomancy, {main="Idris",sub="Genmei Shield",range="Dunna",
        ring1="Patricius Ring",back="Lifestream Cape",legs="Bagua Pants +3",feet="Azimuth Gaiters +3"})
    sets.midcast.Geomancy.Entrust = set_combine(sets.midcast.Geomancy.Indi, {main="Solstice",sub="Genmei Shield"})

    -- Idle/resting/defense/etc sets

    sets.idle = {main="Mafic Cudgel",sub="Genmei Shield",range="Dunna",
        head=gear.mer_head_rf,neck="Loricate Torque +1",ear1="Eabani Earring",ear2="Lugalbanda Earring",
        body="Shamash Robe",hands="Bagua Mitaines +3",ring1="Shneddick Ring +1",ring2="Defending Ring",
        back=gear.PetCape,waist="Null Belt",legs=gear.mer_legs_rf,feet=gear.mer_feet_rf}
    sets.idle.Pet = {main="Idris",sub="Genmei Shield",
        head="Azimuth Hood +3",neck="Bagua Charm +2",ear1="Eabani Earring",ear2="Lugalbanda Earring",
        body="Shamash Robe",hands="Geomancy Mitaines +3",ring1="Shneddick Ring +1",ring2="Defending Ring",
        back=gear.PetCape,waist="Isa Belt",legs=gear.mer_legs_rf,feet="Bagua Sandals +3"}
    sets.idle.PDT = set_combine(sets.idle, {head="Azimuth Hood +3",legs="Nyame Flanchard",feet=gear.mer_feet_rf})
    sets.idle.PDT.Pet = set_combine(sets.idle.Pet, {legs="Nyame Flanchard"})
    sets.idle.MEVA = {main="Mafic Cudgel",sub="Genmei Shield",range="Dunna",
        head="Nyame Helm",neck="Loricate Torque +1",ear1="Eabani Earring",ear2="Lugalbanda Earring",
        body="Nyame Mail",hands="Geomancy Mitaines +3",ring1="Shadow Ring",ring2="Defending Ring",
        back=gear.PetCape,waist="Null Belt",legs="Nyame Flanchard",feet=gear.mer_feet_rf}
    sets.idle.MEVA.Pet = set_combine(sets.idle.MEVA, {main="Idris",sub="Genmei Shield",neck="Bagua Charm +2",waist="Isa Belt"})
    sets.latent_refresh = {waist="Fucho-no-Obi"}
    sets.regain = {head="Null Masque"}
    sets.sphere = {body="Zendik Robe"}
    sets.buff.doom = {neck="Nicander's Necklace",ring1="Saida Ring",ring2="Defending Ring",waist="Gishdubar Sash"}
    sets.buff.sleep = {main="Prime Maul",sub="Genmei Shield"}

    -- Defense sets
    sets.defense.PDT      = sets.idle.PDT
    sets.defense.PDT.Pet  = sets.idle.PDT.Pet
    sets.defense.MEVA     = sets.idle.MEVA
    sets.defense.MEVA.Pet = sets.idle.MEVA.Pet
    sets.Kiting = {feet="Geomancy Sandals +3"}

    -- Engaged sets
    sets.engaged = {main="Maxentius",sub="Genmei Shield",range="Dunna",
        head="Blistering Sallet +1",neck="Bagua Charm +2",ear1="Telos Earring",ear2="Dignitary's Earring",
        body="Nyame Mail",hands="Gazu Bracelets +1",ring1="Chirich Ring +1",ring2="Defending Ring",
        back="Null Shawl",waist="Null Belt",legs="Jhakri Slops +2",feet="Azimuth Gaiters +3"}
    sets.engaged.PDef = set_combine(sets.engaged, {head="Null Masque",legs="Nyame Flanchard"})
    sets.engaged.PetPDef = set_combine(sets.engaged.PDef, {hands="Geomancy Mitaines +3"})
    sets.dualwield = {back=gear.DWCape}

    -- Sets the depend upon idle sets
    sets.midcast.FastRecast = set_combine(sets.defense.PDT.Pet, {back=gear.MACape,waist="Cornelia's Belt"})
    sets.midcast.Dia   = set_combine(sets.defense.PDT.Pet, sets.TreasureHunter)
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
    elseif player.status == 'Idle' and S{'Full Circle','Radial Arcana'}:contains(spell.english) then
        equip(sets.idle[state.IdleMode.value] or sets.idle)
    elseif spell.type == 'Geomancy' then
        if not state.Buff.Entrust and state.OffenseMode.value ~= 'None' and player.equipment.main ~= 'Idris' then
            -- don't let meleeing lower geomancy potency
            enable('main','sub','range','ammo')
            state.OffenseMode:set('None')
            hud_update_on_state_change('Offense Mode')
        end
    end
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_midcast(spell, action, spellMap, eventArgs)
    geo_state_updates(spell, action)
end

-- Run after the default midcast() is done.
-- eventArgs is the same one used in job_midcast, in case information needs to be persisted.
function job_post_midcast(spell, action, spellMap, eventArgs)
    if spell.type == 'Geomancy' then
        if spellMap == 'Indi' and spell.target.type ~= 'SELF' then
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
        --send_command('wait 0.5;gs c update')
        interrupted_message(spell)
    else
        if S{'JobAbility','Scholar'}:contains(spell.type) then
            -- aftercast can get in the way. skip it to avoid breaking bubbles sometimes.
            eventArgs.handled = true
        elseif spell.english:startswith('Geo-') then
            state.Buff.Pet = true
            send_command('timers c luopan 750 down')
        elseif spell.english == 'Impact' then
            debuff_timer(spell, 180)
        elseif spell.english == 'Sleep' or spell.english == 'Sleepga' then
            debuff_timer(spell, 60)
        elseif spell.english == 'Sleep II' then
            debuff_timer(spell, 90)
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
    if lbuff == 'doom' and not midaction() then
        handle_equipping_gear(player.status)
    end
    if gain then
        if lbuff == 'sleep' then
            if not buffactive["Sublimation: Activated"] then
                equip(sets.buff.sleep)
            end
            if buffactive.Stoneskin then
                add_to_chat(123, 'cancelling stoneskin')
                send_command('cancel stoneskin')
            end
        end
        if info.chat_notice_buffs:contains(lbuff) then
            add_to_chat(104, 'Gained ['..buff..']')
        end
    end
    if S{'bolster','widened compass'}:contains(lbuff) then
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
    if state.SphereIdle.value and state.DefenseMode.value == 'None' then
        idleSet = set_combine(idleSet, sets.sphere)
    end
    if player.mpp < 51 and not pet.isvalid then
        idleSet = set_combine(idleSet, sets.latent_refresh)
    end
    if S{'Western Adoulin','Eastern Adoulin'}:contains(world.area) then
        if player.wardrobe4["Councilor's Garb"]   then idleSet = set_combine(idleSet, {body="Councilor's Garb"}) end
    end
    if buffactive['Reive Mark'] then
        if player.wardrobe4["Arciela's Grace +1"] then idleSet = set_combine(idleSet, {neck="Arciela's Grace +1"}) end
    end
    if state.Buff.sleep and not buffactive["Sublimation: Activated"] then
        idleSet = set_combine(idleSet, sets.buff.sleep)
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
    if state.Buff.sleep and not buffactive["Sublimation: Activated"] then
        defenseSet = set_combine(defenseSet, sets.buff.sleep)
    end
    if state.Buff.doom then
        defenseSet = set_combine(defenseSet, sets.buff.doom)
    end
    return defenseSet
end

-- Modify the default melee set after it was constructed.
function customize_melee_set(meleeSet)
    if state.DefenseMode.value == 'None' then
        if state.OffenseMode.value ~= 'None' then
            meleeSet = set_combine(meleeSet, sets.weapons[state.CombatWeapon.value])
            if state.CombatForm.has_value and state.CombatForm.value == 'DW' then
                meleeSet = set_combine(meleeSet, sets.dualwield)
            end
            if buffactive['elvorseal'] then
                meleeSet = set_combine(meleeSet, {body="Angantyr Robe",hands="Angantyr Mittens",legs="Angantyr Tights"})
            end
        else
            meleeSet = sets.idle.PDT.Pet
        end
    end
    if state.HybridMode.value == 'PDef' and player.equipment.main == 'Idris' then
        meleeSet = set_combine(meleeSet, sets.engaged.PetPDef)
    end
    if state.Buff.sleep and not buffactive["Sublimation: Activated"] then
        meleeSet = set_combine(meleeSet, sets.buff.sleep)
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
    report_ja_recasts(info.recast_ids, true, 6)
    eventArgs.handled = true
end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements self-commands.
-------------------------------------------------------------------------------------------------------------------

-- Called for custom player commands.
function job_self_command(cmdParams, eventArgs)
    eventArgs.handled = true
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
    elseif cmdParams[1] == 'scholar' then
        handle_stratagems(cmdParams)
    elseif cmdParams[1] == 'save' then
        save_self_command(cmdParams)
    elseif cmdParams[1] == 'rebind' then
        info.keybinds:bind()
        info.bubble_binds:bind()
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
--    set_macro_page(1,1)
--end

-- returns a list for use with make_keybind_list
function job_keybinds()
    local bind_command_list = L{
        'bind !^l input /lockstyleset 1',
        'bind %`   gs c update user',
        'bind F9   gs c cycle OffenseMode',
        'bind !F9  gs c reset OffenseMode',
        'bind @F9  gs c cycle CombatWeapon',
        'bind F10  gs c cycle CastingMode',
        'bind !F10 gs c reset CastingMode',
        'bind F11  gs c cycle IdleMode',
        'bind !F11 gs c reset IdleMode',
        'bind @F11 gs c toggle Kiting',
        'bind ^space gs c cycle HybridMode',
        'bind !space gs c set DefenseMode Physical',
        'bind @space gs c set DefenseMode Magical',
        'bind !@space gs c reset DefenseMode',
        'bind ~!^q gs c set CombatWeapon Dagger',
        'bind !^q  gs c set CombatWeapon Staff',
        'bind !^w  gs c weap Idris',
        'bind !^e  gs c weap Maxen',
        'bind !^r  gs c weap Day',
        'bind !w   gs c set   OffenseMode Normal',
        'bind !@w  gs c reset OffenseMode',
        'bind ^z   gs c toggle SphereIdle',
        'bind !z   gs c toggle MagicBurst',
        'bind ^c   gs c reset CastingMode',
        'bind ~^c  gs c set CastingMode MAcc',
        'bind !@z  gs c toggle Seidr',
        'bind  !^z gs c set   AutoSeidr',
        'bind ~!^z gs c unset AutoSeidr',
        'bind ^\\\\  gs c toggle CardinalMsg',
        'bind !^\\\\ gs c toggle GeoHUD',
        'bind %~q input /target <pet>',
        'bind ~!^2 gs c CureCheat',

        'bind !^` input /ja Bolster <me>',
        'bind ^@` input /ja "Widened Compass" <me>',
        'bind ^`  input /ja "Blaze of Glory" <me>',
        'bind @`  input /ja Dematerialize <me>',
        'bind !`  input /ja Entrust <me>',
        'bind  ^@tab input /ja "Ecliptic Attrition" <me>',
        'bind ~^@tab input /ja "Life Cycle" <me>',
        'bind @tab   input /ja "Radial Arcana" <me>',
        'bind ~@tab  input /ja "Mending Halation" <me>',
        'bind @q   input /ja "Full Circle" <me>',
        'bind ^@q  input /ja "Concentric Pulse"',

        'bind ^-|^@-|!-|!@-|%- input /ja "Theurgic Focus" <me>',
        'bind ^=|^@=|!=|!@=|%= input /ja "Collimated Fervor" <me>',

        'bind ^1   input /ma "Dia II"',
        'bind ^@1  input /ma "Bio II"',
        'bind ~^@1 input /ma Diaga <stnpc>',
        'bind ^2   input /ma Slow',
        'bind ^@2  input /ma Blind',
        'bind ^3   input /ma Paralyze',
        'bind ^@3  input /ma Bind <stnpc>',
        'bind ^4   input /ma Silence',
        'bind ^@4  input /ma Gravity',
        'bind ^5   input /ma "Sleep II" <stnpc>',
        'bind ^@5  input /ma Sleep <stnpc>',
        'bind ^backspace input /ma Impact',

        'bind !1 input /ma "Cure III" <stpc>',
        'bind !2 input /ma "Cure IV" <stpc>',
        'bind !3 input /ma Distract',
        'bind !4 input /ma Frazzle',
        'bind !5 input /ma Haste <stpc>',
        'bind !6 input /ma Refresh <stpc>',
        'bind !7 input /ma Flurry <stpc>',

        'bind ~@8 input /ma "Stone III"',
        'bind ~@9 input /ma "Water III"',
        'bind ~@0 input /ma "Aero III"',
        'bind  @8 input /ma "Fire III"',
        'bind  @9 input /ma "Blizzard III"',
        'bind  @0 input /ma "Thunder III"',

        'bind ~!8 input /ma "Stone IV"',
        'bind ~!9 input /ma "Water IV"',
        'bind ~!0 input /ma "Aero IV"',
        'bind  !8 input /ma "Fire IV"',
        'bind  !9 input /ma "Blizzard IV"',
        'bind  !0 input /ma "Thunder IV"',

        'bind ~!@8|%~8 input /ma "Stone V"',
        'bind ~!@9|%~9 input /ma "Water V"',
        'bind ~!@0|%~0 input /ma "Aero V"',
        'bind  !@8|%8  input /ma "Fire V"',
        'bind  !@9|%9  input /ma "Blizzard V"',
        'bind  !@0|%0  input /ma "Thunder V"',

        'bind ~^@8 input /ma "Stonera II"',
        'bind ~^@9 input /ma "Watera II"',
        'bind ~^@0 input /ma "Aera II"',
        'bind  ^@8 input /ma "Fira II"',
        'bind  ^@9 input /ma "Blizzara II"',
        'bind  ^@0 input /ma "Thundara II"',

        'bind ~^8 input /ma "Stonera III"',
        'bind ~^9 input /ma "Watera III"',
        'bind ~^0 input /ma "Aera III"',
        'bind  ^8 input /ma "Fira III"',
        'bind  ^9 input /ma "Blizzara III"',
        'bind  ^0 input /ma "Thundara III"',

        'bind !f  input /ma Haste        <me>',
        'bind !g  input /ma Phalanx      <me>',
        'bind @g  input /ma "Ice Spikes" <me>',
        'bind !@g input /ma Stoneskin    <me>',
        'bind !b  input /ma Refresh      <me>',
        'bind @c  input /ma Blink        <me>',
        'bind @v  input /ma Aquaveil     <me>',
        'bind ~^x  input /ma Sneak     <me>',
        'bind ~!^x input /ma Invisible <me>',

        'bind ^q  input /ma Dispelga',
        'bind @d input /ma "Aspir II"',
        'bind !d  input /ma "Aspir III"',
        'bind !@d input /ma Aspir'}

    if     player.sub_job == 'RDM' then
        bind_command_list:extend(L{
            'bind !@`  input /ja Convert <me>',
            'bind ^tab input /ma Dispel'})
    elseif player.sub_job == 'WHM' then
        bind_command_list:extend(L{
            'bind ^tab input /ja "Divine Seal" <me>',
            'bind !@1 input /ma Curaga',
            'bind !@2 input /ma "Curaga II"',
            'bind !@3 input /ma "Curaga III"',
            'bind @1 input /ma Poisona',
            'bind @2 input /ma Paralyna',
            'bind @3 input /ma Blindna',
            'bind @4 input /ma Silena',
            'bind @5 input /ma Stona',
            'bind @6 input /ma Viruna',
            'bind @7 input /ma Cursna',
            'bind @F1 input /ma Erase'})
    elseif player.sub_job == 'BLM' then
        bind_command_list:extend(L{
            'bind ^tab input /ja "Elemental Seal" <me>',
            'bind ~^@5 input /ma Sleepga',
            'bind !e   input /ma Stun'})
    elseif player.sub_job == 'SCH' then
        -- TODO
    elseif player.sub_job == 'DRK' then
        -- TODO
    elseif player.sub_job == 'DNC' then
        bind_command_list:extend(L{
            'bind !1 input /ja "Curing Waltz II" <stpc>',
            'bind !2 input /ja "Curing Waltz III" <stpc>',
            'bind @F1 input /ja "Healing Waltz" <stpc>',
            'bind @F2 input /ja "Divine Waltz" <me>',
            'bind !v input /ja "Spectral Jig" <me>',
            'bind !f input /ja "Haste Samba" <me>',
            'bind !@f input /ja "Reverse Flourish" <me>',
            'bind !e input /ja "Box Step"',
            'bind !@e input /ja Quickstep'})
    elseif player.sub_job == 'NIN' then
        bind_command_list:extend(L{
            'bind !e  input /ma "Utsusemi: Ni" <me>',
            'bind !@e input /ma "Utsusemi: Ichi" <me>'})
    end

    return bind_command_list
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
            info  = {indi_dur = 306, entrust_dur = 324} -- edit to proper values
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
            if state.Buff.Entrust and spell.target.type ~= 'SELF' then
                local dur = info.entrust_dur
                if action == 'midcast' then state.saved_entrust = state.entrust:copy()
                else                        state.saved_entrust = nil end
                state.entrust = T{started = os.time(), duration = dur, target = spell.target.name, last_colure = spell.english:sub(6),
                                  bolster = state.Buff.Bolster, wide = state.Buff['Widened Compass']}
            else
                local dur = info.indi_dur
                if action == 'midcast' then state.saved_indi    = state.indi:copy()
                else                        state.saved_indi = nil end
                state.indi = T{started = os.time(), duration = dur, last_colure = spell.english:sub(6)}
            end
        end
    end
end

function init_state_text()
    if hud then return end

    local mb_text_settings    = {flags={draggable=false,bold=true},bg={red=250,green=200,blue=0,alpha=150},text={stroke={width=2}}}
    local seidr_text_settings = {pos={y=18},flags={draggable=false,bold=true},bg={red=0,green=220,blue=220,alpha=150},
                                 text={stroke={width=2}}}
    local ally_text_settings  = {pos={x=-178},flags={draggable=false,right=true,bold=true},bg={alpha=200},text={font='Courier New',size=10}}
    local hyb_text_settings   = {pos={x=130,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local def_text_settings   = {pos={x=172,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local off_text_settings   = {pos={x=172,y=697},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local geo_entrust_text_settings = {pos={x=1000,y=676},flags={draggable=false,bold=true},
                                       bg={alpha=150},padding=1,text={font='Courier New',size=10,stroke={width=1}}}
    local geo_luopan_text_settings  = {pos={x=1000,y=697},flags={draggable=false,bold=true},
                                       bg={alpha=150},padding=1,text={font='Courier New',size=10,stroke={width=1}}}
    local geo_indi_text_settings    = {pos={x=1000,y=718},flags={draggable=false,bold=true},
                                       bg={alpha=150},padding=1,text={font='Courier New',size=10,stroke={width=1}}}

    hud = {texts=T{}}
    hud.texts.mb_text          = texts.new('MBurst',         mb_text_settings)
    hud.texts.seidr_text       = texts.new('Seidr',          seidr_text_settings)
    hud.texts.ally_text        = texts.new('AllyCure',       ally_text_settings)
    hud.texts.hyb_text         = texts.new('initializing..', hyb_text_settings)
    hud.texts.def_text         = texts.new('initializing..', def_text_settings)
    hud.texts.off_text         = texts.new('initializing..', off_text_settings)
    hud.texts.geo_entrust_text = texts.new('initializing..', geo_entrust_text_settings)
    hud.texts.geo_luopan_text  = texts.new('initializing..', geo_luopan_text_settings)
    hud.texts.geo_indi_text    = texts.new('initializing..', geo_indi_text_settings)

    -- update infrequently changing text boxes in job_state_change or where they are changed
    function hud_update_on_state_change(stateField)
        if not hud then init_state_text() end

        if not stateField or stateField == 'Magic Burst' then
            hud.texts.mb_text:visible(state.MagicBurst.value)
        end

        if not stateField or stateField == 'Seidr Nukes' then
            hud.texts.seidr_text:visible(state.Seidr.value)
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

    -- update continuously changing text boxes with a prerender event
    local counter, interval = 15, 15 -- only update bubble texts every <interval> frames
    function hud_update_on_prerender()
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
                    hud.texts.geo_entrust_text:text(text)
                    hud.texts.geo_entrust_text:color(255,255,255)
                    hud.texts.geo_entrust_text:bg_color(0,green,0)
                elseif entrust_recast > 0 then
                    local min, sec = math.floor(entrust_recast / 60), entrust_recast % 60
                    hud.texts.geo_entrust_text:text('Entrust : %d:%02d':format(min, sec)
                        ..(state.entrust.last_colure and     ' (last: '..state.entrust.last_colure..')' or ''))
                    hud.texts.geo_entrust_text:color(255,255,255)
                    hud.texts.geo_entrust_text:bg_color(0,0,0)
                else
                    hud.texts.geo_entrust_text:text('NO ENTRUST'
                        ..(state.entrust.last_colure and '     (last: '..state.entrust.last_colure..')' or ''))
                    hud.texts.geo_entrust_text:color(0,0,0)
                    hud.texts.geo_entrust_text:bg_color(255,0,0)
                end
                hud.texts.geo_entrust_text:show()

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
                    hud.texts.geo_luopan_text:text(text)
                    hud.texts.geo_luopan_text:color(255,255,255)
                    hud.texts.geo_luopan_text:bg_color(0,green,0)
                else
                    hud.texts.geo_luopan_text:text('NO LUOPAN'
                        ..(state.luopan.last_colure and '      (last: '..state.luopan.last_colure..')' or ''))
                    hud.texts.geo_luopan_text:color(0,0,0)
                    hud.texts.geo_luopan_text:bg_color(255,0,0)
                end
                hud.texts.geo_luopan_text:show()

                if player.indi then
                    local indi_time_remaining = math.max(0, state.indi.started and state.indi.started - now + state.indi.duration or 0)
                    local min, sec = math.floor(indi_time_remaining / 60), indi_time_remaining % 60
                    local green    = math.min(math.max(0, math.floor(255 * indi_time_remaining / (state.indi.duration or 1))), 255)
                    local text     = 'Indi-%s : %d:%02d':format((state.indi.last_colure and state.indi.last_colure or '?'), min, sec)
                    if state.Buff.Bolster then text = '[BOLSTER]'..text end
                    hud.texts.geo_indi_text:text(text)
                    hud.texts.geo_indi_text:color(255,255,255)
                    hud.texts.geo_indi_text:bg_color(0,green,0)
                else
                    hud.texts.geo_indi_text:text('NO INDICOLURE'
                        ..(state.indi.last_colure and '  (last: '..state.indi.last_colure..')' or ''))
                    hud.texts.geo_indi_text:color(0,0,0)
                    hud.texts.geo_indi_text:bg_color(255,0,0)
                end
                hud.texts.geo_indi_text:show()
            else
                hud.texts.geo_entrust_text:hide()
                hud.texts.geo_luopan_text:hide()
                hud.texts.geo_indi_text:hide()
            end
        elseif not state.GeoHUD.value then
            hud.texts.geo_entrust_text:hide()
            hud.texts.geo_luopan_text:hide()
            hud.texts.geo_indi_text:hide()
        end
    end

    hud.prerender_event_id = windower.raw_register_event('prerender', hud_update_on_prerender)
end
