extends Control
class_name GUI

onready var score_label = get_node("ScoreLabel")
onready var lives_container = get_node("LivesContainer")
onready var wave_label = get_node("WaveContainer/WaveLabel")
onready var wave_container = get_node("WaveContainer")
onready var start_label = get_node("StartLabel")
onready var game_over_ctrl = get_node("GameOverScreen")
onready var press_any_btn_label = get_node("GameOverScreen/PressAnyBtnLabel")
onready var game_over_score = get_node("GameOverScreen/GameOverScoreLabel")
onready var name_entry = get_node("GameOverScreen/NameEntry")
onready var game_over_timer = get_node("GameOverTimer")
onready var fps_label = get_node("FPSLabel")
onready var pause_screen = get_node("PauseScreen")
onready var audio_stream = get_node("AudioStreamPlayer")

const life_rect = preload("res://GUI/scenes/LifeRect.tscn")
const high_score_row = preload("res://GUI/scenes/HighScoreRow.tscn")
const next_wave_sound = preload("res://GUI/assets/sfx_coin_cluster4.wav")
const new_life_sound = preload("res://GUI/assets/sfx_sounds_powerup2.wav")

enum screen_mode {START, PLAY, PAUSE, GAME_OVER}
var curr_screen_mode: int

var lives: int
var max_lives: int
var score: int
var wave: int
var is_score_disabled: bool
var is_show_fps: bool
var is_wait_for_input: bool

signal gui_reset

func _ready():
	is_wait_for_input = false
	name_entry.connect("name_entered", self, "on_name_entered")

func start_game(a_lives: int, a_score: int, a_wave: int) -> void:
	set_screen_mode(screen_mode.PLAY)
	is_wait_for_input = false
	is_score_disabled = false
	set_score(a_score)
	max_lives = a_lives
	lives = max_lives
	reset_lives()
	set_wave(a_wave)
	score_label.add_color_override("font_color", Color.white)

func hide_all() -> void:
	for i in range(get_child_count()):
		var child = get_child(i)
		if child is CanvasItem:
			child.visible = false

func set_screen_mode(a_mode: int) -> void:
	curr_screen_mode = a_mode
	hide_all()
	if a_mode == screen_mode.START:
		start_label.visible = true
	elif a_mode == screen_mode.PLAY:
		lives_container.visible = true
		score_label.visible = true
		wave_container.visible = true
	elif a_mode == screen_mode.PAUSE:
		pause_screen.visible = true
	elif a_mode == screen_mode.GAME_OVER:
		game_over_ctrl.visible = true
		name_entry.visible = false
		press_any_btn_label.visible = false
	else:
		print('GUI error: invalid screen mode: %s' % a_mode)
	show_fps(is_show_fps)

func _process(delta) -> void:
	if is_show_fps:
		var fps = Engine.get_frames_per_second()
		fps_label.text = 'fps = %s' % fps

func start_screen() -> void:
	set_screen_mode(screen_mode.START)
	is_wait_for_input = true

func game_over_screen(is_new_high_score: bool, high_scores: Array) -> void:
	game_over_score.text = str(score)
	set_screen_mode(screen_mode.GAME_OVER)
	show_high_scores(high_scores)
	if is_new_high_score:
		name_entry.do_name_entry()
	else:
		game_over_timer.start()
		yield(game_over_timer, "timeout")
		press_any_btn_label.visible = true
		is_wait_for_input = true

func on_name_entered(name_entry: String) -> void:
	game_over_timer.start()
	yield(game_over_timer, "timeout")
	press_any_btn_label.visible = true
	is_wait_for_input = true

func _input(event) -> void:
	if not is_wait_for_input:
		return
	if (event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton) and event.pressed:
		emit_signal("gui_reset")
		is_wait_for_input = false

func set_score(a_score: int) -> void:
	if is_score_disabled:
		return
	score = a_score
	score_label.text = '%s' % score

func increment_lives() -> void:
	audio_stream.stream = new_life_sound
	audio_stream.play()
	lives += 1
	if lives <= max_lives:
		lives_container.get_child(lives_container.get_child_count() - lives).visible = true
	else:
		var new_life = life_rect.instance()
		new_life.do_flashing(6) 
		lives_container.add_child(new_life)

func decrement_lives() -> void:
	if lives > 0:
		lives_container.get_child(lives_container.get_child_count() - lives).visible = false
		lives -= 1

func reset_lives() -> void:
	for i in range(lives_container.get_child_count()):
		lives_container.get_child(i).queue_free()
	for i in range(max_lives):
		lives_container.add_child(life_rect.instance())

func set_wave(a_wave) -> void:
	wave = a_wave
	wave_label.text = 'wave %s' % wave

func next_wave() -> void:
	set_wave(wave + 1)
	var wave_anim = wave_label.get_node("AnimationPlayer")
	wave_anim.play("new wave")
	audio_stream.stream = next_wave_sound
	audio_stream.play()

func disable_score() -> void:
	is_score_disabled = true
	score_label.add_color_override("font_color", Color.red)

func show_fps(a_show_fps: bool) -> void:
	is_show_fps = a_show_fps
	fps_label.visible = is_show_fps

func show_high_scores(high_scores: Array) -> void:
	for i in range($GameOverScreen/HighScores/VBoxContainer.get_child_count()):
		$GameOverScreen/HighScores/VBoxContainer.get_child(i).queue_free()
	for i in range(len(high_scores)):
		var hs_row = high_score_row.instance()
		hs_row.get_node("Name").text = high_scores[i]["name"].to_upper()
		hs_row.get_node("Score").text = str(high_scores[i]["score"])
		$GameOverScreen/HighScores/VBoxContainer.add_child(hs_row)

func show_pause_screen(a_show: bool) -> void:
	if a_show:
		set_screen_mode(screen_mode.PAUSE)
	else:
		set_screen_mode(screen_mode.PLAY)
	
