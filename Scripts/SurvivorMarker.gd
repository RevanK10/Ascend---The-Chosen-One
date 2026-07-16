extends Area3D
class_name SurvivorMarker

func _ready() -> void:
	add_to_group("mission_survivor")
	monitoring = true
	monitorable = false

	var col := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 1.2
	col.shape = shape
	add_child(col)

	var mesh := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.3
	capsule.height = 1.6
	mesh.mesh = capsule
	mesh.position.y = 0.8
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 1, 0.5, 1)
	mat.emission_enabled = true
	mat.emission = Color(0.2, 1, 0.5, 1)
	mat.emission_energy_multiplier = 1.8
	mesh.set_surface_override_material(0, mat)
	add_child(mesh)

	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	var lm = get_tree().get_first_node_in_group("level_manager")
	if lm and lm.has_method("survivor_rescued"):
		lm.survivor_rescued()
	queue_free()
