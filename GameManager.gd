class_name GameManager
extends Node2D

const asteroid_big = preload("res://Asteroid/Asteroid_Big.tscn")
const Asteroid = preload("res://Asteroid/Asteroid.gd")
const Projectile = preload("res://Projectile/Projectile.gd")
const Player = preload("res://Player/Player.tscn")

onready var player = get_parent().get_node("Player")
onready var gui = get_parent().get_node("GUI")
onready var rng = RandomNumberGenerator.new()
onready var screen_width = get_viewport_rect().size.x
onready var screen_height = get_viewport_rect().size.y

export var initial_asteroids: int = 5

# PLAYER VARS
export var max_lives: int = 5
var player_lives: int
var game_over: bool

# SCORING
export var big_asteroid_pts: int = 20
export var medium_asteroid_pts: int = 50
export var small_asteroid_pts: int = 100
export var big_saucer_pts: int = 200
export var small_saucer_pts: int = 1000
var score: int

func _ready():
	get_tree().connect("node_added", self, "on_node_added")
	reset_game()

func reset_game() -> void:
	game_over = false
	player_lives = max_lives
	score = 0
	rng.randomize()
	if not player:
		player = Player.instance()
		get_tree().root.add_child(player)
	player.connect("player_hit", self, "on_player_hit")
	gui.call_deferred("start", max_lives, score)
	#gui.start(max_lives, score)
	init_asteroid_spawn()

func _process(delta):
	pass

func init_asteroid_spawn() -> void:
	for i in range(initial_asteroids):
		asteroid_spawn()

func asteroid_spawn() -> void:
	# pick a random location on the edge of the screen
	# "unwrap" the screen into a single line, pick a random point on that line
	var unwrapped_range = (2 * screen_height) + (2 * screen_width)
	var rand_num = rng.randi_range(0, unwrapped_range)
	# "wrap" values around the screen rect
	var rand_point: Vector2
	# LEFT SIDE
	if rand_num < screen_height:
		rand_point = Vector2(0, rand_num)
	# RIGHT SIDE
	elif rand_num < 2 * screen_height:
		var line_offset = screen_height
		rand_point = Vector2(screen_width, rand_num - line_offset)
	# TOP SIDE
	elif rand_num < (2 * screen_height) + screen_width:
		var line_offset = 2 * screen_height
		rand_point = Vector2(rand_num - line_offset, 0)
	# BOTTOM SIDE
	else:
		var line_offset = (2 * screen_height) + screen_width
		rand_point = Vector2(rand_num - line_offset, screen_height)
	var rand_rot = rng.randf_range(0, TAU)
	var asteroid_inst = asteroid_big.instance()
	#get_tree().root.add_child(asteroid_inst)
	get_tree().root.call_deferred("add_child", asteroid_inst)
	asteroid_inst.start(rand_point, rand_rot)

func on_node_added(node) -> void:
	if node is Projectile:
		node.connect("projectile_hit", self, "on_projectile_hit")

func on_projectile_hit(node) -> void:
	if node is Asteroid:
		if node is Asteroid_Big:
			score += big_asteroid_pts
			gui.set_score(score)
		elif node is Asteroid_Small:
			score += small_asteroid_pts
			gui.set_score(score)
		node.destroy()

func on_player_hit() -> void:
	player_lives -= 1
	game_over = (player_lives == 0)
	player.kill(game_over)
	gui.decrement_lives()

func on_game_over() -> void:
	pass
