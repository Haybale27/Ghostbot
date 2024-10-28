extends Node2D


var stats = player_stats
onready var droidScene = load("res://Player/player_droid.tscn")
onready var ghostScene = load("res://Enemies/enemy_ghost.tscn")
onready var timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	stats.connect("spawn_player_droid", self, "spawn")
	stats.connect("ghost_mode", self, "resumeTimer")
	stats.connect("bot_mode", self, "pauseTimer")

func spawn():
	var droid = droidScene.instance()
	get_node("/root/Room").call_deferred("add_child", droid)
	stats.playerBots.append(droid)
	droid.id = stats.playerBots.size() - 1
	droid.global_position = self.global_position

func spawnGhost():
	var ghost = ghostScene.instance()
	get_node("/root/Room/Ghostly").call_deferred("add_child", ghost)
	var spawny = randi() % 2
	var spawnx = randi() % 2
	if spawny == 0:
		spawny = -240
	else:
		spawny = 240
	if spawnx == 0:
		spawnx = -368
	else:
		spawnx = 368
	var spawn = Vector2(spawnx, spawny)
	ghost.global_position = spawn

func resumeTimer():
	timer.set_paused(false)
func pauseTimer():
	timer.set_paused(true)

func _on_Timer_timeout():
	timer.stop()
	spawnGhost()
	timer.start()
