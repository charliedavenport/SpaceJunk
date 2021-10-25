extends Asteroid
class_name Asteroid_Small

func destroy() -> void:
	emit_signal("asteroid_destroyed", self)
	queue_free()
