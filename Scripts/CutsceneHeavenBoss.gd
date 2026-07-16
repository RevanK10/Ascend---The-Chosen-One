extends "res://Scripts/CinematicCutscene.gd"

func _ready() -> void:
	next_scene = "res://Scenes/UpgradeMenu.tscn"
	shots = [
	{
		"cam_pos": Vector3(0, 2.0, 5.0), "cam_look": Vector3(0, 1.5, 0),
		"duration": 5.0, "bg_light": Color(0.8, 0.85, 1.0, 1), "bg_light_e": 1.8,
		"subtitle": "The Archangel falls. As its corrupted form dissolves, the sky above Heaven — sealed in darkness for centuries — cracks open. Light pours through.",
		"speaker": "",
		"characters": [
			{"id": "warrior",   "pos": Vector3(1.5, 0, 0),  "rot_y": -20},
			{"id": "archangel", "pos": Vector3(-1.2, 0, 0), "rot_y": 15}
		]
	},
	{
		"cam_pos": Vector3(-1.0, 2.0, 2.0), "cam_look": Vector3(-1.2, 1.8, 0),
		"duration": 5.5, "bg_light": Color(0.9, 0.92, 1.0, 1), "bg_light_e": 2.0,
		"subtitle": "\"Warrior... I remember now. I remember who I was before the darkness took me. You gave that back to me.\"",
		"speaker": "Archangel — freed",
		"characters": [
			{"id": "warrior",   "pos": Vector3(1.5, 0, 0),  "rot_y": -30},
			{"id": "archangel", "pos": Vector3(-1.2, 0, 0), "rot_y": 10}
		]
	},
	{
		"cam_pos": Vector3(1.2, 1.7, 2.0), "cam_look": Vector3(1.5, 1.7, 0),
		"duration": 4.5, "bg_light": Color(0.85, 0.88, 1.0, 1), "bg_light_e": 1.9,
		"subtitle": "\"Heaven is free. But the corruption didn't start here. Where does it lead?\"",
		"speaker": "The Warrior",
		"characters": [
			{"id": "warrior",   "pos": Vector3(1.5, 0, 0),  "rot_y": -20},
			{"id": "archangel", "pos": Vector3(-1.2, 0, 0), "rot_y": 10}
		]
	},
	{
		"cam_pos": Vector3(0, 1.5, 4.5), "cam_look": Vector3(-0.6, 1.3, 0),
		"duration": 5.0, "bg_light": Color(0.8, 0.84, 1.0, 1), "bg_light_e": 1.6,
		"subtitle": "\"It came from below. From the Astral Plane. Descend, Chosen One. Four realms still wait for you.\"",
		"speaker": "Archangel — freed",
		"characters": [
			{"id": "warrior",   "pos": Vector3(1.5, 0, 0),  "rot_y": -25},
			{"id": "archangel", "pos": Vector3(-1.2, 0, 0), "rot_y": 20}
		]
	},
	]
	super._ready()
