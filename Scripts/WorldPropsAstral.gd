extends "res://Scripts/WorldProps.gd"

func build_props() -> void:
	var OBSID  = Color(0.06, 0.04, 0.12, 1)  
	var CRYST  = Color(0.45, 0.18, 0.92, 1)  
	var CRYST_E= Color(0.55, 0.22, 1.00, 1)
	var RUNE   = Color(0.30, 0.08, 0.80, 1)  
	var VOID   = Color(0.02, 0.01, 0.06, 1)  

	var monos = [
		[Vector3(-28, 0, 5),  9.0],  [Vector3(30, 0, 2),  10.5],
		[Vector3(-29, 0, -48), 8.5], [Vector3(31, 0, -52), 11.0],
		[Vector3(-15, 0, -70), 7.5], [Vector3(16, 0, -70), 9.0],
	]
	for m in monos:
		var h: float = m[1]
		
		make_box(m[0] + Vector3(0, h*0.5, 0), Vector3(2.2, h, 2.2), OBSID, 0.3, 0.15)
		
		make_box(m[0] + Vector3(0, h*0.45, 0), Vector3(2.4, 0.18, 2.4), CRYST, 0.2, 0.12,
				 CRYST_E, 2.0, Vector3.ZERO, false)
		
		make_box(m[0] + Vector3(0, h+0.12, 0), Vector3(2.5, 0.22, 2.5), CRYST, 0.2, 0.1,
				 CRYST_E, 3.0, Vector3.ZERO, false)
		add_light(m[0] + Vector3(0, h+0.5, 0), CRYST_E, 3.5, 14.0)

	var clusters = [
		Vector3(-20, 0, -18), Vector3(18, 0, -28),
		Vector3(-14, 0, -44), Vector3(24, 0, -8),
		Vector3(-6, 0, -55),  Vector3(12, 0, 14),
	]
	for center in clusters:
		for j in range(6):
			var a  = j * TAU / 6 + randf_range(-0.25, 0.25)
			var d  = randf_range(0.8, 3.2)
			var h  = randf_range(2.5, 7.0)
			var r  = randf_range(0.18, 0.48)
			var tilt = randf_range(-0.2, 0.2)
			var pos = center + Vector3(cos(a)*d, h*0.5, sin(a)*d)
			make_cyl(pos, r*0.3, h, CRYST, 0.25, 0.08, CRYST_E, 1.8,
					 Vector3(tilt, a, 0), false)
			make_sphere(pos + Vector3(0, h*0.52, 0), r*0.55, CRYST_E, 0.2, 0.06,
						CRYST_E, 3.0, false)
		add_light(center + Vector3(0, 1.5, 0), CRYST_E, 2.5, 12.0)

	var portals = [Vector3(0, 3.5, -28), Vector3(-22, 5, -38), Vector3(24, 4.5, 8)]
	for pp in portals:
		
		make_cyl(pp, 4.0, 0.55, RUNE, 0.35, 0.10, CRYST_E, 1.5,
				 Vector3(PI*0.5, 0, 0), false)
		
		make_sphere(pp, 3.1, VOID, 0.0, 0.95, Color(0.1, 0, 0.3, 1), 0.4, false)
		
		for i in range(8):
			var ra = i * TAU / 8
			make_box(pp + Vector3(cos(ra)*4.2, sin(ra)*4.2, 0), Vector3(0.35, 0.35, 0.25),
					 RUNE, 0.3, 0.12, CRYST_E, 1.8, Vector3(0, 0, ra), false)
		add_light(pp, Color(0.4, 0.1, 1.0, 1), 5.0, 18.0)

	var platforms = [
		[Vector3(-14, 1.8, -16), Vector3(6.5, 0.55, 4.5)],
		[Vector3(15, 2.4, -24),  Vector3(5.5, 0.45, 5.5)],
		[Vector3(-6, 1.2, -38),  Vector3(9.0, 0.5,  4.5)],
		[Vector3(22, 1.5, -42),  Vector3(4.5, 0.45, 6.5)],
	]
	for pf in platforms:
		make_box(pf[0], pf[1], OBSID, 0.4, 0.12, CRYST_E, 0.6)
		
		make_box(pf[0] - Vector3(0, pf[1].y * 0.5 + 0.04, 0), Vector3(pf[1].x, 0.1, pf[1].z),
				 CRYST, 0.2, 0.1, CRYST_E, 3.0, Vector3.ZERO, false)
		add_light(pf[0] - Vector3(0, 0.8, 0), CRYST_E, 2.0, 8.0)

	make_box(Vector3(-14, 2.2, -24), Vector3(0.9, 0.12, 22), CRYST, 0.2, 0.06, CRYST_E, 4.0, Vector3.ZERO, false)
	make_box(Vector3(12, 3.0, -36),  Vector3(22, 0.10, 0.9), CRYST, 0.2, 0.06, CRYST_E, 4.0, Vector3.ZERO, false)

	add_light(Vector3(0, 6, 0),    Color(0.4, 0.1, 0.9, 1), 3.5, 45.0)
	add_light(Vector3(-22, 5, -30),Color(0.3, 0.05, 0.8, 1), 4.0, 32.0)
	add_light(Vector3(22, 5, -20), Color(0.5, 0.1,  0.9, 1), 3.5, 28.0)
	add_light(Vector3(0, 5, -54),  Color(0.2, 0.05, 0.6, 1), 4.5, 34.0)
