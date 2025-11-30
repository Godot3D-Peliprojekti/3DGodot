extends Interactable
class_name ExitAndWinDoor

@export var required_key := 2
@export var locked_message := "Door is locked"
const MESSAGE_TIME := 2.0

var locked_label: Label = null
var win_label: Label = null
var won := false

var message_timer := 0.0
var show_message := false

func _ready():
	var scene_root = get_tree().current_scene

	locked_label = scene_root.get_node("Player/CanvasLayer/Control/DoorLocked_prompt")
	if locked_label:
		locked_label.visible = false
		locked_label.text = ""

	win_label = scene_root.get_node("Player/CanvasLayer/Control/ExitAndWin_prompt")
	if win_label:
		win_label.visible = false
		win_label.text = ""
		# Aseta process_mode, jotta _process toimii myös pausessa
		win_label.process_mode = Node.PROCESS_MODE_ALWAYS
		process_mode = Node.PROCESS_MODE_ALWAYS
		set_process(true)

func interact(player):
	if not player.has_key_2:
		if locked_label:
			locked_label.text = locked_message
			locked_label.visible = true
			show_message = true
			message_timer = MESSAGE_TIME
		return

	show_win_screen()

func show_win_screen():
	if won:
		return
	won = true

	if win_label:
		win_label.visible = true
		win_label.text = "Voitit pelin!\nPaina ESC sulkeaksesi pelin."

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true

func _process(delta):
	if show_message:
		message_timer -= delta
		if message_timer <= 0.0:
			if locked_label:
				locked_label.visible = false
				locked_label.text = ""
			show_message = false

	if won and Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
