extends KinematicBody2D



const ACCELERATION = 200
const MAX_SPEED = 60
const SLOWER_SPEED = 60
const FRICTION = 400
const JUMP_HEIGHT = -100
const JUMP_BOOST = -15
const GRAVITY = 10

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
export var hp = 60
var cooldown = false
var playerVector = Vector2.ZERO
var jumping = false
var initiateJump = false


onready var jumpTimer = $Timer3
onready var sprite = $Sprite
onready var gunSprite = $Sprite2
onready var raycast = $RayCast2D
onready var bulletScene = load("res://Tilemaps_and_Objects/Hazards/enemy_bullet.tscn")

func _ready():
	pass

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
		#velocity.x = min(velocity.x + ACCELERATION, MAX_SPEED)
		velocity.x = (velocity.move_toward(playerVector * MAX_SPEED, ACCELERATION * delta)).x
	else:
		#velocity.x = max(velocity.x - ACCELERATION, -MAX_SPEED)
		velocity.x = (velocity.move_toward(randDir * SLOWER_SPEED, ACCELERATION * delta)).x
	
	if is_on_floor():
		if initiateJump:
			velocity.y = JUMP_HEIGHT
			jumping = true
			initiateJump = false
			jumpTimer.start()
			print(jumpTimer.get_wait_time())
	else:
		velocity.y += GRAVITY
	if jumping == true:
		velocity.y += JUMP_BOOST
	if is_on_ceiling():
		jumping = false

	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	if hp <= 0:
		self.queue_free()
	$RichTextLabel.text = "hp: " + str(hp)


func animate():
	if playerVector.x > 0:
		sprite.flip_h = false
	else:
		sprite.flip_h = true

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

func initiate_jump():
	initiateJump = true


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


func _on_Timer3_timeout():
	jumpTimer.stop()
	jumping = false
