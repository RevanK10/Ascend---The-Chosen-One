extends Area3D

@export var speed: float = 35.0
@export var gravity_strength: float = 12.0
@export var life_time: float = 4.0
@export var damage: int = 25

var velocity: Vector3 = Vector3.ZERO
var direction: Vector3 = Vector3.ZERO
var owner_player: Node = null
var pierce_remaining: int = 0 



func set_direction(dir: Vector3) -> void:
	direction = dir.normalized()

func _ready() -> void:
	await get_tree().process_frame

	if direction == Vector3.ZERO:
		direction = -global_transform.basis.z

	velocity = direction * speed

	if velocity.length() > 0.01:
		look_at(global_position + velocity.normalized(), Vector3.UP)

	body_entered.connect(Callable(self, "_on_body_hit"))

func _physics_process(delta: float) -> void:
	velocity.y -= gravity_strength * delta
	global_position += velocity * delta

	life_time -= delta
	if life_time <= 0:
		queue_free()

func _on_body_hit(body: Node) -> void:
	if body == owner_player:
		return

	var hit_pos := global_position
	if body.has_method("take_hit"):
		var result: Dictionary = body.take_hit(damage, hit_pos)
		if result.get("applied", false):
			_spawn_hit_effects(hit_pos, result.get("damage", damage), result.get("is_headshot", false))
	elif body.has_method("take_damage"):
		body.take_damage(damage)
		_spawn_hit_effects(hit_pos, damage, false)

	if pierce_remaining > 0:
		pierce_remaining -= 1
		return 

	queue_free()

func _spawn_hit_effects(pos: Vector3, damage_dealt: int, is_headshot: bool) -> void:
	_spawn_blood_burst(pos)
	_spawn_damage_number(pos, damage_dealt, is_headshot)
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("show_hit_marker"):
		hud.show_hit_marker(is_headshot)

func _spawn_blood_burst(pos: Vector3) -> void:
	var particles := CPUParticles3D.new()
	particles.one_shot = true
	particles.emitting = false
	particles.amount = 14
	particles.lifetime = 0.4
	particles.explosiveness = 1.0
	particles.direction = Vector3.UP
	particles.spread = 60.0
	particles.gravity = Vector3(0, -9.0, 0)
	particles.initial_velocity_min = 2.0
	particles.initial_velocity_max = 4.0
	particles.scale_amount_min = 0.05
	particles.scale_amount_max = 0.12
	particles.color = Color(0.55, 0.02, 0.02, 1)
	particles.mesh = SphereMesh.new()
	get_tree().current_scene.add_child(particles)
	particles.global_position = pos
	particles.emitting = true
	get_tree().create_timer(particles.lifetime + 0.5).timeout.connect(particles.queue_free)

func _spawn_damage_number(pos: Vector3, amount: int, is_headshot: bool) -> void:
	var label := Label3D.new()
	label.text = str(amount) + ("!" if is_headshot else "")
	label.font_size = 56 if is_headshot else 36
	label.outline_size = 10
	label.modulate = Color(1, 0.85, 0.15, 1) if is_headshot else Color(1, 1, 1, 1)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	get_tree().current_scene.add_child(label)
	label.global_position = pos + Vector3(randf_range(-0.15, 0.15), 0.3, randf_range(-0.15, 0.15))

	var tw := label.create_tween()
	tw.set_parallel(true)
	tw.tween_property(label, "position:y", label.position.y + 0.8, 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(label, "modulate:a", 0.0, 0.55).set_delay(0.2)
	tw.chain().tween_callback(label.queue_free)
