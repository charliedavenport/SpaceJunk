extends Node2D

const asteroid_big = preload("res://Asteroid/Asteroid_Big.tscn")

onready var screen_width = get_viewport_rect().size.x
onready var screen_height = get_viewport_rect().size.y
onready var rng = RandomNumberGenerator.new()



func _ready() -> void:
	rng.randomize()

func spawn_asteroid_wave(a_asteroids: int) -> void:
	for i in range(a_asteroids):
		asteroid_spawn()

func asteroid_spawn() -> void:
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
	var rand_rot = rng.randf_range(0, TAU)
	var asteroid_inst = asteroid_big.instance()
	#get_tree().root.add_child(asteroid_inst)
	get_tree().root.call_deferred("add_child", asteroid_inst)
	asteroid_inst.start(rand_point, rand_rot)
