extends CanvasModulate


var stats = player_stats


func _ready():
	pass # Replace with function body.
	
func _process(_delta):
	if stats.ghostMode:
		var worldlyNodes = get_tree().get_nodes_in_group("Worldly")
		for node in worldlyNodes:
			if node is CanvasModulate:
				node.color = color.from_hsv(0, 0, 0.4, 0.69)
		var ghostlyNodes = get_tree().get_nodes_in_group("Ghostly")
		for node in ghostlyNodes:
			if node is CanvasModulate:
				node.color = color.from_hsv(0, 0, 1, 0.9)
	else:
		var worldly_nodes = get_tree().get_nodes_in_group("Worldly")
		for node in worldly_nodes:
			if node is CanvasModulate:
				node.color = color.from_hsv(0, 0, 1, 1)
		var ghostlyNodes = get_tree().get_nodes_in_group("Ghostly")
		for node in ghostlyNodes:
			if node is CanvasModulate:
				node.color = color.from_hsv(0, 0, 1, 0.117)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
