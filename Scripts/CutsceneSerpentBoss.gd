extends "res://Scripts/CinematicCutscene.gd"

func _ready() -> void:
	next_scene = "res://Scenes/UpgradeMenu.tscn"
	shots = [
	{
		"cam_pos": Vector3(0, 2.0, 5.5), "cam_look": Vector3(0, 1.5, 0),
		"duration": 5.0, "bg_light": Color(0.08, 0.45, 0.05, 1), "bg_light_e": 1.2,
		"subtitle": "The Serpent King lets out one final, earth-shaking hiss. Then — silence. For the first time in centuries, clean air moves through the Serpent Realm.",
		"speaker": "",
		"characters": [
			{"id": "warrior",      "pos": Vector3(1.5, 0, 0),  "rot_y": -20},
			{"id": "serpent_king", "pos": Vector3(-1.4, 0, 0), "rot_y": 15}
		]
	},
	{
		"cam_pos": Vector3(-1.3, 2.0, 2.3), "cam_look": Vector3(-1.4, 1.9, 0),
		"duration": 5.5, "bg_light": Color(0.10, 0.50, 0.06, 1), "bg_light_e": 1.3,
		"subtitle": "\"You... are stronger than I was told. The Demon King said no mortal could reach us. He underestimated what that spear truly is.\"",
		"speaker": "Serpent King — freed",
		"characters": [
			{"id": "warrior",      "pos": Vector3(1.5, 0, 0),  "rot_y": -30},
			{"id": "serpent_king", "pos": Vector3(-1.4, 0, 0), "rot_y": 10}
		]
	},
	{
		"cam_pos": Vector3(1.2, 1.7, 2.0), "cam_look": Vector3(1.5, 1.7, 0),
		"duration": 4.5, "bg_light": Color(0.08, 0.42, 0.05, 1), "bg_light_e": 1.1,
		"subtitle": "\"The Demon King knew I was coming? He's been watching?\"",
		"speaker": "The Warrior",
		"characters": [
			{"id": "warrior",      "pos": Vector3(1.5, 0, 0),  "rot_y": -20},
			{"id": "serpent_king", "pos": Vector3(-1.4, 0, 0), "rot_y": 10}
		]
	},
	{
		"cam_pos": Vector3(0, 1.6, 4.8), "cam_look": Vector3(-0.7, 1.4, 0),
		"duration": 5.5, "bg_light": Color(0.06, 0.35, 0.04, 1), "bg_light_e": 0.9,
		"subtitle": "\"Since the moment you touched the spear. He is afraid of you. That is why he corrupted all five realms — to stop you from ever reaching him. Go. And end this. The Sacred Spear was made for this exact moment.\"",
		"speaker": "Serpent King — freed",
		"characters": [
			{"id": "warrior",      "pos": Vector3(1.5, 0, 0),  "rot_y": -25},
			{"id": "serpent_king", "pos": Vector3(-1.4, 0, 0), "rot_y": 20}
		]
	},
	]
	super._ready()
