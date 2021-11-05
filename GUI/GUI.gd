extends Control
class_name GUI

onready var score_label = get_node("ScoreLabel")
onready var lives_container = get_node("LivesContainer")
onready var wave_label = get_node("WaveLabel")
onready var start_label = get_node("StartLabel")
onready var game_over_ctrl = get_node("GameOverScreen")
onready var press_any_btn_label = get_node("GameOverScreen/PressAnyBtnLabel")
onready var game_over_score = get_node("GameOverScreen/GameOverScoreLabel")
onready var fps_label = get_node("FPSLabel")

const life_rect = preload("res://GUI/LifeRect.tscn")
const high_score_row = preload("res://GUI/HighScoreRow.tscn")

var lives: int
var max_lives: int
var score: int
var wave: int
var is_score_disabled: bool
var is_show_fps: bool

func start_game(a_lives: int, a_score: int, a_wave: int) -> void:
	lives_container.visible = true
	score_label.visible = true
	wave_label.visible = true
	start_label.visible = false
	game_over_ctrl.visible = false
	is_score_disabled = false
	set_score(a_score)
	max_lives = a_lives
	lives = max_lives
	reset_lives()
	set_wave(a_wave)
	score_label.add_color_override("font_color", Color.white)

func _process(delta) -> void:
	if is_show_fps:
		var fps = Engine.get_frames_per_second()
		fps_label.text = 'fps = %s' % fps

func start_screen() -> void:
	lives_container.visible = false
	score_label.visible = false
	wave_label.visible = false
	start_label.visible = true
	game_over_ctrl.visible = false

func game_over_screen() -> void:
	lives_container.visible = false
	score_label.visible = false
	wave_label.visible = false
	game_over_score.text = str(score)
	game_over_ctrl.visible = true
	press_any_btn_label.visible = false

func show_press_any_btn() -> void:
	press_any_btn_label.visible = true

func set_score(a_score: int) -> void:
	if is_score_disabled:
		return
	score = a_score
	score_label.text = '%s' % score

func increment_lives() -> void:
	lives += 1
	if lives <= max_lives:
		lives_container.get_child(lives_container.get_child_count() - lives).visible = true
	else:
		lives_container.add_child(life_rect.instance())

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
		hs_row.get_node("Name").text = high_scores[i]["name"]
		hs_row.get_node("Score").text = str(high_scores[i]["score"])
		$GameOverScreen/HighScores/VBoxContainer.add_child(hs_row)
