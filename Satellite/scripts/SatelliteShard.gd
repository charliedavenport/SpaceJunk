extends BaseSatellite
class_name SatelliteShard

onready var coll_poly = get_node("CollisionPolygon2D")

const destroy_sound = preload("res://Satellite/assets/explodify5.wav")

func _ready():
	set_physics_process(false)
	coll_poly.disabled = true
	self.visible = false
	audio_stream.connect("finished", self, "on_audio_finished")

func start(pos: Vector2, vel_rot: float, rot: float):
	coll_poly.disabled = false
	set_physics_process(true)
	self.visible = true
	.start(pos, vel_rot, rot)

func destroy() -> void:
	emit_signal("satellite_destroyed")
	audio_stream.stream = destroy_sound
	audio_stream.play()
	self.visible = false
	collision_poly.disabled = true
	#queue_free()

func on_audio_finished() -> void:
	queue_free()

