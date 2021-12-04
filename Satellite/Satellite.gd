extends BaseSatellite
class_name Satellite

onready var body = get_node("Body")
onready var l_panel = get_node("L Panel")
onready var r_panel = get_node("R Panel")

func destroy() -> void:
	emit_signal("satellite_destroyed")
	var body_dir = vel.normalized()
	var l_panel_dir = vel.normalized().rotated(-TAU/4) + vel.normalized()
	var r_panel_dir = vel.normalized().rotated(TAU/4) + vel.normalized()
	body.start(self.global_position, body_dir.angle())
	l_panel.start(self.global_position, l_panel_dir.angle())
	r_panel.start(self.global_position, r_panel_dir.angle())
	self.remove_child(body)
	self.remove_child(l_panel)
	self.remove_child(r_panel)
	var root = get_tree().root
	root.add_child(body)
	root.add_child(l_panel)
	root.add_child(r_panel)
	call_deferred("queue_free")
