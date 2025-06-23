-- Modified from 'https://github.com/Kinematics/GearSwap-Jobs/blob/master/WHM.lua'

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
    state.Buff['Divine Caress']   = buffactive['Divine Caress'] or false
    state.Buff['Light Arts']      = buffactive['Light Arts'] or false
    state.Buff['Addendum: White'] = buffactive['Addendum: White'] or false
    state.Buff['Dark Arts']       = buffactive['Dark Arts'] or false
    state.Buff['Addendum: Black'] = buffactive['Addendum: Black'] or false
    state.Buff['Sublimation: Activated'] = buffactive['Sublimation: Activated'] or false
    state.Buff.doom = buffactive.doom or false
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
    state.WeaponskillMode:options('Normal','Acc','NoDmg')
    state.CastingMode:options('Normal','Enmity')                        -- Cycle with F10
    state.IdleMode:options('Normal','PDT','MEVA','Rf')                  -- Cycle with F11, set to PDT with ^F11, reset with !F11
    state.PhysicalDefenseMode:options('PDT','KB')                       -- Cycle with !@z
    state.MagicalDefenseMode:options('MRf','MEVA')                      -- Cycle with @z
    state.CombatWeapon = M{['description']='Combat Weapon'}
    if S{'DNC','NIN'}:contains(player.sub_job) then
        state.CombatWeapon:options('YagTP','MaxTP','DayTP','YagAsc','MaxAsc','DayAsc','Staff')
		state.CombatForm:set('DW')
    else
        state.CombatWeapon:options('Yagrush','Maxentius','Daybreak','Staff')
		state.CombatForm:reset()
    end

    state.WSMsg  = M(false, 'WS Message')                               -- Toggle with ^\
    state.DiaMsg = M(false, 'Dia Message')                              -- Toggle with ^@\
    state.AriseTold = M{['description']='Arise Tells',['string']=''}    -- Holds name of last person pestered to avoid spamming.
    state.AllyBinds = M(false, 'Ally Cure Keybinds')                    -- Toggle with !^delete
    state.MagicBurst = M(false, 'Magic Burst')                          -- Toggle with !z
    state.SphereIdle = M(false, 'Sphere Idle')                          -- Toggle with ^z
    init_state_text()
    hud_update_on_state_change()

    info.magic_ws = S{'Shining Strike','Seraph Strike','Flash Nova','Rock Crusher','Earth Crusher','Starburst','Sunburst','Cataclysm'}

    -- Mote-libs handle obis, gorgets, and other elemental things.
    -- These are default fallbacks if situationally appropriate gear is not available.
    gear.default.obi_waist = "Sacro Cord"                   -- used in Cure/Divine/Dark sets (overriden for cures in job_post_midcast)

    -- Augmented items get variables for convenience and specificity
    gear.FCCape   = {name="Alaunus's Cape", augments={'"Fast Cast"+10'}}
    gear.ENMCape  = {name="Alaunus's Cape", augments={'MND+20','Mag. Acc+20 /Mag. Dmg.+20','Enmity-10'}}
    gear.MEVACape = {name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','Enmity+10'}}
    gear.TPCape   = {name="Alaunus's Cape", augments={'DEX+20','Accuracy+20 Attack+20','"Store TP"+10'}}
    gear.TPCapeDW = {name="Alaunus's Cape", augments={'DEX+20','Accuracy+20 Attack+20','"Dual Wield"+10'}}
    gear.WSCape   = {name="Alaunus's Cape", augments={'MND+20','Accuracy+20 Attack+20','Weapon skill damage +10%'}}
    gear.chir_feet_ma = {name="Chironic Slippers", augments={'"Mag.Atk.Bns."+30','Mag. Acc.+14 "Mag.Atk.Bns."+14'}}
    gear.chir_feet_th = {name="Chironic Slippers", augments={'"Treasure Hunter"+1',}}
    gear.Lstikini = {name="Stikini Ring +1", bag="wardrobe2"}
    gear.Rstikini = {name="Stikini Ring +1", bag="wardrobe3"}

    info.keybinds = make_keybind_list(job_keybinds())
    info.keybinds:bind()

    info.ally_keybinds = make_keybind_list(L{
        'bind %~delete    input /ma "Cure IV" <p0>',
        'bind %~end       input /ma "Cure IV" <p1>',
        'bind %~pagedown  input /ma "Cure IV" <p2>',
        'bind %~insert    input /ma "Cure IV" <p3>',
        'bind %~home      input /ma "Cure IV" <p4>',
        'bind %~pageup    input /ma "Cure IV" <p5>',
        'bind ^delete     input /ma "Cure IV" <a10>',
        'bind ^end        input /ma "Cure IV" <a11>',
        'bind ^pagedown   input /ma "Cure IV" <a12>',
        'bind ^insert     input /ma "Cure IV" <a13>',
        'bind ^home       input /ma "Cure IV" <a14>',
        'bind ^pageup     input /ma "Cure IV" <a15>',
        'bind !delete     input /ma "Cure IV" <a20>',
        'bind !end        input /ma "Cure IV" <a21>',
        'bind !pagedown   input /ma "Cure IV" <a22>',
        'bind !insert     input /ma "Cure IV" <a23>',
        'bind !home       input /ma "Cure IV" <a24>',
        'bind !pageup     input /ma "Cure IV" <a25>',
        'bind %~^delete   input /ma "Cure V" <p0>',
        'bind %~^end      input /ma "Cure V" <p1>',
        'bind %~^pagedown input /ma "Cure V" <p2>',
        'bind %~^insert   input /ma "Cure V" <p3>',
        'bind %~^home     input /ma "Cure V" <p4>',
        'bind %~^pageup   input /ma "Cure V" <p5>',
        'bind ^@delete    input /ma "Cure V" <a10>',
        'bind ^@end       input /ma "Cure V" <a11>',
        'bind ^@pagedown  input /ma "Cure V" <a12>',
        'bind ^@insert    input /ma "Cure V" <a13>',
        'bind ^@home      input /ma "Cure V" <a14>',
        'bind ^@pageup    input /ma "Cure V" <a15>',
        'bind !@delete    input /ma "Cure V" <a20>',
        'bind !@end       input /ma "Cure V" <a21>',
        'bind !@pagedown  input /ma "Cure V" <a22>',
        'bind !@insert    input /ma "Cure V" <a23>',
        'bind !@home      input /ma "Cure V" <a24>',
        'bind !@pageup    input /ma "Cure V" <a25>'})
    send_command('bind !^delete gs c toggle AllyBinds')

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
    info.ws_binds:bind(state.CombatWeapon)
    send_command('bind %\\\\  gs c ListWS')

    info.recast_ids = L{{name="Sacro",id=33},{name="D.Seal",id=26},{name="Devotion",id=28}}
    if     player.sub_job == 'SCH' then
        info.recast_ids:append({name="Strats",id=231})
    elseif player.sub_job == 'RDM' then
        info.recast_ids:append({name="Convert",id=49})
    elseif player.sub_job == 'BLM' then
        info.recast_ids:append({name="E.Seal",id=38})
    end

    --select_default_macro_book()
end

-- Called when this job file is unloaded (eg: job change)
function user_unload()
    info.keybinds:unbind()

    if state.AllyBinds.value then info.ally_keybinds:unbind() end
    send_command('unbind !^delete')

    info.ws_binds:unbind()
    send_command('unbind %\\\\')

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
    sets.weapons.Staff     = {main="Xoanon",sub="Bloodrain Strap"}
    sets.TreasureHunter = {ammo="Perfect Lucky Egg",head="Volte Cap",waist="Chaac Belt",feet=gear.chir_feet_th}

    -- Precast Sets

    sets.precast.Step = {ammo="Amar Cluster",
        head="Null Masque",neck="Null Loop",ear1="Crepuscular Earring",ear2="Telos Earring",
        body="Ayanmo Corazza +2",hands="Ayanmo Manopolas +2",ring1="Ilabrat Ring",ring2="Ephramad's Ring",
        back=gear.TPCape,waist="Null Belt",legs="Ayanmo Cosciales +2",feet="Ayanmo Gambieras +2"}
    sets.precast.JA['Violent Flourish'] = set_combine(sets.precast.Step, {ring1="Etana Ring"})

    sets.precast.FC = {main="Asclepius",sub="Chanter's Shield",ammo="Sapience Orb",
        head="Ebers Cap +3",neck="Cleric's Torque +2",ear1="Malignance Earring",ear2="Loquacious Earring",
        body="Inyanga Jubbah +2",hands="Fanatic Gloves",ring1="Lebeche Ring",ring2="Kishar Ring",
        back=gear.FCCape,waist="Witful Belt",legs="Ayanmo Cosciales +2",feet="Telchine Pigaches"}
    sets.precast.FC['Healing Magic'] = set_combine(sets.precast.FC, {ammo="Impatiens",
        back="Perimede Cape",waist="Witful Belt",legs="Ebers Pantaloons +3"})
    sets.precast.FC.StatusRemoval = set_combine(sets.precast.FC['Healing Magic'], {main="Yagrush",sub="Ammurapi Shield"})
    sets.precast.FC.CureCheat = {main="Yagrush",sub="Genmei Shield",ammo="Sapience Orb",
        head="Piety Cap",neck="Cleric's Torque +2",ear1="Malignance Earring",ear2="Mendicant's Earring",
        body=empty,hands="Volte Gloves",ring1="Lebeche Ring",ring2="Kishar Ring",
        back=gear.FCCape,waist="Embla Sash",legs="Ebers Pantaloons +3",feet=empty}
    sets.impact = {head=empty,body="Twilight Cloak"}
    sets.precast.FC.Impact = set_combine(sets.precast.FC, sets.impact)
    sets.dispelga = {main="Daybreak",sub="Ammurapi Shield"}
    sets.precast.FC.Dispelga = set_combine(sets.precast.FC, sets.dispelga)

    sets.precast.JA.Devotion = {head="Piety Cap"}
    sets.precast.JA.Benediction = {body="Piety Bliaut +3"}

    sets.precast.WS = {ammo="Oshasha's Treatise",
        head="Bunzi's Hat",neck="Fotia Gorget",ear1="Moonshade Earring",ear2="Telos Earring",
        body="Nyame Mail",hands="Nyame Gauntlets",ring1="Ilabrat Ring",ring2="Ephramad's Ring",
        back=gear.WSCape,waist="Fotia Belt",legs="Nyame Flanchard",feet="Nyame Sollerets"}
    sets.precast.WS['Hexa Strike'] = set_combine(sets.precast.WS, {
        head="Blistering Sallet +1",ear1="Crepuscular Earring",ring1="Begrudging Ring",back=gear.TPCape})
    sets.precast.WS['Mystic Boon'] = set_combine(sets.precast.WS, {
        head="Nyame Helm",ring1="Epaminondas's Ring",waist="Null Belt"})
    sets.precast.WS['Black Halo']  = set_combine(sets.precast.WS, {
        head="Nyame Helm",ear2="Regal Earring",ring1="Epaminondas's Ring"})
    sets.precast.WS['Brainshaker'] = set_combine(sets.precast.WS, {
        head="Null Masque",neck="Null Loop",back="Null Shawl",waist="Null Belt"})
    sets.precast.WS['Shell Crusher'] = set_combine(sets.precast.WS['Brainshaker'], {})
    sets.precast.WS['Flash Nova'] = set_combine(sets.precast.WS, {ammo="Sroda Tathlum",
        head="Nyame Helm",neck="Sibyl Scarf",ear1="Malignance Earring",ear2="Friomisi Earring",
        ring1="Epaminondas's Ring",ring2="Freke Ring",waist=gear.ElementalObi})
    sets.precast.WS['Earth Crusher'] = set_combine(sets.precast.WS['Flash Nova'], {ear1="Moonshade Earring"})
    sets.precast.WS['Cataclysm'] = set_combine(sets.precast.WS['Earth Crusher'], {
        head="Pixie Hairpin +1",ring1="Epaminondas's Ring",ring2="Archon Ring"})

    -- Midcast Sets

    sets.midcast.Cure = {main="Queller Rod",sub="Genmei Shield",ammo="Staunch Tathlum +1",
        head="Ebers Cap +3",neck="Cleric's Torque +2",ear1="Glorious Earring",ear2="Mendicant's Earring",
        body="Theophany Bliaut +3",hands="Ebers Mitts +3",ring1="Shadow Ring",ring2="Defending Ring",
        back=gear.ENMCape,waist=gear.ElementalObi,legs="Ebers Pantaloons +3",feet="Ebers Duckbills +3"}
    sets.midcast.Curaga = set_combine(sets.midcast.Cure, {})
    sets.midcast.CureSolace = set_combine(sets.midcast.Cure, {body="Ebers Bliaut +3"})
    sets.midcast.Cure.Melee = set_combine(sets.midcast.Cure, {body="Chironic Doublet"})
    sets.midcast.Curaga.Melee = set_combine(sets.midcast.Cure.Melee, {})
    sets.midcast.CureSolace.Melee = set_combine(sets.midcast.Cure.Melee, {
        body="Ebers Bliaut +3",ring1="Vocane Ring +1",feet="Medium's Sabots"})
    sets.midcast.Cure.Enmity = {main="Mafic Cudgel",sub="Genmei Shield",ammo="Staunch Tathlum +1",
        head="Ebers Cap +3",neck="Unmoving Collar +1",ear1="Cryptic Earring",ear2="Trux Earring",
        body="Chironic Doublet",hands="Telchine Gloves",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.MEVACape,waist="Kasiri Belt",legs="Ebers Pantaloons +3",feet="Inyanga Crackows +2"}
    sets.midcast.Curaga.Enmity = set_combine(sets.midcast.Cure.Enmity, {})
    sets.midcast.CureSolace.Enmity = set_combine(sets.midcast.Cure.Enmity, {})
    sets.midcast.CureCheat = {main="Asclepius",sub="Ammurapi Shield",ammo="Staunch Tathlum +1",
        head="Theophany Cap +3",neck="Nodens Gorget",ear1="Glorious Earring",ear2="Etiolation Earring",
        body="Chironic Doublet",hands="Telchine Gloves",ring1="Vocane Ring +1",ring2="Defending Ring",
        back="Moonbeam Cape",waist="Platinum Moogle Belt",legs="Ebers Pantaloons +3",feet="Nyame Sollerets"}
    sets.midcast.CureCheat.Enmity = set_combine(sets.midcast.CureCheat, {main="Asclepius",sub="Genmei Shield",
        head="Ebers Cap +3",neck="Unmoving Collar +1",ear1="Cryptic Earring",feet="Theophany Duckbills +3"})
    sets.cmp_belt  = {waist="Shinjutsu-no-Obi +1"}
    sets.gishdubar = {waist="Gishdubar Sash"}

    sets.midcast.StatusRemoval = {main="Yagrush",sub="Genmei Shield",head="Ebers Cap +3",legs="Ebers Pantaloons +3"}
    sets.midcast.Erase = set_combine(sets.midcast.StatusRemoval, {neck="Cleric's Torque +2"})
    sets.midcast.Raise = {main="Asclepius",sub="Genmei Shield",ammo="Pemphredo Tathlum",
        head="Vanya Hood",neck="Loricate Torque +1",ear1="Malignance Earring",ear2="Mendicant's Earring",
        body="Inyanga Jubbah +2",hands="Fanatic Gloves",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.MEVACape,waist="Shinjutsu-no-Obi +1",legs="Ayanmo Cosciales +2",feet="Medium's Sabots"}
    sets.midcast.Reraise = set_combine(sets.midcast.Raise, {})
    sets.midcast.Esuna   = set_combine(sets.midcast.Raise, {})
    sets.buff['Divine Caress'] = {hands="Ebers Mitts +3",back="Mending Cape"}
    sets.midcast.Cursna = {main="Yagrush",sub="Genmei Shield",ammo="Staunch Tathlum +1",
        head="Ebers Cap +3",neck="Debilis Medallion",ear1="Glorious Earring",ear2="Ebers Earring +1",
        body="Ebers Bliaut +3",hands="Fanatic Gloves",ring1="Haoma's Ring",ring2="Haoma's Ring",
        back=gear.FCCape,waist="Cornelia's Belt",legs="Theophany Pantaloons +3",feet="Vanya Clogs"}

    sets.midcast.EnhancingDuration = {main="Gada",sub="Ammurapi Shield",ammo="Staunch Tathlum +1",
        head="Telchine Cap",neck="Loricate Torque +1",ear1="Genmei Earring",ear2="Etiolation Earring",
        body="Telchine Chasuble",hands="Telchine Gloves",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.MEVACape,waist="Embla Sash",legs="Telchine Braconi",feet="Theophany Duckbills +3"}
    sets.midcast['Enhancing Magic'] = set_combine(sets.midcast.EnhancingDuration, {main="Gada",sub="Ammurapi Shield",
        head="Telchine Cap",neck="Incanter's Torque",ear1="Mimir Earring",ear2="Andoaa Earring",
        body="Telchine Chasuble",hands="Inyanga Dastanas +2",ring1=gear.Lstikini,ring2=gear.Rstikini,
        back="Perimede Cape",waist="Olympus Sash",legs="Piety Pantaloons +3",feet="Theophany Duckbills +3"})
    sets.midcast.Auspice   = set_combine(sets.midcast.EnhancingDuration, {feet="Ebers Duckbills +3"})
    sets.midcast.Stoneskin = set_combine(sets.midcast.EnhancingDuration, {
        neck="Nodens Gorget",waist="Siegel Sash",legs="Shedir Seraweels"})
    sets.midcast.Aquaveil  = {main="Vadose Rod",sub="Genmei Shield",ammo="Staunch Tathlum +1",
        head="Chironic Hat",neck="Loricate Torque +1",ear1="Mimir Earring",ear2="Andoaa Earring",
        body="Telchine Chasuble",hands="Regal Cuffs",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.MEVACape,waist="Emphatikos Rope",legs="Shedir Seraweels",feet="Theophany Duckbills +3"}
    sets.midcast.Phalanx = {main="Gada",sub="Ammurapi Shield",ammo="Staunch Tathlum +1",
        head="Telchine Cap",neck="Loricate Torque +1",ear1="Mimir Earring",ear2="Andoaa Earring",
        body="Telchine Chasuble",hands="Telchine Gloves",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.MEVACape,waist="Embla Sash",legs="Piety Pantaloons +3",feet="Theophany Duckbills +3"}
    sets.midcast.StatBoost = set_combine(sets.midcast.Phalanx, {})
    sets.midcast.BarElement = {main="Beneficus",sub="Ammurapi Shield",ammo="Staunch Tathlum +1",
        head="Ebers Cap +3",neck="Incanter's Torque",ear1="Mimir Earring",ear2="Andoaa Earring",
        body="Ebers Bliaut +3",hands="Ebers Mitts +3",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.MEVACape,waist="Embla Sash",legs="Piety Pantaloons +3",feet="Ebers Duckbills +3"}
    sets.midcast.BarStatus = {main="Gada",sub="Ammurapi Shield",ammo="Staunch Tathlum +1",
        head="Telchine Cap",neck="Sroda Necklace",ear1="Mimir Earring",ear2="Andoaa Earring",
        body="Telchine Chasuble",hands="Telchine Gloves",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.MEVACape,waist="Embla Sash",legs="Telchine Braconi",feet="Theophany Duckbills +3"}
    sets.midcast.Regen = set_combine(sets.midcast.EnhancingDuration, {main="Bolelabunga",sub="Ammurapi Shield",
        head="Inyanga Tiara +2",body="Piety Bliaut +3",hands="Ebers Mitts +3",legs="Theophany Pantaloons +3"})
    sets.midcast.FixedPotencyEnhancing = set_combine(sets.midcast.EnhancingDuration, {})

    sets.midcast['Divine Magic'] = {main="Daybreak",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
        head="Bunzi's Hat",neck="Sibyl Scarf",ear1="Malignance Earring",ear2="Regal Earring",
        body="Nyame Mail",hands="Chironic Gloves",ring1="Metamorph Ring +1",ring2="Freke Ring",
        back=gear.ENMCape,waist=gear.ElementalObi,legs="Nyame Flanchard",feet=gear.chir_feet_ma}
    sets.midcast['Divine Magic'].MB = set_combine(sets.midcast['Divine Magic'], {
        neck="Mizukage-no-Kubikazari",hands="Bunzi's Gloves",ring1="Mujin Band",ring2="Locus Ring"})
    sets.midcast.Banish = set_combine(sets.midcast['Divine Magic'], {hands="Fanatic Gloves"})
    sets.orpheus   = {waist="Orpheus's Sash"}
    sets.ele_obi   = {waist="Hachirin-no-Obi"}
    sets.nuke_belt = {waist="Sacro Cord"}

    sets.midcast.Repose = {main="Asclepius",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
        head="Ebers Cap +3",neck="Null Loop",ear1="Malignance Earring",ear2="Regal Earring",
        body="Ebers Bliaut +3",hands="Ebers Mitts +3",ring1=gear.Lstikini,ring2="Kishar Ring",
        back=gear.ENMCape,waist="Null Belt",legs="Theophany Pantaloons +3",feet="Ebers Duckbills +3"}
    sets.midcast.Flash = {main="Mafic Cudgel",sub="Genmei Shield",ammo="Staunch Tathlum +1",
        head="Null Masque",neck="Unmoving Collar +1",ear1="Cryptic Earring",ear2="Trux Earring",
        body="Inyanga Jubbah +2",hands="Inyanga Dastanas +2",ring1="Supershear Ring",ring2="Eihwaz Ring",
        back=gear.MEVACape,waist="Kasiri Belt",legs="Inyanga Shalwar +2",feet="Inyanga Crackows +2"}

    sets.midcast.Drain = set_combine(sets.midcast.Repose, {main="Rubicundity",sub="Ammurapi Shield",
        head="Pixie Hairpin +1",neck="Erra Pendant",
        hands="Inyanga Dastanas +2",ring1="Archon Ring",ring2="Evanescence Ring"})
    sets.midcast.Aspir = set_combine(sets.midcast.Drain, {})
    sets.drain_belt = {waist="Fucho-no-Obi"}

    sets.midcast.Stun = set_combine(sets.midcast.Repose, {})
    sets.midcast['Elemental Magic'] = set_combine(sets.midcast['Divine Magic'], {})
    sets.midcast.Impact = set_combine(sets.midcast.Stun,
        {ring1="Metamorph Ring +1",ring2=gear.Rstikini,waist="Null Belt"},
        sets.impact)

    sets.midcast['Enfeebling Magic'] = {main="Asclepius",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
        head="Theophany Cap +3",neck="Null Loop",ear1="Malignance Earring",ear2="Regal Earring",
        body="Theophany Bliaut +3",hands="Kaykaus Cuffs +1",ring1=gear.Lstikini,ring2=gear.Rstikini,
        back="Null Shawl",waist="Obstinate Sash",legs="Chironic Hose",feet="Theophany Duckbills +3"}
    sets.midcast.Sleep = set_combine(sets.midcast['Enfeebling Magic'], {
        hands="Regal Cuffs",ring1="Metamorph Ring +1",ring2="Kishar Ring"})
    sets.midcast.Bind = set_combine(sets.midcast.Sleep, {})
    sets.midcast.Gravity = set_combine(sets.midcast.Sleep, {})
    sets.midcast.Dispelga = set_combine(sets.midcast['Enfeebling Magic'], sets.dispelga)
    sets.midcast.MndEnfeebles = set_combine(sets.midcast['Enfeebling Magic'], {main="Daybreak",sub="Ammurapi Shield",
        head="Null Masque",neck="Cleric's Torque +2",ring1="Metamorph Ring +1",back=gear.ENMCape})
    sets.midcast.IntEnfeebles = set_combine(sets.midcast['Enfeebling Magic'], {main="Bunzi's Rod",sub="Ammurapi Shield",
        ring1="Metamorph Ring +1"})

    sets.midcast.Utsusemi = {waist="Cornelia's Belt"}

    -- Sets to return to when not performing an action.

    sets.idle = {main="Asclepius",sub="Genmei Shield",ammo="Homiliary",
        head="Null Masque",neck="Loricate Torque +1",ear1="Thureous Earring",ear2="Etiolation Earring",
        body="Ebers Bliaut +3",hands="Volte Gloves",ring1="Inyanga Ring",ring2="Defending Ring",
        back=gear.MEVACape,waist="Null Belt",legs="Inyanga Shalwar +2",feet="Herald's Gaiters"}
    sets.idle.PDT = {main="Asclepius",sub="Genmei Shield",ammo="Staunch Tathlum +1",
        head="Null Masque",neck="Warder's Charm +1",ear1="Thureous Earring",ear2="Ebers Earring +1",
        body="Ebers Bliaut +3",hands="Volte Gloves",ring1="Shadow Ring",ring2="Defending Ring",
        back=gear.MEVACape,waist="Null Belt",legs="Inyanga Shalwar +2",feet="Inyanga Crackows +2"}
    sets.idle.MEVA = {main="Daybreak",sub="Genmei Shield",ammo="Staunch Tathlum +1",
        head="Null Masque",neck="Warder's Charm +1",ear1="Thureous Earring",ear2="Ebers Earring +1",
        body="Ebers Bliaut +3",hands="Nyame Gauntlets",ring1="Shadow Ring",ring2="Defending Ring",
        back=gear.MEVACape,waist="Null Belt",legs="Ebers Pantaloons +3",feet="Ebers Duckbills +3"}
    sets.idle.Rf = {main="Bolelabunga",sub="Genmei Shield",ammo="Homiliary",
        head="Null Masque",neck="Sibyl Scarf",ear1="Genmei Earring",ear2="Ebers Earring +1",
        body="Ebers Bliaut +3",hands="Volte Gloves",ring1="Inyanga Ring",ring2=gear.Rstikini,
        back=gear.MEVACape,waist="Null Belt",legs="Inyanga Shalwar +2",feet="Inyanga Crackows +2"}
    sets.latent_refresh = {ammo="Homiliary",waist="Fucho-no-obi"}
    sets.buff.doom = {neck="Nicander's Necklace",ring1="Eshmun's Ring",waist="Gishdubar Sash"}
    sets.buff.sleep = {main="Lorg Mor",sub="Genmei Shield",ammo="Homiliary",
        head="Null Masque",neck="Warder's Charm +1",ear1="Genmei Earring",ear2="Etiolation Earring",
        body="Ebers Bliaut +3",hands="Nyame Gauntlets",ring1="Shadow Ring",ring2="Defending Ring",
        back=gear.MEVACape,waist="Null Belt",legs="Nyame Flanchard",feet="Nyame Sollerets"}

    sets.defense.PDT  = set_combine(sets.idle.PDT, {})
    sets.defense.KB   = set_combine(sets.defense.PDT, {ring1="Vocane Ring +1",back="Repulse Mantle"})
    sets.defense.MEVA = set_combine(sets.idle.MEVA, {})
    sets.defense.MRf  = set_combine(sets.idle.Rf, {main="Asclepius",sub="Genmei Shield"})
    sets.Kiting       = {feet="Herald's Gaiters"}
    sets.sphere       = {body="Gyve Doublet"}
    sets.buff.Sublimation = {waist="Embla Sash"}

    sets.engaged = {main="Yagrush",sub="Genmei Shield",ammo="Amar Cluster",
        head="Bunzi's Hat",neck="Null Loop",ear1="Brutal Earring",ear2="Telos Earring",
        body="Ayanmo Corazza +2",hands="Bunzi's Gloves",ring1="Chirich Ring +1",ring2="Ephramad's Ring",
        back=gear.TPCape,waist="Windbuffet Belt +1",legs="Ayanmo Cosciales +2",feet="Nyame Sollerets"}
    sets.engaged.PDef = set_combine(sets.engaged, {
        body="Nyame Mail",hands="Bunzi's Gloves",waist="Cornelia's Belt",legs="Nyame Flanchard",feet="Nyame Sollerets"})
    sets.dualwield = {back=gear.TPCapeDW} -- applied inside customize_melee_set

    -- Sets that depend upon idle sets
    sets.midcast.FastRecast = set_combine(sets.idle.PDT, {main="Asclepius",sub="Genmei Shield",waist="Cornelia's Belt"})
    sets.midcast.Dia     = set_combine(sets.idle, sets.TreasureHunter)
    sets.midcast.Bio     = set_combine(sets.idle, sets.TreasureHunter)
    sets.midcast.Stone   = set_combine(sets.idle, sets.TreasureHunter)
    sets.midcast.Stonega = set_combine(sets.idle, sets.TreasureHunter)

    sets.encumber = {ammo="Homiliary",
        head="Theophany Cap +3",neck="Cleric's Torque +2",ear1="Glorious Earring",ear2="Ebers Earring +1",
        body="Ebers Bliaut +3",hands="Fanatic Gloves",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.FCCape,waist="Embla Sash",legs="Ebers Pantaloons +3",feet="Medium's Sabots"}
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.
function job_precast(spell, action, spellMap, eventArgs)
    if classes.CustomClass == 'CureCheat' then
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
            equip(resolve_ele_belt(spell, sets.ele_obi, sets.nuke_belt, 3))
        end
    end
end

function job_post_midcast(spell, action, spellMap, eventArgs)
    -- Apply Divine Caress boosting items as highest priority over other gear, if applicable.
    if state.Buff['Divine Caress'] and spellMap == 'StatusRemoval' and spell.english ~= 'Erase' then
        equip(sets.buff['Divine Caress'])
        if spell.english == 'Cursna' then
            equip({back=gear.MEVACape})
        end
    elseif S{'Drain','Aspir'}:contains(spellMap) then
        equip(resolve_ele_belt(spell, sets.ele_obi, sets.drain_belt, 5))
    elseif S{'Banish','Holy'}:contains(spellMap) or spell.skill == 'Elemental Magic' then
        if state.MagicBurst.value then equip(sets.midcast['Divine Magic'].MB) end
        equip(resolve_ele_belt(spell, sets.ele_obi, sets.nuke_belt, 3))
    elseif classes.CustomClass ~= 'CureCheat' and (spellMap == 'Cure' or spellMap == 'Curaga') then
        if spell.target.type == 'SELF' and spellMap ~= 'Curaga' then
            equip(resolve_ele_belt(spell, sets.ele_obi, sets.gishdubar, 9))
        elseif spell.target.type == 'MONSTER' then
            equip(resolve_ele_belt(spell, sets.ele_obi, sets.nuke_belt, 3))
        else
            equip(resolve_ele_belt(spell, sets.ele_obi, sets.cmp_belt, 2))
        end
    elseif spell.target.type == 'SELF' then
        if spell.english == 'Refresh' then
            equip(sets.gishdubar)
        elseif spell.english == 'Cursna' then
            if state.Buff.doom then
                equip(sets.buff.doom)
            end
        end
    end
end

function job_aftercast(spell, action, spellMap, eventArgs)
    if spell.interrupted then
        send_command('wait 0.5;gs c update')
        interrupted_message(spell)
    else
        if S{'JobAbility','Scholar'}:contains(spell.type) then
            eventArgs.handled = true
        elseif spell.english == 'Dia II' and state.DiaMsg.value then
            if spell.target.name and spell.target.type == 'MONSTER' then
                send_command('input /p Dia II /')
            end
        elseif spell.type == 'WeaponSkill' and state.WSMsg.value then
            if state.WSMsg.value then
                send_command('input /p '..spell.english)
            end
        elseif spell.english == 'Impact' then
            debuff_timer(spell, 180)
        elseif spell.english == 'Repose' then
            debuff_timer(spell, 90)
        elseif spell.english == 'Banish III' then
            debuff_timer(spell, 45)
        elseif spell.english == 'Banish II' or spell.english == 'Banishga II' then
            debuff_timer(spell, 30)
        elseif spell.english == 'Sleep' or spell.english == 'Sleepga' then
            debuff_timer(spell, 81)
        elseif spell.english == 'Sleep II' or spell.english == 'Sleepga II' then
            debuff_timer(spell, 121)
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
    if spell.action_type == 'Magic' then
        if default_spell_map == 'Cure' and state.Buff['Afflatus Solace'] then
            return "CureSolace"
        elseif spell.skill == 'Enfeebling Magic' then
            -- Spells with variable potencies, divided into dINT and dMND spells.
            -- These spells also benefit from RDM gear and WKR shoes.
            if S{'Slow','Paralyze','Addle'}:contains(spell.english) then
                return "MndEnfeebles"
            elseif S{'Blind','Gravity'}:contains(spell.english) then
                return "IntEnfeebles"
            end
        elseif spell.skill == 'Enhancing Magic' then
            if not S{'Regen','BarElement','BarStatus','EnSpell','StatBoost','Teleport'}:contains(default_spell_map) then
                return "FixedPotencyEnhancing"
            end
        end
    end
end

function customize_idle_set(idleSet)
    if state.SphereIdle.value and state.DefenseMode.value == 'None' then
        idleSet = set_combine(idleSet, sets.sphere)
    end
    if state.Buff['Sublimation: Activated'] then
        idleSet = set_combine(idleSet, sets.buff.Sublimation)
    elseif player.mpp < 60 and state.DefenseMode.value == 'None' then
        idleSet = set_combine(idleSet, sets.latent_refresh)
    end
    if buffactive['Reive Mark'] then
        if player.inventory["Arciela's Grace +1"] then idleSet = set_combine(idleSet, {neck="Arciela's Grace +1"}) end
    end
    if state.Buff.sleep and not buffactive["Sublimation: Activated"] then
        idleSet = set_combine(idleSet, sets.buff.sleep)
    end
    return idleSet
end

function customize_melee_set(meleeSet)
    if state.DefenseMode.value == 'None' then
        if state.CombatForm.has_value and state.CombatForm.value == 'DW' then
            meleeSet = set_combine(meleeSet, sets.dualwield)
        end
    end
    if state.Buff.sleep and not buffactive["Sublimation: Activated"] then
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
    elseif cmdParams[1] == 'user' then
        state.AriseTold:reset()
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

    msg = msg .. 'Cast['..state.CastingMode.value..'] Idle['..state.IdleMode.value..']'

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
    if state.Buff['Afflatus Solace'] then
        msg = msg .. ' Solace'
    elseif state.Buff['Afflatus Misery'] then
        msg = msg .. ' Misery'
    else
        msg = msg .. ' *NoAfflatus*'
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
    if     cmdParams[1] == 'scholar' then
        handle_stratagems(cmdParams)
    elseif cmdParams[1] == 'CureCheat' then
        classes.CustomClass = 'CureCheat'
        send_command('input /ma "Cure III" <me>')
    elseif cmdParams[1] == 'ListWS' then
        info.ws_binds:print('ListWS:')
    elseif cmdParams[1] == 'weap' then
        weap_self_command(cmdParams, 'CombatWeapon')
    elseif cmdParams[1] == 'save' then
        save_self_command(cmdParams)
    elseif cmdParams[1] == 'rebind' then
        info.keybinds:bind()
    elseif cmdParams[1] == 'encumber' then
        equip(sets.encumber)
        disable('head','neck','ear1','ear2','body','hands','ring1','ring2','back','waist','legs','feet')
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
        'bind !@F9 gs c cycleback CombatWeapon',
        'bind F10  gs c cycle CastingMode',
        'bind !F10 gs c reset CastingMode',
        'bind F11  gs c cycle IdleMode',
        'bind ^F11 gs c set IdleMode PDT',
        'bind !F11 gs c reset IdleMode',
        'bind @F11 gs c toggle Kiting',
        'bind ^space  gs c cycle HybridMode',
        'bind !space  gs c set DefenseMode Physical',
        'bind @space  gs c set DefenseMode Magical',
        'bind !@space gs c reset DefenseMode',
        'bind !w   gs c set OffenseMode Normal',
        'bind !@w  gs c reset OffenseMode',
        'bind !^q gs c set CombatWeapon Staff',
        'bind !^w gs c weap Yag',
        'bind !^e gs c weap Max',
        'bind !^r gs c weap Day',
        'bind ^@w gs c weap Yag Asc',
        'bind ^@e gs c weap Max Asc',
        'bind ^\\\\  gs c toggle WSMsg',
        'bind ^@\\\\ gs c toggle DiaMsg',
        'bind !@z     gs c cycle PhysicalDefenseMode',
        'bind @z      gs c cycle MagicalDefenseMode',
        'bind !z      gs c toggle MagicBurst',
        'bind ^z      gs c toggle SphereIdle',

        'bind ^`    input /ja "Divine Seal" <me>',
        'bind !`    input /ja Devotion',
        'bind @`    input /ja "Divine Caress" <me>',
        'bind ^@`   input /ja Sacrosanctity <me>',
        'bind ^@tab input /ja Asylum <me>',
        'bind !^`   input /ja Benediction <me>',
        'bind ~^tab input /ja "Afflatus Solace" <me>',
        'bind ~^q   input /ja "Afflatus Misery" <me>',

        'bind ^1  input /ma "Dia II"',
        'bind ^2  input /ma Slow',
        'bind ^3  input /ma Paralyze',
        'bind ^4  input /ma Addle',
        'bind ^5  input /ma Repose <stnpc>',
        'bind ^6  input /ma Silence',
        'bind ^backspace input /ma Impact',
        'bind !1  input /ma "Cure III" <stpc>',
        'bind !2  input /ma "Cure IV" <stpc>',
        'bind !3  input /ma "Cure V" <stpc>',
        'bind !4  input /ma "Cure VI" <stpc>',
        'bind !@1 input /ma "Curaga"',
        'bind !@2 input /ma "Curaga II"',
        'bind !@3 input /ma "Curaga III"',
        'bind !@4 input /ma "Curaga IV"',
        'bind !@5 input /ma "Curaga V"',
        'bind !5  input /ma Haste <stpc>',
        'bind !8  input /ma Auspice <me>',
        'bind !9  input /ma "Regen IV" <stpc>',
        'bind !0  input /ma Flash',

        'bind @1  input /ma Poisona',
        'bind @2  input /ma Paralyna',
        'bind @3  input /ma Blindna',
        'bind @4  input /ma Silena',
        'bind @5  input /ma Stona',
        'bind @6  input /ma Viruna',
        'bind @7  input /ma Cursna',
        'bind @F1 input /ma Erase',
        'bind @F2 input /ma Esuna <me>',
        'bind @F3 input /ma Sacrifice',
        'bind @F4 input /ma "Full Cure" <t>',

        'bind ^@1  input /ma Barfira <me>',
        'bind ^@2  input /ma Barblizzara <me>',
        'bind ^@3  input /ma Baraera <me>',
        'bind ^@4  input /ma Barstonra <me>',
        'bind ^@5  input /ma Barthundra <me>',
        'bind ^@6  input /ma Barwatera <me>',
        'bind ~^@1 input /ma Baramnesra <me>',
        'bind ~^@2 input /ma Barparalyzra <me>',
        'bind ~^@3 input /ma Barsilencera <me>',
        'bind ~^@4 input /ma Barpetra <me>',
        'bind ~^@5 input /ma Barsleepra <me>',
        'bind ~^@6 input /ma Barpoisonra <me>',

        'bind ~^1 input /ma Boost-STR <me>',
        'bind ~^2 input /ma Boost-DEX <me>',
        'bind ~^3 input /ma Boost-INT <me>',
        'bind ~^4 input /ma Boost-MND <me>',
        'bind ~^5 input /ma Boost-VIT <me>',
        'bind ~^6 input /ma Boost-AGI <me>',
        'bind ~^7 input /ma Boost-CHR <me>',

        'bind ^c gs c CureCheat',
        'bind @c input /ma Blink <me>',
        'bind @v input /ma Aquaveil <me>',
        'bind ~^x  input /ma Sneak',
        'bind ~!^x input /ma Invisible',
        'bind !@g input /ma Stoneskin <me>',
        'bind !b input /ma Repose <t>',    -- for charmed people
        'bind !n input /ma "Holy II" <t>', -- for charmed people too
        'bind ^q input /ma Dispelga'}

    if     player.sub_job == 'SCH' then
        bind_command_list:extend(L{
            'bind !6   input /ma Aurorastorm <me>',
            'bind !7   input /ma Klimaform <me>',
            'bind ^tab input /ja Sublimation <me>',
            'bind @tab gs c scholar cost',
            'bind @q   gs c scholar speed',
            'bind ^@q  gs c scholar aoe',
            'bind @e   input /ja "Light Arts" <me>',
            'bind !@e  gs c scholar dark',
            'bind !e   input /ma Sleep <stnpc>',
            'bind !d   input /ma Dispel',
            'bind @d   input /ma Aspir',
            'bind !@d  input /ma Drain'})
    elseif player.sub_job == 'RDM' then
        bind_command_list:extend(L{
            'bind !6   input /ma Refresh <stpc>',
            'bind !7   input /ma Flurry <stpc>',
            'bind !@`  input /ja Convert <me>',
            'bind @q   input /ma Bind <stnpc>',
            'bind ^@q  input /ma Gravity <stnpc>',
            'bind ^tab input /ma Dispel',
            'bind !g   input /ma Phalanx <me>',
            'bind !d   input /ma Distract',
            'bind @d   input /ma Frazzle',
            'bind !e   input /ma Sleep <stnpc>',
            'bind !@e  input /ma "Sleep II" <stnpc>'})
    elseif player.sub_job == 'BLM' then
        bind_command_list:extend(L{
            'bind ^tab input /ja "Elemental Seal"',
            'bind @q   input /ma Bind <stnpc>',
            'bind ^@q  input /ma Sleepga <stnpc>',
            'bind !e   input /ma Sleep <stnpc>',
            'bind !@e  input /ma "Sleep II" <stnpc>',
            'bind !d   input /ma Stun'})
    elseif player.sub_job == 'DNC' then
        bind_command_list:extend(L{
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
            'bind !e  input /pet "Mewing Lullaby" <t>',
            'bind @e  input /pet "Aero II" <t>',
            'bind !d  input /pet Assault <t>',
            'bind @d  input /pet Retreat <me>',
            'bind !b  input /ma "Cait Sith" <me>',
            'bind @b  input /ma Garuda <me>',
            'bind !@b input /pet Release <me>'})
    end

    return bind_command_list
end

function init_state_text()
    if hud then return end

    local mb_text_settings    = {flags={draggable=false,bold=true},bg={red=250,green=200,blue=0,alpha=150},text={stroke={width=2}}}
    local ally_text_settings  = {pos={x=-178},flags={draggable=false,right=true,bold=true},bg={alpha=200},text={font='Courier New',size=10}}
    local hyb_text_settings   = {pos={x=130,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local def_text_settings   = {pos={x=172,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local off_text_settings   = {pos={x=172,y=697},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}

    hud = {texts=T{}}
    hud.texts.mb_text   = texts.new('MBurst',         mb_text_settings)
    hud.texts.ally_text = texts.new('AllyCure',       ally_text_settings)
    hud.texts.hyb_text  = texts.new('initializing..', hyb_text_settings)
    hud.texts.def_text  = texts.new('initializing..', def_text_settings)
    hud.texts.off_text  = texts.new('initializing..', off_text_settings)

    -- update infrequently changing text boxes in job_state_change or where they are changed
    function hud_update_on_state_change(stateField)
        if not hud then init_state_text() end

        if not stateField or stateField == 'Magic Burst' then
            hud.texts.mb_text:visible(state.MagicBurst.value)
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
