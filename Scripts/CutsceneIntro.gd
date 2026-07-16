extends "res://Scripts/CinematicCutscene.gd"

func _ready() -> void:
	next_scene = "res://Scenes/Worlds/Heaven.tscn"


	shots = [
	{
		"cam_pos": Vector3(0, 1.5, 5.5), "cam_look": Vector3(0, 1.2, 0),
		"duration": 5.5, "bg_light": Color(0.15, 0.15, 0.25, 1), "bg_light_e": 0.5,
		"subtitle": "Before time had a name, the Five Realms existed in perfect balance.",
		"speaker": "",
		"characters": [
			{"id": "warrior", "pos": Vector3(0, 0, 0), "rot_y": 0}
		]
	},

	{
		"cam_pos": Vector3(0.3, 1.75, 1.6), "cam_look": Vector3(0, 1.75, 0),
		"duration": 5.0, "bg_light": Color(0.2, 0.18, 0.3, 1), "bg_light_e": 0.7,
		"subtitle": "Heaven sang. The Astral Plane shimmered. The Human World thrived. And Hell was bound by sacred chains.",
		"speaker": "",
		"characters": [
			{"id": "warrior", "pos": Vector3(0, 0, 0), "rot_y": 5}
		]
	},
	{
		"cam_pos": Vector3(-1.5, 1.5, 4.0), "cam_look": Vector3(0, 1.2, 0),
		"duration": 6.0, "bg_light": Color(0.2, 0.25, 0.35, 1), "bg_light_e": 0.9,
		"subtitle": "Then a corruption was born — born not from chaos, but from grief. It twisted angels, broke guardians, drove the demons of Hell to madness.",
		"speaker": "",
		"characters": [
			{"id": "warrior", "pos": Vector3(1.2, 0, 0),  "rot_y": -25},
			{"id": "sage",    "pos": Vector3(-1.0, 0, 0), "rot_y": 30}
		]
	},
	
	{
		"cam_pos": Vector3(1.4, 1.7, 2.2), "cam_look": Vector3(-0.8, 1.5, 0),
		"duration": 6.0, "bg_light": Color(0.25, 0.3, 0.4, 1), "bg_light_e": 1.0,
		"subtitle": "\"The last sage of the Astral Plane foresaw you. One warrior. Born mortal. Carrying divine fire. They will begin at Heaven's broken gates and fight their way down to Hell itself.\"",
		"speaker": "Sage of the Astral",
		"characters": [
			{"id": "warrior", "pos": Vector3(1.2, 0, 0),  "rot_y": -25},
			{"id": "sage",    "pos": Vector3(-1.0, 0, 0), "rot_y": 30}
		]
	},
	{
		"cam_pos": Vector3(0.8, 1.2, 1.8), "cam_look": Vector3(0.5, 1.4, 0),
		"duration": 5.5, "bg_light": Color(0.3, 0.4, 0.6, 1), "bg_light_e": 1.2,
		"subtitle": "\"This Sacred Spear was the last divine weapon forged before the corruption fell. It chose you. No one else can wield it.\"",
		"speaker": "Sage of the Astral",
		"characters": [
			{"id": "warrior", "pos": Vector3(0, 0, 0), "rot_y": -10}
		]
	},

	{
		"cam_pos": Vector3(-0.4, 1.7, 1.8), "cam_look": Vector3(0, 1.7, 0),
		"duration": 5.0, "bg_light": Color(0.35, 0.4, 0.55, 1), "bg_light_e": 1.1,
		"subtitle": "\"I didn't ask for this. I found the spear buried beneath the ruins of my village. When I touched it — I saw everything. Every realm. Every soul trapped inside the darkness.\"",
		"speaker": "The Chosen Warrior",
		"characters": [
			{"id": "warrior", "pos": Vector3(0, 0, 0), "rot_y": 0}
		]
	},

	{
		"cam_pos": Vector3(1.2, 1.6, 3.0), "cam_look": Vector3(-0.5, 1.3, 0),
		"duration": 5.5, "bg_light": Color(0.2, 0.22, 0.35, 1), "bg_light_e": 0.8,
		"subtitle": "\"Then you already know what must be done. Five realms. Five corrupted rulers. You are the only one who can purge the darkness. Begin at the palace of Heaven.\"",
		"speaker": "Sage of the Astral",
		"characters": [
			{"id": "warrior", "pos": Vector3(1.2, 0, 0),  "rot_y": -30},
			{"id": "sage",    "pos": Vector3(-1.0, 0, 0), "rot_y": 25}
		]
	},
	{
		"cam_pos": Vector3(0, 1.8, 6.0), "cam_look": Vector3(0, 1.3, 0),
		"duration": 4.5, "bg_light": Color(0.15, 0.18, 0.30, 1), "bg_light_e": 0.6,
		"subtitle": "Five realms are waiting. Do not let them fall.",
		"speaker": "",
		"characters": [
			{"id": "warrior", "pos": Vector3(0, 0, 0), "rot_y": 180}
		]
	},
	]
	super._ready()
