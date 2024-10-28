extends StaticBody2D

enum {
	MOVE,
	IDLE
}

var minAngle = -195
var maxAngle = 15

var state = IDLE
var stats = player_stats
var id
export var hp = 120
var cooldown = false
var playerVector


onready var sprite = $Sprite
onready var gunSprite = $Sprite2
onready var raycast = $RayCast2D
onready var bulletScene = load("res://Tilemaps_and_Objects/Hazards/enemy_bullet.tscn")

func _ready():
	pass

func _physics_process(_delta):
	match state:
		MOVE:
			move_state()
		IDLE:
			idle_state()
	



func move_state():
	if stats.ghostMode:
		state = IDLE
	else:
		if hp <= 0:
			self.queue_free()
		$RichTextLabel.text = "hp: " + str(hp)
		animate()
		aim()
		playerVector = (stats.activePlayer.global_position - self.global_position).normalized()
	

func idle_state():
	if !stats.ghostMode:
		state = MOVE
		cooldown = true
		$Timer.start()


func animate():
	gunSprite.rotation_degrees = raycast.rotation_degrees + 90

func aim():
	var player = stats.activePlayer.global_position
	var playerAngle = rad2deg((player - self.global_position).angle()) - self.rotation_degrees
	if playerAngle > 90:
		playerAngle -= 360
	if playerAngle >= minAngle and playerAngle <= maxAngle:
		raycast.look_at(player)
		raycast.cast_to.x = sqrt(pow((player.x - self.global_position.x), 2) + pow((player.y - self.global_position.y), 2))
		if raycast.is_colliding() == false and cooldown == false:
			shoot()
	else:
		raycast.rotation_degrees = clamp(raycast.rotation_degrees, minAngle, maxAngle)

func shoot():
	var limitedPlayerVector = Vector2(cos(deg2rad(raycast.rotation_degrees + self.rotation_degrees)), sin(deg2rad(raycast.rotation_degrees + self.rotation_degrees)))
	cooldown = true
	$Timer.start()
	var bullet = bulletScene.instance()
	get_node("/root/Room").call_deferred("add_child", bullet)
	bullet.shoot($RayCast2D/BulletSpawn.global_position, limitedPlayerVector, raycast.rotation_degrees + self.rotation_degrees, 1, 1.17)


func _on_Area2D_body_entered(body):
	hp += body.damage


func _on_Timer_timeout():
	$Timer.stop()
	cooldown = false
