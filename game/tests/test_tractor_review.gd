extends SceneTree
func _init() -> void: call_deferred("verify")
func verify() -> void:
	root.size = Vector2i(1280,720)
	var host = load("res://main.tscn").instantiate(); root.add_child(host)
	await process_frame
	host.set_physics_process(false); host.set_process(false)
	host.lobby_panel.hide(); host.lobby_backdrop.hide()
	host.tractor_directional_approved = true
	var label := Label.new(); label.text="DIRECTIONAL TRACTOR — ART REVIEW"; label.position=Vector2(30,20); label.add_theme_font_size_override("font_size",24); var hud := CanvasLayer.new(); hud.layer = 100; root.add_child(hud); hud.add_child(label)
	host.tractor_body.position=host._logical_to_pixel(Vector2(44,-30))
	host.logical_positions={1:Vector2(44,-30),2:Vector2(44,-30)}
	for id in [1,2]: host.players[id].hide()
	host._update_camera(100)
	for y in range(7): host.world_root.crop_field.apply_tractor_work(host._logical_to_pixel(Vector2(44,-30))+Vector2(0,y*28))
	for entry in [["down",Vector2.DOWN],["up",Vector2.UP],["left",Vector2.LEFT],["right",Vector2.RIGHT]]:
		await physics_frame
		host._drive_tractor(1,entry[1],false,.016)
		if host.tractor_sprite.rotation != 0: push_error("Tractor tilted"); quit(1); return
		if host.tractor_sprite.texture != host.tractor_directions[entry[0]]: push_error("Wrong facing"); quit(1); return
		await process_frame
		if DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://../docs/audits/2026-09-28-cohesive/tractor-%s.png" % entry[0])
	print("Four upright tractor directions passed")
	quit()
