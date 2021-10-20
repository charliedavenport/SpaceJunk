extends KinematicBody2D

const speed: float = 500.0

signal hit

func start(transf: Transform2D):
	self.global_transform = transf

func _physics_process(delta):
	var vel = self.transform.y * speed * -1 * delta
	var collision = move_and_collide(vel)
	if collision:
		queue_free()
