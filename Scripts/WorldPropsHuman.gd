extends "res://Scripts/WorldProps.gd"

func build_props() -> void:
	var STONE  = Color(0.44, 0.40, 0.34, 1)  
	var STONE2 = Color(0.36, 0.32, 0.27, 1)  
	var BRICK  = Color(0.52, 0.26, 0.16, 1)  
	var BRICK2 = Color(0.42, 0.20, 0.12, 1)  
	var WOOD   = Color(0.40, 0.28, 0.16, 1)  
	var WOOD2  = Color(0.30, 0.20, 0.10, 1)  
	var THATCH = Color(0.55, 0.46, 0.22, 1)  
	var DIRT   = Color(0.32, 0.26, 0.18, 1)  
	var MOSS   = Color(0.22, 0.34, 0.14, 1)  

	make_box(Vector3(0, 0.02, -8), Vector3(28, 0.04, 28), DIRT, 0, 0.98)

	var AB = Vector3(-20, 0, -24)
	make_box(AB + Vector3(0, 0.2, 0),    Vector3(14, 0.4, 18), STONE2, 0, 0.92)  
	make_box(AB + Vector3(-7, 5, 0),     Vector3(0.9, 10, 18), STONE,  0, 0.88)  
	make_box(AB + Vector3(0, 5, -9),     Vector3(14, 10, 0.9), STONE,  0, 0.90)  
	make_box(AB + Vector3(0, 5, 9),      Vector3(5, 10, 0.9),  STONE,  0, 0.90)  
	make_box(AB + Vector3(4.5, 5, 9),    Vector3(4, 10, 0.9),  STONE,  0, 0.90)  

	make_box(AB + Vector3(0, 9.5, 9),    Vector3(3.5, 1.2, 1.0), STONE, 0, 0.88)
	
	make_box(AB + Vector3(-2, 10.3, -2), Vector3(9, 0.4, 10), WOOD, 0, 0.92,
			 Color.BLACK, 0, Vector3(deg_to_rad(12), 0, 0))
	
	make_box(AB + Vector3(-2, 10.65, -2), Vector3(9, 0.22, 10), THATCH, 0, 0.96,
			 Color.BLACK, 0, Vector3(deg_to_rad(12), 0, 0), false)
	
	make_box(AB + Vector3(0, 7.5, -4), Vector3(14, 0.3, 0.22), WOOD2, 0, 0.94)
	make_box(AB + Vector3(0, 7.5, 2),  Vector3(14, 0.3, 0.22), WOOD2, 0, 0.94)
	
	make_box(AB + Vector3(-7, 0.5, 0), Vector3(0.1, 1.0, 16), MOSS, 0, 0.98, Color.BLACK, 0, Vector3.ZERO, false)

	var BB = Vector3(20, 0, -28)
	make_box(BB + Vector3(0, 0.2, 0),   Vector3(12, 0.4, 12), STONE2, 0, 0.92)
	make_box(BB + Vector3(-6, 4, 0),    Vector3(0.9, 8, 12), BRICK, 0, 0.90)
	make_box(BB + Vector3(6, 4, 0),     Vector3(0.9, 8, 12), BRICK, 0, 0.90)
	make_box(BB + Vector3(0, 4, -6),    Vector3(12, 8, 0.9), BRICK, 0, 0.90)
	make_box(BB + Vector3(-3, 4, 6),    Vector3(6, 8, 0.9), BRICK, 0, 0.90)
	make_box(BB + Vector3(4, 4, 6),     Vector3(4, 8, 0.9), BRICK2, 0, 0.90)
	
	for i in range(4):
		make_box(BB + Vector3(-6, 1.5 + i * 1.8, 0), Vector3(0.1, 0.08, 12),
				 STONE2, 0, 0.96, Color.BLACK, 0, Vector3.ZERO, false)
				
	make_box(BB + Vector3(5, 0.8, 5), Vector3(3.5, 1.6, 2.5), BRICK2, 0, 0.88)

	make_box(Vector3(0, 8.5, -62), Vector3(5.5, 17.0, 5.5), STONE, 0, 0.88)
	make_box(Vector3(0, 17.5, -62), Vector3(7.0, 0.55, 7.0), STONE, 0, 0.85) 
	
	for i in range(4):
		var ba = i * TAU / 4
		make_box(Vector3(cos(ba)*3.0, 18.6, -62 + sin(ba)*3.0), Vector3(1.1, 2.2, 1.1), STONE, 0, 0.88)
	
	for i in range(3):
		make_box(Vector3(-2.8, 5 + i * 4.5, -62), Vector3(0.12, 0.8, 0.22), STONE2, 0, 0.98, Color.BLACK, 0, Vector3.ZERO, false)

	make_box(Vector3(0, 17.28, -62), Vector3(4.8, 0.18, 4.8), WOOD, 0, 0.92)
	
	for j in range(8):
		make_box(Vector3(-2.4, 1.5 + j * 1.8, -59.5), Vector3(0.5, 0.1, 0.08), WOOD, 0, 0.94, Color.BLACK, 0, Vector3.ZERO, false)

	var stalls = [
		[Vector3(-10, 0, -8), Color(0.70, 0.52, 0.28, 1)],
		[Vector3(10, 0, -12), Color(0.55, 0.22, 0.18, 1)],
	]
	for st in stalls:
		var sp: Vector3 = st[0]
		var fc: Color   = st[1]

		for px in [-2.0, 2.0]:
			for pz in [-1.4, 1.4]:
				make_cyl(sp + Vector3(px, 1.0, pz), 0.07, 2.0, WOOD, 0, 0.94)

		make_box(sp + Vector3(0, 2.1, 0), Vector3(5.0, 0.09, 3.5), fc, 0, 0.88, Color.BLACK, 0,
				 Vector3(deg_to_rad(-8), 0, 0), false)

		make_box(sp + Vector3(0, 0.55, -0.9), Vector3(4.5, 0.25, 0.5), WOOD2, 0, 0.90)

	make_cyl(Vector3(5, 0.6, -5), 1.1, 1.2, STONE, 0, 0.88)
	make_cyl(Vector3(5, 0.1, -5), 1.4, 0.22, STONE2, 0, 0.92)
	make_box(Vector3(4.5, 1.8, -5), Vector3(0.1, 1.6, 0.1), WOOD, 0, 0.94)
	make_box(Vector3(5.5, 1.8, -5), Vector3(0.1, 1.6, 0.1), WOOD, 0, 0.94)
	make_box(Vector3(5, 2.65, -5), Vector3(1.5, 0.1, 0.1), WOOD, 0, 0.94)

	make_box(Vector3(-28, 2, 6),  Vector3(22, 4.0, 1.0), STONE, 0, 0.90)
	make_box(Vector3(26, 1.5, 6), Vector3(18, 3.0, 1.0), STONE, 0, 0.90)
	make_box(Vector3(-40, 3, -14),Vector3(1.0, 6.0, 22), STONE, 0, 0.90)
	
	make_box(Vector3(-7, 3.5, 6), Vector3(1.5, 7, 1.5), STONE, 0, 0.88)
	make_box(Vector3(7, 3.5, 6),  Vector3(1.5, 7, 1.5), STONE, 0, 0.88)
	make_box(Vector3(0, 7.5, 6),  Vector3(15.5, 1.2, 1.5), STONE, 0, 0.88)

	var trees = [
		Vector3(-36, 0, 6), Vector3(36, 0, 4), Vector3(-34, 0, -52),
		Vector3(36, 0, -42), Vector3(-14, 0, -66), Vector3(16, 0, -66)
	]
	for tp in trees:
		var h = randf_range(5.5, 9.0)
		make_cyl(tp + Vector3(0, h*0.5, 0), 0.38, h, Color(0.28, 0.20, 0.12, 1), 0, 0.95)

		make_sphere(tp + Vector3(0, h + 1.8, 0), randf_range(2.0, 3.2),
					Color(0.18, 0.32, 0.09, 1), 0, 0.98)
		make_sphere(tp + Vector3(randf_range(-0.5,0.5), h + 3.2, randf_range(-0.5,0.5)),
					randf_range(1.2, 2.0), Color(0.14, 0.26, 0.07, 1), 0, 0.98)

	for i in range(10):
		var rp = Vector3(randf_range(-38, 38), 0.22, randf_range(-62, 8))
		var rs = Vector3(randf_range(0.3, 1.4), randf_range(0.15, 0.8), randf_range(0.3, 1.1))
		make_box(rp, rs, STONE2, 0, 0.92)

	var torches = [
		Vector3(-20, 1, 10), Vector3(22, 1, -18), Vector3(0, 1, -65),
		Vector3(-20, 1, -28), Vector3(0, 1, -15),
	]
	for tp in torches:
		make_cyl(tp, 0.06, 0.5, WOOD2, 0, 0.95)
		make_sphere(tp + Vector3(0, 0.38, 0), 0.12,
					Color(1.0, 0.60, 0.10, 1), 0, 0.1, Color(1, 0.5, 0, 1), 3.0, false)
		add_light(tp + Vector3(0, 0.5, 0), Color(1.0, 0.68, 0.25, 1), 3.5, 16.0)
