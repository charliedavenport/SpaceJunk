extends Control

onready var score_label = get_node("ScoreLabel")
onready var lives_container = get_node("LivesContainer")

var lives: int
var score: int

func start(a_lives: int, a_score: int) -> void:
	set_score(a_score)
	lives = a_lives

func set_score(a_score: int) -> void:
	score = a_score
	score_label.text = '%s' % score

func decrement_lives() -> void:
	lives_container.get_child(lives_container.get_child_count() - lives).visible = false
	lives -= 1
	
