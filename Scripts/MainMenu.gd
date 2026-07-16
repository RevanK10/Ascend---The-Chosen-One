extends Control

func _ready():
	$VBoxContainer/StartButton.pressed.connect(_start_game)
	$VBoxContainer/ContinueButton.visible = CampaignManager.has_save()
	$VBoxContainer/ContinueButton.pressed.connect(_continue_game)
	$VBoxContainer/ArcadeButton.pressed.connect(_start_arcade)
	$VBoxContainer/QuitButton.pressed.connect(_quit_game)

func _start_game():
	if not CampaignManager.intro_shown:
		CampaignManager.intro_shown = true
		get_tree().change_scene_to_file("res://Scenes/CutsceneIntro.tscn")
	else:
		CampaignManager.reset()
		get_tree().change_scene_to_file("res://Scenes/Worlds/Heaven.tscn")

func _continue_game():
	get_tree().change_scene_to_file("res://Scenes/Worlds/%s.tscn" % CampaignManager.get_current_world())

func _start_arcade():
	CampaignManager.start_arcade()
	get_tree().change_scene_to_file("res://Scenes/Worlds/%s.tscn" % CampaignManager.get_current_world())

func _quit_game():
	get_tree().quit()
