extends Node

var tutorial_complete = false
var supporter = false
var nopop_limit = false
var location = 'wimborn'
var condition = 85 setget cond_set
var condition_mod = 1.3
var spec = ''
var farm = 0 
var apiary = 0
var branding = 0
var slave_guild_visited = 0
var umbra_first_visit = true
var item_list = {}
var spell_list = {}
var main_quest = 0
var main_quest_complete = false
var rank = 0
var password = ''
var sidequests = {
    startslave = 0, emily = 0, brothel = 0, cali = 0, caliparentsdead = false, chloe = 0, ayda = 0, ivran = '', yris = 0, zoe = 0, ayneris = 0, sebastianumbra = 0, maple = 0
} setget quest_set
var repeatables = {
    wimbornslaveguild = [],
    frostfordslaveguild = [],
    gornslaveguild = []
}
var baby_list = []
var companion = -1
var headgirl_behavior = 'none'
var portals = {
    wimborn = {
        'enabled': false, 'code': 'wimborn'
    }, 
    gorn = {
        'enabled': false, 'code': 'gorn'
    },
    frostford = {
        'enabled': false, 'code': 'frostford'
    },
    amberguard = {
        'enabled': false, 'code': 'amberguard'
    }, 
    umbra = {
        'enabled': false, 'code': 'umbra'
    }
}
var sebastian_order = {
    race = 'none', 
    taken = false, 
    duration = 0
}
var sebastian_slave
var sandbox = false
var snails = 0
var groupsex = true
var playergroup = []
var timedevents = {}
var custom_cursor = "res://files/buttons/kursor1.png"
var upcoming_events = []
var reputation = { wimborn = 0, frostford = 0, gorn = 0, amberguard = 0 } setget reputation_set
var daily_event_countdown = 0
var daily_event_previous = 0
var current_version = 5000
var unstackables = {}
var supply_keep = 10
var food_buy = 200
var supply_buy = false
var tutorial = {basics = false, person = false, alchemy = false, jail = false, lab = false, farm = false, outside = false, combat = false, interactions = false}
var item_counter = 0
var slave_counter = 0
var alise_cloth = 'normal'
var decisions = []
var lorefound = []
var relatives_data = {}
var descript_settings = {full = true, basic = true, appearance = true, genitals = true, piercing = true, tattoo = true, mods = true}
var mansion_upgrades = {
    farm_capacity = 0,
    farm_hatchery = 0,
    farm_treatment = 0,
    food_capacity = 0,
    food_preservation = 0,
    jail_capacity = 1,
    jail_treatment = 0,
    jail_incenses = 0,
    mansion_communal = 4,
    mansion_personal = 1,
    mansion_bed = 0,
    mansion_luxury = 0,
    mansion_alchemy = 0,
    mansion_library = 0,
    mansion_lab = 0,
    mansion_kennels = 0,
    mansion_nursery = 0,
    mansion_parlor = 0,
}
var plot_sceneseen = []
var captured_group = []
var ghost_rep = {wimborn = 0, frostford = 0, gorn = 0, amberguard = 0}
var backpack = {stackables = {}, unstackables = []} setget backpack_set
var restday = 0
var default_masternoun = "Master"
var sex_actions = 1
var nonsex_actions = 1
var action_blacklist = []