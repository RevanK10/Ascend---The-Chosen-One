extends Node

var total_enemies := 0
var alive_enemies := 0

var hold_origin: Vector3 = Vector3.ZERO
var hold_broken: bool = false
var mission_active: bool = false

var generators_total: int = 0
var generators_destroyed: int = 0
var survivor_rescued_flag: bool = false

func start_mission_tracking(player_pos: Vector3) -> void:
	hold_origin = player_pos
	hold_broken = false
	mission_active = true
	generators_total = 0
	generators_destroyed = 0
	survivor_rescued_flag = false

func generator_destroyed() -> void:
	generators_destroyed += 1

func survivor_rescued() -> void:
	survivor_rescued_flag = true

func _process(_delta: float) -> void:
	if not mission_active or CampaignManager.current_mission_type != CampaignManager.MissionType.HOLD_POSITION:
		return
	var player = get_tree().get_first_node_in_group("player")
	if player and player.global_position.distance_to(hold_origin) > 12.0:
		hold_broken = true

func register_enemy():
	total_enemies += 1
	alive_enemies += 1

func register_pending(count: int) -> void:
	total_enemies += count
	alive_enemies += count

func enemy_killed():
	alive_enemies -= 1
	print("Enemies left:", alive_enemies)

	if alive_enemies <= 0:
		level_complete()

func level_complete():
	mission_active = false
	CampaignManager.last_wave_kills = total_enemies
	match CampaignManager.current_mission_type:
		CampaignManager.MissionType.HOLD_POSITION:
			if not hold_broken:
				CampaignManager.upgrade_points += 2
		CampaignManager.MissionType.DESTROY_GENERATORS:
			if generators_total > 0 and generators_destroyed >= generators_total:
				CampaignManager.upgrade_points += 2
		CampaignManager.MissionType.RESCUE_SURVIVOR:
			if survivor_rescued_flag:
				CampaignManager.upgrade_points += 2

	if CampaignManager.is_boss_wave():
		CampaignManager.go_to_next_world()
	else:
		CampaignManager.complete_wave()
