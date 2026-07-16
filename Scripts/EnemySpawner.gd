extends Node3D

@export var enemy_scene: PackedScene
@export var spawn_height: float = 5.0  
@export var spawn_stagger: float = 0.15
@export var raycast_start_height: float = 30.0
var boss_pools = {
	"Heaven":  preload("res://Enemies/Archangel.tscn"),
	"Astral":  preload("res://Enemies/VoidLord.tscn"),
	"Human":   preload("res://Enemies/Warlord.tscn"),
	"Serpent": preload("res://Enemies/SerpentKing.tscn"),
	"Hell":    preload("res://Enemies/DevilKing.tscn"),
}

var world_enemy_pools = {
	"Heaven":  [BaseEnemy.EnemyType.ANGEL],
	"Astral":  [BaseEnemy.EnemyType.ASTRALWRAITH],
	"Human":   [BaseEnemy.EnemyType.SOLDIER],
	"Serpent": [BaseEnemy.EnemyType.SERPENTWARRIOR, BaseEnemy.EnemyType.VENOMBEAST],
	"Hell":    [BaseEnemy.EnemyType.DEMON, BaseEnemy.EnemyType.GOLEM],
}

func get_enemy_count() -> int:
	var base = 4 + CampaignManager.current_world_index * 2
	var wave_bonus = int(CampaignManager.current_wave * 0.5)
	return min(base + wave_bonus, 20)

func _ready() -> void:
	await get_tree().process_frame
	CampaignManager.roll_mission_type()
	CampaignManager.save_checkpoint()
	var player = get_tree().get_first_node_in_group("player")
	var level_manager = get_tree().get_first_node_in_group("level_manager")
	if level_manager and player:
		level_manager.start_mission_tracking(player.global_position)
	match CampaignManager.current_mission_type:
		CampaignManager.MissionType.DESTROY_GENERATORS:
			_spawn_generators()
		CampaignManager.MissionType.RESCUE_SURVIVOR:
			_spawn_survivor()
	call_deferred("spawn_wave")

func _spawn_generators() -> void:
	var level_manager = get_tree().get_first_node_in_group("level_manager")
	var count := 3
	if level_manager:
		level_manager.generators_total = count
	for i in range(count):
		var angle := (float(i) / count) * TAU + randf_range(-0.2, 0.2)
		var pos := _pick_spawn_position(angle, randf_range(6.0, 14.0))
		pos.y -= 1.6
		var gen := MissionGenerator.new()
		get_tree().current_scene.add_child(gen)
		gen.global_position = pos

func _spawn_survivor() -> void:
	var angle := randf() * TAU
	var pos := _pick_spawn_position(angle, randf_range(10.0, 18.0))
	pos.y -= 1.6
	var survivor := SurvivorMarker.new()
	get_tree().current_scene.add_child(survivor)
	survivor.global_position = pos

func spawn_wave() -> void:
	if CampaignManager.is_boss_wave():
		spawn_boss()
	elif CampaignManager.is_arcade_miniboss_wave():
		spawn_boss(true)
	else:
		spawn_normal_wave()
		
func _snap_to_terrain(xz_position: Vector3) -> Vector3:
	var space_state = get_world_3d().direct_space_state
	var from = xz_position + Vector3(0, raycast_start_height, 0)
	var to = xz_position + Vector3(0, -raycast_start_height, 0)
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	if result:
		return result.position + Vector3(0, 1.6, 0)
	return xz_position + Vector3(0, spawn_height, 0)


func _overlaps_solid(position: Vector3) -> bool:
	var space_state = get_world_3d().direct_space_state
	var shape := SphereShape3D.new()
	shape.radius = 0.5
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = Transform3D(Basis(), position)
	query.collide_with_bodies = true
	return space_state.intersect_shape(query, 1).size() > 0

func _pick_spawn_position(angle: float, dist: float) -> Vector3:
	var xz_target = global_position + Vector3(cos(angle) * dist, 0, sin(angle) * dist)
	var candidate = _snap_to_terrain(xz_target)
	var attempts = 0
	while _overlaps_solid(candidate) and attempts < 4:
		dist += 2.0
		xz_target = global_position + Vector3(cos(angle) * dist, 0, sin(angle) * dist)
		candidate = _snap_to_terrain(xz_target)
		attempts += 1
	return candidate

func spawn_normal_wave() -> void:
	if not enemy_scene:
		push_error("EnemySpawner: enemy_scene not set!")
		return

	var count = get_enemy_count()
	var level_manager = get_tree().get_first_node_in_group("level_manager")
	if level_manager:
		level_manager.register_pending(count)

	var pool: Array = world_enemy_pools.get(CampaignManager.get_current_world(), [BaseEnemy.EnemyType.SOLDIER])

	for i in range(count):
		var enemy: BaseEnemy = enemy_scene.instantiate()
		enemy.skip_auto_register = true
		enemy.enemy_type = pool[randi() % pool.size()]
		if i == 0 and CampaignManager.current_mission_type == CampaignManager.MissionType.BONUS_TARGET:
			enemy.is_bonus_target = true

		var angle = (float(i) / count) * TAU + randf_range(-0.3, 0.3)
		var dist = randf_range(8.0, 20.0)
		var target_pos = _pick_spawn_position(angle, dist)

		get_tree().current_scene.add_child(enemy)
		enemy.global_position = target_pos
		enemy.force_update_transform()

		if spawn_stagger > 0.0:
			await get_tree().create_timer(spawn_stagger).timeout

func spawn_boss(is_mini: bool = false) -> void:
	var world = CampaignManager.get_current_world()
	if not boss_pools.has(world):
		push_error("No boss defined for world: " + world)
		return

	var boss: BaseEnemy = boss_pools[world].instantiate()
	if is_mini:
		boss.boss_health_multiplier *= 0.5
		boss.boss_damage_multiplier *= 0.7
		boss.boss_scale_multiplier = max(boss.boss_scale_multiplier * 0.8, 1.4)
	var target_pos = _pick_spawn_position(deg_to_rad(-90), 15.0)

	get_tree().current_scene.add_child(boss)
	boss.global_position = target_pos
	boss.force_update_transform()

	print("Boss spawned for world: ", world, " mini=", is_mini)
