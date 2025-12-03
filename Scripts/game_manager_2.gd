extends Node3D
class_name GameManager2

@export var drawers: Array[Interactable] = []
@export var keys: Array[Key] = []

func _ready():
	await get_tree().process_frame  # wait one frame for all nodes to initialize
	randomize()

	if drawers.is_empty() or keys.is_empty():
		print("Assign drawers and keys in the inspector!")
		return

	# Pick a random drawer
	var chosen_index = randi() % drawers.size()
	var chosen_drawer = drawers[chosen_index]

	# Pick a random key (we will force it to be key_id = 2)
	var chosen_key_index = randi() % keys.size()
	var chosen_key = keys[chosen_key_index]

	# Assign the chosen key to the chosen drawer
	chosen_drawer.key = chosen_key
	chosen_key.key_id = 2  # set as second-floor key
	chosen_key.set_pickable(false)  # hidden initially
	print("Key ", chosen_key.name, " assigned to drawer ", chosen_drawer.name, " as key_id 2")

	# Remove keys from all other drawers
	for drawer in drawers:
		if drawer != chosen_drawer:
			drawer.key = null

	# Hide all other keys
	for key in keys:
		if key != chosen_key:
			key.set_pickable(false)
