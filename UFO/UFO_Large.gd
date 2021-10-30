extends KinematicBody2D
class_name UFO_Large

const projectile = preload("res://Projectile/Projectile.tscn")

onready var screen_width = get_viewport_rect().size.x
onready var screen_height = get_viewport_rect().size.y
onready var shoot_timer = get_node("ShootTimer")
onready var change_dir_timer = get_node("ChangeDirectionTimer")
onready var rng = RandomNumberGenerator.new()
onready var player = get_tree().root.get_node("Player")

var speed: float = 100.0
var vel: Vector2

signal ufo_destroyed

func _ready():
	rng.randomize()

func start(a_point: Vector2, a_target: Vector2) -> void:
	position = a_point
	vel = (a_target - position).normalized()
	start_shooting()
	start_changing_direction()

func start_changing_direction() -> void:
	while true:
		change_dir_timer.start()
		yield(change_dir_timer, "timeout")
		change_direction()

func change_direction() -> void:
	var rand_rot = rng.randf_range(0, TAU)
	vel = vel.rotated(rand_rot)

func start_shooting() -> void:
	shoot_timer.start()
	yield(shoot_timer, "timeout")
	while true:
		shoot_timer.start()
		yield(shoot_timer, "timeout")
		shoot_at_player()

func shoot_at_player() -> void:
	if not player:
		return
	var dir_to_player = (player.position - position).normalized()
	var projectile_inst = projectile.instance()
	get_tree().root.add_child(projectile_inst)
	# apply a random angle offset, so the ufo isn't perfectly accurate
	var shoot_angle = dir_to_player.angle() + rng.randf_range(-TAU/10, TAU/10)
	projectile_inst.start(global_transform.origin, shoot_angle, projectile_inst.source_type.UFO)
	

func _physics_process(delta):
	var collision = move_and_collide(vel * speed * delta)
	if collision:
		if collision.collider is Asteroid:
			print('ufo hit asteroid')
			collision.collider.destroy()
			destroy()
	position.x = wrapf(position.x, 0, screen_width)
	position.y = wrapf(position.y, 0, screen_height)

func destroy() -> void:
	emit_signal("ufo_destroyed")
	queue_free()


