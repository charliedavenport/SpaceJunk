extends KinematicBody2D

const speed: float = 750.0

onready var screen_width = get_viewport_rect().size.x
onready var screen_height = get_viewport_rect().size.y

signal projectile_hit(collision)

func start(transf: Transform2D):
	self.global_transform = transf
	$KillTimer.connect("timeout", self, "on_timeout")
	$KillTimer.start()

func _physics_process(delta):
	var vel = self.transform.y * speed * -1 * delta
	var collision = move_and_collide(vel)
	if collision:
		emit_signal("projectile_hit", collision)
		queue_free()
	position.x = wrapf(position.x, 0, screen_width)
	position.y = wrapf(position.y, 0, screen_height)

func on_timeout() -> void:
	queue_free()
