class_name ProductionWorld2D
extends Node2D

const PIXELS_PER_METRE := 10.0
const MAP_CENTER := Vector2(850, 600)
const MAP_MIN := Vector2(-82, -57)
const MAP_MAX := Vector2(82, 57)

const CropFieldScript := preload("res://scripts/crop_field_2d.gd")
const STONE_BARN := preload("res://assets/2d/production/stone_barn.png")
const MACHINERY_SHED := preload("res://assets/2d/production/machinery_shed.png")
const REPAIR_WORKSHOP := preload("res://assets/2d/production/repair_workshop.png")
const FEED_STORE := preload("res://assets/2d/production/feed_store.png")
const GRAIN_SILOS := preload("res://assets/2d/production/grain_silos.png")
const PACKING_CANOPY := preload("res://assets/2d/production/packing_canopy.png")
const OAK_TREE := preload("res://assets/2d/production/reference_oak.png")
const WILLOW_TREE := preload("res://assets/2d/production/reference_willow.png")
const ORCHARD_TREE := preload("res://assets/2d/production/reference_orchard.png")
const FLOWERING_TREE := preload("res://assets/2d/production/reference_blossom.png")
const HEDGE_HORIZONTAL := preload("res://assets/2d/production/reference_hedge.png")
const HEDGE_VERTICAL := preload("res://assets/2d/production/verge_hedge_v.png")
const HEDGE_GATE := preload("res://assets/2d/production/hedge_gate_v2.png")
const WALL_HORIZONTAL := preload("res://assets/2d/production/verge_wall_h.png")
const WALL_VERTICAL := preload("res://assets/2d/production/verge_wall_v.png")
const WALL_GATE := preload("res://assets/2d/production/wall_gate_v2.png")
const STONE_BRIDGE := preload("res://assets/2d/production/stone_bridge.png")
const SHALLOW_FORD := preload("res://assets/2d/production/shallow_ford.png")
const HAY_BALE_STACK := preload("res://assets/2d/production/hay_bale_stack.png")
const FARM_SUPPLIES := preload("res://assets/2d/production/farm_supplies.png")
const TOOL_STATION := preload("res://assets/2d/production/tool_station.png")
const WATER_TROUGH := preload("res://assets/2d/production/water_trough.png")
const PRODUCE_CRATES := preload("res://assets/2d/production/produce_crates.png")
const DESTINATION_SIGNPOST := preload("res://assets/2d/production/destination_signpost.png")
const SHEEP_ALERT := preload("res://assets/2d/production/sheep_alert.png")
const SHEEP_GRAZING := preload("res://assets/2d/production/sheep_grazing.png")
const APIARY_HIVES := preload("res://assets/2d/production/apiary_hives.png")
const GRAIN_INTAKE := preload("res://assets/2d/production/grain_intake.png")
const FARM_TRAILER := preload("res://assets/2d/production/farm_trailer.png")
const DELIVERY_VAN := preload("res://assets/2d/production/delivery_van.png")
const PRODUCE_PALLET := preload("res://assets/2d/production/produce_pallet.png")
const SPARE_PARTS_CRATE := preload("res://assets/2d/production/spare_parts_crate.png")
const TERRAIN_PASTURE := preload("res://assets/2d/production/terrain_pasture.png")
const TERRAIN_HAY := preload("res://assets/2d/production/terrain_hay.png")
const TERRAIN_ORCHARD := preload("res://assets/2d/production/terrain_orchard.png")
const TERRAIN_MEADOW := preload("res://assets/2d/production/terrain_meadow.png")
const TERRAIN_YARD := preload("res://assets/2d/production/terrain_yard.png")
const TERRAIN_TRACK := preload("res://assets/2d/production/terrain_track.png")
const CONTACT_SHADOW := preload("res://assets/2d/production/contact_shadow.png")
const TERRAIN_UV_SCALE := 2.55

var crop_field: CropField2D
var layout: Dictionary
var destination_nodes: Dictionary = {}

func build() -> void:
	name = "BrackenridgeFarm2D"
	y_sort_enabled = true
	layout = JSON.parse_string(FileAccess.get_file_as_string("res://data/world_layout.json"))
	_build_ground()
	_build_routes()
	_build_stream()
	_build_boundaries()
	_build_buildings()
	_build_work_zones()
	_dress_building_bases()
	_build_operational_assets()
	_build_destinations()
	_build_trees()
	_build_verge_dressing()
	_build_estate_edge()
	_build_world_edge()
	_build_sun_shadows()

func _process(_delta: float) -> void:
	for destination_id in destination_nodes:
		var marker: Node2D = destination_nodes[destination_id]
		var reveal_radius := float(marker.get_meta("radius", 7.0)) * PIXELS_PER_METRE
		var nearby := false
		for player_id in [1, 2]:
			var player := get_node_or_null("Player%d" % player_id) as Node2D
			if player != null and player.visible and player.global_position.distance_to(marker.global_position) <= reveal_radius:
				nearby = true
		var panel := marker.get_node("DestinationPanel") as Control
		panel.visible = nearby and not bool(marker.get_meta("suppressed",false))

func nearest_destination(pixel_position: Vector2, max_distance_metres: float = 8.0) -> Dictionary:
	var best := {}
	var best_distance := max_distance_metres * PIXELS_PER_METRE
	for destination in layout.get("destinations", []):
		var position := logical_to_pixel(Vector2(float(destination.position[0]), float(destination.position[1])))
		var distance := pixel_position.distance_to(position)
		if distance <= best_distance:
			best_distance = distance
			best = destination.duplicate(true)
			best["distance_pixels"] = distance
	return best

func destination_ids() -> PackedStringArray:
	var result := PackedStringArray()
	for destination in layout.get("destinations", []): result.append(str(destination.id))
	return result

func set_destination_suppressed(destination_id: String, suppressed: bool) -> void:
	if destination_nodes.has(destination_id): destination_nodes[destination_id].set_meta("suppressed",suppressed)

func logical_to_pixel(value: Vector2) -> Vector2:
	return MAP_CENTER + value * PIXELS_PER_METRE

func pixel_to_logical(value: Vector2) -> Vector2:
	return (value - MAP_CENTER) / PIXELS_PER_METRE

func apply_tractor_work(pixel_position: Vector2) -> bool:
	return crop_field.apply_tractor_work(pixel_position) if crop_field else false

func cycle_crop_state() -> void:
	if crop_field: crop_field.cycle_stage()

func _build_ground() -> void:
	var ground := Sprite2D.new(); ground.name = "BlendedCountryside"
	ground.texture = load("res://assets/2d/production/cohesive_ground_mask.png")
	ground.centered = false; ground.scale = Vector2(2.4,2.4); ground.position = Vector2(-170,-120); ground.z_index = -100
	var material := ShaderMaterial.new(); material.shader = load("res://shaders/cohesive_ground.gdshader")
	material.set_shader_parameter("wear_tex",load("res://assets/2d/production/cohesive_wear_mask.png"))
	material.set_shader_parameter("meadow_tex",load("res://assets/2d/production/reference_meadow.png"))
	for key in ["grass","earth","yard","water"]:
		material.set_shader_parameter(key + "_tex", load("res://assets/2d/production/cohesive_%s.png" % key))
	ground.material = material; add_child(ground)
	for district in layout.districts:
		if district.kind != "crop": continue
		crop_field = CropFieldScript.new(); crop_field.name = "BarleyField"; add_child(crop_field)
		for road in layout.roads:
			if road.kind == "heavy": crop_field.reserved_routes.append({"points":_logical_points(road.points),"radius":float(road.width)*PIXELS_PER_METRE*0.5})
		crop_field.setup(_logical_points(district.points))

func _build_routes() -> void:
	# The static surface mask joins routes and yard in one continuous material.
	# Named anchors remain for validation; grassy shoulders preserve clearances.
	for road in layout.roads:
		var surface := Node2D.new(); surface.name = "%sSurface" % road.id; add_child(surface)

func _build_stream() -> void:
	var stream_points := PackedVector2Array([logical_to_pixel(Vector2(-84, 46)), logical_to_pixel(Vector2(-62, 43)), logical_to_pixel(Vector2(-42, 47)), logical_to_pixel(Vector2(-20, 55)), logical_to_pixel(Vector2(6, 61))])
	# Water and bank colour are independent channels of the ground material.
	# Keep the water solid away from the crossings. The central bridge and east
	# ford are deliberate gaps so both walkers and farm vehicles can traverse it.
	# Continuous water collision with only the authored bridge and ford gaps.
	for index in range(stream_points.size() - 1):
		var start: Vector2 = stream_points[index]
		var finish: Vector2 = stream_points[index + 1]
		var direction := (finish-start).normalized()
		if index in [1,3]: start += direction * 65.0
		if index in [0,2]: finish -= direction * 65.0
		_add_segment_collision("StreamBank%d" % index, start, finish, 62.0)

	_add_bridge(Vector2(-62, 43), -0.13)
	_add_ford(Vector2(-20, 55), 0.30)

func _add_bridge(logical_position: Vector2, rotation_value: float) -> void:
	var bridge := Node2D.new(); bridge.name = "StoneBridge"; bridge.position = logical_to_pixel(logical_position); bridge.rotation = rotation_value; bridge.z_index = -18; add_child(bridge)
	var sprite := Sprite2D.new(); sprite.texture = STONE_BRIDGE; var scale_value := 150.0 / STONE_BRIDGE.get_width(); sprite.scale = Vector2(scale_value,scale_value); bridge.add_child(sprite)

func _add_ford(logical_position: Vector2, rotation_value: float) -> void:
	var ford := Node2D.new(); ford.name = "ShallowFord"; ford.position = logical_to_pixel(logical_position); ford.rotation = rotation_value; ford.z_index = -18; add_child(ford)
	var sprite := Sprite2D.new(); sprite.texture = SHALLOW_FORD; var scale_value := 142.0 / SHALLOW_FORD.get_width(); sprite.scale = Vector2(scale_value,scale_value); ford.add_child(sprite)

func _build_buildings() -> void:
	for building in layout.structures:
		var texture := load("res://assets/2d/production/%s.png" % building.asset) as Texture2D
		var centre := Vector2(building.x, building.z)
		if building.kind == "silo":
			_add_closed_structure(building.node, texture, centre, building.width, building.depth, "")
		elif building.kind == "canopy":
			_add_open_canopy(building.node, texture, centre, building.width, building.depth, "")
		else:
			_add_building(building.node, texture, centre, building.width, building.depth, building.door, "")

func _build_work_zones() -> void:
	# All prop placement is authored in the same measured layout as structures.
	pass

func _build_operational_assets() -> void:
	for prop in layout.props:
		var texture := load("res://assets/2d/production/%s.png" % prop.asset) as Texture2D
		_add_operational_prop(prop.node, texture, Vector2(prop.position[0],prop.position[1]), prop.widthPixels, Vector2(prop.collisionPixels[0],prop.collisionPixels[1]))

func _add_operational_prop(node_name: String, texture: Texture2D, logical_position: Vector2, target_width: float, collision_size: Vector2) -> void:
	var root := Node2D.new(); root.name = node_name; root.position = logical_to_pixel(logical_position); add_child(root)
	_add_contact_shadow(root, target_width * 0.72, target_width * 0.22, Vector2(4,-2))
	root.add_child(_bottom_aligned_sprite(texture, target_width))
	if collision_size.length() > 0.0: _add_static_rect(root, collision_size, Vector2(0,-collision_size.y * 0.5))

func _build_destinations() -> void:
	for destination in layout.get("destinations", []):
		var marker := Node2D.new()
		marker.name = "Destination_%s" % str(destination.id)
		marker.position = logical_to_pixel(Vector2(float(destination.position[0]), float(destination.position[1])))
		marker.z_as_relative = false
		marker.z_index = 70
		marker.set_meta("radius", float(destination.radius))
		marker.set_meta("purpose", str(destination.purpose))
		add_child(marker)
		var panel := PanelContainer.new()
		panel.name = "DestinationPanel"
		panel.position = Vector2(-78,-72)
		panel.size = Vector2(156,31)
		panel.visible = false
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.035,0.12,0.085,0.91)
		style.border_color = Color("#f0cf72")
		style.set_border_width_all(2)
		style.set_corner_radius_all(8)
		panel.add_theme_stylebox_override("panel", style)
		marker.add_child(panel)
		var label := Label.new()
		label.text = str(destination.label)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 13)
		label.add_theme_color_override("font_color", Color("#fff1bd"))
		panel.add_child(label)
		var pointer := Polygon2D.new()
		pointer.name = "DestinationPointer"
		pointer.polygon = PackedVector2Array([Vector2(-7,-39),Vector2(7,-39),Vector2(0,-29)])
		pointer.color = Color("#f0cf72")
		pointer.visible = false
		marker.add_child(pointer)
		panel.visibility_changed.connect(func(): pointer.visible = panel.visible)
		destination_nodes[str(destination.id)] = marker

func _add_prop(node_name: String, texture: Texture2D, logical_position: Vector2, target_width: float, collision_size: Vector2) -> void:
	var root := Node2D.new(); root.name = node_name; root.position = logical_to_pixel(logical_position); add_child(root)
	_add_contact_shadow(root, target_width * 0.74, target_width * 0.24, Vector2(4,-2))
	var sprite := _bottom_aligned_sprite(texture, target_width); root.add_child(sprite)
	_add_static_rect(root, collision_size, Vector2(0,-collision_size.y * 0.5))

func _add_building(node_name: String, texture: Texture2D, logical_centre: Vector2, width_m: float, depth_m: float, door_m: float, label_text: String) -> void:
	var root := Node2D.new(); root.name = node_name
	var centre := logical_to_pixel(logical_centre)
	root.position = centre + Vector2(0, depth_m * PIXELS_PER_METRE * 0.5)
	add_child(root)
	_add_contact_shadow(root, width_m * PIXELS_PER_METRE * 0.92, depth_m * PIXELS_PER_METRE * 0.72, Vector2(7, -depth_m * PIXELS_PER_METRE * 0.18))
	var sprite := _bottom_aligned_sprite(texture, width_m * PIXELS_PER_METRE); sprite.name = "ForegroundArt"; root.add_child(sprite)
	_add_building_collision(root, width_m * PIXELS_PER_METRE, depth_m * PIXELS_PER_METRE, door_m * PIXELS_PER_METRE)
	var interior := Area2D.new(); interior.name = "InteriorReveal"; interior.collision_layer = 0; interior.collision_mask = 2; interior.position = Vector2(0, -depth_m * PIXELS_PER_METRE * 0.48); root.add_child(interior)
	var interior_shape := CollisionShape2D.new(); var rectangle := RectangleShape2D.new(); rectangle.size = Vector2(maxf(20.0, width_m * PIXELS_PER_METRE - 28.0), maxf(20.0, depth_m * PIXELS_PER_METRE - 24.0)); interior_shape.shape = rectangle; interior.add_child(interior_shape)
	var floor := Polygon2D.new(); floor.name = "UsableInteriorFloor"
	var half_width := (width_m*PIXELS_PER_METRE-26.0)*.5
	var back := -depth_m*PIXELS_PER_METRE+13.0
	floor.polygon = PackedVector2Array([Vector2(-half_width,back),Vector2(half_width,back),Vector2(half_width,-7),Vector2(-half_width,-7)])
	floor.texture = preload("res://assets/2d/production/interior_timber.png")
	floor.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	var floor_uv := PackedVector2Array()
	for point in floor.polygon: floor_uv.append(Vector2(point.y,point.x)*3.0)
	floor.uv = floor_uv
	floor.color = Color(.90,.85,.72)
	floor.z_index = -12; floor.z_as_relative = false
	floor.visible = false; root.add_child(floor)
	# Cutaway masonry follows structural walls, leaving the actual door open.
	var wall_rects := [
		Rect2(-half_width-7,back-7,half_width*2+14,7),
		Rect2(-half_width-7,back,7,-7-back),
		Rect2(half_width,back,7,-7-back),
		Rect2(-half_width-7,-7,half_width+7-door_m*PIXELS_PER_METRE*.5,7),
		Rect2(door_m*PIXELS_PER_METRE*.5,-7,half_width+7-door_m*PIXELS_PER_METRE*.5,7)]
	for rect in wall_rects:
		var wall := Polygon2D.new()
		wall.polygon = PackedVector2Array([rect.position,rect.position+Vector2(rect.size.x,0),rect.end,rect.position+Vector2(0,rect.size.y)])
		wall.texture = preload("res://assets/2d/production/interior_limestone.png")
		wall.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		wall.uv = PackedVector2Array([rect.position*4,(rect.position+Vector2(rect.size.x,0))*4,rect.end*4,(rect.position+Vector2(0,rect.size.y))*4])
		wall.z_index = 1
		floor.add_child(wall)
	# Rear-wall furnishings reuse the coordinated world props and leave the centre
	# aisle/door clear. They reveal with the structural floor, not the roof image.
	var furnishing: Texture2D=preload("res://assets/2d/production/produce_crates.png")
	if node_name=="StoneBarn": furnishing=preload("res://assets/2d/production/hay_bale_stack.png")
	elif node_name=="RepairWorkshop": furnishing=preload("res://assets/2d/production/tool_station.png")
	elif node_name=="MachineryShed": furnishing=preload("res://assets/2d/production/spare_parts_crate.png")
	for side in [-1,1]:
		var prop:=_bottom_aligned_sprite(furnishing,minf(42,width_m*PIXELS_PER_METRE*.24))
		prop.position=Vector2(side*half_width*.64,back-12);prop.z_index=2;floor.add_child(prop)
	root.set_meta("usable_interior",Rect2(Vector2(-half_width,back),Vector2(half_width*2,-7-back)))
	var occupants := {"count": 0}
	interior.body_entered.connect(func(body):
		if str(body.name).begins_with("Player"):
			occupants.count += 1; sprite.modulate.a = 0.12; floor.visible = true
	)
	interior.body_exited.connect(func(body):
		if str(body.name).begins_with("Player"):
			occupants.count = maxi(0, int(occupants.count) - 1); sprite.modulate.a = 0.12 if occupants.count > 0 else 1.0; floor.visible = occupants.count > 0
	)
	if not label_text.is_empty(): _add_world_label(root, label_text, Vector2(0, -depth_m * PIXELS_PER_METRE - 24))

func _add_closed_structure(node_name: String, texture: Texture2D, logical_centre: Vector2, width_m: float, depth_m: float, label_text: String) -> void:
	var root := Node2D.new(); root.name = node_name; root.position = logical_to_pixel(logical_centre) + Vector2(0, depth_m * PIXELS_PER_METRE * 0.5); add_child(root)
	_add_contact_shadow(root, width_m * PIXELS_PER_METRE * 0.90, depth_m * PIXELS_PER_METRE * 0.70, Vector2(7, -depth_m * PIXELS_PER_METRE * 0.18))
	root.add_child(_bottom_aligned_sprite(texture, width_m * PIXELS_PER_METRE))
	_add_static_rect(root, Vector2(width_m * PIXELS_PER_METRE, depth_m * PIXELS_PER_METRE), Vector2(0, -depth_m * PIXELS_PER_METRE * 0.5))
	if not label_text.is_empty(): _add_world_label(root, label_text, Vector2(0, -depth_m * PIXELS_PER_METRE - 20))

func _add_open_canopy(node_name: String, texture: Texture2D, logical_centre: Vector2, width_m: float, depth_m: float, label_text: String) -> void:
	var root := Node2D.new(); root.name = node_name; root.position = logical_to_pixel(logical_centre) + Vector2(0, depth_m * PIXELS_PER_METRE * 0.5); add_child(root)
	_add_contact_shadow(root, width_m * PIXELS_PER_METRE * 0.90, depth_m * PIXELS_PER_METRE * 0.62, Vector2(7, -depth_m * PIXELS_PER_METRE * 0.12))
	var sprite := _bottom_aligned_sprite(texture, width_m * PIXELS_PER_METRE); root.add_child(sprite)
	_add_static_rect(root, Vector2(13, depth_m * PIXELS_PER_METRE), Vector2(-width_m * PIXELS_PER_METRE * 0.43, -depth_m * PIXELS_PER_METRE * 0.5))
	_add_static_rect(root, Vector2(13, depth_m * PIXELS_PER_METRE), Vector2(width_m * PIXELS_PER_METRE * 0.43, -depth_m * PIXELS_PER_METRE * 0.5))
	if not label_text.is_empty(): _add_world_label(root, label_text, Vector2(0, -depth_m * PIXELS_PER_METRE - 20))

func _build_trees() -> void:
	for tree in layout.trees:
		var tree_assets := {"oak_tree":"reference_oak","willow_tree":"reference_willow","orchard_tree":"reference_orchard","flowering_tree":"reference_blossom"}
		var texture := load("res://assets/2d/production/%s.png" % tree_assets.get(tree.asset,tree.asset)) as Texture2D
		_add_tree(tree.node, texture, Vector2(tree.position[0],tree.position[1]), tree.heightMetres)

func _add_tree(node_name: String, texture: Texture2D, logical_position: Vector2, visual_height_m: float) -> void:
	var root := Node2D.new(); root.name = node_name; root.position = logical_to_pixel(logical_position); add_child(root)
	var target_height := visual_height_m * PIXELS_PER_METRE
	_add_contact_shadow(root, target_height * 0.58, target_height * 0.19, Vector2(7, -2))
	var sprite := Sprite2D.new(); sprite.texture = texture; var scale_value := target_height / texture.get_height(); sprite.scale = Vector2(scale_value, scale_value); sprite.position.y = -target_height * 0.5; root.add_child(sprite)
	var collision := CollisionShape2D.new(); var circle := CircleShape2D.new(); circle.radius = clampf(visual_height_m * 0.65, 9.0, 14.0); collision.shape = circle; collision.position = Vector2(0, -5); var body := StaticBody2D.new(); body.collision_layer = 1; body.collision_mask = 0; body.add_child(collision); root.add_child(body)
	var reveal := Area2D.new(); reveal.collision_layer = 0; reveal.collision_mask = 2; reveal.position = Vector2(0, -target_height * 0.35); root.add_child(reveal)
	var reveal_shape := CollisionShape2D.new(); var reveal_circle := CircleShape2D.new(); reveal_circle.radius = target_height * 0.31; reveal_shape.shape = reveal_circle; reveal.add_child(reveal_shape)
	var occupants := {"count": 0}
	reveal.body_entered.connect(func(body_entered):
		if str(body_entered.name).begins_with("Player"): occupants.count += 1; sprite.modulate.a = 0.56
	)
	reveal.body_exited.connect(func(body_exited):
		if str(body_exited.name).begins_with("Player"): occupants.count = maxi(0, int(occupants.count) - 1); sprite.modulate.a = 0.56 if occupants.count > 0 else 1.0
	)

func _build_boundaries() -> void:
	for boundary in layout.boundaries:
		_add_boundary_line(boundary.node, boundary.kind, Vector2(boundary.start[0],boundary.start[1]), Vector2(boundary.end[0],boundary.end[1]))
	_add_boundary_end("PastureGate", "hedge", Vector2(-42,-9))
	_add_boundary_end("CropGate", "hedge", Vector2(33,-9))
	# West-yard wall ends form a clear aperture without rotating perspective art.

func _add_boundary_line(prefix: String, kind: String, start: Vector2, finish: Vector2) -> void:
	var horizontal := absf(finish.x - start.x) >= absf(finish.y - start.y)
	var distance := start.distance_to(finish)
	var count := maxi(1, ceili(distance / 8.0))
	var segment_length := distance / count
	for index in range(count):
		var midpoint := start.lerp(finish, (float(index) + 0.5) / count)
		_add_boundary_module("%s%02d" % [prefix,index], kind, midpoint, segment_length, horizontal)

func _add_boundary_module(node_name: String, kind: String, logical_position: Vector2, length_m: float, horizontal: bool) -> void:
	var root := Node2D.new(); root.name = node_name; root.position = logical_to_pixel(logical_position); add_child(root)
	var texture: Texture2D = HEDGE_HORIZONTAL if kind == "hedge" and horizontal else HEDGE_VERTICAL if kind == "hedge" else WALL_HORIZONTAL if horizontal else WALL_VERTICAL
	if kind == "hedge" and not horizontal:
		var length_pixels := length_m * PIXELS_PER_METRE
		var count := maxi(2,ceili(length_pixels/12.0))
		for i in range(count):
			var crown := _bottom_aligned_sprite(HEDGE_HORIZONTAL,43.0)
			crown.position += Vector2(sin(float(i)*2.0)*3.0,-length_pixels*.5+(float(i)+.5)*length_pixels/count)
			root.add_child(crown)
		_add_static_rect(root,Vector2(10.0,length_pixels*.92),Vector2(0,-4))
		return
	var sprite := Sprite2D.new(); sprite.texture = texture
	var length_pixels := length_m * PIXELS_PER_METRE
	var scale_value := length_pixels / (texture.get_width() if horizontal else texture.get_height())
	sprite.scale = Vector2(scale_value * (1.14 if horizontal else 1.0), scale_value * (1.5 if horizontal and kind == "hedge" else 1.0 if horizontal else 1.14))
	sprite.flip_h = horizontal and int(logical_position.x) % 3 == 0
	sprite.modulate = Color(0.95,1.0,0.91) if int(logical_position.x + logical_position.y) % 2 == 0 else Color.WHITE
	sprite.position.y = -maxf(4.0, texture.get_height() * scale_value * 0.23)
	root.add_child(sprite)
	_add_static_rect(root, Vector2(length_pixels * 0.92, 10.0) if horizontal else Vector2(10.0, length_pixels * 0.92), Vector2(0,-4))

func _add_boundary_end(node_name: String, kind: String, logical_position: Vector2, vertical: bool = false) -> void:
	var root := Node2D.new(); root.name = node_name; root.position = logical_to_pixel(logical_position); add_child(root)
	var sprite := Sprite2D.new(); sprite.texture = HEDGE_GATE if kind == "hedge" else WALL_GATE
	var target_width := 120.0 if node_name == "PastureGate" else 100.0 if node_name == "CropGate" else 60.0
	var scale_value := target_width / sprite.texture.get_width(); sprite.scale = Vector2(scale_value,scale_value); sprite.position.y = -sprite.texture.get_height() * scale_value * 0.35; sprite.rotation = PI * 0.5 if vertical else 0.0; root.add_child(sprite)

func _build_world_edge() -> void:
	_add_static_rect(self, Vector2(1700, 24), Vector2(850, -12))
	_add_static_rect(self, Vector2(1700, 24), Vector2(850, 1212))
	_add_static_rect(self, Vector2(24, 1200), Vector2(-12, 600))
	_add_static_rect(self, Vector2(24, 1200), Vector2(1712, 600))

func _build_estate_edge() -> void:
	# Beyond the playable fence: scenery roots are outside the collision estate.
	# These are individual sprites, not a painted background containing actors.
	var edge_positions: Array[Vector2] = []
	for x in range(-94,100,11): edge_positions.append(Vector2(x,-60))
	for y in range(-44,65,13):
		edge_positions.append(Vector2(-89,y)); edge_positions.append(Vector2(90,y))
	for index in range(edge_positions.size()):
		var root := Node2D.new(); root.name = "BeyondEstate%d" % index; root.position = logical_to_pixel(edge_positions[index] + Vector2(sin(float(index)*2.7)*2.4, -absf(sin(float(index)*1.9))*2.0)); add_child(root)
		root.add_child(_bottom_aligned_sprite(load("res://assets/2d/production/verge_shrub.png"),110.0))
		var texture: Texture2D = FLOWERING_TREE if index % 7 == 0 else load("res://assets/2d/production/reference_oak_b.png") if index % 3 == 0 else OAK_TREE
		var tree_art := _bottom_aligned_sprite(texture,92.0+absf(sin(float(index)*1.73))*48.0)
		tree_art.flip_h = index % 2 == 0
		tree_art.modulate = Color(0.91+float(index%3)*.025,0.96,0.88+float(index%4)*.025)
		root.add_child(tree_art)

func _build_verge_dressing() -> void:
	# Small authored foliage groups sit on boundary shoulders, never in travel lanes.
	var flowers := load("res://assets/2d/production/verge_flowers.png") as Texture2D
	var reeds := load("res://assets/2d/production/verge_reeds.png") as Texture2D
	var shrub := load("res://assets/2d/production/verge_shrub.png") as Texture2D
	for boundary in layout.boundaries:
		var start := Vector2(boundary.start[0],boundary.start[1]); var finish := Vector2(boundary.end[0],boundary.end[1])
		var count := int(start.distance_to(finish)/7.0)
		for index in range(count):
			var pos := start.lerp(finish,(float(index)+.5)/maxi(1,count)) + Vector2(0,1.6)
			var root := Node2D.new(); root.position = logical_to_pixel(pos); add_child(root)
			root.add_child(_bottom_aligned_sprite(flowers,29.0 + float(index%3)*5.0))
	for pos in [Vector2(-82,42),Vector2(-73,43),Vector2(-53,42),Vector2(-44,44),Vector2(-33,47),Vector2(-27,49),Vector2(-10,54),Vector2(-76,52),Vector2(-51,52),Vector2(-30,57)]:
		var root := Node2D.new(); root.position = logical_to_pixel(pos); add_child(root); root.add_child(_bottom_aligned_sprite(reeds,47.0))
	for pos in [Vector2(-24,-15),Vector2(-22,-19),Vector2(-28,24),Vector2(1,29),Vector2(29,24),Vector2(39,37),Vector2(79,36),Vector2(-78,-54),Vector2(-64,-53),Vector2(-30,-53),Vector2(7,-47)]:
		var root := Node2D.new(); root.position = logical_to_pixel(pos); add_child(root); root.add_child(_bottom_aligned_sprite(shrub,45.0))

func _bottom_aligned_sprite(texture: Texture2D, target_width: float) -> Sprite2D:
	var sprite := Sprite2D.new(); sprite.texture = texture
	var scale_value := target_width / texture.get_width(); sprite.scale = Vector2(scale_value, scale_value)
	sprite.position.y = -texture.get_height() * scale_value * 0.5
	return sprite

func _add_contact_shadow(parent: Node2D, width: float, height: float, offset: Vector2) -> void:
	var shadow := Sprite2D.new(); shadow.name = "ContactShadow"; shadow.texture = CONTACT_SHADOW; shadow.position = offset
	shadow.scale = Vector2(width / CONTACT_SHADOW.get_width(), height / CONTACT_SHADOW.get_height()); shadow.z_index = -14; shadow.z_as_relative = false; shadow.modulate = Color(0.65,0.75,0.70,0.85); parent.add_child(shadow)

func _scaled_uv(points: PackedVector2Array, scale_value: float) -> PackedVector2Array:
	var result := PackedVector2Array()
	for point in points: result.append(point * scale_value)
	return result

func _offset_polyline(points: PackedVector2Array, distance: float) -> PackedVector2Array:
	var result := PackedVector2Array()
	for index in range(points.size()):
		var previous: Vector2 = points[maxi(0, index - 1)]
		var following: Vector2 = points[mini(points.size() - 1, index + 1)]
		var direction := (following - previous).normalized()
		result.append(points[index] + Vector2(-direction.y, direction.x) * distance)
	return result

func _add_building_collision(root: Node2D, width: float, depth: float, door_width: float) -> void:
	var wall := 13.0
	_add_static_rect(root, Vector2(width, wall), Vector2(0, -depth))
	_add_static_rect(root, Vector2(wall, depth), Vector2(-width * 0.5, -depth * 0.5))
	_add_static_rect(root, Vector2(wall, depth), Vector2(width * 0.5, -depth * 0.5))
	var front_piece := maxf(10.0, (width - door_width) * 0.5)
	_add_static_rect(root, Vector2(front_piece, wall), Vector2(-width * 0.5 + front_piece * 0.5, 0))
	_add_static_rect(root, Vector2(front_piece, wall), Vector2(width * 0.5 - front_piece * 0.5, 0))

func _add_static_rect(parent: Node, size: Vector2, offset: Vector2) -> void:
	var body := StaticBody2D.new(); body.collision_layer = 1; body.collision_mask = 0; parent.add_child(body)
	var collision := CollisionShape2D.new(); var rectangle := RectangleShape2D.new(); rectangle.size = size; collision.shape = rectangle; collision.position = offset; body.add_child(collision)

func _add_segment_collision(node_name: String, start: Vector2, finish: Vector2, width: float) -> void:
	var body := StaticBody2D.new(); body.name = node_name; body.collision_layer = 1; body.collision_mask = 0; add_child(body)
	var collision := CollisionShape2D.new(); var rectangle := RectangleShape2D.new(); rectangle.size = Vector2(start.distance_to(finish), width); collision.shape = rectangle; collision.position = (start + finish) * 0.5; collision.rotation = (finish - start).angle(); body.add_child(collision)

func _add_world_label(parent: Node2D, text_value: String, offset: Vector2) -> void:
	var label := Label.new(); label.text = text_value; label.position = offset + Vector2(-110, 0); label.size = Vector2(220, 28); label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; label.add_theme_font_size_override("font_size", 13); label.add_theme_color_override("font_color", Color("#fff4c8")); label.add_theme_color_override("font_outline_color", Color("#263a2c")); label.add_theme_constant_override("outline_size", 5); parent.add_child(label)

func _logical_points(values: Array) -> PackedVector2Array:
	var result := PackedVector2Array()
	for value in values: result.append(logical_to_pixel(Vector2(float(value[0]), float(value[1]))))
	return result


func _build_sun_shadows() -> void:
	# Static silhouettes project southeast from their ground anchor. Keep shadows
	# below every actor, independent of y-sort and building reveal transparency.
	var layer := Node2D.new()
	layer.name = "SunShadows"
	layer.z_index = -15
	var shadow_material := ShaderMaterial.new()
	shadow_material.shader = preload("res://shaders/sun_shadow.gdshader")
	for object in get_children():
		if object == crop_field or not object is Node2D or str(object.name).begins_with("PastureSheep"): continue
		for child in object.get_children():
			if not child is Sprite2D or child.name == "ContactShadow": continue
			var art := child as Sprite2D
			if art.texture == null or object.rotation != 0.0: continue
			for structure in layout.structures:
				if str(object.name) == str(structure.node):
					var clean := ShaderMaterial.new()
					clean.shader = preload("res://shaders/clean_sprite.gdshader")
					art.material = clean
					break
			var path := art.texture.resource_path
			if "flowers" in path or "rocks" in path or "grate" in path: continue
			var shadow := Sprite2D.new()
			shadow.texture = art.texture
			shadow.flip_h = art.flip_h
			shadow.material = shadow_material
			var h := float(art.texture.get_height()) * art.scale.y
			var foot: Vector2 = object.position + art.position + Vector2(0,h*.5)
			shadow.transform = Transform2D(Vector2(art.scale.x,0),Vector2(-art.scale.y*.30,-art.scale.y*.18),foot+Vector2(h*.15,h*.09-2.0))
			layer.add_child(shadow)
			if "tree" in path or "reference_oak" in path or "reference_orchard" in path or "reference_blossom" in path or "reference_willow" in path or "shrub" in path or "reeds" in path:
				var breeze := ShaderMaterial.new()
				breeze.shader = preload("res://shaders/foliage_breeze.gdshader")
				breeze.set_shader_parameter("phase",object.position.x*.07+object.position.y*.03)
				art.material = breeze
	add_child(layer)

func _dress_building_bases() -> void:
	# Planting is anchored to facade corners; keep the measured centre door clear.
	var flowers := load("res://assets/2d/production/verge_flowers.png") as Texture2D
	var shrub := load("res://assets/2d/production/verge_shrub.png") as Texture2D
	for building in layout.structures:
		if building.kind in ["silo","canopy"]: continue
		var root := get_node(str(building.node)) as Node2D
		var width := float(building.width)*PIXELS_PER_METRE
		for side in [-1.0,1.0]:
			var plant := _bottom_aligned_sprite(shrub,24.0 if building.kind == "barn" else 18.0)
			plant.position += Vector2(side*width*.44,-2)
			root.add_child(plant)
			var bloom := _bottom_aligned_sprite(flowers,28.0)
			bloom.position += Vector2(side*width*.38,2)
			root.add_child(bloom)
