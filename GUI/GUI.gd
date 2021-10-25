extends Control
class_name GUI

onready var score_label = get_node("ScoreLabel")
onready var lives_container = get_node("LivesContainer")
onready var wave_label = get_node("WaveLabel")
onready var start_label = get_node("StartLabel")
onready var game_over_label = get_node("GameOverLabel")

var lives: int
var score: int
var wave: int

func start_game(a_lives: int, a_score: int, a_wave: int) -> void:
	lives_container.visible = true
	score_label.visible = true
	wave_label.visible = true
	start_label.visible = false
	game_over_label.visible = false
	set_score(a_score)
	lives = a_lives
	reset_lives()
	set_wave(a_wave)

func start_screen() -> void:
	lives_container.visible = false
	score_label.visible = false
	wave_label.visible = false
	start_label.visible = true

func game_over_screen() -> void:
	lives_container.visible = false
	score_label.visible = false
	wave_label.visible = false
	game_over_label.visible = true

func set_score(a_score: int) -> void:
	score = a_score
	score_label.text = '%s' % score

func decrement_lives() -> void:
	if lives > 0:
		lives_container.get_child(lives_container.get_child_count() - lives).visible = false
		lives -= 1

func reset_lives() -> void:
	for i in range(lives_container.get_child_count()):
		lives_container.get_child(i).visible = true

func set_wave(a_wave) -> void:
	wave = a_wave
	wave_label.text = 'wave %s' % wave
	
