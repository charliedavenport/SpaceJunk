extends Asteroid
class_name Asteroid_Big

const asteroid_medium = preload("res://Asteroid/Asteroid_Medium.tscn")

func destroy() -> void:
	# spawn two small asteroids and then destroy self
	for i in range(2):
		var asteroid_medium_inst = asteroid_medium.instance()
		var rand_rot = rng.randf_range(0, TAU)
		get_tree().root.add_child(asteroid_medium_inst)
		asteroid_medium_inst.speed = 75 # probably should be defined in asteroid_small.gd
		asteroid_medium_inst.start(position, rand_rot)
	emit_signal("asteroid_destroyed", self)
	queue_free()
