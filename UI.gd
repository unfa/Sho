extends Control

onready var stars_total = get_tree().get_nodes_in_group("stars").size()
var stars_collected = 0

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Player_star_collected():
	print("UI: star collected!")
	stars_collected += 1
	# update UI
	
	print(stars_collected)
	
	$PanelContainer/StarCounter.text = "Stars Collected: " + String(stars_collected) + " out of " + String(stars_total)
	

func _on_StartButton_pressed():
	get_tree().get_nodes_in_group("players")[0].activate()
	
	$CenterContainer/StartButton.hide()	
	$PanelContainer.show()