class_name CinematicCutscene
extends Node3D

signal cutscene_finished

@export var next_scene: String = ""

var shots: Array = []
var current_shot: int = -1
var shot_timer: float = 0.0
var is_running: bool = false
var is_transitioning: bool = false

@onready var cam:            Camera3D     = $CinematicCamera
@onready var subtitle_label: Label        = $UI/SubtitleBar/VBox/SubtitleLabel
@onready var speaker_label:  Label        = $UI/SubtitleBar/VBox/SpeakerLabel
@onready var subtitle_bar:   PanelContainer = $UI/SubtitleBar
@onready var fade_rect:      ColorRect    = $UI/FadeRect
@onready var char_root:      Node3D       = $CharacterRoot
@onready var world_env:      WorldEnvironment = $WorldEnvironment
@onready var ambient_light:  DirectionalLight3D = $AmbientLight


var _characters: Dictionary = {}

const CHAR_DEFS = {
	"warrior": {
		"body": Color(0.55, 0.45, 0.35, 1), "eye": Color(0.2, 0.6, 1.0, 1),
		"outfit": Color(0.25, 0.22, 0.18, 1), "scale": 1.0,
		"has_spear": true
	},
	"archangel": {
		"body": Color(0.92, 0.90, 0.82, 1), "eye": Color(0.8, 0.4, 1.0, 1),
		"outfit": Color(0.80, 0.78, 0.65, 1), "scale": 1.3,
		"corrupted": true
	},
	"void_lord": {
		"body": Color(0.08, 0.04, 0.18, 1), "eye": Color(0.6, 0.1, 1.0, 1),
		"outfit": Color(0.12, 0.05, 0.25, 1), "scale": 1.4,
		"corrupted": true
	},
	"warlord": {
		"body": Color(0.35, 0.28, 0.22, 1), "eye": Color(1.0, 0.4, 0.0, 1),
		"outfit": Color(0.28, 0.18, 0.12, 1), "scale": 1.35,
		"corrupted": true
	},
	"serpent_king": {
		"body": Color(0.08, 0.28, 0.08, 1), "eye": Color(0.1, 1.0, 0.05, 1),
		"outfit": Color(0.06, 0.20, 0.06, 1), "scale": 1.4,
		"corrupted": true
	},
	"demon_king": {
		"body": Color(0.55, 0.04, 0.02, 1), "eye": Color(1.0, 0.8, 0.0, 1),
		"outfit": Color(0.35, 0.03, 0.01, 1), "scale": 1.8,
		"corrupted": true
	},
	"sage": {
		"body": Color(0.70, 0.62, 0.55, 1), "eye": Color(0.4, 0.8, 0.6, 1),
		"outfit": Color(0.45, 0.38, 0.30, 1), "scale": 0.95
	},
}

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	fade_rect.modulate.a = 1.0
	subtitle_bar.modulate.a = 0.0
	_setup_environment()
	var tw = create_tween()
	tw.tween_property(fade_rect, "modulate:a", 0.0, 0.9)
	await tw.finished
	is_running = true
	_advance_shot()

func _setup_environment() -> void:
	var plane := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(200, 200)
	var pmat := StandardMaterial3D.new()
	pmat.albedo_color = Color(0.05, 0.05, 0.08, 1)
	pmat.roughness = 1.0
	pm.material = pmat
	plane.mesh = pm
	add_child(plane)

func _process(delta: float) -> void:
	if not is_running or is_transitioning:
		return
	shot_timer -= delta
	if shot_timer <= 0.0:
		_advance_shot()

func _input(event: InputEvent) -> void:
	if is_transitioning:
		return
	var skip = (event is InputEventKey and event.pressed and not event.echo) or \
			   (event is InputEventMouseButton and event.pressed and event.button_index == 1)
	if skip:
		shot_timer = -1.0

func _advance_shot() -> void:
	current_shot += 1
	if current_shot >= shots.size():
		_finish()
		return
	_play_shot(shots[current_shot])

func _play_shot(shot: Dictionary) -> void:
	shot_timer = shot.get("duration", 4.0)

	var cp: Vector3 = shot.get("cam_pos", Vector3(0, 1.6, 3))
	var cl: Vector3 = shot.get("cam_look", Vector3.ZERO)
	var tw = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tw.tween_property(cam, "global_position", cp, 0.6)
	cam.look_at(cl, Vector3.UP)
	var prev_pos = cam.global_position
	await get_tree().process_frame
	cam.global_position = prev_pos
	tw = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tw.tween_property(cam, "global_position", cp, 0.5)
	cam.look_at(cl, Vector3.UP)

	var bl: Color = shot.get("bg_light", Color(0.5, 0.5, 0.6, 1))
	var be: float = shot.get("bg_light_e", 1.0)
	if ambient_light:
		ambient_light.light_color = bl
		ambient_light.light_energy = be

	var chars: Array = shot.get("characters", [])
	_update_characters(chars)

	var sub: String = shot.get("subtitle", "")
	var spk: String = shot.get("speaker", "")
	if sub.is_empty():
		var tw2 = create_tween()
		tw2.tween_property(subtitle_bar, "modulate:a", 0.0, 0.3)
	else:
		speaker_label.text = spk.to_upper() if not spk.is_empty() else ""
		speaker_label.visible = not spk.is_empty()
		subtitle_label.text = sub
		var tw2 = create_tween()
		tw2.tween_property(subtitle_bar, "modulate:a", 1.0, 0.4)

func _update_characters(char_list: Array) -> void:
	for id in _characters:
		_characters[id].visible = false

	for cdata in char_list:
		var id: String = cdata.get("id", "")
		if id.is_empty():
			continue
		if not _characters.has(id):
			_characters[id] = _spawn_character(id)
		var root: Node3D = _characters[id]
		root.visible = true
		root.global_position = cdata.get("pos", Vector3.ZERO)
		root.rotation_degrees.y = cdata.get("rot_y", 0.0)

func _spawn_character(id: String) -> Node3D:
	var def: Dictionary = CHAR_DEFS.get(id, {
		"body": Color(0.6, 0.5, 0.4, 1), "eye": Color(1, 0.3, 0.1, 1),
		"outfit": Color(0.3, 0.3, 0.3, 1), "scale": 1.0
	})

	var root := Node3D.new()
	root.name = "Char_" + id
	root.scale = Vector3.ONE * def.get("scale", 1.0)
	char_root.add_child(root)

	var skin_c:   Color = def.get("body",   Color(0.7, 0.6, 0.5, 1))
	var eye_c:    Color = def.get("eye",    Color(1, 0.2, 0.2, 1))
	var outfit_c: Color = def.get("outfit", Color(0.3, 0.3, 0.4, 1))
	var is_corrupt: bool = def.get("corrupted", false)

	for side in [-1, 1]:
		var leg := _make_mesh_node(root, CapsuleMesh.new(), Vector3(side * 0.15, 0.5, 0))
		var lm := leg.mesh as CapsuleMesh; lm.radius = 0.12; lm.height = 0.9
		_set_mat(leg, outfit_c, 0.75)

	var torso := _make_mesh_node(root, CapsuleMesh.new(), Vector3(0, 1.15, 0))
	var tm := torso.mesh as CapsuleMesh; tm.radius = 0.30; tm.height = 0.85
	_set_mat(torso, outfit_c, 0.7)

	for side in [-1, 1]:
		var arm := _make_mesh_node(root, CapsuleMesh.new(), Vector3(side * 0.42, 1.1, 0))
		var am := arm.mesh as CapsuleMesh; am.radius = 0.10; am.height = 0.65
		_set_mat(arm, skin_c, 0.7)

	var head := _make_mesh_node(root, SphereMesh.new(), Vector3(0, 1.78, 0))
	var hm := head.mesh as SphereMesh; hm.radius = 0.22; hm.height = 0.44
	_set_mat(head, skin_c, 0.65)


	for side in [-1, 1]:
		var eye := _make_mesh_node(root, SphereMesh.new(), Vector3(side * 0.09, 1.82, 0.2))
		var em := eye.mesh as SphereMesh; em.radius = 0.04; em.height = 0.08
		_set_mat(eye, eye_c, 0.7, 0.0, eye_c, 2.5)

	if def.get("has_spear", false):
		_build_spear(root)

	if id == "archangel":
		_build_wings(root, outfit_c)

	if id == "demon_king":
		_build_crown(root)

	if is_corrupt:
		var ov := _make_mesh_node(root, CapsuleMesh.new(), Vector3(0, 1.15, 0))
		var ovm := ov.mesh as CapsuleMesh; ovm.radius = 0.42; ovm.height = 2.1
		var omat := StandardMaterial3D.new()
		omat.albedo_color = Color(0, 0, 0, 0.55)
		omat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		omat.cull_mode = BaseMaterial3D.CULL_FRONT
		omat.emission_enabled = true
		omat.emission = Color(0.15, 0.0, 0.25, 1)
		omat.emission_energy_multiplier = 1.2
		omat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		ov.set_surface_override_material(0, omat)
		root.set_meta("corruption_overlay", ov)

	return root

func _build_spear(root: Node3D) -> void:
	var holder := Node3D.new()
	holder.position = Vector3(0.55, 1.2, 0)
	holder.rotation_degrees = Vector3(-15, 0, 10)
	root.add_child(holder)
	
	var shaft := _make_mesh_node(holder, CylinderMesh.new(), Vector3(0, 0, 0))
	var sm := shaft.mesh as CylinderMesh; sm.top_radius = 0.03; sm.bottom_radius = 0.03; sm.height = 1.8
	_set_mat(shaft, Color(0.55, 0.38, 0.20, 1), 0.8)

	var tip := _make_mesh_node(holder, CylinderMesh.new(), Vector3(0, 1.05, 0))
	var tipm := tip.mesh as CylinderMesh; tipm.top_radius = 0.0; tipm.bottom_radius = 0.09; tipm.height = 0.32
	_set_mat(tip, Color(0.85, 0.85, 0.92, 1), 0.9, 0.15, Color(0.5, 0.7, 1.0, 1), 0.8)

func _build_wings(root: Node3D, c: Color) -> void:
	for side in [-1, 1]:
		var wing := _make_mesh_node(root, BoxMesh.new(),
			Vector3(side * 0.9, 1.3, -0.1),
			Vector3(deg_to_rad(-10), 0, deg_to_rad(side * 40)))
		var wm := wing.mesh as BoxMesh; wm.size = Vector3(0.9, 1.4, 0.06)
		_set_mat(wing, c * 1.1, 0.3, 0.1)

func _build_crown(root: Node3D) -> void:
	var base := _make_mesh_node(root, CylinderMesh.new(), Vector3(0, 2.05, 0))
	var bm := base.mesh as CylinderMesh; bm.top_radius = 0.28; bm.bottom_radius = 0.28; bm.height = 0.18
	_set_mat(base, Color(0.7, 0.1, 0.0, 1), 0.7, 0.2, Color(1, 0.3, 0, 1), 0.8)
	for i in range(5):
		var angle = i * TAU / 5
		var spike := _make_mesh_node(root, CylinderMesh.new(),
			Vector3(cos(angle)*0.22, 2.24, sin(angle)*0.22))
		var spm := spike.mesh as CylinderMesh; spm.top_radius = 0.0; spm.bottom_radius = 0.06; spm.height = 0.28
		_set_mat(spike, Color(0.8, 0.15, 0.0, 1), 0.8, 0.1, Color(1, 0.4, 0, 1), 1.2)

func _make_mesh_node(parent: Node3D, mesh: Mesh, pos: Vector3,
					  rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = pos
	mi.rotation = rot
	parent.add_child(mi)
	return mi

func _set_mat(mi: MeshInstance3D, albedo: Color,
			  roughness: float = 0.7, metallic: float = 0.0,
			  emit: Color = Color.BLACK, emit_e: float = 0.0) -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = albedo
	mat.roughness = roughness
	mat.metallic = metallic
	if emit_e > 0.0:
		mat.emission_enabled = true
		mat.emission = emit
		mat.emission_energy_multiplier = emit_e
	mi.set_surface_override_material(0, mat)

func _finish() -> void:
	if is_transitioning:
		return
	is_transitioning = true
	var tw = create_tween()
	tw.tween_property(fade_rect, "modulate:a", 1.0, 0.8)
	await tw.finished
	emit_signal("cutscene_finished")
	var dest = next_scene if not next_scene.is_empty() else "res://Scenes/MainMenu.tscn"
	get_tree().change_scene_to_file(dest)
