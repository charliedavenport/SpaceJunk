extends BaseSatellite
class_name SatelliteShard

onready var coll_poly = get_node("CollisionPolygon2D")

func _ready():
	set_physics_process(false)
	coll_poly.disabled = true
	self.visible = false
	#speed = 75.0

func start(pos: Vector2, vel_rot: float, rot: float):
	coll_poly.disabled = false
	set_physics_process(true)
	self.visible = true
	.start(pos, vel_rot, rot)

func destroy() -> void:
	emit_signal("satellite_destroyed")
	queue_free()
