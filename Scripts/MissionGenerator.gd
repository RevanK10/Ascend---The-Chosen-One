extends StaticBody3D
class_name MissionGenerator

@export var max_health: int = 40
var current_health: int

func _ready() -> void:
	current_health = max_health
	add_to_group("mission_generator")

	var col := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = 0.6
	shape.height = 1.4
	col.shape = shape
	col.position.y = 0.7
	add_child(col)

	var mesh := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.6
	cyl.bottom_radius = 0.7
	cyl.height = 1.4
	mesh.mesh = cyl
	mesh.position.y = 0.7
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.3, 0.5, 0.9, 1)
	mat.emission_enabled = true
	mat.emission = Color(0.3, 0.6, 1, 1)
	mat.emission_energy_multiplier = 1.5
	mesh.set_surface_override_material(0, mat)
	add_child(mesh)

func take_hit(amount: int, _hit_position: Vector3) -> Dictionary:
	take_damage(amount)
	return {"applied": true, "damage": amount, "is_headshot": false}

func take_damage(amount: int) -> void:
	if current_health <= 0:
		return
	current_health -= amount
	if current_health <= 0:
		_destroy()

func _destroy() -> void:
	var lm = get_tree().get_first_node_in_group("level_manager")
	if lm and lm.has_method("generator_destroyed"):
		lm.generator_destroyed()
	queue_free()
