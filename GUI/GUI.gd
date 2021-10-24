extends Control

var lives: int
var score: int

func start(a_lives: int, a_score: int) -> void:
	set_score(a_score)
	lives = a_lives

func set_score(a_score: int) -> void:
	score = a_score

func decrement_lives() -> void:
	$LivesContainer.get_child($LivesContainer.get_child_count() - lives).visible = false
	lives -= 1
	
