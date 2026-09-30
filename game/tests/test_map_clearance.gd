extends SceneTree

func _init() -> void:
	call_deferred("verify")

func verify() -> void:
	var world = load("res://scripts/production_world_2d.gd").new()
	root.add_child(world)
	world.build()
	await physics_frame
	await physics_frame
	var failures: Array[String] = []
	var checked := 0
	for road in world.layout.roads:
		var shape := CircleShape2D.new()
		shape.radius = 32.5 if road.kind == "heavy" else 16.0 if road.kind == "farm" else 6.0
		for index in range(road.points.size()-1):
			var start := Vector2(road.points[index][0],road.points[index][1])
			var end := Vector2(road.points[index+1][0],road.points[index+1][1])
			for sample in range(ceili(start.distance_to(end)) + 1):
				var point := start.lerp(end, minf(1.0,float(sample)/maxf(1.0,start.distance_to(end))))
				if absf(point.x) > 81.0 or absf(point.y) > 56.0: continue
				var query := PhysicsShapeQueryParameters2D.new()
				query.shape = shape; query.collision_mask = 1
				query.transform = Transform2D(0.0,world.logical_to_pixel(point))
				var hits = world.get_world_2d().direct_space_state.intersect_shape(query)
				checked += 1
				if not hits.is_empty():
					failures.append("%s at %s blocked by %s" % [road.id,point,hits[0].collider.get_parent().name])
	# Interaction coordinates must be usable positions, not the centres of props.
	var walker := CircleShape2D.new(); walker.radius = 6.0
	for destination in world.layout.destinations:
		var query := PhysicsShapeQueryParameters2D.new()
		query.shape = walker; query.collision_mask = 1
		query.transform = Transform2D(0.0,world.logical_to_pixel(Vector2(destination.position[0],destination.position[1])))
		if not world.get_world_2d().direct_space_state.intersect_shape(query).is_empty():
			failures.append("Destination %s is inside collision" % destination.id)
	# Flood the real collision space from the yard, rather than trusting a declared
	# exit count. Every destination must belong to the same walkable component.
	var open: Dictionary = {}
	for x in range(-80,81,2):
		for y in range(-56,57,2):
			var query := PhysicsShapeQueryParameters2D.new()
			query.shape = walker; query.collision_mask = 1
			query.transform = Transform2D(0.0,world.logical_to_pixel(Vector2(x,y)))
			if world.get_world_2d().direct_space_state.intersect_shape(query).is_empty(): open[Vector2i(x,y)] = true
	var queue: Array[Vector2i] = [Vector2i(0,8)]
	var reached: Dictionary = {Vector2i(0,8):true}
	var cursor := 0
	while cursor < queue.size():
		var current := queue[cursor]; cursor += 1
		for direction in [Vector2i(2,0),Vector2i(-2,0),Vector2i(0,2),Vector2i(0,-2)]:
			var next: Vector2i = current + direction
			if open.has(next) and not reached.has(next): reached[next] = true; queue.append(next)
	for destination in world.layout.destinations:
		var target := Vector2(destination.position[0],destination.position[1])
		var accessible := false
		for cell in reached:
			if Vector2(cell).distance_to(target) < 2.0: accessible = true; break
		if not accessible: failures.append("Destination %s is disconnected from the yard" % destination.id)
	for failure in failures: push_error(failure)
	print("Map clearance: %d samples, %d blocked" % [checked,failures.size()])
	quit(0 if failures.is_empty() else 1)
