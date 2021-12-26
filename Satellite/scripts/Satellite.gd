extends BaseSatellite
class_name Satellite

onready var body = get_node("Body")
onready var l_panel = get_node("L Panel")
onready var r_panel = get_node("R Panel")

const destroy_sound = preload("res://Satellite/assets/explodify2.wav")

func _ready():
	audio_stream.connect("finished", self, "on_audio_finished")

func destroy() -> void:
	audio_stream.stream = destroy_sound
	audio_stream.play()
	emit_signal("satellite_destroyed")
	var body_dir = vel.normalized()
	var l_panel_dir = (l_panel.global_position - global_position).normalized() + vel.normalized()
	var r_panel_dir = (r_panel.global_position - global_position).normalized() + vel.normalized()
	body.start(body.global_position, body_dir.angle(), self.rotation)
	l_panel.start(l_panel.global_position, l_panel_dir.angle(), self.rotation)
	r_panel.start(r_panel.global_position, r_panel_dir.angle(), self.rotation)
	self.remove_child(body)
	self.remove_child(l_panel)
	self.remove_child(r_panel)
	var root = get_tree().root
	root.add_child(body)
	root.add_child(l_panel)
	root.add_child(r_panel)
	self.visible = false
	collision_poly.disabled = true
	#call_deferred("queue_free")

func on_audio_finished() -> void:
	queue_free()
