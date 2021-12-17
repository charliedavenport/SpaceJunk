extends Control

var player_name: String
var is_check_input: bool
var char_ind: int
onready var timer = get_node("Timer")
onready var new_hs_label = get_node("NewHighScoreLabel")
onready var char_entry_container = get_node("CenterContainer/CharacterEntryContainer")

signal name_entered(name)

func _ready():
	is_check_input = false

func do_name_entry():
	self.visible = true
	char_entry_container.visible = false
	timer.start()
	yield(timer, "timeout")
	char_entry_container.visible = true
	player_name = ""
	char_ind = 0
	is_check_input = true
	for i in range(char_entry_container.get_child_count()):
		var label = char_entry_container.get_child(i)
		label.text = "_"
	char_entry_container.get_child(char_ind).flash()

func next_char(entered_char: String) -> void:
	if char_ind > 2:
		return
	var char_label = char_entry_container.get_child(char_ind)
	char_label.text = entered_char
	char_label.idle()
	if char_ind == 2:
		print("player entered name")
		emit_signal("name_entered", player_name)
		return
	char_ind += 1
	char_label = char_entry_container.get_child(char_ind)
	char_label.flash()
	

func _input(event):
	if not is_check_input:
		return
	if event is InputEventKey and event.is_pressed():
		var key = event.scancode
		if key >= KEY_A and key <= KEY_Z:
			if len(player_name) < 3:
				var new_char = char(key).to_upper()
				player_name += new_char
				next_char(new_char)
		elif key == KEY_BACKSPACE:
			pass
