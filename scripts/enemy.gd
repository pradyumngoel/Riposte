extends CharacterBody2D

@export var enemyType: String
@export var isDead: bool

var speed = 100

var health = 100
var damage;
var player_in_area = false
var player;

var canMove = true
var hittable = false

var bulletCooldown = true

var slimeBullet = preload("res://scenes/slime_bullet.tscn")
var orcAttack = preload("res://scenes/orc_attack.tscn")
var soldierArrow = preload("res://scenes/arrow.tscn")
var soldierAttack = preload("res://scenes/soldier_attack.tscn")

func _ready():
	determineEnemy()
	isDead = false

func determineEnemy():
	if enemyType == "slime":
		speed = 100
		$AnimatedSprite2D.scale = Vector2(1.7, 1.7)
		$CollisionShape2D.shape = $hitboxes/slime_hitbox.shape
		$CollisionShape2D.position = $hitboxes/slime_hitbox.position
		$hitbox/CollisionShape2D.shape = $CollisionShape2D.shape
		$hitbox/CollisionShape2D.position = $hitboxes/slime_hitbox.position
		$detectionArea/CollisionShape2D.scale = Vector2(1, 1)
	elif enemyType == "orc":
		speed = 80
		$AnimatedSprite2D.scale = Vector2(1.7, 1.7)
		$CollisionShape2D.shape = $hitboxes/orc_hitbox.shape
		$CollisionShape2D.position = $hitboxes/orc_hitbox.position
		$hitbox/CollisionShape2D.shape = $CollisionShape2D.shape
		$hitbox/CollisionShape2D.position = $hitboxes/orc_hitbox.position
		$detectionArea/CollisionShape2D.scale = Vector2(1, 1)
	elif enemyType == "soldier":
		speed = 90
		$AnimatedSprite2D.scale = Vector2(2, 2)
		$CollisionShape2D.shape = $hitboxes/soldier_hitbox.shape
		$CollisionShape2D.position = $hitboxes/soldier_hitbox.position
		$hitbox/CollisionShape2D.shape = $CollisionShape2D.shape
		$hitbox/CollisionShape2D.position = $hitboxes/soldier_hitbox.position
		$detectionArea/CollisionShape2D.scale = Vector2(4, 4)

func _physics_process(delta):
	if canMove:
		if !isDead:
			$detectionArea/CollisionShape2D.disabled = false
			if player_in_area:
				position += (player.position - position) / speed
				$AnimatedSprite2D.play(enemyType + "-walk")
				
				if player.position.x < position.x:
					$AnimatedSprite2D.flip_h = true
				else:
					$AnimatedSprite2D.flip_h = false
				
				if bulletCooldown:
					shoot()
			else:
				$AnimatedSprite2D.play(enemyType + "-idle")
		if isDead:
			$detectionArea/CollisionShape2D.disabled = true
			$AnimatedSprite2D.play(enemyType + "-death")
			await get_tree().create_timer(1).timeout
			queue_free()
			
func _process(delta):
	if health <= 0:
		isDead = true

func _on_detection_area_body_entered(body):
	if body.has_method("player"):
		player_in_area = true
		player = body


func _on_detection_area_body_exited(body):
	if body.has_method("player"):
		player_in_area = false
		
func shoot():
	bulletCooldown = false
	
	if enemyType == "slime":
		var slimeBulletInstance = slimeBullet.instantiate()
		$Marker2D.look_at(player.position)
		slimeBulletInstance.rotation = $Marker2D.rotation
		slimeBulletInstance.position = position
		slimeBulletInstance.origin = get_node(".")
		add_child(slimeBulletInstance)
	elif enemyType == "orc" and hittable:
		canMove = false
		$AnimatedSprite2D.play("orc-attack")
		await get_tree().create_timer(0.3).timeout
		var orcAttackInstance = orcAttack.instantiate()
		$Marker2D.look_at(player.position)
		orcAttackInstance.rotation = $Marker2D.rotation
		orcAttackInstance.position = position
		orcAttackInstance.origin = get_node(".")
		add_child(orcAttackInstance)
		await get_tree().create_timer(0.2).timeout
		$AnimatedSprite2D.stop()
		canMove = true
	elif enemyType == "soldier":
		if !hittable:
			canMove = false
			$AnimatedSprite2D.play("soldier-attack2")
			await get_tree().create_timer(0.9).timeout
			canMove = true
			var soldierArrowInstance1 = soldierArrow.instantiate()
			var soldierArrowInstance2 = soldierArrow.instantiate()
			var soldierArrowInstance3 = soldierArrow.instantiate()
			var soldierArrowInstance4 = soldierArrow.instantiate()
			var soldierArrowInstance5 = soldierArrow.instantiate()
			$Marker2D.look_at(player.position)
			soldierArrowInstance1.rotation = $Marker2D.rotation
			soldierArrowInstance2.rotation = $Marker2D.rotation + 0.2
			soldierArrowInstance3.rotation = $Marker2D.rotation + 0.4
			soldierArrowInstance4.rotation = $Marker2D.rotation - 0.2
			soldierArrowInstance5.rotation = $Marker2D.rotation - 0.4
			soldierArrowInstance1.position = position
			soldierArrowInstance2.position = position
			soldierArrowInstance3.position = position
			soldierArrowInstance4.position = position
			soldierArrowInstance5.position = position
			soldierArrowInstance1.origin = get_node(".")
			soldierArrowInstance2.origin = get_node(".")
			soldierArrowInstance3.origin = get_node(".")
			soldierArrowInstance4.origin = get_node(".")
			soldierArrowInstance5.origin = get_node(".")
			add_child(soldierArrowInstance1)
			add_child(soldierArrowInstance2)
			add_child(soldierArrowInstance3)
			add_child(soldierArrowInstance4)
			add_child(soldierArrowInstance5)
		if hittable:
			canMove = false
			$AnimatedSprite2D.play("soldier-attack1")
			await get_tree().create_timer(0.5).timeout
			var soldierAttackInstance = soldierAttack.instantiate()
			$Marker2D.look_at(player.position)
			soldierAttackInstance.rotation = $Marker2D.rotation
			soldierAttackInstance.position = position
			soldierAttackInstance.origin = get_node(".")
			add_child(soldierAttackInstance)
			await get_tree().create_timer(0.5).timeout
			$AnimatedSprite2D.stop()
			canMove = true
		
	await get_tree().create_timer(1).timeout
	bulletCooldown = true


func _on_hitbox_area_entered(area):
	if area.has_method("bullet") and area.isParried == true:
		area.queue_free()
		if enemyType != "soldier":
			isDead = true
		else:
			health -= 10
	if area.has_method("spike"):
		area.queue_free()
		if enemyType != "soldier":
			isDead = true
		else:
			health -= 10


func _on_hitting_area_body_entered(body):
	if body.has_method("player"):
		hittable = true


func _on_hitting_area_body_exited(body):
	if body.has_method("player"):
		hittable = false
