extends Node2D
class_name BaseSpawner

onready var screen_width = get_viewport_rect().size.x
onready var screen_height = get_viewport_rect().size.y
onready var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func pick_random_point() -> Vector2:
	# pick a random location on the edge of the screen
	# "unwrap" the screen into a single line, pick a random point on that line
	var unwrapped_range = (2 * screen_height) + (2 * screen_width)
	var rand_num = rng.randi_range(0, unwrapped_range)
	# "wrap" values around the screen rect
	var rand_point: Vector2
	# LEFT SIDE
	if rand_num < screen_height:
		rand_point = Vector2(0, rand_num)
	# RIGHT SIDE
	elif rand_num < 2 * screen_height:
		var line_offset = screen_height
		rand_point = Vector2(screen_width, rand_num - line_offset)
	# TOP SIDE
	elif rand_num < (2 * screen_height) + screen_width:
		var line_offset = 2 * screen_height
		rand_point = Vector2(rand_num - line_offset, 0)
	# BOTTOM SIDE
	else:
		var line_offset = (2 * screen_height) + screen_width
		rand_point = Vector2(rand_num - line_offset, screen_height)
	return rand_point
