extends KinematicBody2D
class_name Player

export var thrust: float = 1.0
export var stopping_thrust: float = 2.0
export var turnspeed: float = 1.0
export var slowdown: float = 0.005

var vel: Vector2
var alive: bool
var is_invincible: bool
var is_hyperspace: bool
var is_godmode: bool

onready var screen_width = get_viewport_rect().size.x
onready var screen_height = get_viewport_rect().size.y
onready var rng = RandomNumberGenerator.new()
onready var invincible_timer = get_node("InvincibleTimer")
onready var anim = get_node("AnimationPlayer")
onready var collision_shape = get_node("CollisionShape2D")
onready var thruster = get_node("ThrusterPolygon")
onready var ship_sprite = get_node("ShipSprite")
onready var godmode_sprite = get_node("GodmodeSprite")
const projectile = preload("res://Projectile/Projectile.tscn")

signal player_hit

func _ready():
	self.visible = false
	rng.randomize()
	position = Vector2(screen_width/2, screen_height/2)
	rotation = -TAU/4
	alive = true
	is_hyperspace = false
	is_godmode = false
	vel = Vector2.ZERO
	thruster.visible = false
	anim.play("Idle")

func _physics_process(delta):
	if not alive or is_hyperspace:
		return
	if Input.is_action_just_pressed("hyperspace"):
		do_hyperspace()
		return
	if Input.is_action_just_pressed("cheat_godmode"):
		toggle_godmode()
	# handle rotation
	if Input.is_action_pressed("turn_left"):
		rotate(-1.0 * turnspeed * delta)
	elif Input.is_action_pressed("turn_right"):
		rotate(turnspeed * delta)
	# handle thrust
	if Input.is_action_pressed("forward"):
		thruster.visible = true
		var delta_vec = transform.x * delta
		if delta_vec.dot(vel) > 0:
			delta_vec *= thrust
		else:
			delta_vec *= stopping_thrust
		vel += delta_vec
	else:
		thruster.visible = false
		# gently slow down
		vel *= (1.0 - slowdown)
	var collision = move_and_collide(vel)
	if collision:
		emit_signal("player_hit")
	# wrap player to other side of screen
	position.x = wrapf(position.x, 0, screen_width)
	position.y = wrapf(position.y, 0, screen_height)

func _input(event):
	if event.is_action_pressed("shoot") and alive:
		shoot()

func shoot() -> void:
	var projectile_inst = projectile.instance()
	get_tree().root.add_child(projectile_inst)
	projectile_inst.start(self.global_transform.origin, self.transform.x.angle(), projectile_inst.source_type.PLAYER)

func kill(a_game_over: bool) -> void:
	print("player killed")
	alive = false
	collision_shape.disabled = true
	anim.play("Destroyed")
	thruster.visible = false
	yield(anim, "animation_finished")
	if a_game_over:
		self.visible = false
	else:
		call_deferred("reset", true)

func reset(a_invincibility: bool) -> void:
	print('player reset')
	self.visible = true
	alive = true
	rotation = -TAU/4
	position = Vector2(screen_width/2, screen_height/2)
	vel = Vector2.ZERO
	collision_shape.disabled = false
	anim.play("Idle")
	if a_invincibility:
		do_invincibility()

func do_invincibility() -> void:
	is_invincible = true
	anim.play("Flashing")
	collision_shape.disabled = true
	invincible_timer.start()
	yield(invincible_timer, "timeout")
	is_invincible = false
	anim.play("Idle")
	collision_shape.disabled = false

func do_hyperspace() -> void:
	is_invincible = false
	is_hyperspace = true
	anim.play("HyperSpace")
	yield(anim, "animation_finished")
	anim.play("Idle")
	var random_point = Vector2(rng.randi_range(0, screen_width), rng.randi_range(0, screen_height))
	position = random_point
	is_hyperspace = false

func toggle_godmode() -> void:
	is_godmode = not is_godmode
	if is_godmode:
		print("God mode cheat is active")
		collision_shape.disabled = true
		ship_sprite.visible = false
		godmode_sprite.visible = true
	else:
		print("God mode cheat is not active")
		collision_shape.disabled = false
		ship_sprite.visible = true
		godmode_sprite.visible = false
		
