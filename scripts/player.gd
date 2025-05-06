extends CharacterBody2D

var speed = 200

@export var canMove = true

var playerState; #animation state of player
var bullet_hit = false
var is_parrying = false
var parryable = true

var playerDirection = "s";

var bullet;

var spike = preload("res://scenes/spike.tscn")
var spikeCooldown = true

var areaParry = false
var areaParryCooldown = true
var inArea = []

@export var health = 100

func _physics_process(delta):
	if canMove:
		var direction = Input.get_vector("left", "right", "up", "down")
		
		if direction.x == 0 and direction.y == 0:
			playerState = "idle"
		elif direction.x != 0 or direction.y != 0:
			playerState = "walking"
			
		if health <= 0:
			death()
			
		if bullet_hit:
			bullet_hit = false
			if is_parrying:
				bullet.isParried = true
				
				if bullet.has_method("slime_bullet"):
					$Marker2D.look_at(bullet.origin.position)
					bullet.rotation = $Marker2D.rotation
				elif bullet.has_method("soldierArrow"):
					$Marker2D.look_at(bullet.origin.position)
					bullet.rotation = $Marker2D.rotation
				elif bullet.has_method("attack"):
					bullet.origin.isDead = true
				
				parryable = true
				
				canMove = false
				$AnimatedSprite2D.play("parry-" + playerDirection)
				await get_tree().create_timer(0.25).timeout
				$AnimatedSprite2D.stop()
				canMove = true
				
			else:
				health -= bullet.damage
				bullet.queue_free()
				
		if areaParry:
			areaParry = false
			for i in range(inArea.size()):
				inArea[i].isParried = true
				$Marker2D.look_at(inArea[i].origin.position)
				inArea[i].rotation = $Marker2D.rotation
				
			canMove = false
			$AnimatedSprite2D.play("parry-" + playerDirection)
			await get_tree().create_timer(0.25).timeout
			$AnimatedSprite2D.stop()
			canMove = true
		
		velocity = direction * speed
		move_and_slide()
	
		play_animation(direction)
	
func _process(delta):
	$healthBar.value = health
	
	if Input.is_action_just_pressed("rmb") and parryable:
		is_parrying = true
		await get_tree().create_timer(0.3).timeout
		is_parrying = false
		
	if Input.is_action_just_pressed("ui_accept") and areaParryCooldown:
		areaParry = true
		areaParryCooldown = false
		await get_tree().create_timer(5).timeout
		areaParryCooldown = true
		
	if is_parrying and !bullet_hit:
		parryable = false
		await get_tree().create_timer(0.7).timeout
		parryable = true
		
	if Input.is_action_just_pressed("lmb") and Global.spikes >= 1:
		placeSpike()
		
	if Global.isLevelOver:
		for i in range($spikes.get_child_count()):
			$spikes.get_child(i).queue_free()
		
	addSpikes()
	
func play_animation(dir):
	if playerState == "idle" and canMove:
		$AnimatedSprite2D.play("idle")
	if playerState == "walking" and canMove:
		#4-directional movement
		if dir.y == -1:
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("n-walk")
			playerDirection = "n"
		if dir.x == 1:
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("e-walk")
			playerDirection = "e"
		if dir.y == 1:
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("s-walk")
			playerDirection = "s"
		if dir.x == -1:
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("w-walk")
			playerDirection = "w"

func player():
	pass


func _on_hitbox_area_entered(area):
	if area.has_method("bullet"):
		bullet = area
		bullet_hit = true
		inArea.erase(area)

func death():
	canMove = false
	Global.died = true
	Global.isLevelOver = true
	Global.levelNumber = 1
	$AnimatedSprite2D.play("death")
	await get_tree().create_timer(1).timeout
	$AnimatedSprite2D.stop()
	
	queue_free()

func placeSpike():
	var spikeInstance = spike.instantiate()
	spikeInstance.position = position
	$spikes.add_child(spikeInstance)
	Global.spikes -= 1

func addSpikes():
	if Global.spikes < 4 and spikeCooldown:
		spikeCooldown = false
		Global.spikes += 1
		await get_tree().create_timer(20).timeout
		spikeCooldown = true

func _on_area_parry_area_entered(area):
	if area.has_method("shootBullet"):
		inArea.append(area)

func _on_area_parry_area_exited(area):
	if area.has_method("shootBullet"):
		inArea.erase(area)
