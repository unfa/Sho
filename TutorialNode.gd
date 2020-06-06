extends Area

#onready var UI = get_tree().get_nodes_in_group("ui")[0]
var active = true
export (String, MULTILINE) var tutorial_text = ""
export var tutorial_delay: float = 1
export var single_use = false

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
		$Timer.start(tutorial_delay)

func _on_TutorialNode_body_exited(body):
	if body.is_in_group("players") and active:
		$Timer.stop()
		#UI.hide_tutorial()
		HUD.hide_message()
		
		# if the node should only be activated once - disable it now
		if single_use:
			active = false

func _on_Timer_timeout():
	#UI.show_tutorial(tutorial_text)
	HUD.display_message(tutorial_text)
