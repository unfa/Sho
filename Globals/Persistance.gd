extends Node

# This script deas with storing and restoring game states

class GameState:
	var playerName: String = "Sho"
	var stage: int = 1
	var score: int = 0
	var time: float = 0
	var frames: int = 0

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
