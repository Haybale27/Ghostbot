extends KinematicBody2D

const ACCELERATION = 999
const MAX_SPEED = 300
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

onready var sprite = $Sprite

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
	stats.botIsActive = true
	
	if Input.is_action_just_pressed("ui_accept") and transferReady:
		stats.activate_ghost_mode()
		state = IDLE
	

func idle_state(_delta):
	self.rotation_degrees = 0
	velocity = Vector2.ZERO
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
	if Input.is_action_pressed("ui_right"):
		sprite.flip_h = false
		sprite.offset.x = 0.5
	elif Input.is_action_pressed("ui_left"):
		sprite.flip_h = true
		sprite.offset.x = -0.5
	if Input.is_action_pressed("ui_up"):
		rotation_degrees = 25 * sprite.offset.x * -2
	elif Input.is_action_pressed("ui_down"):
		rotation_degrees = 25 * sprite.offset.x * 2
	else:
		rotation_degrees = 0

func _on_Area2D_area_entered(_area):
	stats.botReady = true
	transferReady = true
	stats.botID = id


func _on_Area2D_area_exited(_area):
	stats.botReady = false
	transferReady = false
