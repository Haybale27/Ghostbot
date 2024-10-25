extends Node2D


var stats = player_stats
onready var droidScene = load("res://Player/player_droid.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	stats.connect("spawn_player_droid", self, "spawn")

func spawn():
	var droid = droidScene.instance()
	get_node("/root/Room").call_deferred("add_child", droid)
	stats.playerBots.append(droid)
	droid.id = stats.playerBots.size() - 1
