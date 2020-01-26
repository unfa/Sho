extends Node

var stars_collected = 0

onready var stars_total = get_tree().get_nodes_in_group("stars").size()
onready var player = get_tree().get_nodes_in_group("players")[0]


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#player.connect("star_collected", self, "star_collected")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func show_info(var info):
	var label = $UI/InfoBox/Info
	var anim = $UI/InfoBox/AnimationPlayer
	label.text = info
	
	anim.stop()
	anim.play("ShowInfo")
	
func show_tutorial(var tutorial):
	var label = $UI/TutorialBox/Info
	var anim = $UI/TutorialBox/AnimationPlayer
	label.text = tutorial
	
	anim.stop()
	anim.play("Show")
	
func hide_tutorial():
	var label = $UI/TutorialBox/Info
	var anim = $UI/TutorialBox/AnimationPlayer
	
	anim.play("Hide", 1)

func star_collected():
	stars_collected += 1
	show_info("Stars Collected: " + String(stars_collected) + " out of " + String(stars_total))

	
func _input(event):
	if event is InputEventKey and Input.is_action_just_pressed("game_restart"):
		get_tree().reload_current_scene()
