extends Interactable
class_name ExitDoor

@export var target_scene: PackedScene
@export var required_key := 1
@export var locked_message := "Door is locked"

const MESSAGE_TIME := 1.5
var message_timer := 0.0
var show_message := false
var hud_label: Label = null

func _ready():
	# Etsi MessageLabel pelin nykyisestä scenestä
	#var scene_root = get_tree().get_current_scene()
	#hud_label = scene_root.get_node("Player/CanvasLayer/Control/DoorLocked_prompt")
	if hud_label:
		hud_label.visible = false
		hud_label.text = ""

func interact(player):
	if not player.has_key_1:
		print("ExitDoor locked – no key")
		if hud_label:
			hud_label.text = locked_message
			hud_label.visible = true
			show_message = true
			message_timer = MESSAGE_TIME
		return

	print("ExitDoor open – change scene")
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_packed(target_scene)

func _process(delta):
	if show_message:
		message_timer -= delta
		if message_timer <= 0.0:
			if hud_label:
				hud_label.visible = false
			show_message = false
