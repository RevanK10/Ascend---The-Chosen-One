extends Control

@onready var retry_button = $PanelContainer/VBoxContainer/RetryButton
@onready var menu_button = $PanelContainer/VBoxContainer/MainMenuButton
@onready var quit_button = $PanelContainer/VBoxContainer/QuitButton


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if CampaignManager.is_arcade_mode:
		retry_button.text = "Play Arcade Again"

	retry_button.pressed.connect(_retry)
	menu_button.pressed.connect(_main_menu)
	quit_button.pressed.connect(_quit)


func _retry():
	if CampaignManager.is_arcade_mode:
		CampaignManager.start_arcade()
		get_tree().change_scene_to_file("res://Scenes/Worlds/%s.tscn" % CampaignManager.get_current_world())
		return

	CampaignManager.load_checkpoint()
	var world_name = CampaignManager.get_current_world()
	get_tree().change_scene_to_file(
		"res://Scenes/Worlds/%s.tscn" % world_name
	)


func _main_menu():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _quit():
	get_tree().quit()
