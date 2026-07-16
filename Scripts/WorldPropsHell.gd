extends "res://Scripts/WorldProps.gd"

func build_props() -> void:
	var BASALT = Color(0.14, 0.04, 0.02, 1)
	var BASALT2= Color(0.08, 0.02, 0.01, 1)
	var BONE   = Color(0.80, 0.76, 0.62, 1)
	var LAVA   = Color(0.85, 0.18, 0.0, 1)
	var LAVA_E = Color(1.0, 0.45, 0.0, 1)
	var GOLD   = Color(0.55, 0.08, 0.0, 1)
	var GOLD_E = Color(1.0, 0.35, 0.0, 1)

	make_box(Vector3(0, 0.4, -40), Vector3(38, 0.8, 42), BASALT2, 0, 0.92, LAVA_E, 0.05)

	for s in [-1, 1]:
		make_box(Vector3(s*9.5, 9, -22), Vector3(5.5, 18, 5.5), BASALT, 0, 0.90, LAVA_E, 0.04)

		for i in range(3):
			make_box(Vector3(s*9.5 + (i-1)*1.9, 18.6, -22), Vector3(1.2, 2.4, 1.2), BASALT, 0, 0.88)
			make_box(Vector3(s*9.5, 18.6, -22 + (i-1)*1.9), Vector3(1.2, 2.4, 1.2), BASALT, 0, 0.88)

		make_box(Vector3(s*9.5, 6, -19.7), Vector3(0.18, 10, 0.08), LAVA, 0, 0.1, LAVA_E, 2.5, Vector3.ZERO, false)
		add_light(Vector3(s*9.5, 14, -22), Color(1.0, 0.3, 0.0, 1), 6.0, 28.0)

	make_box(Vector3(-6.5, 6, -22), Vector3(4, 12, 1.5), BASALT, 0, 0.90, LAVA_E, 0.04)
	make_box(Vector3(6.5, 6, -22),  Vector3(4, 12, 1.5), BASALT, 0, 0.90, LAVA_E, 0.04)
	make_box(Vector3(0, 12.5, -22), Vector3(9, 2.8, 1.5), BASALT, 0, 0.88, LAVA_E, 0.08)
	
	make_sphere(Vector3(0, 15, -22), 0.85, BONE, 0.05, 0.70)

	make_box(Vector3(0, 7.5, -61), Vector3(38, 15, 1.5), BASALT, 0, 0.90, LAVA_E, 0.04)
	make_box(Vector3(-19, 7.5, -40),Vector3(1.5, 15, 42), BASALT, 0, 0.90, LAVA_E, 0.04)
	make_box(Vector3(19, 7.5, -40), Vector3(1.5, 15, 42), BASALT, 0, 0.90, LAVA_E, 0.04)

	make_box(Vector3(0, 0.35, -50), Vector3(16, 0.7, 20), BASALT2, 0, 0.94, LAVA_E, 0.06)

	make_box(Vector3(0, 1.1, -57.5), Vector3(5, 0.9, 4), GOLD, 0.7, 0.18, GOLD_E, 0.4)
	make_box(Vector3(0, 4.5, -59.8), Vector3(5, 5.5, 0.5), GOLD, 0.72, 0.15, GOLD_E, 0.6)
	make_box(Vector3(0, 7.0, -59.8), Vector3(3.2, 0.9, 0.6), Color(0.7,0.08,0.0,1), 0.8, 0.1, GOLD_E, 1.2)
	make_box(Vector3(-2.5, 2.5, -57.5), Vector3(0.5, 1.5, 4), GOLD, 0.7, 0.2, GOLD_E, 0.3)
	make_box(Vector3(2.5, 2.5, -57.5),  Vector3(0.5, 1.5, 4), GOLD, 0.7, 0.2, GOLD_E, 0.3)

	make_box(Vector3(0, 0.22, -55), Vector3(9, 0.45, 7), BASALT, 0, 0.90)
	make_box(Vector3(0, 0.62, -56), Vector3(7.5, 0.45, 5.5), BASALT, 0, 0.90)
	make_box(Vector3(0, 0.95, -57), Vector3(6.5, 0.35, 4), BASALT, 0, 0.88)
	add_light(Vector3(0, 4, -57.5), Color(1.0, 0.3, 0.0, 1), 10.0, 22.0)

	var bp_pos = [
		Vector3(-14,0,-24), Vector3(14,0,-24),
		Vector3(-14,0,-38), Vector3(14,0,-38),
		Vector3(-14,0,-52), Vector3(14,0,-52),
	]
	for bp in bp_pos:
		make_cyl(bp + Vector3(0,4.8,0), 0.52, 9.6, BONE, 0.05, 0.72)
		make_sphere(bp + Vector3(0,9.85,0), 0.68, BONE, 0.05, 0.70)
	
		make_sphere(bp + Vector3(0,10.55,0), 0.48, Color(0.76,0.72,0.58,1), 0.0, 0.78)

		for ri in range(3):
			var ra = ri * TAU / 3
			make_box(bp + Vector3(cos(ra)*0.6, 3+ri*2, sin(ra)*0.6),
					 Vector3(0.12, 0.85, 1.1), BONE, 0.05, 0.75, Color.BLACK, 0,
					 Vector3(0, ra, deg_to_rad(28)), false)

	var cracks = [
		[Vector3(-14, 0.02, -10), Vector3(8.5, 0.14, 0.55), Vector3.ZERO],
		[Vector3(10, 0.02, -6),   Vector3(0.5, 0.14, 13),   Vector3.ZERO],
		[Vector3(-5, 0.02, -30),  Vector3(16, 0.14, 0.5),   Vector3(0, deg_to_rad(22), 0)],
		[Vector3(12, 0.02, -46),  Vector3(0.45, 0.14, 11),  Vector3.ZERO],
		[Vector3(-8, 0.02, -51),  Vector3(7, 0.14, 0.5),    Vector3(0, deg_to_rad(-18), 0)],
		[Vector3(0, 0.02, -15),   Vector3(0.55, 0.14, 9),   Vector3.ZERO],
		[Vector3(16, 0.02, -30),  Vector3(6, 0.14, 0.5),    Vector3(0, deg_to_rad(40), 0)],
	]
	for c in cracks:
		make_box(c[0], c[1], LAVA, 0, 0.08, LAVA_E, 3.5, c[2], false)
		add_light(c[0] + Vector3(0, 0.6, 0), Color(1.0, 0.4, 0.0, 1), 2.5, c[1].length() * 3.5)

	for fp in [Vector3(-20,0,-30), Vector3(20,0,-30), Vector3(-20,0,-50), Vector3(20,0,-50), Vector3(0,0,6)]:
		make_cyl(fp + Vector3(0,0.45,0), 2.2, 0.9, BASALT, 0, 0.90, LAVA_E, 0.15)
		make_cyl(fp + Vector3(0,0.08,0), 1.85, 0.2, LAVA, 0, 0.06, LAVA_E, 4.5, Vector3.ZERO, false)
		add_light(fp + Vector3(0, 1.8, 0), Color(1.0, 0.5, 0.0, 1), 6.0, 20.0)

	for rcp in [Vector3(-30,0,-14), Vector3(32,0,-20), Vector3(-32,0,-46),
				Vector3(32,0,-52), Vector3(-26,0,6), Vector3(28,0,6)]:
		for j in range(5):
			var rp = rcp + Vector3(randf_range(-3.5,3.5), 0, randf_range(-3.5,3.5))
			var rh = randf_range(1.8, 5.5)
			var rw = randf_range(0.7, 2.2)
			make_box(rp + Vector3(0, rh*0.5, 0), Vector3(rw, rh, rw*0.75), BASALT2, 0, 0.94,
					 Color.BLACK, 0, Vector3(randf_range(-0.18,0.18), randf_range(0,TAU), randf_range(-0.18,0.18)))

	add_light(Vector3(-10, 5, -40), Color(1.0, 0.3, 0.0, 1), 4.5, 28.0)
	add_light(Vector3(10, 5, -40),  Color(1.0, 0.3, 0.0, 1), 4.5, 28.0)
	add_light(Vector3(0, 6, -30),   Color(1.0, 0.25, 0.0, 1), 3.5, 32.0)
	add_light(Vector3(-16, 3, -56), Color(1.0, 0.2, 0.0, 1), 4.0, 22.0)
	add_light(Vector3(16, 3, -56),  Color(1.0, 0.2, 0.0, 1), 4.0, 22.0)
	add_light(Vector3(-30, 2.5, -10), Color(0.8, 0.15, 0.0, 1), 3.5, 22.0)
	add_light(Vector3(30, 2.5, -10),  Color(0.8, 0.15, 0.0, 1), 3.5, 22.0)
