extends KinematicBody2D

const ACCELERATION = 500
const MAX_SPEED = 120
const FRICTION = 200

enum {
	MOVE,
	IDLE
}

var state = MOVE
var velocity = Vector2.ZERO
var stats = player_stats
var transferReady = false
var bot

onready var sprite = $AnimatedSprite

func _ready():
	add_to_group("ghostly")
	#OS.window_maximized = true

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		IDLE:
			idle_state(delta)
	
func move_state(delta):
	var inputVector = Vector2.ZERO
	inputVector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	inputVector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	inputVector = inputVector.normalized()
	
	if inputVector != Vector2.ZERO:
		velocity = velocity.move_toward(inputVector * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	animate()
	
	if Input.is_action_just_pressed("ui_accept") and stats.transferReady():
		stats.activate_bot_mode()
		state = IDLE
	if Input.is_action_just_pressed("ui_cancel"):
		stats.spawn_player_droid()
	if Input.is_action_just_pressed("ui_home"):
		for i in range(stats.playerBots.size()):
			print(i, " ", stats.playerBots[i])
	
	
	move()

func idle_state(_delta):
	self.position = stats.activeBot.position
	animate()
	if stats.ghostMode:
		state = MOVE

func animate():
	if Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down"):
		sprite.playing = false
	else:
		sprite.playing = true
	if Input.is_action_pressed("ui_right"):
		sprite.flip_h = false
	elif Input.is_action_pressed("ui_left"):
		sprite.flip_h = true

func move():
	velocity = move_and_slide(velocity)


func _on_Area2D_area_entered(_area):
	stats.ghostReady = true


func _on_Area2D_area_exited(_area):
	stats.ghostReady = false
