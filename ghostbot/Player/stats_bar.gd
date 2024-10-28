extends Control

onready var hp = $hp
var stats = player_stats

func _process(_delta):
	hp.text = "HP: " + stats.hp


func _ready():
	pass


