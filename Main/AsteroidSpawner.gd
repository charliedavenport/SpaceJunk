extends BaseSpawner
class_name Asteroid_Spawner

const asteroid_big = preload("res://Asteroid/Asteroid_Big.tscn")

var asteroid_count: int

signal no_asteroids_left

func _ready() -> void:
	asteroid_count = 0
	get_tree().connect("node_added", self, "on_node_added")

func spawn_asteroid_wave(a_asteroids: int) -> void:
	for i in range(a_asteroids):
		asteroid_spawn()

func asteroid_spawn() -> void:
	# implemented in base spawner class
	var rand_point = pick_random_point()
	var rand_rot = rng.randf_range(0, TAU)
	var asteroid_inst = asteroid_big.instance()
	get_tree().root.call_deferred("add_child", asteroid_inst) # triggers on_node_added()
	asteroid_inst.start(rand_point, rand_rot)

func clear_asteroids() -> void:
	var root = get_tree().root
	for i in range(root.get_child_count()):
		var node = root.get_child(i)
		if node is Asteroid:
			node.queue_free()
	asteroid_count = 0

func on_asteroid_destroyed(node) -> void:
	asteroid_count -= 1
	if asteroid_count == 0:
		print("all asteroids destroyed")
		emit_signal("no_asteroids_left")

func on_node_added(node) -> void:
	if node is Asteroid:
		node.connect("asteroid_destroyed", self, "on_asteroid_destroyed")
		asteroid_count += 1
