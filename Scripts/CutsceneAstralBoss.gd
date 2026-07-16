extends "res://Scripts/CinematicCutscene.gd"

func _ready() -> void:
	next_scene = "res://Scenes/UpgradeMenu.tscn"
	shots = [
	{
		"cam_pos": Vector3(0, 2.0, 5.5), "cam_look": Vector3(0, 1.5, 0),
		"duration": 5.0, "bg_light": Color(0.35, 0.1, 0.8, 1), "bg_light_e": 1.4,
		"subtitle": "The Void Lord shatters. The maddening hum that filled the Astral Plane — the sound of a thousand corrupted minds — goes silent. And in the silence, the stars return.",
		"speaker": "",
		"characters": [
			{"id": "warrior",   "pos": Vector3(1.5, 0, 0),  "rot_y": -20},
			{"id": "void_lord", "pos": Vector3(-1.3, 0, 0), "rot_y": 15}
		]
	},
	{
		"cam_pos": Vector3(-1.2, 1.9, 2.2), "cam_look": Vector3(-1.3, 1.8, 0),
		"duration": 5.5, "bg_light": Color(0.4, 0.15, 0.85, 1), "bg_light_e": 1.6,
		"subtitle": "\"I was a keeper of ancient wisdom. The corruption hollowed me out and filled me with nothing but hunger. You... restored what I was. I can feel knowledge returning.\"",
		"speaker": "Void Lord — freed",
		"characters": [
			{"id": "warrior",   "pos": Vector3(1.5, 0, 0),  "rot_y": -30},
			{"id": "void_lord", "pos": Vector3(-1.3, 0, 0), "rot_y": 12}
		]
	},
	{
		"cam_pos": Vector3(1.2, 1.7, 2.0), "cam_look": Vector3(1.5, 1.7, 0),
		"duration": 4.5, "bg_light": Color(0.3, 0.1, 0.75, 1), "bg_light_e": 1.2,
		"subtitle": "\"Where did the corruption flow from here? I need to trace it to its source.\"",
		"speaker": "The Warrior",
		"characters": [
			{"id": "warrior",   "pos": Vector3(1.5, 0, 0),  "rot_y": -20},
			{"id": "void_lord", "pos": Vector3(-1.3, 0, 0), "rot_y": 12}
		]
	},
	{
		"cam_pos": Vector3(0, 1.6, 4.8), "cam_look": Vector3(-0.5, 1.4, 0),
		"duration": 5.5, "bg_light": Color(0.28, 0.08, 0.7, 1), "bg_light_e": 1.1,
		"subtitle": "\"It flowed down into the Human World like a river. The mortals there — they do not know what hunts them. They have been made into soldiers for the darkness without ever understanding why.\"",
		"speaker": "Void Lord — freed",
		"characters": [
			{"id": "warrior",   "pos": Vector3(1.5, 0, 0),  "rot_y": -25},
			{"id": "void_lord", "pos": Vector3(-1.3, 0, 0), "rot_y": 20}
		]
	},
	]
	super._ready()
