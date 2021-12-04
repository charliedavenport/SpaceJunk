extends KinematicBody2D
class_name Projectile

const speed: float = 1000.0

const red_texture = preload("res://Projectile/projectile_red.png")
const green_texture = preload("res://Projectile/projectile.png")

onready var screen_width = get_viewport_rect().size.x
onready var screen_height = get_viewport_rect().size.y
onready var kill_timer = get_node("KillTimer")

enum source_type {PLAYER, UFO}
var source: int 

signal projectile_hit(proj, collision)

func start(a_point: Vector2, a_rot: float, a_src: int):
	self.global_transform.origin = a_point
	self.rotate(a_rot)
	source = a_src
	if source == source_type.UFO:
		collision_mask = 0b0101 # Asteroid AND Player
		$Sprite.texture = red_texture
	else:
		collision_mask = 0b1100 # UFO AND Asteroid
		$Sprite.texture = green_texture
	kill_timer.start()
	yield(kill_timer, "timeout")
	queue_free()

func _physics_process(delta):
	var vel = self.transform.x * speed * delta
	var collision = move_and_collide(vel)
	if collision:
		emit_signal("projectile_hit", self, collision.collider)
		queue_free()
	position.x = wrapf(position.x, 0, screen_width)
	position.y = wrapf(position.y, 0, screen_height)
