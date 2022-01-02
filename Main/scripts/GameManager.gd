extends Node
class_name GameManager

onready var gui = get_node("CanvasLayer/GUI")
onready var score_manager = get_node("ScoreManager")
onready var satellite_spawner = get_node("SatelliteSpawner")
onready var ufo_spawner = get_node("UFOSpawner")
onready var gui_name_entry = get_node("CanvasLayer/GUI/GameOverScreen/NameEntry")
onready var explosion_manager = get_node("ExplosionManager")
onready var audio_stream = get_node("AudioStreamPlayer")

# MUSIC
const menu_music = preload("res://Main/assets/Map.wav")
const play_music = preload("res://Main/assets/Venus.wav")
var music_playback_pos: float

# PLAYER VARS
const player_scene = preload("res://Player/scenes/Player.tscn")
const max_lives: int = 3
const new_life_score: int = 10000
var player: Player
var player_lives: int
var is_player_cheated: bool

# WAVES
const beg_asteroids_per_wave: int = 2
var wave: int
var asteroids_per_wave: int
var asteroid_speed_scale: float

# GAME STATE
enum game_state {START, PLAY, GAME_OVER}
var curr_game_state: int

# DEBUG
const debug_no_sat := false
const debug_no_ufo := false

func _ready():
	get_tree().connect("node_added", self, "on_node_added")
	player = player_scene.instance()
	get_tree().root.call_deferred("add_child", player)
	player.connect("player_hit", self, "on_player_hit")
	player.connect("player_cheated", self, "on_player_cheated")
	satellite_spawner.connect("no_satellites_left", self, "on_no_satellites_left")
	gui_name_entry.connect("name_entered", self, "save_high_score")
	gui.show_fps(false)
	satellite_spawner.spawn_satellite_wave(4)
	set_game_state(game_state.START)
	gui.connect("gui_reset", self, "reset_game")
	gui.start_screen()
	audio_stream.stream = menu_music
	audio_stream.play()

func _process(delta):
	if curr_game_state == game_state.PLAY and Input.is_action_just_pressed("pause"):
		toggle_pause()

func toggle_pause() -> void:
	if get_tree().paused:
		get_tree().paused = false
		gui.show_pause_screen(false)
		audio_stream.play()
		audio_stream.seek(music_playback_pos)
	else:
		get_tree().paused = true
		gui.show_pause_screen(true)
		music_playback_pos = audio_stream.get_playback_position()
		audio_stream.stop()

func _input(event):
	if event.is_action_pressed("reset"):
		reset_game()

func set_game_state(a_state: int) -> void:
	curr_game_state = a_state

func game_over() -> void:
	print('game over')
	var is_new_high_score = not is_player_cheated and score_manager.check_high_score()
	if is_new_high_score:
		print("New high score! Saving")
	gui.game_over_screen(is_new_high_score, score_manager.high_scores)
	audio_stream.stream = menu_music
	audio_stream.play()

func reset_game() -> void:
	set_game_state(game_state.PLAY)
	get_tree().paused = false
#	if not player:
#		player = player_scene.instance()
	satellite_spawner.clear_satellites()
	ufo_spawner.clear_ufo()
	clear_projectiles()
	# wait one frame to let everything queue free
	yield(get_tree(), "idle_frame")
	print('game reset')
	is_player_cheated = false
	player_lives = max_lives
	score_manager.reset()
	player.reset(false)
	gui.start_game(max_lives, score_manager.score, wave)
	if not debug_no_ufo:
		ufo_spawner.start(1)
	wave = 0
	if not debug_no_sat:
		next_wave()
	audio_stream.stream = play_music
	audio_stream.play()

func next_wave() -> void:
	wave += 1
	print('wave = %s' % wave)
	if wave == 1:
		gui.set_wave(1)
		asteroids_per_wave = beg_asteroids_per_wave
		asteroid_speed_scale = 1.0
	else:
		gui.next_wave()
		asteroids_per_wave += 1
		asteroid_speed_scale += 0.075
	print('spawning %s asteroids' % asteroids_per_wave)
	satellite_spawner.clear_satellites()
	satellite_spawner.spawn_satellite_wave(asteroids_per_wave)

func on_no_satellites_left() -> void:
	if ufo_spawner.ufo_active:
		return # wait for player to destroy ufo before spawning next wave
	else:
		next_wave()

func on_node_added(node) -> void:
	if node is Projectile:
		node.connect("projectile_hit", self, "on_projectile_hit")
	elif node is BaseSatellite and not node.is_connected("satellite_collision", self, "on_satellite_collision"):
		node.connect("satellite_collision", self, "on_satellite_collision")
		node.speed *= asteroid_speed_scale
	elif node is UFO:
		node.connect("ufo_destroyed", satellite_spawner, "on_ufo_destroyed")

func on_satellite_collision(sat, coll) -> void:
	#explosion_manager.spawn_explosion(sat.global_position)
	if coll is Player:
		on_player_hit()
	elif coll is UFO:
		ufo_spawner.destroy_ufo()

func on_projectile_hit(proj, node) -> void:
	explosion_manager.spawn_explosion(node.global_position)
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
	var prev_score = score_manager.score
	score_manager.update_score(node)
	# new life every next_life_score points
	var next_life_threshold = score_manager.score - (score_manager.score % new_life_score)
	if prev_score < next_life_threshold:
		print("player earned a new life!")
		player_lives += 1
		gui.increment_lives()
	gui.set_score(score_manager.score)

func on_player_hit() -> void:
	if not player.alive:
		return
	explosion_manager.spawn_explosion(player.global_position)
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
	score_manager.reset()
	gui.set_score(0)
	is_player_cheated = true
	gui.disable_score()

func save_high_score(name_entry: String) -> void:
	score_manager.save_high_score(name_entry)
	gui.show_high_scores(score_manager.high_scores)

func clear_projectiles() -> void:
	var root = get_tree().root
	for i in range(root.get_child_count()):
		var node = root.get_child(i)
		if node is Projectile:
			node.queue_free()
