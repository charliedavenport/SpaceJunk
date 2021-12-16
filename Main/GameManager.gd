extends Node
class_name GameManager

onready var gui = get_node("CanvasLayer/GUI")
onready var satellite_spawner = get_node("SatelliteSpawner")
onready var ufo_spawner = get_node("UFOSpawner")
onready var gui_name_entry = get_node("CanvasLayer/GUI/GameOverScreen/NameEntry")

# PLAYER VARS
const player_scene = preload("res://Player/Player.tscn")
const max_lives: int = 3
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
const beg_asteroids_per_wave: int = 2
var wave: int
var asteroids_per_wave: int
var asteroid_speed_scale: float

# GAME STATE
enum game_state {START, PLAY, GAME_OVER}
var curr_game_state: int

func _ready():
	get_tree().connect("node_added", self, "on_node_added")
	player = player_scene.instance()
	get_tree().root.call_deferred("add_child", player)
	player.connect("player_hit", self, "on_player_hit")
	player.connect("player_cheated", self, "on_player_cheated")
	satellite_spawner.connect("no_satellites_left", self, "next_wave")
	gui.connect("gui_reset", self, "reset_game")
	gui_name_entry.connect("name_entered", self, "save_high_score")
	high_scores = get_high_scores()
	gui.show_fps(true)
	satellite_spawner.spawn_satellite_wave(4)
	set_game_state(game_state.START)
	gui.start_screen()

func _process(delta):
	if curr_game_state == game_state.PLAY and Input.is_action_just_pressed("pause"):
		if get_tree().paused:
			get_tree().paused = false
			gui.show_pause_screen(false)
		else:
			get_tree().paused = true
			gui.show_pause_screen(true)

func _input(event):
	if event.is_action_pressed("reset"):
		reset_game()

func set_game_state(a_state: int) -> void:
	curr_game_state = a_state

func game_over() -> void:
	print('game over')
	var is_new_high_score := not is_player_cheated and check_high_score()
	if is_new_high_score:
		print("New high score! Saving")
	gui.game_over_screen(is_new_high_score, high_scores)

func reset_game() -> void:
	set_game_state(game_state.PLAY)
	satellite_spawner.clear_satellites()
	ufo_spawner.clear_ufo()
	# wait one frame to let everything queue free
	yield(get_tree(), "idle_frame")
	print('game reset')
	is_player_cheated = false
	player_lives = max_lives
	score = 0
	player.reset(false)
	gui.start_game(max_lives, score, wave)
	ufo_spawner.start(1)
	wave = 0
	next_wave()

func next_wave() -> void:
	wave += 1
	print('wave = %s' % wave)
	gui.set_wave(wave)
	if wave == 1:
		asteroids_per_wave = beg_asteroids_per_wave
		asteroid_speed_scale = 1.0
	else:
		asteroids_per_wave += 1
		asteroid_speed_scale += 0.05
	print('spawning %s asteroids' % asteroids_per_wave)
	satellite_spawner.clear_satellites()
	satellite_spawner.spawn_satellite_wave(asteroids_per_wave)

func on_node_added(node) -> void:
	if node is Projectile:
		node.connect("projectile_hit", self, "on_projectile_hit")
	elif node is BaseSatellite and not node.is_connected("satellite_collision", self, "on_satellite_collision"):
		node.connect("satellite_collision", self, "on_satellite_collision")
		node.speed *= asteroid_speed_scale

func on_satellite_collision(sat, coll) -> void:
	if coll is Player:
		on_player_hit()
	elif coll is UFO:
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
	if node is Satellite:
		score += big_asteroid_pts
	elif node is SatelliteComponent:
		score += medium_asteroid_pts
	elif node is SatelliteShard:
		score += small_asteroid_pts
	elif node is UFO:
		if node.ufo_type == UFO.ufo_type_enum.LARGE:
			score += ufo_large_pts
		else:
			score += ufo_small_pts
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
	gui.decrement_lives()
	print('lives = %s' % player_lives )
	if player_lives == 0:
		set_game_state(game_state.GAME_OVER)
		player.kill(true)
		game_over()
	else:
		player.kill(false)

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
		high_scores_file.seek(0)
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

func save_high_score(name_entry: String) -> void:
	var score_entry = {"name": name_entry, "score":score}
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
	gui.show_high_scores(high_scores)
	high_scores_file.open(high_scores_filepath, File.WRITE)
	high_scores_file.seek(0)
	high_scores_file.store_line(JSON.print(high_scores))
	high_scores_file.close()
