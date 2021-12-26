extends Sprite
class_name CrossOverIndicator

onready var screen_width = get_viewport_rect().size.x
onready var screen_height = get_viewport_rect().size.y
onready var anim = get_node("AnimationPlayer")

const vel_check_multiplier := 100.0
const vel_check_max_dist := 400.0
const default_scale := 0.05
const padding := 30

func _ready():
	anim.play("flashing")

func update_indicator(player_pos: Vector2, player_vel: Vector2) -> void:
	# detect if player is heading towards edge of the screen
	self.visible = true
	var intersect: Vector2
	var new_pos: Vector2
	var vel_check := (player_vel * vel_check_multiplier)
	if vel_check.length() > vel_check_max_dist:
		vel_check = vel_check.normalized() * vel_check_max_dist
	vel_check = player_pos + vel_check
	if vel_check.x < 0:
		# find y-intercept of vel and screen edge
		var y_int = player_pos.y - ((player_vel.y / player_vel.x) * player_pos.x)
		intersect = Vector2(0, y_int)
		new_pos   = Vector2(screen_width - padding, y_int)
	elif vel_check.x > screen_width:
		var y_int = player_pos.y + ((player_vel.y / player_vel.x) * (screen_width - player_pos.x))
		intersect = Vector2(screen_width, y_int)
		new_pos   = Vector2(padding, y_int)
	elif vel_check.y < 0:
		var x_int = player_pos.x - ((player_vel.x / player_vel.y) * player_pos.y)
		intersect = Vector2(x_int, 0)
		new_pos   = Vector2(x_int, screen_height - padding)
	elif vel_check.y > screen_height:
		var x_int = player_pos.x + ((player_vel.x / player_vel.y) * (screen_height - player_pos.y))
		intersect = Vector2(x_int, screen_height)
		new_pos   = Vector2(x_int, padding)
	else:
		self.visible = false
		return
	# use distance to edge of screen to scale the sprite
	var dist = (intersect - player_pos).length()
	var sprite_scale = default_scale * (vel_check_max_dist - dist) / vel_check_max_dist
	self.scale = Vector2(sprite_scale, sprite_scale)
	self.global_position = new_pos

