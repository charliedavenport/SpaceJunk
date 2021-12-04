extends BaseSpawner
class_name Satellite_Spawner

const satellite = preload("res://Satellite/Satellite.tscn")

var satellite_count: int

signal no_satellites_left

func _ready() -> void:
	satellite_count = 0
	get_tree().connect("node_added", self, "on_node_added")

func spawn_satellite_wave(a_satellites: int) -> void:
	for i in range(a_satellites):
		satellite_spawn()

func satellite_spawn() -> void:
	# implemented in base spawner class
	var rand_point = pick_random_point()
	var rand_rot = rng.randf_range(0, TAU)
	var satellite_inst = satellite.instance()
	get_tree().root.call_deferred("add_child", satellite_inst) # triggers on_node_added()
	satellite_inst.start(rand_point, rand_rot)
	satellite_count += 4

func clear_satellites() -> void:
	var root = get_tree().root
	for i in range(root.get_child_count()):
		var node = root.get_child(i)
		if node is BaseSatellite:
			node.queue_free()
	satellite_count = 0

func on_satellite_destroyed() -> void:
	satellite_count -= 1
	if satellite_count == 0:
		print("all satellites destroyed")
		emit_signal("no_satellites_left")

func on_node_added(node) -> void:
	if node is BaseSatellite and not node.is_connected("satellite_destroyed", self, "on_satellite_destroyed"):
		var rtn = node.connect("satellite_destroyed", self, "on_satellite_destroyed")
