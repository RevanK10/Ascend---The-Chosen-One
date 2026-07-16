extends Control

@onready var health_button: Button = $PanelContainer/VBoxContainer/UpgradeHealth
@onready var damage_button: Button = $PanelContainer/VBoxContainer/UpgradeDamage
@onready var speed_button: Button = $PanelContainer/VBoxContainer/UpgradeSpeed
@onready var cooldown_button: Button = $PanelContainer/VBoxContainer/UpgradeCooldown
@onready var pierce_button: Button = $PanelContainer/VBoxContainer/UpgradePierce
@onready var continue_button: Button = $PanelContainer/VBoxContainer/ContinueJourney
@onready var points_label: Label = $PanelContainer/VBoxContainer/PointsLabel
@onready var title_label: Label = $PanelContainer/VBoxContainer/TitleLabel
@onready var world_label: Label = $PanelContainer/VBoxContainer/WorldLabel


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	update_ui()

	health_button.pressed.connect(_buy_health)
	damage_button.pressed.connect(_buy_damage)
	speed_button.pressed.connect(_buy_speed)
	cooldown_button.pressed.connect(_buy_cooldown)
	pierce_button.pressed.connect(_buy_pierce)
	continue_button.pressed.connect(_continue_journey)


func _buy_health() -> void:
	CampaignManager.upgrade_health()
	update_ui()


func _buy_damage() -> void:
	CampaignManager.upgrade_damage()
	update_ui()


func _buy_speed() -> void:
	CampaignManager.upgrade_speed()
	update_ui()


func _buy_cooldown() -> void:
	CampaignManager.upgrade_cooldown()
	update_ui()


func _buy_pierce() -> void:
	CampaignManager.upgrade_pierce()
	update_ui()


func _continue_journey() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	load_next_world_scene()


func load_next_world_scene() -> void:
	var world_name: String = CampaignManager.get_current_world()
	var next_scene := "res://Scenes/Worlds/%s.tscn" % world_name

	if ResourceLoader.exists(next_scene):
		get_tree().change_scene_to_file(next_scene)
	else:
		print("Missing world scene:", next_scene)


func update_ui() -> void:
	var world_name = CampaignManager.get_current_world()
	if CampaignManager.is_arcade_mode:
		title_label.text = "⚔  ARCADE UPGRADE  ⚔"
		world_label.text = "Arcade Wave %d  |  Score %d\nDefeated %d enemies last wave" % [CampaignManager.arcade_wave, CampaignManager.arcade_score, CampaignManager.last_wave_kills]
	else:
		world_label.text = "Next World: %s  |  Wave %d\nDefeated %d enemies last wave" % [world_name, CampaignManager.current_wave, CampaignManager.last_wave_kills]
	points_label.text = "Upgrade Points: %d" % CampaignManager.upgrade_points

	health_button.text = "❤ Health +20  (Cost: %d)" % CampaignManager.health_upgrade_cost
	damage_button.text = "🗡 Damage +10  (Cost: %d)" % CampaignManager.damage_upgrade_cost
	speed_button.text = "⚡ Speed +1    (Cost: %d)" % CampaignManager.speed_upgrade_cost
	cooldown_button.text = "⏱ Faster Throw  (Cost: %d)" % CampaignManager.cooldown_upgrade_cost
	pierce_button.text = "Piercing Spear (OWNED)" if CampaignManager.spear_pierce_unlocked else "➤ Piercing Spear  (Cost: %d)" % CampaignManager.pierce_upgrade_cost

	health_button.disabled = CampaignManager.upgrade_points < CampaignManager.health_upgrade_cost
	damage_button.disabled = CampaignManager.upgrade_points < CampaignManager.damage_upgrade_cost
	speed_button.disabled = CampaignManager.upgrade_points < CampaignManager.speed_upgrade_cost
	cooldown_button.disabled = CampaignManager.upgrade_points < CampaignManager.cooldown_upgrade_cost
	pierce_button.disabled = CampaignManager.spear_pierce_unlocked or CampaignManager.upgrade_points < CampaignManager.pierce_upgrade_cost
