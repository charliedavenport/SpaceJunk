extends Node2D
class_name ExplosionManager

const explosion = preload("res://Main/Explosion.tscn")

func spawn_explosion(a_point: Vector2) -> void:
	var explosion_inst = explosion.instance()
	explosion_inst.global_position = a_point
	get_tree().root.add_child(explosion_inst)
	yield(explosion_inst.get_node("AnimationPlayer"), "animation_finished")
	explosion_inst.queue_free()
