class_name Asteroid
extends KinematicBody2D

var speed: float = 50
var rot_speed: float = 1.0
var vel: Vector2
var screen_padding: float = 30.0

onready var screen_width = get_viewport_rect().size.x
onready var screen_height = get_viewport_rect().size.y
onready var rng = RandomNumberGenerator.new()

signal asteroid_destroyed(node)

func _ready():
	rng.randomize()

func start(point: Vector2, rot: float) -> void:
	self.position = point
	self.rotate(rot)
	vel = transform.y * speed * -1

func _physics_process(delta):
	self.rotate(rot_speed * delta)
	var collision = move_and_collide(vel * delta)
	position.x = wrapf(position.x, 0 - screen_padding, screen_width + screen_padding)
	position.y = wrapf(position.y, 0 - screen_padding, screen_height + screen_padding)
	
