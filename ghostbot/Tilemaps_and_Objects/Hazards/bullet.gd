extends KinematicBody2D

const ACCELERATION = 9999
var speed = 350

var damage = -10
var velocity = Vector2.RIGHT
var stats = player_stats
var targetVector

onready var timer = $Timer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if !stats.ghostMode:
		var collision = move_and_collide(Vector2.ZERO * delta)
		velocity = velocity.move_toward(targetVector * speed, ACCELERATION * delta)
	#	self.position += (Vector2.RIGHT * speed).rotated(deg2rad(rotation_degrees)) * delta
	#	self.position += (Vector2(speed, 0)).rotated(deg2rad(rotation_degrees)) * delta
	# warning-ignore:return_value_discarded
		#self.move_and_collide(Vector2().normalized() * speed * delta)
		velocity = move_and_slide(velocity)
		if collision:
			self.queue_free()
	else:
		self.queue_free()
	
func shoot(pos1, pos2, rot, damageBuff, speedBuff):
	self.global_position = pos1
	targetVector = pos2
	self.rotation_degrees = rot
	damage *= damageBuff
	speed *= speedBuff
	#$CollisionShape2D.set_deferred("disabled", true)
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	$CollisionShape2D.set_deferred("disabled", false)
	timer.stop()
