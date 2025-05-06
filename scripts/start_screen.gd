extends Node2D

func _on_button_pressed():
	Global.levelNumber = 1
	Global.isLevelOver = true
	Global.died = false
	Global.spikes = 4
	get_tree().change_scene_to_file("res://scenes/world.tscn")
