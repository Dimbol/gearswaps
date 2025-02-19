-- Modified from 'https://github.com/Kinematics/GearSwap-Jobs/'

-- nin dual wield cheatsheet
-- haste:   0   15  30  cap
--   +dw:  39   32  21   1

-- NOTES
-- innin boosts ninjutsu damage
-- retsu has a 30% paralysis
-- subtle blow is easy to cap
--   trait 27, merits 5, myoshu 10, auspice 25
--   ternion 9, adh.bonnet 8, herc.boots 6, kenda 8/12/8/10/8
--   fudo B 25(II), mpaca hose 5(II), gleti knife 10(II)
-- when zerging, use chi with bolster malaise and savage otherwise
-- the EvaPDT defense mode overrides enmity swaps for JAs and utsu

-- SKILLCHAINS
-- to teki shun shun
-- shun ten kamu shun shun
-- chi teki chi teki chi teki
-- chi teki chi to
-- teki to chi to yu to
-- teki to chi to ei/kamu kamu
-- ku retsu ten hi
-- frag: to teki
-- dist: ku/rin retsu
-- grav: jin ei
-- impa: yu chi
-- 7stp: ei rin ei rin ...
--    or wasp gust wasp gust ...
-- crab: to chi to
-- imp: teki to chi to teki to chi

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
    state.Buff.sleep = buffactive.sleep or false

    state.Buff.Sange = buffactive['sange'] or false
    state.Buff.Futae = buffactive['futae'] or false
    state.Buff.Yonin = buffactive['yonin'] or false
    state.Buff.Innin = buffactive['innin'] or false
    state.Buff.Migawari = buffactive['migawari'] or false

    --include('Mote-TreasureHunter')

    logout_event_id = windower.raw_register_event('logout', destroy_state_text)
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
    state.OffenseMode:options('Normal','MEVA','Acc','Crit','EXP','None') -- Cycle with F9, set with ^c, @c, !c, !w, @w
    state.HybridMode:options('Normal','PDef')                            -- Cycle with ^F9
    state.RangedMode:options('Shuriken','Tathlum','Blink')               -- Cycle with !F9, set with !-, !=, !backspace
    state.WeaponskillMode:options('Normal','Acc','NoDmg')                -- Cycle with @F9
    state.CastingMode:options('Enmity','Normal')                         -- Cycle with F10, @z
    state.IdleMode:options('Normal','Rf')                                -- Cycle with F11, reset with !F11
    state.PhysicalDefenseMode:options('PDT','EvaPDT')                    -- Cycle with !z
    state.MagicalDefenseMode:options('MDT')
    state.CombatWeapon = M{['description']='Combat Weapon'}              -- Set with !^q through !^r and others
    state.CombatWeapon:options('Heishi','HeiTsu','HeiFudo','HeiSB','HeishiTP','Gokotai','GokoBow','FudoCBow',
                               'Nagi','NagiTP','Kannagi','Kikoku','FudoB','FudoBTP','FudoC','FudoCTP',
                               'AEDagger','SCDagger','GKatana','GKGekko','Club','H2H','Naeg','NaegTP')

    state.MagicBurst = M(true,  'Magic Burst')                  -- Toggle with ^z
    state.WSMsg      = M(false, 'WS Message')                   -- Toggle with ^\
    state.SCB        = M(false, 'WS SCB')                       -- Toggle with %c
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
                       'Tachi: Goten','Tachi: Kagero','Tachi: Jinpu','Tachi: Koki',
                       'Hot Shot','Flaming Arrow'}
    info.obi_ws    = S{}:union(info.magic_ws):union(info.hybrid_ws)

    -- Ammo used with /ra sets
    gear.arrow_tp = {name="Chapuli Arrow"}
    gear.arrow_ws = {name="Beryllium Arrow"}

    -- Augmented items get variables for convenience and specificity
    gear.fudoB = {name="Fudo Masamune", augments={'Path: B'}}
    gear.fudoC = {name="Fudo Masamune", augments={'Path: C'}}
    gear.taeon_head_phlx  = {name="Taeon Chapeau", augments={'Phalanx +3'}}
	gear.taeon_head_snap  = {name="Taeon Chapeau", augments={'"Snapshot"+5'}}
	gear.taeon_body_snap  = {name="Taeon Tabard", augments={'"Snapshot"+5'}}
	gear.taeon_hands_snap = {name="Taeon Gloves", augments={'"Snapshot"+5'}}
	gear.taeon_feet_snap  = {name="Taeon Boots", augments={'"Snapshot"+5'}}
    gear.adh_body_ta = {name="Adhemar Jacket +1", augments={'Accuracy+20'}, priority=63}
    gear.adh_body_fc = {name="Adhemar Jacket +1", augments={'"Fast Cast"+10'}, priority=168}
    gear.herc_feet_ta   = {name="Herculean Boots", augments={'"Triple Atk."+4'}}
    gear.herc_hands_rf  = {name="Herculean Gloves", augments={'"Refresh"+2'}}
    gear.herc_legs_rf   = {name="Herculean Trousers", augments={'"Refresh"+2'}}
    gear.herc_legs_th   = {name="Herculean Trousers", augments={'"Treasure Hunter"+2'}}
    gear.herc_head_fc   = {name="Herculean Helm", augments={'"Fast Cast"+6'}}
    gear.herc_legs_fc   = {name="Herculean Trousers", augments={'"Fast Cast"+7'}}
    gear.herc_feet_fc   = {name="Herculean Boots", augments={'"Fast Cast"+6'}}
    gear.herc_body_phlx  = {name="Herculean Vest", augments={'Phalanx +5'}}
    gear.herc_hands_phlx = {name="Herculean Gloves", augments={'Phalanx +5'}}
    gear.herc_legs_phlx  = {name="Herculean Trousers", augments={'Phalanx +4'}}
    gear.herc_feet_phlx  = {name="Herculean Boots", augments={'Phalanx +5'}}
    gear.Lstikini = {name="Stikini Ring +1", bag="wardrobe2"}
    gear.Rstikini = {name="Stikini Ring +1", bag="wardrobe3"}

    gear.TPCape    = {name="Andartia's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','"Store TP"+10'}}
    gear.DWCape    = {name="Andartia's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','"Dual Wield"+10'}}
    gear.ShunCape  = {name="Andartia's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','"Dbl.Atk."+10'}}
    gear.TenCape   = {name="Andartia's Mantle", augments={'STR+20','Accuracy+20 Attack+20','Weapon skill damage +10%'}}
    gear.MetsuCape = {name="Andartia's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','Weapon skill damage +10%'}}
    gear.HiCape    = {name="Andartia's Mantle", augments={'AGI+20','Accuracy+20 Attack+20','Weapon skill damage +10%'}}
    gear.CritCape  = {name="Andartia's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','Crit.hit rate+10'}}
    gear.EnmCape   = {name="Andartia's Mantle", augments={'HP+60','Enmity+10','Phys. dmg. taken-10%'}, priority=60}
    gear.ParryCape = {name="Andartia's Mantle", augments={'HP+60','Enmity+10','Parrying rate+5%'}, priority=60}
    gear.NukeCape  = {name="Andartia's Mantle", augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','"Mag.Atk.Bns."+10'}}
    gear.FCCape    = {name="Andartia's Mantle", augments={'HP+60','HP+20','"Fast Cast"+10'}, priority=80}
    gear.SnapCape  = {name="Andartia's Mantle", augments={'"Snapshot"+10'}}

    -- High HP items get tagged with priorities
    gear.hp = {}
    gear.hp["Aqreqaq Bomblet"] = 20
    gear.hp["Ashera Harness"] = 182
    gear.hp["Bathy Choker +1"] = 35
    gear.hp["Cryptic Earring"] = 40
    gear.hp["Eabani Earring"] = 45
    gear.hp["Eihwaz Ring"] = 70
    gear.hp["Etana Ring"] = 60
    gear.hp["Ethereal Earring"] = 15
    gear.hp["Etiolation Earring"] = 50
    gear.hp["Gavialis Helm"] = 115
    gear.hp["Gelatinous Ring +1"] = 120
    gear.hp["Genmei Kabuto"] = 191
    gear.hp["Hachiya Hatsuburi +3"] = 64
    gear.hp["Hachiya Kyahan +3"] = 29
    gear.hp["Hizamaru Haramaki +2"] = 100
    gear.hp["Hizamaru Sune-Ate +2"] = 30
    gear.hp["Ilabrat Ring"] = 60
    gear.hp["Kasiri Belt"] = 30
    gear.hp["Kendatsuba Hakama +1"] = 115
    gear.hp["Kendatsuba Jinpachi +1"] = 88
    gear.hp["Kendatsuba Samue +1"] = 122
    gear.hp["Kendatsuba Sune-Ate +1"] = 70
    gear.hp["Kendatsuba Tekko +1"] = 61
    gear.hp["Malignance Boots"] = 34
    gear.hp["Malignance Gloves"] = 57
    gear.hp["Metamorph Ring +1"] = -60
    gear.hp["Mochizuki Hakama +3"] = 82
    gear.hp["Mochizuki Hatsuburi +3"] = 106
    gear.hp["Mochizuki Kyahan +3"] = 33
    gear.hp["Mochizuki Tekko +3"] = 45
    gear.hp["Moonbeam Cape"] = 250
    gear.hp["Mpaca's Doublet"] = 84
    gear.hp["Mpaca's Hose"] = 72
    gear.hp["Mummu Gamashes +2"] = 30
    gear.hp["Null Masque"] = 100
    gear.hp["Null Loop"] = 50
    gear.hp["Nyame Flanchard"] = 114
    gear.hp["Nyame Gauntlets"] = 91
    gear.hp["Nyame Helm"] = 91
    gear.hp["Nyame Mail"] = 136
    gear.hp["Nyame Sollerets"] = 68
    gear.hp["Odnowa Earring +1"] = 110
    gear.hp["Pixie Hairpin +1"] = -35
    gear.hp["Platinum Moogle Belt"] = 240
    gear.hp["Rawhide Gloves"] = 75
    gear.hp["Regal Ring"] = 50
    gear.hp["Repulse Mantle"] = 30
    gear.hp["Supershear Ring"] = 30
    gear.hp["Unmoving Collar +1"] = 200
    gear.hp["Volte Cap"] = 57
    for k, v in pairs(gear.hp) do
        gear.hp[k] = {name = k, priority = v}
    end

    gear.slots = S{'main','sub','range','ammo','head','neck','ear1','ear2','body','hands','ring1','ring2','back','waist','legs','feet'}

    function prioritize(set)
        for k, v in pairs(set) do
            if gear.slots[k] and gear.hp[v] then
                set[k] = gear.hp[v]
            end
        end
        return set
    end

    info.keybinds = make_keybind_list(job_keybinds())
    info.keybinds:bind()

    info.ws_binds = make_keybind_list(T{
        ['Katana']=L{
            'bind ^1|%1 input /ws "Blade: Hi"',
            'bind ^2|%2 input /ws "Blade: Shun"',
            'bind ^3|%3 input /ws "Blade: Ten"',
            'bind ^4|%4 input /ws "Blade: Kamu"',
            'bind ^5|%5 input /ws "Blade: Jin"',
            'bind ^6|%6 input /ws "Blade: Ku"',
            'bind !^1   input /ws "Blade: Ei"',
            'bind !^2   input /ws "Blade: Chi"',
            'bind !^3   input /ws "Blade: To"',
            'bind !^4   input /ws "Blade: Teki"',
            'bind !^5   input /ws "Blade: Yu"',
            'bind ~^1|%~1 input /ws "Blade: Hi" <stnpc>',
            'bind ~^2|%~2 input /ws "Blade: Shun" <stnpc>',
            'bind ~^3|%~3 input /ws "Blade: Ten" <stnpc>',
            'bind ~^4|%~4 input /ws "Blade: Kamu" <stnpc>',
            'bind ~^5|%~5 input /ws "Blade: Jin" <stnpc>',
            'bind ~^6|%~6 input /ws "Blade: Ku" <stnpc>',
            'bind ~!^1    input /ws "Blade: Ei" <stnpc>',
            'bind ~!^2    input /ws "Blade: Chi" <stnpc>',
            'bind ~!^3    input /ws "Blade: To" <stnpc>',
            'bind ~!^4    input /ws "Blade: Teki" <stnpc>',
            'bind ~!^5    input /ws "Blade: Yu" <stnpc>'},
        ['RKatana']=L{
            'bind ^1|%1 input /ws "Blade: Hi"',
            'bind ^2|%2 input /ws "Blade: Shun"',
            'bind ^3|%3 input /ws "Blade: Ten"',
            'bind ^4|%4 input /ws "Blade: Metsu"',
            'bind ^5|%5 input /ws "Blade: Jin"',
            'bind ^6|%6 input /ws "Blade: Ku"',
            'bind !^1   input /ws "Blade: Ei"',
            'bind !^2   input /ws "Blade: Chi"',
            'bind !^3   input /ws "Blade: To"',
            'bind !^4   input /ws "Blade: Teki"',
            'bind !^5   input /ws "Blade: Yu"',
            'bind ~^1|%~1 input /ws "Blade: Hi" <stnpc>',
            'bind ~^2|%~2 input /ws "Blade: Shun" <stnpc>',
            'bind ~^3|%~3 input /ws "Blade: Ten" <stnpc>',
            'bind ~^4|%~4 input /ws "Blade: Metsu" <stnpc>',
            'bind ~^5|%~5 input /ws "Blade: Jin" <stnpc>',
            'bind ~^6|%~6 input /ws "Blade: Ku" <stnpc>',
            'bind ~!^1    input /ws "Blade: Ei" <stnpc>',
            'bind ~!^2    input /ws "Blade: Chi" <stnpc>',
            'bind ~!^3    input /ws "Blade: To" <stnpc>',
            'bind ~!^4    input /ws "Blade: Teki" <stnpc>',
            'bind ~!^5    input /ws "Blade: Yu" <stnpc>'},
        ['BowKatana']=L{
            'bind ^1|%1 input /ws "Blade: Hi"',
            'bind ^2|%2 input /ws "Empyreal Arrow"',
            'bind ^3|%3 input /ws "Blade: Ten"',
            'bind ^4|%4 input /ws "Blade: Kamu"',
            'bind ^5|%5 input /ws "Flaming Arrow"',
            'bind ^6|%6 input /ws "Blade: Ku"',
            'bind !^1   input /ws "Blade: Ei"',
            'bind !^2   input /ws "Blade: Chi"',
            'bind !^3   input /ws "Blade: To"',
            'bind !^4   input /ws "Blade: Teki"',
            'bind !^5   input /ws "Blade: Yu"',
            'bind ~^1|%~1 input /ws "Blade: Hi" <stnpc>',
            'bind ~^2|%~2 input /ws "Blade: Shun" <stnpc>',
            'bind ~^3|%~3 input /ws "Blade: Ten" <stnpc>',
            'bind ~^4|%~4 input /ws "Blade: Kamu" <stnpc>',
            'bind ~^5|%~5 input /ws "Blade: Jin" <stnpc>',
            'bind ~^6|%~6 input /ws "Blade: Ku" <stnpc>',
            'bind ~!^1    input /ws "Blade: Ei" <stnpc>',
            'bind ~!^2    input /ws "Blade: Chi" <stnpc>',
            'bind ~!^3    input /ws "Blade: To" <stnpc>',
            'bind ~!^4    input /ws "Blade: Teki" <stnpc>',
            'bind ~!^5    input /ws "Blade: Yu" <stnpc>'},
        ['Dagger']=L{
            'bind ^1|%1 input /ws "Evisceration"',
            'bind ^2|%2 input /ws "Wasp Sting"',
            'bind ^3|%3 input /ws "Gust Slash"',
            'bind ^4|%4 input /ws "Exenterator"',
            'bind ^6|%6 input /ws "Aeolian Edge"',
            'bind ^7|%7 input /ws "Cyclone"',
            'bind ~^1|%~1 input /ws "Evisceration" <stnpc>',
            'bind ~^2|%~2 input /ws "Wasp Sting" <stnpc>',
            'bind ~^3|%~3 input /ws "Gust Slash" <stnpc>',
            'bind ~^4|%~4 input /ws "Exenterator" <stnpc>',
            'bind ~^6|%~6 input /ws "Aeolian Edge" <stnpc>',
            'bind ~^7|%~7 input /ws "Cyclone" <stnpc>'},
        ['GKatana']=L{
            'bind ^1|%1 input /ws "Tachi: Ageha"',
            'bind ^2|%2 input /ws "Tachi: Kasha"',
            'bind ^3|%3 input /ws "Tachi: Jinpu"',
            'bind ^4|%4 input /ws "Tachi: Kagero"',
            'bind ^5|%5 input /ws "Tachi: Koki"',
            'bind ~^1|%~1 input /ws "Tachi: Ageha" <stnpc>',
            'bind ~^2|%~2 input /ws "Tachi: Kasha" <stnpc>',
            'bind ~^3|%~3 input /ws "Tachi: Jinpu" <stnpc>',
            'bind ~^4|%~4 input /ws "Tachi: Kagero" <stnpc>',
            'bind ~^5|%~5 input /ws "Tachi: Koki" <stnpc>',
            'bind !^d   input /ws "Tachi: Hobaku"'},
        ['Sword']=L{
            'bind ^1|%1 input /ws "Sanguine Blade"',
            'bind ^2|%2 input /ws "Vorpal Blade"',
            'bind ^3|%3 input /ws "Savage Blade"',
            'bind ^4|%4 input /ws "Red Lotus Blade"',
            'bind ^5|%5 input /ws "Seraph Blade"',
            'bind ^6|%6 input /ws "Circle Blade"',
            'bind ~^1|%~1 input /ws "Sanguine Blade" <stnpc>',
            'bind ~^2|%~2 input /ws "Vorpal Blade" <stnpc>',
            'bind ~^3|%~3 input /ws "Savage Blade" <stnpc>',
            'bind ~^4|%~4 input /ws "Red Lotus Blade" <stnpc>',
            'bind ~^5|%~5 input /ws "Seraph Blade" <stnpc>',
            'bind ~^6|%~6 input /ws "Circle Blade" <stnpc>',
            'bind !^d   input /ws "Flat Blade"'},
        ['Club']=L{
            'bind ^1|%1 input /ws "Flash Nova"',
            'bind ^2|%2 input /ws "Judgment"',
            'bind ^3|%3 input /ws "True Strike"',
            'bind ~^1|%~1 input /ws "Flash Nova" <stnpc>',
            'bind ~^2|%~2 input /ws "Judgment" <stnpc>',
            'bind ~^3|%~3 input /ws "True Strike" <stnpc>',
            'bind !^d   input /ws "Brainshaker"'},
        ['H2H']=L{
            'bind ^1|%1 input /ws "Raging Fists"',
            'bind ^2|%2 input /ws "Asuran Fists"',
            'bind ^3|%3 input /ws "Tornado Kick"',
            'bind ^6|%6 input /ws "Spinning Attack"',
            'bind ~^1|%~1 input /ws "Raging Fists" <stnpc>',
            'bind ~^2|%~2 input /ws "Asuran Fists" <stnpc>',
            'bind ~^3|%~3 input /ws "Tornado Kick" <stnpc>',
            'bind ~^6|%~6 input /ws "Spinning Attack" <stnpc>',
            'bind !^d   input /ws "Shoulder Tackle"'}},
        {['Heishi']='Katana',['HeiTsu']='Katana',['HeiFudo']='Katana',['HeiSB']='Katana',['HeishiTP']='Katana',
         ['Nagi']='Katana',['NagiTP']='Katana',['Kannagi']='Katana',['Kikoku']='RKatana',
         ['FudoB']='Katana',['FudoBTP']='Katana',['FudoC']='Katana',['FudoCTP']='Katana',
         ['Gokotai']='Katana',['GokoBow']='BowKatana',
         ['FudoCBow']='BowKatana',['KannaBow']='BowKatana',['KaKuBow']='BowKatana',
         ['AEDagger']='Dagger',['SCDagger']='Dagger',['Naeg']='Sword',['NaegTP']='Sword',
         ['GKatana']='GKatana',['GKGekko']='GKatana',['Club']='Club',['H2H']='H2H'})
    info.ws_binds:bind(state.CombatWeapon)
    send_command('bind %\\\\ gs c ListWS')

    info.recast_ids = L{{name='Yonin',id=146},{name='Issekigan',id=57}}
    if     player.sub_job == 'WAR' then
        info.recast_ids:extend(L{{name='Provoke',id=5},{name='Warcry',id=2}})
    elseif player.sub_job == 'DRG' then
        info.recast_ids:extend(L{{name='High Jump',id=159},{name='Super Jump',id=160}})
    elseif player.sub_job == 'DRK' then
        info.recast_ids:extend(L{{name='Last Resort',id=87},{name='Souleater',id=85}})
    elseif player.sub_job == 'RUN' then
        info.recast_ids:extend(L{{name='Vallation',id=23},{name='Valiance',id=113},{name='Swordplay',id=24},{name='Pflug',id=59}})
    elseif player.sub_job == 'PLD' then
        info.recast_ids:extend(L{{name='Sentinel',id=75}})
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
    sets.weapons.Heishi   = {main="Heishi Shorinken",sub="Kunimitsu"}
    sets.weapons.HeishiTP = {main="Heishi Shorinken",sub="Hitaki"}
    sets.weapons.HeiSB    = {main="Heishi Shorinken",sub="Gleti's Knife"}
    sets.weapons.HeiTsu   = {main="Heishi Shorinken",sub="Tsuru"}
    sets.weapons.HeiFudo  = {main="Heishi Shorinken",sub=gear.fudoB}
    sets.weapons.Nagi     = {main="Nagi",sub="Tsuru"}
    sets.weapons.NagiTP   = {main="Nagi",sub="Hitaki"}
    sets.weapons.FudoB    = {main=gear.fudoB,sub="Gleti's Knife"}
    sets.weapons.FudoBTP  = {main=gear.fudoB,sub="Hitaki"}
    sets.weapons.FudoC    = {main=gear.fudoC,sub="Tsuru"}
    sets.weapons.FudoCTP  = {main=gear.fudoC,sub="Hitaki"}
    sets.weapons.Kannagi  = {main="Kannagi",sub="Gleti's Knife"}
    sets.weapons.Kikoku   = {main="Kikoku",sub="Kunimitsu"}
    sets.weapons.Gokotai  = {main="Gokotai",sub="Kunimitsu"}
    sets.weapons.GokoBow  = {main="Gokotai",sub="Hitaki",range="Ullr",ammo=gear.arrow_tp}
    sets.weapons.FudoCBow = {main=gear.fudoC,sub="Hitaki",range="Ullr",ammo=gear.arrow_tp}
    sets.weapons.KannaBow = {main="Kannagi",sub="Hitaki",range="Ullr",ammo=gear.arrow_tp}
    sets.weapons.KaKuBow  = {main="Kannagi",sub="Kunimitsu",range="Ullr",ammo=gear.arrow_tp}
    sets.weapons.AEDagger = {main="Tauret",sub="Kunimitsu"}
    sets.weapons.SCDagger = {main="Tauret",sub="Gleti's Knife"}
    sets.weapons.GKatana  = {main="Hachimonji",sub="Bloodrain Strap"}
    sets.weapons.GKGekko  = {main="Beryllium Tachi",sub="Bloodrain Strap"}
    sets.weapons.Naeg     = {main="Naegling",sub="Kunimitsu"}
    sets.weapons.NaegTP   = {main="Naegling",sub="Hitaki"}
    sets.weapons.Club     = {main="Mafic Cudgel",sub="Hitaki"}
    sets.weapons.H2H      = {main="Karambit",sub=empty}
    sets.weapons.Daken      = {ammo="Date Shuriken"}
    sets.weapons.TPTathlum  = {ammo="Yamarang"}
    sets.weapons.WSTathlum  = {ammo="Oshasha's Treatise"}
    sets.weapons.MATathlum  = {ammo="Pemphredo Tathlum"}
    sets.weapons.ENMTathlum = prioritize({ammo="Aqreqaq Bomblet"})
    sets.weapons.DTTathlum  = {ammo="Staunch Tathlum +1"}

    sets.TreasureHunter = prioritize({head="Volte Cap",waist="Chaac Belt",legs=gear.herc_legs_th})

    -- Precast Sets
    sets.Enmity = prioritize({main=gear.fudoC,sub="Tsuru",ammo="Date Shuriken",
        head="Genmei Kabuto",neck="Moonlight Necklace",ear1="Trux Earring",ear2="Cryptic Earring",
        body="Emet Harness +1",hands="Kurys Gloves",ring1="Eihwaz Ring",ring2="Supershear Ring",
        back=gear.EnmCape,waist="Kasiri Belt",legs="Zoar Subligar +1",feet="Ahosi Leggings"})
    -- FudoC: enm+97~167, pdt-35, dt-10, def~1167, eva~954, meva+435
    sets.Enmity.EvaPDT = prioritize({main=gear.fudoC,sub="Tsuru",ammo="Date Shuriken",
        head="Null Masque",neck="Bathy Choker +1",ear1="Eabani Earring",ear2="Infused Earring",
        body="Emet Harness +1",hands="Shigure Tekko +1",ring1="Gelatinous Ring +1",ring2="Defending Ring",
        back=gear.ParryCape,waist="Kasiri Belt",legs="Mpaca's Hose",feet="Nyame Sollerets"})
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
    sets.precast.JA['Weapon Bash'] = set_combine(sets.Enmity, sets.GKatana)
    sets.precast.JA['Mijin Gakure'] = {main="Nagi"}

    sets.gavialis = prioritize({head="Gavialis Helm"}) -- combined in job_post_precast
    sets.scb = prioritize({head="Nyame Helm",neck="Warder's Charm +1",
        body="Nyame Mail",hands="Nyame Gauntlets",legs="Nyame Flanchard",feet="Nyame Sollerets"})
    sets.precast.WS = prioritize({ammo="Oshasha's Treatise",
        head="Adhemar Bonnet +1",neck="Fotia Gorget",ear1="Moonshade Earring",ear2="Hattori Earring +1",
        body="Kendatsuba Samue +1",hands="Adhemar Wristbands +1",ring1="Regal Ring",ring2="Ephramad's Ring",
        back=gear.ShunCape,waist="Fotia Belt",legs="Samnuha Tights",feet=gear.herc_feet_ta})
    sets.precast.WS['Blade: Shun'] = prioritize({ammo="Cath Palug Stone",
        head="Kendatsuba Jinpachi +1",neck="Fotia Gorget",ear1="Odr Earring",ear2="Hattori Earring +1",
        body="Kendatsuba Samue +1",hands="Kendatsuba Tekko +1",ring1="Regal Ring",ring2="Ephramad's Ring",
        back=gear.ShunCape,waist="Fotia Belt",legs="Jokushu Haidate",feet="Kendatsuba Sune-Ate +1"})
    sets.precast.WS['Blade: Ten'] = prioritize({ammo="Oshasha's Treatise",
        head="Nyame Helm",neck="Ninja Nodowa +2",ear1="Moonshade Earring",ear2="Hattori Earring +1",
        body="Nyame Mail",hands="Nyame Gauntlets",ring1="Epaminondas's Ring",ring2="Ephramad's Ring",
        back=gear.TenCape,waist="Sailfi Belt +1",legs="Nyame Flanchard",feet="Nyame Sollerets"})
    sets.precast.WS['Blade: Metsu'] = prioritize({ammo="Cath Palug Stone",
        head="Hachiya Hatsuburi +3",neck="Ninja Nodowa +2",ear1="Lugra Earring +1",ear2="Hattori Earring +1",
        body="Nyame Mail",hands="Nyame Gauntlets",ring1="Epaminondas's Ring",ring2="Ephramad's Ring",
        back=gear.MetsuCape,waist="Fotia Belt",legs="Nyame Flanchard",feet="Nyame Sollerets"})
    sets.precast.WS['Blade: Kamu'] = prioritize({ammo="Oshasha's Treatise",
        head="Nyame Helm",neck="Ninja Nodowa +2",ear1="Lugra Earring +1",ear2="Hattori Earring +1",
        body="Nyame Mail",hands="Nyame Gauntlets",ring1="Gere Ring",ring2="Ephramad's Ring",
        back=gear.TenCape,waist="Fotia Belt",legs="Nyame Flanchard",feet=gear.herc_feet_ta})
    sets.precast.WS['Blade: Hi'] = prioritize({ammo="Yetshila +1",
        head="Hachiya Hatsuburi +3",neck="Ninja Nodowa +2",ear1="Odr Earring",ear2="Hattori Earring +1",
        body="Kendatsuba Samue +1",hands="Mummu Wrists +2",ring1="Epaminondas's Ring",ring2="Ephramad's Ring",
        back=gear.HiCape,waist="Windbuffet Belt +1",legs="Mummu Kecks +2",feet="Mummu Gamashes +2"})
    sets.precast.WS['Blade: Jin'] = prioritize(set_combine(sets.precast.WS['Blade: Hi'], {
        head="Adhemar Bonnet +1",body="Kendatsuba Samue +1",ring1="Ilabrat Ring",
        back=gear.ShunCape,waist="Fotia Belt"}))
    sets.precast.WS.Evisceration = set_combine(sets.precast.WS['Blade: Jin'], {})
    sets.precast.WS['Vorpal Blade'] = set_combine(sets.precast.WS['Blade: Jin'], {})
    sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS['Blade: Ten'], {ammo="Seething Bomblet +1"})
    sets.precast.WS['Tachi: Kasha'] = set_combine(sets.precast.WS['Savage Blade'], {})
    sets.precast.WS['Judgment']    = set_combine(sets.precast.WS['Savage Blade'], {})
    sets.precast.WS['True Strike']  = set_combine(sets.precast.WS['Savage Blade'], {})

    sets.precast.WS['Aeolian Edge'] = prioritize({ammo="Seething Bomblet +1",
        head="Mochizuki Hatsuburi +3",neck="Fotia Gorget",ear1="Moonshade Earring",ear2="Friomisi Earring",
        body="Nyame Mail",hands="Nyame Gauntlets",ring1="Dingir Ring",ring2="Epaminondas's Ring",
        back=gear.MetsuCape,waist="Fotia Belt",legs="Nyame Flanchard",feet="Nyame Sollerets"})
    sets.precast.WS['Aeolian Edge'].Tag = prioritize({ammo="Seething Bomblet +1",
        head="Nyame Helm",neck="Bathy Choker +1",ear1="Eabani Earring",ear2="Moonshade Earring",
        body="Nyame Mail",hands="Nyame Gauntlets",ring1="Hizamaru Ring",ring2="Defending Ring",
        back=gear.MetsuCape,waist="Null Belt",legs="Nyame Flanchard",feet="Nyame Sollerets"})
    sets.precast.WS.Cyclone = sets.precast.WS['Aeolian Edge']
    sets.precast.WS['Blade: Yu']       = set_combine(sets.precast.WS['Aeolian Edge'], {ear1="Hecate's Earring"})
    sets.precast.WS['Blade: Ei']       = set_combine(sets.precast.WS['Aeolian Edge'], {head="Pixie Hairpin +1",ring2="Archon Ring"})
    sets.precast.WS['Sanguine Blade']  = set_combine(sets.precast.WS['Blade: Ei'], {})
    sets.precast.WS['Red Lotus Blade'] = set_combine(sets.precast.WS['Aeolian Edge'], {})
    sets.precast.WS['Seraph Blade']    = set_combine(sets.precast.WS['Aeolian Edge'], {})
    sets.precast.WS['Flash Nova']      = set_combine(sets.precast.WS['Aeolian Edge'], {})

    sets.precast.WS['Blade: To'] = prioritize({ammo="Oshasha's Treatise",
        head="Mochizuki Hatsuburi +3",neck="Ninja Nodowa +2",ear1="Moonshade Earring",ear2="Hattori Earring +1",
        body="Nyame Mail",hands="Nyame Gauntlets",ring1="Gere Ring",ring2="Ephramad's Ring",
        back=gear.TenCape,waist="Orpheus's Sash",legs="Nyame Flanchard",feet="Nyame Sollerets"})
    sets.precast.WS['Blade: Teki']  = set_combine(sets.precast.WS['Blade: To'], {})
    sets.precast.WS['Blade: Chi']   = set_combine(sets.precast.WS['Blade: To'], {})
    sets.precast.WS['Tachi: Jinpu'] = set_combine(sets.precast.WS['Blade: To'], {})

    sets.precast.WS['Blade: Retsu'] = prioritize({ammo="Yetshila +1",
        head="Null Masque",neck="Null Loop",ear1="Moonshade Earring",ear2="Hattori Earring +1",
        body="Nyame Mail",hands="Nyame Gauntlets",ring1="Regal Ring",ring2="Ephramad's Ring",
        back=gear.TPCape,waist="Null Belt",legs="Nyame Flanchard",feet="Nyame Sollerets"})
    sets.precast.WS['Tachi: Ageha']  = set_combine(sets.precast.WS['Blade: Retsu'], {})
    sets.precast.WS['Tachi: Gekko']  = set_combine(sets.precast.WS['Blade: Retsu'], {})
    sets.precast.WS['Tachi: Hobaku'] = set_combine(sets.precast.WS['Blade: Retsu'], {})
    sets.precast.WS['Flat Blade']    = set_combine(sets.precast.WS['Blade: Retsu'], {})

    sets.precast.WS['Empyreal Arrow'] = prioritize({ammo=gear.arrow_ws,
        head="Nyame Helm",neck="Null Loop",ear1="Moonshade Earring",ear2="Hattori Earring +1",
        body="Nyame Mail",hands="Nyame Gauntlets",ring1="Epaminondas's Ring",ring2="Ephramad's Ring",
        back=gear.HiCape,waist="Null Belt",legs="Nyame Flanchard",feet="Nyame Sollerets"})
    sets.precast.WS['Flaming Arrow'] = set_combine(sets.precast.WS['Empyreal Arrow'], {neck="Fotia Gorget",waist="Fotia Belt"})
    sets.precast.WS['Hot Shot']      = set_combine(sets.precast.WS['Flaming Arrow'], {})

    sets.precast.RA = prioritize({ammo="Date Shuriken",
        head=gear.taeon_head_snap,body=gear.taeon_body_snap,hands=gear.taeon_hands_snap,
        back=gear.SnapCape,waist="Yemaya Belt",legs="Adhemar Kecks +1",feet=gear.taeon_feet_snap})
    sets.precast.RA.Bow = set_combine(sets.precast.RA, {range="Ullr",ammo=gear.arrow_tp})
    sets.precast.FC = prioritize({main=gear.fudoB,sub="Tsuru",ammo="Sapience Orb",
        head=gear.herc_head_fc,neck="Orunmila's Torque",ear1="Etiolation Earring",ear2="Odnowa Earring +1",
        body=gear.adh_body_fc,hands="Leyline Gloves",ring1="Gelatinous Ring +1",ring2="Kishar Ring",
        back=gear.FCCape,waist="Platinum Moogle Belt",legs=gear.herc_legs_fc,feet=gear.herc_feet_fc})
    -- fc+63
    sets.precast.FC.Ninjutsu = set_combine(sets.precast.FC, {ammo="Impatiens"})
    sets.precast.FC.Utsusemi = prioritize(set_combine(sets.precast.FC.Ninjutsu, {neck="Magoraga Beads",legs="Nyame Flanchard"}))
    sets.precast.FC.Utsusemi.SubRDM = set_combine(sets.precast.FC.Utsusemi, {back="Moonbeam Cape"})

    sets.precast.Waltz = prioritize({ammo="Yamarang",
        head="Mummu Bonnet +2",neck="Bathy Choker +1",ear1="Eabani Earring",ear2="Odnowa Earring +1",
        body="Nyame Mail",hands="Nyame Gauntlets",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.ParryCape,waist="Kasiri Belt",legs="Nyame Flanchard",feet="Nyame Sollerets"})
    sets.precast.Step = prioritize({ammo="Yamarang",
        head="Null Masque",neck="Null Loop",ear1="Telos Earring",ear2="Dignitary's Earring",
        body="Nyame Mail",hands="Nyame Gauntlets",ring1="Ilabrat Ring",ring2="Ephramad's Ring",
        back=gear.TPCape,waist="Null Belt",legs="Nyame Flanchard",feet="Nyame Sollerets"})
    sets.precast.JA['Violent Flourish'] = prioritize(set_combine(sets.precast.Step, {ring1="Etana Ring"}))
    sets.precast.JA['Animated Flourish'] = set_combine(sets.Enmity, {})
    sets.precast.WS.NoDmg = set_combine(sets.precast.Step, {back=gear.EnmCape,ring2="Defending Ring"})

    -- Midcast Sets
    sets.midcast.RA = prioritize({ammo="Date Shuriken",
        head="Malignance Chapeau",neck="Ninja Nodowa +2",ear1="Telos Earring",ear2="Odnowa Earring +1",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Dingir Ring",ring2="Defending Ring",
        back=gear.HiCape,waist="Null Belt",legs="Malignance Tights",feet="Malignance Boots"})
    sets.midcast.RA.Bow = set_combine(sets.midcast.RA, {range="Ullr",ammo=gear.arrow_tp,
        ear2="Crepuscular Earring",ring2="Ephramad's Ring"})
    sets.precast.JA.Shadowbind = sets.midcast.RA.Bow

    sets.midcast.Ninjutsu = prioritize({main=gear.fudoC,sub="Tsuru",ammo="Date Shuriken",
        head="Null Masque",neck="Bathy Choker +1",ear1="Eabani Earring",ear2="Odnowa Earring +1",
        body="Mpaca's Doublet",hands="Mochizuki Tekko +3",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.ParryCape,waist="Platinum Moogle Belt",legs="Nyame Flanchard",feet="Nyame Sollerets"})
    sets.midcast['Migawari: Ichi'] = set_combine(sets.midcast.Ninjutsu, {back=gear.FCCape})

    sets.midcast.Utsusemi = prioritize(set_combine(sets.midcast.Ninjutsu, {hands="Nyame Gauntlets",feet="Hattori Kyahan +2"}))
    sets.midcast.Utsusemi.Enmity = prioritize({main=gear.fudoC,sub="Tsuru",ammo="Date Shuriken",
        head="Genmei Kabuto",neck="Moonlight Necklace",ear1="Trux Earring",ear2="Cryptic Earring",
        body="Emet Harness +1",hands="Kurys Gloves",ring1="Eihwaz Ring",ring2="Defending Ring",
        back=gear.EnmCape,waist="Platinum Moogle Belt",legs="Nyame Flanchard",feet="Hattori Kyahan +2"})
    -- enm+64, pdt-44, dt-23
    sets.midcast.Utsusemi.NoCancel = prioritize({ring2="Supershear Ring",feet="Nyame Sollerets"})
    sets.midcast.Utsusemi.Enmity.NoCancel = {feet="Ahosi Leggings"}
    sets.midcast.Utsusemi.EvaPDT = prioritize({main=gear.fudoC,sub="Tsuru",ammo="Date Shuriken",
        head="Null Masque",neck="Bathy Choker +1",ear1="Eabani Earring",ear2="Infused Earring",
        body="Mpaca's Doublet",hands="Nyame Gauntlets",ring1="Hizamaru Ring",ring2="Defending Ring",
        back=gear.ParryCape,waist="Kasiri Belt",legs="Mpaca's Hose",feet="Nyame Sollerets"})
    sets.midcast.Utsusemi.SIRD = prioritize({main="Tancho +1",sub="Tancho",ammo="Date Shuriken",
        head="Null Masque",neck="Moonlight Necklace",ear1="Eabani Earring",ear2="Odnowa Earring +1",
        body="Mpaca's Doublet",hands="Rawhide Gloves",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.ParryCape,waist="Audumbla Sash",legs="Nyame Flanchard",feet="Hattori Kyahan +2"})
    -- enm+32, pdt-50, dt-36, sird+105

    sets.midcast.ElementalNinjutsu = prioritize({main="Gokotai",sub="Kunimitsu",ammo="Pemphredo Tathlum",
        head="Mochizuki Hatsuburi +3",neck="Sibyl Scarf",ear1="Lugra Earring +1",ear2="Friomisi Earring",
        body="Nyame Mail",hands="Nyame Gauntlets",ring1="Dingir Ring",ring2="Metamorph Ring +1",
        back=gear.NukeCape,waist="Eschan Stone",legs="Nyame Flanchard",feet="Mochizuki Kyahan +3"})
    sets.midcast.ElementalNinjutsu.MB = set_combine(sets.midcast.ElementalNinjutsu, {neck="Warder's Charm +1",ring1="Mujin Band"})
    sets.buff.Futae = {hands="Hattori Tekko +2"}
    sets.orpheus    = {waist="Orpheus's Sash"}
    sets.ele_obi    = {waist="Hachirin-no-Obi"}
    sets.nuke_belt  = {waist="Eschan Stone"}
    sets.donargun   = {range="Donar Gun",ammo=empty}

    sets.midcast.EnfeeblingNinjutsu = prioritize({main="Nagi",sub="Gokotai",ammo="Yamarang",
        head="Hachiya Hatsuburi +3",neck="Null Loop",ear1="Crepuscular Earring",ear2="Hattori Earring +1",
        body="Malignance Tabard",hands="Malignance Gloves",ring1=gear.Lstikini,ring2="Metamorph Ring +1",
        back=gear.NukeCape,waist="Null Belt",legs="Malignance Tights",feet="Hachiya Kyahan +3"})
    sets.kajabow = {range="Ullr",ammo=empty}

    sets.midcast['Enfeebling Magic'] = set_combine(sets.midcast.EnfeeblingNinjutsu, {})
    sets.midcast.Repose = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast['Enhancing Magic'] = {neck="Incanter's Torque",ear1="Andoaa Earring",ear2="Mimir Earring",
        ring1=gear.Lstikini,ring2=gear.Rstikini,waist="Olympus Sash"}
    sets.phlx = {head=gear.taeon_head_phlx,body=gear.herc_body_phlx,
        hands=gear.herc_hands_phlx,legs=gear.herc_legs_phlx,feet=gear.herc_feet_phlx}
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
    sets.midcast['Blue Magic']   = {}
    sets.midcast['Stinking Gas'] = set_combine(sets.Enmity, {})
    sets.midcast['Sheep Song']   = set_combine(sets.Enmity, {})
    sets.midcast['Geist Wall']   = set_combine(sets.Enmity, {})
    sets.midcast['Blank Gaze']   = set_combine(sets.Enmity, {})
    sets.midcast.Soporific       = set_combine(sets.Enmity, {})
    sets.midcast.Jettatura       = set_combine(sets.Enmity, {})

    -- Sets to return to when not performing an action.
    sets.idle = prioritize({main=gear.fudoC,sub="Tsuru",ammo="Yamarang",
        head="Null Masque",neck="Bathy Choker +1",ear1="Eabani Earring",ear2="Infused Earring",
        body="Hizamaru Haramaki +2",hands="Nyame Gauntlets",ring1="Gelatinous Ring +1",ring2="Defending Ring",
        back=gear.EnmCape,waist="Platinum Moogle Belt",legs="Nyame Flanchard",feet="Hachiya Kyahan +3"})
    sets.idle.Rf  = prioritize(set_combine(sets.idle, {
        neck="Sibyl Scarf",
        body="Mekosuchinae Harness",hands=gear.herc_hands_rf,ring1=gear.Lstikini,ring2=gear.Rstikini,
        legs=gear.herc_legs_rf}))
    sets.idle.DW = prioritize({ammo="Yamarang",
        head="Ryuo Somen +1",neck="Null Loop",ear1="Eabani Earring",ear2="Suppanomimi",
        body="Mochizuki Chainmail +3",hands="Floral Gauntlets",ring1="Vocane Ring +1",ring2="Defending Ring",
        back=gear.DWCape,waist="Reiki Yotai",legs="Mochizuki Hakama +3",feet="Hizamaru Sune-Ate +2"})

    sets.defense.PDT = prioritize({main=gear.fudoC,sub="Tsuru",ammo="Yamarang",
        head="Null Masque",neck="Bathy Choker +1",ear1="Cryptic Earring",ear2="Odnowa Earring +1",
        body="Mpaca's Doublet",hands="Nyame Gauntlets",ring1="Gere Ring",ring2="Epona's Ring",
        back=gear.EnmCape,waist="Platinum Moogle Belt",legs="Mpaca's Hose",feet="Nyame Sollerets"})
    -- FudoC/Shuriken: acc~1233/1209/1128, haste+25, da+9, ta+16 FIXME
    -- pdt-50, dt-46, def~1468, eva~1208, meva+587, hp~3581, enm+14, rg+3, counter+23, killer+10
    sets.defense.EvaPDT = prioritize({main="Tancho +1",sub="Tsuru",ammo="Yamarang",
        head="Null Masque",neck="Bathy Choker +1",ear1="Eabani Earring",ear2="Infused Earring",
        body="Mpaca's Doublet",hands="Nyame Gauntlets",ring1="Hizamaru Ring",ring2="Defending Ring",
        back=gear.ParryCape,waist="Kasiri Belt",legs="Mpaca's Hose",feet="Nyame Sollerets"})
    -- FudoC/Shuriken: acc~1225/1201/1127, haste+26, stp+0, dw+4, da+6, ta+8 FIXME
    -- pdt-50, dt-31, def~1454, eva~1260, meva+595, hp~3181, enm+16, rg+4, counter+20, parry+5, killer+10
    sets.defense.MDT = prioritize({main=gear.fudoC,sub="Tsuru",ammo="Yamarang",
        head="Null Masque",neck="Warder's Charm +1",ear1="Eabani Earring",ear2="Cryptic Earring",
        body="Nyame Mail",hands="Nyame Gauntlets",ring1="Shadow Ring",ring2="Defending Ring",
        back=gear.ParryCape,waist="Platinum Moogle Belt",legs="Nyame Flanchard",feet="Nyame Sollerets"})
    -- FudoC/Shuriken: acc~1206/1182/1221, haste+20, dw+4, da+12 FIXME
    -- dt-50, def~1457, eva~1200, meva+740, hp~3575, enm+14, parry+5

    sets.danzo     = {feet="Danzo Sune-Ate"}
    sets.hachiya   = prioritize({feet="Hachiya Kyahan +3"})
    sets.Kiting    = sets.hachiya
    sets.buff.doom = prioritize({
        head="Malignance Chapeau",neck="Nicander's Necklace",ear1="Telos Earring",ear2="Odnowa Earring +1",
        body="Mpaca's Doublet",hands="Nyame Gauntlets",ring1="Eshmun's Ring",ring2="Defending Ring",
        back=gear.TPCape,waist="Gishdubar Sash",legs="Malignance Tights",feet="Nyame Sollerets"})
    sets.buff.sleep = {main="Dokoku"}

    -- Engaged sets
    sets.engaged = prioritize({main=gear.fudoB,sub="Kunimitsu",ammo="Date Shuriken",
        head="Adhemar Bonnet +1",neck="Ninja Nodowa +2",ear1="Telos Earring",ear2="Brutal Earring",
        body="Kendatsuba Samue +1",hands="Adhemar Wristbands +1",ring1="Gere Ring",ring2="Epona's Ring",
        back="Null Shawl",waist="Windbuffet Belt +1",legs="Samnuha Tights",feet=gear.herc_feet_ta})
    -- Heishi/Shuriken: acc~1216/1191/1062, haste+26, stp+47, da+12, ta+33, qa+2, pdt-12, sb=50, eva~902, meva+369 FIXME
    sets.engaged.DW30 = prioritize(set_combine(sets.engaged, {ear1="Eabani Earring",back=gear.DWCape,waist="Reiki Yotai"}))
    sets.engaged.DW15 = prioritize(set_combine(sets.engaged.DW30, {ear2="Suppanomimi",body=gear.adh_body_ta}))
    sets.engaged.DW00 = prioritize(set_combine(sets.engaged.DW30, {head="Ryuo Somen +1",body="Mochizuki Chainmail +3"}))

    sets.engaged.PDef = prioritize({main=gear.fudoB,sub="Kunimitsu",ammo="Date Shuriken",
        head="Malignance Chapeau",neck="Ninja Nodowa +2",ear1="Telos Earring",ear2="Dignitary's Earring",
        body="Malignance Tabard",hands="Malignance Gloves",ring1="Gere Ring",ring2="Defending Ring",
        back=gear.TPCape,waist="Windbuffet Belt +1",legs="Mpaca's Hose",feet=gear.herc_feet_ta})
    -- Heishi/Shuriken: acc~1291/1266/1124, haste+26, stp+66, da+1, ta+17, qa+2, pdt-50, dt-30, sb=43+5, eva~1067, meva+545 FIXME
    sets.engaged.DW30.PDef = prioritize(set_combine(sets.engaged.PDef, {ear1="Eabani Earring",back=gear.DWCape,waist="Reiki Yotai"}))
    sets.engaged.DW15.PDef = set_combine(sets.engaged.DW30.PDef, {ear2="Suppanomimi",feet="Hizamaru Sune-Ate +2"})
    sets.engaged.DW00.PDef = set_combine(sets.engaged.DW15.PDef, {})

    sets.engaged.EXP = prioritize(set_combine(sets.engaged.PDef, {ear2="Brutal Earring",body="Mpaca's Doublet",ring2="Epona's Ring"}))
    sets.engaged.DW30.EXP = prioritize(set_combine(sets.engaged.DW30.PDef, {body="Mpaca's Doublet",ring2="Epona's Ring"}))
    sets.engaged.DW15.EXP = set_combine(sets.engaged.DW30.EXP, {ear2="Suppanomimi",body=gear.adh_body_ta})
    sets.engaged.DW00.EXP = set_combine(sets.engaged.DW00, {})

    sets.engaged.MEVA = prioritize({main=gear.fudoB,sub="Kunimitsu",ammo="Date Shuriken",
        head="Kendatsuba Jinpachi +1",neck="Ninja Nodowa +2",ear1="Telos Earring",ear2="Brutal Earring",
        body="Malignance Tabard",hands="Kendatsuba Tekko +1",ring1="Gere Ring",ring2="Defending Ring",
        back="Null Shawl",waist="Windbuffet Belt +1",legs="Malignance Tights",feet="Kendatsuba Sune-Ate +1"})
    -- Heishi/Shuriken: acc~1325/1300/1192, haste+26, stp+54, da+6, ta+19, qa+2, dt-26, sb=50, eva~1009, meva+619 FIXME
    sets.engaged.DW30.MEVA = prioritize(set_combine(sets.engaged.MEVA, {ear1="Eabani Earring",back=gear.DWCape,waist="Reiki Yotai"}))
    sets.engaged.DW15.MEVA = set_combine(sets.engaged.DW30.MEVA, {ear2="Suppanomimi",body=gear.adh_body_ta})
    sets.engaged.DW00.MEVA = set_combine(sets.engaged.DW15.MEVA, {head="Ryuo Somen +1"})

    sets.engaged.MEVA.PDef      = set_combine(sets.engaged.MEVA, {head="Malignance Chapeau",ring1="Vocane Ring +1",back=gear.TPCape})
    sets.engaged.DW30.MEVA.PDef = prioritize(set_combine(sets.engaged.MEVA.PDef, {ear1="Eabani Earring",back=gear.DWCape,waist="Reiki Yotai"}))
    sets.engaged.DW15.MEVA.PDef = set_combine(sets.engaged.DW30.MEVA.PDef, {ear2="Suppanomimi"})
    sets.engaged.DW00.MEVA.PDef = set_combine(sets.engaged.DW15.MEVA.PDef, {head="Ryuo Somen +1",feet="Malignance Boots"})

    sets.engaged.None      = sets.engaged.MEVA
    sets.engaged.DW30.None = sets.engaged.DW30.MEVA
    sets.engaged.DW15.None = sets.engaged.DW15.MEVA
    sets.engaged.DW00.None = sets.engaged.DW00.MEVA

    sets.engaged.Acc = prioritize({main=gear.fudoB,sub="Kunimitsu",ammo="Date Shuriken",
        head="Kendatsuba Jinpachi +1",neck="Ninja Nodowa +2",ear1="Telos Earring",ear2="Hattori Earring +1",
        body="Kendatsuba Samue +1",hands="Adhemar Wristbands +1",ring1="Gere Ring",ring2="Ephramad's Ring",
        back="Null Shawl",waist="Windbuffet Belt +1",legs="Kendatsuba Hakama +1",feet="Kendatsuba Sune-Ate +1"})
    sets.engaged.DW30.Acc = prioritize(set_combine(sets.engaged.Acc,      {ear1="Eabani Earring",back=gear.DWCape,waist="Reiki Yotai"}))
    sets.engaged.DW15.Acc = prioritize(set_combine(sets.engaged.DW30.Acc, {ear2="Suppanomimi",body=gear.adh_body_ta}))
    sets.engaged.DW00.Acc = prioritize(set_combine(sets.engaged.DW15.Acc, {head="Ryuo Somen +1"}))

    sets.engaged.Acc.PDef = prioritize(set_combine(sets.engaged.Acc, {
        head="Malignance Chapeau",body="Malignance Tabard",hands="Malignance Gloves",ring2="Defending Ring",
        back=gear.TPCape,legs="Malignance Tights",feet="Malignance Boots"}))
    sets.engaged.DW30.Acc.PDef = prioritize(set_combine(sets.engaged.Acc.PDef, {ear1="Eabani Earring",back=gear.DWCape,waist="Reiki Yotai"}))
    sets.engaged.DW15.Acc.PDef = set_combine(sets.engaged.DW30.Acc.PDef, {ear2="Suppanomimi"})
    sets.engaged.DW00.Acc.PDef = set_combine(sets.engaged.DW15.Acc.PDef, {})

    sets.engaged.Crit      = prioritize(set_combine(sets.engaged.Acc,      {
        ear1="Odr Earring",ear2="Brutal Earring",hands="Kendatsuba Tekko +1",back=gear.CritCape}))
    sets.engaged.DW30.Crit = prioritize(set_combine(sets.engaged.DW30.Acc, {
        ear1="Odr Earring",hands="Kendatsuba Tekko +1"}))
    sets.engaged.DW15.Crit = prioritize(set_combine(sets.engaged.DW15.Acc, {hands="Kendatsuba Tekko +1"}))
    sets.engaged.DW00.Crit = prioritize(set_combine(sets.engaged.DW00.Acc, {hands="Kendatsuba Tekko +1"}))

    sets.engaged.Crit.PDef = prioritize({main="Kannagi",sub="Gleti's Knife",ammo="Date Shuriken",
        head="Malignance Chapeau",neck="Ninja Nodowa +2",ear1="Odr Earring",ear2="Brutal Earring",
        body="Mpaca's Doublet",hands="Malignance Gloves",ring1="Gere Ring",ring2="Defending Ring",
        back=gear.CritCape,waist="Windbuffet Belt +1",legs="Mpaca's Hose",feet="Kendatsuba Sune-Ate +1"})
    sets.engaged.DW30.Crit.PDef = prioritize(set_combine(sets.engaged.Crit.PDef, {ear1="Eabani Earring",back=gear.DWCape,waist="Reiki Yotai"}))
    sets.engaged.DW15.Crit.PDef = set_combine(sets.engaged.DW30.Crit.PDef, {ear2="Suppanomimi"})
    sets.engaged.DW00.Crit.PDef = set_combine(sets.engaged.DW15.Crit.PDef, {})

    sets.engaged.H2H      = set_combine(sets.engaged,      {ear1="Mache Earring +1"})
    sets.engaged.H2H.MEVA = set_combine(sets.engaged.MEVA, {ear1="Mache Earring +1"})
    sets.engaged.H2H.Acc  = set_combine(sets.engaged.Acc,  {ear1="Mache Earring +1"})
    sets.engaged.H2H.PDef = set_combine(sets.engaged.PDef, {ear1="Mache Earring +1"})

    -- Spells default to a midcast of FastRecast before layering on the above sets
    sets.midcast.FastRecast = set_combine(sets.defense.PDT, {})
    sets.hpup = prioritize({main=gear.fudoC,sub="Tsuru",
        head="Genmei Kabuto",neck="Unmoving Collar +1",ear1="Etiolation Earring",ear2="Odnowa Earring +1",
        body="Ashera Harness",hands="Nyame Gauntlets",ring1="Gelatinous Ring +1",ring2="Regal Ring",
        back="Moonbeam Cape",waist="Platinum Moogle Belt",legs="Nyame Flanchard",feet="Nyame Sollerets"})
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
    elseif spellMap == 'Utsusemi' and player.sub_job == 'RDM' then
        equip(sets.precast.FC.Utsusemi.SubRDM)
    elseif spell.english == 'Valiance' and buffactive['Vallation'] then
        send_command('cancel Vallation')
    elseif spell.english == 'Mijin Gakure' then
        if not buffactive.Reraise then
            enable('main','sub')
            state.OffenseMode:set('None')
            hud_update_on_state_change('Offense Mode')
        end
    elseif spell.action_type == 'Ranged Attack' and state.RangedMode.value == 'Tathlum' then
        eventArgs.cancel = true
    end
end

-- Run after the general precast() is done.
function job_post_precast(spell, action, spellMap, eventArgs)
    if spell.type == 'WeaponSkill' then
        if buffactive['elvorseal'] and player.inventory["Heidrek Boots"] then equip({feet="Heidrek Boots"}) end
        if state.WeaponskillMode.value == 'NoDmg' then
            if info.magic_ws:contains(spell.english) and spell.english ~= 'Aeolian Edge' then
                equip(sets.naked)
            else
                equip(sets.precast.WS.NoDmg)
            end
        elseif state.DefenseMode.value == 'Physical' and state.PhysicalDefenseMode.value == 'EvaPDT'
        and S{'Aeolian Edge','Cyclone'}:contains(spell.english) then -- tag safely
            equip(sets.precast.WS[spell.english].Tag)
        elseif info.obi_ws:contains(spell.english) then
            equip(resolve_ele_belt(spell, sets.ele_obi, sets.nuke_belt, 2.5))
        elseif state.SCB.value then
            equip(sets.scb)
        elseif spell.english == 'Blade: Shun'  and S{'Fire','Light','Lightning'}:contains(world.day_element)
        or     spell.english == 'Blade: Kamu'  and S{'Wind','Lightning','Dark'}:contains(world.day_element)
        or     spell.english == 'Blade: Ku'    and S{'Earth','Dark','Light'}:contains(world.day_element)
        or     spell.english == 'Evisceration' and S{'Earth','Dark','Light'}:contains(world.day_element)
        or     spell.english == 'Raging Fists' and world.day_element == 'Lightning'
        or     spell.english == 'Tornado Kick' and S{'Ice','Lightning','Wind'}:contains(world.day_element)
        or     spell.english == 'Asuran Fists' and S{'Earth','Dark','Fire'}:contains(world.day_element) then
            equip(sets.gavialis)
        end
    elseif spell.type == 'JobAbility' then
        if state.DefenseMode.value == 'Physical' and state.PhysicalDefenseMode.value == 'EvaPDT'
        and sets.precast.JA[spell.english] and spell.english ~= 'Mijin Gakure' then
            equip(sets.Enmity.EvaPDT)
        end
        if not buffactive['Copy Image (4+)'] and sets.precast.JA[spell.english] then
            -- use nagi instead of fudo C for enmity
            equip(sets.nagi)
        end
    elseif spell.action_type == 'Ranged Attack' and state.CombatWeapon.value:endswith('Bow') then
        equip(sets.precast.RA.Bow)
    end

    -- control blinking or tp loss for ranged modes
    if state.CombatWeapon.value:endswith('Bow') and state.OffenseMode.value ~= 'None' then
        if spell.type == 'WeaponSkill' then
            equip(sets.weapons[state.CombatWeapon.value], {ammo=gear.arrow_ws})
        else
            equip(sets.weapons[state.CombatWeapon.value], {ammo=gear.arrow_tp})
        end
    elseif state.RangedMode.value == 'Shuriken' then
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
        local eva_defense = state.DefenseMode.value == 'Physical' and state.PhysicalDefenseMode.value == 'EvaPDT'
        local enmity_utsu = state.Buff.Yonin and state.CastingMode.value == 'Enmity' and not eva_defense

        local utsu_set = sets.midcast.Utsusemi
        if     eva_defense then utsu_set = sets.midcast.Utsusemi.EvaPDT
        elseif enmity_utsu then utsu_set = sets.midcast.Utsusemi.Enmity
        end
        equip(utsu_set)

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
            elseif state.LastUtsu.value > 1 then
                equip(utsu_set.NoCancel or utsu_set)
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
            elseif state.LastUtsu.value == 3 then
                equip(utsu_set.NoCancel or utsu_set)
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
    elseif spell.action_type == 'Ranged Attack' and state.CombatWeapon.value:endswith('Bow') then
        equip(sets.midcast.RA.Bow)
    end

    -- control blinking or tp loss for ranged modes
    if state.CombatWeapon.value:endswith('Bow') and state.OffenseMode.value ~= 'None' then
        if spell.type == 'WeaponSkill' then
            equip(sets.weapons[state.CombatWeapon.value], {ammo=gear.arrow_ws})
        else
            equip(sets.weapons[state.CombatWeapon.value], {ammo=gear.arrow_tp})
        end
    elseif state.RangedMode.value == 'Shuriken' then
        equip(sets.weapons.Daken)
    elseif state.RangedMode.value == 'Tathlum' then
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
            send_command('input /p '..spell.english)
        end
        if state.SCB.value then
            state.SCB:unset()
            hud_update_on_state_change('WS SCB')
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
    if state.AutoHybrid.value ~= 'off' and lbuff:startswith('copy ') then
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
    elseif lbuff == 'yonin' then
        hud_update_on_state_change('Casting Mode')
    elseif lbuff == 'doom' and not midaction() then
        handle_equipping_gear(player.status)
    elseif lbuff == 'sleep' and not midaction() then
        handle_equipping_gear(player.status)
    end
    if gain and info.chat_notice_buffs:contains(lbuff) then
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
            if player.equipment.sub == (type(new_set.main) == 'table' and new_set.main.name or new_set.main) then
                equip({main=empty,sub=empty})
                add_to_chat(123, 'unequipped weapons')
            elseif player.equipment.main == (type(new_set.sub) == 'table' and new_set.sub.name or new_set.sub) then
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
            send_command('bind ^delete input /fish')
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
            send_command('bind ^delete input /lastsynth')
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
        if state.OffenseMode.value ~= 'None' and state.IdleMode.value == 'Normal'
        and S{'Gokotai','GokoBow'}:contains(state.CombatWeapon.value) then
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
    if state.Buff.doom then
        idleSet = set_combine(idleSet, sets.buff.doom)
    end
    if state.Buff.sleep then
        idleSet = set_combine(idleSet, sets.buff.sleep)
    end
    if state.CombatWeapon.value:endswith('Bow') and state.OffenseMode.value ~= 'None' then
        idleSet = set_combine(idleSet, sets.weapons[state.CombatWeapon.value], {ammo=gear.arrow_tp})
    elseif state.RangedMode.value == 'Shuriken' then
        idleSet = set_combine(idleSet, sets.weapons.Daken)
    end
    return idleSet
end

-- Modify the default defense set after it was constructed.
function customize_defense_set(defenseSet)
    if state.DefenseMode.value == 'Physical' then
        if state.CombatWeapon.value == 'None'
        or sets.weapons[state.CombatWeapon.value].sub == 'Tsuru' then
            if state.PhysicalDefenseMode.value == 'PDT' then
                defenseSet = set_combine(defenseSet, {back=gear.ParryCape})
            end
        end
    end
    if state.Buff.doom then
        defenseSet = set_combine(defenseSet, sets.buff.doom)
    end
    if state.Buff.sleep then
        defenseSet = set_combine(defenseSet, sets.buff.sleep)
    end
    return defenseSet
end

-- Modify the default melee set after it was constructed.
function customize_melee_set(meleeSet)
    if buffactive['elvorseal'] and state.DefenseMode.value == 'None' then
        if player.inventory["Heidrek Gloves"] then meleeSet = set_combine(meleeSet, {hands="Heidrek Gloves"}) end
    end
    if state.HybridMode.value == 'PDef' then
        if state.CombatWeapon.value == 'None'
        or sets.weapons[state.CombatWeapon.value].sub == 'Tsuru' then
            local ring1 = meleeSet.ring1 or meleeSet.lring or meleeSet.left_ring or nil
            local ring2 = meleeSet.ring2 or meleeSet.rring or meleeSet.right_ring or nil
            if type(ring1) == 'table' then ring1 = ring1.name end
            if type(ring2) == 'table' then ring2 = ring2.name end
            if     ring1 == "Vocane Ring +1" then
                meleeSet = set_combine(meleeSet, {ring1="Gere Ring"})
            elseif ring2 == "Defending Ring" then
                meleeSet = set_combine(meleeSet, {ring2="Epona's Ring"})
            end
        end
    end
    if state.Buff.doom then
        meleeSet = set_combine(meleeSet, sets.buff.doom)
    end
    if state.Buff.sleep then
        meleeSet = set_combine(meleeSet, sets.buff.sleep)
    end
    if state.CombatWeapon.value:endswith('Bow') and state.OffenseMode.value ~= 'None' then
        meleeSet = set_combine(meleeSet, sets.weapons[state.CombatWeapon.value], {ammo=gear.arrow_tp})
    elseif state.RangedMode.value == 'Tathlum' then
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
    if state.WeaponskillMode.value ~= 'Normal' then
        msg = msg .. ' WS[' .. state.WeaponskillMode.current .. ']'
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
        elseif weap == 'HeiSB'    then handle_set({'CombatWeapon', 'HeiTsu'})
        elseif weap == 'HeiTsu'   then handle_set({'CombatWeapon', 'HeiFudo'})
        elseif weap == 'HeiFudo'  then handle_set({'CombatWeapon', 'HeiSB'})
        elseif weap == 'Gokotai'  then handle_set({'CombatWeapon', 'GokoBow'})
        elseif weap == 'GokoBow'  then handle_set({'CombatWeapon', 'FudoCBow'})
        elseif weap == 'FudoCBow' then handle_set({'CombatWeapon', 'Gokotai'})
        elseif weap == 'SCDagger' then handle_set({'CombatWeapon', 'AEDagger'})
        elseif weap == 'AEDagger' then handle_set({'CombatWeapon', 'SCDagger'})
        elseif weap == 'GKatana'  then handle_set({'CombatWeapon', 'GKGekko'})
        elseif weap == 'GKGekko'  then handle_set({'CombatWeapon', 'GKatana'})
        else add_to_chat(122, 'Combat Weapon remains %s.':format(state.CombatWeapon.value)) end
    elseif cmdParams[1] == 'save' then
        save_self_command(cmdParams)
    elseif cmdParams[1] == 'rebind' then
        info.keybinds:bind()
    else
        eventArgs.handled = false
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------

-- Select default macro book on initial load or subjob change.
--function select_default_macro_book()
--    set_macro_page(1,13)
--end

-- returns a list for use with make_keybind_list
function job_keybinds()
    local bind_command_list = L{
        'bind !^l input /lockstyleset 6',
        'bind %`   gs c update user',
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
        'bind @z  gs c cycle CastingMode',
        'bind ^z  gs c toggle MagicBurst',
        'bind !z  gs c cycle PhysicalDefenseMode',
        'bind !w  gs c reset OffenseMode',
        'bind @w  gs c set   OffenseMode EXP',
        'bind !@w gs c set   OffenseMode None',
        'bind ~^q gs c altweap',
        'bind !^q  gs c set CombatWeapon Kannagi',
        'bind ~!^q gs c set CombatWeapon Nagi',
        'bind ^@q  gs c set CombatWeapon AEDagger',
        'bind ~^@q gs c set CombatWeapon Gokotai',
        'bind !^w  gs c set CombatWeapon Heishi',
        'bind ~!^w gs c set CombatWeapon HeiSB',
        'bind ^@w  gs c set CombatWeapon GKatana',
        'bind !^e  gs c set CombatWeapon FudoB',
        'bind ~!^e gs c set CombatWeapon FudoC',
        'bind !^r  gs c set CombatWeapon NaegTP',
        'bind ~!^r gs c set CombatWeapon Kikoku',
        'bind !-         gs c set RangedMode Tathlum',
        'bind !=         gs c set RangedMode Shuriken',
        'bind !backspace gs c set RangedMode Blink',
        'bind ^c  gs c set OffenseMode Crit',
        'bind !c  gs c set OffenseMode Acc',
        'bind @c  gs c set OffenseMode MEVA',
        'bind !@c gs c toggle SIRDUtsu',
        'bind %c  gs c toggle SCB',
        'bind %b  gs equip TreasureHunter',

        'bind !^` input /ja "Mijin Gakure" <t>',
        'bind ^@` input /ja Mikage',
        'bind ^` input /ja Futae',
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

        'bind @` input /ra <stnpc>',

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
        'bind @g gs equip phlx',                       -- phalanx+15
        'bind @f input /ma "Gekka: Ichi"',             -- enm+30
        'bind !@f input /ma "Yain: Ichi"',             -- enm-15
        'bind !f input /ma "Kakka: Ichi"',             -- stp+10
        'bind !b input /ma "Myoshu: Ichi"',            -- sb+10
        'bind ~^x  input /ma "Monomi: Ichi" <me>',
        'bind ~!^x input /ma "Tonko: Ni" <me>'}

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
            'bind !5 input /ja "Super Jump"',
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
            'bind ~^tab input /ja Valiance <me>',      -- 450/900 per target, -15% damage per rune
            'bind !d input /ma Flash',                 -- 180/1280
            'bind @d input /ma Flash <stnpc>',
            'bind !^v input /ma Aquaveil <me>',
            'bind !6 input /ma Protect <stpc>'})
    elseif player.sub_job == 'PLD' then
        bind_command_list:extend(L{
            'bind !5 input /ja Cover <stpc>',
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
    elseif player.sub_job == 'RNG' then
        bind_command_list:extend(L{
            'bind !4 input /ja Barrage <me>',
            'bind !5 input /ja Sharpshot <me>',
            'bind !6 input /ja "Scavenge" <me>',
            'bind !d input /ja Shadowbind <stnpc>'})
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
    local bag_ids = T{['Inventory']=0,['Wardrobe']=8,['Wardrobe 2']=10,['Wardrobe 3']=11,['Wardrobe 4']=12,['Wardrobe 5']=13}
    local item_list = L{{name='shihei',id=1179},{name='shika',id=2972},{name='chono',id=2973},{name='ino',id=2971},
                        {name='shuriken',id=22292}}
    local counts = T{}
    for item in item_list:it() do counts[item.id] = 0 end

    for bag in S{'Inventory','Wardrobe','Wardrobe 5'}:it() do
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
    local scb_text_settings   = {pos={y=18},flags={draggable=false,bold=true},bg={red=0,green=220,blue=220,alpha=150},text={stroke={width=2}}}
    local sird_text_settings  = {pos={y=36},flags={draggable=false},bg={blue=150,green=150,alpha=150},text={stroke={width=2}}}
    local hyb_text_settings   = {pos={x=130,y=716},flags={draggable=false},bg={visible=false},text={size=12,stroke={width=2}}}
    local def_text_settings   = {pos={x=174,y=716},flags={draggable=false},bg={visible=false},text={size=12,stroke={width=2}}}
    local off_text_settings   = {pos={x=170,y=697},flags={draggable=false},bg={visible=false},text={size=12,stroke={width=2}}}
    local dw_text_settings    = {pos={x=130,y=699},flags={draggable=false},bg={visible=false},text={size=10,stroke={width=2}}}
    local enm_text_settings   = {pos={x=222,y=697},flags={draggable=false},bg={visible=false},
                                 text={red=50,green=220,blue=50,size=12,stroke={width=2}}}

    hud = {texts=T{}}
    hud.texts.mb_text    = texts.new('NonMB',          mb_text_settings)
    hud.texts.scb_text   = texts.new('SCB',            scb_text_settings)
    hud.texts.sird_text  = texts.new('SIRD',           sird_text_settings)
    hud.texts.hyb_text   = texts.new('initializing..', hyb_text_settings)
    hud.texts.def_text   = texts.new('initializing..', def_text_settings)
    hud.texts.off_text   = texts.new('initializing..', off_text_settings)
    hud.texts.dw_text    = texts.new('initializing..', dw_text_settings)
    hud.texts.enm_text   = texts.new('ENM',            enm_text_settings)

    -- update infrequently changing text boxes in job_state_change or where they are changed
    function hud_update_on_state_change(stateField)
        if not hud then init_state_text() end

        if not stateField or stateField == 'Magic Burst' then
            hud.texts.mb_text:visible((not state.MagicBurst.value))
        end

        if not stateField or stateField == 'WS SCB' then
            hud.texts.scb_text:visible(state.SCB.value)
        end

        if not stateField or stateField == 'SIRD Utsu' then
            hud.texts.sird_text:visible(state.SIRDUtsu.value)
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

        if not stateField or stateField == 'Casting Mode' then
            hud.texts.enm_text:visible(state.Buff.Yonin and state.CastingMode.value == 'Enmity')
        end
    end
end
