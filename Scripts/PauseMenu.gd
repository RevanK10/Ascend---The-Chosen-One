extends Control

@onready var resume_button: Button = $Panel/VBoxContainer/ResumeButton
@onready var menu_button: Button = $Panel/VBoxContainer/MainMenuButton
@onready var quit_button: Button = $Panel/VBoxContainer/QuitButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	resume_button.pressed.connect(_resume)
	menu_button.pressed.connect(_main_menu)
	quit_button.pressed.connect(_quit)


func _resume() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	queue_free()

func _main_menu() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _quit() -> void:
	get_tree().paused = false
	get_tree().quit()
