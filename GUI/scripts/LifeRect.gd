extends TextureRect
class_name LifeRect

onready var anim = get_node("AnimationPlayer")

func do_flashing(a_num_flashes) -> void:
	if not anim:
		anim = get_node("AnimationPlayer")
	for i in range(a_num_flashes):
		anim.play("Flashing")
		yield(anim, "animation_finished")
	anim.play("Idle")
