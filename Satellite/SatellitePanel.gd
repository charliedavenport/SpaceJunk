extends BaseSatellite
class_name SatellitePanel

onready var coll_poly_1 = get_node("CollisionPolygon2D")
onready var coll_poly_2 = get_node("CollisionPolygon2D2")

func _ready():
	set_physics_process(false)
	coll_poly_1.disabled = true
	coll_poly_2.disabled = true

func start(pos: Vector2, rot: float):
	coll_poly_1.disabled = false
	coll_poly_2.disabled = false
	set_physics_process(true)
	.start(pos, rot)

func destroy() -> void:
	emit_signal("satellite_destroyed")
	queue_free()
