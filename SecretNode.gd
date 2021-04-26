extends Area

#onready var UI = get_tree().get_nodes_in_group("ui")[0]
var active = true
export (String, MULTILINE) var secret_text = ""

onready var HUD = get_tree().get_nodes_in_group("HUD")[0]

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_TutorialNode_body_entered(body):
	if body.is_in_group("players") and active:
		HUD.display_message("Secret found!\n\n" + secret_text)
		body.secrets += 1

func _on_TutorialNode_body_exited(body):
	if body.is_in_group("players") and active:
		HUD.hide_message()
		active = false
