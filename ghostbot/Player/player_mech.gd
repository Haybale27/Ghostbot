extends KinematicBody2D


const ACCELERATION = 200
const MAX_SPEED = 60
const FRICTION = 400
const JUMP_HEIGHT = -100
const JUMP_BOOST = -15
const GRAVITY = 10

enum {
	MOVE,
	IDLE
}

var state = IDLE
var velocity = Vector2()
var stats = player_stats
var transferReady = false
var id
var hp = 200 * stats.healthBoost
var cooldown = false
var jumping = false

onready var sprite = $Sprite
onready var gunSprite = $Sprite2
onready var raycast = $RayCast2D
onready var bulletScene = load("res://Tilemaps_and_Objects/Hazards/bullet.tscn")

func _ready():
	add_to_group("PlayerBots")

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		IDLE:
			idle_state(delta)
	
	if !stats.ghostMode and state == IDLE:
		self.modulate = modulate.from_hsv(0, 0, 0.4, 0.69)
	else:
		self.modulate = modulate.from_hsv(0, 0, 1, 1)



func move_state(delta):
	if Input.is_action_just_pressed("switch") and transferReady:
		stats.activate_ghost_mode()
		state = IDLE
	else:
		move(delta)
		animate()
		aim()
		stats.botIsActive = true
		$CollisionShape2D.set_deferred("disabled", false)
		stats.hp = str(hp)
		if hp <= 0:
			stats.activate_ghost_mode()
			self.queue_free()

func idle_state(_delta):
	velocity = Vector2.ZERO
	$CollisionShape2D.set_deferred("disabled", true)
	if !stats.ghostMode and stats.ghostReady and transferReady and !stats.botIsActive and stats.botID == id:
		state = MOVE
		stats.activePlayer = self



func move(delta):
	var inputVector = Vector2.ZERO
	inputVector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	if inputVector.x != Vector2.ZERO.x:
		velocity.x = (velocity.move_toward(inputVector * MAX_SPEED, ACCELERATION * delta)).x
	else:
		velocity.x = (velocity.move_toward(Vector2.ZERO, FRICTION * delta)).x
#	if Input.is_action_pressed("ui_right"):
#		velocity.x = min(velocity.x + ACCELERATION, MAX_SPEED)
#	elif Input.is_action_pressed("ui_left"):
#		velocity.x = max(velocity.x - ACCELERATION, -MAX_SPEED)
#	else:
#		velocity.x = 0
	
	if is_on_floor():
		if Input.is_action_pressed("jump"):
			velocity.y = JUMP_HEIGHT
			jumping = true
			$Timer2.start()
	else:
		velocity.y += GRAVITY
	if !Input.is_action_pressed("jump"):
		jumping = false
	elif Input.is_action_pressed("jump") and jumping == true:
		velocity.y += JUMP_BOOST
	if is_on_ceiling():
		jumping = false
	
	velocity = move_and_slide(velocity, Vector2(0, -1))

func animate():
	var direction = (get_global_mouse_position() - self.global_position).normalized()
	if direction.x > 0:
		sprite.flip_h = false
	else:
		sprite.flip_h = true

func aim():
	var mouse = get_global_mouse_position()
	raycast.look_at(mouse)
	gunSprite.rotation_degrees = raycast.rotation_degrees
	if Input.is_action_pressed("shoot") and cooldown == false:
		shoot()

func shoot():
	cooldown = true
	$Timer.start()
	var bullet = bulletScene.instance()
	get_node("/root/Room").call_deferred("add_child", bullet)
	bullet.shoot($RayCast2D/BulletSpawn.global_position, get_local_mouse_position().normalized(), raycast.rotation_degrees, 1, 1)



func _on_Area2D_area_entered(_area):
	stats.botReady = true
	transferReady = true
	stats.botID = id


func _on_Area2D_area_exited(_area):
	stats.botReady = false
	transferReady = false


func _on_Area2D2_body_entered(body):
	hp += body.damage
	body.queue_free()


func _on_Timer_timeout():
	$Timer.stop()
	cooldown = false


func _on_Timer2_timeout():
	$Timer2.stop()
	jumping = false
