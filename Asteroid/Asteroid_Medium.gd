extends Asteroid
class_name Asteroid_Medium

const asteroid_small = preload("res://Asteroid/Asteroid_Small.tscn")

func destroy() -> void:
	# spawn two small asteroids and then destroy self
	for i in range(2):
		var asteroid_small_inst = asteroid_small.instance()
		var rand_rot = rng.randf_range(0, TAU)
		get_tree().root.add_child(asteroid_small_inst)
		asteroid_small_inst.speed = 75 # probably should be defined in asteroid_small.gd
		asteroid_small_inst.start(position, rand_rot)
	emit_signal("asteroid_destroyed", self)
	queue_free()
