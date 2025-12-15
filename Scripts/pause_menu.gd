extends Control

@onready var main_buttons: VBoxContainer = $Main_Buttons
@onready var death_buttons: VBoxContainer = $Death_Buttons
@onready var options: Panel = $Options
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var hud_control: Control = $"../Control"

func _hide() -> void:
	main_buttons.visible = false
	death_buttons.visible = false
	options.visible = false
	visible = false

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false

func _show_pause() -> void:
	main_buttons.visible = true
	visible = true

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true

func _show_death() -> void:
	death_buttons.visible = true
	visible = true

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true

# Called when the node enters the scene tree for the first time.
func _ready():
	main_buttons.visible = false
	death_buttons.visible = false
	options.visible = false

	#if not audio_stream_player.playing:
		#audio_stream_player.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_continue_pressed() -> void:
	#audio_stream_player.stream_paused = true
	get_tree().paused = false
	visible = false
	hud_control.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_try_again_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_options_pressed() -> void:
	main_buttons.visible = false
	options.visible = true

func _on_options_back_pressed() -> void:
	main_buttons.visible = true
	options.visible = false

func _on_exit_pressed() -> void:
	get_tree().quit()
