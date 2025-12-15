extends Control

@onready var main_buttons: VBoxContainer = $Main_Buttons
@onready var death_buttons: VBoxContainer = $Death_Buttons
@onready var win_buttons: VBoxContainer = $Win_Buttons
@onready var options: Panel = $Options
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var hud_control: Control = $"../Control"

@onready var filter = $Greyscale_Filter
var filter_value: float = 0.0

func _ready() -> void:
	main_buttons.visible = false
	death_buttons.visible = false
	win_buttons.visible = false
	options.visible = false
	visible = true

	#if not audio_stream_player.playing:
		#audio_stream_player.play()

func _process(delta: float) -> void:
	if _visible():
		filter_value = lerp(filter_value, 1.0, 16.0 * delta)

	filter.material.set_shader_parameter("value", filter_value)

	if Input.is_action_just_pressed("ui_cancel"):
		if _visible():
			_hide()
		else:
			_show_pause()

func _visible() -> bool:
	return main_buttons.visible or death_buttons.visible or win_buttons.visible or options.visible

func _hide() -> void:
	main_buttons.visible = false
	death_buttons.visible = false
	win_buttons.visible = false
	options.visible = false

	filter_value = 0.0
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false

func _show_pause() -> void:
	main_buttons.visible = true

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true

func _show_death() -> void:
	death_buttons.visible = true

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true

func _show_win() -> void:
	win_buttons.visible = true

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true

func _on_continue_pressed() -> void:
	#audio_stream_player.stream_paused = true
	hud_control.visible = true
	_hide()

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
