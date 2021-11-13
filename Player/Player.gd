extends KinematicBody2D
class_name Player

const THRUST: float = 2.0
const STOPPING_THRUST: float = 3.0
const TURNSPEED: float = 4.0
const SLOWDOWN: float = 0.01
const LASER_DIST: float = 500.0

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
onready var laser_line = get_node("LaserLine")
onready var laser_line_cont = get_node("LaserLineContinued")
const projectile = preload("res://Projectile/Projectile.tscn")

signal player_hit
signal player_cheated

func _ready():
	self.visible = false
	rng.randomize()
	is_godmode = false
	thruster.visible = false
	collision_shape.disabled = true
	laser_line.points[0] = Vector2.ZERO
	laser_line.points[1] = Vector2(LASER_DIST, 0.0)

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
		rotate(-1.0 * TURNSPEED * delta)
	elif Input.is_action_pressed("turn_right"):
		rotate(TURNSPEED * delta)
	if is_godmode and Input.is_action_pressed("shoot"):
		shoot()
	# handle thrust
	if Input.is_action_pressed("forward"):
		thruster.visible = true
		var delta_vec = transform.x * delta
		if delta_vec.dot(vel) > 0:
			delta_vec *= THRUST
		else:
			delta_vec *= STOPPING_THRUST
		vel += delta_vec
	else:
		thruster.visible = false
		# gently slow down
		vel *= (1.0 - SLOWDOWN)
	var collision = move_and_collide(vel)
	if collision:
		emit_signal("player_hit")
	# wrap player to other side of screen
	position = wrap_point(position)

func wrap_point(a_point: Vector2) -> Vector2:
	return Vector2(wrapf(a_point.x, 0, screen_width), wrapf(a_point.y, 0, screen_height))

func _process(delta):
	handle_laser_cont()

func _input(event):
	if event.is_action_pressed("shoot") and alive:
		shoot()
	if event.is_action_pressed("kill") and alive:
		emit_signal("player_hit")

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
	if is_godmode:
		toggle_godmode()
	self.visible = true
	alive = true
	is_hyperspace = false
	rotation = -TAU/4
	position = Vector2(screen_width/2, screen_height/2)
	vel = Vector2.ZERO
	anim.play("Idle")
	if a_invincibility:
		do_invincibility()
	else:
		do_i_frame()

func do_i_frame() -> void:
	is_invincible = true
	collision_shape.disabled = true
	yield(get_tree(), "idle_frame")
	is_invincible = false
	collision_shape.disabled = false

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
		emit_signal("player_cheated")
		print("God mode cheat is active")
		collision_shape.disabled = true
		ship_sprite.visible = false
		godmode_sprite.visible = true
	else:
		print("God mode cheat is not active")
		collision_shape.disabled = false
		ship_sprite.visible = true
		godmode_sprite.visible = false

func handle_laser_cont() -> void:
	laser_line_cont.clear_points()
	var laser_end = to_global(laser_line.points[1])
	if laser_end.x <= screen_width and laser_end.y <= screen_height and laser_end.x >= 0 and laser_end.y >= 0:
		return
	var wrap_laser_end = wrap_point(laser_end)
	var laser_cont_start := Vector2.ZERO
	# TODO: handle corners
	if laser_end.x < 0:
		laser_cont_start = self.global_position + Vector2(screen_width, 0)
	elif laser_end.x > screen_width:
		laser_cont_start = self.global_position - Vector2(screen_width, 0)
	elif laser_end.y < 0:
		laser_cont_start = self.global_position + Vector2(0, screen_height)
	elif laser_end.y > screen_height:
		laser_cont_start = self.global_position - Vector2(0, screen_height)
	laser_line_cont.add_point(to_local(laser_cont_start))
	laser_line_cont.add_point(to_local(wrap_laser_end))
