extends Asteroid
class_name Asteroid_Big

const asteroid_medium = preload("res://Asteroid/Asteroid_Medium.tscn")

func destroy() -> void:
	# spawn two medium asteroids and then destroy self
	for i in range(2):
		var asteroid_medium_inst = asteroid_medium.instance()
		var dir = vel.normalized().rotated(TAU/4 if i==0 else -TAU/4)
		dir = dir + vel.normalized()
		get_tree().root.add_child(asteroid_medium_inst)
		asteroid_medium_inst.start(position, dir.angle())
	print("big asteroid destroyed")
	emit_signal("asteroid_destroyed", self)
	queue_free()
