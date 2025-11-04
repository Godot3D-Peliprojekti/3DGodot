extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_pressed() -> void:
	#print("Start pressed")
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _on_options_pressed() -> void:
	#print("Options pressed")
	pass


func _on_exit_pressed() -> void:
	#print("Exit pressed")
	get_tree().quit()
