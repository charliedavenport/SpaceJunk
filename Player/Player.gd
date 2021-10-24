extends KinematicBody2D

export var thrust: float = 1.0
export var stopping_thrust: float = 2.0
export var turnspeed: float = 1.0

var vel: Vector2
var alive: bool
var game_over: bool

onready var screen_width = get_viewport_rect().size.x
onready var screen_height = get_viewport_rect().size.y
onready var projectile = preload("res://Projectile/Projectile.tscn")

signal player_hit

func _ready():
	alive = true
	game_over = false
	vel = Vector2.ZERO
	$ThrusterPolygon.visible = false
	$AnimationPlayer.play("Idle")

func _physics_process(delta):
	if not alive:
		return
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
		emit_signal("player_hit")
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

func kill(a_game_over: bool) -> void:
	alive = false
	game_over = a_game_over 
	$CollisionShape2D.disabled = true
	$AnimationPlayer.play("Destroyed")
	$ThrusterPolygon.visible = false

func on_destroyed_end() -> void:
	if game_over:
		queue_free()
	$AnimationPlayer.play("Idle")
	reset()

func reset() -> void:
	alive = true
	rotation = 0.0
	position = Vector2(screen_width/2, screen_height/2)
	vel = Vector2.ZERO
	$CollisionShape2D.disabled = false

