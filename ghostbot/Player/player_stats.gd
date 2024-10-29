extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var test = 0


var ghostMode = true
var activePlayer
var botReady = false
var ghostReady = false
var botIsActive = false
var playerBots = []
var botID
var healthBoost = 1
var hp = "Infinite"
var levelNum = 1
var roomNum = 1
var rooms = []
var selectedRooms = []
var currentRoom = 0
var currentScene
onready var folderPath = "res://Levels/Level" + str(levelNum) + "/"

onready var enemyGhost = load("res://Enemies/enemy_ghost.tscn")

signal ghost_mode
signal bot_mode
signal spawn_player_droid
signal allow_exit

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	check_players()
	#sort_rooms()
	var dir = Directory.new()
	if dir.open(folderPath) == OK:
		dir.list_dir_begin()
		while true:
			var filename = dir.get_next()
			if filename == "":
				break
			if filename.begins_with("room") and filename.ends_with(".tscn"):
				rooms.append(filename)
		dir.list_dir_end()
	else:
		print("Error opening folder")
	print(rooms)
	change_room()

func _process(_delta):
	pass

func respawn(_scene):
	playerBots.clear()
	roomNum = 1
	levelNum = 1
	currentRoom = 0
	#sort_rooms()
	change_room()
# warning-ignore:return_value_discarded
	get_tree().change_scene(currentScene)

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

func check_enemies():
	var enemies = get_tree().get_nodes_in_group("Enemy")
	if enemies.size() <= 1:
		emit_signal("allow_exit")

func check_players():
	playerBots.empty()
	playerBots = get_tree().get_nodes_in_group("PlayerBots")
	for i in range(playerBots.size()):
		playerBots[i].id = i

func change_room():
	botReady = false
	ghostReady = false
	botIsActive = false
	activate_ghost_mode()
	check_enemies()
	currentRoom += 1
#	if currentRoom > 3:
#		level_change()
#		currentRoom = 1
#		currentScene = (folderPath + selectedRooms[currentRoom - 1])
#	else:
#		currentScene = (folderPath + selectedRooms[currentRoom - 1])
	if currentRoom > 9:
		pass
	else:
		currentScene = (folderPath + rooms[currentRoom - 1])
	print(currentScene)
	print(currentRoom)

func level_change():
	levelNum += 1
	folderPath = "res://Levels/Level" + str(levelNum) + "/"
	sort_rooms()

func sort_rooms():
	rooms.clear()
	selectedRooms.clear()
	var dir = Directory.new()
	if dir.open(folderPath) == OK:
		dir.list_dir_begin()
		while true:
			var filename = dir.get_next()
			if filename == "":
				break
			if filename.begins_with("room") and filename.ends_with(".tscn"):
				rooms.append(filename)
		dir.list_dir_end()
		var counter = 0
		while selectedRooms.size() < 3:
			var randomIndex = randi() % rooms.size()
			var fail = false
			if counter > 0:
				for i in range(selectedRooms.size()):
					if rooms[randomIndex] == selectedRooms[i]:
						fail = true
				if !fail:
					selectedRooms.append(rooms[randomIndex])
					counter += 1
			else:
				selectedRooms.append(rooms[randomIndex])
				counter += 1
	else:
		print("Error opening directory")




