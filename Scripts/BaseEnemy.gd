class_name BaseEnemy
extends CharacterBody3D

enum EnemyType { SOLDIER, THIEF, DEMON, GOLEM, ANGEL, ASTRALWRAITH, SERPENTWARRIOR, VENOMBEAST }
enum AnimState { IDLE, WALK, ATTACK, HIT, DEATH }

@export var enemy_type: EnemyType = EnemyType.SOLDIER
@export var max_health: int = 100
@export var move_speed: float = 4.0
@export var attack_damage: int = 10
@export var attack_cooldown: float = 1.5
@export var is_boss: bool = false
@export var is_demon_king: bool = false
@export var boss_display_name: String = "" 
@export var custom_mesh_scene: PackedScene = null 
@export var skip_auto_register: bool = false

@export_group("Audio (drag sound files in here - none are bundled)")
@export var hit_sound: AudioStream
@export var death_sound: AudioStream
@export var attack_sound: AudioStream

@onready var sfx_player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
var is_bonus_target: bool = false
var is_elite: bool = false
var has_detonated: bool = false

@export var boss_scale_multiplier: float = 2.0
@export var boss_health_multiplier: float = 3.0
@export var boss_damage_multiplier: float = 1.8
@export var boss_detection_multiplier: float = 1.6
@export var boss_kit: String = ""

const BaseEnemyScene := preload("res://Scenes/BaseEnemy.tscn")
const LootPickupScript := preload("res://Scripts/LootPickup.gd")

const ANGEL_MESH  := preload("res://Assets/Models/AngelEnemy.glb")
const ASTRAL_WRAITH_MESH    := preload("res://Assets/Models/AstralWraithEnemy.glb")
const DEMON_MESH    := preload("res://Assets/Models/DemonEnemy.glb")
const GOLEM_MESH    := preload("res://Assets/Models/ElementalGolemEnemy.glb")
const SERPENT_WARRIOR_MESH    := preload("res://Assets/Models/SerpentWarriorEnemy.glb")
const SOLDIER_MESH      := preload("res://Assets/Models/SoliderEnemy.glb")
const THIEF_MESH := preload("res://Assets/Models/ThiefEnemy.glb")
const VENOM_BEAST_MESH    := preload("res://Assets/VenomBeastEnemy.glb")

var is_enraged: bool = false
var boss_ability_cooldown: float = 0.0
var boss_ability_step: int = 0
var boss_buff_timer: float = 0.0
var boss_buff_speed_bonus: float = 0.0
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var attack_area: Area3D = $AttackArea
@onready var enemy_root: Node3D = $EnemyRoot
@onready var corruption_overlay: MeshInstance3D = $EnemyRoot/CorruptionOverlay

var mesh_body: MeshInstance3D = null
var head_node: Node3D = null
var arm_left: Node3D = null
var arm_right: Node3D = null

var current_health: int
var player: CharacterBody3D
var player_in_range: bool = false
var attack_timer: float = 0.0
var level_manager: Node = null

var knockback_velocity: Vector3 = Vector3.ZERO
var knockback_decay: float = 8.0

var anim_time: float = 0.0
var anim_state: AnimState = AnimState.IDLE
var death_anim_timer: float = 0.0
var is_dying: bool = false
var hit_flash_timer: float = 0.0
var attack_lunge_timer: float = 0.0

var body_color: Color = Color(0.2, 0.8, 0.9, 1)
var eye_color: Color = Color(1, 0.1, 0.1, 1)
var enemy_scale: float = 1.0

var nav_ready: bool = false
var nav_wait_timer: float = 0.0

var stuck_check_pos: Vector3 = Vector3.ZERO
var stuck_timer: float = 0.0
var unstuck_nudge: Vector3 = Vector3.ZERO
var unstuck_nudge_timer: float = 0.0

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as CharacterBody3D
	level_manager = get_tree().get_first_node_in_group("level_manager")
	add_child(sfx_player)

	mesh_body  = $EnemyRoot/MeshInstance3D if has_node("EnemyRoot/MeshInstance3D") else null
	head_node  = $EnemyRoot/Head if has_node("EnemyRoot/Head") else null
	arm_left   = $EnemyRoot/ArmLeft if has_node("EnemyRoot/ArmLeft") else null
	arm_right  = $EnemyRoot/ArmRight if has_node("EnemyRoot/ArmRight") else null

	configure_enemy()
	assign_enemy_mesh()

	add_to_group("enemy")

	if is_boss:
		add_to_group("boss_enemy")
		_scale_boss_collision()

	_apply_custom_mesh_if_present()
	apply_visuals()
	apply_corruption_overlay()

	attack_area.body_entered.connect(_on_attack_area_body_entered)
	attack_area.body_exited.connect(_on_attack_area_body_exited)

	if level_manager and not skip_auto_register:
		level_manager.register_enemy()

	current_health = max_health

	nav_agent.velocity_computed.connect(_on_nav_velocity_computed)
	nav_agent.max_speed = move_speed

	var body_shape := ($CollisionShape3D as CollisionShape3D).shape
	if body_shape is CapsuleShape3D:
		nav_agent.radius = (body_shape as CapsuleShape3D).radius * scale.x

	stuck_check_pos = global_position
	_init_nav_delayed()


func _init_nav_delayed() -> void:
	var elapsed := 0.0
	var timeout := 3.0
	while elapsed < timeout:
		await get_tree().physics_frame
		elapsed += get_physics_process_delta_time()
		var map := nav_agent.get_navigation_map()
		if NavigationServer3D.map_get_iteration_id(map) > 0:
			break
	nav_ready = true

func _on_nav_velocity_computed(safe_velocity: Vector3) -> void:
	velocity.x = safe_velocity.x + knockback_velocity.x
	velocity.z = safe_velocity.z + knockback_velocity.z


func _apply_custom_mesh_if_present() -> void:
	var custom: Node3D = null

	if custom_mesh_scene != null:
		custom = custom_mesh_scene.instantiate() as Node3D
		custom.name = "CustomMesh"
		enemy_root.add_child(custom)
	elif enemy_root.has_node("CustomMesh"):
		custom = enemy_root.get_node("CustomMesh") as Node3D

	if custom == null:
		return

	for child_path in [
		"MeshInstance3D",
		"Head",
		"ArmLeft",
		"ArmRight",
		"LegLeft",
		"LegRight"
	]:
		var n = enemy_root.get_node_or_null(child_path)
		if n:
			n.visible = false

	var mi := _find_first_mesh_instance(custom)
	if mi == null:
		return

	var collision := $CollisionShape3D.shape as CapsuleShape3D
	if collision == null:
		return

	var aabb := mi.get_aabb()
	
	var true_mesh_scale = mi.scale
	var mesh_width = max(aabb.size.x * true_mesh_scale.x, aabb.size.z * true_mesh_scale.z)
	var mesh_height = aabb.size.y * true_mesh_scale.y

	var target_width = collision.radius * 2.0
	var target_height = collision.height

	var scale_factor = min(
		target_width / mesh_width,
		target_height / mesh_height
	)

	custom.scale = Vector3.ONE * scale_factor

	var center := aabb.get_center()
	var feet_y := aabb.position.y
	custom.position = Vector3(
		-center.x * true_mesh_scale.x * scale_factor,
		-feet_y * true_mesh_scale.y * scale_factor,
		-center.z * true_mesh_scale.z * scale_factor
	)

	if corruption_overlay:
		var capsule := corruption_overlay.mesh as CapsuleMesh
		if capsule:
			capsule.radius = collision.radius * 1.05
			capsule.height = collision.height * 1.05
			corruption_overlay.position = Vector3.ZERO


func _find_first_mesh_instance(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node
	for child in node.get_children():
		var found = _find_first_mesh_instance(child)
		if found:
			return found
	return null

func configure_enemy() -> void:
	match enemy_type:
		EnemyType.SOLDIER:
			max_health = 100; move_speed = 4.0; attack_damage = 10; attack_cooldown = 1.5
			body_color = Color(0.4, 0.5, 0.9, 1); eye_color = Color(1, 0.3, 0.1, 1); enemy_scale = 1.0
		EnemyType.THIEF:
			max_health = 60;  move_speed = 6.5; attack_damage = 8;  attack_cooldown = 0.8
			body_color = Color(0.3, 0.8, 0.3, 1); eye_color = Color(0.8, 1, 0.1, 1); enemy_scale = 0.85
		EnemyType.DEMON:
			max_health = 140; move_speed = 4.5; attack_damage = 18; attack_cooldown = 1.2
			body_color = Color(0.8, 0.15, 0.1, 1); eye_color = Color(1, 0.6, 0.0, 1); enemy_scale = 1.15
		EnemyType.GOLEM:
			max_health = 250; move_speed = 2.5; attack_damage = 30; attack_cooldown = 2.0
			body_color = Color(0.5, 0.5, 0.5, 1); eye_color = Color(0.3, 0.8, 1, 1); enemy_scale = 1.5
		EnemyType.ANGEL:
			max_health = 120; move_speed = 7.0; attack_damage = 15; attack_cooldown = 0.9
			body_color = Color(0.9, 0.9, 0.7, 1); eye_color = Color(0.8, 0.2, 1, 1); enemy_scale = 1.1
		EnemyType.ASTRALWRAITH:
			max_health = 500; move_speed = 8.0; attack_damage = 40; attack_cooldown = 0.6
			body_color = Color(0.9, 0.7, 0.1, 1); eye_color = Color(1, 1, 1, 1); enemy_scale = 1.8
		EnemyType.VENOMBEAST:
			max_health = 45; move_speed = 7.5; attack_damage = 35; attack_cooldown = 999.0
			body_color = Color(0.9, 0.4, 0.05, 1); eye_color = Color(1, 1, 0.2, 1); enemy_scale = 0.9
		EnemyType.SERPENTWARRIOR:
			max_health = 100; move_speed = 4.0; attack_damage = 10; attack_cooldown = 1.5
			body_color = Color(0.4, 0.5, 0.9, 1); eye_color = Color(1, 0.3, 0.1, 1); enemy_scale = 1.0


	if is_bonus_target:
		eye_color = Color(1, 0.85, 0, 1)
		body_color = body_color.lerp(Color(1, 0.85, 0, 1), 0.35)

	if CampaignManager.is_arcade_mode:
		max_health = int(max_health * CampaignManager.arcade_hp_mult())
		attack_damage = int(attack_damage * CampaignManager.arcade_dmg_mult())
		move_speed *= CampaignManager.arcade_speed_mult()
		if CampaignManager.has_modifier("double_speed"):
			move_speed *= 2.0

	if is_boss:
		max_health = int(max_health * boss_health_multiplier)
		attack_damage = int(attack_damage * boss_damage_multiplier)
		enemy_scale = enemy_scale * boss_scale_multiplier
		if boss_display_name == "":
			boss_display_name = name

func _scale_boss_collision() -> void:
	var atk_col := attack_area.get_node("CollisionShape3D") as CollisionShape3D
	if atk_col and atk_col.shape is CapsuleShape3D:
		var atk_shape := (atk_col.shape as CapsuleShape3D).duplicate() as CapsuleShape3D
		atk_shape.radius *= boss_detection_multiplier
		atk_shape.height *= boss_detection_multiplier
		atk_col.shape = atk_shape

func apply_visuals() -> void:
	scale = Vector3.ONE * enemy_scale
	if custom_mesh_scene != null or enemy_root.has_node("CustomMesh"):
		return
	var mat = StandardMaterial3D.new()
	mat.albedo_color = body_color
	mat.roughness = 0.6
	mat.metallic = 0.1
	if mesh_body:
		mesh_body.set_surface_override_material(0, mat)
	for limb_path in ["ArmLeft/ArmLeftMesh", "ArmRight/ArmRightMesh", "LegLeft", "LegRight"]:
		var n = enemy_root.get_node_or_null(limb_path)
		if n and n is MeshInstance3D:
			n.set_surface_override_material(0, mat)
	if head_node:
		for eye_name in ["EyeLeft", "EyeRight"]:
			var eye = head_node.get_node_or_null(eye_name) as MeshInstance3D
			if eye:
				var em = StandardMaterial3D.new()
				em.albedo_color = eye_color
				em.emission_enabled = true
				em.emission = eye_color
				em.emission_energy_multiplier = 2.5
				eye.set_surface_override_material(0, em)

func apply_corruption_overlay() -> void:
	if not corruption_overlay:
		return
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.0, 0.0, 0.0, 0.55)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_FRONT
	mat.emission_enabled = true
	mat.emission = Color(0.15, 0.0, 0.25, 1)
	mat.emission_energy_multiplier = 0.8
	corruption_overlay.set_surface_override_material(0, mat)
	corruption_overlay.visible = true

func _physics_process(delta: float) -> void:
	if is_dying:
		_animate_death(delta)
		return

	if player == null:
		player = get_tree().get_first_node_in_group("player") as CharacterBody3D
		return

	var direction: Vector3 = Vector3.ZERO

	if nav_ready:
		nav_agent.target_position = player.global_position
		if not nav_agent.is_navigation_finished():
			var next_pos = nav_agent.get_next_path_position()
			direction = (next_pos - global_position).normalized()
		if direction.length() < 0.1:
			var to_player = (player.global_position - global_position)
			if to_player.length() > 1.5:
				direction = to_player.normalized()
	else:
		var to_player = (player.global_position - global_position)
		if to_player.length() > 1.5:
			direction = to_player.normalized()

	if unstuck_nudge_timer > 0:
		direction = unstuck_nudge
		unstuck_nudge_timer -= delta

	if direction.length() > 0.05:
		var target_angle = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_angle, 10.0 * delta)
		anim_state = AnimState.WALK
	else:
		anim_state = AnimState.IDLE

	var desired_velocity = Vector3(direction.x * move_speed, 0, direction.z * move_speed)
	if nav_ready and nav_agent.avoidance_enabled:
		nav_agent.set_velocity(desired_velocity)
	else:
		velocity.x = desired_velocity.x + knockback_velocity.x
		velocity.z = desired_velocity.z + knockback_velocity.z

	if not is_on_floor():
		velocity.y -= 10.0 * delta
	move_and_slide()

	knockback_velocity = knockback_velocity.lerp(Vector3.ZERO, knockback_decay * delta)
	_check_stuck(delta, direction)

	if player_in_range:
			attack_timer -= delta
			if attack_timer <= 0:
				if player and player.has_method("take_damage"):
					player.take_damage(attack_damage, global_position)
					anim_state = AnimState.ATTACK
					attack_lunge_timer = 0.3
					_play_sfx(attack_sound)
				attack_timer = attack_cooldown

	anim_time += delta
	_animate(delta)
	_pulse_corruption(delta)
	if is_boss:
		_update_boss_abilities(delta)

func _check_stuck(delta: float, direction: Vector3) -> void:
	if unstuck_nudge_timer > 0 or direction.length() < 0.05 or is_dying:
		stuck_check_pos = global_position
		return

	stuck_timer += delta
	if stuck_timer < 0.6:
		return
	stuck_timer = 0.0

	var moved := global_position.distance_to(stuck_check_pos)
	stuck_check_pos = global_position
	if moved < 0.15:
		var perpendicular = Vector3(-direction.z, 0, direction.x)
		unstuck_nudge = (direction + perpendicular * (1.0 if randf() > 0.5 else -1.0)).normalized()
		unstuck_nudge_timer = 0.5

func _play_sfx(stream: AudioStream) -> void:
	if stream == null:
		return
	sfx_player.stream = stream
	sfx_player.play()

func _maybe_drop_loot() -> void:
	var drop_chance := 0.18
	if is_elite:
		drop_chance = 0.9
	if is_boss:
		drop_chance = 1.0
	if randf() > drop_chance:
		return

	var loot_type := "upgrade"
	if randf() < 0.4:
		loot_type = "health"

	var amount := 1
	if is_boss:
		amount = 5
	elif is_elite:
		amount = 2

	_spawn_pickup(global_position + Vector3(0, 1.0, 0), loot_type, amount)

func _spawn_pickup(pos: Vector3, loot_type: String, amount: int) -> void:
	var pickup: LootPickup = LootPickupScript.new()
	pickup.loot_type = loot_type
	pickup.amount = amount
	get_tree().current_scene.add_child(pickup)
	pickup.global_position = pos

func _detonate() -> void:
	if has_detonated or is_dying:
		return
	has_detonated = true
	var origin := global_position
	var dmg := attack_damage
	_spawn_telegraph_ring(origin, 3.0, 0.25, Color(1, 0.5, 0.05))
	get_tree().create_timer(0.25).timeout.connect(func():
		if player and is_instance_valid(player) and player.global_position.distance_to(origin) <= 3.0:
			player.take_damage(dmg, origin)
	)
	die()

func _pulse_corruption(delta: float) -> void:
	if not corruption_overlay or not corruption_overlay.visible:
		return
	var t = Time.get_ticks_msec() * 0.001
	var pulse = 0.5 + 0.5 * sin(t * 2.5)
	var mat = corruption_overlay.get_surface_override_material(0) as StandardMaterial3D
	if mat:
		mat.emission_energy_multiplier = 0.4 + pulse * 0.8



func _update_boss_abilities(delta: float) -> void:
	if boss_buff_timer > 0.0:
		boss_buff_timer -= delta
		if boss_buff_timer <= 0.0:
			move_speed -= boss_buff_speed_bonus
			boss_buff_speed_bonus = 0.0
			nav_agent.max_speed = move_speed

	if not is_enraged and current_health <= max_health * 0.3:
		_enter_enraged()

	if boss_kit == "" or player == null or not is_instance_valid(player):
		return

	if boss_ability_cooldown > 0.0:
		boss_ability_cooldown -= delta
		return

	var dist := global_position.distance_to(player.global_position)
	match boss_kit:
		"angel": _angel_ability(dist)
		"demon": _demon_ability(dist)
		"serpent": _serpent_ability(dist)
		"void": _void_ability(dist)
		"warlord": _warlord_ability(dist)

func _enter_enraged() -> void:
	is_enraged = true
	move_speed *= 1.3
	attack_damage = int(attack_damage * 1.25)
	nav_agent.max_speed = move_speed

func _angel_ability(dist: float) -> void:
	boss_ability_step = (boss_ability_step + 1) % 4
	match boss_ability_step:
		0:
			_boss_fire_projectile(player.global_position - global_position, Color(1, 0.95, 0.6, 1))
			boss_ability_cooldown = 2.2
		1:
			_boss_ground_hazard(player.global_position, 3.0, 8, 2.0, 0.6, Color(1, 1, 0.7, 1))
			boss_ability_cooldown = 3.0
		2:
			if dist <= 5.0:
				_boss_melee_aoe(4.0, 1.2, 0.4)
			boss_ability_cooldown = 2.5
		3:
			if not is_enraged and current_health < max_health:
				_boss_heal(0.08)
			boss_ability_cooldown = 5.0

func _demon_ability(dist: float) -> void:
	boss_ability_step = (boss_ability_step + 1) % 4
	match boss_ability_step:
		0:
			for i in range(3):
				var spread := float(i - 1) * 0.18
				var dir := (player.global_position - global_position).rotated(Vector3.UP, spread)
				_boss_fire_projectile(dir, Color(1, 0.4, 0.05, 1))
			boss_ability_cooldown = 2.6
		1:
			_boss_ground_hazard(player.global_position, 3.0, 12, 2.5, 0.8, Color(1, 0.3, 0, 1))
			boss_ability_cooldown = 3.5
		2:
			if dist <= 10.0 and dist > 2.0:
				_boss_charge_attack()
			boss_ability_cooldown = 3.0
		3:
			if is_enraged:
				_boss_ground_hazard(player.global_position, 4.5, 18, 2.0, 1.2, Color(1, 0.1, 0, 1))
			boss_ability_cooldown = 4.0

func _serpent_ability(dist: float) -> void:
	boss_ability_step = (boss_ability_step + 1) % 4
	match boss_ability_step:
		0:
			_boss_fire_projectile(player.global_position - global_position, Color(0.3, 1, 0.2, 1), 0.8, true)
			boss_ability_cooldown = 2.0
		1:
			if dist <= 4.5:
				_boss_melee_aoe(3.5, 1.0, 0.35)
			boss_ability_cooldown = 2.2
		2:
			_boss_summon_minions(2, EnemyType.THIEF)
			boss_ability_cooldown = 6.0
		3:
			_boss_ground_hazard(player.global_position, 3.5, 6, 3.0, 0.7, Color(0.4, 0.9, 0.1, 1))
			boss_ability_cooldown = 3.5

func _void_ability(dist: float) -> void:
	boss_ability_step = (boss_ability_step + 1) % 4
	match boss_ability_step:
		0:
			_boss_fire_projectile(player.global_position - global_position, Color(0.6, 0.2, 1, 1))
			boss_ability_cooldown = 2.0
		1:
			_boss_ground_hazard(player.global_position, 3.0, 10, 2.0, 0.9, Color(0.5, 0.1, 0.9, 1))
			boss_ability_cooldown = 3.2
		2:
			if dist <= 5.0:
				_boss_melee_aoe(4.5, 1.1, 0.4)
			boss_ability_cooldown = 3.0
		3:
			_boss_summon_minions(2, EnemyType.THIEF)
			boss_ability_cooldown = 6.5

func _warlord_ability(dist: float) -> void:
	boss_ability_step = (boss_ability_step + 1) % 4
	match boss_ability_step:
		0:
			_boss_fire_projectile(player.global_position - global_position, Color(0.6, 0.6, 0.65, 1))
			boss_ability_cooldown = 2.5
		1:
			if not is_enraged:
				_boss_self_buff(0.4, 3.0)
			boss_ability_cooldown = 6.0
		2:
			if dist <= 4.5:
				_boss_melee_aoe(3.5, 1.15, 0.35)
			boss_ability_cooldown = 2.8
		3:
			_boss_summon_minions(2, EnemyType.SOLDIER)
			boss_ability_cooldown = 6.5

func _boss_fire_projectile(direction: Vector3, color: Color, dmg_mult: float = 1.0, poison: bool = false) -> void:
	if direction.length() < 0.01:
		return
	var dir := direction.normalized()
	var spawn_pos := global_position + Vector3(0, 1.4, 0) + dir * 0.8
	BossProjectile.spawn(get_tree().current_scene, spawn_pos, dir, int(attack_damage * dmg_mult), color, poison, self)

func _boss_melee_aoe(radius: float, dmg_mult: float, telegraph_time: float) -> void:
	var origin := global_position
	_spawn_telegraph_ring(origin, radius, telegraph_time, Color(1, 0.3, 0.1))
	var dmg := int(attack_damage * dmg_mult)
	get_tree().create_timer(telegraph_time).timeout.connect(func():
		if is_dying or not is_instance_valid(self):
			return
		if player and is_instance_valid(player) and global_position.distance_to(player.global_position) <= radius:
			player.take_damage(dmg, origin)
	)

func _boss_ground_hazard(pos: Vector3, radius: float, dmg_per_tick: int, duration: float, telegraph_time: float, color: Color) -> void:
	_spawn_telegraph_ring(pos, radius, telegraph_time, color)
	get_tree().create_timer(telegraph_time).timeout.connect(func():
		_activate_hazard_zone(pos, radius, dmg_per_tick, duration, color)
	)

func _activate_hazard_zone(pos: Vector3, radius: float, dmg_per_tick: int, duration: float, color: Color) -> void:
	var zone := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = 0.08
	zone.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(color.r, color.g, color.b, 0.55)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 2.0
	zone.set_surface_override_material(0, mat)
	get_tree().current_scene.add_child(zone)
	zone.global_position = pos + Vector3(0, 0.05, 0)

	var tick_timer := Timer.new()
	tick_timer.wait_time = 0.6
	tick_timer.autostart = true
	zone.add_child(tick_timer)
	tick_timer.timeout.connect(func():
		if player and is_instance_valid(player) and zone.global_position.distance_to(player.global_position) <= radius:
			player.take_damage(dmg_per_tick, zone.global_position)
	)
	get_tree().create_timer(duration).timeout.connect(zone.queue_free)

func _spawn_telegraph_ring(pos: Vector3, radius: float, duration: float, color: Color) -> void:
	var ring := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = 0.05
	ring.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(color.r, color.g, color.b, 0.3)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 1.5
	ring.set_surface_override_material(0, mat)
	get_tree().current_scene.add_child(ring)
	ring.global_position = pos + Vector3(0, 0.05, 0)
	var tw := ring.create_tween()
	tw.tween_property(mat, "albedo_color:a", 0.7, max(duration - 0.1, 0.05))
	tw.tween_callback(ring.queue_free)

func _boss_charge_attack() -> void:
	var dir := (player.global_position - global_position).normalized()
	knockback_velocity = dir * move_speed * 3.0

func _boss_summon_minions(count: int, minion_type: EnemyType) -> void:
	for i in range(count):
		var minion := BaseEnemyScene.instantiate() as BaseEnemy
		minion.enemy_type = minion_type
		var angle := randf() * TAU
		var offset := Vector3(cos(angle), 0, sin(angle)) * randf_range(2.0, 4.0)
		get_tree().current_scene.add_child(minion)
		minion.global_position = global_position + offset + Vector3(0, 1.0, 0)

func _boss_heal(percent: float) -> void:
	current_health = min(current_health + int(max_health * percent), max_health)

func _boss_self_buff(speed_bonus_pct: float, duration: float) -> void:
	boss_buff_speed_bonus = move_speed * speed_bonus_pct
	move_speed += boss_buff_speed_bonus
	boss_buff_timer = duration
	nav_agent.max_speed = move_speed


func _animate(delta: float) -> void:
	if hit_flash_timer > 0:
		hit_flash_timer -= delta
		var flash = (sin(hit_flash_timer * 40.0) + 1.0) * 0.5
		enemy_root.scale = Vector3.ONE * (1.0 + flash * 0.1)
		return

	if attack_lunge_timer > 0:
		attack_lunge_timer -= delta
		var lunge = sin(attack_lunge_timer * PI / 0.3)
		if arm_left:  arm_left.rotation.x  = -lunge * 0.8
		if arm_right: arm_right.rotation.x = -lunge * 0.8
		if head_node: head_node.rotation.x =  lunge * 0.2
		return

	match anim_state:
		AnimState.IDLE:
			var bob = sin(anim_time * 1.5) * 0.04
			enemy_root.position.y = bob
			if head_node: head_node.rotation.x = sin(anim_time * 0.8) * 0.05
			if arm_left:  arm_left.rotation.x  = sin(anim_time * 0.9 + 0.5) * 0.1
			if arm_right: arm_right.rotation.x = sin(anim_time * 0.9) * 0.1
			enemy_root.scale = Vector3.ONE

		AnimState.WALK:
			var sf = move_speed / 4.0
			var bob = abs(sin(anim_time * 6.0 * sf)) * 0.06
			enemy_root.position.y = bob
			if arm_left:  arm_left.rotation.x  =  sin(anim_time * 6.0 * sf) * 0.5
			if arm_right: arm_right.rotation.x = -sin(anim_time * 6.0 * sf) * 0.5
			enemy_root.rotation.z = sin(anim_time * 3.0 * sf) * 0.04

		AnimState.ATTACK:
			if arm_left:  arm_left.rotation.x  = lerp(arm_left.rotation.x,  0.0, 0.15)
			if arm_right: arm_right.rotation.x = lerp(arm_right.rotation.x, 0.0, 0.15)
			if head_node: head_node.rotation.x = lerp(head_node.rotation.x, 0.0, 0.15)

func _animate_death(delta: float) -> void:
	death_anim_timer += delta

	if is_demon_king:
		_animate_demon_king_death(delta)
		return

	var t = min(death_anim_timer / 1.0, 1.0)
	enemy_root.position.y = lerp(0.0, -0.5, t)
	enemy_root.rotation.z = lerp(0.0, PI * 0.5, t)
	enemy_root.scale = Vector3.ONE * lerp(1.0, 0.1, t)

	
	if corruption_overlay:
		if death_anim_timer < 0.4:
			var flash = sin(death_anim_timer * 30.0) * 0.5 + 0.5
			var mat = corruption_overlay.get_surface_override_material(0) as StandardMaterial3D
			if mat:
				mat.albedo_color = Color(flash * 0.5, 0.0, flash, 0.8)
				mat.emission = Color(flash, 0.0, flash * 2, 1)
				mat.emission_energy_multiplier = flash * 5.0
		elif death_anim_timer >= 0.4 and corruption_overlay.visible:
		
			corruption_overlay.visible = false


	_fade_mesh(enemy_root, lerp(1.0, 0.0, t))

	if death_anim_timer >= 1.0:
		queue_free()

func _animate_demon_king_death(delta: float) -> void:
	var t = min(death_anim_timer / 3.0, 1.0)

	if death_anim_timer < 0.6:
		if corruption_overlay:
			var flash = sin(death_anim_timer * 25.0) * 0.5 + 0.5
			var pulse_scale = 1.0 + flash * 0.4
			corruption_overlay.scale = Vector3.ONE * pulse_scale
			var mat = corruption_overlay.get_surface_override_material(0) as StandardMaterial3D
			if mat:
				mat.albedo_color = Color(flash * 0.3, 0.0, flash, 0.9)
				mat.emission = Color(flash * 2, 0.0, flash * 3, 1)
				mat.emission_energy_multiplier = flash * 8.0
	elif death_anim_timer < 0.8:
		if corruption_overlay and corruption_overlay.visible:
			corruption_overlay.visible = false
	else:
		var fall_t = min((death_anim_timer - 0.8) / 2.2, 1.0)
		enemy_root.rotation.x = lerp(0.0, PI * 0.5, fall_t)
		enemy_root.position.y = lerp(0.0, -1.5, fall_t * fall_t)
		enemy_root.scale = Vector3.ONE * lerp(1.0, 0.5, fall_t)

	if death_anim_timer >= 3.0:
		queue_free()

func get_hit_zone(hit_y: float) -> String:
	var col := $CollisionShape3D as CollisionShape3D
	var shape := col.shape as CapsuleShape3D if col else null
	if shape == null:
		return "torso"
	var world_height: float = shape.height * scale.y
	var feet_y: float = global_position.y
	var rel: float = (hit_y - feet_y) / max(world_height, 0.01)
	if rel > 0.82:
		return "head"
	elif rel < 0.35:
		return "limb"
	return "torso"

func take_hit(amount: int, hit_position: Vector3) -> Dictionary:
	if is_dying:
		return {"applied": false}
	var zone := get_hit_zone(hit_position.y)
	var multiplier := 1.0
	match zone:
		"head": multiplier = 2.0
		"limb": multiplier = 0.75
		_: multiplier = 1.0
	var final_damage := int(round(amount * multiplier))
	take_damage(final_damage)
	return {"applied": true, "zone": zone, "damage": final_damage, "is_headshot": zone == "head"}

func take_damage(amount: int) -> void:
	if amount <= 0 or is_dying:
		return
	current_health -= amount
	hit_flash_timer = 0.15
	knockback_velocity = (global_position - player.global_position).normalized() * 8.0
	velocity.y = 1.5
	_play_sfx(hit_sound)
	if current_health <= 0:
		die()

func die() -> void:
	if is_dying:
		return
	is_dying = true
	_play_sfx(death_sound)
	if level_manager:
		level_manager.enemy_killed()
	if is_bonus_target and CampaignManager.current_mission_type == CampaignManager.MissionType.BONUS_TARGET:
		CampaignManager.upgrade_points += 3
	if CampaignManager.has_modifier("exploding_enemies") and not has_detonated:
		has_detonated = true
		var origin := global_position
		if player and is_instance_valid(player) and player.global_position.distance_to(origin) <= 2.5:
			player.take_damage(int(attack_damage * 0.5), origin)
	_maybe_drop_loot()
	$CollisionShape3D.set_deferred("disabled", true)
	attack_area.set_deferred("monitoring", false)
	attack_area.set_deferred("monitorable", false)

func _on_attack_area_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		attack_timer = attack_cooldown * 0.3

func _on_attack_area_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		
func _fade_mesh(node: Node, alpha: float) -> void:
	if node is MeshInstance3D:
		var mat = node.get_surface_override_material(0) as StandardMaterial3D
		if mat:
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mat.albedo_color.a = alpha

	for child in node.get_children():
		_fade_mesh(child, alpha)

func assign_enemy_mesh() -> void:
	match enemy_type:
		EnemyType.SOLDIER:
			custom_mesh_scene = SOLDIER_MESH

		EnemyType.THIEF:
			custom_mesh_scene = THIEF_MESH

		EnemyType.DEMON:
			custom_mesh_scene = DEMON_MESH

		EnemyType.GOLEM:
			custom_mesh_scene = GOLEM_MESH

		EnemyType.ANGEL:
			custom_mesh_scene = ANGEL_MESH

		EnemyType.ASTRALWRAITH:
			custom_mesh_scene = ASTRAL_WRAITH_MESH

		EnemyType.SERPENTWARRIOR:
			custom_mesh_scene = SERPENT_WARRIOR_MESH

		EnemyType.VENOMBEAST:
			custom_mesh_scene = VENOM_BEAST_MESH
