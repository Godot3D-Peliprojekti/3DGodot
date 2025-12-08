extends StaticBody3D
class_name Chest

@export var prompt_message := "Press F to open"
@export var animation_player: AnimationPlayer
@export var open_animation_name := "open"
@export var close_animation_name := "close"

var is_open := false
var on_cooldown := false  # estää useamman interaktion animaation aikana
@export var cooldown_time := 1.0  # aika sekunteina

func interact(_body):
	if on_cooldown:
		return

	if not animation_player:
		print("AnimationPlayer missing")
		return

	on_cooldown = true

	if is_open:
		if animation_player.has_animation(close_animation_name):
			animation_player.play(close_animation_name)
			is_open = false
			prompt_message = "Press F to open"
	else:
		if animation_player.has_animation(open_animation_name):
			animation_player.play(open_animation_name)
			is_open = true
			prompt_message = "Press F to close"

	var t = Timer.new()
	t.wait_time = cooldown_time
	t.one_shot = true
	t.autostart = true
	t.connect("timeout", Callable(self, "_on_cooldown_finished"))
	add_child(t)

func _on_cooldown_finished():
	on_cooldown = false
