extends Node2D


export var blocksToJump = 1
export var jump = true
#1 block 0.04sec to 0.11 goal: 0.06
#2 block 0.12sec to 0.18 goal: 0.14
#3 block 0.19sec to 0.23 goal: 0.21
#4 block 0.24sec to 0.29 goal: 0.26
#5 block 0.30 and above


func _ready():
	pass


func _on_Area2D_body_entered(body):
	if jump:
		body.jumpTimer.set_wait_time((0.07 * blocksToJump) - 0.01)
		body.initiateJump = true
	else:
		body.follow = false
		body.velocity.x = 0
		body.noJump = true


func _on_Area2D_body_exited(body):
	body.noJump = false
