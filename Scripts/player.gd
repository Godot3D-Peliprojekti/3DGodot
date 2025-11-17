extends Node3D

@export var mouse_sensitivity = 0.003
@onready var usable_character = $UsableCharacter
@onready var camera = $UsableCharacter/Camera3D
@export var camera_height_stand = 1.7
@export var camera_height_crouch = 1.0
@export var camera_smooth = 6.0
@onready var movement_script = $UsableCharacter  # käytetään is_crouching
var rotation_y = 0.0
var camera_pitch = 0.0

@onready var prompt_label = $CanvasLayer/flashlightPromt
var prompt_active = true  # true kun ohje näkyy

# --- Taskulamppu ---
@onready var spotlight = $UsableCharacter/Camera3D/SpotLight3D
var flashlight_on = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if event.is_action_pressed("flashlight"):
		if prompt_active:
			# Ensimmäinen painallus: sulje prompt ja sytytä taskulamppu
			prompt_active = false
			prompt_label.visible = false
			flashlight_on = true
		else:
			# Muuten vaihdetaan taskulamppu normaalisti
			flashlight_on = !flashlight_on

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotation_y -= event.relative.x * mouse_sensitivity
		camera_pitch -= event.relative.y * mouse_sensitivity
		camera_pitch = clamp(camera_pitch, -1.2, 1.2)
		usable_character.rotation.y = rotation_y
		camera.rotation.x = camera_pitch

func _process(delta):
	# Kamera laskeutuu kyykkyä varten
	var target_height = camera_height_stand
	if movement_script.is_crouching:
		target_height = camera_height_crouch

	camera.transform.origin.y = lerp(
		camera.transform.origin.y,
		target_height,
		camera_smooth * delta
	)

	# SpotLight näkyvyys: näkyy vain jos flashlight_on ja ei kyykky
	if prompt_active:
		spotlight.visible = false  # estetään taskulamppu promptin aikana
	else:
		spotlight.visible = flashlight_on and not movement_script.is_crouching
