extends KinematicBody2D

const ACCELERATION = 200
const MAX_SPEED = 60
const FRICTION = 150

enum {
	MOVE,
	IDLE
}

var state = IDLE
var velocity = Vector2.ZERO
var stats = player_stats
var playerVector = Vector2.ZERO
var follow = false

onready var sprite = $AnimatedSprite


func _ready():
	pass

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		IDLE:
			idle_state(delta)
	



func move_state(delta):
	if !stats.ghostMode:
		state = IDLE
		follow = false
		$CollisionShape2D.set_deferred("disabled", true)
	elif follow:
		move(delta)
		animate()
		playerVector = (stats.activePlayer.global_position - self.global_position).normalized()
	

func idle_state(_delta):
	velocity = Vector2.ZERO
	if stats.ghostMode:
		state = MOVE
		$Timer.start()


func move(delta):
	velocity = velocity.move_toward(playerVector * MAX_SPEED, ACCELERATION * delta)
	velocity = move_and_slide(velocity)


func animate():
	sprite.playing = true
	if velocity.x > 0:
		sprite.flip_h = false
	else:
		sprite.flip_h = true
	if !follow:
		self.modulate = modulate.from_hsv(0, 0, 1, .001)

func _on_Timer_timeout():
	$Timer.stop()
	follow = true
	$CollisionShape2D.set_deferred("disabled", false)
