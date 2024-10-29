extends Control

onready var selecter_1 = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer/HBoxContainer/Selecter
onready var selecter_2 = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer2/HBoxContainer/Selecter
onready var selecter_3 = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer3/HBoxContainer/Selecter
onready var menuSelectSFX = $Sounds/MenuSelect
onready var menuChooseSFX = $Sounds/MenuChoose
var stats = player_stats
var current_selection = 1

func _ready():
	set_current_selection(1)

func _process(_delta):
	if Input.is_action_just_pressed("ui_down") and current_selection < 2:
		current_selection += 1
		set_current_selection(current_selection)
		menuSelectSFX.playing = true
	elif Input.is_action_just_pressed("ui_up") and current_selection > 0:
		current_selection -= 1
		set_current_selection(current_selection)
		menuSelectSFX.playing = true
	elif Input.is_action_just_pressed("ui_accept"):
		handle_selection(current_selection)

func handle_selection(_current_selection):
	if _current_selection == 0:
		menuChooseSFX.playing = true
# warning-ignore:return_value_discarded
		get_tree().change_scene(stats.currentScene)
	elif _current_selection == 1:
		menuChooseSFX.playing = true
		print("Insert Options Here")
	elif _current_selection == 2:
		menuChooseSFX.playing = true
		get_tree().quit()

func set_current_selection(_current_selection):
	selecter_1.text = ""
	selecter_2.text = ""
	selecter_3.text = ""
	if _current_selection == 0:
		selecter_1.text = ">"
	elif _current_selection == 1:
		selecter_2.text = ">"
	elif _current_selection == 2:
		selecter_3.text = ">"
