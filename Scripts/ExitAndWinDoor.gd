extends Interactable
class_name ExitAndWinDoor

@export var required_key := 2

@onready var door_locked_prompt: Label
@onready var pause_menu = $"../../../Player/CanvasLayer/Pause_menu"
@onready var locked_audio: AudioStreamPlayer3D = $"../../AudioStreamPlayer3D"

const MESSAGE_TIME := 2.0

var message_timer := 0.0
var show_message := false

func _ready():
	door_locked_prompt = get_node("/root/Node3D/NavigationRegion3D/First_Floor/Player/CanvasLayer/Control/DoorLocked_prompt")
	assert(door_locked_prompt)
	door_locked_prompt.visible = false

func interact(_player):
	if not PlayerData.has_key_2:
		if not locked_audio.playing:
			locked_audio.play()

		door_locked_prompt.visible = true
		show_message = true
		message_timer = MESSAGE_TIME
		return

	show_win_screen()

func show_win_screen():
	if pause_menu._visible():
		return

	pause_menu._show_win()

func _process(delta):
	if show_message:
		message_timer -= delta
		if message_timer <= 0.0:
			door_locked_prompt.visible = false
			show_message = false
