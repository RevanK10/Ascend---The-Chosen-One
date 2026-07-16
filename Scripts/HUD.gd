extends CanvasLayer

var player: Node = null
var current_boss: BaseEnemy = null
var hit_marker_timer: float = 0.0
var damage_dir_timer: float = 0.0

func _ready() -> void:
	add_to_group("hud")
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

func show_hit_marker(is_headshot: bool) -> void:
	hit_marker_timer = 0.25
	$HitMarker.modulate = Color(1, 0.25, 0.2, 1) if is_headshot else Color(1, 1, 1, 0.9)
	$HitMarker.visible = true

func show_damage_direction(angle_rad: float) -> void:
	damage_dir_timer = 0.5
	var deg := rad_to_deg(wrapf(angle_rad, -PI, PI))
	$DamageIndicatorFront.visible = deg > -45.0 and deg <= 45.0
	$DamageIndicatorRight.visible = deg > 45.0 and deg <= 135.0
	$DamageIndicatorLeft.visible = deg < -45.0 and deg >= -135.0
	$DamageIndicatorBack.visible = deg > 135.0 or deg < -135.0

func _process(delta: float) -> void:
	$DarknessOverlay.visible = CampaignManager.has_modifier("darkness")

	if hit_marker_timer > 0.0:
		hit_marker_timer -= delta
		if hit_marker_timer <= 0.0:
			$HitMarker.visible = false

	if damage_dir_timer > 0.0:
		damage_dir_timer -= delta
		if damage_dir_timer <= 0.0:
			$DamageIndicatorFront.visible = false
			$DamageIndicatorRight.visible = false
			$DamageIndicatorLeft.visible = false
			$DamageIndicatorBack.visible = false

	if not player:
		player = get_tree().get_first_node_in_group("player")
		return

	$HealthLabel.text = "HP: %d / %d" % [player.current_health, CampaignManager.max_health]
	$DamageLabel.text = "Spear: %d dmg" % CampaignManager.spear_damage
	$WorldLabel.text = "World: %s" % CampaignManager.get_current_world()
	$LevelLabel.text = "Wave: %d / 10" % CampaignManager.current_wave
	$UpgradeLabel.text = "Points: %d" % CampaignManager.upgrade_points

	$HealthBar.max_value = CampaignManager.max_health
	$HealthBar.value = player.current_health

	_update_boss_hp()

func _update_boss_hp() -> void:
	if not is_instance_valid(current_boss):
		current_boss = null
		for b in get_tree().get_nodes_in_group("boss_enemy"):
			if is_instance_valid(b) and not (b as BaseEnemy).is_dying:
				current_boss = b as BaseEnemy
				break

	if current_boss == null:
		$BossNameLabel.visible = false
		$BossHealthBar.visible = false
		return

	$BossNameLabel.visible = true
	$BossHealthBar.visible = true
	$BossNameLabel.text = current_boss.boss_display_name if current_boss.boss_display_name != "" else "Boss"
	$BossHealthBar.max_value = current_boss.max_health
	$BossHealthBar.value = current_boss.current_health
