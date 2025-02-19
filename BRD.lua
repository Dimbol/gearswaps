-- Modified from 'https://github.com/Kinematics/GearSwap-Jobs/blob/master/BRD.lua'

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
    state.Buff.Pianissimo        = buffactive.Pianissimo or false
    state.Buff.Marcato           = buffactive.Marcato or false
    state.Buff.Tenuto            = buffactive.Tenuto or false
    state.Buff.Troubadour        = buffactive.Troubadour or false
    state.Buff.Nightingale       = buffactive.Nightingale or false
    state.Buff['Soul Voice']     = buffactive['Soul Voice'] or false
    state.Buff['Clarion Call']   = buffactive['Clarion Call'] or false
    state.Buff['Elemental Seal'] = buffactive['Elemental Seal'] or false
    state.Buff.doom              = buffactive.doom or false
    state.Buff.sleep             = buffactive.sleep or false

    logout_event_id = windower.raw_register_event('logout', destroy_state_text)
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
    state.OffenseMode:options('None','Normal','Acc')                    -- Cycle with F9, will swap weapon
    state.HybridMode:options('Normal','PDef')                           -- Cycle with ^F9
    state.WeaponskillMode:options('Normal','SB')                        -- Cycle with @F9
    state.CastingMode:options('Normal','Resistant')                     -- Cycle with F10
    state.IdleMode:options('Normal','Roller','Rf')                      -- Cycle with F11, reset with !F11
    state.PhysicalDefenseMode:options('PDT','Eva')                      -- Cycle with @z
    state.CombatWeapon = M{['description']='Combat Weapon'}             -- Cycle with @F9
    if S{'DNC','NIN'}:contains(player.sub_job) then
        state.CombatWeapon:options('CarnCrep','CarnGleti','AenDem','AenTwash','TwashTP','TwashDW','TaurAE','NaegTP','NaegDW','Staff')
		state.CombatForm:set('DW')
    else
        state.CombatWeapon:options('Carn','Aeneas','Twashtar','Naegling','Staff')
		state.CombatForm:reset()
    end
    state.ExtraSongsMode = M{['description']='Extra Songs','None','Dummy','FullHarp'}  -- Set/unset with !c/!@c
    state.DummySongs = {['1']="Bewitching Etude",['2']="Enchanting Etude"}

    state.HarpLullaby = M(true,  'Harp Lullaby Radius')                 -- Toggle with !z
    state.SphereIdle  = M(false, 'Sphere Idle')                         -- toggle with ^z
    state.LongSongs   = M(false, 'Uneven Songs')                        -- Toggle with !@z
    state.WSMsg       = M(false, 'WS Message')                          -- Toggle with ^\
    state.DiaMsg      = M(false, 'Dia Message')                         -- Toggle with ^@\
    state.Fishing     = M(false, 'Fishing Gear')
    init_state_text()
    hud_update_on_state_change()

    info.magic_ws = S{'Aeolian Edge','Cyclone','Gust Slash','Energy Steal','Energy Drain',
                      'Burning Blade','Red Lotus Blade','Shining Blade','Seraph Blade','Sanguine Blade',
                      'Rock Crusher','Earth Crusher','Starburst','Sunburst','Cataclysm',
                      'Shining Strike','Seraph Strike'}

    -- Mote-libs handle obis, gorgets, and other elemental things.
    -- These are default fallbacks if situationally appropriate gear is not available.
    gear.default.obi_waist = "Platinum Moogle Belt"                     -- used in sets.midcast.Cure and friends

    -- Augmented items get variables for convenience and specificity
    gear.chir_feet_ma = {name="Chironic Slippers", augments={'"Mag.Atk.Bns."+30','Mag. Acc.+14 "Mag.Atk.Bns."+14'}}
    gear.chir_feet_th = {name="Chironic Slippers", augments={'"Treasure Hunter"+1'}}
    gear.Lstikini = {name="Stikini Ring +1", bag="wardrobe2"}
    gear.Rstikini = {name="Stikini Ring +1", bag="wardrobe3"}
    gear.linos_tp = {name="Linos", augments={'Quadruple Attack +3'}}
    gear.linos_qm = {name="Linos", augments={'Occ. quickens spellcasting +4%'}}
    gear.SongCape  = {name="Intarabus's Cape", augments={'CHR+20','Mag. Acc+20 /Mag. Dmg.+20','"Fast Cast"+10'}}
    gear.TPCape    = {name="Intarabus's cape", augments={'DEX+20','Accuracy+20 Attack+20','"Dbl.Atk."+10'}}
    gear.RudraCape = {name="Intarabus's Cape", augments={'DEX+20','Accuracy+20 Attack+20','Weapon skill damage +10%'}}
    gear.RimeCape  = {name="Intarabus's Cape", augments={'CHR+20','Accuracy+20 Attack+20','Weapon skill damage +10%'}}
    gear.SBCape    = {name="Intarabus's Cape", augments={'STR+20','Accuracy+20 Attack+20','Weapon skill damage +10%'}}
    gear.MEVACape  = {name="Intarabus's Cape", augments={'Eva.+20 /Mag. Eva.+20','Mag. Evasion+10'}}
    gear.EVACape   = {name="Intarabus's Cape", augments={'AGI+20','Eva.+20 /Mag. Eva.+20'}}

    info.keybinds = make_keybind_list(job_keybinds())
    info.keybinds:bind()

    info.ws_binds = make_keybind_list(T{
        ['Dagger']=L{
            'bind !^1|%1 input /ws "Evisceration"',
            'bind !^2|%2 input /ws "Rudra\'s Storm"',
            'bind !^3|%3 input /ws "Mordant Rime"',
            'bind !^4|%4 input /ws "Exenterator"',
            'bind !^6|%6 input /ws "Aeolian Edge"',
            'bind !^7|%7 input /ws "Cyclone"',
            'bind ~!^1|%~1 input /ws "Evisceration" <stnpc>',
            'bind ~!^2|%~2 input /ws "Rudra\'s Storm" <stnpc>',
            'bind ~!^3|%~3 input /ws "Mordant Rime" <stnpc>',
            'bind ~!^4|%~4 input /ws "Exenterator" <stnpc>',
            'bind ~!^6|%~6 input /ws "Aeolian Edge" <stnpc>',
            'bind ~!^7|%~7 input /ws "Cyclone" <stnpc>',
            'bind !^d input /ws "Shadowstitch"'},
        ['Sword']=L{
            'bind !^1|%1 input /ws "Sanguine Blade"',
            'bind !^3|%3 input /ws "Savage Blade"',
            'bind !^6|%6 input /ws "Circle Blade"',
            'bind ~!^1|%~1 input /ws "Sanguine Blade" <stnpc>',
            'bind ~!^3|%~3 input /ws "Savage Blade" <stnpc>',
            'bind ~!^6|%~6 input /ws "Circle Blade" <stnpc>',
            'bind !^d input /ws "Flat Blade"'},
        ['Staff']=L{
            'bind !^1|%1 input /ws "Shell Crusher"',
            'bind !^2|%2 input /ws "Shattersoul"',
            'bind !^3|%3 input /ws "Retribution"',
            'bind !^4|%4 input /ws "Spirit Taker"',
            'bind !^6|%6 input /ws "Cataclysm"',
            'bind ~!^1|%~1 input /ws "Shell Crusher" <stnpc>',
            'bind ~!^2|%~2 input /ws "Shattersoul" <stnpc>',
            'bind ~!^3|%~3 input /ws "Retribution" <stnpc>',
            'bind ~!^4|%~4 input /ws "Spirit Taker" <stnpc>',
            'bind ~!^6|%~6 input /ws "Cataclysm" <stnpc>'}},
        {['Carn']='Dagger',['CarnCrep']='Dagger',['CarnGleti']='Dagger',
         ['Aeneas']='Dagger',['AenTwash']='Dagger',['AenDem']='Dagger',
         ['Twashtar']='Dagger',['TwashTP']='Dagger',['TwashDW']='Dagger',
         ['TaurAE']='Dagger',['Naegling']='Sword',['NaegTP']='Sword',['NaegDW']='Sword',['Staff']='Staff'})
    info.ws_binds:bind(state.CombatWeapon)
    send_command('bind %\\\\ gs c ListWS')

    info.recast_ids = L{{name="N",id=109},{name="T",id=110},{name="M",id=48}}
    if     player.sub_job == 'WHM' then
        info.recast_ids:append({name="D.Seal",id=26})
    elseif player.sub_job == 'SCH' then
        info.recast_ids:append({name="Strats",id=231})
    elseif player.sub_job == 'BLM' then
        info.recast_ids:append({name="E.Seal",id=38})
    elseif player.sub_job == 'PLD' then
        info.recast_ids:append({name="Sentinel",id=75})
    end

    --select_default_macro_book()
end

-- Called when this job file is unloaded (eg: job change)
function user_unload()
    info.keybinds:unbind()

    info.ws_binds:unbind()
    send_command('unbind %\\\\')

    destroy_state_text()
end

-- Define sets and vars used by this job file.
function init_gear_sets()

    sets.weapons = {}
    --sets.weapons.Carn      = {main="Carnwenhan",sub="Genmei Shield"}
    sets.weapons.Carn      = {main="Carnwenhan",sub="Ammurapi Shield"}
    sets.weapons.CarnCrep  = {main="Carnwenhan",sub="Crepuscular Knife"}
    sets.weapons.CarnGleti = {main="Carnwenhan",sub="Gleti's Knife"}
    sets.weapons.Aeneas    = {main="Aeneas",sub="Genmei Shield"}
    sets.weapons.AenDem    = {main="Aeneas",sub="Demersal Degen +1"}
    sets.weapons.AenTwash  = {main="Aeneas",sub="Twashtar"}
    sets.weapons.Twashtar  = {main="Twashtar",sub="Genmei Shield"}
    sets.weapons.TwashTP   = {main="Twashtar",sub="Centovente"}
    sets.weapons.TwashDW   = {main="Twashtar",sub="Gleti's Knife"}
    sets.weapons.Naegling  = {main="Naegling",sub="Genmei Shield"}
    sets.weapons.NaegTP    = {main="Naegling",sub="Centovente"}
    sets.weapons.NaegDW    = {main="Naegling",sub="Gleti's Knife"}
    sets.weapons.Tauret    = {main="Tauret",sub="Genmei Shield"}
    sets.weapons.TaurAE    = {main="Tauret",sub="Malevolence"}
    sets.weapons.Staff     = {main="Xoanon",sub="Bloodrain Strap"}
    sets.TreasureHunter = {range=empty,ammo="Perfect Lucky Egg",head="Volte Cap",waist="Chaac Belt",feet=gear.chir_feet_th}

    -- Precast Sets

    sets.precast.JA.Nightingale = {feet="Bihu Slippers +3"}
    sets.precast.JA.Troubadour = {body="Bihu Justaucorps +3"}
    sets.precast.JA['Soul Voice'] = {legs="Bihu Cannions +3"}

    sets.precast.FC = {main="Kali",sub="Genmei Shield",range=gear.linos_qm,
        head="Bunzi's Hat",neck="Orunmila's Torque",ear1="Loquacious Earring",ear2="Etiolation Earring",
        body="Inyanga Jubbah +2",hands="Leyline Gloves",ring1="Lebeche Ring",ring2="Kishar Ring",
        back=gear.SongCape,waist="Witful Belt",legs="Ayanmo Cosciales +2",feet="Fili Cothurnes +3"}
    sets.precast.FC.Cure = set_combine(sets.precast.FC, {ear2="Mendicant's Earring"})
    sets.precast.FC.BardSong = {range=gear.linos_qm,
        head="Fili Calot +2",neck="Orunmila's Torque",ear1="Loquacious Earring",ear2="Etiolation Earring",
        body="Brioso Justaucorps +3",hands="Leyline Gloves",ring1="Lebeche Ring",ring2="Kishar Ring",
        back=gear.SongCape,waist="Witful Belt",legs="Ayanmo Cosciales +2",feet="Telchine Pigaches"}
    sets.precast.FC['Honor March'] = set_combine(sets.precast.FC.BardSong, {range="Marsyas"})
    sets.precast.FC['Aria of Passion'] = set_combine(sets.precast.FC.BardSong, {range="Loughnashade"})
    sets.dispelga = {main="Daybreak",sub="Ammurapi Shield"}
    sets.precast.FC.Dispelga = set_combine(sets.precast.FC, sets.dispelga)

    sets.precast.Step = {range=gear.linos_tp,
        head="Null Masque",neck="Null Loop",ear1="Telos Earring",ear2="Fili Earring +1",
        body="Nyame Mail",hands="Nyame Gauntlets",ring1="Chirich Ring +1",ring2="Ephramad's Ring",
        back="Null Shawl",waist="Null Belt",legs="Nyame Flanchard",feet="Nyame Sollerets"}
    sets.precast.JA['Violent Flourish'] = set_combine(sets.precast.Step, {ring1="Etana Ring"})

    sets.precast.WS = {range=gear.linos_tp,
        head="Bunzi's Hat",neck="Bard's Charm +2",ear1="Telos Earring",ear2="Moonshade Earring",
        body="Bihu Justaucorps +3",hands="Nyame Gauntlets",ring1="Hetairoi Ring",ring2="Ephramad's Ring",
        back=gear.TPCape,waist="Fotia Belt",legs="Nyame Flanchard",feet="Nyame Sollerets"}
    sets.precast.WS['Evisceration'] = set_combine(sets.precast.WS, {head="Blistering Sallet +1"})
    sets.precast.WS['Exenterator'] = set_combine(sets.precast.WS, {head="Nyame Helm",ear2="Brutal Earring"})
    sets.precast.WS.Rudras = set_combine(sets.precast.WS, {
        head="Nyame Helm",ear1="Ishvara Earring",ring1="Epaminondas's Ring",back=gear.RudraCape,waist="Sailfi Belt +1"})
    sets.precast.WS['Rudra\'s Storm'] = sets.precast.WS.Rudras
    sets.precast.WS['Rudra\'s Storm'].SB = set_combine(sets.precast.WS['Rudra\'s Storm'], {
        ear1="Dignitary's Earring",ring1="Chirich Ring +1",waist="Peiste Belt +1"})
    sets.precast.WS['Savage Blade'] = {range=gear.linos_tp,
        head="Nyame Helm",neck="Bard's Charm +2",ear1="Regal Earring",ear2="Moonshade Earring",
        body="Nyame Mail",hands="Nyame Gauntlets",ring1="Epaminondas's Ring",ring2="Ephramad's Ring",
        back=gear.SBCape,waist="Sailfi Belt +1",legs="Nyame Flanchard",feet="Nyame Sollerets"}
    sets.precast.WS['Savage Blade'].SB = set_combine(sets.precast.WS['Savage Blade'], {
        neck="Bathy Choker +1",ear1="Dignitary's Earring",ring1="Chirich Ring +1",waist="Peiste Belt +1"})
    sets.precast.WS['Mordant Rime'] = {range=gear.linos_tp,
        head="Nyame Helm",neck="Bard's Charm +2",ear1="Telos Earring",ear2="Regal Earring",
        body="Bihu Justaucorps +3",hands="Bunzi's Gloves",ring1="Ilabrat Ring",ring2="Ephramad's Ring",
        back=gear.RimeCape,waist="Sailfi Belt +1",legs="Nyame Flanchard",feet="Nyame Sollerets"}
    sets.precast.WS['Mordant Rime'].SB = set_combine(sets.precast.WS['Mordant Rime'], {
        ear1="Dignitary's Earring",ring1="Chirich Ring +1",waist="Peiste Belt +1"})
        --neck="Bathy Choker +1",ear1="Dignitary's Earring",ring1="Chirich Ring +1"})
    sets.precast.WS.Magical = {range=gear.linos_tp,
        head="Nyame Helm",neck="Fotia Gorget",ear1="Regal Earring",ear2="Moonshade Earring",
        body="Nyame Mail",hands="Nyame Gauntlets",ring1="Epaminondas's Ring",ring2="Ilabrat Ring",
        back=gear.RudraCape,waist="Fotia Belt",legs="Nyame Flanchard",feet="Nyame Sollerets"}
    sets.precast.WS['Cataclysm'] = set_combine(sets.precast.WS.Magical, {head="Pixie Hairpin +1",ring2="Archon Ring"})
    sets.precast.WS['Energy Drain'] = set_combine(sets.precast.WS['Cataclysm'], {})
    sets.precast.WS['Sanguine Blade'] = set_combine(sets.precast.WS['Cataclysm'], {})
    sets.precast.WS['Shell Crusher'] = {range=gear.linos_tp,
        head="Null Masque",neck="Null Loop",ear1="Moonshade Earring",ear2="Crepuscular Earring",
        body="Ayanmo Corazza +2",hands="Ayanmo Manopolas +2",ring1="Chirich Ring +1",ring2="Ephramad's Ring",
        back="Null Shawl",waist="Null Belt",legs="Ayanmo Cosciales +2",feet="Ayanmo Gambieras +2"}
    sets.orpheus = {waist="Orpheus's Sash"}
    sets.ele_obi = {waist="Hachirin-no-Obi"}

    -- Midcast Sets

    sets.midcast.SongEffect = {main="Carnwenhan",sub="Genmei Shield",range="Loughnashade",
        head="Fili Calot +2",neck="Moonbow Whistle +1",ear1="Genmei Earring",ear2="Etiolation Earring",
        body="Fili Hongreline +3",hands="Fili Manchettes +2",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.SongCape,waist="Platinum Moogle Belt",legs="Inyanga Shalwar +2",feet="Brioso Slippers +3"}              -- dur+171

    sets.midcast.Madrigal = set_combine(sets.midcast.SongEffect, {
        head="Fili Calot +2",body="Aoidos' Hongreline +1",back=gear.SongCape,legs="Fili Rhingrave +3"})                   -- dur+165
    sets.midcast.Prelude  = set_combine(sets.midcast.SongEffect, {back=gear.SongCape,legs="Fili Rhingrave +3"})           -- dur+164 *
    sets.midcast.March    = set_combine(sets.midcast.SongEffect, {hands="Fili Manchettes +2",legs="Fili Rhingrave +3"})   -- dur+164 *
    sets.midcast.Minuet   = set_combine(sets.midcast.SongEffect, {body="Fili Hongreline +3",legs="Fili Rhingrave +3"})    -- dur+164 *
    sets.midcast.Minne    = set_combine(sets.midcast.SongEffect, {body="Aoidos' Hongreline +1",legs="Mousai Seraweels +1"})-- dur+165
    sets.midcast.Mambo    = set_combine(sets.midcast.SongEffect, {
        body="Aoidos' Hongreline +1",legs="Inyanga Shalwar +1",feet="Mousai Crackows +1"})                                -- dur+165
    sets.midcast.Carol    = set_combine(sets.midcast.SongEffect, {
        body="Aoidos' Hongreline +1",hands="Mousai Gages +1",legs="Fili Rhingrave +3"})                                   -- dur+165
    sets.midcast.Etude    = set_combine(sets.midcast.SongEffect, {body="Aoidos' Hongreline +2",legs="Inyanga Shalwar +1"})-- dur+165
    sets.midcast.Ballad   = set_combine(sets.midcast.SongEffect, {legs="Fili Rhingrave +3"})                              -- dur+164 *
    sets.midcast.Paeon    = set_combine(sets.midcast.SongEffect, {
        head="Brioso Roundlet +3",body="Aoidos' Hongreline +1",legs="Fili Rhingrave +3"})                                 -- dur+165
    sets.midcast['Honor March'] = set_combine(sets.midcast.SongEffect, {range="Marsyas",
        body="Aoidos' Hongreline +1",hands="Fili Manchettes +2",legs="Fili Rhingrave +3"})                                -- dur+165
    sets.midcast['Aria of Passion'] = set_combine(sets.midcast.SongEffect, {range="Loughnashade",
        body="Aoidos' Hongreline +2",legs="Inyanga Shalwar +1"})                                                          -- dur+165
    sets.midcast['Sentinel\'s Scherzo'] = set_combine(sets.midcast.SongEffect, {
        legs="Inyanga Shalwar +1",feet="Fili Cothurnes +3"})                                                              -- dur+164 *
    sets.midcast.BardSong = set_combine(sets.midcast.SongEffect, {body="Aoidos' Hongreline +2",legs="Inyanga Shalwar +1"})-- dur+165

    sets.midcast.Madrigal.FullHarp = set_combine(sets.midcast.Madrigal, {range="Daurdabla",feet="Fili Cothurnes +3"})     -- dur+165
    sets.midcast.Prelude.FullHarp = set_combine(sets.midcast.Prelude, {range="Daurdabla",body="Aoidos' Hongreline +1"})   -- dur+165
    sets.midcast.March.FullHarp   = set_combine(sets.midcast.March,   {range="Daurdabla",body="Aoidos' Hongreline +1"})   -- dur+165
    sets.midcast.Minuet.FullHarp  = set_combine(sets.midcast.Minuet,  {range="Daurdabla",
        body="Aoidos' Hongreline +2",legs="Inyanga Shalwar",feet="Fili Cothurnes +3"})                                    -- dur+167 +
    sets.midcast.Minne.FullHarp   = set_combine(sets.midcast.Minne,   {range="Daurdabla",
        body="Aoidos' Hongreline +2",feet="Fili Cothurnes +3"})                                                           -- dur+165
    sets.midcast.Mambo.FullHarp   = set_combine(sets.midcast.Mambo,   {range="Daurdabla",
        body="Aoidos' Hongreline +2",legs="Fili Rhingrave +3"})                                                           -- dur+165
    sets.midcast.Carol.FullHarp   = set_combine(sets.midcast.Carol,   {range="Daurdabla",
        body="Aoidos' Hongreline +2",feet="Fili Cothurnes +3"})                                                           -- dur+165
    sets.midcast.Ballad.FullHarp  = set_combine(sets.midcast.Ballad,  {range="Daurdabla",body="Aoidos' Hongreline +1"})   -- dur+165

    sets.midcast.LongMadrigal        = set_combine(sets.midcast.SongEffect, {head="Fili Calot +2"})                       -- dur+191
    sets.midcast.LongPrelude         = set_combine(sets.midcast.SongEffect, {back=gear.SongCape})                         -- dur+181
    sets.midcast.LongMarch           = set_combine(sets.midcast.SongEffect, {hands="Fili Manchettes +2"})                 -- dur+181
    sets.midcast.LongMinuet          = set_combine(sets.midcast.SongEffect, {body="Fili Hongreline +3"})                  -- dur+181
    sets.midcast.LongMinne           = set_combine(sets.midcast.SongEffect, {legs="Mousai Seraweels +1"})                 -- dur+174
    sets.midcast.LongMambo           = set_combine(sets.midcast.SongEffect, {feet="Mousai Crackows +1"})                  -- dur+176
    sets.midcast.LongCarol           = set_combine(sets.midcast.SongEffect, {hands="Mousai Gages +1"})                    -- dur+191
    sets.midcast.LongEtude           = set_combine(sets.midcast.SongEffect, {})                                           -- dur+171
    sets.midcast.LongBallad          = set_combine(sets.midcast.SongEffect, {legs="Fili Rhingrave +3"})                   -- dur+164
    sets.midcast.LongPaeon           = set_combine(sets.midcast.SongEffect, {head="Brioso Roundlet +3"})                  -- dur+191
    sets.midcast['Honor March'].Long = set_combine(sets.midcast.SongEffect, {range="Marsyas",
        body="Brioso Justaucorps +3",hands="Fili Manchettes +2",ring1=gear.Lstikini})                                     -- dur+191
    sets.midcast['Aria of Passion'].Long = set_combine(sets.midcast.SongEffect, {range="Loughnashade"})                   -- dur+171
    sets.midcast.LongBardSong = sets.midcast.SongEffect                                                                   -- dur+171
    sets.subkali = {sub="Kali"}

    sets.midcast.Mazurka = set_combine(sets.midcast.SongEffect, {range="Daurdabla"})
    sets.midcast.DummySong = {range="Daurdabla",legs="Nyame Flanchard"} -- Handled in job_post_midcast()

    sets.midcast.SongDebuff = {main="Carnwenhan",sub="Ammurapi Shield",range="Gjallarhorn",
        head="Brioso Roundlet +3",neck="Moonbow Whistle +1",ear1="Regal Earring",ear2="Fili Earring +1",
        body="Fili Hongreline +3",hands="Fili Manchettes +2",ring1=gear.Lstikini,ring2=gear.Rstikini,
        back="Null Shawl",waist="Null Belt",legs="Inyanga Shalwar +2",feet="Brioso Slippers +3"}                          -- dur+171%
    sets.midcast.SongDebuff.Resistant = set_combine(sets.midcast.SongDebuff, {legs="Fili Rhingrave +3"})                  -- dur+154%
    sets.midcast.Lullaby = set_combine(sets.midcast.SongDebuff, {hands="Brioso Cuffs +3"})                -- dur+181% (aoe), dur+191% (1)
    sets.midcast.Lullaby.Resistant  = set_combine(sets.midcast.Lullaby, {legs="Fili Rhingrave +3"})       -- dur+164% (aoe), dur+174% (1)
    sets.midcast.Lullaby.TH = set_combine(sets.midcast.Lullaby, sets.TreasureHunter, {range="Daurdabla",ammo=empty})
    sets.midcast['Magic Finale']    = set_combine(sets.midcast.SongDebuff.Resistant, {legs="Fili Rhingrave +3"})
    sets.midcast.Elegy                        = sets.midcast.SongDebuff
    sets.midcast.Elegy.Resistant              = sets.midcast.SongDebuff.Resistant
    sets.midcast.Threnody                     = set_combine(sets.midcast.SongDebuff, {body="Mousai Manteel +1"})          -- dur+177%
    sets.midcast.Threnody.Resistant           = sets.midcast.SongDebuff.Resistant
    sets.midcast['Pining Nocturne']           = sets.midcast.SongDebuff
    sets.midcast['Pining Nocturne'].Resistant = sets.midcast.SongDebuff.Resistant
    sets.midcast.Requiem                      = sets.midcast.SongDebuff
    sets.midcast.Requiem.Resistant            = sets.midcast.SongDebuff.Resistant
    sets.midcast['Maiden\'s Virelai']         = sets.midcast.SongDebuff
    sets.midcast.Lullaby.MaxDur               = set_combine(sets.midcast.Lullaby, {range="Marsyas"})      -- dur+181% (aoe), dur+201% (1)

    sets.midcast.Cure = {main="Daybreak",sub="Genmei Shield",
        head="Vanya Hood",neck="Loricate Torque +1",ear1="Genmei Earring",ear2="Mendicant's Earring",
        body="Chironic Doublet",hands="Inyanga Dastanas +2",ring1="Vocane Ring +1",ring2="Defending Ring",
        back="Moonbeam Cape",waist=gear.ElementalObi,legs="Fili Rhingrave +3",feet="Vanya Clogs"}
    sets.midcast.Curaga = sets.midcast.Cure
    sets.midcast.StatusRemoval = {}
    sets.midcast.Cursna = {neck="Debilis Medallion",hands="Inyanga Dastanas +2",
        ring1="Haoma's Ring",ring2="Haoma's Ring",feet="Vanya Clogs"}
    sets.cmp_belt  = {waist="Shinjutsu-no-Obi +1"}
    sets.gishdubar = {waist="Gishdubar Sash"}

    sets.midcast.EnhancingDuration = {main="Daybreak",sub="Ammurapi Shield",
        head="Telchine Cap",body="Telchine Chasuble",hands="Telchine Gloves",
        waist="Embla Sash",legs="Telchine Braconi",feet="Telchine Pigaches"}
    sets.midcast['Enhancing Magic'] = {main="Daybreak",sub="Ammurapi Shield",
        head="Telchine Cap",neck="Incanter's Torque",ear1="Andoaa Earring",ear2="Mimir Earring",
        body="Telchine Chasuble",hands="Inyanga Dastanas +2",ring1=gear.Lstikini,ring2=gear.Rstikini,
        back="Perimede Cape",waist="Embla Sash",legs="Shedir Seraweels",feet="Telchine Pigaches"}
    sets.midcast.Stoneskin = set_combine(sets.midcast.EnhancingDuration, {
        neck="Nodens Gorget",waist="Siegel Sash",legs="Shedir Seraweels"})
    sets.midcast.Aquaveil  = set_combine(sets.midcast.EnhancingDuration, {
        head="Chironic Hat",waist="Emphatikos Rope",legs="Shedir Seraweels"})
    sets.midcast.Regen     = set_combine(sets.midcast.EnhancingDuration, {head="Inyanga Tiara +2"})
    sets.midcast.FixedPotencyEnhancing = sets.midcast.EnhancingDuration
    sets.midcast.Klimaform = {}

    sets.midcast['Enfeebling Magic'] = {main="Carnwenhan",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
        head="Brioso Roundlet +3",neck="Null Loop",ear1="Regal Earring",ear2="Fili Earring +1",
        body="Brioso Justaucorps +3",hands="Kaykaus Cuffs +1",ring1=gear.Lstikini,ring2=gear.Rstikini,
        back="Null Shawl",waist="Null Belt",legs="Chironic Hose",feet="Fili Cothurnes +3"}
    sets.midcast.Dispelga = set_combine(sets.midcast['Enfeebling Magic'], {legs="Fili Rhingrave +3"}, sets.dispelga)
    sets.midcast['Absorb-TP'] = set_combine(sets.midcast['Enfeebling Magic'], {
        hands="Inyanga Dastanas +2",waist="Cornelia's Belt",legs="Fili Rhingrave +3"})
    sets.midcast['Absorb-TP'].Resistant = set_combine(sets.midcast['Absorb-TP'], {waist="Null Belt"})

    sets.midcast.Utsusemi = {main="Mafic Cudgel",sub="Genmei Shield",ammo="Staunch Tathlum +1",
        head="Null Masque",neck="Loricate Torque +1",ear1="Genmei Earring",ear2="Etiolation Earring",
        body="Ashera Harness",hands="Bunzi's Gloves",ring1="Vocane Ring +1",ring2="Defending Ring",
        back="Moonbeam Cape",waist="Cornelia's Belt",legs="Nyame Flanchard",feet="Nyame Sollerets"}

    -- Sets to return to when not performing an action.

    sets.idle = {main="Sangoma",sub="Genmei Shield",range="Loughnashade",
        head="Null Masque",neck="Bathy Choker +1",ear1="Infused Earring",ear2="Fili Earring +1",
        body="Fili Hongreline +3",hands="Bunzi's Gloves",ring1="Shadow Ring",ring2="Defending Ring",
        back=gear.MEVACape,waist="Null Belt",legs="Nyame Flanchard",feet="Fili Cothurnes +3"}
    sets.idle.Rf = {main="Daybreak",sub="Genmei Shield",
        head="Null Masque",neck="Sibyl Scarf",ear1="Genmei Earring",ear2="Fili Earring +1",
        body="Inyanga Jubbah +2",hands="Volte Gloves",ring1="Inyanga Ring",ring2=gear.Rstikini,
        back=gear.MEVACape,waist="Platinum Moogle Belt",legs="Inyanga Shalwar +2",feet="Inyanga Crackows +2"}
    sets.idle.Roller = set_combine(sets.idle, {ring1="Vocane Ring +1",ring2="Roller's Ring"})
    sets.latent_refresh = {waist="Fucho-no-obi"}
    sets.sphere = {body="Gyve Doublet"}
    sets.buff.doom = {neck="Nicander's Necklace",ring1="Eshmun's Ring",waist="Gishdubar Sash"}
    sets.buff.sleep = {}

    sets.defense.PDT = {main="Daybreak",sub="Genmei Shield",
        head="Null Masque",neck="Bathy Choker +1",ear1="Infused Earring",ear2="Fili Earring +1",
        body="Fili Hongreline +3",hands="Bunzi's Gloves",ring1="Shadow Ring",ring2="Defending Ring",
        back=gear.MEVACape,waist="Null Belt",legs="Nyame Flanchard",feet="Fili Cothurnes +3"}
    sets.defense.MDT = set_combine(sets.defense.PDT, {neck="Warder's Charm +1",ear1="Eabani Earring"})
    sets.defense.Eva = {main="Ternion Dagger +1",sub="Genmei Shield",range=gear.linos_qm,
        head="Null Masque",neck="Bathy Choker +1",ear1="Eabani Earring",ear2="Infused Earring",
        body="Nyame Mail",hands="Nyame Gauntlets",ring1="Shadow Ring",ring2="Defending Ring",
        back=gear.EVACape,waist="Null Belt",legs="Nyame Flanchard",feet="Hippomenes Socks +1"}
    sets.Kiting = {feet="Fili Cothurnes +3"}

    sets.engaged = {range=gear.linos_tp,
        head="Bunzi's Hat",neck="Bard's Charm +2",ear1="Telos Earring",ear2="Brutal Earring",
        body="Ashera Harness",hands="Bunzi's Gloves",ring1="Chirich Ring +1",ring2="Moonlight Ring",
        back=gear.TPCape,waist="Windbuffet Belt +1",legs="Volte Tights",feet="Volte Spats"}
    sets.engaged.Acc = set_combine(sets.engaged, {
        head="Bunzi's Hat",ear2="Crepuscular Earring",
        body="Ayanmo Corazza +2",hands="Ayanmo Manopolas +2",ring2="Ephramad's Ring",
        back="Null Shawl",waist="Null Belt",legs="Ayanmo Cosciales +2",feet="Ayanmo Gambieras +2"})
    sets.engaged.PDef        = set_combine(sets.engaged,          {ear2="Fili Earring +1",feet="Nyame Sollerets"})
    sets.engaged.Acc.PDef    = set_combine(sets.engaged.Acc,      {ring2="Defending Ring"})
	sets.engaged.DW          = set_combine(sets.engaged,          {ear1="Eabani Earring",waist="Reiki Yotai"})
	sets.engaged.DW.Acc      = set_combine(sets.engaged.Acc,      {ear1="Eabani Earring",waist="Reiki Yotai"})
	sets.engaged.DW.PDef     = set_combine(sets.engaged.PDef,     {ear1="Eabani Earring",waist="Reiki Yotai"})
	sets.engaged.DW.Acc.PDef = set_combine(sets.engaged.Acc.PDef, {ear1="Eabani Earring",waist="Reiki Yotai"})

    -- Sets that depend upon idle sets
    sets.midcast.FastRecast = set_combine(sets.idle.PDT, {})
    sets.midcast['Dia II'] = set_combine(sets.idle, sets.TreasureHunter, {ring2="Kishar Ring",waist="Obstinate Sash"})

    sets.lowhp = {
        head="Pixie Hairpin +1",neck="Bathy Choker +1",ear1="Infused Earring",ear2="Fili Earring +1",
        body=empty,hands=empty,ring1=empty,ring2=empty,
        back=empty,waist="Null Belt",feet="Fili Cothurnes +3"}
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_precast(spell, action, spellMap, eventArgs)
    if state.Buff.Nightingale and spell.type == 'BardSong' then
        if spell.english == 'Honor March' then
            equip(sets.midcast['Honor March'])
        elseif spell.english == 'Aria of Passion' then
            equip(sets.midcast['Aria of Passion'])
        end
        eventArgs.handled = true
    elseif spell.english == "Pianissimo" and buffactive.Pianissimo then
        send_command('cancel Pianissimo')
        eventArgs.cancel = true
    elseif S{'BarElement','Protect','Shell'}:contains(spellMap) or spell.english == 'Flash' then
        eventArgs.handled = true
    end
end

-- Run after the general precast() is done.
function job_post_precast(spell, action, spellMap, eventArgs)
    if spell.type == 'WeaponSkill' then
        if info.magic_ws:contains(spell.english) then
            if not sets.precast.WS[spell.english] then
                equip(sets.precast.WS.Magical)
            end
            equip(resolve_ele_belt(spell, sets.ele_obi))
        end
        if buffactive['elvorseal'] and player.inventory["Angantyr Boots"] then equip({feet="Angantyr Boots"}) end
    elseif spell.english == 'Weapon Bash' then
        enable('main','sub')
        equip(sets.weapons.Staff)
        state.OffenseMode:set('None')
        hud_update_on_state_change('Offense Mode')
    end
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_midcast(spell, action, spellMap, eventArgs)
    -- Let these spells skip midcast sets by replacing it with the default idle set.
    -- This should make the character only blink once (for precast) rather than twice.
    if S{'Warp','Warp II','Escape'}:contains(spell.english)
    or npcs.Trust:contains(spell.english)
    or spellMap == 'Teleport' then
        equip(sets.idle[state.IdleMode.value] or sets.idle)
        eventArgs.handled = true
    end
end

function job_post_midcast(spell, action, spellMap, eventArgs)
    if spell.type == 'BardSong' then
        -- Handle special cases for dummy songs
        if state.ExtraSongsMode.value == 'Dummy' then
            equip(set_combine(sets.idle[state.IdleMode.value] or sets.idle, sets.midcast.DummySong))
        elseif state.ExtraSongsMode.value == 'FullHarp' then
            if sets.midcast[spellMap] and sets.midcast[spellMap].FullHarp then
                equip(sets.midcast[spellMap].FullHarp)
            else
                equip(set_combine(sets.midcast.SongEffect, sets.midcast.DummySong))
            end
        end
        state.ExtraSongsMode:reset()
        hud_update_on_state_change('Extra Songs')

        if S{'Honor March','Aria of Passion'}:contains(spell.english) then
            if state.LongSongs.value or state.Buff.Marcato then
                equip(sets.midcast[spell.english].Long)
            end
        end

        if state.Buff.Troubadour or state.Buff['Elemental Seal'] then
            -- Some spells
            if spellMap == 'Lullaby' then
                equip(sets.midcast[spellMap].MaxDur)
            end
        end

        if spell.english == 'Horde Lullaby' and state.DefenseMode.value == 'Physical' and state.PhysicalDefenseMode.value == 'Eva' then
            equip(sets.defense.Eva, {range="Daurdabla"})
            return
        elseif state.HarpLullaby.value and S{'Horde Lullaby','Horde Lullaby II'}:contains(spell.english) then
            equip({range="Daurdabla"})
            if state.TreasureMode and state.TreasureMode.value ~= 'None' and spell.english == 'Horde Lullaby' then
                equip(sets.midcast.Lullaby.TH)
            end
        end

        if S{'NIN','DNC'}:contains(player.sub_job) then
            equip(sets.subkali)
        end

    elseif spell.target.type == 'SELF' then
        if S{'Cure','Refresh'}:contains(spellMap) then
            equip({waist="Gishdubar Sash"})
        elseif spell.english == 'Cursna' then
            equip(sets.buff.doom)
        end
    elseif spell.english == 'Absorb-TP' and spell.target.name and spell.target.name == 'Aminon' then
        equip(sets.midcast['Absorb-TP'].Resistant)
    end
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_aftercast(spell, action, spellMap, eventArgs)
    if spell.interrupted then
        --send_command('wait 0.5;gs c update')
        interrupted_message(spell)
    else
        if 'Lullaby' == spellMap then
            lullaby_timer(spell)
        elseif spell.english == 'Impact' then
            debuff_timer(spell, 180)
        elseif spell.english == 'Dark Threnody II' and spell.target.name and spell.target.name == 'Aminon' then
            debuff_timer(spell, 578)
        elseif S{'Pianissimo','Tenuto','Nightingale','Troubadour','Marcato','Clarion Call','Soul Voice'}:contains(spell.english) then
            eventArgs.handled = true
        elseif spell.english == 'Dia II' and state.DiaMsg.value then
            if spell.target.name and spell.target.type == 'MONSTER' then
                send_command('input /p Dia II /')
            end
        elseif spell.type == 'WeaponSkill' then
            if state.WSMsg.value or spell.english == 'Shadowstitch' then
                send_command('input /p '..spell.english)
            end
        end
        --if state.Buff.Nightingale and spell.type == 'BardSong' then
        --    -- skip aftercast swaps so rapid singing isn't broken
        --    eventArgs.handled = true
        --end
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for non-casting events.
-------------------------------------------------------------------------------------------------------------------

-- Called when the player's status changes.
function job_status_change(newStatus, oldStatus, eventArgs)
    if newStatus == 'Engaged' or oldStatus == 'Engaged' then
        -- Don't swap gear mid song if the engaged target dies
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
end

-- Handle notifications of general user state change.
function job_state_change(stateField, newValue, oldValue)
    if stateField == 'Offense Mode' then
        enable('main','sub','ammo')
        if newValue ~= 'None' then
            equip(sets.weapons[state.CombatWeapon.value])
            disable('main','sub','ammo')
        end
        handle_equipping_gear(player.status)
    elseif stateField == 'Combat Weapon' then
        info.ws_binds:bind(state.CombatWeapon)
        if state.OffenseMode.value ~= 'None' then
            enable('main','sub','ammo')
            equip(sets.weapons[state.CombatWeapon.value])
            disable('main','sub','ammo')
        end
    elseif stateField == 'Defense Mode' then
        if newValue ~= 'None' then
            handle_equipping_gear(player.status)
        end
    elseif stateField == 'Fishing Gear' then
        if newValue then
            sets.Fishing = {range="Ebisu Fishing Rod +1",ammo=empty,
                head="Tlahtlamah Glasses",neck="Fisher's Torque",
                body="Fisherman's Smock",hands="Angler's Gloves",ring1="Noddy Ring",ring2="Puffin Ring",
                waist="Fisher's Rope",legs="Angler's Hose",feet="Waders"}
            equip(sets.Fishing)
            disable('ring1','ring2')
            send_command('bind ^delete input /fish')
        else
            enable('ring1','ring2')
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
        if  not S{'Erase','Phalanx','Stoneskin','Aquaveil'}:contains(spell.english)
        and not S{'BarElement','BarStatus','Regen','Teleport'}:contains(default_spell_map) then
            return "FixedPotencyEnhancing"
        end
    elseif spell.type == 'BardSong' and state.LongSongs.value and default_spell_map ~= 'Mazurka' then
        if sets.midcast[default_spell_map] then
            return "Long" .. default_spell_map
        else
            return "LongBardSong"
        end
    end
end

-- Modify the default idle set after it was constructed.
function customize_idle_set(idleSet)
    if state.DefenseMode.value == 'None' then
        if player.mpp < 51 and state.IdleMode.value == 'Rf' and S{'WHM','SCH','RDM'}:contains(player.sub_job) then
            idleSet = set_combine(idleSet, sets.latent_refresh)
        end
        if state.SphereIdle.value then
            idleSet = set_combine(idleSet, sets.sphere)
        end
        if state.Fishing.value then
            idleSet = set_combine(idleSet, sets.Fishing)
        end
    end
    if state.Buff.doom then
        idleSet = set_combine(idleSet, sets.buff.doom)
    end
    if state.Buff.sleep and not buffactive["Sublimation: Activated"] then
        idleSet = set_combine(idleSet, sets.buff.sleep)
    end
    return idleSet
end

-- Modify the default melee set after it was constructed.
function customize_melee_set(meleeSet)
    if state.DefenseMode.value == 'None' then
        meleeSet = set_combine(meleeSet, sets.weapons[state.CombatWeapon.value])
    end
    if state.Buff.doom then
        meleeSet = set_combine(meleeSet, sets.buff.doom)
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
    end
end

-- Function to display the current relevant user state when doing an update.
function display_current_job_state(eventArgs)
    local msg = ''

    if state.OffenseMode.value ~= 'None' then
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

    if state.ExtraSongsMode.value ~= 'None' then
        msg = msg .. ' Extra[' .. state.ExtraSongsMode.value .. ']'
    end
    if state.HarpLullaby.value then
        msg = msg .. ' HarpLullaby'
    end
    if state.LongSongs.value then
        msg = msg .. ' LongSongs'
    end
    if state.WSMsg.value then
        msg = msg .. ' WSMsg'
    end
    if state.DiaMsg.value then
        msg = msg .. ' DiaMsg'
    end
    if state.TreasureMode and state.TreasureMode.value ~= 'None' then
        msg = msg .. ' TH+3'
    end
    if state.Fishing.value then
        msg = msg .. ' Fishing'
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
    if cmdParams[1] == 'dummy' then
        if S{'1','2'}:contains(cmdParams[2]) then
            state.ExtraSongsMode:set('Dummy')
            if cmdParams[3] then
                send_command('input /ma ' .. state.DummySongs[cmdParams[2]] .. ' ' .. cmdParams[3])
            else
                if state.Buff.Pianissimo then
                    if S{'SELF','PLAYER'}:contains(player.target.type) then
                        send_command('input /ma ' .. state.DummySongs[cmdParams[2]] .. ' ' .. player.target.name)
                    else
                        send_command('input /ma ' .. state.DummySongs[cmdParams[2]] .. ' <stpc>')
                    end
                else
                    send_command('input /ma ' .. state.DummySongs[cmdParams[2]])
                end
            end
        else
            add_to_chat(123, 'Invalid dummy command.')
        end
    elseif cmdParams[1] == 'ListWS' then
        info.ws_binds:print('ListWS:')
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
--    set_macro_page(1, 11)
--end

-- returns a list for use with make_keybind_list
function job_keybinds()
    local bind_command_list = L{
        'bind !^l input /lockstyleset 3',
        'bind %`   gs c update user',
        'bind F9   gs c cycle OffenseMode',
        'bind !F9  gs c reset OffenseMode',
        'bind @F9  gs c cycle WeaponskillMode',
        'bind F10  gs c cycle CastingMode',
        'bind !F10 gs c reset CastingMode',
        'bind F11  gs c cycle IdleMode',
        'bind !F11 gs c reset IdleMode',
        'bind @F11 gs c toggle Kiting',
        'bind ^space gs c cycle HybridMode',
        'bind !space gs c set DefenseMode Physical',
        'bind @space gs c set DefenseMode Magical',
        'bind !@space gs c reset DefenseMode',
        'bind  @z  gs c cycle PhysicalDefenseMode',
        'bind %~z  gs c toggle Kiting',
        'bind  !w  gs c   set OffenseMode Normal',
        'bind  @w  gs c   set OffenseMode Acc',
        'bind  !@w gs c reset OffenseMode',
        'bind  !^q gs c weap Carn',
        'bind ~!^q gs c set CombatWeapon CarnGleti',
        'bind  !^w gs c weap Aen',
        'bind ~!^w gs c set CombatWeapon AenTwash',
        'bind  ^@w gs c set CombatWeapon Staff',
        'bind ~^@w gs c weap Taur',
        'bind  !^e gs c weap Twash',
        'bind ~!^e gs c set CombatWeapon TwashDW',
        'bind  !^r gs c weap Naeg',
        'bind ~!^r gs c set CombatWeapon NaegDW',
        'bind ^\\\\ gs c toggle WSMsg',
        'bind ^@\\\\ gs c toggle DiaMsg',
        'bind !F12 gs c cycle TreasureMode',
        'bind !z  gs c toggle HarpLullaby',
        'bind ^z  gs c toggle SphereIdle',
        'bind !@z gs c toggle LongSongs',
        'bind !c  gs c set ExtraSongsMode FullHarp',
        'bind !@c gs c set ExtraSongsMode Dummy',
        'bind ^c gs c reset ExtraSongsMode',

        'bind !^` input /ja "Soul Voice" <me>',
        'bind ^@` input /ja "Clarion Call" <me>',
        'bind ^@tab input /ja Troubadour <me>',
        'bind ^@q input /ja Nightingale <me>',
        'bind ^` input /ja Marcato <me>',
        'bind @tab input /ja Pianissimo <me>',
        'bind @q input /ja Tenuto <me>',

        'bind ^tab input /ma "Magic Finale"',
        'bind ^q input /ma Dispelga',
        'bind !@` input /ma "Chocobo Mazurka" <stpc>',

        'bind ^1  input /ma "Carnage Elegy"',
        'bind ^@1 input /ma "Battlefield Elegy"',
        'bind ^2  input /ma "Foe Lullaby II"',
        'bind ^3  input /ma "Horde Lullaby II"',
        'bind ^@3 input /ma "Foe Requiem VII"',
        'bind ^4  input /ma "Pining Nocturne"',
        'bind ~^1  input /ma "Carnage Elegy" <stnpc>',
        'bind ~^@1 input /ma "Battlefield Elegy" <stnpc>',
        'bind ~^2  input /ma "Foe Lullaby II" <stnpc>',
        'bind ~^3  input /ma "Horde Lullaby II" <stnpc>',
        'bind ~^@3 input /ma "Foe Requiem VII" <stnpc>',
        'bind ~^4  input /ma "Pining Nocturne" <stnpc>',

        'bind !3 gs c dummy 1',
        'bind !4 gs c dummy 2',
        'bind !5 input /ma "Honor March" <stpc>',
        'bind ^5 input /ma "Victory March" <stpc>',
        'bind ^@5 input /ma "Advancing March" <stpc>',
        'bind ~!6 input /ma "Aria of Passion" <stpc>',
        'bind !6 input /ma "Valor Minuet V" <stpc>',
        'bind ^6 input /ma "Valor Minuet IV" <stpc>',
        'bind ^@6 input /ma "Valor Minuet III" <stpc>',
        'bind !7 input /ma "Blade Madrigal" <stpc>',
        'bind ^7 input /ma "Sword Madrigal" <stpc>',
        'bind !8 input /ma "Archer\'s Prelude" <stpc>',
        'bind ^8 input /ma "Hunter\'s Prelude" <stpc>',
        'bind !9 input /ma "Mage\'s Ballad III" <stpc>',
        'bind ^9 input /ma "Mage\'s Ballad II" <stpc>',
        'bind ^@9 input /ma "Mage\'s Ballad" <stpc>',
        'bind !0 input /ma "Knight\'s Minne V" <stpc>',
        'bind ^0 input /ma "Knight\'s Minne IV" <stpc>',
        'bind ^@0 input /ma "Knight\'s Minne III" <stpc>',
        'bind !- input /ma "Army\'s Paeon VI" <stpc>',
        'bind ^- input /ma "Army\'s Paeon V" <stpc>',
        'bind ^@- input /ma "Army\'s Paeon IV" <stpc>',
        'bind != input /ma "Dragonfoe Mambo" <stpc>',
        'bind ^= input /ma "Sheepfoe Mambo" <stpc>',
        'bind !backspace input /ma "Sentinel\'s Scherzo" <stpc>',
        'bind !^backspace input /ma "Goddess\'s Hymnus" <stpc>',
        'bind !@backspace input /ma "Maiden\'s Virelai"',

        'bind !@5 input /ma "Earth Threnody II"',
        'bind !@6 input /ma "Water Threnody II"',
        'bind !@7 input /ma "Wind Threnody II"',
        'bind !@8 input /ma "Fire Threnody II"',
        'bind !@9 input /ma "Ice Threnody II"',
        'bind !@0 input /ma "Ltng. Threnody II"',
        'bind !@- input /ma "Light Threnody II"',
        'bind !@= input /ma "Dark Threnody II"',

        'bind !b input /ma "Horde Lullaby"'}

    if     player.sub_job == 'WHM' then
        bind_command_list:extend(L{
            'bind @` input /ja "Divine Seal" <me>',
            'bind !1 input /ma "Cure III" <stpc>',
            'bind !2 input /ma "Cure IV" <stpc>',
            'bind !@1 input /ma Curaga',
            'bind !@2 input /ma "Curaga II"',
            'bind !@3 input /ma "Curaga III"',
            'bind ^@2 input /ma "Dia II"',
            'bind ^@4 input /ma Silence',
            'bind ~^@2 input /ma "Dia II" <stnpc>',
            'bind ~^@4 input /ma Silence <stnpc>',
            'bind !d input /ma Flash',
            'bind ~!d input /ma Flash <stnpc>',
            'bind !@g input /ma Stoneskin <me>',
            'bind @c input /ma Blink <me>',
            'bind @v input /ma Aquaveil <me>',
            'bind !@b input /ma Banishga <stnpc>',
            'bind !f input /ma Haste',
            'bind @1 input /ma Poisona',
            'bind @2 input /ma Paralyna',
            'bind @3 input /ma Blindna',
            'bind @4 input /ma Silena',
            'bind @5 input /ma Stona',
            'bind @6 input /ma Viruna',
            'bind @7 input /ma Cursna',
            'bind @F1 input /ma Erase',
            'bind ~^x  input /ma Sneak <me>',
            'bind ~!^x input /ma Invisible <me>'})
    elseif player.sub_job == 'BLM' then
        bind_command_list:extend(L{
            'bind @` input /ja "Elemental Seal" <me>',
            'bind !d input /ma Stun',
            'bind ~!d input /ma Stun <stnpc>'})
    elseif player.sub_job == 'DRK' then
        bind_command_list:extend(L{
            'bind !e input /ma "Absorb-TP"',
            'bind !d input /ma Stun',
            'bind !@d input /ja "Weapon Bash"',
            'bind ~!d input /ma Stun <stnpc>'})
    elseif player.sub_job == 'DNC' then
        bind_command_list:extend(L{
            'bind !1 input /ja "Curing Waltz II" <stpc>',
            'bind !2 input /ja "Curing Waltz III" <stpc>',
            'bind @F1 input /ja "Healing Waltz" <stpc>',
            'bind @F2 input /ja "Divine Waltz" <me>',
            'bind !v input /ja "Spectral Jig" <me>',
            'bind !d input /ja "Violent Flourish"',
            'bind !@d input /ja "Animated Flourish"',
            'bind !f input /ja "Haste Samba" <me>',
            'bind !@f input /ja "Reverse Flourish" <me>',
            'bind !e input /ja "Box Step"',
            'bind !@e input /ja Quickstep'})
    elseif player.sub_job == 'NIN' then
        bind_command_list:extend(L{
            'bind !1 input /target <stpc>',
            'bind !2 input /target <stpc>',
            'bind !e input /ma "Utsusemi: Ni" <me>',
            'bind !@e input /ma "Utsusemi: Ichi" <me>',
            'bind ~^x  input /ma "Monomi: Ichi" <me>',
            'bind ~!^x input /ma "Tonko: Ni" <me>'})
    elseif player.sub_job == 'PLD' then
        bind_command_list:extend(L{
            'bind !1 input /ma "Cure III" <stpc>',
            'bind !2 input /ma "Cure IV" <stpc>',
            'bind !e input /ja "Shield Bash"',
            'bind @e input /ja Cover <stpc>',
            'bind !@e input /ja "Holy Circle" <me>',
            'bind !g input /ja Sentinel <me>',
            'bind !d input /ma Flash',
            'bind ~!d input /ma Flash <stnpc>',
            'bind !@b input /ma Banishga <stnpc>',
        })
    elseif player.sub_job == 'SMN' then
        bind_command_list:extend(L{
            'bind !v input //mewinglullaby',
            'bind !b input //caitsith',
            'bind !@b input //release',
            'bind !n input //retreat'})
    end

    return bind_command_list
end

-- Called from job_aftercast
function lullaby_timer(spell)
    local dur = 0

    if      spell.english == 'Foe Lullaby'    or spell.english == 'Horde Lullaby' then
        dur = 30
    elseif  spell.english == 'Foe Lullaby II' or spell.english == 'Horde Lullaby II' then
        dur = 60
    end

    -- gear sets have different duration boosts, and are selected by m.acc level (+5% for the 1200 job point gift)
    -- the HarpLullaby toggle overrides instrument choice as well (dur: horn+40%, flute+50%, harp+30%)
    if state.Buff.Troubadour or state.Buff['Elemental Seal'] then
        -- dur +201%
        if state.HarpLullaby.value and spell.english:startswith('Horde') then
            dur = math.floor(dur * 2.81)    -- [base]3:08, [NT]6:16, [NT+M]6:36, [NT+CC]7:36, [NT+CC+M]7:56
        else
            dur = math.floor(dur * 3.01)    -- [base]3:20, [NT]6:40, [NT+M]7:00, [NT+CC]8:00, [NT+CC+M]8:20
        end
    elseif state.CastingMode.value == 'Normal' then
        -- dur +191%
        if state.HarpLullaby.value and spell.english:startswith('Horde') then
            dur = math.floor(dur * 2.81)    -- [base]3:08
        else
            dur = math.floor(dur * 2.91)    -- [base]3:14
        end
    elseif state.CastingMode.value == 'Resistant' then
        -- dur +160%
        if state.HarpLullaby.value and spell.english:startswith('Horde') then
            dur = math.floor(dur * 2.64)    -- [base]2:58
        else
            dur = math.floor(dur * 2.74)    -- [base]3:04
        end
    end

    -- lullaby and clarion call job point bonuses are doubled by troubadour
    dur = dur + 20
    if state.Buff['Clarion Call'] then
        dur = dur + 40
    end

    -- troubadour doubles duration multiplicatively
    if state.Buff.Troubadour then
        dur = dur * 2
    end

    -- marcato job point bonus in not boosted by troubadour
    if state.Buff.Marcato and not state.Buff['Soul Voice'] then
        dur = dur + 20
    end

    debuff_timer(spell, dur)
end

function init_state_text()
    if hud then return end

    local dummy_text_settings = {pos={x=130,y=680},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local hyb_text_settings   = {pos={x=130,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local def_text_settings   = {pos={x=172,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local off_text_settings   = {pos={x=172,y=697},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}

    hud = {texts=T{}}
    hud.texts.dummy_text = texts.new('DummySong',      dummy_text_settings)
    hud.texts.hyb_text   = texts.new('initializing..', hyb_text_settings)
    hud.texts.def_text   = texts.new('initializing..', def_text_settings)
    hud.texts.off_text   = texts.new('initializing..', off_text_settings)

    -- update infrequently changing text boxes in job_state_change or where they are changed
    function hud_update_on_state_change(stateField)
        if not hud then init_state_text() end

        if not stateField or stateField == 'Extra Songs' then
            hud.texts.dummy_text:visible((state.ExtraSongsMode.value ~= 'None'))
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
