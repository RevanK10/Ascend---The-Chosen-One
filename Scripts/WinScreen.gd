extends Control

@onready var play_again_button = $PanelContainer/VBoxContainer/PlayAgainButton
@onready var main_menu_button = $PanelContainer/VBoxContainer/MainMenuButton
@onready var quit_button = $PanelContainer/VBoxContainer/QuitButton


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	play_again_button.pressed.connect(_play_again)
	main_menu_button.pressed.connect(_main_menu)
	quit_button.pressed.connect(_quit)


func _play_again():
	CampaignManager.reset()
	CampaignManager.intro_shown = true
	get_tree().change_scene_to_file("res://Scenes/Worlds/Heaven.tscn")


func _main_menu():
	CampaignManager.reset()
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")


func _quit():
	get_tree().quit()
