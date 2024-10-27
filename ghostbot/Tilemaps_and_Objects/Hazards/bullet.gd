extends KinematicBody2D


var speed = 400

var damage = -10
var velocity = Vector2.ZERO
var startPos

onready var timer = $Timer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	var collision = move_and_collide(Vector2.ZERO * delta)
	self.position += (Vector2.RIGHT * speed).rotated(deg2rad(rotation_degrees)) * delta
	self.position += (Vector2(speed, 0)).rotated(deg2rad(rotation_degrees)) * delta
# warning-ignore:return_value_discarded
	self.move_and_collide(Vector2().normalized() * speed * delta)
	if collision:
		self.queue_free()
	
func shoot(pos, rot, damageBuff, speedBuff):
	self.global_position = pos
	startPos = pos
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
