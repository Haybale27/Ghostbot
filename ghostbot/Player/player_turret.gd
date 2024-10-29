extends StaticBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var minAngle = -195
var maxAngle = 15
const MAX_ANGLE = 90
var state = IDLE
var stats = player_stats
var transferReady = false
var id
var hp = 300 * stats.healthBoost
var cooldown = false
var mouseVector

onready var sprite = $Sprite
onready var gunSprite = $Sprite2
onready var raycast = $RayCast2D
onready var bulletScene = load("res://Tilemaps_and_Objects/Hazards/bullet.tscn")

enum {
	MOVE,
	IDLE
}
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("PlayerBots")

func _physics_process(_delta):
	match state:
		MOVE:
			move_state()
		IDLE:
			idle_state()
	if !stats.ghostMode and state == IDLE:
		self.modulate = modulate.from_hsv(0, 0, 0.4, 0.69)
	else:
		self.modulate = modulate.from_hsv(0, 0, 1, 1)


func move_state():
	if Input.is_action_just_pressed("switch") and transferReady:
		stats.activate_ghost_mode()
		state = IDLE
	else:
		animate()
		aim()
		stats.botIsActive = true
		$CollisionShape2D.set_deferred("disabled", false)
		$Area2D2/CollisionShape2D.set_deferred("disabled", false)
		stats.hp = str(hp)
		if hp <= 0:
			stats.activate_ghost_mode()
			self.queue_free()
		mouseVector = (get_global_mouse_position() - self.global_position).normalized()

func idle_state():
	$CollisionShape2D.set_deferred("disabled", true)
	$Area2D2/CollisionShape2D.set_deferred("disabled", true)
	if !stats.ghostMode and stats.ghostReady and transferReady and !stats.botIsActive and stats.botID == id:
		state = MOVE
		stats.activePlayer = self
		stats.botID = id
		cooldown = true
		$Timer.start()



func aim():
	var mouse =  get_global_mouse_position()
	var mouseAngle = rad2deg((mouse - self.global_position).angle()) - self.rotation_degrees
	#var mouseAngleRotatedUp = rad2deg(((mouse - self.global_position).rotated(deg2rad(90))).angle())
	if mouseAngle > 90:
		mouseAngle -= 360
	if mouseAngle >= minAngle and mouseAngle <= maxAngle:
		raycast.rotation_degrees = mouseAngle
		raycast.cast_to.x = sqrt(pow((mouse.x - self.global_position.x), 2) + pow((mouse.y - self.global_position.y), 2))
	else:
		raycast.rotation_degrees = clamp(raycast.rotation_degrees, minAngle, maxAngle)
	if Input.is_action_pressed("shoot") and cooldown == false:
		shoot()

func animate():
	gunSprite.rotation_degrees = raycast.rotation_degrees + 90

func shoot():
	var limitedMouseVector = Vector2(cos(deg2rad(raycast.rotation_degrees + self.rotation_degrees)), sin(deg2rad(raycast.rotation_degrees + self.rotation_degrees)))
	cooldown = true
	$Timer.start()
	var bullet = bulletScene.instance()
	get_node("/root/Room").call_deferred("add_child", bullet)
	bullet.shoot($RayCast2D/BulletSpawn.global_position, limitedMouseVector, raycast.rotation_degrees + self.rotation_degrees, 1, 1.17)




func _on_Area2D_area_entered(_area):
	stats.botReady = true
	transferReady = true
	stats.botID = id


func _on_Area2D_area_exited(_area):
	stats.botReady = false
	transferReady = false


func _on_Area2D2_body_entered(body):
	hp += body.damage


func _on_Timer_timeout():
	$Timer.stop()
	cooldown = false
