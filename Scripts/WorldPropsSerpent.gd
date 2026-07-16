extends "res://Scripts/WorldProps.gd"

func build_props() -> void:
	var STONE  = Color(0.20, 0.28, 0.14, 1)  
	var STONE2 = Color(0.12, 0.18, 0.08, 1)  
	var MOSS   = Color(0.16, 0.30, 0.08, 1)  
	var BARK   = Color(0.10, 0.16, 0.06, 1)  
	var LEAF   = Color(0.06, 0.20, 0.04, 1)  
	var POISON = Color(0.04, 0.28, 0.02, 1)  
	var PE     = Color(0.08, 0.90, 0.03, 1)  
	var GOLD   = Color(0.40, 0.32, 0.06, 1)  

	
	make_box(Vector3(0, 0.05, -18), Vector3(6.5, 0.10, 30), STONE2, 0, 0.95)
	for side in [-1, 1]:
		for i in range(3):
			var pp = Vector3(side * 5.5, 0, -18 - i * 8)
			make_box(pp + Vector3(0, 0.6, 0), Vector3(0.7, 1.2, 0.7), STONE, 0, 0.92)
			make_cyl(pp + Vector3(0, 1.45, 0), 0.06, 0.6, BARK, 0, 0.95)
			make_sphere(pp + Vector3(0, 1.85, 0), 0.14, Color(1, 0.55, 0.05, 1), 0, 0.1,
						Color(1, 0.45, 0, 1), 3.0, false)
			add_light(pp + Vector3(0, 2.2, 0), Color(0.8, 0.6, 0.1, 1), 3.0, 12.0)

	make_box(Vector3(0, 0.45, -37), Vector3(30, 0.9, 30), STONE, 0, 0.90)

	make_box(Vector3(0, 0.2, -22), Vector3(12, 0.4, 2.2), STONE2, 0, 0.92)
	make_box(Vector3(0, 0.55, -24.2), Vector3(12, 0.7, 2.2), STONE2, 0, 0.92)
	make_box(Vector3(0, 0.95, -26.4), Vector3(12, 0.8, 2.2), STONE2, 0, 0.92)

	make_box(Vector3(0, 6, -52), Vector3(30, 12, 1.1), STONE2, 0, 0.90)   
	make_box(Vector3(-15, 6, -37), Vector3(1.1, 12, 30), STONE2, 0, 0.90) 
	make_box(Vector3(15, 6, -37),  Vector3(1.1, 12, 30), STONE2, 0, 0.90) 

	make_box(Vector3(-10.5, 6, -22), Vector3(9, 12, 1.1), STONE2, 0, 0.90)
	make_box(Vector3(10.5, 6, -22),  Vector3(9, 12, 1.1), STONE2, 0, 0.90)
	make_box(Vector3(0, 11.5, -22),  Vector3(12, 2.5, 1.1), STONE, 0, 0.88)  

	for side in [-1, 1]:
		make_box(Vector3(side*14.5, 3, -37), Vector3(0.12, 5, 28), MOSS, 0, 0.98, Color.BLACK, 0, Vector3.ZERO, false)

	for i in range(3):
		for side in [-1, 1]:
			var cp = Vector3(side * 10.5, 0, -27 - i * 8)
			make_cyl(cp + Vector3(0, 5.5, 0), 0.75, 11.0, STONE, 0, 0.90)
			make_box(cp + Vector3(0, 11.2, 0), Vector3(1.9, 0.7, 1.9), STONE2, 0, 0.92)
			make_box(cp + Vector3(0, 0.22, 0), Vector3(1.8, 0.45, 1.8), STONE2, 0, 0.92)

			make_box(cp + Vector3(side*0.76, 4, 0), Vector3(0.08, 6, 0.12), MOSS, 0, 0.98, Color.BLACK, 0, Vector3.ZERO, false)

	make_box(Vector3(0, 1.3, -47), Vector3(4.5, 1.2, 3.2), STONE, 0, 0.88)
	make_box(Vector3(0, 1.95, -47), Vector3(3.8, 0.55, 2.6), GOLD, 0.5, 0.55)

	make_sphere(Vector3(0, 2.55, -47), 0.7, POISON, 0.1, 0.15, PE, 3.5, false)
	add_light(Vector3(0, 3.5, -47), Color(0.08, 1.0, 0.04, 1), 7.0, 16.0)

	var tp_list = [
		Vector3(-24, 0, -12), Vector3(22, 0, -8), Vector3(-28, 0, -54),
		Vector3(24, 0, -50),  Vector3(-23, 0, -28), Vector3(28, 0, -30),
		Vector3(-36, 0, 6),   Vector3(38, 0, 6),   Vector3(0, 0, 8),
		Vector3(-10, 0, -68), Vector3(10, 0, -68),
	]
	for tp in tp_list:
		var h = randf_range(6, 11)
		var tilt_x = randf_range(-0.25, 0.25)
		var tilt_z = randf_range(-0.15, 0.15)
		make_cyl(tp + Vector3(0, h*0.5, 0), 0.42, h, BARK, 0, 0.97,
				 Color.BLACK, 0, Vector3(tilt_x, randf_range(0, TAU), tilt_z))

		make_sphere(tp + Vector3(0, h+1.2, 0), randf_range(2.2, 3.4), LEAF, 0, 0.98)
		make_sphere(tp + Vector3(randf_range(-0.6,0.6), h+2.8, randf_range(-0.6,0.6)),
					randf_range(1.2, 2.2), Color(0.04, 0.16, 0.02, 1), 0, 0.98)

		for r in range(3):
			var ra = r * TAU / 3 + randf_range(-0.3, 0.3)
			make_box(tp + Vector3(cos(ra)*1.0, 0.5, sin(ra)*1.0), Vector3(0.28, 1.0, 0.55), BARK,
					 0, 0.97, Color.BLACK, 0, Vector3(0, ra, 0.4))

	var pools = [
		[Vector3(-13, 0.06, -10), 3.5], [Vector3(15, 0.06, -15), 4.0],
		[Vector3(-9, 0.06, -55), 3.0],  [Vector3(11, 0.06, -55), 3.5],
		[Vector3(0, 0.06, 8), 2.5],
	]
	for pp in pools:
		var pr: float = pp[1]
		make_cyl(pp[0], pr, 0.14, POISON, 0, 0.15, PE, 2.0, Vector3.ZERO, false)

		for bi in range(4):
			var ba = bi * TAU / 4 + randf_range(-0.3, 0.3)
			make_sphere(pp[0] + Vector3(cos(ba)*pr*0.5, 0.1, sin(ba)*pr*0.5),
						randf_range(0.08, 0.22), PE, 0, 0.08, PE, 2.5, false)
		add_light(pp[0] + Vector3(0, 0.8, 0), Color(0.08, 0.9, 0.04, 1), 2.5, pr * 3.5)

	make_box(Vector3(0, 0.32, -65), Vector3(3.5, 0.65, 3.5), STONE2, 0, 0.92)
	for i in range(7):
		var w = 1.1 - i * 0.08
		make_box(Vector3(0, 0.8 + i * 1.1, -65 - i * 0.35),
				 Vector3(w * 1.6, 1.0, w), STONE, 0, 0.90,
				 Color.BLACK, 0, Vector3(0, i * 0.18, 0))
	make_sphere(Vector3(0, 8.8, -67.5), 1.1, STONE2, 0.05, 0.88)

	for ex in [-0.38, 0.38]:
		make_sphere(Vector3(ex, 9.1, -68.5), 0.20, PE, 0, 0.05, PE, 5.0, false)
	add_light(Vector3(0, 6.5, -66), Color(0.08, 0.9, 0.02, 1), 6.0, 22.0)

	for oi in range(5):
		var oa = oi * TAU / 5
		make_cyl(Vector3(cos(oa)*2.5, 0.25, -65 + sin(oa)*2.5), 0.25, 0.5, GOLD, 0.55, 0.5)

	
	make_box(Vector3(-30, 2.5, 6),  Vector3(18, 5.0, 1.0), STONE2, 0, 0.90)
	make_box(Vector3(32, 2.0, 5),   Vector3(14, 4.0, 1.0), STONE2, 0, 0.90)
	make_box(Vector3(-44, 3.5, -16),Vector3(1.0, 7.0, 24), STONE2, 0, 0.90)
	make_box(Vector3(44, 3.0, -22), Vector3(1.0, 6.0, 16), STONE2, 0, 0.90)

	add_light(Vector3(0, 5, -37),  Color(0.04, 0.7, 0.02, 1), 4.0, 32.0)
	add_light(Vector3(-12, 3, -37),Color(0.04, 0.5, 0.02, 1), 2.5, 18.0)
	add_light(Vector3(12, 3, -37), Color(0.04, 0.5, 0.02, 1), 2.5, 18.0)
	add_light(Vector3(-22, 2, -14),Color(0.04, 0.4, 0.02, 1), 2.0, 14.0)
	add_light(Vector3(22, 2, -28), Color(0.04, 0.4, 0.02, 1), 2.0, 14.0)
