extends Sprite
class_name CrossOverIndicator

onready var screen_width = get_viewport_rect().size.x
onready var screen_height = get_viewport_rect().size.y

const vel_check_multiplier := 100.0
const vel_check_max_dist := 400.0
const padding := 30

func update_indicator(player_pos: Vector2, player_vel: Vector2) -> void:
	# detect if player is heading towards edge of the screen
	self.visible = true
	var new_pos: Vector2
	var vel_check := (player_vel * vel_check_multiplier)
	if vel_check.length() > vel_check_max_dist:
		vel_check = vel_check.normalized() * vel_check_max_dist
	vel_check = player_pos + vel_check
	if vel_check.x < 0:
		# find y-intercept of vel and screen edge
		var y_int = player_pos.y - ((player_vel.y / player_vel.x) * player_pos.x)
		new_pos = Vector2(screen_width - padding, y_int)
	elif vel_check.x > screen_width:
		var y_int = player_pos.y + ((player_vel.y / player_vel.x) * (screen_width - player_pos.x))
		new_pos = Vector2(padding, y_int)
	elif vel_check.y < 0:
		var x_int = player_pos.x - ((player_vel.x / player_vel.y) * player_pos.y)
		new_pos = Vector2(x_int, screen_height - padding)
	elif vel_check.y > screen_height:
		var x_int = player_pos.x + ((player_vel.x / player_vel.y) * (screen_height - player_pos.y))
		new_pos = Vector2(x_int, padding)
	else:
		self.visible = false
		return
	self.global_position = new_pos

