extends Control

@onready var main_buttons: VBoxContainer = $MainButtons
@onready var options: Panel = $Options
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var scene = preload("res://Scenes/test.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	main_buttons.visible = true
	options.visible = false

	if not audio_stream_player.playing:
		audio_stream_player.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_start_pressed() -> void:
	get_tree().change_scene_to_packed(scene)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#audio_stream_player.stream_paused = true

func _on_options_pressed() -> void:
	main_buttons.visible = false
	options.visible = true

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_back_options_pressed() -> void:
	main_buttons.visible = true
	options.visible = false
