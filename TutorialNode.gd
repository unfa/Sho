extends Area

onready var UI = get_tree().get_nodes_in_group("ui")[0]
var active = true
export var tutorial_text = ""

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_TutorialNode_body_entered(body):
	if body.is_in_group("players") and active:
		$Timer.start()

func _on_TutorialNode_body_exited(body):
	if body.is_in_group("players") and active:
		#active = false
		$Timer.stop()
		UI.hide_tutorial()

func _on_Timer_timeout():
	UI.show_tutorial(tutorial_text)
