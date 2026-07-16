extends CharacterBody3D

@export var mouse_sensitivity: float = 0.002
@export var spear_scene: PackedScene

@export_group("Attack Feel")
@export var attack_cooldown: float = 0.6
@export var windup_time: float = 0.12
@export var lunge_time: float = 0.18
@export var recoil_kick_degrees: float = 5.0
@export var sway_amount: float = 0.02
@export var bob_amount: float = 0.015

@export_group("Screen Shake")
@export var shake_decay: float = 2.5
@export var shake_max_offset: float = 0.08
@export var shake_max_roll_degrees: float = 4.0

@export_group("Audio (drag sound files in here - none are bundled)")
@export var throw_sound: AudioStream
@export var footstep_sound: AudioStream
@export var hit_taken_sound: AudioStream
@export var jump_sound: AudioStream
@export var footstep_interval: float = 0.4

@onready var rotation_helper: Node3D = $Rotation_Helper
@onready var camera: Camera3D = $Rotation_Helper/Camera3D
@onready var projectile_spawn: Marker3D = $Rotation_Helper/Camera3D/ProjectileSpawnPoint
@onready var spear_viewmodel: Node3D = $Rotation_Helper/Camera3D/SpearViewmodel if has_node("Rotation_Helper/Camera3D/SpearViewmodel") else null
@onready var sfx_player: AudioStreamPlayer = AudioStreamPlayer.new()

var gravity_strength: float = 20.0
var jump_force: float = 8.0
var current_health: int
var footstep_timer: float = 0.0

var aim_pitch: float = 0.0
var recoil_pitch: float = 0.0
var mouse_delta_smoothed: Vector2 = Vector2.ZERO
var shake_trauma: float = 0.0

var attack_timer: float = 0.0
var is_winding_up: bool = false
var windup_timer: float = 0.0
var lunge_timer: float = 0.0
var bob_time: float = 0.0

func _enter_tree() -> void:
	add_to_group("player")

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	current_health = CampaignManager.max_health
	add_child(sfx_player)

func _play_sfx(stream: AudioStream) -> void:
	if stream == null:
		return
	sfx_player.stream = stream
	sfx_player.play()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		aim_pitch -= event.relative.y * mouse_sensitivity
		aim_pitch = clamp(aim_pitch, deg_to_rad(-85), deg_to_rad(85))
		mouse_delta_smoothed = mouse_delta_smoothed.lerp(event.relative, 0.5)

	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func _physics_process(delta: float) -> void:
	var input_dir: Vector3 = Vector3.ZERO

	if Input.is_action_pressed("move_forward"):
		input_dir -= transform.basis.z
	if Input.is_action_pressed("move_backward"):
		input_dir += transform.basis.z
	if Input.is_action_pressed("move_left"):
		input_dir -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		input_dir += transform.basis.x

	input_dir = input_dir.normalized()

	velocity.x = input_dir.x * CampaignManager.movement_speed
	velocity.z = input_dir.z * CampaignManager.movement_speed

	if is_on_floor() and input_dir.length() > 0.1:
		footstep_timer -= delta
		if footstep_timer <= 0.0:
			footstep_timer = footstep_interval
			_play_sfx(footstep_sound)
	else:
		footstep_timer = 0.0

	if not is_on_floor():
		var g := gravity_strength
		if CampaignManager.has_modifier("low_gravity"):
			g *= 0.4
		velocity.y -= g * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
		_play_sfx(jump_sound)

	move_and_slide()

	_update_attack_state(delta)

func _update_attack_state(delta: float) -> void:
	if attack_timer > 0.0:
		attack_timer -= delta

	if is_winding_up:
		windup_timer -= delta
		if windup_timer <= 0.0:
			is_winding_up = false
			_release_throw()
	elif lunge_timer > 0.0:
		lunge_timer -= delta
	elif Input.is_action_just_pressed("attack") and attack_timer <= 0.0:
		is_winding_up = true
		windup_timer = windup_time

func _release_throw() -> void:
	throw_spear()
	lunge_timer = lunge_time
	attack_timer = attack_cooldown * CampaignManager.spear_cooldown_mult
	if CampaignManager.has_modifier("rapid_throw"):
		attack_timer *= 0.25

func throw_spear() -> void:
	if spear_scene == null:
		return

	var spear = spear_scene.instantiate()
	get_tree().current_scene.add_child(spear)

	spear.global_transform = projectile_spawn.global_transform
	spear.owner_player = self
	if "damage" in spear:
		spear.damage = CampaignManager.spear_damage
	if "pierce_remaining" in spear and CampaignManager.spear_pierce_unlocked:
		spear.pierce_remaining = CampaignManager.spear_pierce_charges

	spear.set_direction(-camera.global_transform.basis.z)

	recoil_pitch -= deg_to_rad(recoil_kick_degrees)
	_play_sfx(throw_sound)

func _process(delta: float) -> void:
	recoil_pitch = lerp(recoil_pitch, 0.0, 8.0 * delta)
	rotation_helper.rotation.x = clamp(aim_pitch + recoil_pitch, deg_to_rad(-95), deg_to_rad(95))

	shake_trauma = max(shake_trauma - shake_decay * delta, 0.0)
	if shake_trauma > 0.0:
		var amount := shake_trauma * shake_trauma
		camera.h_offset = randf_range(-1, 1) * shake_max_offset * amount
		camera.v_offset = randf_range(-1, 1) * shake_max_offset * amount
		camera.rotation.z = randf_range(-1, 1) * deg_to_rad(shake_max_roll_degrees) * amount
	else:
		camera.h_offset = 0.0
		camera.v_offset = 0.0
		camera.rotation.z = 0.0

	mouse_delta_smoothed = mouse_delta_smoothed.lerp(Vector2.ZERO, 6.0 * delta)
	_update_weapon_viewmodel(delta)

func _update_weapon_viewmodel(delta: float) -> void:
	if spear_viewmodel == null:
		return

	var is_moving := Vector2(velocity.x, velocity.z).length() > 0.3
	bob_time += delta * (5.0 if is_moving else 1.5)

	var target_pos := Vector3.ZERO
	var target_rot := Vector3.ZERO

	if is_winding_up:
		var t: float = 1.0 - (windup_timer / max(windup_time, 0.001))
		target_pos = Vector3(0.05, 0.03, 0.12) * t
		target_rot = Vector3(deg_to_rad(-10), deg_to_rad(6), 0) * t
	elif lunge_timer > 0.0:
		var t: float = lunge_timer / max(lunge_time, 0.001)
		target_pos = Vector3(0, -0.02, -0.18) * t
		target_rot = Vector3(deg_to_rad(8), 0, 0) * t
	else:
		target_pos = Vector3(
			-mouse_delta_smoothed.x * sway_amount * 0.01,
			sin(bob_time * 2.0) * bob_amount * (1.0 if is_moving else 0.3),
			-mouse_delta_smoothed.y * sway_amount * 0.005
		)
		target_rot = Vector3(0, -mouse_delta_smoothed.x * sway_amount * 0.01, mouse_delta_smoothed.x * sway_amount * 0.02)

	spear_viewmodel.position = spear_viewmodel.position.lerp(target_pos, 10.0 * delta)
	spear_viewmodel.rotation = spear_viewmodel.rotation.lerp(target_rot, 10.0 * delta)

func take_damage(amount: int, attacker_position: Vector3 = Vector3.ZERO) -> void:
	current_health -= amount
	print("Player HP:", current_health)

	shake_trauma = min(shake_trauma + 0.35, 1.0)
	_play_sfx(hit_taken_sound)

	if attacker_position != Vector3.ZERO:
		var hud = get_tree().get_first_node_in_group("hud")
		if hud and hud.has_method("show_damage_direction"):
			var to_attacker: Vector3 = attacker_position - global_position
			var local_dir: Vector3 = global_transform.basis.inverse() * to_attacker
			hud.show_damage_direction(atan2(local_dir.x, -local_dir.z))

	if current_health <= 0:
		die()

func heal(amount: int) -> void:
	current_health = min(current_health + amount, CampaignManager.max_health)

func die() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://Scenes/DeathScreen.tscn")

func _reload_scene() -> void:
	get_tree().reload_current_scene()

func toggle_pause() -> void:
	if get_tree().paused:
		return

	var pause_menu = preload("res://Scenes/PauseMenu.tscn").instantiate()
	pause_menu.name = "PauseMenu"

	get_tree().current_scene.add_child(pause_menu)

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	get_tree().paused = true
