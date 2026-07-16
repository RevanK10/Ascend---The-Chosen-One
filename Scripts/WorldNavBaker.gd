extends Node3D

func _ready() -> void:
	
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	var nav = get_parent().get_node_or_null("NavigationRegion3D") as NavigationRegion3D
	if nav:
		nav.bake_navigation_mesh(false)
	else:
		push_warning("WorldNavBaker: no NavigationRegion3D found in parent")
