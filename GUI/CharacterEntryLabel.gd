extends Label

onready var anim = get_node("AnimationPlayer")

func flash() -> void:
	anim.play("flashing")

func idle() -> void:
	anim.play("idle")
