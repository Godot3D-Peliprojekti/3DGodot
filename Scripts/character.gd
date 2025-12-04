extends Node3D


func play_footstep() -> void:
	if owner and owner.has_method("play_footstep"):
		owner.play_footstep()
