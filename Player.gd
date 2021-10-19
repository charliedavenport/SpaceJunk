extends KinematicBody2D

export var thrust: float = 1.0
export var turnspeed: float = 1.0

var vel: Vector2

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
		var delta_vec = -1.0 * transform.y * thrust * delta
		vel += delta_vec
	else:
		$ThrusterPolygon.visible = false
	var collision = move_and_collide(vel)
	if collision:
		pass # do something
