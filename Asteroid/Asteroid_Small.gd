extends Asteroid
class_name Asteroid_Small

func destroy() -> void:
	#print("small asteroid destroyed")
	emit_signal("asteroid_destroyed", self)
	queue_free()
