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

    include('Mote-TreasureHunter')
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
    state.OffenseMode:options('None','Normal','Acc')                    -- Cycle with F9, will swap weapon
    state.HybridMode:options('Normal','PDef')                           -- Cycle with ^F9
    state.CastingMode:options('Normal','Resistant')                     -- Cycle with F10
    state.IdleMode:options('Normal','Refresh','PDT','MEVA')             -- Cycle with F11, reset with !F11
    state.CombatWeapon = M{['description']='Combat Weapon'}             -- Cycle with @F9
    if S{'DNC','NIN'}:contains(player.sub_job) then
        state.CombatWeapon:options('CarnTern','AenBlur','AenTwash','TwashCent','NaegCent','NaegTern','Xoanon')
		state.CombatForm:set('DW')
    else
        state.CombatWeapon:options('Carn','Aeneas','Twashtar','Naegling','Xoanon')
		state.CombatForm:reset()
    end
    state.ExtraSongsMode = M{['description']='Extra Songs','None','Dummy','FullHarp'}  -- Set/unset with !c/!@c
    state.DummySongs = {['1']="Bewitching Etude",['2']="Enchanting Etude"}

    state.HarpLullaby = M(true,  'Harp Lullaby Radius')                 -- Toggle with !z
    state.ZendikIdle  = M(false, 'Zendik Sphere')                       -- toggle with @z
    state.LongSongs   = M(false, 'Uneven Songs')                        -- Toggle with !@z
    state.WSMsg       = M(false, 'WS Message')                          -- Toggle with ^\
    state.DiaMsg      = M(false, 'Dia Message')                         -- Toggle with ^@\
    state.Fishing     = M(false, 'Fishing Gear')
    init_state_text()

    info.magic_ws = S{'Aeolian Edge','Cyclone','Gust Slash','Energy Steal','Energy Drain',
                      'Burning Blade','Red Lotus Blade','Shining Blade','Seraph Blade','Sanguine Blade',
                      'Rock Crusher','Earth Crusher','Starburst','Sunburst','Cataclysm'}

    -- Mote-libs handle obis, gorgets, and other elemental things.
    -- These are default fallbacks if situationally appropriate gear is not available.
    gear.default.obi_waist = "Flume Belt +1"                -- used in sets.midcast.Cure and friends

    -- Augmented items get variables for convenience and specificity
    gear.chir_feet_ma = {name="Chironic Slippers", augments={'"Mag.Atk.Bns."+30','DEX+10','Mag. Acc.+14 "Mag.Atk.Bns."+14'}}
    gear.chir_feet_th = {name="Chironic Slippers",
        augments={'"Mag.Atk.Bns."+13','Accuracy+7','"Treasure Hunter"+1','Accuracy+19 Attack+19','Mag. Acc.+19 "Mag.Atk.Bns."+19'}}
    gear.Lstikini = {name="Stikini Ring +1", bag="wardrobe2"}
    gear.Rstikini = {name="Stikini Ring +1", bag="wardrobe3"}
    gear.SongCape = {name="Intarabus's Cape",
        augments={'CHR+20','Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+10','"Fast Cast"+10','Phys. dmg. taken-10%'}}
    gear.TPCape   = {name="Intarabus's cape",
        augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Dbl.Atk."+10','Phys. dmg. taken-10%'}}
    gear.RudraCape   = {name="Intarabus's Cape",
        augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','Weapon skill damage +10%','Phys. dmg. taken-10%'}}
    gear.RimeCape   = {name="Intarabus's Cape",
        augments={'CHR+20','Accuracy+20 Attack+20','CHR+10','Weapon skill damage +10%','Phys. dmg. taken-10%'}}
    gear.MEVACape = {name="Intarabus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Phys. dmg. taken-10%'}}

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
            'bind !^d input /ws "Shadowstitch"'},
        ['Sword']=L{
            'bind !^1|%1 input /ws "Sanguine Blade"',
            'bind !^3|%3 input /ws "Savage Blade"',
            'bind !^6|%6 input /ws "Circle Blade"',
            'bind !^d input /ws "Flat Blade"'},
        ['Staff']=L{
            'bind !^1|%1 input /ws "Shell Crusher"',
            'bind !^2|%2 input /ws "Shattersoul"',
            'bind !^3|%3 input /ws "Retribution"',
            'bind !^4|%4 input /ws "Spirit Taker"',
            'bind !^6|%6 input /ws "Cataclysm"'}},
        {['Carn']='Dagger',['CarnTern']='Dagger',['Twashtar']='Dagger',['TwashCent']='Dagger',
         ['Aeneas']='Dagger',['AenTwash']='Dagger',['AenBlur']='Dagger',
         ['Naegling']='Sword',['NaegCent']='Sword',['NaegTern']='Sword',['Xoanon']='Staff'})
    info.ws_binds:bind(state.CombatWeapon)
    send_command('bind %\\\\ gs c ListWS')

    info.recast_ids = L{{name="N",id=109},{name="T",id=110},{name="M",id=48}}
    if     player.sub_job == 'WHM' then
        info.recast_ids:append({name="D.Seal",id=26})
    elseif player.sub_job == 'SCH' then
        info.recast_ids:append({name="Strats",id=231})
    elseif player.sub_job == 'BLM' then
        info.recast_ids:append({name="E.Seal",id=38})
    end

    select_default_macro_book()
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
    sets.weapons.Carn      = {main="Carnwenhan",sub="Genmei Shield"}
    sets.weapons.Aeneas    = {main="Aeneas",sub="Genmei Shield"}
    sets.weapons.Twashtar  = {main="Twashtar",sub="Genmei Shield"}
    sets.weapons.Tauret    = {main="Tauret",sub="Genmei Shield"}
    sets.weapons.CarnTern  = {main="Carnwenhan",sub="Ternion Dagger +1"}
    sets.weapons.AenBlur   = {main="Aeneas",sub="Blurred Knife +1"}
    sets.weapons.AenTwash  = {main="Aeneas",sub="Twashtar"}
    sets.weapons.TwashBlur = {main="Twashtar",sub="Blurred Knife +1"}
    sets.weapons.TwashCent = {main="Twashtar",sub="Centovente"}
    sets.weapons.Naegling  = {main="Naegling",sub="Centovente"}
    sets.weapons.NaegTern  = {main="Naegling",sub="Ternion Dagger +1"}
    sets.weapons.NaegCent  = {main="Naegling",sub="Centovente"}
    sets.weapons.Xoanon    = {main="Xoanon",sub="Bloodrain Strap"}
    sets.weapons.Sari      = {main="Taming Sari",sub="Genmei Shield"}
    sets.TreasureHunter = {head="Volte Cap",waist="Chaac Belt",feet=gear.chir_feet_th}

    -- Precast Sets

    sets.precast.JA.Nightingale = {feet="Bihu Slippers +3"}
    sets.precast.JA.Troubadour = {body="Bihu Justaucorps +3"}
    sets.precast.JA['Soul Voice'] = {legs="Bihu Cannions +3"}

    sets.precast.FC = {main="Kali",sub="Genmei Shield",
        head="Nahtirah Hat",neck="Orunmila's Torque",ear1="Loquacious Earring",ear2="Etiolation Earring",
        body="Inyanga Jubbah +2",hands="Leyline Gloves",ring2="Kishar Ring",
        back=gear.SongCape,waist="Embla Sash",legs="Ayanmo Cosciales +2",feet="Telchine Pigaches"}
    -- cast time -74%
    sets.precast.FC.Cure = set_combine(sets.precast.FC, {ear2="Mendicant's Earring",body="Heka's Kalasiris",feet="Vanya Clogs"})
    sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {waist="Siegel Sash"})
    sets.precast.FC.BardSong = set_combine(sets.precast.FC, {head="Fili Calot +1",body="Brioso Justaucorps +3"})
    sets.precast.FC['Honor March'] = set_combine(sets.precast.FC.BardSong, {range="Marsyas"})
    sets.dispelga = {main="Daybreak",sub="Ammurapi Shield"}
    sets.precast.FC.Dispelga = set_combine(sets.precast.FC, sets.dispelga)

    sets.precast.Step = {range="Linos",
        head="Ayanmo Zucchetto +2",neck="Combatant's Torque",ear1="Telos Earring",ear2="Dignitary's Earring",
        body="Ayanmo Corazza +2",hands="Ayanmo Manopolas +2",ring1="Cacoethic Ring +1",ring2="Ilabrat Ring",
        back=gear.TPCape,waist="Grunfeld Rope",legs="Ayanmo Cosciales +2",feet="Ayanmo Gambieras +2"}
    sets.precast.JA['Violent Flourish'] = set_combine(sets.precast.Step, {
        neck="Sanctity Necklace",ring1="Etana Ring",waist="Eschan Stone"})

    sets.precast.WS = {range="Linos",
        head="Ayanmo Zucchetto +2",neck="Bard's Charm +2",ear1="Telos Earring",ear2="Moonshade Earring",
        body="Bihu Justaucorps +3",hands="Ayanmo Manopolas +2",ring1="Hetairoi Ring",ring2="Ilabrat Ring",
        back=gear.TPCape,waist="Fotia Belt",legs="Ayanmo Cosciales +2",feet="Ayanmo Gambieras +2"}
    sets.precast.WS['Evisceration'] = set_combine(sets.precast.WS, {})
    sets.precast.WS['Exenterator'] = set_combine(sets.precast.WS, {ear2="Brutal Earring"})
    sets.precast.WS.Rudras = set_combine(sets.precast.WS, {ear1="Ishvara Earring",ring1="Petrov Ring",
        back=gear.RudraCape,waist="Grunfeld Rope",legs="Lustratio Subligar +1",feet="Lustratio Leggings +1"})
    sets.precast.WS['Rudra\'s Storm'] = sets.precast.WS.Rudras
    sets.precast.WS['Savage Blade'] = {range="Linos",
        head="Bihu Roundlet +3",neck="Bard's Charm +2",ear1="Regal Earring",ear2="Moonshade Earring",
        body="Bihu Justaucorps +3",hands="Ayanmo Manopolas +2",ring1=gear.Lstikini,ring2="Rufescent Ring",
        back=gear.RudraCape,waist="Grunfeld Rope",legs="Bihu Cannions +3",feet="Ayanmo Gambieras +2"}
    sets.precast.WS['Mordant Rime'] = {range="Linos",
        head="Bihu Roundlet +3",neck="Bard's Charm +2",ear1="Telos Earring",ear2="Regal Earring",
        body="Bihu Justaucorps +3",hands="Bihu Cuffs +3",ring1="Metamorph Ring +1",ring2="Ilabrat Ring",
        back=gear.RimeCape,waist="Grunfeld Rope",legs="Bihu Cannions +3",feet="Bihu Slippers +3"}
    sets.precast.WS['Aeolian Edge'] = set_combine(sets.precast.WS, {
        head="Chironic Hat",neck="Fotia Gorget",ear1="Friomisi Earring",ear2="Hecate's Earring",
        body="Chironic Doublet",hands="Chironic Gloves",ring1="Metamorph Ring +1",ring2="Ilabrat Ring",
        back=gear.RudraCape,waist="Fotia Belt",legs="Lengo Pants",feet=gear.chir_feet_ma})
    sets.precast.WS['Cyclone'] = set_combine(sets.precast.WS['Aeolian Edge'], {})
    sets.precast.WS['Cataclysm'] = set_combine(sets.precast.WS['Aeolian Edge'], {head="Pixie Hairpin +1",ring2="Archon Ring"})
    sets.precast.WS['Energy Drain'] = set_combine(sets.precast.WS['Cataclysm'], {})
    sets.precast.WS['Sanguine Blade'] = set_combine(sets.precast.WS['Cataclysm'], {})
    sets.orpheus = {waist="Orpheus's Sash"}
    sets.ele_obi = {waist="Hachirin-no-Obi"}

    -- Midcast Sets

    sets.midcast.SongEffect = {main="Carnwenhan",sub="Genmei Shield",range="Gjallarhorn",
        head="Fili Calot +1",neck="Moonbow Whistle +1",ear1="Genmei Earring",ear2="Etiolation Earring",
        body="Fili Hongreline +1",hands="Fili Manchettes +1",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.SongCape,waist="Flume Belt +1",legs="Inyanga Shalwar +2",feet="Brioso Slippers +3"}                     -- dur+169

    sets.midcast.Madrigal = set_combine(sets.midcast.SongEffect, {
        head="Fili Calot +1",body="Inyanga Jubbah +2",back=gear.SongCape,feet="Fili Cothurnes +1"})                       -- dur+162
    sets.midcast.Prelude  = set_combine(sets.midcast.SongEffect, {
        body="Inyanga Jubbah +2",back=gear.SongCape,legs="Inyanga Shalwar"})                                              -- dur+162
    sets.midcast.March    = set_combine(sets.midcast.SongEffect, {
        body="Inyanga Jubbah +2",hands="Fili Manchettes +1",legs="Inyanga Shalwar"})                                      -- dur+162
    sets.midcast.Minuet   = set_combine(sets.midcast.SongEffect, {body="Aoidos' Hongreline +2",feet="Fili Cothurnes +1"}) -- dur+162
    sets.midcast.Minne    = set_combine(sets.midcast.SongEffect, {body="Inyanga Jubbah +2",legs="Mousai Seraweels +1"})   -- dur+160 *
    sets.midcast.Carol    = set_combine(sets.midcast.SongEffect, {
        body="Inyanga Jubbah +2",hands="Mousai Gages +1",feet="Fili Cothurnes +1"})                                       -- dur+162
    sets.midcast.Etude    = set_combine(sets.midcast.SongEffect, {body="Aoidos' Hongreline +2",legs="Inyanga Shalwar"})   -- dur+162
    sets.midcast.Ballad   = set_combine(sets.midcast.SongEffect, {legs="Fili Rhingrave +1"})                              -- dur+162
    sets.midcast.Paeon    = set_combine(sets.midcast.SongEffect, {
        head="Brioso Roundlet +3",body="Inyanga Jubbah +2",feet="Fili Cothurnes +1"})                                     -- dur+162
    sets.midcast['Honor March'] = set_combine(sets.midcast.SongEffect, {range="Marsyas",
        body="Brioso Justaucorps +3",hands="Fili Manchettes +1",ring1=gear.Lstikini,feet="Fili Cothurnes +1"})            -- dur+162
    sets.midcast['Sentinel\'s Scherzo'] = set_combine(sets.midcast.SongEffect, {
        body="Aoidos' Hongreline +2",feet="Fili Cothurnes +1"})                                                           -- dur+162
    sets.midcast.BardSong = set_combine(sets.midcast.SongEffect, {body="Aoidos' Hongreline +2",legs="Inyanga Shalwar"})   -- dur+162

    sets.midcast.Prelude.FullHarp = set_combine(sets.midcast.Prelude, {range="Daurdabla",feet="Inyanga Crackows +2"})
    sets.midcast.March.FullHarp   = set_combine(sets.midcast.March,   {range="Daurdabla",feet="Inyanga Crackows +2"})
    sets.midcast.Minne.FullHarp   = set_combine(sets.midcast.Minne,   {range="Daurdabla",feet="Inyanga Crackows +2"})
    sets.midcast.Etude.FullHarp   = set_combine(sets.midcast.Etude,   {range="Daurdabla",feet="Inyanga Crackows +2"})
    sets.midcast.Ballad.FullHarp  = set_combine(sets.midcast.Ballad,  {range="Daurdabla",feet="Inyanga Crackows +2"})

    sets.midcast.LongMadrigal        = set_combine(sets.midcast.SongEffect, {head="Fili Calot +1"})                       -- dur+189
    sets.midcast.LongPrelude         = set_combine(sets.midcast.SongEffect, {back=gear.SongCape})                         -- dur+179
    sets.midcast.LongMarch           = set_combine(sets.midcast.SongEffect, {hands="Fili Manchettes +1"})                 -- dur+179
    sets.midcast.LongMinuet          = set_combine(sets.midcast.SongEffect, {body="Fili Hongreline +1"})                  -- dur+179
    sets.midcast.LongMinne           = set_combine(sets.midcast.SongEffect, {})                                           -- dur+169
    sets.midcast.LongCarol           = set_combine(sets.midcast.SongEffect, {hands="Mousai Gages +1"})                    -- dur+189
    sets.midcast.LongEtude           = set_combine(sets.midcast.SongEffect, {})                                           -- dur+169
    sets.midcast.LongBallad          = set_combine(sets.midcast.SongEffect, {legs="Fili Rhingrave +1"})                   -- dur+162
    sets.midcast.LongPaeon           = set_combine(sets.midcast.SongEffect, {head="Brioso Roundlet +3"})                  -- dur+189
    sets.midcast['Honor March'].Long = set_combine(sets.midcast.SongEffect, {range="Marsyas",
        body="Brioso Justaucorps +3",hands="Fili Manchettes +1",ring1=gear.Lstikini})                                     -- dur+189
    sets.midcast.LongBardSong = sets.midcast.SongEffect                                                                   -- dur+169

    sets.midcast.Mazurka = set_combine(sets.midcast.SongEffect, {range="Daurdabla"})
    sets.midcast.DummySong = {range="Daurdabla",legs="Ayanmo Cosciales +2"} -- Handled in job_post_midcast()

    sets.midcast.SongDebuff = {main="Carnwenhan",sub="Ammurapi Shield",range="Gjallarhorn",
        head="Brioso Roundlet +3",neck="Moonbow Whistle +1",ear1="Regal Earring",ear2="Dignitary's Earring",
        body="Brioso Justaucorps +3",hands="Brioso Cuffs +3",ring1=gear.Lstikini,ring2=gear.Rstikini,
        back=gear.SongCape,waist="Luminary Sash",legs="Inyanga Shalwar +2",feet="Brioso Slippers +3"}
    -- m.acc+752, sing=500, wind=480, chr+266, dur+157%
    sets.midcast.SongDebuff.Resistant = set_combine(sets.midcast.SongDebuff, {legs="Brioso Cannions +3"})
    -- m.acc+778, sing=500, wind=499, chr+267, dur+140%
    sets.midcast.Lullaby            = sets.midcast.SongDebuff
    -- m.acc+752, sing=500, wind=480, chr+266, dur+177% (foe)
    -- m.acc+752, sing=495, strg=488, chr+256, dur+167% (horde)
    sets.midcast.Lullaby.Resistant  = set_combine(sets.midcast.Lullaby, {legs="Brioso Cannions +3"})
    -- m.acc+778, sing=500, wind=499, chr+267, dur+160% (foe)
    -- m.acc+778, sing=495, strg=488, chr+257, dur+150% (horde)
    sets.midcast['Magic Finale']    = set_combine(sets.midcast.SongDebuff.Resistant, {legs="Fili Rhingrave +1"})
    sets.midcast['Magic Finale'].Resistant      = sets.midcast.SongDebuff.Resistant
    sets.midcast.Elegy                          = sets.midcast.SongDebuff
    sets.midcast.Elegy.Resistant                = sets.midcast.SongDebuff.Resistant
    sets.midcast.Threnody                       = set_combine(sets.midcast.SongDebuff, {body="Mousai Manteel +1"})
    -- m.acc+725, sing=483, wind=480, chr+265, dur+177%
    sets.midcast.Threnody.Resistant             = sets.midcast.SongDebuff.Resistant
    sets.midcast['Pining Nocturne']             = sets.midcast.SongDebuff
    sets.midcast['Pining Nocturne'].Resistant   = sets.midcast.SongDebuff.Resistant
    sets.midcast.Requiem                        = sets.midcast.SongDebuff
    sets.midcast.Requiem.Resistant              = sets.midcast.SongDebuff.Resistant
    sets.midcast['Maiden\'s Virelai']           = sets.midcast.SongDebuff
    sets.midcast.Lullaby.MaxDur = set_combine(sets.midcast.Lullaby, {range="Marsyas",body="Fili Hongreline +1",legs="Inyanga Shalwar +2"})
    -- m.acc+673, sing=472, wind=469, chr+250, dur+199% (foe)
    -- m.acc+673, sing=492, strg=474, chr+250, dur+179% (horde)
    sets.midcast.Threnody.MaxDur = set_combine(sets.midcast.Lullaby.MaxDur, {range="Gjallarhorn",body="Mousai Manteel +1"})
    sets.midcast['Pining Nocturne'].MaxDur = set_combine(sets.midcast.Lullaby.MaxDur, {range="Gjallarhorn"})

    sets.midcast.Cure = {main="Daybreak",sub="Genmei Shield",
        head="Vanya Hood",neck="Loricate Torque +1",ear1="Genmei Earring",ear2="Mendicant's Earring",
        body="Chironic Doublet",hands="Inyanga Dastanas +2",ring1="Vocane Ring +1",ring2="Defending Ring",
        back="Moonbeam Cape",waist=gear.ElementalObi,legs="Ayanmo Cosciales +2",feet="Vanya Clogs"}
    -- cure potency +50
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
    sets.midcast.Stoneskin = set_combine(sets.midcast.EnhancingDuration, {neck="Nodens Gorget",waist="Siegel Sash",legs="Shedir Seraweels"})
    sets.midcast.Aquaveil  = set_combine(sets.midcast.EnhancingDuration, {head="Chironic Hat",legs="Shedir Seraweels"})
    sets.midcast.Regen     = set_combine(sets.midcast.EnhancingDuration, {head="Inyanga Tiara +2"})
    sets.midcast.FixedPotencyEnhancing = sets.midcast.EnhancingDuration
    sets.midcast.Klimaform = {}

    sets.midcast['Enfeebling Magic'] = {main="Carnwenhan",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
        head="Brioso Roundlet +3",neck="Moonbow Whistle +1",ear1="Regal Earring",ear2="Dignitary's Earring",
        body="Brioso Justaucorps +3",hands="Kaykaus Cuffs +1",ring1=gear.Lstikini,ring2=gear.Rstikini,
        back=gear.SongCape,waist="Luminary Sash",legs="Chironic Hose",feet="Skaoi Boots"}
    -- enf.skill=217, m.acc+734, mnd+209
    sets.midcast.Dispelga = set_combine(sets.midcast['Enfeebling Magic'], sets.dispelga)

    sets.midcast.Utsusemi = {main="Mafic Cudgel",sub="Genmei Shield",ammo="Staunch Tathlum +1",
        head="Ayanmo Zucchetto +2",neck="Loricate Torque +1",ear1="Genmei Earring",ear2="Etiolation Earring",
        body="Ashera Harness",hands="Ayanmo Manopolas +2",ring1="Vocane Ring +1",ring2="Defending Ring",
        back="Moonbeam Cape",waist="Flume Belt +1",legs="Ayanmo Cosciales +2",feet="Ayanmo Gambieras +2"}

    -- Sets to return to when not performing an action.

    sets.idle = {main="Daybreak",sub="Genmei Shield",
        head="Inyanga Tiara +2",neck="Loricate Torque +1",ear1="Genmei Earring",ear2="Etiolation Earring",
        body="Inyanga Jubbah +2",hands="Volte Gloves",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.MEVACape,waist="Flume Belt +1",legs="Inyanga Shalwar +2",feet="Fili Cothurnes +1"}
    -- refresh+3, pdt-50, mdt-50, meva+627
    sets.idle.PDT = set_combine(sets.idle, {legs="Brioso Cannions +3",feet="Inyanga Crackows +2"})
    -- refresh+3, pdt-50, mdt-50, meva+647
    sets.idle.MEVA = set_combine(sets.idle, {
        neck="Warder's Charm +1",ear1="Eabani Earring",ring1="Inyanga Ring",feet="Inyanga Crackows +2"})
    -- refresh+5, pdt-34, mdt-43, meva+707
    sets.idle.Refresh = set_combine(sets.idle.MEVA, {main="Daybreak",sub="Genmei Shield",
        ring1="Inyanga Ring",ring2=gear.Rstikini})
    -- refresh+8, pdt-24, mdt-27, meva+724
    sets.latent_refresh = {waist="Fucho-no-obi"}
    sets.zendik = {body="Zendik Robe"}
    sets.buff.doom = {neck="Nicander's Necklace",ring1="Eshmun's Ring",waist="Gishdubar Sash"}

    sets.defense.PDT = sets.idle.PDT
    sets.defense.MDT = sets.idle.MEVA
    sets.Kiting = {feet="Fili Cothurnes +1"}

    sets.engaged = {range="Linos",
        head="Ayanmo Zucchetto +2",neck="Bard's Charm +2",ear1="Telos Earring",ear2="Brutal Earring",
        body="Ashera Harness",hands="Volte Mittens",ring1="Moonlight Ring",ring2="Ilabrat Ring",
        back=gear.TPCape,waist="Windbuffet Belt +1",legs="Ayanmo Cosciales +2",feet="Battlecast Gaiters"}
    sets.engaged.Acc = set_combine(sets.engaged, {body="Ayanmo Corazza +2",ear2="Dignitary's Earring",feet="Ayanmo Gambieras +2"})
    sets.engaged.PDef = set_combine(sets.engaged, {hands="Ayanmo Manopolas +2",ring2="Defending Ring"})
    sets.engaged.Acc.PDef = sets.engaged.PDef
	sets.engaged.DW          = set_combine(sets.engaged,          {ear1="Eabani Earring",waist="Reiki Yotai"})
    -- aen/blur: acc~1166/1142, haste+26, stp+59, da+18, qa+6, dw+11, pdt-33, mdt-20
	sets.engaged.DW.Acc      = set_combine(sets.engaged.Acc,      {ear2="Eabani Earring",waist="Reiki Yotai"})
	sets.engaged.DW.PDef     = set_combine(sets.engaged.PDef,     {ear1="Eabani Earring",waist="Reiki Yotai"})
	sets.engaged.DW.Acc.PDef = set_combine(sets.engaged.Acc.PDef, {ear2="Eabani Earring",waist="Reiki Yotai"})

    -- Sets that depend upon idle sets
    sets.midcast.FastRecast = set_combine(sets.idle.PDT, {})
    sets.midcast['Dia II'] = set_combine(sets.idle, {main="Taming Sari",
        head="Volte Cap",ring2="Kishar Ring",waist="Chaac Belt",feet=gear.chir_feet_th})
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_precast(spell, action, spellMap, eventArgs)
    if state.Buff.Nightingale and spell.type == 'BardSong' then
        if spell.english == 'Honor March' then
            equip(sets.midcast['Honor March'])
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
        if info.magic_ws:contains(spell.english) then equip(resolve_ele_belt(spell, sets.ele_obi)) end
        if buffactive['elvorseal'] and player.inventory["Angantyr Boots"] then equip({feet="Angantyr Boots"}) end
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

        if spell.english == 'Honor March' then
            if state.LongSongs.value or state.Buff.Marcato then
                equip(sets.midcast['Honor March'].Long)
            end
        end

        if state.Buff.Troubadour or state.Buff['Elemental Seal'] then
            -- Some spells 
            if S{'Lullaby','Threnody'}:contains(spellMap) then
                equip(sets.midcast[spellMap].MaxDur)
            elseif spell.english == 'Pining Nocturne' then
                equip(sets.midcast['Pining Nocturne'].MaxDur)
            end
        end

        if state.HarpLullaby.value and S{'Horde Lullaby','Horde Lullaby II'}:contains(spell.english) then
            equip({range="Daurdabla"})
            if state.TreasureMode.value ~= 'None' and spell.english == 'Horde Lullaby' then
                equip(sets.weapons.Sari, sets.TreasureHunter)
            end
        end

    elseif spell.target.type == 'SELF' then
        if S{'Cure','Refresh'}:contains(spellMap) then
            equip({waist="Gishdubar Sash"})
        elseif spell.english == 'Cursna' then
            equip(sets.buff.doom)
        end
    end
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_aftercast(spell, action, spellMap, eventArgs)
    if spell.interrupted then
        send_command('wait 0.5;gs c update')
        interrupted_message(spell)
    else
        if 'Lullaby' == spellMap then
            lullaby_timer(spell)
        elseif S{'Pianissimo','Tenuto','Nightingale','Troubadour','Marcato','Clarion Call','Soul Voice'}:contains(spell.english) then
            eventArgs.handled = true
        elseif spell.english == 'Dia II' and state.DiaMsg.value then
            if spell.target.name and spell.target.type == 'MONSTER' then
                send_command('@input /p '..spell.english..' /')
            end
        elseif spell.type == 'WeaponSkill' then
            if state.WSMsg.value then
                send_command('@input /p '..spell.english)
            end
        end
        if state.Buff.Troubadour and spell.type == 'BardSong' then
            -- skip aftercast swaps so rapid singing isn't broken
            eventArgs.handled = true
        end
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
    elseif buff:lower() == 'doom' and not midaction() then
        handle_equipping_gear(player.status)
    end
    if gain then
        add_to_chat(104, 'Gained ['..buff..']')
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
            send_command('bind ^numpad0 input /fish')
        else
            enable('ring1','ring2')
        end
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
        if player.mpp < 51 and state.IdleMode.value == 'Refresh' and S{'WHM','SCH','RDM'}:contains(player.sub_job) then
            idleSet = set_combine(idleSet, sets.latent_refresh)
        end
        if state.ZendikIdle.value then
            idleSet = set_combine(idleSet, sets.zendik)
        end
        if state.Fishing.value then
            idleSet = set_combine(idleSet, sets.Fishing)
        end
    end
    if has_any_buff_of(S{'petrification','sleep','stun','terror'}) then
        idleSet = set_combine(sets.defense.PDT, {})
    end
    if state.Buff.doom then
        idleSet = set_combine(idleSet, sets.buff.doom)
    end
    return idleSet
end

-- Modify the default melee set after it was constructed.
function customize_melee_set(meleeSet)
    if state.DefenseMode.value == 'None' then
        meleeSet = set_combine(meleeSet, sets.weapons[state.CombatWeapon.value])
    end
    if has_any_buff_of(S{'petrification','sleep','stun','terror'}) then
        meleeSet = set_combine(sets.defense.PDT, {})
    end
    if state.Buff.doom then
        meleeSet = set_combine(meleeSet, sets.buff.doom)
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
    if state.TreasureMode.value ~= 'None' then
        msg = msg .. ' TH+3'
    end
    if state.Fishing.value then
        msg = msg .. ' Fishing'
    end
    if state.Kiting.value == true then
        msg = msg .. ' Kiting'
    end

    add_to_chat(122, msg)
    report_ja_recasts(info.recast_ids)
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
                send_command('@input /ma ' .. state.DummySongs[cmdParams[2]] .. ' ' .. cmdParams[3])
            else
                if state.Buff.Pianissimo then
                    if S{'SELF','PLAYER'}:contains(player.target.type) then
                        send_command('@input /ma ' .. state.DummySongs[cmdParams[2]] .. ' ' .. player.target.name)
                    else
                        send_command('@input /ma ' .. state.DummySongs[cmdParams[2]] .. ' <stpc>')
                    end
                else
                    send_command('@input /ma ' .. state.DummySongs[cmdParams[2]])
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
    --elseif cmdParams[1] == 'mooglehp' then
    --    equip({neck="Sanctity Necklace",ear1="Thureous Earring",ear2="Etiolation Earring",
    --    ring1="Etana Ring",ring2="Ilabrat Ring",back="Moonbeam Cape"})
    --    disable('neck','ear1','ear2','ring1','ring2','back')
    --    if cmdParams[2] and cmdParams[2] == 'off' then
    --        enable('neck','ear1','ear2','ring1','ring2','back')
    --        handle_equipping_gear(player.status)
    --    end
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
function select_default_macro_book()
    set_macro_page(1, 11)
    send_command('bind !^l input /lockstyleset 11')
end

-- returns a list for use with make_keybind_list
function job_keybinds()
    local bind_command_list = L{
        'bind %`|F12 gs c update user',
        'bind F9   gs c cycle OffenseMode',
        'bind !F9  gs c reset OffenseMode',
        'bind F10  gs c cycle CastingMode',
        'bind !F10 gs c reset CastingMode',
        'bind F11  gs c cycle IdleMode',
        'bind !F11 gs c reset IdleMode',
        'bind @F11 gs c toggle Kiting',
        'bind ^space gs c cycle HybridMode',
        'bind !space gs c set DefenseMode Physical',
        'bind @space gs c set DefenseMode Magical',
        'bind !@space gs c reset DefenseMode',
        'bind !w  gs c   set OffenseMode Normal',
        'bind !@w gs c reset OffenseMode',
        'bind !^q gs c weap Carn',
        'bind !^w gs c weap Aen',
        'bind ^@w gs c set CombatWeapon Xoanon',
        'bind !^e gs c weap Twash',
        'bind !^r gs c weap Naeg',
        'bind ^\\\\ gs c toggle WSMsg',
        'bind ^@\\\\ gs c toggle DiaMsg',
        'bind !F12 gs c cycle TreasureMode',
        'bind !z  gs c toggle HarpLullaby',
        'bind @z  gs c toggle ZendikIdle',
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
        'bind ^@1 input /ma "Carnage Elegy" <stnpc>',
        'bind ^2  input /ma "Foe Lullaby II" <stnpc>',
        'bind ^@2 input /ma Foe Lullaby <stnpc>',
        'bind ^3  input /ma "Horde Lullaby II"',
        'bind ^@3 input /ma "Horde Lullaby II" <stnpc>',
        'bind ^4  input /ma "Pining Nocturne"',
        'bind ^@4 input /ma "Foe Requiem VII"',

        'bind !3 gs c dummy 1',
        'bind !4 gs c dummy 2',
        'bind !5 input /ma "Honor March" <stpc>',
        'bind ^5 input /ma "Victory March" <stpc>',
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
            'bind !d input /ma Flash',
            'bind !@g input /ma Stoneskin <me>',
            'bind @c input /ma Blink <me>',
            'bind @v input /ma Aquaveil <me>',
            'bind !f input /ma Haste',
            'bind @1 input /ma Poisona',
            'bind @2 input /ma Paralyna',
            'bind @3 input /ma Blindna',
            'bind @4 input /ma Silena',
            'bind @5 input /ma Stona',
            'bind @6 input /ma Viruna',
            'bind @7 input /ma Cursna',
            'bind @F1 input /ma Erase',
            'bind @F2 input /ma "Dia II"',
            'bind @F3 input /ma Silence'})
    elseif player.sub_job == 'BLM' then
        bind_command_list:extend(L{
            'bind @` input /ja "Elemental Seal" <me>'})
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
            'bind !@e input /ma "Utsusemi: Ichi" <me>'})
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
        -- dur +199%
        if state.HarpLullaby.value and spell.english:startswith('Horde') then
            dur = math.floor(dur * 2.79)    -- [base]3:07, [NT]6:14, [NT+M]6:34, [NT+CC]7:34, [NT+CC+M]7:54
        else
            dur = math.floor(dur * 2.99)    -- [base]3:19, [NT]6:38, [NT+M]6:58, [NT+CC]7:58, [NT+CC+M]8:18
        end
    elseif state.CastingMode.value == 'Normal' then
        -- dur +177%
        if state.HarpLullaby.value and spell.english:startswith('Horde') then
            dur = math.floor(dur * 2.67)    -- [base]3:00
        else
            dur = math.floor(dur * 2.77)    -- [base]3:06
        end
    elseif state.CastingMode.value == 'Resistant' then
        -- dur +160%
        if state.HarpLullaby.value and spell.english:startswith('Horde') then
            dur = math.floor(dur * 2.50)    -- [base]2:50
        else
            dur = math.floor(dur * 2.60)    -- [base]2:56
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

    send_command('@timers c "'..spell.english..' ['..spell.target.name..']" '..tostring(dur)..' down')
end

function init_state_text()
    destroy_state_text()
    local dummy_text_settings={pos={x=130,y=680},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local hyb_text_settings = {pos={x=130,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local def_text_settings = {pos={x=172,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    state.dummy_text = texts.new('DummySong', dummy_text_settings)
    state.hyb_text = texts.new('/${hybrid}', hyb_text_settings)
    state.def_text = texts.new('(${defense})', def_text_settings)

    windower.register_event('logout', destroy_state_text)
    state.texts_event_id = windower.register_event('prerender', function()
        state.dummy_text:visible((state.ExtraSongsMode.value ~= 'None'))

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
        for text in S{state.dummy_text, state.hyb_text, state.def_text}:it() do
            text:hide()
            text:destroy()
        end
    end
    state.texts_event_id = nil
end
