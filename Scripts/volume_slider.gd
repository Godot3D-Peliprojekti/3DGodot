extends HSlider

# The name of the bus the slider will control
@export var bus_name: String

var bus_index: int
func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)		# Get the bus index and store it to bus_index variable
	value_changed.connect(_on_value_changed)
	
	value = db_to_linear(
		AudioServer.get_bus_volume_db(bus_index)
	)
	
	# Update the volume when slider value changes
func _on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(value)
	)
