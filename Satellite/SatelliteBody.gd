extends BaseSatellite
class_name SatelliteBody

onready var collision_shape = get_node("CollisionShape2D")

func _ready():
	collision_shape.disabled = true
	set_physics_process(false)

func start(pos: Vector2, rot: float):
	collision_shape.disabled = false
	set_physics_process(true)
	.start(pos, rot)

func destroy() -> void:
	emit_signal("satellite_destroyed")
	queue_free()
