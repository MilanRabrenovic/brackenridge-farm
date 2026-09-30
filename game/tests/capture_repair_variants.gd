extends SceneTree
# Staged solo wording review, not completion or qualifying TV footage.
func _init() -> void:call_deferred("capture")
func capture() -> void:
	root.size=Vector2i(1280,720)
	var host=load("res://main.tscn").instantiate();root.add_child(host);await process_frame
	host.set_process(false);host.set_physics_process(false);host.admitted_players=1
	host.lobby_panel.hide();host.lobby_backdrop.hide()
	var session=host.weekend
	if session==null:quit(1);return
	session.sound_enabled=false;session.start(1)
	for fault_variant in [0,2]:
		session.variant=fault_variant;session._enter("repair",180)
		session.update(.016,host.logical_positions,{1:{"action":false},2:{"action":false}})
		host._update_camera(100)
		await process_frame;await process_frame;await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://../docs/audits/2026-09-30-solo/repair-%s.png" % host.repair_incident.required_part)
	quit()
