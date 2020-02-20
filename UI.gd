extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
	
func _input(event):
	if event is InputEventKey and Input.is_action_just_pressed("game_restart"):
		get_tree().reload_current_scene()
