extends Area2D

@export var damage: int
@export var origin: CharacterBody2D
@export var isParried: bool

var speed = 400

func _ready():
	set_as_top_level(true)

func _process(delta):
	position += (Vector2.RIGHT * speed).rotated(rotation) * delta

func bullet():
	pass
	
func shootBullet():
	pass
	
func soldierArrow():
	pass

func _on_visible_on_screen_enabler_2d_screen_exited():
	queue_free()
