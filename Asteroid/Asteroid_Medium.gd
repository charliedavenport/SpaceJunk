extends Asteroid
class_name Asteroid_Medium

const asteroid_small = preload("res://Asteroid/Asteroid_Small.tscn")

func destroy() -> void:
	# spawn two small asteroids and then destroy self
	for i in range(2):
		var asteroid_small_inst = asteroid_small.instance()
		var dir = vel.normalized().rotated(TAU/4 if i==0 else -TAU/4)
		dir = dir + vel.normalized()
		get_tree().root.add_child(asteroid_small_inst)
		asteroid_small_inst.start(position, dir.angle())
	print("medium asteroid destroyed")
	emit_signal("asteroid_destroyed", self)
	queue_free()
