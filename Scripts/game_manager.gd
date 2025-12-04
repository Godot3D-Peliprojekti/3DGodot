extends Node3D
class_name GameManager

@export var drawers: Array[Interactable] = []
@export var keys: Array[Key] = []

func _ready():
	await get_tree().process_frame
	randomize()

	# Poistetaan null-arvot varmuuden vuoksi
	drawers = drawers.filter(func(d): return d != null)
	keys = keys.filter(func(k): return k != null)

	if drawers.is_empty() or keys.is_empty():
		push_error("Assign drawers and keys in the inspector! (No valid nodes)")
		return

	var chosen_index = randi() % drawers.size()
	var chosen_drawer = drawers[chosen_index]

	var chosen_key_index = randi() % keys.size()
	var chosen_key = keys[chosen_key_index]

	chosen_drawer.key = chosen_key
	chosen_key.set_pickable(false)
	print("Key ", chosen_key.name, " assigned to drawer ", chosen_drawer.name)

	for drawer in drawers:
		if drawer != chosen_drawer:
			drawer.key = null

	for key in keys:
		if key != chosen_key:
			key.set_pickable(false)
