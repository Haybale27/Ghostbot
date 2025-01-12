extends KinematicBody2D

const ACCELERATION = 400
const MAX_SPEED = 200
const SLOWER_SPEED = 80
const FRICTION = 400

enum {
	MOVE,
	IDLE
}

var state = IDLE
var velocity = Vector2.ZERO
var stats = player_stats
var id
var playerDetected = false
var randDir = Vector2.RIGHT
var follow = false
export var hp = 50
var cooldown = false
var playerVector = Vector2.ZERO


onready var sprite = $Sprite
onready var gunSprite = $Sprite2
onready var raycast = $RayCast2D
onready var bulletScene = load("res://Tilemaps_and_Objects/Hazards/enemy_bullet.tscn")

func _ready():
	add_to_group("Enemy")

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		IDLE:
			idle_state(delta)
	



func move_state(delta):
	if stats.ghostMode:
		state = IDLE
	else:
		move(delta)
		animate()
		aim()
		playerVector = (stats.activePlayer.global_position - self.global_position).normalized()
	

func idle_state(_delta):
	velocity = Vector2.ZERO
	if !stats.ghostMode:
		state = MOVE
		follow = true
		cooldown = true
		$Timer2.start()


func move(delta):
	if follow:
		velocity = velocity.move_toward(playerVector * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(randDir * SLOWER_SPEED, ACCELERATION * delta)
	velocity = move_and_slide(velocity)
	
	if hp <= 0:
		stats.check_enemies()
		self.queue_free()
	$RichTextLabel.text = "hp: " + str(hp)


func animate():
	if playerVector.x > 0:
		sprite.flip_h = false
		sprite.offset.x = 0.5
		gunSprite.offset.x = 0.5
	else:
		sprite.flip_h = true
		sprite.offset.x = -0.5
	if playerVector.y < -0.4:
		sprite.rotation_degrees = 25 * sprite.offset.x * -2
	elif playerVector.y > 0.4:
		sprite.rotation_degrees = 25 * sprite.offset.x * 2
	else:
		sprite.rotation_degrees = 0

func aim():
	if !stats.ghostMode:
		var player = stats.activePlayer.global_position
		raycast.look_at(player)
		gunSprite.rotation_degrees = raycast.rotation_degrees
		raycast.cast_to.x = sqrt(pow((stats.activePlayer.global_position.x - self.global_position.x), 2) + pow((stats.activePlayer.global_position.y - self.global_position.y), 2))
		if raycast.is_colliding() == false and cooldown == false:
			shoot()

func shoot():
	cooldown = true
	$Timer2.start()
	var bullet = bulletScene.instance()
	get_node("/root/Room").call_deferred("add_child", bullet)
	bullet.shoot($RayCast2D/BulletSpawn.global_position, playerVector, raycast.rotation_degrees, 1, 1)


func random_direction():
	if !stats.ghostMode:
		var direction = rad2deg(get_angle_to((stats.activePlayer.global_position - self.global_position).normalized()))
		var leftOrRight = randi() % 2
		if leftOrRight == 0:
			randDir = randDir.rotated(deg2rad(rand_range(direction + 45, direction + 90)))
		else:
			randDir = randDir.rotated(deg2rad(rand_range(direction - 45, direction - 90)))
	#print("direction ", direction, " randDir ", randDir, " random ", rad2deg(get_angle_to((randDir).normalized())))

func _on_Area2D_body_entered(_body):
	playerDetected = true
	follow = false
	random_direction()
	$Timer.start()


func _on_Area2D_body_exited(_body):
	playerDetected = false


func _on_Timer_timeout():
	$Timer.stop()
	if playerDetected == true:
		$Timer.start()
	random_direction()
	if !playerDetected:
		follow = true


func _on_Timer2_timeout():
	$Timer2.stop()
	cooldown = false




func _on_Area2D2_body_entered(body):
	hp += body.damage
