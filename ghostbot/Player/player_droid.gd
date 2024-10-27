extends KinematicBody2D

const ACCELERATION = 999
const MAX_SPEED = 250
const FRICTION = 999

enum {
	MOVE,
	IDLE
}

var state = IDLE
var velocity = Vector2.ZERO
var stats = player_stats
var transferReady = false
var id
var hp = 40 * stats.healthBoost

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
	move(delta)
	animate()
	aim()
	stats.botIsActive = true
	$CollisionShape2D.set_deferred("disabled", false)
	stats.hp.text = "HP: " + str(hp)
	if hp <= 0:
		stats.activate_ghost_mode()
		self.queue_free()
	
	if Input.is_action_just_pressed("ui_accept") and transferReady:
		stats.activate_ghost_mode()
		state = IDLE
	

func idle_state(_delta):
	sprite.rotation_degrees = 0
	velocity = Vector2.ZERO
	$CollisionShape2D.set_deferred("disabled", true)
	if !stats.ghostMode and stats.ghostReady and transferReady and !stats.botIsActive and stats.botID == id:
		state = MOVE
		stats.activeBot = self


func move(delta):
	var inputVector = Vector2.ZERO
	inputVector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	inputVector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	inputVector = inputVector.normalized()
	
	if inputVector != Vector2.ZERO:
		velocity = velocity.move_toward(inputVector * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	velocity = move_and_slide(velocity)

func animate():
	var direction = (get_global_mouse_position() - self.global_position).normalized()
	if direction.x > 0:
		sprite.flip_h = false
		sprite.offset.x = 0.5
		gunSprite.offset.x = 0.5
	else:
		sprite.flip_h = true
		sprite.offset.x = -0.5
	if direction.y < -0.6:
		sprite.rotation_degrees = 25 * sprite.offset.x * -2
	elif direction.y > 0.6:
		sprite.rotation_degrees = 25 * sprite.offset.x * 2
	else:
		sprite.rotation_degrees = 0

func aim():
	var mouse = get_global_mouse_position()
	raycast.look_at(mouse)
	gunSprite.rotation_degrees = raycast.rotation_degrees
	if Input.is_action_just_pressed("shoot"):
		var bullet = bulletScene.instance()
		get_node("/root/Room").call_deferred("add_child", bullet)
		bullet.shoot($RayCast2D/BulletSpawn.global_position, raycast.rotation_degrees, 1, 1)

func _on_Area2D_area_entered(_area):
	stats.botReady = true
	transferReady = true
	stats.botID = id


func _on_Area2D_area_exited(_area):
	stats.botReady = false
	transferReady = false


func _on_Area2D2_body_entered(body):
	hp += body.damage
	print(hp)
