extends Node3D

var health: int

# Health bar
@onready var health_bar = $Health_Bar
@onready var health_bar_progress_bar = $Health_Bar_SubViewport/Control/ProgressBar
@onready var health_bar_label = $Health_Bar_SubViewport/Control/Label

# Health indicator
@onready var health_indicator = $Health_Indicator
@onready var health_indicator_label = $Health_Indicator_SubViewport/Label

func _hit(damage: int) -> void:
	health_indicator_label.text = "-" + str(damage)
	health_indicator.position.y = 0.0
	health_indicator.modulate.a = 1.0

func _look_at(target: Vector3) -> void:
	health_bar.look_at(target)
	health_bar.global_rotation.x = 0.0
	health_bar.global_rotation.z = 0.0

	health_indicator.look_at(target)
	health_indicator.position.z = -0.1
	health_indicator.global_rotation.x = 0.0
	health_indicator.global_rotation.z = 0.0

func _process(delta: float) -> void:
	health_bar_progress_bar.value = lerp(health_bar_progress_bar.value, float(health), 10.0 * delta)
	health_bar_label.text = str(health)

	health_indicator.position.y = lerp(health_indicator.position.y, 0.07, 2.0 * delta)
	health_indicator.modulate.a = lerp(health_indicator.modulate.a, 0.0, 4.0 * delta)

	var s = float(health) / 100.0
	health_bar_progress_bar.modulate.r = -s + 1
	health_bar_progress_bar.modulate.g = s
