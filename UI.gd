extends Control

onready var stars_total = get_tree().get_nodes_in_group("stars").size()
onready var player = get_tree().get_nodes_in_group("players")[0]
var stars_collected = 0

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = true
	player.connect("star_collected", self, "star_collected")
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func show_info(var info):
	var label = $InfoBox/Info
	var anim = $InfoBox/AnimationPlayer
	label.text = info
	
	anim.stop()
	anim.play("ShowInfo")
	
func show_tutorial(var tutorial):
	var label = $TutorialBox/Info
	var anim = $TutorialBox/AnimationPlayer
	label.text = tutorial
	
	anim.stop()
	anim.play("Show")
	
func hide_tutorial():
	var label = $TutorialBox/Info
	var anim = $TutorialBox/AnimationPlayer
	
	anim.play("Hide", 1)

func star_collected():
	stars_collected += 1
	show_info("Stars Collected: " + String(stars_collected) + " out of " + String(stars_total))

func _on_StartButton_pressed():
	get_tree().get_nodes_in_group("players")[0].activate()
	get_tree().paused = false
	
	# Start music stems
	$Music/Bass.play(0)
	$Music/Drums.play(0)
	$Music/Lead.play(0)
	$Music/Support.play(0)
	
	# mute the MUSIC submix bus
	AudioServer.set_bus_mute(AudioServer.get_bus_index("MUSIC"), false)
	
	#AudioServer.set_bus_mute(AudioServer.get_bus_index("Music A"), true)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music B"), true)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music C"), true)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music D"), true)
	
	$CenterContainer/StartButton.hide()	
	
func _input(event):
	if event is InputEventKey and Input.is_action_just_pressed("game_restart"):
		get_tree().reload_current_scene()
