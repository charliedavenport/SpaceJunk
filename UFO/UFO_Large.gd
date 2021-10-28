extends KinematicBody2D
class_name UFO_Large

onready var screen_width = get_viewport_rect().size.x
onready var screen_height = get_viewport_rect().size.y

var target_point: Vector2
var speed: float = 100.0
var vel: Vector2

signal ufo_destroyed

func start(a_point: Vector2, a_target: Vector2) -> void:
	position = a_point
	target_point = a_target
	vel = (target_point - position).normalized()


func _physics_process(delta):
	var collision = move_and_collide(vel * speed * delta)
	if collision:
		if collision.collider is Asteroid:
			print('ufo hit asteroid')
			collision.collider.destroy()
			destroy()
	position.x = wrapf(position.x, 0, screen_width)
	position.y = wrapf(position.y, 0, screen_height)

func destroy() -> void:
	print('destroying ufo')
	emit_signal("ufo_destroyed")
	queue_free()


