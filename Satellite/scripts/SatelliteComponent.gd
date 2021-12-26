extends BaseSatellite
class_name SatelliteComponent

onready var coll_poly = get_node("CollisionPolygon2D")

onready var shard1 = get_node("Shard1")
onready var shard2 = get_node("Shard2")

const destroy_sound = preload("res://Satellite/assets/explodify3.wav")

func _ready():
	set_physics_process(false)
	coll_poly.disabled = true
	audio_stream.connect("finished", self, "on_audio_finished")

func start(pos: Vector2, vel_rot: float, rot: float):
	coll_poly.disabled = false
	set_physics_process(true)
	.start(pos, vel_rot, rot)

func destroy() -> void:
	emit_signal("satellite_destroyed")
	audio_stream.stream = destroy_sound
	audio_stream.play()
	var dir1 = (shard1.global_position - global_position).normalized() + vel.normalized()
	var dir2 = (shard2.global_position - global_position).normalized() + vel.normalized()
	shard1.start(shard1.global_position, dir1.angle(), self.rotation)
	shard2.start(shard2.global_position, dir2.angle(), self.rotation)
	self.remove_child(shard1)
	self.remove_child(shard2)
	var root = get_tree().root
	root.add_child(shard1)
	root.add_child(shard2)
	self.visible = false
	collision_poly.disabled = true
	#call_deferred("queue_free")

func on_audio_finished() -> void:
	queue_free()
