extends Node2D

@onready var help = $Control/help
@onready var help_text = $Control/helpText
@onready var panel = $Control/Panel

const PANEL_BASE = preload("res://panel_base.tres")
const PANEL_HOVERED = preload("res://panel_hovered.tres")

func _on_button_pressed():
	Global.levelNumber = 1
	Global.isLevelOver = true
	Global.died = false
	Global.spikes = 4
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_help_mouse_entered():
	help_text.show()

func _on_help_mouse_exited():
	help_text.hide()
