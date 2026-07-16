extends "res://Scripts/WorldProps.gd"

func build_props() -> void:
	var MARBLE   = Color(0.90, 0.91, 0.95, 1)   
	var MARBLE_D = Color(0.72, 0.74, 0.80, 1)   
	var GOLD     = Color(0.80, 0.68, 0.20, 1)   
	var GOLD_B   = Color(0.92, 0.80, 0.28, 1)   
	var DEAD_W   = Color(0.52, 0.46, 0.36, 1)   
	var MOSS     = Color(0.28, 0.38, 0.24, 1)   
	var RUBBLE   = Color(0.62, 0.60, 0.65, 1)   
	var SKIN     = Color(0.78, 0.68, 0.56, 1)   

	make_box(Vector3(0, 0.3, -30), Vector3(32, 0.65, 44), MARBLE, 0.15, 0.25)
	
	make_box(Vector3(0, 0.65, -50), Vector3(22, 0.5, 14), MARBLE, 0.15, 0.22)
	make_box(Vector3(0, 1.0, -51), Vector3(16, 0.4, 10), MARBLE, 0.15, 0.20)


	make_box(Vector3(0, 7, -57), Vector3(34, 14, 1.4), MARBLE_D, 0.1, 0.35)
	make_box(Vector3(0, 4.2, -57), Vector3(34, 0.6, 1.6), GOLD, 0.7, 0.25)
	make_box(Vector3(0, 9.8, -57), Vector3(34, 0.6, 1.6), GOLD, 0.7, 0.25)
	
	make_box(Vector3(-16, 7, -38), Vector3(1.4, 14, 40), MARBLE_D, 0.1, 0.35)
	make_box(Vector3(-16, 4.2, -38), Vector3(1.6, 0.5, 40), GOLD, 0.7, 0.25)
	
	make_box(Vector3(16, 5, -35), Vector3(1.4, 10, 34), MARBLE_D, 0.1, 0.38)
	
	make_box(Vector3(0, 8, -8), Vector3(22, 16, 1.4), MARBLE_D, 0.1, 0.35)

	var col_xs = [-13.0, -8.0, 8.0, 13.0]
	var col_zs = [-13.0, -22.0, -34.0, -46.0]
	for cx in col_xs:
		for cz in col_zs:
			var col_id = str(cx) + str(cz)
			
			make_box(Vector3(cx, 0.22, cz), Vector3(1.9, 0.45, 1.9), MARBLE, 0.15, 0.2)
			
			make_cyl(Vector3(cx, 5.7, cz), 0.78, 10.5, MARBLE, 0.12, 0.22)
			
			make_box(Vector3(cx, 11.2, cz), Vector3(2.1, 0.75, 2.1), MARBLE, 0.15, 0.2)
			make_box(Vector3(cx, 11.75, cz), Vector3(1.8, 0.5, 1.8), GOLD, 0.75, 0.2)
	
	make_cyl(Vector3(9.5, 0.78, -40), 0.78, 11.0, Color(0.68, 0.70, 0.78, 1), 0.1, 0.35,
			 Color.BLACK, 0, Vector3(0, 0.4, PI * 0.5))
	
	make_box(Vector3(-13, 8.5, -46), Vector3(1.9, 4.0, 1.9), RUBBLE, 0.05, 0.45)

	make_box(Vector3(-4.5, 5, -8), Vector3(1.4, 10, 1.4), MARBLE, 0.12, 0.22)
	make_box(Vector3(4.5, 5, -8),  Vector3(1.4, 10, 1.4), MARBLE, 0.12, 0.22)
	make_box(Vector3(0, 10.5, -8), Vector3(10, 1.2, 1.4), MARBLE, 0.12, 0.22)
	make_box(Vector3(0, 10.5, -8), Vector3(10, 0.45, 1.6), GOLD, 0.75, 0.22)

	
	make_box(Vector3(0, 1.52, -53), Vector3(3.8, 0.65, 2.8), GOLD_B, 0.8, 0.15)
	
	make_box(Vector3(0, 4.2, -55.2), Vector3(3.8, 4.6, 0.45), GOLD, 0.78, 0.18)
	make_box(Vector3(0, 6.1, -55.2), Vector3(2.4, 0.8, 0.5), GOLD_B, 0.85, 0.12)
	
	make_box(Vector3(-1.9, 2.3, -53), Vector3(0.4, 1.2, 2.8), GOLD, 0.78, 0.2)
	make_box(Vector3(1.9, 2.3, -53),  Vector3(0.4, 1.2, 2.8), GOLD, 0.78, 0.2)
	
	for sx in [-1.6, 1.6]:
		for sz in [-1.2, 1.2]:
			make_cyl(Vector3(sx, 0.6, -53 + sz), 0.12, 1.2, GOLD_B, 0.82, 0.15)
	
	make_box(Vector3(0, 1.87, -53), Vector3(3.0, 0.22, 2.2), Color(0.45, 0.06, 0.06, 1), 0.0, 0.95)

	for sx in [-6.0, 6.0]:
		
		make_cyl(Vector3(sx, 1.0, -52), 0.38, 2.0, MARBLE, 0.12, 0.25)
		
		make_sphere(Vector3(sx, 2.28, -52), 0.28, MARBLE, 0.12, 0.25)
		
		make_box(Vector3(sx - 0.7, 1.5, -52.1), Vector3(0.8, 1.5, 0.08), MARBLE, 0.12, 0.22,
				 Color.BLACK, 0, Vector3(0, 0, deg_to_rad(25)))
		make_box(Vector3(sx + 0.7, 1.5, -52.1), Vector3(0.8, 1.5, 0.08), MARBLE, 0.12, 0.22,
				 Color.BLACK, 0, Vector3(0, 0, deg_to_rad(-25)))
	
	make_cyl(Vector3(12, 0.38, -30), 0.38, 2.0, Color(0.70, 0.72, 0.78, 1), 0.1, 0.4,
			 Color.BLACK, 0, Vector3(0, 0.3, PI * 0.5))
	make_sphere(Vector3(13.1, 0.35, -30.2), 0.28, Color(0.70, 0.72, 0.78, 1), 0.1, 0.42)

	var rubble = [
		[Vector3(-6, 0.22, -20), Vector3(1.4, 0.45, 1.1)],
		[Vector3(11, 0.28, -28), Vector3(0.9, 0.55, 1.3)],
		[Vector3(-12, 0.18, -36), Vector3(1.6, 0.38, 0.8)],
		[Vector3(8, 0.35, -42), Vector3(1.1, 0.72, 0.9)],
		[Vector3(-4, 0.25, -48), Vector3(1.8, 0.5, 1.2)],
		[Vector3(5, 0.2, -15), Vector3(0.8, 0.4, 0.7)],
	]
	for r in rubble:
		make_box(r[0], r[1], RUBBLE, 0.08, 0.5)
		
		make_box(r[0] + Vector3(0, r[1].y * 0.5 + 0.05, 0), Vector3(r[1].x, 0.05, r[1].z), MOSS, 0.0, 0.98, Color.BLACK, 0, Vector3.ZERO, false)

	var trees = [Vector3(-22, 0, -18), Vector3(22, 0, -32), Vector3(-26, 0, -44), Vector3(22, 0, -10)]
	for tp in trees:
		var h = randf_range(5.5, 8.5)
		make_cyl(tp + Vector3(0, h * 0.5, 0), 0.32, h, DEAD_W, 0.0, 0.9)
		
		for i in range(3):
			var ba = i * TAU / 3 + randf_range(-0.3, 0.3)
			make_cyl(tp + Vector3(cos(ba) * 1.0, h - 0.8, sin(ba) * 1.0), 0.12, 2.2, DEAD_W, 0, 0.92,
					 Color.BLACK, 0, Vector3(0.65, ba, 0), false)

	make_box(Vector3(-28, 0.7, -18), Vector3(14, 1.4, 0.9), Color(0.58, 0.56, 0.60, 1), 0.05, 0.8)
	make_box(Vector3(28, 0.5, -24), Vector3(0.9, 1.0, 12), Color(0.55, 0.54, 0.58, 1), 0.05, 0.8)

	add_light(Vector3(0, 6, -35),  Color(1.00, 0.96, 0.88, 1), 5.0, 40.0)  
	add_light(Vector3(0, 3, -53),  Color(1.00, 0.90, 0.45, 1), 7.0, 22.0)  
	add_light(Vector3(-12, 4, -46),Color(0.88, 0.92, 1.00, 1), 3.5, 24.0)  
	add_light(Vector3(12, 4, -40), Color(0.88, 0.92, 1.00, 1), 3.5, 24.0)  
	add_light(Vector3(0, 3, -12),  Color(1.00, 0.95, 0.80, 1), 3.0, 20.0)  
	add_light(Vector3(-22, 2, -22),Color(0.75, 0.80, 0.95, 1), 2.0, 18.0)  
