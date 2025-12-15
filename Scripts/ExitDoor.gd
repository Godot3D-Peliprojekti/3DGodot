extends Interactable
class_name ExitDoor

@export var target_scene: PackedScene
@export var required_key := 1
@onready var door_locked_prompt: Label
@onready var locked_audio: AudioStreamPlayer3D = $"../../../AudioStreamPlayer3D"

const MESSAGE_TIME := 2.0

var message_timer := 0.0
var show_message := false

func _ready():
	door_locked_prompt = get_node("/root/Node3D/NavigationRegion3D/Main/Player/CanvasLayer/Control/DoorLocked_prompt")
	assert(door_locked_prompt)
	door_locked_prompt.visible = false

func interact(_player):
	if not PlayerData.has_key_1:
		if not locked_audio.playing:
			locked_audio.play()

		print("ExitDoor locked – no key")
		door_locked_prompt.visible = true
		show_message = true
		message_timer = MESSAGE_TIME
		return

	print("ExitDoor open – change scene")
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_packed(target_scene)
	print(target_scene)

	PlayerData.is_on_first_floor = true

func _process(delta):
	if show_message:
		message_timer -= delta
		if message_timer <= 0.0:
			door_locked_prompt.visible = false
			show_message = false
