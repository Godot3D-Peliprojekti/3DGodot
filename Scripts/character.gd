extends Node3D


func play_footstep() -> void:
	if owner and owner.has_method("play_footstep"):
		owner.play_footstep()
		
func play_gun_reload() -> void:
	if owner and owner.has_method("play_gun_reload"):
		owner.play_gun_reload()
		
func play_gunshot() -> void:
	if owner and owner.has_method("play_gunshot"):
		owner.play_gunshot()
