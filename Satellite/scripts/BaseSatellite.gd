extends KinematicBody2D
class_name BaseSatellite

export var speed: float
var rot_speed: float = 1.0
var vel: Vector2
var screen_padding: float = 0.0

onready var screen_width = get_viewport_rect().size.x
onready var screen_height = get_viewport_rect().size.y
onready var rng = RandomNumberGenerator.new()
onready var audio_stream = get_node("AudioStreamPlayer")
onready var collision_poly = get_node("CollisionPolygon2D")

signal satellite_destroyed(node)
signal satellite_collision(ast, coll)

func _ready():
	rng.randomize()
	rot_speed = rng.randf_range(-1.0, 1.0)

func start(point: Vector2, vel_rot: float, rot: float) -> void:
	self.position = point
	vel = transform.x * speed
	vel = vel.rotated(vel_rot)
	self.rotate(rot)

func _physics_process(delta):
	self.rotate(rot_speed * delta)
	var collision = move_and_collide(vel * delta)
	if collision:
		emit_signal("satellite_collision", self, collision.collider)
		#self.destroy()
	position.x = wrapf(position.x, 0 - screen_padding, screen_width + screen_padding)
	position.y = wrapf(position.y, 0 - screen_padding, screen_height + screen_padding)

func destroy() -> void:
	# implemented in descendant classes
	pass
