-------------------------------------------------------------------------------------------------------------------
-- Mappings, lists and sets to describe game relationships that aren't easily determinable otherwise.
-------------------------------------------------------------------------------------------------------------------
my_mote_mappings = true
-------------------------------------------------------------------------------------------------------------------
-- Elemental mappings for element relationships and certain types of spells and gear.
-------------------------------------------------------------------------------------------------------------------

-- Basic elements
elements = {}

elements.list = S{'Light','Dark','Fire','Ice','Wind','Earth','Lightning','Water'}

elements.weak_to = {['Light']='Dark', ['Dark']='Light', ['Fire']='Ice', ['Ice']='Wind', ['Wind']='Earth', ['Earth']='Lightning',
        ['Lightning']='Water', ['Water']='Fire'}

elements.strong_to = {['Light']='Dark', ['Dark']='Light', ['Fire']='Water', ['Ice']='Fire', ['Wind']='Ice', ['Earth']='Wind',
        ['Lightning']='Earth', ['Water']='Lightning'}

storms = S{"Aurorastorm", "Voidstorm", "Firestorm", "Sandstorm", "Rainstorm", "Windstorm", "Hailstorm", "Thunderstorm",
		"Aurorastorm II", "Voidstorm II", "Firestorm II", "Sandstorm II", "Rainstorm II", "Windstorm II", "Hailstorm II", "Thunderstorm II"}

elements.storm_of = {['Light']="Aurorastorm", ['Dark']="Voidstorm", ['Fire']="Firestorm", ['Earth']="Sandstorm",
        ['Water']="Rainstorm", ['Wind']="Windstorm", ['Ice']="Hailstorm", ['Lightning']="Thunderstorm",['Light']="Aurorastorm II",
		['Dark']="Voidstorm II", ['Fire']="Firestorm II", ['Earth']="Sandstorm II", ['Water']="Rainstorm II", ['Wind']="Windstorm II",
		['Ice']="Hailstorm II", ['Lightning']="Thunderstorm II"}

spirits = S{"LightSpirit", "DarkSpirit", "FireSpirit", "EarthSpirit", "WaterSpirit", "AirSpirit", "IceSpirit", "ThunderSpirit"}
elements.spirit_of = {['Light']="Light Spirit", ['Dark']="Dark Spirit", ['Fire']="Fire Spirit", ['Earth']="Earth Spirit",
        ['Water']="Water Spirit", ['Wind']="Air Spirit", ['Ice']="Ice Spirit", ['Lightning']="Thunder Spirit"}

runes = S{'Lux', 'Tenebrae', 'Ignis', 'Gelus', 'Flabra', 'Tellus', 'Sulpor', 'Unda'}
elements.rune_of         = {['Light']='Lux', ['Dark']='Tenebrae', ['Fire']='Ignis', ['Ice']='Gelus', ['Wind']='Flabra',
     ['Earth']='Tellus', ['Lightning']='Sulpor', ['Water']='Unda'}
elements.rune_element_of = {['Lux']='Light', ['Tenebrae']='Dark', ['Ignis']='Fire', ['Gelus']='Ice', ['Flabra']='Wind',
     ['Tellus']='Earth', ['Sulpor']='Lightning', ['Unda']='Water'}

elements.obi_of = {['Light']='Hachirin-no-obi', ['Dark']='Hachirin-no-obi', ['Fire']='Hachirin-no-obi', ['Ice']='Hachirin-no-obi', ['Wind']='Hachirin-no-obi',
     ['Earth']='Hachirin-no-obi', ['Lightning']='Hachirin-no-obi', ['Water']='Hachirin-no-obi'}

elements.gorget_of = {['Light']='Fotia Gorget', ['Dark']='Fotia Gorget', ['Fire']='Fotia Gorget', ['Ice']='Fotia Gorget',
    ['Wind']='Fotia Gorget', ['Earth']='Fotia Gorget', ['Lightning']='Fotia Gorget', ['Water']='Fotia Gorget'}

elements.belt_of = {['Light']='Fotia Belt', ['Dark']='Fotia Belt', ['Fire']='Fotia Belt', ['Ice']='Fotia Belt',
    ['Wind']='Fotia Belt', ['Earth']='Fotia Belt', ['Lightning']='Fotia Belt', ['Water']='Fotia Belt'}

elements.fastcast_staff_of = {['Light']='Arka I', ['Dark']='Xsaeta I', ['Fire']='Atar I', ['Ice']='Vourukasha I',
    ['Wind']='Vayuvata I', ['Earth']='Vishrava I', ['Lightning']='Apamajas I', ['Water']='Haoma I', ['Thunder']='Apamajas I'}

elements.recast_staff_of = {['Light']='Arka II', ['Dark']='Xsaeta II', ['Fire']='Atar II', ['Ice']='Vourukasha II',
    ['Wind']='Vayuvata II', ['Earth']='Vishrava II', ['Lightning']='Apamajas II', ['Water']='Haoma II', ['Thunder']='Apamajas II'}

elements.perpetuance_staff_of = {['Light']='Arka III', ['Dark']='Xsaeta III', ['Fire']='Atar III', ['Ice']='Vourukasha III',
    ['Wind']='Vayuvata III', ['Earth']='Vishrava III', ['Lightning']='Apamajas III', ['Water']='Haoma III', ['Thunder']='Apamajas III'}


-- Elements for skillchain names
skillchain_elements = {}
skillchain_elements.Light = S{'Light','Fire','Wind','Lightning'}
skillchain_elements.Darkness = S{'Dark','Ice','Earth','Water'}
skillchain_elements.Fusion = S{'Light','Fire'}
skillchain_elements.Fragmentation = S{'Wind','Lightning'}
skillchain_elements.Distortion = S{'Ice','Water'}
skillchain_elements.Gravitation = S{'Dark','Earth'}
skillchain_elements.Transfixion = S{'Light'}
skillchain_elements.Compression = S{'Dark'}
skillchain_elements.Liquification = S{'Fire'}
skillchain_elements.Induration = S{'Ice'}
skillchain_elements.Detonation = S{'Wind'}
skillchain_elements.Scission = S{'Earth'}
skillchain_elements.Impaction = S{'Lightning'}
skillchain_elements.Reverberation = S{'Water'}


-------------------------------------------------------------------------------------------------------------------
-- Mappings for weaponskills
-------------------------------------------------------------------------------------------------------------------

-- REM weapons and their corresponding weaponskills
data = {}
data.weaponskills = {}
data.weaponskills.relic = {
    ["Spharai"] = "Final Heaven",
    ["Mandau"] = "Mercy Stroke",
    ["Excalibur"] = "Knights of Round",
    ["Ragnarok"] = "Scourge",
    ["Guttler"] = "Onslaught",
    ["Bravura"] = "Metatron Torment",
    ["Apocalypse"] = "Catastrophe",
    ["Gungnir"] = "Gierskogul",
    ["Kikoku"] = "Blade: Metsu",
    ["Amanomurakumo"] = "Tachi: Kaiten",
    ["Mjollnir"] = "Randgrith",
    ["Claustrum"] = "Gates of Tartarus",
    ["Annihilator"] = "Coronach",
    ["Yoichinoyumi"] = "Namas Arrow"}
data.weaponskills.mythic = {
    ["Conqueror"] = "King's Justice",
    ["Glanzfaust"] = "Ascetic's Fury",
    ["Yagrush"] = "Mystic Boon",
    ["Laevateinn"] = "Vidohunir",
    ["Murgleis"] = "Death Blossom",
    ["Vajra"] = "Mandalic Stab",
    ["Burtgang"] = "Atonement",
    ["Liberator"] = "Insurgency",
    ["Aymur"] = "Primal Rend",
    ["Carnwenhan"] = "Mordant Rime",
    ["Gastraphetes"] = "Trueflight",
    ["Kogarasumaru"] = "Tachi: Rana",
    ["Nagi"] = "Blade: Kamu",
    ["Ryunohige"] = "Drakesbane",
    ["Nirvana"] = "Garland of Bliss",
    ["Tizona"] = "Expiacion",
    ["Death Penalty"] = "Leaden Salute",
    ["Kenkonken"] = "Stringing Pummel",
    ["Terpsichore"] = "Pyrrhic Kleos",
    ["Tupsimati"] = "Omniscience",
    ["Idris"] = "Exudation",
    ["Epeolatry"] = "Dimidiation"}
data.weaponskills.empyrean = {
    ["Verethragna"] = "Victory Smite",
    ["Twashtar"] = "Rudra's Storm",
    ["Almace"] = "Chant du Cygne",
    ["Caladbolg"] = "Torcleaver",
    ["Farsha"] = "Cloudsplitter",
    ["Ukonvasara"] = "Ukko's Fury",
    ["Redemption"] = "Quietus",
    ["Rhongomiant"] = "Camlann's Torment",
    ["Kannagi"] = "Blade: Hi",
    ["Masamune"] = "Tachi: Fudo",
    ["Gambanteinn"] = "Dagann",
    ["Hvergelmir"] = "Myrkr",
    ["Gandiva"] = "Jishnu's Radiance",
    ["Armageddon"] = "Wildfire"}

-- Weaponskills that can be used at range.
data.weaponskills.ranged = S{"Flaming Arrow", "Piercing Arrow", "Dulling Arrow", "Sidewinder", "Arching Arrow",
    "Empyreal Arrow", "Refulgent Arrow", "Apex Arrow", "Namas Arrow", "Jishnu's Radiance",
    "Hot Shot", "Split Shot", "Sniper Shot", "Slug Shot", "Heavy Shot", "Detonator", "Last Stand",
    "Coronach", "Trueflight", "Leaden Salute", "Wildfire",
    "Myrkr"}

ranged_weaponskills = data.weaponskills.ranged

-------------------------------------------------------------------------------------------------------------------
-- Spell mappings allow defining a general category or description that each of sets of related
-- spells all fall under.
-------------------------------------------------------------------------------------------------------------------

spell_maps = {
    ['Cure']='Cure',['Cure II']='Cure',['Cure III']='Cure',['Cure IV']='Cure',['Cure V']='Cure',['Cure VI']='Cure',
    ['Full Cure']='Cure',
    ['Cura']='Curaga',['Cura II']='Curaga',['Cura III']='Curaga',
    ['Curaga']='Curaga',['Curaga II']='Curaga',['Curaga III']='Curaga',['Curaga IV']='Curaga',['Curaga V']='Curaga',
    -- Status Removal doesn't include Esuna or Sacrifice, since they work differently than the rest
    ['Poisona']='StatusRemoval',['Paralyna']='StatusRemoval',['Silena']='StatusRemoval',['Blindna']='StatusRemoval',['Cursna']='StatusRemoval',
    ['Stona']='StatusRemoval',['Viruna']='StatusRemoval',['Erase']='StatusRemoval',
    ['Barfire']='BarElement',['Barstone']='BarElement',['Barwater']='BarElement',['Baraero']='BarElement',['Barblizzard']='BarElement',['Barthunder']='BarElement',
    ['Barfira']='BarElement',['Barstonra']='BarElement',['Barwatera']='BarElement',['Baraera']='BarElement',['Barblizzara']='BarElement',['Barthundra']='BarElement',
    ['Baramnesia']='BarStatus',['Barvirus']='BarStatus',['Barparalyze']='BarStatus',['Barsilence']='BarStatus',['Barpetrify']='BarStatus',['Barpoison']='BarStatus',['Barblind']='BarStatus',['Barsleep']='BarStatus',
    ['Baramnesra']='BarStatus',['Barvira']='BarStatus',['Barparalyzra']='BarStatus',['Barsilencera']='BarStatus',['Barpetra']='BarStatus',['Barpoisonra']='BarStatus',['Barblindra']='BarStatus',['Barsleepra']='BarStatus',
    ['Enfire']='EnSpell',['Enblizzard']='EnSpell',['Enaero']='EnSpell',['Enstone']='EnSpell',['Enthunder']='EnSpell',['Enwater']='EnSpell',
    ['Enfire II']='EnSpell',['Enblizzard II']='EnSpell',['Enaero II']='EnSpell',['Enstone II']='EnSpell',['Enthunder II']='EnSpell',['Enwater II']='EnSpell',
    ['Boost-STR']='StatBoost',['Boost-DEX']='StatBoost',['Boost-VIT']='StatBoost',['Boost-AGI']='StatBoost',['Boost-INT']='StatBoost',['Boost-MND']='StatBoost',['Boost-CHR']='StatBoost',
    ['Gain-STR']='StatBoost',['Gain-DEX']='StatBoost',['Gain-VIT']='StatBoost',['Gain-AGI']='StatBoost',['Gain-INT']='StatBoost',['Gain-MND']='StatBoost',['Gain-CHR']='StatBoost',
    ['Raise']='Raise',['Raise II']='Raise',['Raise III']='Raise',['Arise']='Raise',
    ['Reraise']='Reraise',['Reraise II']='Reraise',['Reraise III']='Reraise',['Reraise IV']='Reraise',
    ['Protect']='Protect',['Protect II']='Protect',['Protect III']='Protect',['Protect IV']='Protect',['Protect V']='Protect',
    ['Shell']='Shell',['Shell II']='Shell',['Shell III']='Shell',['Shell IV']='Shell',['Shell V']='Shell',
    ['Protectra']='Protectra',['Protectra II']='Protectra',['Protectra III']='Protectra',['Protectra IV']='Protectra',['Protectra V']='Protectra',
    ['Shellra']='Shellra',['Shellra II']='Shellra',['Shellra III']='Shellra',['Shellra IV']='Shellra',['Shellra V']='Shellra',
    ['Regen']='Regen',['Regen II']='Regen',['Regen III']='Regen',['Regen IV']='Regen',['Regen V']='Regen',
    ['Haste']='Haste',['Haste II']='Haste',
    ['Refresh']='Refresh',['Refresh II']='Refresh',['Refresh III']='Refresh',
    ['Teleport-Holla']='Teleport',['Teleport-Dem']='Teleport',['Teleport-Mea']='Teleport',['Teleport-Altep']='Teleport',['Teleport-Yhoat']='Teleport',
    ['Teleport-Vahzl']='Teleport',['Recall-Pashh']='Teleport',['Recall-Meriph']='Teleport',['Recall-Jugner']='Teleport',
    ['Valor Minuet']='Minuet',['Valor Minuet II']='Minuet',['Valor Minuet III']='Minuet',['Valor Minuet IV']='Minuet',['Valor Minuet V']='Minuet',
    ["Knight's Minne"]='Minne',["Knight's Minne II"]='Minne',["Knight's Minne III"]='Minne',["Knight's Minne IV"]='Minne',["Knight's Minne V"]='Minne',
    ['Advancing March']='March',['Victory March']='March',['Honor March']='March',
    ['Sword Madrigal']='Madrigal',['Blade Madrigal']='Madrigal',
    ["Hunter's Prelude"]='Prelude',["Archer's Prelude"]='Prelude',
    ['Sheepfoe Mambo']='Mambo',['Dragonfoe Mambo']='Mambo',
    ['Raptor Mazurka']='Mazurka',['Chocobo Mazurka']='Mazurka',
    ['Sinewy Etude']='Etude',['Dextrous Etude']='Etude',['Vivacious Etude']='Etude',['Quick Etude']='Etude',['Learned Etude']='Etude',['Spirited Etude']='Etude',['Enchanting Etude']='Etude',
    ['Herculean Etude']='Etude',['Uncanny Etude']='Etude',['Vital Etude']='Etude',['Swift Etude']='Etude',['Sage Etude']='Etude',['Logical Etude']='Etude',['Bewitching Etude']='Etude',
    ["Mage's Ballad"]='Ballad',["Mage's Ballad II"]='Ballad',["Mage's Ballad III"]='Ballad',
    ["Army's Paeon"]='Paeon',["Army's Paeon II"]='Paeon',["Army's Paeon III"]='Paeon',["Army's Paeon IV"]='Paeon',["Army's Paeon V"]='Paeon',["Army's Paeon VI"]='Paeon',
    ['Fire Carol']='Carol',['Ice Carol']='Carol',['Wind Carol']='Carol',['Earth Carol']='Carol',['Lightning Carol']='Carol',['Water Carol']='Carol',['Light Carol']='Carol',['Dark Carol']='Carol',
    ['Fire Carol II']='Carol',['Ice Carol II']='Carol',['Wind Carol II']='Carol',['Earth Carol II']='Carol',['Lightning Carol II']='Carol',['Water Carol II']='Carol',['Light Carol II']='Carol',['Dark Carol II']='Carol',
    ['Foe Lullaby']='Lullaby',['Foe Lullaby II']='Lullaby',['Horde Lullaby']='Lullaby',['Horde Lullaby II']='Lullaby',
    ['Fire Threnody']='Threnody',['Ice Threnody']='Threnody',['Wind Threnody']='Threnody',['Earth Threnody']='Threnody',['Ltng. Threnody']='Threnody',['Water Threnody']='Threnody',['Light Threnody']='Threnody',['Dark Threnody']='Threnody',
    ['Fire Threnody II']='Threnody',['Ice Threnody II']='Threnody',['Wind Threnody II']='Threnody',['Earth Threnody II']='Threnody',['Ltng. Threnody II']='Threnody',['Water Threnody II']='Threnody',['Light Threnody II']='Threnody',['Dark Threnody II']='Threnody',
    ['Battlefield Elegy']='Elegy',['Carnage Elegy']='Elegy',
    ['Foe Requiem']='Requiem',['Foe Requiem II']='Requiem',['Foe Requiem III']='Requiem',['Foe Requiem IV']='Requiem',['Foe Requiem V']='Requiem',['Foe Requiem VI']='Requiem',['Foe Requiem VII']='Requiem',
    ['Utsusemi: Ichi']='Utsusemi',['Utsusemi: Ni']='Utsusemi',['Utsusemi: San']='Utsusemi',
    ['Katon: Ichi'] = 'ElementalNinjutsu',['Suiton: Ichi'] = 'ElementalNinjutsu',['Raiton: Ichi'] = 'ElementalNinjutsu',
    ['Doton: Ichi'] = 'ElementalNinjutsu',['Huton: Ichi'] = 'ElementalNinjutsu',['Hyoton: Ichi'] = 'ElementalNinjutsu',
    ['Katon: Ni'] = 'ElementalNinjutsu',['Suiton: Ni'] = 'ElementalNinjutsu',['Raiton: Ni'] = 'ElementalNinjutsu',
    ['Doton: Ni'] = 'ElementalNinjutsu',['Huton: Ni'] = 'ElementalNinjutsu',['Hyoton: Ni'] = 'ElementalNinjutsu',
    ['Katon: San'] = 'ElementalNinjutsu',['Suiton: San'] = 'ElementalNinjutsu',['Raiton: San'] = 'ElementalNinjutsu',
    ['Doton: San'] = 'ElementalNinjutsu',['Huton: San'] = 'ElementalNinjutsu',['Hyoton: San'] = 'ElementalNinjutsu',
    ['Kurayami: Ichi'] = 'EnfeeblingNinjutsu', ['Kurayami: Ni'] = 'EnfeeblingNinjutsu',
    ['Hojo: Ichi'] = 'EnfeeblingNinjutsu', ['Hojo: Ni'] = 'EnfeeblingNinjutsu',
    ['Jubaku: Ichi'] = 'EnfeeblingNinjutsu', ['Dokumori: Ni'] = 'EnfeeblingNinjutsu',
    ['Aisha: Ichi'] = 'EnfeeblingNinjutsu', ['Yurin: Ni'] = 'EnfeeblingNinjutsu',
    ['Banish']='Banish',['Banish II']='Banish',['Banish III']='Banish',['Banishga']='Banish',['Banishga II']='Banish',
    ['Holy']='Holy',['Holy II']='Holy',
    ['Dia']='Dia',['Dia II']='Dia',['Dia III']='Dia',['Diaga']='Dia',
    ['Bio']='Bio',['Bio II']='Bio',['Bio III']='Bio',
    ['Drain']='Drain',['Drain II']='Drain',['Drain III']='Drain',
    ['Aspir']='Aspir',['Aspir II']='Aspir',['Aspir III']='Aspir',
    ['Sleep']='Sleep',['Sleep II']='Sleep',['Sleepga']='Sleep',['Sleepga II']='Sleep',
    ['Break']='Break',['Breakga']='Break',
    ['Gravity']='Gravity',['Gravity II']='Gravity',
    ['Absorb-STR']='Absorb',['Absorb-DEX']='Absorb',['Absorb-VIT']='Absorb',['Absorb-AGI']='Absorb',['Absorb-INT']='Absorb',['Absorb-MND']='Absorb',['Absorb-CHR']='Absorb',
    ['Absorb-ACC']='Absorb',['Absorb-TP']='Absorb',['Absorb-Attri']='Absorb',
    ['Enlight']='Enlight',['Enlight II']='Enlight',['Endark']='Endark',['Endark II']='Endark',
    ['Burn']='ElementalEnfeeble',['Frost']='ElementalEnfeeble',['Choke']='ElementalEnfeeble',['Rasp']='ElementalEnfeeble',['Shock']='ElementalEnfeeble',['Drown']='ElementalEnfeeble',
    ['Pyrohelix']='Helix',['Cryohelix']='Helix',['Anemohelix']='Helix',['Geohelix']='Helix',['Ionohelix']='Helix',['Hydrohelix']='Helix',['Luminohelix']='Helix',['Noctohelix']='Helix',
	['Pyrohelix II']='Helix',['Cryohelix II']='Helix',['Anemohelix II']='Helix',['Geohelix II']='Helix',['Ionohelix II']='Helix',['Hydrohelix II']='Helix',['Luminohelix II']='Helix',['Noctohelix II']='Helix',
    ['Firestorm']='Storm',['Hailstorm']='Storm',['Windstorm']='Storm',['Sandstorm']='Storm',['Thunderstorm']='Storm',['Rainstorm']='Storm',['Aurorastorm']='Storm',['Voidstorm']='Storm',
	['Firestorm II']='Storm',['Hailstorm II']='Storm',['Windstorm II']='Storm',['Sandstorm II']='Storm',['Thunderstorm II']='Storm',['Rainstorm II']='Storm',['Aurorastorm II']='Storm',['Voidstorm II']='Storm',
    ['Stonera']='GeoNuke', ['Stonera II']='GeoNuke', ['Stonera III']='GeoNuke',
    ['Watera']='GeoNuke',  ['Watera II']='GeoNuke',  ['Watera III']='GeoNuke',
    ['Aera']='GeoNuke',    ['Aera II']='GeoNuke',    ['Aera III']='GeoNuke',
    ['Fira']='GeoNuke',    ['Fira II']='GeoNuke',    ['Fira III']='GeoNuke',
    ['Blizzara']='GeoNuke',['Blizzara II']='GeoNuke',['Blizzara III']='GeoNuke',
    ['Thundara']='GeoNuke',['Thundara II']='GeoNuke',['Thundara III']='GeoNuke',
    ['Fire Maneuver']='Maneuver',['Ice Maneuver']='Maneuver',['Wind Maneuver']='Maneuver',['Earth Maneuver']='Maneuver',['Thunder Maneuver']='Maneuver',
    ['Water Maneuver']='Maneuver',['Light Maneuver']='Maneuver',['Dark Maneuver']='Maneuver',
}

no_skill_spells_list = S{'Haste', 'Refresh', 'Regen', 'Protect', 'Protectra', 'Shell', 'Shellra',
        'Raise', 'Reraise', 'Sneak', 'Invisible', 'Deodorize'}


-------------------------------------------------------------------------------------------------------------------
-- Tables to specify general area groupings.  Creates the 'areas' table to be referenced in job files.
-- Zone names provided by world.area/world.zone are currently in all-caps, so defining the same way here.
-------------------------------------------------------------------------------------------------------------------

areas = {}

-- City areas for town gear and behavior.
areas.Cities = S{
    "Ru'Lude Gardens",
    "Upper Jeuno",
    "Lower Jeuno",
    "Port Jeuno",
    "Port Windurst",
    "Windurst Waters",
    "Windurst Woods",
    "Windurst Walls",
    "Heavens Tower",
    "Port San d'Oria",
    "Northern San d'Oria",
    "Southern San d'Oria",
    "Chateau d'Oraguille",
    "Port Bastok",
    "Bastok Markets",
    "Bastok Mines",
    "Metalworks",
    "Aht Urhgan Whitegate",
    "Tavnazian Safehold",
    "Nashmau",
    "Selbina",
    "Mhaura",
    "Rabao",
    "Norg",
    "Eastern Adoulin",
    "Western Adoulin",
    "Celennia Memorial Library",
    "Mog Garden",
    "Kazham"
}
-- Adoulin areas, where Ionis will grant special stat bonuses.
areas.Adoulin = S{
    "Yahse Hunting Grounds",
    "Ceizak Battlegrounds",
    "Foret de Hennetiel",
    "Morimar Basalt Fields",
    "Yorcia Weald",
    "Yorcia Weald [U]",
    "Cirdas Caverns",
    "Cirdas Caverns [U]",
    "Marjami Ravine",
    "Kamihr Drifts",
    "Sih Gates",
    "Moh Gates",
    "Dho Gates",
    "Woh Gates",
    "Rala Waterways",
    "Rala Waterways [U]",
    "Outer Ra'Kaznar",
    "Outer Ra'Kaznar [U]"
}


-------------------------------------------------------------------------------------------------------------------
-- Lists of certain NPCs. (Not up to date)
-------------------------------------------------------------------------------------------------------------------

npcs = {}
npcs.Trust = S{
'Adelheid',
'Ajido-Marujido',
'Aldo',
'Amchuchu',
'Apururu',
'Arciela',
'ArkEV',
'ArkGK',
'ArkHM',
'ArkMR',
'ArkTT',
'August',
'Ayame',
'BabbanMheillea',
'Balamor',
'Chacharoon',
'Cherukiki',
'Curilla',
'D.Shantotto',
'Elivira',
'Excenmille',
'FerreousCoffin',
'Gadalar',
'Gessho',
'Gilgamesh',
'Halver',
'Ingrid',
'Iroha',
'IronEater',
'Joachim',
'Karaha-Baruha',
'Kayeel-Payeel',
'KingOfHearts',
'Klara',
'Koru-Moru',
'Kukki-Chebukki',
'Kupipi',
'Leonoyne',
'LhuMhakaracca',
'Lilisette',
'Lion',
'Luzaf',
'Maat',
'Maximilian',
'Mayakov',
'MihliAliapoh',
'Mnejing',
'Monberaux',
'Moogle',
'Mumor',
'Najelith',
'Naji',
'NajaSalaheem',
'NanaaMihgo',
'Nashmeira',
'Noillurie',
'Ovjang',
'Prishe',
'Qultada',
'Rainemard',
'Robel-Akbel',
'RomaaMihgo',
'Rosulatia',
'Sakura',
'Selh\'teus',
'SemihLafihna',
'Shantotto',
'ShikareeZ',
'StarSibyl',
'Sylvie',
'Tenzen',
'Teodor',
'Trion',
'UkaTotlihn',
'Ulmia',
'Ullegore',
'Valaineral',
'Ygnas',
'Yoran-Oran',
'Zazarg',
'Zeid'
}
