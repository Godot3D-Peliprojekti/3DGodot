extends StaticBody3D
class_name Chest

@export var prompt_message := "Press F to open"
@export var animation_player: AnimationPlayer
@export var open_animation_name := "open"
@export var close_animation_name := "close"

var is_open := false
var on_cooldown := false 
@export var cooldown_time := 1.0  

@onready var pill_bottle: Node = $PillBottle
@onready var health_kit: Node = $HealthKit
var chosen_item: Node = null

# Spawn the pill_bottle or health_kit in random chest
func _ready():
	randomize()
	setup_random_item()  

func setup_random_item():
	if randi() % 2 == 0:
		chosen_item = pill_bottle
		pill_bottle.show()
		health_kit.hide()
	else:
		chosen_item = health_kit
		health_kit.show()
		pill_bottle.hide()
	
	# Item cannot be picked up when chest is closed
	if chosen_item.has_method("set_pickable"):
		chosen_item.set_pickable(false)
		
func interact(_body) -> void:
	if on_cooldown:
		return
		
	if not animation_player:
		print("AnimationPlayer missing")
		return
		
	on_cooldown = true
	
	if is_open:
		# Close chest
		if animation_player.has_animation(close_animation_name):
			animation_player.play(close_animation_name)
		is_open = false
		prompt_message = "Press F to open"
		
		if chosen_item and chosen_item.has_method("set_pickable"):
			chosen_item.set_pickable(false)
			
	else:
		# Open chest
		if animation_player.has_animation(open_animation_name):
			animation_player.play(open_animation_name)
		is_open = true
		prompt_message = "Press F to close"

		# Now the item can be picked up
		if chosen_item and chosen_item.has_method("set_pickable"):
			chosen_item.set_pickable(true)
			
	# Cooldown timer
	var t := Timer.new()
	t.wait_time = cooldown_time
	t.one_shot = true
	add_child(t)
	t.timeout.connect(_on_cooldown_finished)
	t.start()
	
func _on_cooldown_finished() -> void:
	on_cooldown = false
