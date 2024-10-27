extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var state = IDLE
var velocity = Vector2.ZERO
var stats = player_stats
var transferReady = false
var id

enum {
	MOVE,
	IDLE
}
# Called when the node enters the scene tree for the first time.
func _ready():
	.add_to_group("PlayerBots")

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


func move_state(_delta):
	move()
	animate()
	stats.botIsActive = true
	$CollisionShape2D.set_deferred("disabled", false)
	
	if Input.is_action_just_pressed("ui_accept") and transferReady:
		stats.activate_ghost_mode()
		state = IDLE

func idle_state(_delta):
	#print("Turret down")
	velocity = Vector2.ZERO
	$CollisionShape2D.set_deferred("disabled", true)
	if !stats.ghostMode and stats.ghostReady and transferReady and !stats.botIsActive and stats.botID == id:
		state = MOVE
		stats.activeBot = self



func move():
	#print("Turret movin, turret groovin")
	pass

func animate():
	pass






func _on_Area2D_area_entered(_area):
	stats.botReady = true
	transferReady = true
	stats.botID = id
	print("fuck you")


func _on_Area2D_area_exited(_area):
	stats.botReady = false
	transferReady = false
