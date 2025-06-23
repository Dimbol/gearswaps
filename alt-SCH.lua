-- Modified from 'https://github.com/Kinematics/GearSwap-Jobs/blob/master/SCH.lua'

-- notes:
-- shattersoul has mdef-10 like vidohunir
-- aeolian edge can be used /rdm, or cataclysm /whm

-- skillchains
-- wind    > dark    = gravitation      (earth/dark)
-- light   > stone   = distortion       (water/ice)
-- fire    > thunder = fusion           (light/fire)
-- ice     > water   = fragmentation    (wind/thunder)
-- fire    > stone   = scission         (stone)
-- wind    > stone   = scission         (stone)
-- stone   > water   = reverberation    (water)
-- light   > water   = reverberation    (water)
-- stone   > wind    = detonation       (wind)
-- thunder > wind    = detonation       (wind)
-- dark    > wind    = detonation       (wind)
-- stone   > fire    = liquefaction     (fire)
-- thunder > fire    = liquefaction     (fire)
-- water   > ice     = induration       (ice)
-- water   > thunder = impaction        (thunder)
-- ice     > thunder = impaction        (thunder)
-- dark    > light   = transfixion      (light)
-- ice     > dark    = compression      (dark)
-- light   > dark    = compression      (dark)

-- staff weaponskill properties
-- heavy swing:         impaction
-- rock crusher:        impaction
-- earth crusher:       detonation, impaction
-- starburst/sunburst:  compression, reverberation
-- shell crusher:       detonation
-- full swing:          liquefaction, impaction
-- retribution:         gravitation, reverberation
-- shattersoul:         gravitation, induration
-- omniscience:         gravitation, tranxfixion

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

    state.Buff['Light Arts']      = buffactive['Light Arts'] or false
    state.Buff['Addendum: White'] = buffactive['Addendum: White'] or false
    state.Buff['Dark Arts']       = buffactive['Dark Arts'] or false
    state.Buff['Addendum: Black'] = buffactive['Addendum: Black'] or false
    state.Buff['Enlightenment']   = buffactive['Enlightenment'] or false
    state.Buff['Ebullience']      = buffactive['Ebullience'] or false
    state.Buff['Rapture']         = buffactive['Rapture'] or false
    state.Buff['Perpetuance']     = buffactive['Perpetuance'] or false
    state.Buff['Immanence']       = buffactive['Immanence'] or false
    state.Buff['Penury']          = buffactive['Penury'] or false
    state.Buff['Parsimony']       = buffactive['Parsimony'] or false
    state.Buff['Celerity']        = buffactive['Celerity'] or false
    state.Buff['Alacrity']        = buffactive['Alacrity'] or false
    state.Buff['Elemental Seal']  = buffactive['Elemental Seal'] or false
    state.Buff.doom = buffactive.doom or false
    state.Buff.sleep = buffactive.sleep or false

    logout_event_id = windower.raw_register_event('logout', destroy_state_text)
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
    state.OffenseMode:options('None','Normal')                              -- Cycle with F9, set with !w, unset with !@w
    state.HybridMode:options('Normal','PDef')                               -- Cycle with ^space
    state.CastingMode:options('Normal','MAcc')                              -- Cycle with F10, set with ^c, ~^c
    state.IdleMode:options('Normal','MRf')                                  -- Cycle with F11
    state.MagicalDefenseMode:options('MDT','MRf')                           -- Cycle with @z
    state.CombatWeapon = M{['description']='Combat Weapon'}
    state.CombatWeapon:options('Marin','Musa','Pole','Khat','Bunzi','Dagger')   -- Cycle with @F9

    state.SphereIdle = M(false, 'Sphere Sphere')        -- Toggle with ^z
    state.AllyBinds  = M(false, 'Ally Cure Keybinds')   -- Toggle with !^delete
    state.DiaMsg     = M(false, 'Dia Message')          -- Toggle with ^\
    state.MagicBurst = M(false, 'MB Mode')              -- Toggle with !z, %z
    state.MBSingle   = M(false, 'MB (1)')               -- Toggle with FIXME
    state.OANuke     = M(false, 'OA Mode')              -- Toggle with ~^z
    state.OASingle   = M(false, 'OA (1)')               -- Toggle with ~z
    state.SeidrNuke  = M(false, 'Seidr Nukes')          -- Toggle with !@z
    state.AutoSeidr  = M(false, 'Seidr Auto')           -- Toggle with ~!@z
    state.AutoSeidr.low_mp = 750

    state.SCMode     = M('Manual','Auto')                -- Set with !c or !^c
    state.SCDmg      = M(true,  'Damaging Skillchains')  -- Toggle with !\
    state.SCHelix    = M(false, 'SC Helix Closer')       -- Toggle with @\
    state.SCHUD      = M(true,  'Skillchain HUD')        -- Toggle with !^\
    info.skillchains = T{
        ['grav']          = {name='Gravitation',   list=L{{action='Aero'},          {action='Noctohelix'}}},
        ['grav-ws']       = {name='Gravitation',   list=L{{action='Aero'},          {action='Starburst'}}},
        ['grav-dag']      = {name='Gravitation',   list=L{{action='Cyclone'},       {action='Noctohelix'}}},
        ['t3-grav']       = {name='Gravitation',   list=L{{action='Aero III'},      {action='Noctohelix'}}},
        ['t3-grav-ws']    = {name='Gravitation',   list=L{{action='Aero III'},      {action='Starburst'}}},
        ['dist']          = {name='Distortion',    list=L{{action='Luminohelix'},   {action='Stone'}}},
        ['dist-ws']       = {name='Distortion',    list=L{{action='Omniscience'},   {action='Stone'}}},
        ['dist-dag']      = {name='Distortion',    list=L{{action='Luminohelix'},   {action='Aeolian Edge'}}},
        ['h-dist']        = {name='Distortion',    list=L{{action='Luminohelix'},   {action='Geohelix'}}},
        ['h-dist-ws']     = {name='Distortion',    list=L{{action='Omniscience'},   {action='Geohelix'}}},
        ['t3-dist']       = {name='Distortion',    list=L{{action='Luminohelix'},   {action='Stone III'}}},
        ['t3-dist-ws']    = {name='Distortion',    list=L{{action='Omniscience'},   {action='Stone III'}}},
        ['fusion']        = {name='Fusion',        list=L{{action='Fire'},          {action='Thunder'}}},
        ['fusion-ws']     = {name='Fusion',        list=L{{action='Fire'},          {action='Rock Crusher'}}},
        ['fusion-dag']    = {name='Fusion',        list=L{{action='Fire'},          {action='Cyclone'}}},
        ['h-fusion']      = {name='Fusion',        list=L{{action='Fire'},          {action='Ionohelix'}}},
        ['t3-fusion']     = {name='Fusion',        list=L{{action='Fire III'},      {action='Thunder III'}}},
        ['t3-fusion-ws']  = {name='Fusion',        list=L{{action='Fire III'},      {action='Rock Crusher'}}},
        ['frag']          = {name='Fragmentation', list=L{{action='Blizzard'},      {action='Water'}}},
        ['frag-ws']       = {name='Fragmentation', list=L{{action='Shattersoul'},   {action='Water'}}},
        ['h-frag']        = {name='Fragmentation', list=L{{action='Blizzard'},      {action='Hydrohelix'}}},
        ['h-frag-ws']     = {name='Fragmentation', list=L{{action='Shattersoul'},   {action='Hydrohelix'}}},
        ['t3-frag']       = {name='Fragmentation', list=L{{action='Blizzard III'},  {action='Water III'}}},
        ['t3-frag-ws']    = {name='Fragmentation', list=L{{action='Shattersoul'},   {action='Water III'}}},
        ['earth']         = {name='Scission',      list=L{{action='Aero'},          {action='Stone'}}},
        ['earth-ws']      = {name='Scission',      list=L{{action='Shell Crusher'}, {action='Stone'}}},
        ['earth-dag']     = {name='Scission',      list=L{{action='Cyclone'},       {action='Stone'}}},
        ['h-earth']       = {name='Scission',      list=L{{action='Aero'},          {action='Geohelix'}}},
        ['h-earth-ws']    = {name='Scission',      list=L{{action='Shell Crusher'}, {action='Geohelix'}}},
        ['t3-earth']      = {name='Scission',      list=L{{action='Aero III'},      {action='Stone III'}}},
        ['t3-earth-ws']   = {name='Scission',      list=L{{action='Shell Crusher'}, {action='Stone III'}}},
        ['water']         = {name='Reverberation', list=L{{action='Stone'},         {action='Water'}}},
        ['water-ws']      = {name='Reverberation', list=L{{action='Omniscience'},   {action='Water'}}},
        ['water-dag']     = {name='Reverberation', list=L{{action='Aeolian Edge'},  {action='Water'}}},
        ['h-water']       = {name='Reverberation', list=L{{action='Stone'},         {action='Hydrohelix'}}},
        ['h-water-ws']    = {name='Reverberation', list=L{{action='Omniscience'},   {action='Hydrohelix'}}},
        ['t3-water']      = {name='Reverberation', list=L{{action='Stone III'},     {action='Water III'}}},
        ['t3-water-ws']   = {name='Reverberation', list=L{{action='Omniscience'},   {action='Water III'}}},
        ['wind']          = {name='Detonation',    list=L{{action='Stone'},         {action='Aero'}}},
        ['wind-ws']       = {name='Detonation',    list=L{{action='Rock Crusher'},  {action='Aero'}}},
        ['wind-dag']      = {name='Detonation',    list=L{{action='Stone'},         {action='Cyclone'}}},
        ['h-wind']        = {name='Detonation',    list=L{{action='Stone'},         {action='Anemohelix'}}},
        ['h-wind-ws']     = {name='Detonation',    list=L{{action='Rock Crusher'},  {action='Anemohelix'}}},
        ['t3-wind']       = {name='Detonation',    list=L{{action='Stone III'},     {action='Aero III'}}},
        ['t3-wind-ws']    = {name='Detonation',    list=L{{action='Rock Crusher'},  {action='Aero III'}}},
        ['fire']          = {name='Liquefaction',  list=L{{action='Stone'},         {action='Fire'}}},
        ['fire-ws']       = {name='Liquefaction',  list=L{{action='Rock Crusher'},  {action='Fire'}}},
        ['fire-dag']      = {name='Liquefaction',  list=L{{action='Aeolian Edge'},  {action='Fire'}}},
        ['h-fire']        = {name='Liquefaction',  list=L{{action='Stone'},         {action='Pyrohelix'}}},
        ['h-fire-ws']     = {name='Liquefaction',  list=L{{action='Rock Crusher'},  {action='Pyrohelix'}}},
        ['t3-fire']       = {name='Liquefaction',  list=L{{action='Thunder III'},   {action='Fire III'}}},
        ['t3-fire-ws']    = {name='Liquefaction',  list=L{{action='Rock Crusher'},  {action='Fire III'}}},
        ['ice']           = {name='Induration',    list=L{{action='Water'},         {action='Blizzard'}}},
        ['ice-ws']        = {name='Induration',    list=L{{action='Water'},         {action='Shattersoul'}}},
        ['h-ice']         = {name='Induration',    list=L{{action='Water'},         {action='Cryohelix'}}},
        ['t3-ice']        = {name='Induration',    list=L{{action='Water III'},     {action='Blizzard III'}}},
        ['t3-ice-ws']     = {name='Induration',    list=L{{action='Water III'},     {action='Shattersoul'}}},
        ['thunder']       = {name='Impaction',     list=L{{action='Blizzard'},      {action='Thunder'}}},
        ['thunder-ws']    = {name='Impaction',     list=L{{action='Shattersoul'},   {action='Thunder'}}},
        ['thunder-dag']   = {name='Impaction',     list=L{{action='Blizzard'},      {action='Cyclone'}}},
        ['h-thunder']     = {name='Impaction',     list=L{{action='Blizzard'},      {action='Ionohelix'}}},
        ['h-thunder-ws']  = {name='Impaction',     list=L{{action='Shattersoul'},   {action='Ionohelix'}}},
        ['t3-thunder']    = {name='Impaction',     list=L{{action='Blizzard III'},  {action='Thunder III'}}},
        ['t3-thunder-ws'] = {name='Impaction',     list=L{{action='Shattersoul'},   {action='Thunder III'}}},
        ['light']         = {name='Transfixion',   list=L{{action='Noctohelix'},    {action='Luminohelix'}}},
        ['light-ws']      = {name='Transfixion',   list=L{{action='Starburst'},     {action='Luminohelix'}}},
        ['dark']          = {name='Compression',   list=L{{action='Blizzard'},      {action='Noctohelix'}}},
        ['dark-ws']       = {name='Compression',   list=L{{action='Omniscience'},   {action='Noctohelix'}}},
        ['t3-dark']       = {name='Compression',   list=L{{action='Blizzard III'},  {action='Noctohelix'}}},
        ['30k']           = {name='30k Combo',     list=L{{action='Luminohelix'}, {action='Stone'}, {action='Omniscience'}}},
        ['longgrav']      = {name='Long Grav.',    list=L{{action='Stone'}, {action='Aero'}, {action='Stone'},
                                                          {action='Anemohelix'}, {action='Noctohelix'}}},
        ['6step']         = {name='Six Step?',     list=L{{action='Stone'}, {action='Aero'}, {action='Stone'},
                                                          {action='Aero'}, {action='Stone'}, {action='Aero'},
                                                          {action='Starburst'}}},
    }
    info.sc_step_waits = T{} -- TODO test for and place exceptions to default wait times here
    info.weaponskills = gearswap.res.weapon_skills:rekey('en')
    skillchain_state_updates(nil, 'init')
    init_state_text()
    hud_update_on_state_change()

    info.addendum_spells = T{'Poisona','Paralyna','Blindna','Silena','Stona','Viruna','Cursna','Erase',
                             'Raise II','Raise III','Reraise','Reraise II','Reraise III',
                             'Stone IV','Water IV','Aero IV','Fire IV','Blizzard IV','Thunder IV',
                             'Stone V','Water V','Aero V','Fire V','Blizzard V','Thunder V',
                             'Sleep','Sleep II','Dispel'}

    -- Augmented items get variables for convenience and specificity
    gear.MACape   = {name="Lugh's Cape", augments={'MND+20','Mag. Acc+20 /Mag. Dmg.+20','"Fast Cast"+10'}}
    gear.NukeCape = {name="Lugh's Cape", augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','"Mag.Atk.Bns."+10'}}
    gear.IdleCape = {name="Lugh's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','Enmity-10'}}
    gear.TPCape   = {name="Lugh's Cape", augments={'DEX+20','Accuracy+20 Attack+20','"Dbl.Atk."+10'}}
    gear.HDurCape  = {name="Bookworm's Cape", augments={'Helix eff. dur. +20'}}
    gear.RegenCape = {name="Bookworm's Cape", augments={'"Regen" potency+10'}}

    gear.chir_legs_ma  = {name="Chironic Hose", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25','Mag. Acc.+13'}}
    gear.mer_head_rf   = {name="Merlinic Hood", augments={'"Refresh"+2'}}
    gear.mer_head_fc   = {name="Merlinic Hood", augments={'"Fast Cast"+7'}}
    gear.mer_body_oa   = {name="Merlinic Jubbah", augments={'"Occult Acumen"+11'}}
    gear.mer_hand_rf   = {name="Merlinic Dastanas", augments={'"Refresh"+2'}}
    gear.mer_hand_oa   = {name="Merlinic Dastanas", augments={'"Occult Acumen"+11'}}
    gear.mer_hand_phlx = {name="Merlinic Dastanas", augments={'Phalanx +3'}}
    gear.mer_legs_rf   = {name="Merlinic Shalwar", augments={'"Refresh"+2'}}
    gear.mer_legs_th   = {name="Merlinic Shalwar", augments={'"Treasure Hunter"+2'}}
    gear.mer_feet_rf   = {name="Merlinic Crackows", augments={'"Refresh"+2'}}
    gear.mer_feet_oa   = {name="Merlinic Crackows", augments={'"Occult Acumen"+11'}}
    gear.mer_feet_fc   = {name="Merlinic Crackows", augments={'"Fast Cast"+7'}}
    gear.tel_head_enh  = {name="Telchine Cap", augments={'Enh. Mag. eff. dur. +10'}}
    gear.tel_body_enh  = {name="Telchine Chas.", augments={'Enh. Mag. eff. dur. +10'}}
    gear.tel_hand_enh  = {name="Telchine Gloves", augments={'Enh. Mag. eff. dur. +10'}}
    gear.tel_legs_enh  = {name="Telchine Braconi", augments={'Enh. Mag. eff. dur. +10'}}
    gear.tel_feet_enh  = {name="Telchine Pigaches", augments={'Enh. Mag. eff. dur. +10'}}

    info.keybinds = make_keybind_list(job_keybinds())
    info.keybinds:bind()

    info.ally_keybinds = make_keybind_list(L{
        'bind %~delete   input /ma "Cure IV" <p0>',
        'bind %~end      input /ma "Cure IV" <p1>',
        'bind %~pagedown input /ma "Cure IV" <p2>',
        'bind %~insert   input /ma "Cure IV" <p3>',
        'bind %~home     input /ma "Cure IV" <p4>',
        'bind %~pageup   input /ma "Cure IV" <p5>',
        'bind ^delete    input /ma "Cure IV" <a10>',
        'bind ^end       input /ma "Cure IV" <a11>',
        'bind ^pagedown  input /ma "Cure IV" <a12>',
        'bind ^insert    input /ma "Cure IV" <a13>',
        'bind ^home      input /ma "Cure IV" <a14>',
        'bind ^pageup    input /ma "Cure IV" <a15>',
        'bind !delete    input /ma "Cure IV" <a20>',
        'bind !end       input /ma "Cure IV" <a21>',
        'bind !pagedown  input /ma "Cure IV" <a22>',
        'bind !insert    input /ma "Cure IV" <a23>',
        'bind !home      input /ma "Cure IV" <a24>',
        'bind !pageup    input /ma "Cure IV" <a25>'})
    send_command('bind !^delete gs c toggle AllyBinds')

    info.ws_binds = make_keybind_list(T{
        ['Staff']=L{
            'bind !^1 input /ws "Shell Crusher"',
            'bind !^2 input /ws "Omniscience"',
            'bind !^3 input /ws "Shattersoul"',
            'bind !^4 input /ws "Rock Crusher"',
            'bind !^5 input /ws "Starburst"',
            'bind !^6 input /ws "Cataclysm"',
            'bind !@e input /ws "Myrkr"'},
        ['Club']=L{
            'bind !^1 input /ws "Brainshaker"',
            'bind !^2 input /ws "Shining Strike"',
            'bind !^3 input /ws "Black Halo"',
            'bind !^4 input /ws "Realmrazer"',
        },
        ['Dagger']=L{
            'bind !^1 input /ws "Energy Drain"',
            'bind !^2 input /ws "Wasp Sting"',
            'bind !^3 input /ws "Gust Slash"',
            'bind !^4 input /ws "Shadowstitch"',
            'bind !^6 input /ws "Aeolian Edge"'}},
        {['Marin']='Staff',['Musa']='Staff',['Pole']='Staff',['Khat']='Staff',
         ['Bunzi']='Club',['Club']='Club',['Dagger']='Dagger'})
    info.ws_binds:bind(state.CombatWeapon)
    send_command('bind %\\\\ gs c ListWS')

    info.recast_ids = L{{name="Strats",id=231}}
    if     player.sub_job == 'RDM' then
        info.recast_ids:append({name="Convert",id=49})
    elseif player.sub_job == 'WHM' then
        info.recast_ids:append({name="D.Seal",id=26})
    elseif player.sub_job == 'BLM' then
        info.recast_ids:append({name="E.Seal",id=38})
    end

    --select_default_macro_book()

    -- give monkey_check_spell access to the gearswap environment, plus our state vars
    local monkey_env = {state=state}
    setmetatable(monkey_env, {__index = gearswap})
    gearswap.setfenv(monkey_check_spell, monkey_env)
    gearswap.setfenv(monkey_filter_pretarget, monkey_env)

    -- monkey patch gearswap.check_spell
    gearswap_check_spell = gearswap_check_spell or gearswap.check_spell
    gearswap.check_spell = monkey_check_spell

    -- monkey patch gearswap.filter_pretarget
    gearswap_filter_pretarget = gearswap_filter_pretarget or gearswap.filter_pretarget
    gearswap.filter_pretarget = monkey_filter_pretarget
end

-- Called when this job file is unloaded (eg: job change)
function user_unload()
    info.keybinds:unbind()

    if state.AllyBinds.value then info.ally_keybinds:unbind() end
    send_command('unbind !^delete')

    info.ws_binds:unbind()
    send_command('unbind %\\\\')

    destroy_state_text()

    if gearswap.check_spell == monkey_check_spell then
        gearswap.check_spell = gearswap_check_spell
    end

    if gearswap.filter_pretarget == monkey_filter_pretarget then
        gearswap.filter_pretarget = gearswap_filter_pretarget
    end
end

-- Define sets and vars used by this job file.
function init_gear_sets()

    sets.weapons = {}
    sets.weapons.Akademos = {main="Akademos",sub="Enki Strap"}
    sets.weapons.Marin    = {main="Marin Staff +1",sub="Enki Strap"}
    sets.weapons.Musa     = {main="Musa",sub="Khonsu"}
    sets.weapons.Pole     = {main="Malignance Pole",sub="Khonsu"}
    sets.weapons.Khat     = {main="Khatvanga",sub="Khonsu"}
    sets.weapons.Bunzi    = {main="Bunzi's Rod",sub="Ammurapi Shield"}
    sets.weapons.Club     = {main="Maxentius",sub="Ammurapi Shield"}
    sets.weapons.Dagger   = {main="Malevolence",sub="Ammurapi Shield"}

    sets.TreasureHunter = {ammo="Perfect Lucky Egg",waist="Chaac Belt",legs=gear.mer_legs_th}

    sets.buff['Perpetuance'] = {hands="Arbatel Bracers +3"} -- duration x2.65
    sets.buff['Penury']      = {legs="Arbatel Pants +3"}    -- caps conserve mp
    sets.buff['Parsimony']   = {legs="Arbatel Pants +3"}    -- caps conserve mp
    sets.buff['Celerity']    = {feet="Pedagogy Loafers +3"} -- cap breaking recast reduction
    sets.buff['Alacrity']    = {feet="Pedagogy Loafers +3"} -- cap breaking recast reduction
    sets.buff['Ebullience']  = {head="Arbatel Bonnet +3"}   -- damage x1.41 (instead of x1.20)
    sets.buff['Klimaform']   = {feet="Arbatel Loafers +3"}  -- damage x1.25

    ---- Precast Sets ----
    sets.precast.JA['Tabula Rasa'] = {legs="Pedagogy Pants +3"}

    sets.precast.FC = {main="Musa",sub="Clerisy Strap",ammo="Impatiens",
        head=gear.mer_head_fc,neck="Orunmila's Torque",ear1="Malignance Earring",ear2="Etiolation Earring",
        body="Zendik Robe",hands="Academic's Bracers +3",ring1="Lebeche Ring",ring2="Medada's Ring",
        back=gear.MACape,waist="Witful Belt",legs="Pinga Pants +1",feet="Academic's Loafers +3"}
    sets.precast.FC.Cure = set_combine(sets.precast.FC, {
        head="Pedagogy Mortarboard +3",ear2="Mendicant's Earring",feet=gear.mer_feet_fc})
    sets.precast.FC.Curaga = sets.precast.FC.Cure
    sets.precast.FC['Elemental Magic'] = set_combine(sets.precast.FC.Cure, {ear2="Barkarole Earring"})
    sets.precast.FC.no_qm = set_combine(sets.precast.FC, {ammo="Sapience Orb",
        back=gear.MACape,ring1="Kishar Ring",waist="Shinjutsu-no-Obi +1"})
    sets.precast.FC.unlocked = {main="Musa",sub="Clerisy Strap",ammo="Impatiens",
        head="Pedagogy Mortarboard +3",neck="Orunmila's Torque",ear1="Malignance Earring",ear2="Etiolation Earring",
        body="Zendik Robe",hands="Academic's Bracers +3",ring1="Lebeche Ring",ring2="Medada's Ring",
        back="Perimede Cape",waist="Witful Belt",legs="Pinga Pants +1",feet=gear.mer_feet_fc}
    sets.precast.FC.sub_rdm = sets.precast.FC.unlocked
    sets.precast.FC.Impact = {ammo="Sapience Orb",
        head=empty,neck="Orunmila's Torque",ear1="Malignance Earring",ear2="Etiolation Earring",
        body="Twilight Cloak",hands="Academic's Bracers +3",ring1="Kishar Ring",ring2="Medada's Ring",
        back=gear.MACape,waist="Shinjutsu-no-Obi +1",legs="Pinga Pants +1",feet=gear.mer_feet_fc}
    sets.precast.FC.Impact.grim = set_combine(sets.precast.FC.Impact, {main="Musa",sub="Clerisy Strap",feet="Academic's Loafers +3"})
    sets.precast.FC.Impact.grim_qm = set_combine(sets.precast.FC.Impact.grim, {ammo="Impatiens",ring1="Lebeche Ring",waist="Witful Belt"})
    sets.impact = {head=empty,body="Twilight Cloak"}
    sets.dispelga = {main="Daybreak",sub="Ammurapi Shield"}
    sets.precast.FC.Dispelga = set_combine(sets.precast.FC, sets.dispelga)

    sets.precast.WS = {ammo="Oshasha's Treatise",
        head="Blistering Sallet +1",neck="Fotia Gorget",ear1="Telos Earring",ear2="Crepuscular Earring",
        body="Arbatel Gown +3",hands="Gazu Bracelets +1",ring1="Chirich Ring +1",ring2="Cacoethic Ring +1",
        back=gear.TPCape,waist="Fotia Belt",legs="Nyame Flanchard",feet="Arbatel Loafers +3"}
    sets.precast.WS['Black Halo'] = set_combine(sets.precast.WS, {})
    sets.precast.WS.Realmrazer = set_combine(sets.precast.WS, {})

    sets.precast.WS['Shell Crusher'] = {ammo="Amar Cluster",
        head="Blistering Sallet +1",neck="Null Loop",ear1="Moonshade Earring",ear2="Crepuscular Earring",
        body="Arbatel Gown +3",hands="Gazu Bracelets +1",ring1="Chirich Ring +1",ring2="Medada's Ring",
        back="Null Shawl",waist="Null Belt",legs="Arbatel Pants +3",feet="Arbatel Loafers +3"}
    sets.precast.WS.Shattersoul      = set_combine(sets.precast.WS['Shell Crusher'], {})
    sets.precast.WS.Brainshaker      = set_combine(sets.precast.WS['Shell Crusher'], {})

    sets.precast.WS['Rock Crusher'] = {ammo="Ghastly Tathlum +1",
        head="Arbatel Bonnet +3",neck="Sibyl Scarf",ear1="Malignance Earring",ear2="Regal Earring",
        body="Arbatel Gown +3",hands="Arbatel Bracers +3",ring1="Metamorph Ring +1",ring2="Medada's Ring",
        back=gear.NukeCape,waist="Orpheus's Sash",legs="Arbatel Pants +3",feet="Arbatel Loafers +3"}
    sets.precast.WS['Earth Crusher'] = set_combine(sets.precast.WS['Rock Crusher'], {ear2="Moonshade Earring"})
    sets.precast.WS.Starburst        = set_combine(sets.precast.WS['Earth Crusher'], {})
    sets.precast.WS.Sunburst         = sets.precast.WS.Starburst
    sets.precast.WS.Omniscience      = set_combine(sets.precast.WS['Rock Crusher'], {head="Pixie Hairpin +1",ring1="Archon Ring"})
    sets.precast.WS.Cataclysm        = set_combine(sets.precast.WS.Omniscience, {ear2="Moonshade Earring"})
    sets.precast.WS['Flash Nova']    = set_combine(sets.precast.WS['Rock Crusher'], {})
    sets.precast.WS['Aeolian Edge']  = set_combine(sets.precast.WS['Earth Crusher'], {})
    sets.precast.WS.Cyclone          = sets.precast.WS['Aeolian Edge']

    sets.precast.WS.Myrkr = {ammo="Psilomene",
        head="Amalric Coif +1",neck="Sanctity Necklace",ear1="Moonshade Earring",ear2="Etiolation Earring",
        body="Academic's Gown +3",hands="Nyame Gauntlets",ring1="Mephitas's Ring +1",ring2="Sangoma Ring",
        back="Tantalic Cape",waist="Shinjutsu-no-Obi +1",legs="Amalric Slops +1",feet="Amalric Nails +1"}

    ---- Midcast Sets ----
    sets.midcast.Cure = {main="Malignance Pole",sub="Khonsu",ammo="Pemphredo Tathlum",
        head="Vanya Hood",neck="Incanter's Torque",ear1="Calamitous Earring",ear2="Mendicant's Earring",
        body="Arbatel Gown +3",hands="Academic's Bracers +3",ring1="Kuchekula Ring",ring2="Defending Ring",
        back="Solemnity Cape",waist="Shinjutsu-no-Obi +1",legs="Academic's Pants +3",feet="Vanya Clogs"}
    sets.midcast.Curaga = sets.midcast.Cure
    sets.midcast.Cure.Locked = {ammo="Crepuscular Pebble",
        head="Vanya Hood",neck="Loricate Torque +1",ear1="Genmei Earring",ear2="Mendicant's Earring",
        body="Chironic Doublet",hands="Nyame Gauntlets",ring1="Warden's Ring",ring2="Defending Ring",
        back=gear.IdleCape,waist="Shinjutsu-no-Obi +1",legs="Arbatel Pants +3",feet="Vanya Clogs"}
    sets.midcast.Cure.Weather = {main="Chatoyant Staff",sub="Khonsu",ammo="Crepuscular Pebble",
        head="Vanya Hood",neck="Loricate Torque +1",ear1="Genmei Earring",ear2="Mendicant's Earring",
        body="Chironic Doublet",hands="Nyame Gauntlets",ring1="Patricius Ring",ring2="Defending Ring",
        back="Twilight Cape",waist="Hachirin-no-Obi",legs="Arbatel Pants +3",feet="Vanya Clogs"}
    sets.cmp_belt   = {waist="Shinjutsu-no-Obi +1"}
    sets.haste_belt = {waist="Cornelia's Belt"}
    sets.gishdubar  = {waist="Gishdubar Sash"}

    sets.midcast.Raise = {main="Malignance Pole",sub="Khonsu",ammo="Pemphredo Tathlum",
        head=gear.tel_head_enh,neck="Loricate Torque +1",ear1="Calamitous Earring",ear2="Gifted Earring",
        body="Zendik Robe",hands="Academic's Bracers +3",ring1="Mephitas's Ring +1",ring2="Medada's Ring",
        back=gear.MACape,waist="Cornelia's Belt",legs="Arbatel Pants +3",feet=gear.mer_feet_fc}
    sets.midcast.StatusRemoval = set_combine(sets.midcast.Raise, {})
    sets.midcast.Erase         = set_combine(sets.midcast.StatusRemoval, {waist="Cornelia's Belt"})
    sets.midcast.Cursna = {main="Malignance Pole",sub="Khonsu",ammo="Crepuscular Pebble",
        head="Hike Khat +1",neck="Malison Medallion",ear1="Malignance Earring",ear2="Lugalbanda Earring",
        body="Pedagogy Gown +3",hands="Pedagogy Bracers +3",ring1="Ephedra Ring",ring2="Menelaus's Ring",
        back=gear.MACape,waist="Cornelia's Belt",legs="Academic's Pants +3",feet="Vanya Clogs"}

    sets.midcast.FixedPotencyEnhancing = {main="Musa",sub="Khonsu",ammo="Crepuscular Pebble",
        head=gear.tel_head_enh,neck="Loricate Torque +1",ear1="Genmei Earring",ear2="Etiolation Earring",
        body="Pedagogy Gown +3",hands=gear.tel_hand_enh,ring1="Patricius Ring",ring2="Defending Ring",
        back=gear.IdleCape,waist="Embla Sash",legs=gear.tel_legs_enh,feet=gear.tel_feet_enh}
    sets.midcast.Storm     = set_combine(sets.midcast.FixedPotencyEnhancing, {feet="Pedagogy Loafers +3"})
    sets.midcast.Refresh   = set_combine(sets.midcast.FixedPotencyEnhancing, {head="Amalric Coif +1"})
    sets.midcast.Stoneskin = set_combine(sets.midcast.FixedPotencyEnhancing, {
        neck="Nodens Gorget",ear2="Earthcry Earring",waist="Siegel Sash",legs="Shedir Seraweels"})
    sets.midcast.Aquaveil = {main="Vadose Rod",sub="Ammurapi Shield",ammo="Crepuscular Pebble",
        head="Amalric Coif +1",neck="Loricate Torque +1",ear1="Genmei Earring",ear2="Etiolation Earring",
        body="Pedagogy Gown +3",hands=gear.tel_hand_enh,ring1="Patricius Ring",ring2="Defending Ring",
        back=gear.IdleCape,waist="Emphatikos Rope",legs="Shedir Seraweels",feet=gear.tel_feet_enh}
    sets.midcast['Enhancing Magic'] = {main="Musa",sub="Khonsu",ammo="Pemphredo Tathlum",
        head="Befouled Crown",neck="Incanter's Torque",ear1="Andoaa Earring",ear2="Mimir Earring",
        body="Pedagogy Gown +3",hands="Chironic Gloves",ring1="Stikini Ring +1",ring2="Defending Ring",
        back="Fi Follet Cape",waist="Olympus Sash",legs="Shedir Seraweels",feet="Regal Pumps +1"}
    sets.midcast.EnSpell = set_combine(sets.midcast['Enhancing Magic'], {hands=gear.tel_hand_enh,waist="Embla Sash"})
    sets.midcast.Embrava = set_combine(sets.midcast.FixedPotencyEnhancing, {ear2="Mimir Earring"})
    sets.midcast.Phalanx = set_combine(sets.midcast.Embrava, {hands=gear.mer_hand_phlx})
    sets.midcast.Phalanx.AoE = set_combine(sets.midcast.Embrava, {})
    sets.midcast.BarElement  = set_combine(sets.midcast.Embrava, {legs="Shedir Seraweels"})
    sets.midcast.BarStatus   = set_combine(sets.midcast.Embrava, {})
    sets.midcast.Regen = {main="Musa",sub="Khonsu",ammo="Crepuscular Pebble",
        head="Arbatel Bonnet +3",neck="Loricate Torque +1",ear1="Calamitous Earring",ear2="Gifted Earring",
        body=gear.tel_body_enh,hands=gear.tel_hand_enh,ring1="Patricius Ring",ring2="Defending Ring",
        back=gear.RegenCape,waist="Embla Sash",legs=gear.tel_legs_enh,feet=gear.tel_feet_enh}
    sets.midcast.Klimaform = set_combine(sets.midcast.Raise, {})

    sets.midcast['Elemental Magic'] = {main="Wizard's Rod",sub="Ammurapi Shield",ammo="Ghastly Tathlum +1",
        head="Pedagogy Mortarboard +3",neck="Argute Stole +2",ear1="Malignance Earring",ear2="Regal Earring",
        body="Arbatel Gown +3",hands="Amalric Gages +1",ring1="Freke Ring",ring2="Medada's Ring",
        back=gear.NukeCape,waist="Sacro Cord",legs="Arbatel Pants +3",feet="Arbatel Loafers +3"}
    sets.midcast['Elemental Magic'].MAcc  = set_combine(sets.midcast['Elemental Magic'], {
        hands="Arbatel Bracers +3",ring1="Metamorph Ring +1",waist="Acuity Belt +1"})
    sets.midcast['Elemental Magic'].LowMP = set_combine(sets.midcast['Elemental Magic'], {body="Seidr Cotehardie"})
    sets.midcast['Elemental Magic'].OA = {ammo="Seraphic Ampulla",
        head="Mallquis Chapeau +2",neck="Argute Stole +2",ear1="Telos Earring",ear2="Crepuscular Earring",
        body="Seidr Cotehardie",hands=gear.mer_hand_oa,ring1="Chirich Ring +1",ring2="Medada's Ring",
        back=gear.NukeCape,waist="Oneiros Rope",legs="Perdition Slops",feet=gear.mer_feet_oa}

    sets.midcast['Elemental Magic'].MB = {main="Wizard's Rod",sub="Ammurapi Shield",ammo="Ghastly Tathlum +1",
        head="Pedagogy Mortarboard +3",neck="Argute Stole +2",ear1="Malignance Earring",ear2="Static Earring",
        body="Agwu's Robe",hands="Arbatel Bracers +3",ring1="Mujin Band",ring2="Medada's Ring",
        back=gear.NukeCape,waist="Sacro Cord",legs="Arbatel Pants +3",feet="Arbatel Loafers +3"}
    sets.midcast['Elemental Magic'].MAcc.MB = set_combine(sets.midcast['Elemental Magic'].MB, {
        ammo="Pemphredo Tathlum",ring1="Metamorph Ring +1",waist="Acuity Belt +1"})
    sets.midcast['Elemental Magic'].LowMP.MB = set_combine(sets.midcast['Elemental Magic'].MB, {
        body="Seidr Cotehardie",legs="Agwu's Slops"})

    sets.marin = {main="Marin Staff +1",sub="Enki Strap"}
    sets.midcast['Elemental Magic'].Marin = set_combine(sets.midcast['Elemental Magic'],                   sets.marin)
    sets.midcast['Elemental Magic'].MB.Marin = set_combine(sets.midcast['Elemental Magic'].MB,             sets.marin)
    sets.midcast['Elemental Magic'].MAcc.MB.Marin = set_combine(sets.midcast['Elemental Magic'].MAcc.MB,   sets.marin)
    sets.midcast['Elemental Magic'].LowMP.MB.Marin = set_combine(sets.midcast['Elemental Magic'].LowMP.MB, sets.marin)

    sets.midcast.Helix = {main="Wizard's Rod",sub="Culminus",ammo="Ghastly Tathlum +1",
        head="Arbatel Bonnet +3",neck="Argute Stole +2",ear1="Malignance Earring",ear2="Regal Earring",
        body="Arbatel Gown +3",hands="Arbatel Bracers +3",ring1="Metamorph Ring +1",ring2="Medada's Ring",
        back=gear.NukeCape,waist="Sacro Cord",legs="Arbatel Pants +3",feet="Arbatel Loafers +3"}
    sets.midcast.Helix.MAcc = set_combine(sets.midcast.Helix, {main="Wizard's Rod",sub="Ammurapi Shield",waist="Acuity Belt +1"})
    sets.midcast.Helix.MB = set_combine(sets.midcast.Helix, {ear2="Static Earring",body="Agwu's Robe",back=gear.HDurCape})
    sets.midcast.Helix.MAcc.MB = set_combine(sets.midcast.Helix.MB, {main="Wizard's Rod",sub="Ammurapi Shield",waist="Acuity Belt +1"})
    sets.midcast.Helix.MB.Marin = set_combine(sets.midcast.Helix.MB, sets.marin)
    sets.midcast.Helix.NoDmg = {main="Malignance Pole",sub="Khonsu",ammo="Sapience Orb",
        head=empty,neck="Orunmila's Torque",ear1="Gifted Earring",ear2="Lugalbanda Earring",
        body=empty,hands="Gazu Bracelets +1",ring1="Shneddick Ring +1",ring2="Defending Ring",
        back=gear.IdleCape,waist="Cornelia's Belt",legs=empty,feet=empty}

    sets.midcast.LowTierNuke = sets.midcast.Helix
    sets.midcast.NoDmg = {main="Malignance Pole",sub="Khonsu",ammo="Homiliary",
        head=empty,neck="Warder's Charm +1",ear1="Genmei Earring",ear2="Lugalbanda Earring",
        body=empty,hands=empty,ring1="Shneddick Ring +1",ring2="Defending Ring",
        back=gear.IdleCape,waist="Null Belt",legs=empty,feet=empty}

    sets.midcast['Luminohelix'] = set_combine(sets.midcast.Helix, {main="Daybreak",sub="Culminus"})
    sets.midcast['Luminohelix'].MAcc = set_combine(sets.midcast.Helix.MAcc, {main="Daybreak",sub="Ammurapi Shield"})
    sets.midcast['Luminohelix'].MB = set_combine(sets.midcast.Helix.MB, {main="Daybreak",sub="Culminus"})
    sets.midcast['Luminohelix'].MAcc.MB = set_combine(sets.midcast.Helix.MAcc.MB, {main="Daybreak",sub="Ammurapi Shield"})
    sets.midcast['Luminohelix II'] = sets.midcast['Luminohelix']

    sets.midcast['Noctohelix'] = set_combine(sets.midcast.Helix, {head="Pixie Hairpin +1",ring1="Archon Ring"})
    sets.midcast['Noctohelix'].MAcc = set_combine(sets.midcast.Helix.MAcc, {head="Pixie Hairpin +1"})
    sets.midcast['Noctohelix'].MB = set_combine(sets.midcast.Helix.MB, {head="Pixie Hairpin +1",ring1="Archon Ring"})
    sets.midcast['Noctohelix'].MAcc.MB = set_combine(sets.midcast.Helix.MAcc.MB, {head="Pixie Hairpin +1"})
    sets.midcast['Noctohelix II'] = sets.midcast['Noctohelix']

    sets.midcast.Kaustra = {main="Wizard's Rod",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
        head="Pixie Hairpin +1",neck="Argute Stole +2",ear1="Malignance Earring",ear2="Static Earring",
        body="Agwu's Robe",hands="Arbatel Bracers +3",ring1="Archon Ring",ring2="Medada's Ring",
        back=gear.NukeCape,waist="Sacro Cord",legs="Arbatel Pants +3",feet="Arbatel Loafers +3"}
    sets.midcast.Kaustra.MAcc = set_combine(sets.midcast.Kaustra, {ring1="Metamorph Ring +1",waist="Acuity Belt +1"})

    sets.midcast.Impact    = set_combine(sets.midcast['Elemental Magic'].MAcc, sets.impact)
    sets.midcast.Impact.OA = set_combine(sets.midcast['Elemental Magic'].OA, sets.impact)
    sets.midcast.Impact.MB = set_combine(sets.midcast.Impact, {})

    sets.midcast.Banish = sets.midcast['Luminohelix']
    sets.midcast.Holy = sets.midcast.Banish

    sets.orpheus   = {waist="Orpheus's Sash"}
    sets.ele_obi   = {waist="Hachirin-no-Obi"}
    sets.ele_cape  = {back="Twilight Cape"}
    sets.ele_both  = {back="Twilight Cape",waist="Hachirin-no-Obi"}
    sets.nuke_belt = {waist="Sacro Cord"}
    sets.macc_belt = {waist="Acuity Belt +1"}

    sets.midcast.Drain = {main="Rubicundity",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
        head="Pixie Hairpin +1",neck="Erra Pendant",ear1="Malignance Earring",ear2="Barkarole Earring",
        body="Zendik Robe",hands="Gazu Bracelets +1",ring1="Evanescence Ring",ring2="Archon Ring",
        back=gear.MACape,waist="Fucho-no-Obi",legs="Pedagogy Pants +3",feet="Agwu's Pigaches"}
    sets.midcast.Drain.MAcc = {main="Rubicundity",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
        head="Academic's Mortarboard +3",neck="Erra Pendant",ear1="Malignance Earring",ear2="Regal Earring",
        body="Academic's Gown +3",hands="Arbatel Bracers +3",ring1="Evanescence Ring",ring2="Medada's Ring",
        back="Null Shawl",waist="Fucho-no-Obi",legs="Pedagogy Pants +3",feet="Agwu's Pigaches"}
    sets.midcast.Aspir = sets.midcast.Drain
    sets.drain_belt = {waist="Fucho-no-Obi"}

    sets.midcast['Enfeebling Magic'] = {main="Musa",sub="Khonsu",ammo="Pemphredo Tathlum",
        head="Academic's Mortarboard +3",neck="Null Loop",ear1="Malignance Earring",ear2="Regal Earring",
        body="Academic's Gown +3",hands="Academic's Bracers +3",ring1="Metamorph Ring +1",ring2="Medada's Ring",
        back="Null Shawl",waist="Null Belt",legs="Arbatel Pants +3",feet="Academic's Loafers +3"}
    sets.midcast.Dispel   = set_combine(sets.midcast['Enfeebling Magic'], {waist="Cornelia's Belt"})
    sets.midcast.Dispelga = set_combine(sets.midcast.Dispel, sets.dispelga)
    sets.midcast.Silence  = set_combine(sets.midcast['Enfeebling Magic'], {legs=gear.chir_legs_ma})
    sets.midcast.Slow     = set_combine(sets.midcast.Silence, {main="Daybreak",sub="Ammurapi Shield",
        head="Null Masque",neck="Argute Stole +2",back="Aurist's Cape +1",waist="Luminary Sash"})
    sets.midcast.Paralyze = sets.midcast.Slow

    --sets.midcast.Sleep = set_combine(sets.midcast['Enfeebling Magic'], {ring1="Kishar Ring",legs=gear.chir_legs_ma})
    sets.midcast.Sleep = set_combine(sets.midcast['Enfeebling Magic'], {ring1="Kishar Ring"})
    sets.midcast.Break   = sets.midcast.Sleep
    sets.midcast.Bind    = sets.midcast.Sleep
    sets.midcast.Gravity = sets.midcast.Sleep

    sets.midcast.ElementalEnfeeble = set_combine(sets.midcast['Enfeebling Magic'], {legs="Pedagogy Pants +3"})
    sets.midcast['Dark Magic']     = set_combine(sets.midcast.ElementalEnfeeble, {waist="Cornelia's Belt"})
    sets.midcast['Divine Magic']   = set_combine(sets.midcast['Dark Magic'], {})
    sets.midcast.Stun              = set_combine(sets.midcast['Dark Magic'], {back=gear.MACape})

    ---- Sets to return to when not performing an action ----
    sets.idle = {main="Malignance Pole",sub="Oneiros Grip",ammo="Homiliary",
        head=gear.mer_head_rf,neck="Sibyl Scarf",ear1="Eabani Earring",ear2="Lugalbanda Earring",
        body="Arbatel Gown +3",hands=gear.mer_hand_rf,ring1="Shneddick Ring +1",ring2="Defending Ring",
        back=gear.IdleCape,waist="Null Belt",legs=gear.mer_legs_rf,feet=gear.mer_feet_rf}
    sets.idle.PDT = {main="Akademos",sub="Oneiros Grip",ammo="Homiliary",
        head="Null Masque",neck="Warder's Charm +1",ear1="Eabani Earring",ear2="Lugalbanda Earring",
        body="Arbatel Gown +3",hands=gear.mer_hand_rf,ring1="Shneddick Ring +1",ring2="Defending Ring",
        back=gear.IdleCape,waist="Null Belt",legs="Arbatel Pants +3",feet=gear.mer_feet_rf}
    sets.idle.MRf = set_combine(sets.idle, {ring1="Stikini Ring +1"})
    sets.idle.MDT = set_combine(sets.idle, {head="Arbatel Bonnet +3",neck="Warder's Charm +1",ring1="Shadow Ring",legs="Arbatel Pants +3"})

    sets.idle.Subl = set_combine(sets.idle, {head="Academic's Mortarboard +3",body="Pedagogy Gown +3",waist="Embla Sash"})
    sets.idle.PDT.Subl = set_combine(sets.idle.PDT, {ammo="Crepuscular Pebble",head="Academic's Mortarboard +3",waist="Embla Sash"})
    sets.idle.MRf.Subl = set_combine(sets.idle.MRf, {head="Academic's Mortarboard +3",body="Pedagogy Gown +3",waist="Embla Sash"})
    sets.idle.MDT.Subl = set_combine(sets.idle.MDT, {head="Academic's Mortarboard +3",body="Pedagogy Gown +3",waist="Embla Sash"})

    sets.defense = sets.idle

    sets.latent_refresh = {waist="Fucho-no-obi"}
    sets.regain         = {head="Null Masque"}
    sets.sphere         = {body="Gyve Doublet"}
    sets.Kiting         = {ring1="Shneddick Ring +1"}

    sets.buff.doom  = {neck="Nicander's Necklace",ring1="Saida Ring",ring2="Defending Ring",waist="Gishdubar Sash"}
    sets.buff.sleep = {main="Opashoro",sub="Khonsu"}

    sets.engaged = {main="Malignance Pole",sub="Khonsu",ammo="Amar Cluster",
        head="Null Masque",neck="Null Loop",ear1="Telos Earring",ear2="Dignitary's Earring",
        body="Arbatel Gown +3",hands="Gazu Bracelets +1",ring1="Chirich Ring +1",ring2="Pernicious Ring",
        back="Null Shawl",waist="Null Belt",legs="Arbatel Pants +3",feet="Arbatel Loafers +3"}
    sets.engaged.PDef = set_combine(sets.engaged, {ring2="Defending Ring"})

    ---- Misc sets depending upon other sets ----
    sets.midcast.FastRecast = set_combine(sets.idle, {})
    sets.midcast.Dia        = set_combine(sets.idle, sets.TreasureHunter)
    sets.midcast.Bio        = set_combine(sets.midcast.Dia, {})
    sets.midcast.Stonega    = set_combine(sets.midcast.LowTierNuke, sets.TreasureHunter)
    sets.midcast.Stone      = set_combine(sets.midcast.LowTierNuke, sets.TreasureHunter)
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-- Run after the general precast() is done.
function job_post_precast(spell, action, spellMap, eventArgs)
    if spell.type == 'WeaponSkill' then
        if state.skillchain.name == '6step' and state.skillchain.trying == spell.english then
            equip(sets.naked)
        end
    elseif spell.action_type == 'Magic' then
        if spell.english == 'Impact' then
            if player.sub_job == 'RDM' and state.OffenseMode.value == 'None' then
                equip(sets.precast.FC.Impact.grim_qm)
            elseif player.sub_job == 'RDM' or state.OffenseMode.value == 'None' then
                equip(sets.precast.FC.Impact.grim)
            --else normal FC set
            end
        elseif state.Buff.Immanence and spell.skill == 'Elemental Magic' then
            equip(sets.precast.FC.no_qm)
        elseif player.sub_job == 'RDM' then
            equip(sets.precast.FC.sub_rdm)
            if spell.english == 'Dispelga' then
                equip(sets.dispelga)
            end
        elseif state.OffenseMode.value == 'None' and spell.english ~= 'Dispelga' then
            equip(sets.precast.FC.unlocked)
        --else normal FC sets
        end
    elseif spell.english == 'Light Arts' or spell.english == 'Addendum: White' then
        state.Buff['Dark Arts']       = false
        state.Buff['Addendum: Black'] = false
    elseif spell.english == 'Dark Arts'  or spell.english == 'Addendum: Black' then
        state.Buff['Light Arts']      = false
        state.Buff['Addendum: White'] = false
    end
end

-- Run after the default midcast() is done.
-- eventArgs is the same one used in job_midcast, in case information needs to be persisted.
function job_post_midcast(spell, action, spellMap, eventArgs)
    if spell.skill == 'Elemental Magic' and spellMap ~= 'ElementalEnfeeble' or spell.english == 'Kaustra' then
        if state.Buff.Immanence then
            equip(sets.weapons.Marin)
            if spellMap == 'Helix' then
                if not state.SCDmg.value or S{'Leshonn','Gartell'}:contains(spell.target.name) then
                    equip(sets.midcast.Helix.NoDmg)
                end
            elseif not state.SCDmg.value then
                equip(sets.midcast.NoDmg)
            elseif spell.english:endswith('III') then
                if state.OANuke.value or state.OASingle.value then
                    equip(sets.midcast['Elemental Magic'].OA)
                elseif state.CastingMode.value == 'MAcc' then
                    equip(resolve_ele_belt(spell, sets.ele_obi, sets.macc_belt, 5))
                else
                    equip(resolve_ele_belt(spell, sets.ele_obi, sets.nuke_belt, 3))
                end
            end
        else
            local spell_set = sets.midcast[spell.english] or sets.midcast[spellMap] or sets.midcast[spell.skill]

            if (state.OANuke.value or state.OASingle.value) and not (state.MagicBurst.value or state.MBSingle.value)
            and spell_set.OA then
                spell_set = spell_set.OA
            elseif state.SeidrNuke.value
            and spell_set.LowMP then
                spell_set = spell_set.LowMP
            elseif state.CastingMode.value == 'MAcc'
            and spell_set.MAcc then
                spell_set = spell_set.MAcc
            elseif state.AutoSeidr.value and not state.Buff['Parsimony'] and not buffactive['Sublimation: Complete']
            and player.mp - spell.mp_cost < state.AutoSeidr.low_mp
            and spell_set.LowMP then
                spell_set = spell_set.LowMP
            end

            if (state.MagicBurst.value or state.MBSingle.value) then
                spell_set = spell_set.MB or spell_set
            end

            if spell.element == 'Wind' then
                spell_set = spell_set.Marin or spell_set
            end

            equip(spell_set)

            if state.Buff['Ebullience'] then
                equip(sets.buff['Ebullience'])
            end
            if buffactive['Klimaform'] and spell.element == world.weather_element then
                equip(sets.buff['Klimaform'])
            end

            if not state.OANuke.value and not state.OASingle.value then
                if spellMap == 'Helix' then
                    equip(resolve_ele_belt(spell, nil,          sets.nuke_belt, 3))
                elseif state.CastingMode.value == 'MAcc' then
                    equip(resolve_ele_belt(spell, sets.ele_obi, sets.macc_belt, 5))
                else
                    equip(resolve_ele_belt(spell, sets.ele_obi, sets.nuke_belt, 3))
                end
            end
        end
    elseif spell.skill == 'Dark Magic' then
        if S{'Drain','Aspir'}:contains(spellMap) then
            equip(resolve_ele_belt(spell, sets.ele_obi, sets.drain_belt, 5))
        elseif spell.english == 'Stun' and state.Buff['Alacrity'] and world.weather_element == spell.element then
            equip(sets.buff['Alacrity'])
        end
    elseif S{'Cure','Curaga'}:contains(spellMap) then
        if spell.target.type == 'MONSTER' then
            equip(sets.midcast.LowTierNuke, resolve_ele_belt(spell, sets.ele_obi, sets.nuke_belt, 3))
        else
            if state.OffenseMode.value ~=' None' then
                equip(sets.midcast.Cure.Locked)
            elseif world.weather_element == 'Light' then
                equip(sets.midcast.Cure.Weather)
            end
            if spell.target.type == 'SELF' then
                equip(resolve_ele_belt(spell, sets.ele_obi, sets.gishdubar, 9))
            else
                equip(resolve_ele_belt(spell, sets.ele_obi, sets.cmp_belt, 2))
            end
        end
    elseif spell.skill == 'Enhancing Magic' then
        if state.Buff.Accession and spell.english == 'Phalanx' then
            equip(sets.midcast.Phalanx.AoE)
        end
        if state.Buff.Perpetuance then
            equip(sets.buff['Perpetuance'])
        end
    elseif spell.target.type == 'SELF' and spell.english == 'Cursna' then
        equip(sets.buff.doom)
    end
end

function job_aftercast(spell, action, spellMap, eventArgs)
    if spell.interrupted then
        --send_command('wait 0.5;gs c update')
        interrupted_message(spell)
    else
        if S{'JobAbility','Scholar'}:contains(spell.type) then
            -- prevent stratagem aftercast from clobbering the next spell
            eventArgs.handled = true
        elseif spell.english == 'Dia II' and state.DiaMsg.value then
            if spell.target.name and spell.target.type == 'MONSTER' then
                send_command('input /p Dia II /')
            end
        elseif spell.english == 'Impact' then
            debuff_timer(spell, 180)
        elseif spell.english == 'Repose' then
            debuff_timer(spell, 90)
        elseif spell.english == 'Break' or spell.english == 'Breakga' then
            debuff_timer(spell, 33)
        elseif spell.english == 'Sleep' or spell.english == 'Sleepga' then
            debuff_timer(spell, 66)
        elseif spell.english == 'Sleep II' or spell.english == 'Sleepga II' then
            debuff_timer(spell, 99)
        end

        if spell.skill == 'Elemental Magic' and spellMap ~= 'ElementalEnfeeble' then
            if state.OASingle.value then
                state.OASingle:reset()
                hud_update_on_state_change('OA (1)')
            elseif state.MBSingle.value and state.skillchain.trying ~= spell.english then
                state.MBSingle:reset()
                hud_update_on_state_change('MB (1)')
            end
        end
    end
    skillchain_state_updates(spell, action)
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
            if not buffactive['Sublimation: Activated'] then
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
    if spell.skill == 'Enhancing Magic' then
        if not S{'Regen','BarElement','BarStatus','StatusRemoval','Storm','EnSpell'}:contains(default_spell_map) then
            return "FixedPotencyEnhancing"
        end
    elseif spell.skill == 'Elemental Magic' then
        if S{'Stone','Stone II','Stonega','Water','Water II','Waterga',
             'Aero','Aero II','Aeroga','Fire','Fire II','Firaga',
             'Blizzard','Blizzard II','Blizzaga','Thunder','Thunder II','Thundaga'}:contains(spell.english) then
            return "LowTierNuke"
        end
    end
end

-- Modify the default idle set after it was constructed.
function customize_idle_set(idleSet)
    if buffactive['Sublimation: Activated'] then
        if state.DefenseMode.value == 'None' then
            idleSet = sets.idle.Subl
        else
            idleSet = sets.defense[state[state.DefenseMode.value.."DefenseMode"].value].Subl
        end
    else
        if state.OffenseMode.value ~= 'None' then
            idleSet = set_combine(idleSet, sets.regain)
        end
        if player.mpp < 51 then
            idleSet = set_combine(idleSet, sets.latent_refresh)
        end
    end

    if state.SphereIdle.value and state.DefenseMode.value ~= 'Physical' then
        idleSet = set_combine(idleSet, sets.sphere)
    end
    if S{'Western Adoulin','Eastern Adoulin'}:contains(world.area) then
        if player.wardrobe4["Councilor's Garb"]   then idleSet = set_combine(idleSet, {body="Councilor's Garb"}) end
    end
    if buffactive['Reive Mark'] then
        if player.wardrobe4["Arciela's Grace +1"] then idleSet = set_combine(idleSet, {neck="Arciela's Grace +1"}) end
    end
    if state.Buff.doom then
        idleSet = set_combine(idleSet, sets.buff.doom)
    end
    if state.Buff.sleep and not buffactive['Sublimation: Activated'] then
        idleSet = set_combine(idleSet, sets.buff.sleep)
    end
    return idleSet
end

-- Modify the default defense set after it was constructed.
function customize_defense_set(defenseSet)
    if buffactive['Sublimation: Activated'] then
        defenseSet = sets.defense[state[state.DefenseMode.value.."DefenseMode"].value].Subl
    elseif player.mpp < 51 then
        defenseSet = set_combine(defenseSet, sets.latent_refresh)
    end

    if state.SphereIdle.value and state.DefenseMode.value == 'Magical' then
        defenseSet = set_combine(defenseSet, sets.sphere)
    end

    if state.Buff.doom then
        defenseSet = set_combine(defenseSet, sets.buff.doom)
    end
    if state.Buff.sleep and not buffactive['Sublimation: Activated'] then
        defenseSet = set_combine(defenseSet, sets.buff.sleep)
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
    if state.Buff.doom then
        meleeSet = set_combine(meleeSet, sets.buff.doom)
    end
    if state.Buff.sleep and not buffactive['Sublimation: Activated'] then
        meleeSet = set_combine(meleeSet, sets.buff.sleep)
    end
    return meleeSet
end

-- Called by the 'update' self-command.
-- Set eventArgs.handled to true if we don't want automatic equipping of gear.
function job_update(cmdParams, eventArgs)
    if midaction() and cmdParams[1] == 'auto' then
        -- don't break midcast for state changes and such
        eventArgs.handled = true
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
    if player.sub_job == 'SCH' then
        if buffactive['Light Arts'] or buffactive['Addendum: White'] then
            msg = msg .. ' Light Arts'
        elseif buffactive['Dark Arts'] or buffactive['Addendum: Black'] then
            msg = msg .. ' Dark Arts'
        else
            msg = msg .. ' *No Grimoire*'
        end
    end
    if state.AutoSeidr.value then
        msg = msg .. ' AutoSeidr'
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
    report_ja_recasts(info.recast_ids, true)
    eventArgs.handled = true
end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements self-commands.
-------------------------------------------------------------------------------------------------------------------

-- Called for custom player commands.
function job_self_command(cmdParams, eventArgs)
    eventArgs.handled = true
    if cmdParams[1] == 'scholar' then
        handle_stratagems(cmdParams)
    elseif cmdParams[1] == 'sc' then
        skillchain_handle_command(cmdParams[2])
    elseif cmdParams[1] == 'ListWS' then
        info.ws_binds:print('ListWS:')
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
--    set_macro_page(1,4)
--end

-- returns a list for use with make_keybind_list
function job_keybinds()
    local bind_command_list = L{
        'bind !^l input /lockstyleset 4',
        'bind %`   gs c update user',
        'bind F9   gs c cycle OffenseMode',
        'bind !F9  gs c reset OffenseMode',
        'bind @F9  gs c cycle CombatWeapon',
        'bind !@F9 gs c cycleback CombatWeapon',
        'bind F10  gs c cycle CastingMode',
        'bind !F10 gs c reset CastingMode',
        'bind F11  gs c cycle IdleMode',
        'bind !F11 gs c reset IdleMode',
        'bind @F11 gs c toggle Kiting',
        'bind ^space  gs c cycle HybridMode',
        'bind !space  gs c set DefenseMode Physical',
        'bind @space  gs c set DefenseMode Magical',
        'bind !@space gs c reset DefenseMode',
        'bind @z      gs c cycle MagicalDefenseMode',
        'bind !w   gs c set OffenseMode Normal',
        'bind !@w  gs c set OffenseMode None',
        'bind ~!^q gs c set CombatWeapon Dagger',
        'bind !^q  gs c set CombatWeapon Marin',
        'bind !^w  gs c set CombatWeapon Musa',
        'bind !^e  gs c set CombatWeapon Pole',
        'bind ^z   gs c toggle SphereIdle',
        'bind !z   gs c toggle MagicBurst',
        'bind %z   gs c toggle MagicBurst',
        'bind ^c   gs c reset CastingMode',
        'bind ~^c  gs c set CastingMode MAcc',
        'bind ~^z  gs c toggle OANuke',
        'bind %~z  gs c toggle OASingle',
        'bind !@z  gs c toggle SeidrNuke',
        'bind ~!@z gs c toggle AutoSeidr',
        'bind !^c  gs c set SCMode Auto',
        'bind ~!^c gs c set SCMode Manual',
        'bind !@c  gs c sc restart',
        'bind ~!@c gs c sc reset',
        'bind !c gs c sc next', -- also sets SCMode to Manual
        'bind %c gs c sc next', -- also sets SCMode to Manual
        'bind ^\\\\  gs c toggle DiaMsg',
        'bind !\\\\  gs c toggle SCDmg',
        'bind @\\\\  gs c toggle SCHelix',
        'bind !^\\\\ gs c toggle SCHUD',

        'bind !^`   input /ja "Tabula Rasa <me>',
        'bind !@`   input /ja "Caper Emissarius" <t>',
        'bind !`    input /ja Libra',
        'bind ^@`   input /ja Enlightenment <me>',
        'bind !e    input /ja Sublimation <me>',
        'bind @tab  gs c scholar cost',
        'bind @q    gs c scholar speed',
        'bind ^@q   gs c scholar aoe',
        'bind ^@tab gs c scholar specialty',
        'bind @`    gs c scholar power',
        'bind ~^tab gs c scholar light',
        'bind ~^q   gs c scholar dark',

        'bind ^1  input /ma "Dia II"',
        'bind ^2  input /ma Slow',
        'bind ^3  input /ma Paralyze',
        'bind ^4  input /ma Silence',
        'bind ~^1 input /ma Break      <stnpc>',
        'bind ~^2 input /ma Sleep      <stnpc>',
        'bind ~^3 input /ma "Sleep II" <stnpc>',
        'bind ~^4 input /ma Silence    <stnpc>',

        'bind !1 input /ma "Cure III" <stpc>',
        'bind !2 input /ma "Cure IV"  <stpc>',
        'bind !3 input /ma "Regen V"',
        'bind !4 input /ma Adloquium',

        'bind @F1 input /ma Erase',
        'bind @1  input /ma Poisona',
        'bind @2  input /ma Paralyna',
        'bind @3  input /ma Blindna',
        'bind @4  input /ma Silena',
        'bind @5  input /ma Stona',
        'bind @6  input /ma Viruna',
        'bind @7  input /ma Cursna',

        'bind !f  input /ma Haste <me>',
        'bind @f  input /ma "Animus Augeo"',
        'bind !@f input /ma "Animus Minuo"',
        'bind !b  input /ma Klimaform <me>',
        'bind @g  input /ma "Ice Spikes" <me>',
        'bind !@g input /ma Stoneskin <me>',
        'bind @c  input /ma Blink <me>',
        'bind @v  input /ma Aquaveil <me>',
        'bind ~^x  input /ma Sneak     <me>',
        'bind ~!^x input /ma Invisible <me>',

        'bind ^tab input /ma Dispel',
        'bind ^q   input /ma Dispelga',

        'bind @d  input /ma "Aspir II"',
        'bind !@d input /ma "Aspir"',

        'bind ^backspace  input /ma Impact',
        'bind ~^backspace input /ma Kaustra',
        'bind !backspace  input /ma Embrava',

        'bind ^5 input /ma "Sandstorm II"',
        'bind ^6 input /ma "Rainstorm II"',
        'bind ^7 input /ma "Windstorm II"',
        'bind ^8 input /ma "Firestorm II"',
        'bind ^9 input /ma "Hailstorm II"',
        'bind ^0 input /ma "Thunderstorm II"',
        'bind ^- input /ma "Aurorastorm II"',
        'bind ^= input /ma "Voidstorm II"',

        'bind ^@1 gs c sc grav',
        'bind ^@2 gs c sc dist',
        'bind ^@3 gs c sc fusion',
        'bind ^@4 gs c sc frag',
        'bind ^@5 gs c sc earth',
        'bind ^@6 gs c sc water',
        'bind ^@7 gs c sc wind',
        'bind ^@8 gs c sc fire',
        'bind ^@9 gs c sc ice',
        'bind ^@0 gs c sc thunder',
        'bind ^@- gs c sc light',
        'bind ^@= gs c sc dark',

        'bind ~^@1 gs c sc grav-ws',
        'bind ~^@2 gs c sc dist-ws',
        'bind ~^@3 gs c sc fusion-ws',
        'bind ~^@4 gs c sc frag-ws',
        'bind ~^@5 gs c sc earth-ws',
        'bind ~^@6 gs c sc water-ws',
        'bind ~^@7 gs c sc wind-ws',
        'bind ~^@8 gs c sc fire-ws',
        'bind ~^@9 gs c sc ice-ws',
        'bind ~^@0 gs c sc thunder-ws',
        'bind ~^@- gs c sc light-ws',
        'bind ~^@= gs c sc dark-ws',

        'bind ~!^8 input /ma "Geohelix II"',
        'bind ~!^9 input /ma "Hydrohelix II"',
        'bind ~!^0 input /ma "Anemohelix II"',
        'bind ~^8  input /ma "Pyrohelix II"',
        'bind ~^9  input /ma "Cryohelix II"',
        'bind ~^0  input /ma "Ionohelix II"',
        'bind ~^-  input /ma "Luminohelix II"',
        'bind ~^=  input /ma "Noctohelix II"',

        'bind ~^6  input /ma "Poison II"',

        'bind ~@8 input /ma "Stone III"',
        'bind ~@9 input /ma "Water III"',
        'bind ~@0 input /ma "Aero III"',
        'bind @8  input /ma "Fire III"',
        'bind @9  input /ma "Blizzard III"',
        'bind @0  input /ma "Thunder III"',

        'bind ~!8 input /ma "Stone IV"',
        'bind ~!9 input /ma "Water IV"',
        'bind ~!0 input /ma "Aero IV"',
        'bind  !8 input /ma "Fire IV"',
        'bind  !9 input /ma "Blizzard IV"',
        'bind  !0 input /ma "Thunder IV"',

        'bind ~!@8 input /ma "Stone V"',
        'bind ~!@9 input /ma "Water V"',
        'bind ~!@0 input /ma "Aero V"',
        'bind  !@8 input /ma "Fire V"',
        'bind  !@9 input /ma "Blizzard V"',
        'bind  !@0 input /ma "Thunder V"',

        'bind %~8 input /ma "Stone V"',
        'bind %~9 input /ma "Water V"',
        'bind %~0 input /ma "Aero V"',
        'bind  %8 input /ma "Fire V"',
        'bind  %9 input /ma "Blizzard V"',
        'bind  %0 input /ma "Thunder V"'}

    if     player.sub_job == 'RDM' then
        bind_command_list:extend(L{
            'bind ~^@tab input /ja Convert <me>',
            'bind !@3 input /ma Distract',
            'bind !@4 input /ma Frazzle',
            'bind !5  input /ma Haste   <stpc>',
            'bind !6  input /ma Refresh <stpc>',
            'bind !7  input /ma Flurry  <stpc>',
            'bind !g  input /ma Phalanx',
            'bind !^d  input /ma Bind    <stnpc>',
            'bind ~!^d input /ma Gravity <stnpc>'})
    elseif player.sub_job == 'WHM' then
        bind_command_list:extend(L{
            'bind ^`  input /ja "Divine Seal" <me>',
            'bind !@1 input /ma Curaga',
            'bind !@2 input /ma "Curaga II"',
            'bind !5  input /ma Haste <stpc>',
            'bind !d  input /ma Flash',
            'bind !^d input /ma Repose <stnpc>'})
    elseif player.sub_job == 'BLM' then
        bind_command_list:extend(L{
            'bind ^`   input /ja "Elemental Seal" <me>',
            'bind !d   input /ma Stun',
            'bind !^d  input /ma Bind    <stnpc>',
            'bind ~!^d input /ma Sleepga <stnpc>'})
    elseif player.sub_job == 'DRK' then
        bind_command_list:extend(L{
            'bind !d  input /ma Stun',
            'bind !^d input /ma "Absorb-TP"'})
    end

    return bind_command_list
end

-- waiting for buffactive to update sucks
-- let's monkey patch a gearswap function to use state.Buff vars for enlightenment and addendums
-- (a similar approach may be feasible for quickly using stratagems after swapping arts)
function monkey_check_spell(available_spells,spell)
    -- Filter for spells that you do not know. Exclude Impact / Dispelga.
    local spell_jobs = copy_entry(res.spells[spell.id].levels)
    if not available_spells[spell.id] and not (spell.id == 503 or spell.id == 417 or spell.id == 360) then
        return false,"Unable to execute command. You do not know that spell ("..(res.spells[spell.id][language] or spell.id)..")"
    -- Filter for spells that you know, but do not currently have access to
    elseif (not spell_jobs[player.main_job_id] or not (spell_jobs[player.main_job_id] <= player.main_job_level or
        (spell_jobs[player.main_job_id] >= 100 and number_of_jps(player.job_points[__raw.lower(res.jobs[player.main_job_id].ens)]) >= spell_jobs[player.main_job_id]) ) ) and
        (not spell_jobs[player.sub_job_id] or not (spell_jobs[player.sub_job_id] <= player.sub_job_level)) and not (player.main_job_id == 23) then
        return false,"Unable to execute command. You do not have access to that spell ("..(res.spells[spell.id][language] or spell.id)..")"
    -- At this point, we know that it is technically castable by this job combination if the right conditions are met.
    elseif player.main_job_id == 20 and ((addendum_white[spell.id] and not state.Buff['Addendum: White'] and not state.Buff['Enlightenment']) or
        (addendum_black[spell.id] and not state.Buff['Addendum: Black'] and not state.Buff['Enlightenment'])) and
        not (spell_jobs[player.sub_job_id] and spell_jobs[player.sub_job_id] <= player.sub_job_level) then
        return false,"Unable to execute command. Addendum required for that spell ("..(res.spells[spell.id][language] or spell.id)..")"
    elseif player.sub_job_id == 20 and ((addendum_white[spell.id] and not state.Buff['Addendum: White'] and not state.Buff['Enlightenment']) or
        (addendum_black[spell.id] and not state.Buff['Addendum: Black'] and not state.Buff['Enlightenment'])) and
        not (spell_jobs[player.main_job_id] and (spell_jobs[player.main_job_id] <= player.main_job_level or
        (spell_jobs[player.main_job_id] >= 100 and number_of_jps(player.job_points[__raw.lower(res.jobs[player.main_job_id].ens)]) >= spell_jobs[player.main_job_id]) ) ) then
        return false,"Unable to execute command. Addendum required for that spell ("..(res.spells[spell.id][language] or spell.id)..")"
    elseif spell.type == 'BlueMagic' and not ((player.main_job_id == 16 and table.contains(windower.ffxi.get_mjob_data().spells,spell.id))
        or unbridled_learning_set[spell.english]) and
        not (player.sub_job_id == 16 and table.contains(windower.ffxi.get_sjob_data().spells,spell.id)) then
        -- This code isn't hurting anything, but it doesn't need to be here either.
        return false,"Unable to execute command. Blue magic must be set to cast that spell ("..(res.spells[spell.id][language] or spell.id)..")"
    elseif spell.type == 'Ninjutsu'  then
        if player.main_job_id ~= 13 and player.sub_job_id ~= 13 then
            return false,"Unable to make action packet. You do not have access to that spell ("..(spell[language] or spell.id)..")"
        elseif not player.inventory[tool_map[spell.english][language]] and not (player.main_job_id == 13 and player.inventory[universal_tool_map[spell.english][language]]) then
            return false,"Unable to make action packet. You do not have the proper tools."
        end
    end
    return true
end

-- monkey-patch filter_pretarget to pass all stratagems
function monkey_filter_pretarget(action)
    local category = outgoing_action_category_table[unify_prefix[action.prefix]]
    local bool = true
    local err
    if world.in_mog_house then
        msg.debugging("Unable to execute commands. Currently in a Mog House zone.")
        return false
    elseif category == 3 then
        local available_spells = windower.ffxi.get_spells()
        bool,err = check_spell(available_spells,action)
    elseif category == 7 then
        local available = windower.ffxi.get_abilities().weapon_skills
        if not table.contains(available,action.id) then
            bool,err = false,"Unable to execute command. You do not have access to that weapon skill."
        end
    elseif category == 9 and action.type ~= 'Scholar' then
        local available = windower.ffxi.get_abilities().job_abilities
        if not table.contains(available,action.id) then
            bool,err = false,"Unable to execute command. You do not have access to that job ability."
        end
    elseif category == 25 and (not player.main_job_id == 23 or not windower.ffxi.get_mjob_data().species or
        not res.monstrosity[windower.ffxi.get_mjob_data().species] or not res.monstrosity[windower.ffxi.get_mjob_data().species].tp_moves[action.id] or
        not (res.monstrosity[windower.ffxi.get_mjob_data().species].tp_moves[action.id] <= player.main_job_level)) then
        -- Monstrosity filtering
        msg.debugging("Unable to execute command. You do not have access to that monsterskill ("..(res.monster_skills[action.id][language] or action.id)..")")
        return false
    end

    if err then
        msg.debugging(err)
    end
    return bool
end

-- update state.skillchain with skillchain step and hud information
-- initialize state by calling with no arguments
-- call from job_aftercast to do updates
function skillchain_state_updates(spell, action)
    if action == 'init' or action == 'reset' then
        state.skillchain = {}
        state.skillchain.name = nil
        state.skillchain.list = nil
        state.skillchain.cur_step = 0
        state.skillchain.trying = nil
        state.skillchain.window_timer = nil
        if action == 'init' then
            -- set type and wait attributes for skillchain steps
            for sc in info.skillchains:it() do
                local len = sc.list:length()
                for i = 1, len do
                    if info.weaponskills[sc.list[i].action] then
                        if sc.list[i].action == 'Starburst' and player.sub_job == 'WHM' then
                            sc.list[i].action = 'Sunburst'
                        end
                        sc.list[i].type = 'ws'
                        if i ~= len then
                            sc.list[i].wait = info.sc_step_waits[sc.list[i].action] or 5
                        end
                    else -- a spell
                        sc.list[i].type = 'ma'
                        if i ~= len then
                            if info.sc_step_waits[sc.list[i].action] then
                                sc.list[i].wait = info.sc_step_waits[sc.list[i].action]
                            elseif sc.list[i].action:contains('helix') then
                                sc.list[i].wait = 4.5
                            else
                                sc.list[i].wait = 4
                            end
                        end
                    end

                    -- wait longer before stone or a ws
                    if i < len then
                        if     sc.list[i+1].type == 'ws' then
                            sc.list[i].wait = sc.list[i].wait + 1
                        elseif sc.list[i+1].action == 'Stone' then
                            sc.list[i].wait = sc.list[i].wait + 1
                        end
                    end
                end
            end
        end
    elseif action == 'start' then
        state.skillchain.name = spell
        state.skillchain.list = info.skillchains[spell].list
        state.skillchain.cur_step = 1
        state.skillchain.trying = nil
        state.skillchain.window_timer = nil
    elseif action == 'step' then
        if not state.skillchain.name or not state.skillchain.list or state.skillchain.trying == 'DONE' then return end
        local step = state.skillchain.list[state.skillchain.cur_step]
        if state.skillchain.trying == step.action then
            -- attempt next step
            if state.skillchain.cur_step < state.skillchain.list:length() then
                state.skillchain.cur_step = state.skillchain.cur_step + 1
                step = state.skillchain.list[state.skillchain.cur_step]
                state.skillchain.trying = (state.Buff.Immanence or step.type == 'ws') and step.action or 'Immanence'
            else
                state.skillchain.trying = 'DONE'
            end
        else
            -- first step, retry, or magic action after immanence
            state.skillchain.trying = (state.Buff.Immanence or step.type == 'ws') and step.action or 'Immanence'
        end

        if state.skillchain.trying ~= 'Immanence' then
            -- expired skillchains should be timed out, and window information is made available to the hud
            local window_length = 11 - state.skillchain.cur_step
            if state.skillchain.trying:contains('helix') then window_length = window_length + 1 end
            if state.skillchain.cur_step > 2             then window_length = window_length * 2 end  -- in case of missed aftercast
            state.skillchain.window_timer = os.time() + window_length
        end
    elseif action == 'aftercast' then
        if spell.english == state.skillchain.trying then
            if spell.interrupted then
                state.skillchain.trying = 'retry'
                state.SCMode:set('Manual')
                add_to_chat(121,'[%s] interrupted.':format(spell.english))
            elseif spell.english ~= 'Immanence' then
                local window_length = 11 - state.skillchain.cur_step
                if spell.english:contains('helix') then window_length = window_length + 1 end
                state.skillchain.window_timer = os.time() + window_length
                if state.skillchain.cur_step == state.skillchain.list:length() then
                    state.skillchain.trying = 'DONE'
                end
            end
        end
    end
end

-- called from job_self_command, eg, by //gs c sc autonext
function skillchain_handle_command(cmd)
    if cmd == 'next' then
        if state.SCMode.value == 'Manual' then
            if not state.skillchain.name then
                add_to_chat(123,'No skillchain queued.')
            elseif state.skillchain.trying == 'DONE' then
                add_to_chat(123,'Skillchain has completed.')
            elseif state.Buff['Dark Arts'] or state.Buff['Addendum: Black'] then
                if state.skillchain.window_timer and state.skillchain.window_timer + 5 < os.time() then
                    add_to_chat(123,'Skillchain window expired.')
                else
                    skillchain_step()
                end
            else
                add_to_chat(123,'Dark Arts not active.')
            end
        else
            state.SCMode:set('Manual')
        end
    elseif cmd == 'autonext' then
        if state.Buff['Dark Arts'] or state.Buff['Addendum: Black'] then
            if state.SCMode.value == 'Auto' and state.skillchain.trying ~= 'retry' then
                skillchain_step()
            end
        else
            state.SCMode:set('Manual')
            add_to_chat(123,'Dark Arts not active.')
        end
    elseif cmd == 'list' then
        add_to_chat(122,'Listing Skillchains:')
        for sc, name in info.skillchains:it() do
            local col = sc.list:with('type','ws') and 123 or 122
            add_to_chat(col,'[%s]: %s':format(name, sc.list:map(skillchain_step_to_string):concat(' ')))
        end
    elseif cmd == 'reset' then
        add_to_chat(121,'skillchain reset')
        skillchain_state_updates(nil, 'reset')
    elseif cmd == 'restart' then
        if state.skillchain.name then
            skillchain_handle_command(state.skillchain.name)
        else
            add_to_chat(123,'no skillchain to restart')
        end
    elseif info.skillchains[cmd] then
        if state.Buff['Dark Arts'] or state.Buff['Addendum: Black'] then
            local sc = cmd
            if sc == '6step' then
                state.SCDmg:unset()
            elseif sc:endswith('-ws') then
                if state.CombatWeapon.value == 'Dagger' then
                    sc = sc:gsub('-ws$','-dag')
                end
            end
            if state.SCHelix.value and info.skillchains['h-'..sc] then
                sc = 'h-'..sc
            elseif state.SCDmg.value and info.skillchains['t3-'..sc] then
                sc = 't3-'..sc
            end
            skillchain_state_updates(sc, 'start')
            add_to_chat(121,'queuing [%s]: %s':format(sc, state.skillchain.list:map(skillchain_step_to_string):concat(' ')))

            if state.SCMode.value == 'Auto' then
                if state.skillchain.list:with('type','ws') and (state.OffenseMode.value == 'None' or player.tp < 1000) then
                    add_to_chat(123,'aborting [%s]; need tp':format(sc))
                else
                    skillchain_step()
                end
            end
        else
            add_to_chat(123,'Dark Arts not active.')
        end
    else
        add_to_chat(123,'Error: Unknown skillchain ['..cmd..']')
    end
end

-- attempts to take a skillchain step, controlled by values in state.skillchain
function skillchain_step()
    if state.skillchain.name and 1 <= state.skillchain.cur_step and state.skillchain.cur_step <= state.skillchain.list:length() then
        skillchain_state_updates(nil, 'step')
        if state.skillchain.trying == 'DONE' then return end
        local step = state.skillchain.list[state.skillchain.cur_step]
        local action_type = state.skillchain.trying == 'Immanence' and 'ja' or step.type or 'ma'
        send_command('input /%s "%s"':format(action_type, state.skillchain.trying))

        if state.skillchain.list:length() == 2 and state.skillchain.trying ~= 'Immanence' then
            local skillchain_logname = info.skillchains[state.skillchain.name].name
            if state.skillchain.cur_step == 1 then
                send_command('input /p Opening %s, please hold.':format(skillchain_logname))
            else
                send_command('input /p %s! MB':format(skillchain_logname))
            end
        end

        if state.SCMode.value == 'Auto' then
            if state.skillchain.trying == 'Immanence' then
                send_command('wait %.1f; gs c sc autonext':format(0.9))
            elseif step.wait then
                send_command('wait %.1f; gs c sc autonext':format(step.wait))
            end
        end
    end
end

function skillchain_step_to_string(step)
    if step.wait then
        return '"%s" (wait %.1f)':format(step.action, step.wait)
    else
        return '"%s"':format(step.action)
    end
end

function init_state_text()
    if hud then return end

    local mb_text_settings    = {flags={draggable=false,bold=true},text={stroke={width=2}}}
    local oa_text_settings    = {pos={y=18},flags={draggable=false,bold=true},text={stroke={width=2}}}
    local sn_text_settings    = {pos={y=36},flags={draggable=false,bold=true},text={stroke={width=2}}}
    local ally_text_settings  = {pos={x=-178},flags={draggable=false,right=true,bold=true},bg={alpha=200},text={font='Courier New',size=10}}
    local cmode_text_settings = {pos={y=54},flags={draggable=false,bold=true},bg={red=0,green=220,blue=220,alpha=150},text={stroke={width=2}}}
    local hyb_text_settings   = {pos={x=130,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local def_text_settings   = {pos={x=172,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local off_text_settings   = {pos={x=172,y=697},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local sc_text_settings    = {pos={x=1000,y=697},flags={draggable=false,bold=true},
                                 bg={alpha=150},padding=1,text={font='Courier New',size=10,stroke={width=2}}}

    hud = {texts=T{}}
    hud.texts.mb_text    = texts.new('MBurst',         mb_text_settings)
    hud.texts.oa_text    = texts.new('OA Nuke',        oa_text_settings)
    hud.texts.sn_text    = texts.new('Seidr',          sn_text_settings)
    hud.texts.ally_text  = texts.new('AllyCure',       ally_text_settings)
    hud.texts.cmode_text = texts.new('initializing..', cmode_text_settings)
    hud.texts.hyb_text   = texts.new('initializing..', hyb_text_settings)
    hud.texts.def_text   = texts.new('initializing..', def_text_settings)
    hud.texts.off_text   = texts.new('initializing..', off_text_settings)
    hud.texts.sc_text    = texts.new('initializing..', sc_text_settings)

    -- update infrequently changing text boxes in job_state_change or where they are changed
    function hud_update_on_state_change(stateField)
        if not hud then init_state_text() end

        if not stateField or stateField == 'MB Mode' or stateField == 'MB (1)' then
            hud.texts.mb_text:visible(state.MagicBurst.value or state.MBSingle.value)
            if state.MBSingle.value then
                hud.texts.mb_text:bg_color(250, 200, 0)
            else
                hud.texts.mb_text:bg_color(200, 150, 150)
            end
        end

        if not stateField or stateField == 'OA Mode' or stateField == 'OA (1)' then
            hud.texts.oa_text:visible(state.OANuke.value or state.OASingle.value)
            if state.OANuke.value then
                hud.texts.oa_text:bg_color(150, 200, 150)
            else
                hud.texts.oa_text:bg_color(0, 250, 200)
            end
        end

        if not stateField or stateField == 'Seidr Nukes' or stateField == 'Seidr Auto' then
            hud.texts.sn_text:visible(state.SeidrNuke.value or state.AutoSeidr.value)
            if state.SeidrNuke.value then
                hud.texts.sn_text:bg_color(50, 50, 200)
            else
                hud.texts.sn_text:bg_color(0, 150, 0)
            end
        end

        if not stateField or stateField == 'Ally Cure Keybinds' then
            hud.texts.ally_text:visible(state.AllyBinds.value)
        end

        if not stateField or stateField == 'Casting Mode' then
            if state.CastingMode.value ~= 'Normal' then
                hud.texts.cmode_text:text(state.CastingMode.value)
                hud.texts.cmode_text:show()
            else hud.texts.cmode_text:hide() end
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
    local counter, interval = 15, 15 -- only update skillchain text every <interval> frames
    function hud_update_on_prerender()
        counter = counter + 1
        if counter >= interval and state.SCHUD.value then
            counter = 0
            if not areas.Cities:contains(world.area) and (state.Buff['Dark Arts'] or state.Buff['Addendum: Black']) then
                local text = "(%s Mode)":format(state.SCMode.value)
                if not state.SCDmg.value then text = text .. " [NODMG]" end

                local open = true
                local time_remaining = nil
                if not state.skillchain.name then
                    open = false
                elseif state.skillchain.window_timer then
                    time_remaining = state.skillchain.window_timer - os.time()
                    if time_remaining < -5 then
                        open = false
                    end
                -- else just starting
                end

                if not open then
                    hud.texts.sc_text:bg_color(0,0,0)
                else
                    local time_str = ""
                    local try_str = ""

                    if state.skillchain.trying == 'DONE' then
                        hud.texts.sc_text:bg_color(0,0,150)
                        try_str = "MB!"
                    else
                        if state.SCMode.value == 'Auto'   then
                            hud.texts.sc_text:bg_color(0,200,0)
                        elseif state.SCMode.value == 'Manual' then
                            hud.texts.sc_text:bg_color(200,200,0)
                        end

                        if state.skillchain.trying then
                            local next_str = ""

                            if state.skillchain.trying == 'retry' or state.skillchain.trying == 'Immanence' then
                                next_str = " (next: %s)":format(state.skillchain.list[state.skillchain.cur_step].action)
                            elseif state.skillchain.cur_step < state.skillchain.list:length() then
                                next_str = " (next: %s)":format(state.skillchain.list[state.skillchain.cur_step+1].action)
                            end

                            try_str = "try: %s [%d/%d]%s":format(
                                state.skillchain.trying, state.skillchain.cur_step, state.skillchain.list:length(), next_str)
                        elseif state.skillchain.cur_step == 1 then
                            try_str = "first: %s [1/%d] (next: %s)":format(
                                state.skillchain.list[1].action, state.skillchain.list:length(), state.skillchain.list[2].action)
                        end
                    end

                    if time_remaining then
                        if time_remaining >= 0 then
                            time_str = "[0:%02d]":format(time_remaining)
                        else
                            time_str = "[closed]"
                            hud.texts.sc_text:bg_color(255,0,0)
                        end
                    end

                    text = "[%s] %s\n%-8s %s":format(state.skillchain.name, text, time_str, try_str)
                end

                hud.texts.sc_text:text(text)
                hud.texts.sc_text:show()
            else
                hud.texts.sc_text:hide()
            end
        elseif not state.SCHUD.value then
            hud.texts.sc_text:hide()
        end
    end

    hud.prerender_event_id = windower.raw_register_event('prerender', hud_update_on_prerender)
end
