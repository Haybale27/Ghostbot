extends Node2D

onready var levelNum = 1
onready var roomNum = stats.roomNum
export var pickRoom = true
var stats = player_stats
onready var folderPath = "res://Levels/Level" + str(levelNum) + "/"
onready var sprite = $Sprite


func _ready():
	stats.check_enemies()
	stats.connect("allow_exit", self, "open_portal")

func _process(delta):
	sprite.rotation_degrees += (-900 * delta)

func load_room():
	stats.change_room()
# warning-ignore:return_value_discarded
	get_tree().change_scene(stats.currentScene)

func open_portal():
	sprite.visible = true
	$Area2D/CollisionShape2D.set_deferred("disabled", false)

#func sort_rooms():
#	var dir = Directory.new()
#	if dir.open(folderPath) == OK:
#		dir.list_dir_begin()
#		while true:
#			var filename = dir.get_next()
#			if filename == "":
#				break  # End of files
#			if filename.begins_with("room") and filename.ends_with(".tscn"):
#				rooms.append(filename)
#		dir.list_dir_end()
#		var roomCount = min(rooms.size(), 3)
#		while selectedRooms.size() < roomCount:
#			var randomIndex = randi() % rooms.size()
#			var randomRoom = rooms[randomIndex]
#			if randomRoom not in selectedRooms:
#				selectedRooms.append(randomRoom)
#		return selectedRooms
#	else:
#		print("Error: Could not open directory")
#	return []


func _on_Area2D_body_entered(_body):
	$Timer.start()


func _on_Timer_timeout():
	$Timer.stop()
	load_room()
