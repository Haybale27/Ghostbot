extends KinematicBody2D

const ACCELERATION = 200
const MAX_SPEED = 200
const FRICTION = 150

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
	stats.activePlayer = self
	add_to_group("ghostly")
	stats.check_players()
	stats.activate_ghost_mode()
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
	stats.hp = "Infinite"
	
	if Input.is_action_just_pressed("ui_accept") and stats.transferReady():
		stats.activate_bot_mode()
		state = IDLE
	
	
	move()

func idle_state(_delta):
	if stats.ghostMode:
		state = MOVE
		stats.activePlayer = self
	else:
		velocity = Vector2.ZERO
		self.position = stats.activePlayer.position
		animate()

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





func _on_Area2D2_body_entered(_body):
	var scene = get_tree()
	stats.respawn(scene)
