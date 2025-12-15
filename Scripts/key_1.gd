extends StaticBody3D
class_name Key

@export var key_id: int = 1  # 1 = first key, 2 = second key
@export var prompt_message := "[F] Pick up"
@onready var collision: CollisionShape3D = $CollisionShape3D

@onready var key_audio: AudioStreamPlayer3D = $AudioStreamPlayer3D

func _ready():
	#set_pickable(false)  # hide initially
	pass

func set_pickable(value: bool):
	visible = value
	if collision:
		collision.disabled = !value

func interact(body):
	if collision and not collision.disabled:
		if body is Player:
			match key_id:
				1:
					body.has_key_1 = true
				2:
					body.has_key_2 = true
			key_audio.play()
			print(body.name, " picked up Key ", key_id, ": ", name)

			await key_audio.finished
			queue_free()
