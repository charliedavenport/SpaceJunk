extends Node
class_name GameManager

const player_scene = preload("res://Player/Player.tscn")

var player: Player
onready var gui = get_node("CanvasLayer/GUI")
onready var asteroid_spawner = get_node("AsteroidSpawner")
onready var ufo_spawner = get_node("UFOSpawner")
onready var game_over_timer = get_node("GameOverTimer")

# PLAYER VARS
export var max_lives: int = 5
var player_lives: int
var game_over: bool

# SCORING
export var big_asteroid_pts: int = 20
export var medium_asteroid_pts: int = 50
export var small_asteroid_pts: int = 100
export var ufo_large_pts: int = 200
export var ufo_small_pts: int = 1000
var score: int

export var beg_asteroids_per_wave: int = 4
var wave: int
var asteroids_per_wave: int

var is_start_screen: bool
var is_game_over_screen: bool
var is_game_over_timer: bool

func _ready():
	get_tree().connect("node_added", self, "on_node_added")
	is_game_over_timer = false
	is_game_over_screen = false
	start_screen()

func start_screen() -> void:
	is_start_screen = true
	asteroid_spawner.spawn_asteroid_wave(3)
	gui.start_screen()

func game_over() -> void:
	is_game_over_screen = true
	gui.game_over_screen()
	#game_over_timer.start()
	is_game_over_timer = true
	game_over_timer.start()
	yield(game_over_timer, "timeout")
	is_game_over_timer = false
	gui.show_press_any_btn()

func _input(event):
	var reset_game_condition = (is_start_screen or is_game_over_screen) \
								and (event is InputEventKey or event is InputEventMouseButton) \
								and event.pressed and not is_game_over_timer
	if reset_game_condition:
		is_start_screen = false
		is_game_over_screen = false
		reset_game()

func reset_game() -> void:
	game_over = false
	player_lives = max_lives
	score = 0
	wave = 1
	player = player_scene.instance()
	get_tree().root.call_deferred("add_child", player)
	player.connect("player_hit", self, "on_player_hit")
	gui.call_deferred("start_game", max_lives, score, wave)
	ufo_spawner.start(1)
	do_waves()

func do_waves() -> void:
	asteroids_per_wave = beg_asteroids_per_wave
	while true:
		asteroid_spawner.clear_asteroids()
		asteroid_spawner.spawn_asteroid_wave(asteroids_per_wave)
		#ufo_spawner.start(wave)
		yield(asteroid_spawner, "no_asteroids_left")
		if game_over:
			return
		wave += 1
		gui.set_wave(wave)
		asteroids_per_wave += 1

func on_node_added(node) -> void:
	if node is Projectile:
		node.connect("projectile_hit", self, "on_projectile_hit")

func on_projectile_hit(node) -> void:
	if node is Asteroid_Big:
		score += big_asteroid_pts
	elif node is Asteroid_Medium:
		score += medium_asteroid_pts
	elif node is Asteroid_Small:
		score += small_asteroid_pts
	elif node is UFO_Large:
		score += ufo_large_pts
	elif node is Player:
		node.emit_signal("player_hit")
		return
	else:
		print("unknown collision")
		return
	gui.set_score(score)
	node.destroy() 

func on_player_hit() -> void:
	player_lives -= 1
	game_over = (player_lives == 0)
	player.kill(game_over)
	gui.decrement_lives()
	if game_over:
		game_over()

