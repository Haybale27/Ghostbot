extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var test = 0


var ghostMode = true
var activeBot
var botReady = false
var ghostReady = false
var botIsActive = false
var playerBots = []
var botID


signal ghost_mode
signal bot_mode
signal spawn_player_droid

# Called when the node enters the scene tree for the first time.
func _ready():
	playerBots = get_tree().get_nodes_in_group("PlayerBots")
	for i in range(playerBots.size()):
		print(i, " ", playerBots[i])
		playerBots[i].id = i

func _process(_delta):
	pass

func activate_ghost_mode():
	emit_signal("ghost_mode")
	ghostMode = true
	botIsActive = false

func activate_bot_mode():
	emit_signal("bot_mode")
	ghostMode = false
	
func transferReady():
	if ghostReady and botReady:
		return true
	else:
		return false

func spawn_player_droid():
	emit_signal("spawn_player_droid")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
