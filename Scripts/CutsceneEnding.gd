extends "res://Scripts/CinematicCutscene.gd"

func _ready() -> void:
	next_scene = "res://Scenes/WinScreen.tscn"
	shots = [
	{
		"cam_pos": Vector3(0, 2.2, 6.0), "cam_look": Vector3(0, 1.6, 0),
		"duration": 5.5, "bg_light": Color(0.8, 0.2, 0.05, 1), "bg_light_e": 1.5,
		"subtitle": "You stand before the Demon King on his burning throne. The source of all corruption. The grief given form. The first and last darkness.",
		"speaker": "",
		"characters": [
			{"id": "warrior",    "pos": Vector3(1.8, 0, 0),  "rot_y": -30},
			{"id": "demon_king", "pos": Vector3(-1.5, 0, 0), "rot_y": 20}
		]
	},
	{
		"cam_pos": Vector3(-1.4, 2.2, 2.5), "cam_look": Vector3(-1.5, 2.0, 0),
		"duration": 5.5, "bg_light": Color(0.9, 0.25, 0.0, 1), "bg_light_e": 2.0,
		"subtitle": "\"So you actually came. Four realms freed. My generals shattered. I underestimated you, mortal. But this realm is mine. And you will not leave it.\"",
		"speaker": "The Demon King",
		"characters": [
			{"id": "warrior",    "pos": Vector3(1.8, 0, 0),  "rot_y": -30},
			{"id": "demon_king", "pos": Vector3(-1.5, 0, 0), "rot_y": 20}
		]
	},
	{
		"cam_pos": Vector3(1.5, 1.8, 2.2), "cam_look": Vector3(1.8, 1.8, 0),
		"duration": 5.0, "bg_light": Color(0.7, 0.2, 0.05, 1), "bg_light_e": 1.4,
		"subtitle": "\"You corrupted five realms. You enslaved angels, sages, soldiers, and serpents. You turned an entire world against itself because of your own grief. It ends here.\"",
		"speaker": "The Warrior",
		"characters": [
			{"id": "warrior",    "pos": Vector3(1.8, 0, 0),  "rot_y": -30},
			{"id": "demon_king", "pos": Vector3(-1.5, 0, 0), "rot_y": 20}
		]
	},
	{
		"cam_pos": Vector3(3.0, 2.5, 5.0), "cam_look": Vector3(0, 1.5, 0),
		"duration": 5.0, "bg_light": Color(1.0, 0.3, 0.0, 1), "bg_light_e": 2.2,
		"subtitle": "The Sacred Spear ignites — every realm it has freed pouring its light into the blade. You charge.",
		"speaker": "",
		"characters": [
			{"id": "warrior",    "pos": Vector3(1.8, 0, 0),  "rot_y": -40},
			{"id": "demon_king", "pos": Vector3(-1.5, 0, 0), "rot_y": 30}
		]
	},
	{
		"cam_pos": Vector3(-1.2, 2.0, 2.0), "cam_look": Vector3(-1.5, 1.8, 0),
		"duration": 6.0, "bg_light": Color(1.0, 0.8, 0.5, 1), "bg_light_e": 3.0,
		"subtitle": "The spear finds its mark. The corruption — every thread of it across all five realms — fractures at once. A light erupts from Hell itself, white and clean and absolute.",
		"speaker": "",
		"characters": [
			{"id": "warrior",    "pos": Vector3(1.8, 0, 0),  "rot_y": -40},
			{"id": "demon_king", "pos": Vector3(-1.5, 0, 0), "rot_y": 30}
		]
	},
	{
		"cam_pos": Vector3(-1.0, 2.0, 2.2), "cam_look": Vector3(-1.5, 1.9, 0),
		"duration": 6.0, "bg_light": Color(0.9, 0.85, 0.7, 1), "bg_light_e": 2.0,
		"subtitle": "\"I... remember. I was not always this. I grieved. I lost someone. And I let that grief consume creation itself. You... were right to end this. I am sorry.\"",
		"speaker": "The Demon King — freed",
		"characters": [
			{"id": "warrior",    "pos": Vector3(1.8, 0, 0),  "rot_y": -35},
			{"id": "demon_king", "pos": Vector3(-1.5, 0, 0), "rot_y": 25}
		]
	},
	{
		"cam_pos": Vector3(1.5, 1.8, 2.2), "cam_look": Vector3(1.8, 1.7, 0),
		"duration": 5.0, "bg_light": Color(0.85, 0.82, 0.70, 1), "bg_light_e": 1.8,
		"subtitle": "\"Rest. All five realms are free because of what just ended here. They won't forget.\"",
		"speaker": "The Warrior",
		"characters": [
			{"id": "warrior",    "pos": Vector3(1.8, 0, 0),  "rot_y": -30},
			{"id": "demon_king", "pos": Vector3(-1.5, 0, 0), "rot_y": 20}
		]
	},
	{
		"cam_pos": Vector3(0, 2.5, 7.0), "cam_look": Vector3(0, 1.5, 0),
		"duration": 6.0, "bg_light": Color(0.85, 0.90, 1.0, 1), "bg_light_e": 2.5,
		"subtitle": "The freed leaders of all five realms gather before you. Heaven sings again. The Astral Plane remembers. Humanity wakes. The Serpent Realm breathes. Hell's chains are lifted.",
		"speaker": "",
		"characters": [
			{"id": "warrior",   "pos": Vector3(0, 0, 0),    "rot_y": 180},
			{"id": "archangel", "pos": Vector3(-2.5, 0, 1.0), "rot_y": 30},
			{"id": "void_lord", "pos": Vector3(-1.2, 0, 1.5), "rot_y": 25},
			{"id": "warlord",   "pos": Vector3(1.2, 0, 1.5),  "rot_y": -25},
			{"id": "sage",      "pos": Vector3(2.5, 0, 1.0),  "rot_y": -30}
		]
	},
	{
		"cam_pos": Vector3(0, 1.8, 4.0), "cam_look": Vector3(-2.0, 1.8, 0),
		"duration": 6.0, "bg_light": Color(0.90, 0.92, 1.0, 1), "bg_light_e": 2.8,
		"subtitle": "\"Chosen One. Heaven has no guardian. It has not had one since the corruption took our last. We offer you its throne — not as a reward. Because you have already proven you are the only one worthy of it.\"",
		"speaker": "Archangel — freed",
		"characters": [
			{"id": "warrior",   "pos": Vector3(0, 0, 0),    "rot_y": 180},
			{"id": "archangel", "pos": Vector3(-2.5, 0, 1.0), "rot_y": 30},
			{"id": "sage",      "pos": Vector3(2.5, 0, 1.0),  "rot_y": -30}
		]
	},
	{
		"cam_pos": Vector3(0.2, 1.75, 1.6), "cam_look": Vector3(0, 1.75, 0),
		"duration": 6.0, "bg_light": Color(0.90, 0.92, 1.0, 1), "bg_light_e": 2.5,
		"subtitle": "You accept. Not with pride. With the quiet knowledge that someone must watch over the Five Realms — and you have already seen every one of them at their worst, and loved them still enough to fight.",
		"speaker": "",
		"characters": [
			{"id": "warrior",   "pos": Vector3(0, 0, 0), "rot_y": 0}
		]
	},
	{
		"cam_pos": Vector3(0, 3.5, 9.0), "cam_look": Vector3(0, 1.5, 0),
		"duration": 6.0, "bg_light": Color(0.95, 0.95, 1.0, 1), "bg_light_e": 3.0,
		"subtitle": "The throne of Heaven is yours. The Five Realms are free. The corruption is gone.\n\nThank you, Warrior. Thank you for everything.",
		"speaker": "",
		"characters": [
			{"id": "warrior",   "pos": Vector3(0, 0, 0),     "rot_y": 0},
			{"id": "archangel", "pos": Vector3(-2.5, 0, 1.5), "rot_y": 25},
			{"id": "void_lord", "pos": Vector3(-1.3, 0, 2.0), "rot_y": 20},
			{"id": "warlord",   "pos": Vector3(1.3, 0, 2.0),  "rot_y": -20},
			{"id": "sage",      "pos": Vector3(2.5, 0, 1.5),  "rot_y": -25}
		]
	},
	]
	super._ready()
