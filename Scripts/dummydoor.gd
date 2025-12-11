extends Interactable
class_name DummyDoor

@export var locked_message := "You can't go back!"
@onready var dummy_door_prompt: Label = $"../../../../Player/CanvasLayer/Control/DummyDoor_prompt"


const MESSAGE_TIME := 1.5
var message_timer := 0.0
var show_message := false
var hud_label: Label = null

func _ready():
	# Get label from canvaslayer
	hud_label = dummy_door_prompt
	if hud_label:
		hud_label.visible = false
		hud_label.text = ""

func interact(_player):
	if hud_label:
		hud_label.text = locked_message
		hud_label.visible = true
		show_message = true
		message_timer = MESSAGE_TIME

func _process(delta):
	if show_message:
		message_timer -= delta
		if message_timer <= 0.0:
			if hud_label:
				hud_label.visible = false
			show_message = false
