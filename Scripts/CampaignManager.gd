extends Node

const SAVE_PATH := "user://savegame.cfg"

func _ready() -> void:
	load_game()

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func save_game() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "max_health", max_health)
	cfg.set_value("progress", "spear_damage", spear_damage)
	cfg.set_value("progress", "movement_speed", movement_speed)
	cfg.set_value("progress", "upgrade_points", upgrade_points)
	cfg.set_value("progress", "current_wave", current_wave)
	cfg.set_value("progress", "current_world_index", current_world_index)
	cfg.set_value("progress", "health_upgrade_cost", health_upgrade_cost)
	cfg.set_value("progress", "damage_upgrade_cost", damage_upgrade_cost)
	cfg.set_value("progress", "speed_upgrade_cost", speed_upgrade_cost)
	cfg.set_value("progress", "cooldown_upgrade_cost", cooldown_upgrade_cost)
	cfg.set_value("progress", "pierce_upgrade_cost", pierce_upgrade_cost)
	cfg.set_value("progress", "spear_cooldown_mult", spear_cooldown_mult)
	cfg.set_value("progress", "spear_pierce_unlocked", spear_pierce_unlocked)
	cfg.set_value("progress", "intro_shown", intro_shown)
	cfg.set_value("stats", "arcade_high_score", arcade_high_score)
	var err := cfg.save(SAVE_PATH)
	if err != OK:
		push_warning("CampaignManager: failed to save game (%s)" % err)

func load_game() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return 
	max_health = cfg.get_value("progress", "max_health", max_health)
	spear_damage = cfg.get_value("progress", "spear_damage", spear_damage)
	movement_speed = cfg.get_value("progress", "movement_speed", movement_speed)
	upgrade_points = cfg.get_value("progress", "upgrade_points", upgrade_points)
	current_wave = cfg.get_value("progress", "current_wave", current_wave)
	current_world_index = cfg.get_value("progress", "current_world_index", current_world_index)
	health_upgrade_cost = cfg.get_value("progress", "health_upgrade_cost", health_upgrade_cost)
	damage_upgrade_cost = cfg.get_value("progress", "damage_upgrade_cost", damage_upgrade_cost)
	speed_upgrade_cost = cfg.get_value("progress", "speed_upgrade_cost", speed_upgrade_cost)
	cooldown_upgrade_cost = cfg.get_value("progress", "cooldown_upgrade_cost", cooldown_upgrade_cost)
	pierce_upgrade_cost = cfg.get_value("progress", "pierce_upgrade_cost", pierce_upgrade_cost)
	spear_cooldown_mult = cfg.get_value("progress", "spear_cooldown_mult", spear_cooldown_mult)
	spear_pierce_unlocked = cfg.get_value("progress", "spear_pierce_unlocked", spear_pierce_unlocked)
	intro_shown = cfg.get_value("progress", "intro_shown", intro_shown)
	arcade_high_score = cfg.get_value("stats", "arcade_high_score", arcade_high_score)
	checkpoint_wave = current_wave
	checkpoint_world_index = current_world_index

enum MissionType { STANDARD, HOLD_POSITION, BONUS_TARGET, DESTROY_GENERATORS, RESCUE_SURVIVOR }
var current_mission_type: MissionType = MissionType.STANDARD

var checkpoint_wave: int = 1
var checkpoint_world_index: int = 0

var last_wave_kills: int = 0

var max_health: int = 100
var spear_damage: int = 25
var movement_speed: float = 8.0

var upgrade_points: int = 0

var current_wave: int = 1
var current_world_index: int = 0
var waves_per_world: int = 10

var health_upgrade_cost: int = 1
var damage_upgrade_cost: int = 1
var speed_upgrade_cost: int = 1
var cooldown_upgrade_cost: int = 2
var pierce_upgrade_cost: int = 5

var spear_cooldown_mult: float = 1.0
var spear_pierce_unlocked: bool = false
var spear_pierce_charges: int = 2 

var is_arcade_mode: bool = false
var arcade_wave: int = 1
var arcade_loops: int = 0 
var arcade_score: int = 0
var arcade_high_score: int = 0
var arcade_modifiers: Array[String] = []
const ARCADE_ALL_MODIFIERS: Array[String] = ["double_speed", "exploding_enemies", "low_gravity", "elite_enemies", "darkness", "rapid_throw"]

var intro_shown: bool = false

var worlds: Array[String] = [
	"Heaven",
	"Astral",
	"Human",
	"Serpent",
	"Hell"
]

var boss_cutscenes: Array[String] = [
	"res://Scenes/CutsceneHeavenBoss.tscn",
	"res://Scenes/CutsceneAstralBoss.tscn",
	"res://Scenes/CutsceneHumanBoss.tscn",
	"res://Scenes/CutsceneSerpentBoss.tscn",
	"res://Scenes/CutsceneEnding.tscn",
]

var world_rewards = {
	0: 1,
	1: 2,
	2: 3,
	3: 4,
	4: 5 
}

func complete_wave() -> void:
	if is_arcade_mode:
		call_deferred("_do_arcade_next_wave")
		return
	call_deferred("_do_complete_wave")

func _do_complete_wave() -> void:
	upgrade_points += world_rewards[current_world_index]
	current_wave += 1

	if current_wave > waves_per_world:
		current_wave = 1
		current_world_index += 1

		if current_world_index >= worlds.size():
			get_tree().call_deferred("change_scene_to_file", "res://Scenes/CutsceneEnding.tscn")
			return

	get_tree().call_deferred("change_scene_to_file", "res://Scenes/UpgradeMenu.tscn")

func get_current_world() -> String:
	if is_arcade_mode:
		return worlds[arcade_loops % worlds.size()]
	return worlds[current_world_index]

func is_boss_wave() -> bool:
	if is_arcade_mode:
		var cycle_pos := (arcade_wave - 1) % 7
		return cycle_pos == 6 
	return current_wave >= 10

func is_arcade_miniboss_wave() -> bool:
	return is_arcade_mode and ((arcade_wave - 1) % 7) == 3

func save_checkpoint() -> void:
	checkpoint_wave = current_wave
	checkpoint_world_index = current_world_index
	save_game()

func load_checkpoint() -> void:
	current_wave = checkpoint_wave
	current_world_index = checkpoint_world_index

func roll_mission_type() -> void:
	if is_boss_wave():
		current_mission_type = MissionType.STANDARD
		return
	var r := randf()
	if r < 0.45:
		current_mission_type = MissionType.STANDARD
	elif r < 0.6:
		current_mission_type = MissionType.HOLD_POSITION
	elif r < 0.75:
		current_mission_type = MissionType.BONUS_TARGET
	elif r < 0.9:
		current_mission_type = MissionType.DESTROY_GENERATORS
	else:
		current_mission_type = MissionType.RESCUE_SURVIVOR

func start_arcade() -> void:
	reset()
	is_arcade_mode = true
	arcade_wave = 1
	arcade_loops = 0
	arcade_score = 0
	arcade_modifiers.clear()
	intro_shown = true

func has_modifier(mod_name: String) -> bool:
	return is_arcade_mode and arcade_modifiers.has(mod_name)

func arcade_hp_mult() -> float:
	return 1.0 + 0.08 * float(arcade_wave - 1)

func arcade_dmg_mult() -> float:
	return 1.0 + 0.05 * float(arcade_wave - 1)

func arcade_speed_mult() -> float:
	return 1.0 + 0.02 * float(arcade_wave - 1)

func _do_arcade_next_wave() -> void:
	arcade_score += 10 * arcade_wave
	upgrade_points += 1
	arcade_wave += 1
	arcade_loops = (arcade_wave - 1) / 7

	if arcade_wave > 20 and arcade_modifiers.size() < 2 and randf() < 0.3:
		var pool: Array[String] = []
		for m in ARCADE_ALL_MODIFIERS:
			if not arcade_modifiers.has(m):
				pool.append(m)
		if pool.size() > 0:
			arcade_modifiers.append(pool[randi() % pool.size()])

	if arcade_score > arcade_high_score:
		arcade_high_score = arcade_score
		save_game()

	get_tree().call_deferred("change_scene_to_file", "res://Scenes/UpgradeMenu.tscn")

func upgrade_cooldown() -> void:
	if upgrade_points >= cooldown_upgrade_cost:
		upgrade_points -= cooldown_upgrade_cost
		spear_cooldown_mult = max(spear_cooldown_mult * 0.9, 0.4)
		cooldown_upgrade_cost += 1

func upgrade_pierce() -> void:
	if not spear_pierce_unlocked and upgrade_points >= pierce_upgrade_cost:
		upgrade_points -= pierce_upgrade_cost
		spear_pierce_unlocked = true

func upgrade_health():
	if upgrade_points >= health_upgrade_cost:
		upgrade_points -= health_upgrade_cost
		max_health += 20
		health_upgrade_cost += 1

func upgrade_damage():
	if upgrade_points >= damage_upgrade_cost:
		upgrade_points -= damage_upgrade_cost
		spear_damage += 10
		damage_upgrade_cost += 1

func upgrade_speed():
	if upgrade_points >= speed_upgrade_cost:
		upgrade_points -= speed_upgrade_cost
		movement_speed += 1.0
		speed_upgrade_cost += 1

func go_to_next_world() -> void:
	if is_arcade_mode:
		call_deferred("_do_arcade_next_wave")
		return

	upgrade_points += world_rewards[current_world_index] * 2
	
	var cutscene = boss_cutscenes[current_world_index]

	current_wave = 1
	current_world_index += 1

	get_tree().call_deferred("change_scene_to_file", cutscene)

func reset() -> void:
	max_health = 100
	spear_damage = 25
	movement_speed = 8.0
	upgrade_points = 0
	current_wave = 1
	current_world_index = 0
	health_upgrade_cost = 1
	damage_upgrade_cost = 1
	speed_upgrade_cost = 1
	cooldown_upgrade_cost = 2
	pierce_upgrade_cost = 5
	spear_cooldown_mult = 1.0
	spear_pierce_unlocked = false
	last_wave_kills = 0
	current_mission_type = MissionType.STANDARD
	is_arcade_mode = false
	arcade_wave = 1
	arcade_loops = 0
	arcade_score = 0
	arcade_modifiers.clear()
