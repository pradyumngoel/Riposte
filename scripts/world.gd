extends Node2D

@onready var spawn1 = $spawnMarkers/spawn1
@onready var spawn2 = $spawnMarkers/spawn2
@onready var spawn3 = $spawnMarkers/spawn3
@onready var spawn4 = $spawnMarkers/spawn4
@onready var spawn5 = $spawnMarkers/spawn5
@onready var spawn6 = $spawnMarkers/spawn6

@onready var text = $Text

var enemy = preload("res://scenes/enemy.tscn")

var spawns;
var levels = [4, 6, 0]#, 6, 1, 4, 6, 4, 1, 0]
var enemies = []

var player = preload("res://scenes/player.tscn")
var playerInstance

func _ready():
	OS.set_window_title(ProjectSettings.get_setting("application/config/name") + " without debug :-)"
	
	spawns = [spawn1, spawn2, spawn3, spawn4, spawn5, spawn6]
	playerInstance = player.instantiate()
	add_child(playerInstance)
	
	for i in range(levels.size() - 1):
		if levels[i] == 1:
			enemies.append("soldier")
		if levels[i] > 1:
			var random = randi_range(0, 1)
			if random < 0.5:
				enemies.append("orc")
			elif random >= 0.5:
				enemies.append("slime")

func _process(delta):
	if Global.isLevelOver:
		Global.isLevelOver = false
		
		if Global.levelNumber >= levels.size():
			get_tree().change_scene_to_file("res://scenes/win_screen.tscn")
			
		text.text = "Wave " + str(Global.levelNumber)
		
		if Global.levelNumber == 1 and Global.died:
			Global.died = false
			for i in range(levels.size() - 1):
				if levels[i] == 1:
					enemies.append("soldier")
				if levels[i] > 1:
					var random = randi_range(0, 1)
					if random < 0.5:
						enemies.append("orc")
					elif random >= 0.5:
						enemies.append("slime")
						
			playerInstance = player.instantiate()
			add_child(playerInstance)
			playerInstance.visible = false
			playerInstance.canMove = false
			
			text.text = "YOU DIED"
			
			for i in range($enemies.get_child_count()):
				$enemies.get_child(i).visible = false
				
			await get_tree().create_timer(1.5).timeout
			
			playerInstance.visible = true
			playerInstance.canMove = true
			
			Global.levelNumber = 1
			Global.spikes = 4
			
			text.text = "Wave " + str(Global.levelNumber)
			
		if !Global.died:
			playerInstance.position = $playerSpawner.position
		
			for i in range(levels[Global.levelNumber - 1]):
				var enemyInstance = enemy.instantiate()
				enemyInstance.enemyType = enemies[Global.levelNumber - 1]
				enemyInstance.position = spawns[i].position
				$enemies.add_child(enemyInstance)
				
			if $enemies.get_child_count() > levels[Global.levelNumber - 1]:
				for i in range($enemies.get_child_count() - levels[Global.levelNumber - 1]):
					$enemies.get_child(i).queue_free()
			
	if $enemies.get_child_count() == 0:
		Global.isLevelOver = true
		Global.levelNumber += 1
		Global.spikes += 1
		if playerInstance.health <= 75:
			playerInstance.health += 25
		else:
			playerInstance.health = 100
		
	$spikeCount.text = str(Global.spikes)

func win():
	print("win")
