extends Node3D

func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	build_props()

func build_props() -> void:
	pass

func make_box(pos: Vector3, size: Vector3, albedo: Color,
			  metallic: float = 0.0, roughness: float = 0.85,
			  emit: Color = Color.BLACK, emit_e: float = 0.0,
			  rot: Vector3 = Vector3.ZERO, collide: bool = true) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = pos
	body.rotation = rot
	add_child(body)
	if collide:
		var col := CollisionShape3D.new()
		var sh := BoxShape3D.new()
		sh.size = size
		col.shape = sh
		body.add_child(col)
	var mi := MeshInstance3D.new()
	var m := BoxMesh.new()
	m.size = size
	m.material = _mat(albedo, metallic, roughness, emit, emit_e)
	mi.mesh = m
	body.add_child(mi)
	return body

func make_cyl(pos: Vector3, radius: float, height: float, albedo: Color,
			  metallic: float = 0.0, roughness: float = 0.8,
			  emit: Color = Color.BLACK, emit_e: float = 0.0,
			  rot: Vector3 = Vector3.ZERO, collide: bool = true) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = pos
	body.rotation = rot
	add_child(body)
	if collide:
		var col := CollisionShape3D.new()
		var sh := CylinderShape3D.new()
		sh.radius = radius; sh.height = height
		col.shape = sh
		body.add_child(col)
	var mi := MeshInstance3D.new()
	var m := CylinderMesh.new()
	m.top_radius = radius; m.bottom_radius = radius; m.height = height
	m.material = _mat(albedo, metallic, roughness, emit, emit_e)
	mi.mesh = m
	body.add_child(mi)
	return body

func make_sphere(pos: Vector3, radius: float, albedo: Color,
				 metallic: float = 0.0, roughness: float = 0.75,
				 emit: Color = Color.BLACK, emit_e: float = 0.0,
				 collide: bool = false) -> Node3D:
	var body: Node3D = StaticBody3D.new() if collide else Node3D.new()
	body.position = pos
	add_child(body)
	if collide:
		var col := CollisionShape3D.new()
		var sh := SphereShape3D.new(); sh.radius = radius
		col.shape = sh
		(body as StaticBody3D).add_child(col)
	var mi := MeshInstance3D.new()
	var m := SphereMesh.new()
	m.radius = radius; m.height = radius * 2.0
	m.material = _mat(albedo, metallic, roughness, emit, emit_e)
	mi.mesh = m
	body.add_child(mi)
	return body

func add_light(pos: Vector3, color: Color, energy: float = 3.0, range_v: float = 18.0) -> OmniLight3D:
	var l := OmniLight3D.new()
	l.position = pos
	l.light_color = color
	l.light_energy = energy
	l.omni_range = range_v
	l.shadow_enabled = true
	add_child(l)
	return l

func _mat(albedo: Color, metallic: float, roughness: float,
		  emit: Color, emit_e: float) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = albedo
	m.metallic = metallic
	m.roughness = roughness
	if emit_e > 0.0:
		m.emission_enabled = true
		m.emission = emit
		m.emission_energy_multiplier = emit_e
	return m
