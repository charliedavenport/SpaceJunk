extends KinematicBody2D
class_name UFO

const projectile = preload("res://Projectile/Projectile.tscn")
const shoot_sound = preload("res://UFO/fail.wav")
const explosion_sound = preload("res://UFO/explodify.wav")

onready var screen_width = get_viewport_rect().size.x
onready var screen_height = get_viewport_rect().size.y
onready var shoot_timer = get_node("ShootTimer")
onready var change_dir_timer = get_node("ChangeDirectionTimer")
onready var rng = RandomNumberGenerator.new()
onready var player = get_tree().root.get_node("Player")
onready var audio_stream = get_node("AudioStreamPlayer")
onready var shard1 = get_node("Shard1")
onready var shard2 = get_node("Shard2")
onready var shard3 = get_node("Shard3")
onready var coll = get_node("CollisionShape2D")

enum ufo_type_enum {LARGE, SMALL}
export (ufo_type_enum) var ufo_type: int
export var shoot_delay: float
export var speed: float

var vel: Vector2
var alive: bool

signal ufo_destroyed

func _ready():
	if ufo_type == ufo_type_enum.LARGE:
		print('large ufo spawned')
	else:
		print('small ufo spawned')
	rng.randomize()

func start(a_point: Vector2, a_target: Vector2) -> void:
	position = a_point
	vel = (a_target - position).normalized()
	self.visible = true
	shard1.visible = false
	shard2.visible = false
	shard3.visible = false
	alive = true
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
	while alive:
		shoot_timer.start()
		yield(shoot_timer, "timeout")
		shoot_at_player()

func shoot_at_player() -> void:
	if not player:
		return
	audio_stream.stream = shoot_sound
	audio_stream.play()
	var dir_to_player = (player.position - position).normalized()
	var projectile_inst = projectile.instance()
	get_tree().root.add_child(projectile_inst)
	# apply a random angle offset, so the ufo isn't perfectly accurate
	var shoot_angle = dir_to_player.angle() + rng.randf_range(-TAU/10, TAU/10)
	projectile_inst.start(global_transform.origin, shoot_angle, projectile_inst.source_type.UFO)

func _physics_process(delta):
	if not alive:
		return
	var collision = move_and_collide(vel * speed * delta)
	if collision:
		if collision.collider is BaseSatellite:
			collision.collider.destroy()
			destroy()
	position.x = wrapf(position.x, 0, screen_width)
	position.y = wrapf(position.y, 0, screen_height)

func destroy() -> void:
	print('ufo destroyed')
	audio_stream.stream = explosion_sound
	audio_stream.play()
	alive = false
	$CollisionShape2D.disabled = true
	shoot_timer.stop()
	emit_signal("ufo_destroyed")
	var shard1_dir = -1 * TAU / 16 
	var shard2_dir = -3 * TAU / 8
	var shard3_dir = TAU / 4
	shard1.start(global_position, shard1_dir, 0.0)
	shard2.start(global_position, shard2_dir, 0.0)
	shard3.start(global_position, shard3_dir, 0.0)
	self.remove_child(shard1)
	self.remove_child(shard2)
	self.remove_child(shard3)
	var root = get_tree().root
	root.add_child(shard1)
	root.add_child(shard2)
	root.add_child(shard3)
	audio_stream.connect("finished", self, "on_audio_finished")
	self.visible = false
	coll.disabled = true

func on_audio_finished() -> void:
	queue_free()


