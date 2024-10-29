extends Control

onready var hp = $hp
onready var currentScene = $current_scene
var stats = player_stats

func _process(_delta):
	hp.text = "HP: " + stats.hp
	currentScene.text = stats.currentScene


func _ready():
	pass


