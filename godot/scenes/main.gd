extends Control

func _ready() -> void:
	print("=== main _ready START ===")
	get_tree().change_scene_to_file("res://scenes/onboarding/onboarding.tscn")
	print("=== main _ready END ===")
