extends Area3D
class_name BossProjectile

@export var speed: float = 14.0
@export var damage: int = 15
@export var color: Color = Color(1, 0.9, 0.3, 1)
@export var lifetime: float = 4.0
@export var is_poison: bool = false
@export var radius: float = 0.25

var direction: Vector3 = Vector3.FORWARD
var owner_boss: Node = null
var _age: float = 0.0
var _mesh: MeshInstance3D
var _material: StandardMaterial3D

static var _pool: Array[BossProjectile] = []

static func spawn(parent: Node, world_pos: Vector3, dir: Vector3, dmg: int, col: Color, poison: bool, owner_node: Node) -> BossProjectile:
	var proj: BossProjectile = null
	while _pool.size() > 0:
		var candidate: BossProjectile = _pool.pop_back()
		if is_instance_valid(candidate):
			proj = candidate
			break
	if proj == null:
		proj = BossProjectile.new()
	if not proj.is_inside_tree():
		parent.add_child(proj)

	proj.direction = dir.normalized()
	proj.damage = dmg
	proj.color = col
	proj.is_poison = poison
	proj.owner_boss = owner_node
	proj._age = 0.0
	proj.global_position = world_pos
	proj.visible = true
	proj.set_deferred("monitoring", true)
	proj.set_physics_process(true)
	proj._refresh_material()
	return proj

func _ready() -> void:
	monitoring = true
	monitorable = false

	var col := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = radius
	col.shape = shape
	add_child(col)

	_mesh = MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius * 2.0
	_mesh.mesh = sphere
	_material = StandardMaterial3D.new()
	_material.emission_enabled = true
	_material.emission_energy_multiplier = 2.5
	_mesh.set_surface_override_material(0, _material)
	add_child(_mesh)

	body_entered.connect(_on_body_entered)

func _refresh_material() -> void:
	if _material:
		_material.albedo_color = color
		_material.emission = color

func _physics_process(delta: float) -> void:
	_age += delta
	if _age > lifetime:
		_release()
		return
	global_position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	if body == owner_boss:
		return

	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage, global_position)
		if is_poison:
			var target := body
			var follow_up := int(damage * 0.4)
			get_tree().create_timer(1.0).timeout.connect(func():
				if is_instance_valid(target):
					target.take_damage(follow_up)
			)
		_release()
	elif not body.is_in_group("boss_enemy") and not body.is_in_group("enemy"):
		_release()

func _release() -> void:
	visible = false
	set_deferred("monitoring", false)
	set_physics_process(false)
	BossProjectile._pool.append(self)
