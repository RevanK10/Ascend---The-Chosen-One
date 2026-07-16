extends Area3D
class_name LootPickup

@export var loot_type: String = "upgrade"
@export var amount: int = 1

var _bob_time := 0.0

func _ready() -> void:
	set_deferred("monitoring", true)
	set_deferred("monitorable", false)

	var col := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 0.5
	col.shape = shape
	add_child(col)

	var mesh := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.25
	sphere.height = 0.5
	mesh.mesh = sphere
	var mat := StandardMaterial3D.new()
	var color: Color = Color(1, 0.85, 0.1, 1) if loot_type == "upgrade" else Color(0.2, 1, 0.3, 1)
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 2.0
	mesh.set_surface_override_material(0, mat)
	add_child(mesh)

	body_entered.connect(_on_body_entered)
	get_tree().create_timer(20.0).timeout.connect(func():
		if is_instance_valid(self):
			queue_free()
	)

func _process(delta: float) -> void:
	_bob_time += delta
	position.y += sin(_bob_time * 3.0) * delta * 0.3
	rotate_y(delta * 2.0)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	if loot_type == "health" and body.has_method("heal"):
		body.heal(amount * 15)
	elif loot_type == "upgrade":
		CampaignManager.upgrade_points += amount
	queue_free()
