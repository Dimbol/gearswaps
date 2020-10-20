-- Modified from 'https://github.com/Kinematics/GearSwap-Jobs/'
-- TODO make tanking sets more hp stable, like rune sets

-- nin dual wield cheatsheet
-- haste:   0   15  30  cap
--   +dw:  39   32  21   1

-- NOTES
-- innin boosts ninjutsu damage
-- retsu has a 30% paralysis
-- subtle blow is easy to cap (trait 27, ochu 8, adh.bonnet 8, herc.boots 6, kenda 8/12/8/10/8, merits 5)
-- when zerging, use chi with bolster malaise and savage otherwise
-- weaponskills are changed from <stnpc> to <t> in job_auto_change_target

-- SKILLCHAINS
-- to teki shun shun
-- shun ten kamu shun shun
-- teki to chi to yu to
-- teki to chi to ei/kamu kamu
-- ku retsu ten hi
-- frag: to teki
-- dist: ku/rin retsu
-- grav: jin ei
-- impa: yu chi
-- 7stp: ei rin ei rin ...
--    or wasp gust wasp gust ...

-- /BLU SPELLSET
-- jettatura, geist wall, blank gaze,
-- sheep song, cocoon, stinking gas,
-- healing breeze, wild carrot, refueling
-- pollen, wild oats, power attack

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
    enable('ammo','head','neck','ear1','ear2','body','hands','ring1','ring2','back','waist','legs','feet')
    disable('main','sub')
    state.Buff.doom = buffactive.doom or false

    state.Buff.Sange = buffactive['sange'] or false
    state.Buff.Futae = buffactive['futae'] or false
    state.Buff.Yonin = buffactive['yonin'] or false
    state.Buff.Innin = buffactive['innin'] or false
    state.Buff.Migawari = buffactive['migawari'] or false

    --include('Mote-TreasureHunter')

    windower.raw_register_event('logout', destroy_state_text)
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
    state.OffenseMode:options('Normal','MEVA','Acc','None')     -- Cycle with F9 or @c
    state.HybridMode:options('Normal','PDef')                   -- Cycle with ^F9
    state.RangedMode:options('Shuriken','Tathlum','Blink')      -- Cycle with !F9, set with !-, !=, !backspace
    state.WeaponskillMode:options('Normal','NoDmg')             -- Cycle with @F9
    state.CastingMode:options('Enmity','Normal')                -- Cycle with F10
    state.IdleMode:options('Normal','PDT','Rf','EvaPDT','STP')  -- Cycle with F11, reset with !F11
    state.PhysicalDefenseMode:options('EvaPDT','PDT')           -- Cycle with !z
    state.MagicalDefenseMode:options('MEVA')                    -- Cycle with @z
    state.CombatWeapon = M{['description']='Combat Weapon'}     -- Set with !^q through !^r and others
    state.CombatWeapon:options('Heishi','HeiTern','HeishiTP','HeiChi',
                               'Nagi','NagiTP','Kannagi','Kikoku','FudoB','FudoBTP','FudoC','FudoCTP','Gokotai',
                               'AEDagger','SCDagger','GKatana','GKGekko','Club','Naeg','NaegTP')

    state.MagicBurst = M(true,  'Magic Burst')                  -- Toggle with ^z
    state.WSMsg      = M(false, 'WS Message')                   -- Toggle with ^\
    state.SIRDUtsu   = M(false, 'SIRD Utsu')                    -- Set with !@c
    state.LastUtsu   = M{['description']='Utsu Tier',3,2,1}     -- determines when to cancel
    state.AutoHybrid = M{['description']='Auto Hybrid','off','Utsu','Miga'}
    state.Fishing    = M(false, 'Fishing Gear')
    state.Cooking    = M(false, 'Cooking Gear')
    state.HELM       = M(false, 'HELM Gear')
    init_state_text()
    hud_update_on_state_change()

    info.magic_ws  = S{'Blade: Ei','Blade: Yu',
                       'Aeolian Edge','Cyclone','Gust Slash','Energy Steal','Energy Drain',
                       'Burning Blade','Red Lotus Blade','Shining Blade','Seraph Blade','Sanguine Blade'}
    info.hybrid_ws = S{'Blade: To','Blade: Teki','Blade: Chi',
                       'Tachi: Goten','Tachi: Kagero','Tachi: Jinpu','Tachi: Koki'}
    info.obi_ws    = S{}:union(info.magic_ws):union(info.hybrid_ws)

    -- Augmented items get variables for convenience and specificity
    gear.fudoB = {name="Fudo Masamune", augments={'Path: B'}}
    gear.fudoC = {name="Fudo Masamune", augments={'Path: C'}}
    gear.taeon_head_phlx  = {name="Taeon Chapeau", augments={'Phalanx +3'}}
    gear.taeon_body_phlx  = {name="Taeon Tabard", augments={'Spell interruption rate down -10%','Phalanx +3'}}
    gear.taeon_hands_phlx = {name="Taeon Gloves", augments={'Spell interruption rate down -8%','Phalanx +3'}}
    gear.taeon_legs_phlx  = {name="Taeon Tights", augments={'Phalanx +3'}}
    gear.taeon_feet_phlx  = {name="Taeon Boots", augments={'Spell interruption rate down -9%','Phalanx +3'}}
    gear.herc_head_ma  = {name="Herculean Helm",
        augments={'"Mag.Atk.Bns."+23','Mag. Acc.+16','Accuracy+2 Attack+2','Mag. Acc.+12 "Mag.Atk.Bns."+12'}}
    gear.herc_hands_ma = {name="Herculean Gloves",
        augments={'Mag. Acc.+18 "Mag.Atk.Bns."+18','Magic burst dmg.+3%','Mag. Acc.+12','"Mag.Atk.Bns."+10',}}
    gear.herc_legs_ma  = {name="Herculean Trousers",
        augments={'"Mag.Atk.Bns."+30','Weapon Skill Acc.+5','Accuracy+14 Attack+14','Mag. Acc.+16 "Mag.Atk.Bns."+16'}}
    gear.herc_feet_ma  = {name="Herculean Boots",
        augments={'Mag. Acc.+19 "Mag.Atk.Bns."+19','Enmity-2','MND+4','Mag. Acc.+4','"Mag.Atk.Bns."+15'}}
    gear.herc_head_wsd  = {name="Herculean Helm",
        augments={'"Cure" spellcasting time -10%','Pet: INT+6','Weapon skill damage +9%'}}
    gear.herc_body_wsd  = {name="Herculean Vest",
        augments={'Weapon skill damage +5%','STR+8','Accuracy+6 Attack+6','Mag. Acc.+7 "Mag.Atk.Bns."+7'}}
    gear.herc_hands_wsd = {name="Herculean Gloves",
        augments={'Accuracy+25 Attack+25','Weapon skill damage +3%','DEX+3','Accuracy+14','Attack+5'}}
    gear.herc_feet_wsd  = {name="Herculean Boots",
        augments={'Accuracy+16 Attack+16','Weapon skill damage +2%','DEX+10','Accuracy+6','Attack+14'}}
    gear.herc_feet_ta  = {name="Herculean Boots", augments={'Rng.Acc.+4','"Triple Atk."+4','Accuracy+14','Attack+12'}}
    gear.herc_head_rf = {name="Herculean Helm",
        augments={'Accuracy+17','DEX+6','"Refresh"+2','Accuracy+16 Attack+16','Mag. Acc.+20 "Mag.Atk.Bns."+20'}}
    gear.herc_hands_dt = {name="Herculean Gloves", augments={'Attack+27','Damage taken-4%','DEX+5','Accuracy+9'}}
    gear.herc_legs_th = {name="Herculean Trousers",
        augments={'Attack+3','"Cure" spellcasting time -2%','"Treasure Hunter"+2','Accuracy+1 Attack+1'}}
    gear.herc_head_fc = {name="Herculean Helm", augments={'"Mag.Atk.Bns."+2','"Fast Cast"+5'}}
    gear.herc_feet_fc = {name="Herculean Boots", augments={'"Mag.Atk.Bns."+17','"Fast Cast"+5'}}
    gear.Lstikini = {name="Stikini Ring +1", bag="wardrobe2"}
    gear.Rstikini = {name="Stikini Ring +1", bag="wardrobe3"}

    gear.TPCape    = {name="Andartia's Mantle",
        augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Store TP"+10','Phys. dmg. taken-10%'}}
    gear.DWCape    = {name="Andartia's Mantle",
        augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Dual Wield"+10','Phys. dmg. taken-10%'}}
    gear.ShunCape  = {name="Andartia's Mantle",
        augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','"Dbl.Atk."+10','Damage taken-5%'}}
    gear.TenCape   = {name="Andartia's Mantle",
        augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%','Damage taken-5%'}}
    gear.MetsuCape = {name="Andartia's Mantle",
        augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','Weapon skill damage +10%','Damage taken-5%'}}
    gear.HiCape    = {name="Andartia's Mantle",
        augments={'AGI+20','Accuracy+20 Attack+20','AGI+10','Weapon skill damage +10%','Damage taken-5%'}}
    gear.EnmCape   = {name="Andartia's Mantle",
        augments={'HP+60','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Enmity+10','Phys. dmg. taken-10%'}}
    gear.NukeCape  =  {name="Andartia's Mantle",
        augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','INT+10','"Mag.Atk.Bns."+10','Damage taken-5%'}}
    gear.FCCape    =  {name="Andartia's Mantle",
        augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+10','"Fast Cast"+10','Phys. dmg. taken-10%'}}

    info.keybinds = make_keybind_list(job_keybinds())
    info.keybinds:bind()

    info.ws_binds = make_keybind_list(T{
        ['Katana']=L{
            'bind ^1|%1 input /ws "Blade: Hi" <stnpc>',
            'bind ^2|%2 input /ws "Blade: Shun" <stnpc>',
            'bind ^3|%3 input /ws "Blade: Ten" <stnpc>',
            'bind ^4|%4 input /ws "Blade: Kamu" <stnpc>',
            'bind ^5|%5 input /ws "Blade: Jin" <stnpc>',
            'bind ^6|%6 input /ws "Blade: Ku" <stnpc>',
            'bind !^1   input /ws "Blade: Yu" <stnpc>',
            'bind !^2   input /ws "Blade: Ei" <stnpc>',
            'bind !^3   input /ws "Blade: Chi" <stnpc>',
            'bind !^4   input /ws "Blade: To" <stnpc>',
            'bind !^5   input /ws "Blade: Teki" <stnpc>'},
        ['RKatana']=L{
            'bind ^1|%1 input /ws "Blade: Hi" <stnpc>',
            'bind ^2|%2 input /ws "Blade: Shun" <stnpc>',
            'bind ^3|%3 input /ws "Blade: Ten" <stnpc>',
            'bind ^4|%4 input /ws "Blade: Metsu" <stnpc>',
            'bind ^5|%5 input /ws "Blade: Jin" <stnpc>',
            'bind ^6|%6 input /ws "Blade: Ku" <stnpc>',
            'bind !^1   input /ws "Blade: Yu" <stnpc>',
            'bind !^2   input /ws "Blade: Ei" <stnpc>',
            'bind !^3   input /ws "Blade: Chi" <stnpc>',
            'bind !^4   input /ws "Blade: To" <stnpc>',
            'bind !^5   input /ws "Blade: Teki" <stnpc>'},
        ['Dagger']=L{
            'bind ^1|%1 input /ws "Evisceration" <stnpc>',
            'bind ^2|%2 input /ws "Wasp Sting" <stnpc>',
            'bind ^3|%3 input /ws "Gust Slash" <stnpc>',
            'bind ^4|%4 input /ws "Exenterator" <stnpc>',
            'bind ^6|%6 input /ws "Aeolian Edge" <stnpc>',
            'bind ^7|%7 input /ws "Cyclone" <stnpc>'},
        ['GKatana']=L{
            'bind ^1|%1 input /ws "Tachi: Ageha" <stnpc>',
            'bind ^2|%2 input /ws "Tachi: Kasha" <stnpc>',
            'bind ^3|%3 input /ws "Tachi: Jinpu" <stnpc>',
            'bind ^4|%4 input /ws "Tachi: Kagero" <stnpc>',
            'bind ^5|%5 input /ws "Tachi: Koki" <stnpc>',
            'bind !^d   input /ws "Tachi: Hobaku" <stnpc>'},
        ['Sword']=L{
            'bind ^1|%1 input /ws "Sanguine Blade" <stnpc>',
            'bind ^2|%2 input /ws "Vorpal Blade" <stnpc>',
            'bind ^3|%3 input /ws "Savage Blade" <stnpc>',
            'bind ^4|%4 input /ws "Red Lotus Blade" <stnpc>',
            'bind ^5|%5 input /ws "Seraph Blade" <stnpc>',
            'bind ^6|%6 input /ws "Circle Blade" <stnpc>',
            'bind !^d   input /ws "Flat Blade" <stnpc>'},
        ['Club']=L{
            'bind ^1|%1 input /ws "Flash Nova" <stnpc>',
            'bind ^2|%2 input /ws "Judgement" <stnpc>',
            'bind ^3|%3 input /ws "True Strike" <stnpc>',
            'bind !^d   input /ws "Brainshaker" <stnpc>'}},
        {['Heishi']='Katana',['HeiTern']='Katana',['HeishiTP']='Katana',['HeiChi']='Katana',
         ['Gokotai']='Katana',['Nagi']='Katana',['NagiTP']='Katana',['Kannagi']='Katana',
         ['FudoB']='Katana',['FudoBTP']='Katana',['FudoC']='Katana',['FudoCTP']='Katana',
         ['Kikoku']='RKatana',
         ['AEDagger']='Dagger',['SCDagger']='Dagger',['Naeg']='Sword',['NaegTP']='Sword',
         ['GKatana']='GKatana',['GKGekko']='GKatana',['Club']='Club'})
    info.ws_binds:bind(state.CombatWeapon)
    send_command('bind %\\\\ gs c ListWS')

    info.recast_ids = L{{name='Yonin',id=146},{name='Issekigan',id=57}}
    if     player.sub_job == 'WAR' then
        info.recast_ids:extend(L{{name='Provoke',id=5},{name='Warcry',id=2}})
    elseif player.sub_job == 'DRG' then
        info.recast_ids:extend(L{{name='High Jump',id=159}})
    elseif player.sub_job == 'DRK' then
        info.recast_ids:extend(L{{name='Last Resort',id=87},{name='Souleater',id=85}})
    elseif player.sub_job == 'RUN' then
        info.recast_ids:extend(L{{name='Vallation',id=23},{name='Swordplay',id=24},{name='Pflug',id=59}})
    elseif player.sub_job == 'PLD' then
        info.recast_ids:extend(L{{name='Sentinel',id=75}})
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
    sets.weapons.Heishi   = {main="Heishi Shorinken",sub="Ochu"}
    sets.weapons.HeiTern  = {main="Heishi Shorinken",sub="Ternion Dagger +1"}
    sets.weapons.HeiChi   = {main="Heishi Shorinken",sub="Gokotai"}
    sets.weapons.HeishiTP = {main="Heishi Shorinken",sub="Hitaki"}
    sets.weapons.Nagi     = {main="Nagi",sub="Ochu"}
    sets.weapons.NagiTP   = {main="Nagi",sub="Hitaki"}
    sets.weapons.FudoB    = {main=gear.fudoB,sub="Ternion Dagger +1"}
    sets.weapons.FudoBTP  = {main=gear.fudoB,sub="Hitaki"}
    sets.weapons.FudoC    = {main=gear.fudoC,sub="Shuhansadamune"}
    sets.weapons.FudoCTP  = {main=gear.fudoC,sub="Hitaki"}
    sets.weapons.Kannagi  = {main="Kannagi",sub="Ternion Dagger +1"}
    sets.weapons.Kikoku   = {main="Kikoku",sub="Ochu"}
    sets.weapons.Gokotai  = {main="Gokotai",sub="Tauret"}
    sets.weapons.AEDagger = {main="Tauret",sub="Malevolence"}
    sets.weapons.SCDagger = {main="Tauret",sub="Ternion Dagger +1"}
    sets.weapons.GKatana  = {main="Hachimonji",sub="Bloodrain Strap"}
    sets.weapons.GKGekko  = {main="Beryllium Tachi",sub="Bloodrain Strap"}
    sets.weapons.Naeg     = {main="Naegling",sub="Ternion Dagger +1"}
    sets.weapons.NaegTP   = {main="Naegling",sub="Hitaki"}
    sets.weapons.Club     = {main="Mafic Cudgel",sub="Hitaki"}
    sets.weapons.Daken       = {ammo="Date Shuriken"}
    sets.weapons.TPTathlum   = {ammo="Yamarang"}
    sets.weapons.WSTathlum   = {ammo="Voluspa Tathlum"}
    sets.weapons.MATathlum   = {ammo="Pemphredo Tathlum"}
    sets.weapons.ENMTathlum  = {ammo="Aqreqaq Bomblet"}
    sets.weapons.DTTathlum   = {ammo="Staunch Tathlum +1"}

    sets.TreasureHunter = {head="Volte Cap",waist="Chaac Belt",legs=gear.herc_legs_th}

    -- Precast Sets
    sets.Enmity = {main=gear.fudoC,sub="Shuhansadamune",ammo="Date Shuriken",
        head="Genmei Kabuto",neck="Moonlight Necklace",ear1="Cryptic Earring",ear2="Trux Earring",
        body="Emet Harness +1",hands="Kurys Gloves",ring1="Eihwaz Ring",ring2="Supershear Ring",
        back=gear.EnmCape,waist="Kasiri Belt",legs="Zoar Subligar +1",feet="Ahosi Leggings"}
    -- enm+84~164, pdt-27, dt-2, meva+398
    sets.nagi = {main="Nagi"}   -- applied in job_post_precast and job_post_midcast for enmity with few shadows
    sets.precast.JA.Yonin          = set_combine(sets.Enmity, {})
    sets.precast.JA.Provoke        = set_combine(sets.Enmity, {})
    sets.precast.JA.Warcry         = set_combine(sets.Enmity, {})
    sets.precast.JA.Vallation      = set_combine(sets.Enmity, {})
    sets.precast.JA.Swordplay      = set_combine(sets.Enmity, {})
    sets.precast.JA.Pflug          = set_combine(sets.Enmity, {})
    sets.precast.JA.Sentinel       = set_combine(sets.Enmity, {})
    sets.precast.JA.Souleater      = set_combine(sets.Enmity, {})
    sets.precast.JA['Last Resort'] = set_combine(sets.Enmity, {})
    sets.precast.JA['Mijin Gakure'] = {main="Nagi"}

    sets.gavialis = {head="Gavialis Helm"} -- combined in job_post_precast
    sets.precast.WS = {ammo="Voluspa Tathlum",
        head="Adhemar Bonnet +1",neck="Fotia Gorget",ear1="Trux Earring",ear2="Moonshade Earring",
        body="Kendatsuba Samue +1",hands="Adhemar Wristbands +1",ring1="Ilabrat Ring",ring2="Regal Ring",
        back=gear.ShunCape,waist="Fotia Belt",legs="Samnuha Tights",feet=gear.herc_feet_ta}
    sets.precast.WS['Blade: Shun'] = {ammo="Voluspa Tathlum",
        head="Kendatsuba Jinpachi +1",neck="Fotia Gorget",ear1="Lugra Earring +1",ear2="Odr Earring",
        body="Kendatsuba Samue +1",hands="Kendatsuba Tekko +1",ring1="Ilabrat Ring",ring2="Regal Ring",
        back=gear.ShunCape,waist="Fotia Belt",legs="Jokushu Haidate",feet="Kendatsuba Sune-Ate +1"}
    sets.precast.WS['Blade: Ten'] = {ammo="Voluspa Tathlum",
        head="Hachiya Hatsuburi +3",neck="Ninja Nodowa +2",ear1="Lugra Earring +1",ear2="Moonshade Earring",
        body=gear.herc_body_wsd,hands=gear.herc_hands_wsd,ring1="Gere Ring",ring2="Regal Ring",
        back=gear.TenCape,waist="Sailfi Belt +1",legs="Mochizuki Hakama +3",feet="Mochizuki Kyahan +3"}
    sets.precast.WS['Blade: Metsu'] = {ammo="Voluspa Tathlum",
        head="Hachiya Hatsuburi +3",neck="Ninja Nodowa +2",ear1="Lugra Earring +1",ear2="Odr Earring",
        body=gear.herc_body_wsd,hands=gear.herc_hands_wsd,ring1="Ilabrat Ring",ring2="Regal Ring",
        back=gear.MetsuCape,waist="Grunfeld Rope",legs="Jokushu Haidate",feet=gear.herc_feet_wsd}
    sets.precast.WS['Blade: Kamu'] = {ammo="Voluspa Tathlum",
        head="Hachiya Hatsuburi +3",neck="Ninja Nodowa +2",ear1="Brutal Earring",ear2="Lugra Earring +1",
        body="Kendatsuba Samue +1",hands="Malignance Gloves",ring1="Gere Ring",ring2="Epona's Ring",
        back=gear.TenCape,waist="Fotia Belt",legs="Mochizuki Hakama +3",feet=gear.herc_feet_ta}
    sets.precast.WS['Blade: Hi'] = {ammo="Yetshila +1",
        head="Hachiya Hatsuburi +3",neck="Ninja Nodowa +2",ear1="Odr Earring",ear2="Ishvara Earring",
        body="Kendatsuba Samue +1",hands="Mummu Wrists +2",ring1="Ilabrat Ring",ring2="Regal Ring",
        back=gear.HiCape,waist="Windbuffet Belt +1",legs="Mummu Kecks +2",feet="Mummu Gamashes +2"}
    sets.precast.WS['Blade: Jin'] = set_combine(sets.precast.WS['Blade: Hi'], {
        head="Adhemar Bonnet +1",ear2="Moonshade Earring",body="Kendatsuba Samue +1",
        back=gear.ShunCape,waist="Fotia Belt"})
    sets.precast.WS.Evisceration = set_combine(sets.precast.WS['Blade: Jin'], {})
    sets.precast.WS['Vorpal Blade'] = set_combine(sets.precast.WS['Blade: Jin'], {})
    sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS['Blade: Ten'], {})
    sets.precast.WS['Tachi: Kasha'] = set_combine(sets.precast.WS['Savage Blade'], {})
    sets.precast.WS['Judgement']    = set_combine(sets.precast.WS['Savage Blade'], {})
    sets.precast.WS['True Strike']  = set_combine(sets.precast.WS['Savage Blade'], {})

    sets.precast.WS['Aeolian Edge'] = {ammo="Seething Bomblet +1",
        head="Mochizuki Hatsuburi +3",neck="Fotia Gorget",ear1="Moonshade Earring",ear2="Friomisi Earring",
        body="Samnuha Coat",hands=gear.herc_hands_ma,ring1="Dingir Ring",ring2="Metamorph Ring +1",
        back=gear.MetsuCape,waist="Fotia Belt",legs=gear.herc_legs_ma,feet=gear.herc_feet_ma}
    sets.precast.WS.Cyclone = set_combine(sets.precast.WS['Aeolian Edge'], {})
    sets.precast.WS['Blade: Yu']       = set_combine(sets.precast.WS['Aeolian Edge'], {ear1="Hecate's Earring"})
    sets.precast.WS['Blade: Ei']       = set_combine(sets.precast.WS['Aeolian Edge'], {head="Pixie Hairpin +1",ring2="Archon Ring"})
    sets.precast.WS['Sanguine Blade']  = set_combine(sets.precast.WS['Blade: Ei'], {})
    sets.precast.WS['Red Lotus Blade'] = set_combine(sets.precast.WS['Aeolian Edge'], {})
    sets.precast.WS['Seraph Blade']    = set_combine(sets.precast.WS['Aeolian Edge'], {})
    sets.precast.WS['Flash Nova']      = set_combine(sets.precast.WS['Aeolian Edge'], {})

    sets.precast.WS['Blade: To'] = {ammo="Seething Bomblet +1",
        head="Mochizuki Hatsuburi +3",neck="Fotia Gorget",ear1="Moonshade Earring",ear2="Friomisi Earring",
        body="Samnuha Coat",hands=gear.herc_hands_ma,ring1="Gere Ring",ring2="Epona's Ring",
        back=gear.TenCape,waist="Fotia Belt",legs="Mochizuki Hakama +3",feet=gear.herc_feet_ma}
    sets.precast.WS['Blade: Teki']  = set_combine(sets.precast.WS['Blade: To'], {})
    sets.precast.WS['Blade: Chi']   = set_combine(sets.precast.WS['Blade: To'], {})
    sets.precast.WS['Tachi: Jinpu'] = set_combine(sets.precast.WS['Blade: To'], {})

    sets.precast.WS['Blade: Retsu'] = {ammo="Yetshila +1",
        head="Malignance Chapeau",neck="Sanctity Necklace",ear1="Dignitary's Earring",ear2="Telos Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Etana Ring",ring2="Regal Ring",
        back=gear.TPCape,waist="Eschan Stone",legs="Malignance Tights",feet="Malignance Boots"}
    sets.precast.WS['Tachi: Ageha']  = set_combine(sets.precast.WS['Blade: Retsu'], {})
    sets.precast.WS['Tachi: Gekko']  = set_combine(sets.precast.WS['Blade: Retsu'], {})
    sets.precast.WS['Tachi: Hobaku'] = set_combine(sets.precast.WS['Blade: Retsu'], {})
    sets.precast.WS['Flat Blade']    = set_combine(sets.precast.WS['Blade: Retsu'], {})

    sets.precast.RA = {ammo=empty} -- don't /ra
    sets.precast.FC = {main=gear.fudoB,sub="Shuhansadamune",ammo="Sapience Orb",
        head=gear.herc_head_fc,neck="Orunmila's Torque",ear1="Loquacious Earring",ear2="Etiolation Earring",
        body="Adhemar Jacket",hands="Leyline Gloves",ring1="Kishar Ring",ring2="Defending Ring",
        back=gear.FCCape,waist="Flume Belt +1",legs="Rawhide Trousers",feet=gear.herc_feet_fc}
    -- fc+59~66
    sets.precast.FC.Ninjutsu = set_combine(sets.precast.FC, {main="Kikoku",sub="Shuhansadamune"})
    sets.precast.FC.Utsusemi = set_combine(sets.precast.FC.Ninjutsu, {neck="Magoraga Beads"})

    sets.precast.Waltz = {ammo="Yamarang",
        head="Mummu Bonnet +2",body="Mummu Jacket +2",hands="Mummu Wrists +2",
        waist="Chaac Belt",legs="Mummu Kecks +2",feet="Mummu Gamashes +2"}
    sets.precast.Step = {ammo="Yamarang",
        head="Malignance Chapeau",neck="Ninja Nodowa +2",ear1="Odr Earring",ear2="Telos Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Ilabrat Ring",ring2="Cacoethic Ring +1",
        back=gear.TPCape,waist="Eschan Stone",legs="Malignance Tights",feet="Mummu Gamashes +2"}
    sets.precast.JA['Violent Flourish'] = set_combine(sets.precast.Step, {
        neck="Sanctity Necklace",ear1="Dignitary's Earring",ring1="Etana Ring"})
    sets.precast.JA['Animated Flourish'] = set_combine(sets.Enmity, {})
    sets.precast.WS.NoDmg = set_combine(sets.precast.Step, {neck="Combatant's Torque"})

    -- Midcast Sets
    sets.midcast.RA = {ammo=empty}

    sets.midcast.Ninjutsu = {main=gear.fudoC,sub="Shuhansadamune",ammo="Date Shuriken",
        head="Malignance Chapeau",neck="Warder's Charm +1",ear1="Eabani Earring",ear2="Infused Earring",
        body="Malignance Tabard",hands="Mochizuki Tekko +3",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.EnmCape,waist="Engraved Belt",legs="Malignance Tights",feet="Malignance Boots"}
    sets.midcast['Migawari: Ichi'] = set_combine(sets.midcast.Ninjutsu, {back=gear.FCCape})

    sets.midcast.Utsusemi = set_combine(sets.midcast.Ninjutsu, {feet="Hattori Kyahan +1"})
    -- pdt-50, dt-44
    sets.midcast.Utsusemi.Enmity = {main=gear.fudoC,sub="Shuhansadamune",ammo="Date Shuriken",
        head="Genmei Kabuto",neck="Moonlight Necklace",ear1="Cryptic Earring",ear2="Trux Earring",
        body="Emet Harness +1",hands="Kurys Gloves",ring1="Eihwaz Ring",ring2="Defending Ring",
        back=gear.EnmCape,waist="Kasiri Belt",legs="Malignance Tights",feet="Hattori Kyahan +1"}
    -- enm+65~145, pdt-40, dt-19
    sets.midcast.Utsusemi.Enmity.NoCancel = set_combine(sets.midcast.Utsusemi.Enmity, {legs="Zoar Subligar +1",feet="Ahosi Leggings"})
    -- more enmity but less defense, used when ichi or ni will be cast with no effect
    sets.midcast.Utsusemi.SIRD = {main="Tancho +1",sub="Tancho",ammo="Staunch Tathlum +1",
        head="Genmei Kabuto",neck="Moonlight Necklace",ear1="Genmei Earring",ear2="Trux Earring",
        body="Emet Harness +1",hands="Rawhide Gloves",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.EnmCape,waist="Kasiri Belt",legs="Malignance Tights",feet="Hattori Kyahan +1"}
    -- enm+45, pdt-50, dt-28, sird+106

    sets.midcast.ElementalNinjutsu = {main="Gokotai",sub="Tauret",ammo="Pemphredo Tathlum",
        head="Mochizuki Hatsuburi +3",neck="Sanctity Necklace",ear1="Hecate's Earring",ear2="Friomisi Earring",
        body="Samnuha Coat",hands="Leyline Gloves",ring1="Dingir Ring",ring2="Metamorph Ring +1",
        back=gear.NukeCape,waist="Eschan Stone",legs=gear.herc_legs_ma,feet="Mochizuki Kyahan +3"}
    sets.midcast.ElementalNinjutsu.MB = set_combine(sets.midcast.ElementalNinjutsu, {
        neck="Warder's Charm +1",hands=gear.herc_hands_ma,ring1="Locus Ring",ring2="Mujin Band"})
    sets.buff.Futae = {hands="Hattori Tekko +1"}
    sets.orpheus    = {waist="Orpheus's Sash"}
    sets.ele_obi    = {waist="Hachirin-no-Obi"}
    sets.nuke_belt  = {waist="Eschan Stone"}
    sets.donargun   = {range="Donar Gun",ammo=empty}

    sets.midcast.EnfeeblingNinjutsu = {main=gear.fudoC,sub="Gokotai",ammo="Yamarang",
        head="Hachiya Hatsuburi +3",neck="Moonlight Necklace",ear1="Dignitary's Earring",ear2="Gwati Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1=gear.Lstikini,ring2="Metamorph Ring +1",
        back=gear.FCCape,waist="Eschan Stone",legs="Malignance Tights",feet="Hachiya Kyahan +3"}
    sets.kajabow    = {range="Ullr",ammo=empty}

    sets.midcast['Enfeebling Magic'] = set_combine(sets.midcast.EnfeeblingNinjutsu, {})
    sets.midcast.Repose = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast['Enhancing Magic'] = {neck="Incanter's Torque",ear1="Andoaa Earring",ear2="Mimir Earring",
        ring1=gear.Lstikini,ring2=gear.Rstikini,waist="Olympus Sash"}
    sets.phlx = {head=gear.taeon_head_phlx,body=gear.taeon_body_phlx,
        hands=gear.taeon_hands_phlx,legs=gear.taeon_legs_phlx,feet=gear.taeon_feet_phlx}
    sets.midcast.Phalanx = set_combine(sets.midcast['Enhancing Magic'], sets.phlx)
    sets.midcast.Refresh = {waist="Gishdubar Sash"}
    sets.midcast.Haste = {}
    sets.midcast.Stoneskin = {}
    sets.midcast.Aquaveil = {}
    sets.midcast.Poisonga = {}
    sets.midcast.Diaga = {}
    sets.midcast.Banishga = {}
    sets.midcast.Flash           = set_combine(sets.Enmity, {})
    sets.midcast.Stun            = set_combine(sets.Enmity, {})
    sets.midcast['Blue Magic'] = {}
    sets.midcast['Stinking Gas'] = set_combine(sets.Enmity, {})
    sets.midcast['Sheep Song']   = set_combine(sets.Enmity, {})
    sets.midcast['Geist Wall']   = set_combine(sets.Enmity, {})
    sets.midcast['Blank Gaze']   = set_combine(sets.Enmity, {})
    sets.midcast.Soporific       = set_combine(sets.Enmity, {})
    sets.midcast.Jettatura       = set_combine(sets.Enmity, {})

    -- Sets to return to when not performing an action.
    sets.idle = {main=gear.fudoC,sub="Shuhansadamune",ammo="Yamarang",
        head="Genmei Kabuto",neck="Loricate Torque +1",ear1="Eabani Earring",ear2="Etiolation Earring",
        body="Hizamaru Haramaki +2",hands="Malignance Gloves",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.EnmCape,waist="Engraved Belt",legs="Malignance Tights",feet="Hachiya Kyahan +3"}
    sets.idle.PDT = {main=gear.fudoC,sub="Shuhansadamune",ammo="Yamarang",
        head="Malignance Chapeau",neck="Unmoving Collar +1",ear1="Eabani Earring",ear2="Etiolation Earring",
        body="Emet Harness +1",hands="Malignance Gloves",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.EnmCape,waist="Engraved Belt",legs="Malignance Tights",feet="Malignance Boots"}
    -- pdt-50, dt-40, eva~1103, meva+657, enm+30
    sets.idle.Rf  = set_combine(sets.idle, {
        head=gear.herc_head_rf,body="Mekosuchinae Harness",ring1=gear.Lstikini,ring2=gear.Rstikini,
        waist="Flume Belt +1",legs="Rawhide Trousers"})
    sets.idle.Eva = {main="Tancho +1",sub="Shuhansadamune",ammo="Yamarang",
        head="Malignance Chapeau",neck="Ninja Nodowa +2",ear1="Eabani Earring",ear2="Infused Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Ilabrat Ring",ring2="Defending Ring",
        back=gear.EnmCape,waist="Sveltesse Gouriz +1",legs="Malignance Tights",feet="Malignance Boots"}
    sets.idle.EvaPDT = set_combine(sets.idle.Eva, {})
    -- pdt-50, dt-41, eva~1184, meva+712, rg+1
    sets.idle.DW = {ammo="Yamarang",
        head="Malignance Chapeau",neck="Loricate Torque +1",ear1="Eabani Earring",ear2="Suppanomimi",
        body="Adhemar Jacket +1",hands="Floral Gauntlets",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.DWCape,waist="Reiki Yotai",legs="Mochizuki Hakama +3",feet="Hizamaru Sune-Ate +2"}

    sets.defense.PDT    = set_combine(sets.idle.PDT, {})
    sets.defense.EvaPDT = set_combine(sets.idle.EvaPDT, {})
    sets.defense.MEVA   = {main=gear.fudoC,sub="Shuhansadamune",ammo="Yamarang",
        head="Kendatsuba Jinpachi +1",neck="Ninja Nodowa +2",ear1="Eabani Earring",ear2="Telos Earring",
        body="Kendatsuba Samue +1",hands="Kendatsuba Tekko +1",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.EnmCape,waist="Engraved Belt",legs="Malignance Tights",feet="Kendatsuba Sune-Ate +1"}
    -- Heishi/Shuriken: pdt-35, dt-25, eva~1009, meva+655, acc~1283/1258/1185

    sets.danzo   = {feet="Danzo Sune-Ate"}
    sets.hachiya = {feet="Hachiya Kyahan +3"}
    sets.Kiting = sets.hachiya
    sets.buff.doom = {neck="Nicander's Necklace",ring1="Eshmun's Ring",waist="Gishdubar Sash"}

    -- Engaged sets
    sets.engaged = {main=gear.fudoB,sub="Shuhansadamune",ammo="Date Shuriken",
        head="Adhemar Bonnet +1",neck="Ninja Nodowa +2",ear1="Brutal Earring",ear2="Telos Earring",
        body="Kendatsuba Samue +1",hands="Adhemar Wristbands +1",ring1="Gere Ring",ring2="Epona's Ring",
        back=gear.TPCape,waist="Windbuffet Belt +1",legs="Samnuha Tights",feet=gear.herc_feet_ta}
    -- Heishi/Shuriken: acc~1216/1191/1062, haste+26, stp+47, da+12, ta+33, qa+2, pdt-12, meva+369
    sets.engaged.DW30 = set_combine(sets.engaged, {ear1="Eabani Earring",back=gear.DWCape,waist="Reiki Yotai"})
    sets.engaged.DW15 = set_combine(sets.engaged.DW30, {ear2="Suppanomimi",body="Adhemar Jacket +1"})
    sets.engaged.DW00 = set_combine(sets.engaged.DW15, {feet="Hizamaru Sune-Ate +2"})

    sets.engaged.PDef = set_combine(sets.engaged, {
        head="Malignance Chapeau",body="Malignance Tabard",ring1="Vocane Ring +1",ring2="Defending Ring",legs="Malignance Tights"})
    -- Heishi/Shuriken: acc~1279/1254/1165, haste+26, stp+69, da+6, ta+12, qa+2, pdt-50, dt-40, sb=41, eva~1029, meva+530
    sets.engaged.DW30.PDef = set_combine(sets.engaged.PDef, {ear1="Eabani Earring",back=gear.DWCape,waist="Reiki Yotai"})
    sets.engaged.DW15.PDef = set_combine(sets.engaged.DW30.PDef, {ear2="Suppanomimi"})
    sets.engaged.DW00.PDef = set_combine(sets.engaged.DW15.PDef, {})

    sets.engaged.MEVA = {main=gear.fudoB,sub="Shuhansadamune",ammo="Date Shuriken",
        head="Kendatsuba Jinpachi +1",neck="Ninja Nodowa +2",ear1="Brutal Earring",ear2="Telos Earring",
        body="Malignance Tabard",hands="Kendatsuba Tekko +1",ring1="Gere Ring",ring2="Defending Ring",
        back=gear.TPCape,waist="Windbuffet Belt +1",legs="Malignance Tights",feet="Kendatsuba Sune-Ate +1"}
    -- Heishi/Shuriken: acc~1325/1300/1192, haste+26, stp+54, da+6, ta+19, qa+2, pdt-36, dt-26, sb=50, eva~1009, meva+619
    sets.engaged.DW30.MEVA = set_combine(sets.engaged.MEVA, {ear1="Eabani Earring",back=gear.DWCape,waist="Reiki Yotai"})
    sets.engaged.DW15.MEVA = set_combine(sets.engaged.DW30.MEVA, {ear2="Suppanomimi",body="Adhemar Jacket +1"})
    sets.engaged.DW00.MEVA = set_combine(sets.engaged.DW15.MEVA, {})

    sets.engaged.None      = set_combine(sets.engaged.MEVA, {})
    sets.engaged.DW30.None = set_combine(sets.engaged.DW30.MEVA, {})
    sets.engaged.DW15.None = set_combine(sets.engaged.DW15.MEVA, {})
    sets.engaged.DW00.None = set_combine(sets.engaged.DW00.MEVA, {})

    sets.engaged.MEVA.PDef      = set_combine(sets.engaged.MEVA,           {head="Malignance Chapeau",ring1="Vocane Ring +1"})
    sets.engaged.DW30.MEVA.PDef = set_combine(sets.engaged.MEVA.PDef,      {ear1="Eabani Earring",back=gear.DWCape,waist="Reiki Yotai"})
    sets.engaged.DW15.MEVA.PDef = set_combine(sets.engaged.DW30.MEVA.PDef, {ear2="Suppanomimi"})
    sets.engaged.DW00.MEVA.PDef = set_combine(sets.engaged.DW15.MEVA.PDef, {})

    sets.engaged.Acc = {main=gear.fudoB,sub="Shuhansadamune",ammo="Date Shuriken",
        head="Kendatsuba Jinpachi +1",neck="Ninja Nodowa +2",ear1="Brutal Earring",ear2="Telos Earring",
        body="Kendatsuba Samue +1",hands="Adhemar Wristbands +1",ring1="Gere Ring",ring2="Epona's Ring",
        back=gear.TPCape,waist="Windbuffet Belt +1",legs="Kendatsuba Hakama +1",feet="Kendatsuba Sune-Ate +1"}
    -- Heishi/Shuriken: acc~1323/1298/1173, haste+26, stp+40, da+9, ta+30, qa+2, pdt-10, meva+539
    sets.engaged.DW30.Acc = set_combine(sets.engaged.Acc,      {ear1="Eabani Earring",back=gear.DWCape,waist="Reiki Yotai"})
    sets.engaged.DW15.Acc = set_combine(sets.engaged.DW30.Acc, {ear2="Suppanomimi",body="Adhemar Jacket +1"})
    sets.engaged.DW00.Acc = set_combine(sets.engaged.DW15.Acc, {feet="Hizamaru Sune-Ate +2"})

    sets.engaged.Acc.PDef = set_combine(sets.engaged.Acc, {
        head="Malignance Chapeau",body="Malignance Tabard",hands="Malignance Gloves",ring2="Defending Ring",
        legs="Malignance Tights",feet="Malignance Boots"})
    sets.engaged.DW30.Acc.PDef = set_combine(sets.engaged.Acc.PDef, {ear1="Eabani Earring",back=gear.DWCape,waist="Reiki Yotai"})
    sets.engaged.DW15.Acc.PDef = set_combine(sets.engaged.DW30.Acc.PDef, {ear2="Suppanomimi"})
    sets.engaged.DW00.Acc.PDef = set_combine(sets.engaged.DW15.Acc.PDef, {})

    -- Spells default to a midcast of FastRecast before layering on the above sets
    sets.midcast.FastRecast = set_combine(sets.defense.EvaPDT, {})
    sets.hpup = {
        head="Genmei Kabuto",neck="Unmoving Collar +1",ear1="Odnowa Earring +1",ear2="Etiolation Earring",
        body="Adhemar Jacket",hands="Malignance Gloves",ring1="Etana Ring",ring2="Regal Ring",
        back="Moonbeam Cape",waist="Oneiros Belt",legs="Kendatsuba Hakama +1",feet="Kendatsuba Sune-Ate +1"}
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.
function job_precast(spell, action, spellMap, eventArgs)
    if S{'Defender','Souleater','Last Resort'}:contains(spell.english) and buffactive[spell.english] then
        send_command('cancel '..spell.english)
        eventArgs.cancel = true
    elseif state.SIRDUtsu.value and spellMap == 'Utsusemi' then
        enable('main','sub')
        state.OffenseMode:set('None')
        hud_update_on_state_change('Offense Mode')
    elseif spell.english == 'Mijin Gakure' then
        if not buffactive.Reraise then
            enable('main','sub')
        end
    end
end

-- Run after the general precast() is done.
function job_post_precast(spell, action, spellMap, eventArgs)
    if spell.type == 'WeaponSkill' then
        if buffactive['elvorseal'] and player.inventory["Heidrek Boots"] then equip({feet="Heidrek Boots"}) end
        if state.WeaponskillMode.value == 'NoDmg' then
            if info.magic_ws:contains(spell.english) then
                equip(sets.naked)
            else
                equip(sets.precast.WS.NoDmg)
            end
        elseif info.obi_ws:contains(spell.english) then
            equip(resolve_ele_belt(spell, sets.ele_obi, sets.nuke_belt, 2.5))
        elseif spell.english == 'Blade: Shun'  and S{'Fire','Light','Lightning'}:contains(world.day_element)
        or     spell.english == 'Blade: Kamu'  and S{'Wind','Lightning','Dark'}:contains(world.day_element)
        or     spell.english == 'Blade: Ku'    and S{'Earth','Dark','Light'}:contains(world.day_element)
        or     spell.english == 'Evisceration' and S{'Earth','Dark','Light'}:contains(world.day_element) then
            equip(sets.gavialis)
        end
    elseif spell.type == 'JobAbility' then
        if not buffactive['Copy Image (4+)'] and sets.precast.JA[spell.english] then
            -- use nagi instead of fudo C for enmity
            equip(sets.nagi)
        end
    end
    if state.RangedMode.value == 'Shuriken' then
        equip(sets.weapons.Daken)
    elseif state.RangedMode.value == 'Tathlum' and spell.type == 'JobAbility' then
        equip(sets.weapons.ENMTathlum)
    end
end

-- Run after the default midcast() is done.
-- eventArgs is the same one used in job_midcast, in case information needs to be persisted.
function job_post_midcast(spell, action, spellMap, eventArgs)
    if spellMap == 'ElementalNinjutsu' then
        if state.MagicBurst.value then
            equip(sets.midcast.ElementalNinjutsu.MB)
        end
        equip(resolve_ele_belt(spell, sets.ele_obi, sets.nuke_belt, 2.5))
        if state.OffenseMode.value == 'None' and spell.english:startswith('Raiton') then
            equip(sets.donargun)
        end
        if state.Buff.Futae then
            equip(sets.buff.Futae)
        end
    elseif spellMap == 'EnfeeblingNinjutsu' then
        if state.OffenseMode.value == 'None' then
            equip(sets.kajabow)
        end
    elseif spellMap == 'Utsusemi' then
        local enmity_utsu = state.Buff.Yonin and state.CastingMode.value == 'Enmity'
        if not enmity_utsu then
            equip(sets.midcast.FastRecast, sets.midcast.Utsusemi)
        end

        -- shadow cancelling and enmity katana logic
        state.LastUtsu.previous_value = state.LastUtsu.value -- restore to this value in aftercast if interrupted
        if     spell.english:endswith('Ichi') then
            if not buffactive['Copy Image (4+)'] then
                if state.LastUtsu.value > 1 then
                    send_command('cancel copy image,copy image (2),copy image (3)')
                end
                if enmity_utsu and not has_any_buff_of(S{'weakness','slow','Elegy'}) then
                    equip(sets.nagi)
                end
                state.LastUtsu:set(1)
            elseif enmity_utsu and state.LastUtsu.value > 1 then
                equip(sets.midcast.Utsusemi.Enmity.NoCancel)
            end
        elseif spell.english:endswith('Ni') then
            if not buffactive['Copy Image (4+)'] then
                if state.LastUtsu.value == 3 then
                    send_command('cancel copy image,copy image (2),copy image (3)')
                    state.LastUtsu:set(2)
                end
                if enmity_utsu and not has_any_buff_of(S{'weakness','slow','Elegy'}) then
                    equip(sets.nagi)
                end
            elseif enmity_utsu and state.LastUtsu.value == 3 then
                equip(sets.midcast.Utsusemi.Enmity.NoCancel)
            end
            if state.LastUtsu.value < 3 then
                state.LastUtsu:set(2)
            end
        else
            if enmity_utsu and not buffactive['Copy Image (4+)'] and not has_any_buff_of(S{'weakness','slow','Elegy'}) then
                equip(sets.nagi)
            end
            state.LastUtsu:set(3)
        end

        if state.SIRDUtsu.value then
            equip(sets.midcast.Utsusemi.SIRD)
        end
    elseif not buffactive['Copy Image (4+)'] and S{'Flash','Stun'}:contains(spell.english) then
        equip(sets.nagi)
    end
    if state.RangedMode.value == 'Shuriken' then
        equip(sets.weapons.Daken)
    elseif state.RangedMode.value == 'Tathlum' and spellMap == 'Utsusemi' and not state.SIRDUtsu.value then
        equip(sets.weapons.ENMTathlum)
    end
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_aftercast(spell, action, spellMap, eventArgs)
    if spell.interrupted then
        if spellMap == 'Utsusemi' then
            state.LastUtsu:set(state.LastUtsu.previous_value)
        end
        send_command('wait 0.5;gs c update')
        interrupted_message(spell)
    elseif spell.type == 'WeaponSkill' then
        if state.WSMsg.value then
            send_command('@input /p '..spell.english)
        end
    elseif spell.english == 'Migawari: Ichi' then
        if state.AutoHybrid.value == 'Miga' then
            if player_has_shadows() then
                state.HybridMode:set('Normal')
            end
            state.CastingMode:set('Enmity')
            hud_update_on_state_change()
        end
    elseif spellMap == 'Utsusemi' then
        if     state.AutoHybrid.value == 'Utsu' then
            state.HybridMode:set('Normal')
            hud_update_on_state_change('Hybrid Mode')
        elseif state.AutoHybrid.value == 'Miga' and state.Buff.Migawari then
            state.HybridMode:set('Normal')
            state.CastingMode:set('Enmity')
            hud_update_on_state_change()
        end
        if state.SIRDUtsu.value then
            state.SIRDUtsu:unset()
            hud_update_on_state_change('SIRD Utsu')
        end
    elseif spell.type == 'JobAbility' then
        if not sets.precast.JA[spell.english] then
            eventArgs.handled = true
        end
    elseif spell.type == 'Rune' then
        eventArgs.handled = true
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
    if state.DefenseMode.value == 'None' and S{'stun','terror','petrification'}:contains(lbuff) then
        if gain then
            if state.RangedMode.value == 'Tathlum' then
                equip(sets.engaged.PDef, sets.weapons.TPTathlum)
            else
                equip(sets.engaged.PDef)
            end
        elseif not midaction() then
            handle_equipping_gear(player.status)
        end
    elseif state.AutoHybrid.value ~= 'off' and lbuff:startswith('copy ') then
        if gain or player_has_shadows() then
            if state.AutoHybrid.value == 'Utsu' or state.Buff.Migawari then
                state.HybridMode:set('Normal')
            end
        else
            state.HybridMode:set('PDef')
            if not midaction() then
                handle_equipping_gear(player.status)
            end
        end
        hud_update_on_state_change('Hybrid Mode')
    elseif state.AutoHybrid.value == 'Miga' and lbuff == 'migawari' then
        if gain then
            if player_has_shadows() then
                state.HybridMode:set('Normal')
            end
            state.CastingMode:set('Enmity')
        else
            state.HybridMode:set('PDef')
            state.CastingMode:set('Normal')
            if not midaction() then
                handle_equipping_gear(player.status)
            end
        end
        hud_update_on_state_change()
    elseif not midaction() then
        if lbuff == 'doom' then
            handle_equipping_gear(player.status)
        elseif lbuff == 'phalanx' then
            if gain then
                handle_equipping_gear(player.status)
            end
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
        if newValue == 'None' then
            info.ws_binds:bind({value='FudoB'})
        else
            if oldValue == 'None' then
                info.ws_binds:bind(state.CombatWeapon)
            end
            equip(sets.weapons[state.CombatWeapon.value])
            disable('main','sub')
        end
        handle_equipping_gear(player.status)
    elseif stateField == 'Combat Weapon' then
        if state.OffenseMode.value == 'None' then
            info.ws_binds:bind({value='FudoB'})
        else
            info.ws_binds:bind(state.CombatWeapon)
            enable('main','sub','range','ammo')
            -- try to handle exchanging mainhand and offhand weapons gracefully
            local new_set = sets.weapons[state.CombatWeapon.value]
            if player.equipment.sub == new_set.main then
                equip({main=empty,sub=empty})
                add_to_chat(123, 'unequipped weapons')
            elseif player.equipment.main == new_set.sub then
                equip({main=new_set.main,sub=empty})
                add_to_chat(123, 'unequipped offhand')
            else
                equip(new_set)
            end
            disable('main','sub')
        end
    elseif stateField == 'Hybrid Mode' then
        if state.AutoHybrid.value ~= 'off' then
            state.AutoHybrid:reset()
            add_to_chat(104,state.AutoHybrid.description .. ' is now ' .. state.AutoHybrid.current .. '.')
        end
    elseif stateField == 'Auto Hybrid' and newValue ~= 'off' then
        if player_has_shadows() and (newValue == 'Utsu' or state.Buff.Migawari) then
            state.HybridMode:set('Normal')
        else
            state.HybridMode:set('PDef')
        end
        if newValue == 'Miga' then
            if state.Buff.Migawari then
                state.CastingMode:set('Enmity')
            else
                state.CastingMode:set('Normal')
            end
        end
        hud_update_on_state_change()
    elseif stateField == 'Ranged Mode' then
        if not midaction() then
            handle_equipping_gear(player.status)
        end
    elseif stateField:endswith('Defense Mode') then
        if newValue ~= 'None' then
            if newValue == 'MDT50' then
                state.DefenseMode:set('Magical')
            end
            handle_equipping_gear(player.status)
        end
    elseif stateField == 'Fishing Gear' then
        if newValue then
            state.Cooking:unset()
            sets.Fishing = {range="Ebisu Fishing Rod +1",ammo=empty,
                head="Tlahtlamah Glasses",neck="Fisher's Torque",
                body="Fisherman's Smock",hands="Angler's Gloves",ring1="Noddy Ring",ring2="Puffin Ring",
                waist="Fisher's Rope",legs="Angler's Hose",feet="Waders"}
            equip(sets.Fishing)
            disable('range','ammo','ring1','ring2')
            send_command('bind ^numpad0 input /fish')
        else
            enable('range','ammo','ring1','ring2')
        end
    elseif stateField == 'Cooking Gear' then
        if newValue then
            state.Fishing:unset()
            sets.Cooking = {main="Hocho",sub="Chef's Shield",
                head="Chef's Hat",neck="Culinarian's Torque",
                body="Culinarian's Smock",ring1="Craftmaster's Ring",ring2="Artificer's Ring"}
            equip(sets.Cooking)
            enable('main','sub')
            send_command('bind ^numpad0 input /lastsynth')
        else
            equip(sets.weapons[state.CombatWeapon.value])
            disable('main','sub')
        end
    elseif stateField == 'HELM Gear' then
        if newValue then
            sets.HELM = {body="Trench Tunic",hands="Treefeller Gloves",
                waist="Field Rope",legs="Dredger Hose",feet="Agrarian Boots"}
            equip(sets.idle, sets.HELM)
            send_command('alias sickle  input /item "Sickle"<t>')
            send_command('alias tsickle input /item "Trbl. Sickle"<t>')
            send_command('alias axe     input /item "Hatchet"<t>')
            send_command('alias taxe    input /item "Trbl. Hatchet"<t>')
            send_command('alias pick    input /item "Pickaxe"<t>')
            send_command('alias tpick   input /item "Trbl. Pickaxe"<t>')
        end
    end

    if hud_update_on_state_change then
        hud_update_on_state_change(stateField)
    end
end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements standard library decisions.
-------------------------------------------------------------------------------------------------------------------

-- Modify the default idle set after it was constructed.
function customize_idle_set(idleSet)
    if state.DefenseMode.value == 'None' then
        if state.CombatWeapon.value == 'Gokotai' and state.IdleMode.value == 'Normal' then
            idleSet = set_combine(idleSet, sets.idle.DW)
        elseif 7*60 <= world.time and world.time < 17*60 then
            if S{'Normal','Rf'}:contains(state.IdleMode.value) then
                idleSet = set_combine(idleSet, sets.danzo)
            end
            sets.Kiting = sets.danzo
        else
            sets.Kiting = sets.hachiya
        end
        if state.Fishing.value then
            idleSet = set_combine(idleSet, sets.Fishing)
            if state.Kiting.value then
                idleSet = set_combine(idleSet, sets.Kiting)
            end
        elseif state.Cooking.value then
            idleSet = set_combine(idleSet, sets.Cooking)
            if state.Kiting.value then
                idleSet = set_combine(idleSet, sets.Kiting)
            end
        elseif state.HELM.value then
            idleSet = set_combine(idleSet, sets.HELM)
            if state.Kiting.value then
                idleSet = set_combine(idleSet, sets.Kiting)
            end
        end
    end
    if has_any_buff_of(S{'petrification','sleep','stun','terror'}) then
        if state.RangedMode.value == 'Tathlum' then
            idleSet = set_combine(sets.idle.PDT, sets.weapons.TPTathlum)
        else
            idleSet = set_combine(sets.idle.PDT, {})
        end
    end
    if state.Buff.doom then
        idleSet = set_combine(idleSet, sets.buff.doom)
    end
    if state.RangedMode.value == 'Shuriken' then
        idleSet = set_combine(idleSet, sets.weapons.Daken)
    end
    return idleSet
end

-- Modify the default defense set after it was constructed.
function customize_defense_set(defenseSet)
    if state.Buff.doom then
        defenseSet = set_combine(defenseSet, sets.buff.doom)
    end
    return defenseSet
end

-- Modify the default melee set after it was constructed.
function customize_melee_set(meleeSet)
    if buffactive['elvorseal'] and state.DefenseMode.value == 'None' then
        if player.inventory["Heidrek Gloves"] then meleeSet = set_combine(meleeSet, {hands="Heidrek Gloves"}) end
    end
    if has_any_buff_of(S{'petrification','sleep','stun','terror'}) then
        if state.RangedMode.value == 'Tathlum' then
            meleeSet = set_combine(sets.engaged.PDef, sets.weapons.DTTathlum)
        else
            meleeSet = set_combine(sets.engaged.PDef, {})
        end
    end
    if state.Buff.doom then
        meleeSet = set_combine(meleeSet, sets.buff.doom)
    end
    if state.RangedMode.value == 'Tathlum' then
        meleeSet = set_combine(meleeSet, sets.weapons.TPTathlum)
    elseif state.DefenseMode.value ~= 'None' then
        if state.RangedMode.value == 'Shuriken' then
            meleeSet = set_combine(meleeSet, sets.weapons.Daken)
        end
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

-- Set eventArgs.handled to true if we don't want the automatic display to be run.
function display_current_job_state(eventArgs)
    local msg = ''

    msg = msg .. 'TP[' .. state.OffenseMode.current
    if state.HybridMode.value ~= 'Normal' then
        msg = msg .. '/' .. state.HybridMode.value
    end
    msg = msg .. ':' .. state.CombatWeapon.value
    if state.CombatForm.has_value then
        msg = msg .. '/' .. state.CombatForm.value
    end
    msg = msg .. ']'
    if state.WeaponskillMode.value ~= 'Normal' or state.SelectNPCTargets.value then
        msg = msg .. ' WS[' .. state.WeaponskillMode.current .. ']'
        if state.SelectNPCTargets.value then
            msg = msg .. '<stnpc>'
        end
    end
    msg = msg .. ' RA[' .. state.RangedMode.value .. ']'
    msg = msg .. ' Utsu[' .. state.CastingMode.value .. ']'
    msg = msg .. ' Idle[' .. state.IdleMode.current .. ']'

    if state.DefenseMode.value ~= 'None' then
        local defMode = state[state.DefenseMode.value ..'DefenseMode'].current
        msg = msg .. ' Def[' .. state.DefenseMode.value .. ':' .. defMode .. ']'
    end
    if not state.MagicBurst.value then
        msg = msg .. ' NonMB'
    end
    if state.WSMsg.value then
        msg = msg .. ' WSMsg'
    end
    if state.AutoHybrid.value ~= 'off' then
        msg = msg .. ' AH:' .. state.AutoHybrid.value
    end
    if state.SIRDUtsu.value then
        msg = msg .. ' SIRD'
    end
    if state.TreasureMode and state.TreasureMode.value ~= 'None' then
        msg = msg .. ' TH+4'
    end
    if state.Fishing.value then
        msg = msg .. ' Fishing'
    end
    if state.Cooking.value then
        msg = msg .. ' Cooking'
    end
    if state.HELM.value then
        msg = msg .. ' HELM'
    end
    if state.Kiting.value then
        msg = msg .. ' Kiting'
    end

    add_to_chat(122, msg)
    report_ninja_tools()
    report_ja_recasts(info.recast_ids, true, 5)
    eventArgs.handled = true
end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements self-commands.
-------------------------------------------------------------------------------------------------------------------

-- Called for custom player commands.
function job_self_command(cmdParams, eventArgs)
    eventArgs.handled = true
    if     cmdParams[1] == 'CountTools' then
        report_ninja_tools(true)
    elseif cmdParams[1] == 'ListWS' then
        info.ws_binds:print('ListWS:')
    elseif cmdParams[1] == 'altweap' then
        local weap = state.CombatWeapon.value
        if weap:endswith('TP')    then handle_set({'CombatWeapon', weap:sub(1,-3)})
        elseif state.CombatWeapon:contains(weap..'TP') then handle_set({'CombatWeapon', weap..'TP'})
        elseif weap == 'HeiTern'  then handle_set({'CombatWeapon', 'HeiChi'})
        elseif weap == 'HeiChi'   then handle_set({'CombatWeapon', 'HeiTern'})
        elseif weap == 'SCDagger' then handle_set({'CombatWeapon', 'AEDagger'})
        elseif weap == 'AEDagger' then handle_set({'CombatWeapon', 'SCDagger'})
        elseif weap == 'GKatana'  then handle_set({'CombatWeapon', 'GKGekko'})
        elseif weap == 'GKGekko'  then handle_set({'CombatWeapon', 'GKatana'})
        else add_to_chat(123, 'unable to toggle TP bonus offhand.') end
    elseif cmdParams[1] == 'save' then
        save_self_command(cmdParams)
    elseif cmdParams[1] == 'rebind' then
        info.keybinds:bind()
    else
        eventArgs.handled = false
    end
end

-- the Mote SelectNPCTargets does not work for me, but inverting it does
-- this does so for weaponskills, but requires them to be written as <stnpc>
function job_auto_change_target(spell, action, spellMap, eventArgs)
    eventArgs.handled = true
    if spell.type == 'WeaponSkill' and spell.target.raw == '<stnpc>' then
        if not state.SelectNPCTargets.value then
            change_target('<t>')
        else
            add_to_chat(121, spell.english..' <stnpc>')
        end
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    set_macro_page(1,13)
    send_command('bind !^l input /lockstyleset 13')
end

-- returns a list for use with make_keybind_list
function job_keybinds()
    local bind_command_list = L{
        'bind %`|F12 gs c update user',
        'bind F9   gs c cycle OffenseMode',
        'bind @F9  gs c cycle WeaponskillMode',
        'bind !F9  gs c cycle RangedMode',
        'bind F10  gs c cycle CastingMode',
        'bind !F10 gs c reset CastingMode',
        'bind F11  gs c cycle IdleMode',
        'bind !F11 gs c reset IdleMode',
        'bind @F11 gs c toggle Kiting',
        'bind !F12 gs c cycle TreasureMode',
        'bind ^space  gs c cycle HybridMode',
        'bind !space  gs c set DefenseMode Physical',
        'bind @space  gs c set DefenseMode Magical',
        'bind !@space gs c reset DefenseMode',
        'bind ^@space gs c set AutoHybrid Utsu',
        'bind !^space gs c set AutoHybrid Miga',
        'bind @backspace gs c CountTools',
        'bind ^\\\\ gs c toggle WSMsg',
        'bind ^z  gs c toggle MagicBurst',
        'bind !z  gs c cycle PhysicalDefenseMode',
        'bind @z  gs c cycle MagicalDefenseMode',
        'bind !w  gs c reset OffenseMode',
        'bind !@w gs c set   OffenseMode None',
        'bind ~^q gs c altweap',
        'bind !^q  gs c set CombatWeapon Kannagi',
        'bind ~!^q gs c set CombatWeapon Nagi',
        'bind ^@q  gs c set CombatWeapon AEDagger',
        'bind ~^@q gs c set CombatWeapon Gokotai',
        'bind !^w  gs c set CombatWeapon Heishi',
        'bind ~!^w gs c set CombatWeapon HeiTern',
        'bind ^@w  gs c set CombatWeapon GKatana',
        'bind !^e  gs c set CombatWeapon FudoB',
        'bind ~!^e gs c set CombatWeapon FudoC',
        'bind !^r  gs c set CombatWeapon NaegTP',
        'bind ~!^r gs c set CombatWeapon Kikoku',
        'bind !-         gs c set RangedMode Tathlum',
        'bind !=         gs c set RangedMode Shuriken',
        'bind !backspace gs c set RangedMode Blink',
        'bind !c  gs c set OffenseMode Acc',
        'bind @c  gs c set OffenseMode MEVA',
        'bind !@c gs c toggle SIRDUtsu',
        'bind ^q  gs c toggle SelectNPCTargets',

        'bind !^` input /ja "Mijin Gakure" <t>',
        'bind ^@` input /ja Mikage',
        'bind @` input /ja Futae',
        'bind ^@tab input /ja Issekigan',  -- 1/0 and 300/200+ per parry

        'bind !1 input /ja Yonin',
        'bind !2 input /ja Innin',
        'bind !3 input /ja Sange',

        'bind !7 gs c set CombatForm DW00',
        'bind !8 gs c set CombatForm DW15',
        'bind !9 gs c set CombatForm DW30',
        'bind !0 gs c reset CombatForm',

        'bind ^@1 input /ma "Katon: San"',
        'bind ^@2 input /ma "Hyoton: San"',
        'bind ^@3 input /ma "Huton: San"',
        'bind ^@4 input /ma "Doton: San"',
        'bind ^@5 input /ma "Raiton: San"',
        'bind ^@6 input /ma "Suiton: San"',

        'bind ~^@1 input /ma "Katon: Ni"',
        'bind ~^@2 input /ma "Hyoton: Ni"',
        'bind ~^@3 input /ma "Huton: Ni"',
        'bind ~^@4 input /ma "Doton: Ni"',
        'bind ~^@5 input /ma "Raiton: Ni"',
        'bind ~^@6 input /ma "Suiton: Ni"',

        'bind !@1 input /ma "Kurayami: Ni"',           -- acc-30
        'bind !@2 input /ma "Hojo: Ni"',               -- 20% slow
        'bind !@3 input /ma "Jubaku: Ichi"',           -- 20% para
        'bind !@4 input /ma "Aisha: Ichi"',            -- 15% att down
        'bind !@5 input /ma "Yurin: Ichi"',            -- 10% inhibit tp
        'bind !@6 input /ma "Dokumori: Ichi"',         -- 3/tick poison

        'bind @1 input /ma "Kurayami: Ni" <stnpc>',
        'bind @2 input /ma "Hojo: Ni" <stnpc>',
        'bind @3 input /ma "Jubaku: Ichi" <stnpc>',
        'bind @4 input /ma "Aisha: Ichi" <stnpc>',
        'bind @5 input /ma "Yurin: Ichi" <stnpc>',
        'bind @6 input /ma "Dokumori: Ichi" <stnpc>',

        'bind !e input /ma "Utsusemi: Ni"',            -- 0/160 (160/480 yonin)
        'bind @e input /ma "Utsusemi: San"',           -- ditto
        'bind !@e input /ma "Utsusemi: Ichi"',         -- ditto
        'bind !g input /ma "Migawari: Ichi"',
        'bind !@g gs equip phlx',                      -- phalanx+15
        'bind @f input /ma "Gekka: Ichi"',             -- enm+30
        'bind !@f input /ma "Yain: Ichi"',             -- enm-15
        'bind !f input /ma "Kakka: Ichi"',             -- stp+10
        'bind !b input /ma "Myoshu: Ichi"',            -- sb+10
        'bind !v input /ma "Tonko: Ni"',
        'bind @v input /ma "Monomi: Ichi"'}

    if     player.sub_job == 'WAR' then
        bind_command_list:extend(L{
            'bind !4 input /ja Berserk <me>',
            'bind !5 input /ja Aggressor <me>',
            'bind !6 input /ja Warcry <me>',           -- 1/300 per target
            'bind !d input /ja Provoke',               -- 0/1800
            'bind @d input /ja Provoke <stnpc>',
            'bind !@d input /ja Defender <me>'})
    elseif player.sub_job == 'DRG' then
        bind_command_list:extend(L{
            'bind !4 input /ja "High Jump"',
            'bind !6 input /ja "Ancient Circle" <me>'})
    elseif player.sub_job == 'DRK' then
        bind_command_list:extend(L{
            'bind !4 input /ja "Last Resort" <me>',    -- 1/1300
            'bind !5 input /ja Souleater <me>',        -- 1/1300, +25acc, +?/+? per hit
            'bind !6 input /ja "Arcane Circle" <me>',
            'bind !d input /ma Stun',                  -- 180/1280
            'bind @d input /ma Stun <stnpc>',
            'bind !@d input /ma Poisonga'})
    elseif player.sub_job == 'RUN' then
        bind_command_list:extend(L{
            'bind @1 input /ja Ignis <me>',            -- fire up,    ice down
            'bind @2 input /ja Gelus <me>',            -- ice up,     wind down
            'bind @3 input /ja Flabra <me>',           -- wind up,    earth down
            'bind @4 input /ja Tellus <me>',           -- earth up,   thunder down
            'bind @5 input /ja Sulpor <me>',           -- thunder up, water down
            'bind @6 input /ja Unda <me>',             -- water up,   fire down
            'bind @7 input /ja Lux <me>',              -- light up,   dark down
            'bind @8 input /ja Tenebrae <me>',         -- dark up,    light down
            'bind !4 input /ja Swordplay <me>',        -- 160/320, +3 acc/eva per tick
            'bind !5 input /ja Pflug <me>',            -- 450/900, +10 resist per rune
            'bind ^tab input /ja Vallation <me>',      -- 450/900, -15% damage per rune
            'bind !d input /ma Flash',                 -- 180/1280
            'bind @d input /ma Flash <stnpc>',
            'bind !^v input /ma Aquaveil <me>',
            'bind !6 input /ma Protect <stpc>'})
    elseif player.sub_job == 'PLD' then
        bind_command_list:extend(L{
            'bind !6 input /ja "Holy Circle" <me>',
            'bind ^tab input /ja Sentinel <me>',       -- 0/900, enm+50 for 30s
            'bind !d input /ma Flash',                 -- 180/1280
            'bind @d input /ma Flash <stnpc>',
            'bind !@d input /ma Banishga'})
    elseif player.sub_job == 'BLU' then
        bind_command_list:extend(L{
            'bind @1 input /ma "Sheep Song"',          -- (320/320), 6'
            'bind @2 input /ma "Geist Wall"',          -- (320/320), 6'
            'bind @3 input /ma "Stinking Gas"',        -- (320/320), 6'
            'bind !4 input /ma Cocoon <me>',
            'bind !5 input /ma Refueling <me>',
            -- wild carrot aliased to //wc
            'bind !6 input /ma "Healing Breeze" <me>',
            'bind !d input /ma "Blank Gaze"',          -- (320/320), 12'
            'bind !@d input /ma Jettatura'})            -- (180/1020), 9'
    elseif player.sub_job == 'DNC' then
        bind_command_list:extend(L{
            'bind !` input /ja "Curing Waltz III" <stpc>',
            'bind @F1 input /ja "Healing Waltz" <stpc>',
            'bind !4 input /ja "Box Step" <t>',
            'bind !5 input /ja "Haste Samba" <me>',
            'bind !6 input /ja "Divine Waltz" <me>',
            'bind !@f input /ja "Reverse Flourish" <me>',
            'bind !d input /ja "Animated Flourish"',
            'bind @d input /ja "Animated Flourish" <stnpc>',
            'bind !@d input /ja "Violent Flourish" <stnpc>'})
    elseif player.sub_job == 'SAM' then
        bind_command_list:extend(L{
            'bind !4 input /ja Meditate <me>',
            'bind !5 input /ja Sekkanoki <me>',
            'bind !6 input /ja "Warding Circle" <me>',
            'bind !d input /ja "Third Eye" <me>'})
    elseif player.sub_job == 'WHM' then
        bind_command_list:extend(L{
            'bind !5 input /ma Haste <me>',
            'bind !6 input /ma Cura <me>',
            'bind !d input /ma Flash',
            'bind @d input /ma Flash <stnpc>',
            'bind !@d input /ma Banishga',
            'bind !^g input /ma Stoneskin <me>',
            'bind !^v input /ma Aquaveil <me>'})
    elseif player.sub_job == 'RDM' then
        bind_command_list:extend(L{
            'bind !4 input /ma Phalanx <me>',
            'bind !5 input /ma Haste <me>',
            'bind !6 input /ma Refresh <me>',
            'bind ^tab input /ma Dispel',
            'bind !@d input /ma Diaga',
            'bind !^g input /ma Stoneskin <me>',
            'bind !^v input /ma Aquaveil <me>'})
    elseif player.sub_job == 'BLM' then
        bind_command_list:extend(L{
            'bind !4 input /ma "Sleep II" <stnpc>',
            'bind !5 input /ma Sleep <stnpc>',
            'bind !6 input /ma Sleepga',
            'bind !d input /ma Stun',
            'bind @d input /ma Stun <stnpc>',
            'bind !@d input /ma Poisonga'})
    elseif player.sub_job == 'SMN' then
        bind_command_list:extend(L{
            'bind !4 input /ma Diabolos <me>',
            'bind !5 input /pet Somnolence <t>',
            'bind !6 input /pet Release <me>',
            'bind !d input /pet Assault <t>',
            'bind @d input /pet Retreat <me>'})
    end

    return bind_command_list
end

-- prints a message with counts of ninja tools
function report_ninja_tools(always_report)
    local bag_ids = T{['Inventory']=0,['Wardrobe']=8,['Wardrobe 2']=10,['Wardrobe 3']=11,['Wardrobe 4']=12}
    local item_list = L{{name='shihei',id=1179},{name='shika',id=2972},{name='chono',id=2973},{name='ino',id=2971},
                        {name='shuriken',id=22292}}
    local counts = T{}
    for item in item_list:it() do counts[item.id] = 0 end

    for bag in S{'Inventory','Wardrobe'}:it() do
        for _,item in ipairs(windower.ffxi.get_items(bag_ids[bag])) do
            if type(item) == 'table' then
                if counts:containskey(item.id) then
                    counts[item.id] = counts[item.id] + item.count
                end
            end
        end
    end

    local low = false
    local msg = item_list:map(function(item)
        if counts[item.id] <= 20 then
            low = true
            if state.Buff.Sange and item.name == 'shuriken' then
                send_command('cancel sange')
                add_to_chat(123, 'cancelling sange')
            end
        end
        return "%s(%d)":format(item.name,counts[item.id])
    end):concat(' ')
    if always_report or low then add_to_chat((low and 123 or 122), msg) end
end

-- returns true if player has 2+ shadows
function player_has_shadows()
    return buffactive['Copy Image (2)'] or buffactive['Copy Image (3)'] or buffactive['Copy Image (4+)']
end

function init_state_text()
    if hud then return end

    local mb_text_settings    = {flags={draggable=false,bold=true},bg={red=250,green=200,blue=0,alpha=150},text={stroke={width=2}}}
    local sird_text_settings  = {flags={draggable=false},bg={blue=150,green=150,alpha=150},text={stroke={width=2}}}
    local stnpc_text_settings = {pos={y=18},flags={draggable=false},bg={red=200,alpha=150},text={stroke={width=2}}}
    local hyb_text_settings   = {pos={x=130,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local def_text_settings   = {pos={x=172,y=716},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local off_text_settings   = {pos={x=172,y=697},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}
    local dw_text_settings    = {pos={x=130,y=697},flags={draggable=false},bg={alpha=150},text={font='Courier New',size=10}}

    hud = {texts=T{}}
    hud.texts.mb_text    = texts.new('NonMB',          mb_text_settings)
    hud.texts.sird_text  = texts.new('SIRD',           sird_text_settings)
    hud.texts.stnpc_text = texts.new('<stnpc>',        stnpc_text_settings)
    hud.texts.hyb_text   = texts.new('initializing..', hyb_text_settings)
    hud.texts.def_text   = texts.new('initializing..', def_text_settings)
    hud.texts.off_text   = texts.new('initializing..', off_text_settings)
    hud.texts.dw_text    = texts.new('initializing..', dw_text_settings)

    -- update infrequently changing text boxes in job_state_change or where they are changed
    function hud_update_on_state_change(stateField)
        if not hud then init_state_text() end

        if not stateField or stateField == 'Magic Burst' then
            hud.texts.mb_text:visible((not state.MagicBurst.value))
        end

        if not stateField or stateField == 'SIRD Casting' then
            hud.texts.sird_text:visible(state.SIRDUtsu.value)
        end

        if not stateField or stateField == 'Select NPC Targets' then
            hud.texts.stnpc_text:visible(state.SelectNPCTargets.value)
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

        if not stateField or stateField == 'Offense Mode' then
            if state.OffenseMode.value ~= 'Normal' then
                hud.texts.off_text:text(state.OffenseMode.value)
                hud.texts.off_text:show()
            else hud.texts.off_text:hide() end
        end

        if not stateField or stateField == 'Combat Form' then
            if state.CombatForm.has_value then
                hud.texts.dw_text:text(state.CombatForm.value)
                hud.texts.dw_text:show()
            else hud.texts.dw_text:hide() end
        end
    end
end
