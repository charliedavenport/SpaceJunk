extends Node
class_name GameManager

onready var gui = get_node("CanvasLayer/GUI")
onready var asteroid_spawner = get_node("AsteroidSpawner")
onready var ufo_spawner = get_node("UFOSpawner")
onready var game_over_timer = get_node("GameOverTimer")

# PLAYER VARS
const player_scene = preload("res://Player/Player.tscn")
const max_lives: int = 2
const new_life_score: int = 10000
var player: Player
var player_lives: int
var is_player_cheated: bool

# SCORING
const big_asteroid_pts: int = 20
const medium_asteroid_pts: int = 50
const small_asteroid_pts: int = 100
const ufo_large_pts: int = 200
const ufo_small_pts: int = 1000
var score: int
const max_high_scores := 10
const high_scores_filepath = "res://high_scores.json"
var high_scores_file: File
var high_scores

# WAVES
const beg_asteroids_per_wave: int = 4
var wave: int
var asteroids_per_wave: int
var asteroid_speed_scale: float

# GAME STATE
var is_game_over: bool
var is_start_screen: bool
var is_game_over_screen: bool
var is_game_over_timer: bool

func _ready():
	get_tree().connect("node_added", self, "on_node_added")
	player = player_scene.instance()
	get_tree().root.call_deferred("add_child", player)
	player.connect("player_hit", self, "on_player_hit")
	player.connect("player_cheated", self, "on_player_cheated")
	is_game_over_timer = false
	is_game_over_screen = false
	high_scores = get_high_scores()
	gui.show_fps(true)
	start_screen()

func start_screen() -> void:
	is_start_screen = true
	asteroid_spawner.spawn_asteroid_wave(3)
	gui.start_screen()

func game_over() -> void:
	print('game over')
	is_game_over_screen = true
	gui.game_over_screen()
	if not is_player_cheated and check_high_score():
		print("New high score! Saving")
		save_high_score()
	gui.show_high_scores(high_scores)
	is_game_over_timer = true
	game_over_timer.start()
	yield(game_over_timer, "timeout")
	is_game_over_timer = false
	gui.show_press_any_btn()
	sort_high_scores()
	

func _input(event):
	var reset_game_condition = (is_start_screen or is_game_over_screen) \
								and (event is InputEventKey or event is InputEventMouseButton) \
								and event.pressed and not is_game_over_timer
	if reset_game_condition:
		is_start_screen = false
		is_game_over_screen = false
		reset_game()

func reset_game() -> void:
	asteroid_spawner.clear_asteroids()
	ufo_spawner.clear_ufo()
	# wait one frame to let everything queue free
	yield(get_tree(), "idle_frame")
	print('game reset')
	is_game_over = false
	is_player_cheated = false
	player_lives = max_lives
	score = 0
	wave = 1
	player.reset(false)
	gui.call_deferred("start_game", max_lives, score, wave)
	ufo_spawner.start(1)
	do_waves()

func do_waves() -> void:
	asteroids_per_wave = beg_asteroids_per_wave
	asteroid_speed_scale = 1.0
	while true:
		print('spawning %s asteroids' % asteroids_per_wave)
		asteroid_spawner.clear_asteroids()
		asteroid_spawner.spawn_asteroid_wave(asteroids_per_wave)
		#ufo_spawner.start(wave)
		yield(asteroid_spawner, "no_asteroids_left")
		if is_game_over:
			return
		wave += 1
		print('wave = %s' % wave)
		gui.set_wave(wave)
		asteroids_per_wave += 1
		asteroid_speed_scale += 0.1
		yield(get_tree(), "idle_frame")

func on_node_added(node) -> void:
	if node is Projectile:
		node.connect("projectile_hit", self, "on_projectile_hit")
	elif node is Asteroid:
		node.connect("asteroid_collision", self, "on_asteroid_collision")
		node.speed *= asteroid_speed_scale

func on_asteroid_collision(ast, coll) -> void:
	if coll is Player:
		on_player_hit()
	elif coll is UFO_Large:
		ufo_spawner.destroy_ufo()

func on_projectile_hit(proj, node) -> void:
	if proj.source == Projectile.source_type.PLAYER:
		update_player_score(node)
	elif node is Player:
		node.emit_signal("player_hit")
		return
	if node.has_method("destroy"):
		node.destroy() 

func update_player_score(node: Node) -> void:
	if is_player_cheated:
		return
	var prev_score = score
	if node is Asteroid_Big:
		score += big_asteroid_pts
	elif node is Asteroid_Medium:
		score += medium_asteroid_pts
	elif node is Asteroid_Small:
		score += small_asteroid_pts
	elif node is UFO_Large:
		score += ufo_large_pts
	# new life every next_life_score points
	var next_life_threshold = score - (score % new_life_score)
	if prev_score < next_life_threshold:
		print("player earned a new life!")
		player_lives += 1
		gui.increment_lives()
	gui.set_score(score)

func on_player_hit() -> void:
	if not player.alive:
		return
	player_lives -= 1
	is_game_over = (player_lives == 0)
	player.kill(is_game_over)
	gui.decrement_lives()
	print('lives = %s' % player_lives )
	if is_game_over:
		game_over()

func on_player_cheated() -> void:
	if is_player_cheated:
		return
	print("player used a cheat code, so scoring is disabled")
	score = 0
	gui.set_score(0)
	is_player_cheated = true
	gui.disable_score()

func get_high_scores() -> Array:
	high_scores_file = File.new()
	if not high_scores_file.file_exists(high_scores_filepath):
		print('high scores file not found, creating new file')
		high_scores_file.open(high_scores_filepath, File.WRITE)
		high_scores_file.store_line("[]")
		high_scores_file.close()
		return []
	high_scores_file.open(high_scores_filepath, File.READ)
	var scores = parse_json(high_scores_file.get_as_text())
	#print('high scores = %s' % str(scores))
	high_scores_file.close()
	return scores

func check_high_score() -> bool:
	if len(high_scores) < max_high_scores:
		return true
	# return true if any of the saved high scores are lower than score
	for i in range(len(high_scores)):
		var saved_score = high_scores[i]["score"]
		if score > saved_score:
			return true
	return false

static func compare_scores(a,b) -> bool:
	return a["score"] > b["score"]

func sort_high_scores() -> void:
	high_scores.sort_custom(self, "compare_scores")

func save_high_score() -> void:
	var score_entry = {"name":"aaa", "score":score}
	if len(high_scores) < max_high_scores:
		high_scores.append(score_entry)
		sort_high_scores()
	else:
		sort_high_scores()
		high_scores.pop_back()
		var is_inserted := false
		for i in range(len(high_scores)):
			if high_scores[i]["score"] < score:
				high_scores.insert(i, score_entry)
				is_inserted = true
				break
		if not is_inserted:
			high_scores.push_back(score_entry)
	high_scores_file.open(high_scores_filepath, File.WRITE)
	high_scores_file.seek(0)
	high_scores_file.store_line(JSON.print(high_scores))
	high_scores_file.close()
