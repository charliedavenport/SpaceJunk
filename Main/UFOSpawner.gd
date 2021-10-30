extends BaseSpawner
class_name UFOSpawner

const ufo_large = preload("res://UFO/UFO_Large.tscn")

onready var ufo_timer = get_node("UFOSpawnTimer")

var ufo_active: bool
var ufo_inst

func start(wave: int) -> void:
	ufo_active = false
	ufo_timer.wait_time = 5.0
	ufo_timer.start()
	yield(ufo_timer, "timeout")
	spawn_ufo()

func spawn_ufo() -> void:
	if ufo_active:
		print('not spawning ufo because one already exists')
		return
	ufo_active = true
	var rand_point = pick_random_point()
	ufo_inst = ufo_large.instance()
	ufo_inst.connect("ufo_destroyed", self, 'on_ufo_destroyed')
	get_tree().root.add_child(ufo_inst)
	var rand_target = Vector2(rng.randi_range(screen_width/3, 2*screen_width/3),\
							rng.randi_range(screen_height/3, 2*screen_height/3))
	ufo_inst.start(rand_point, rand_target)

func destroy_ufo() -> void:
	if ufo_active:
		ufo_inst.destroy()

func on_ufo_destroyed() -> void:
	ufo_active = false
	ufo_timer.start()
	yield(ufo_timer, "timeout")
	spawn_ufo()
