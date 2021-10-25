class_name Asteroid_Small
extends Asteroid

func destroy() -> void:
	emit_signal("asteroid_destroyed", self)
	queue_free()
