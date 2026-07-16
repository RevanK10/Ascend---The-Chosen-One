extends "res://Scripts/CinematicCutscene.gd"

func _ready() -> void:
	next_scene = "res://Scenes/UpgradeMenu.tscn"
	shots = [
	{
		"cam_pos": Vector3(0, 2.0, 5.5), "cam_look": Vector3(0, 1.5, 0),
		"duration": 5.0, "bg_light": Color(0.65, 0.60, 0.45, 1), "bg_light_e": 1.5,
		"subtitle": "The Warlord falls. Around the battlefield, men and women stop mid-charge. Their eyes go clear — confused, lost. As if waking from a dream they cannot remember.",
		"speaker": "",
		"characters": [
			{"id": "warrior",  "pos": Vector3(1.5, 0, 0),  "rot_y": -20},
			{"id": "warlord",  "pos": Vector3(-1.3, 0, 0), "rot_y": 15}
		]
	},
	{
		"cam_pos": Vector3(-1.2, 1.9, 2.2), "cam_look": Vector3(-1.3, 1.8, 0),
		"duration": 5.5, "bg_light": Color(0.70, 0.65, 0.50, 1), "bg_light_e": 1.6,
		"subtitle": "\"I... I remember my family. My home. I was building a house. Then the darkness came and I... I became something else. Something angry.\"",
		"speaker": "Warlord — freed",
		"characters": [
			{"id": "warrior",  "pos": Vector3(1.5, 0, 0),  "rot_y": -30},
			{"id": "warlord",  "pos": Vector3(-1.3, 0, 0), "rot_y": 12}
		]
	},
	{
		"cam_pos": Vector3(1.2, 1.7, 2.0), "cam_look": Vector3(1.5, 1.7, 0),
		"duration": 4.5, "bg_light": Color(0.65, 0.60, 0.45, 1), "bg_light_e": 1.4,
		"subtitle": "\"Go home. Your world is free now. The corruption came from the Serpent Realm — something older, something primal. I have to go deeper.\"",
		"speaker": "The Warrior",
		"characters": [
			{"id": "warrior",  "pos": Vector3(1.5, 0, 0),  "rot_y": -20},
			{"id": "warlord",  "pos": Vector3(-1.3, 0, 0), "rot_y": 12}
		]
	},
	{
		"cam_pos": Vector3(0.5, 1.6, 4.8), "cam_look": Vector3(0.7, 1.4, 0),
		"duration": 5.0, "bg_light": Color(0.6, 0.55, 0.40, 1), "bg_light_e": 1.2,
		"subtitle": "\"Take this knowledge with you, warrior. The Serpent King has been feeding the corruption into our world for a hundred years. It knew you were coming. It will not go quietly.\"",
		"speaker": "Warlord — freed",
		"characters": [
			{"id": "warrior",  "pos": Vector3(1.5, 0, 0),  "rot_y": -25},
			{"id": "warlord",  "pos": Vector3(-1.3, 0, 0), "rot_y": 20}
		]
	},
	]
	super._ready()
