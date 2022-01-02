extends Node2D
class_name ExplosionManager

const explosion = preload("res://Main/scenes/Explosion.tscn")

onready var rng = RandomNumberGenerator.new().randomize()

func spawn_explosion(a_point: Vector2) -> void:
	var explosion_inst = explosion.instance()
	if not rng:
		rng = RandomNumberGenerator.new()
		rng.randomize()
	explosion_inst.global_position = a_point
	var rand_rot = rng.randf_range(0, TAU)
	explosion_inst.rotate(rand_rot)
	get_tree().root.add_child(explosion_inst)
	yield(explosion_inst.get_node("AnimationPlayer"), "animation_finished")
	explosion_inst.queue_free()
