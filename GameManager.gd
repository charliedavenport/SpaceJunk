class_name GameManager
extends Node

const asteroid_big = preload("res://Asteroid/Asteroid_Big.tscn")
const Asteroid = preload("res://Asteroid/Asteroid.gd")
const Projectile = preload("res://Projectile/Projectile.gd")
const Player = preload("res://Player/Player.tscn")

onready var player = get_node("Player")
onready var gui = get_node("GUI")
onready var asteroid_spawner = get_node("AsteroidSpawner")
onready var rng = RandomNumberGenerator.new()

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

var wave: int

func _ready():
	get_tree().connect("node_added", self, "on_node_added")
	reset_game()

func reset_game() -> void:
	game_over = false
	player_lives = max_lives
	score = 0
	wave = 0
	rng.randomize()
	if not player:
		player = Player.instance()
		get_tree().root.add_child(player)
	player.connect("player_hit", self, "on_player_hit")
	gui.call_deferred("start", max_lives, score, wave)
	#gui.start(max_lives, score)
	asteroid_spawner.spawn_asteroid_wave(4)

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
