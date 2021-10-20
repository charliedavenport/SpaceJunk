extends KinematicBody2D

export var thrust: float = 1.0
export var stopping_thrust: float = 2.0
export var turnspeed: float = 1.0

var vel: Vector2

onready var screen_width = get_viewport_rect().size.x
onready var screen_height = get_viewport_rect().size.y
onready var projectile = preload("res://Projectile.tscn")

func _ready():
	vel = Vector2.ZERO
	$ThrusterPolygon.visible = true

func _physics_process(delta):
	# handle rotation
	if Input.is_action_pressed("turn_left"):
		rotate(-1.0 * turnspeed * delta)
	elif Input.is_action_pressed("turn_right"):
		rotate(turnspeed * delta)
	# handle thrust
	if Input.is_action_pressed("forward"):
		$ThrusterPolygon.visible = true
		var delta_vec = -1.0 * transform.y * delta
		if delta_vec.dot(vel) > 0:
			delta_vec *= thrust
		else:
			delta_vec *= stopping_thrust
		vel += delta_vec
	else:
		$ThrusterPolygon.visible = false
	var collision = move_and_collide(vel)
	if collision:
		kill()
	# wrap player to other side of screen
	position.x = wrapf(position.x, 0, screen_width)
	position.y = wrapf(position.y, 0, screen_height)

func _input(event):
	if event.is_action_pressed("shoot"):
		shoot()

func shoot() -> void:
	var projectile_inst = projectile.instance()
	get_tree().root.add_child(projectile_inst)
	projectile_inst.start(self.global_transform)

func kill() -> void:
	pass
