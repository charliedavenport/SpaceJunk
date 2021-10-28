extends KinematicBody2D
class_name UFO_Large

const projectile = preload("res://Projectile/Projectile.tscn")

onready var screen_width = get_viewport_rect().size.x
onready var screen_height = get_viewport_rect().size.y
onready var shoot_timer = get_node("ShootTimer")

var target_point: Vector2
var speed: float = 100.0
var vel: Vector2

signal ufo_destroyed

func start(a_point: Vector2, a_target: Vector2) -> void:
	position = a_point
	target_point = a_target
	vel = (target_point - position).normalized()
	start_shooting()

func start_shooting() -> void:
	shoot_timer.start()
	yield(shoot_timer, "timeout")
	while true:
		shoot_timer.start()
		yield(shoot_timer, "timeout")
		shoot_at_player()

func shoot_at_player() -> void:
	print("UFO shooting at player")
	var player = get_tree().root.get_node("Player")
	if not player:
		return
	var dir_to_player = (player.position - position).normalized()
	var projectile_inst = projectile.instance()
	get_tree().root.add_child(projectile_inst)
	projectile_inst.start(global_transform.origin, dir_to_player.angle(), projectile_inst.source_type.UFO)
	

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
	print('destroying ufo')
	emit_signal("ufo_destroyed")
	queue_free()


