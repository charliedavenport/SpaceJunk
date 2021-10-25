extends Control
class_name GUI

onready var score_label = get_node("ScoreLabel")
onready var lives_container = get_node("LivesContainer")
onready var wave_label = get_node("WaveLabel")

var lives: int
var score: int
var wave: int

func start(a_lives: int, a_score: int, a_wave: int) -> void:
	set_score(a_score)
	lives = a_lives
	reset_lives()
	set_wave(a_wave)

func set_score(a_score: int) -> void:
	score = a_score
	score_label.text = '%s' % score

func decrement_lives() -> void:
	lives_container.get_child(lives_container.get_child_count() - lives).visible = false
	lives -= 1

func reset_lives() -> void:
	for i in range(lives_container.get_child_count()):
		lives_container.get_child(i).visible = true

func set_wave(a_wave) -> void:
	wave = a_wave
	wave_label.text = 'wave %s' % wave
	
