extends Spatial
#
#signal indoors
#signal outdoors
#
onready var world = get_tree().root.get_node("/root/Game/World")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Indoors_body_entered(body):
	#if body.is_in_group("Players"):
		print("indoors")
		world.indoors()

func _on_Outdoors_body_entered(body):
	#if body.is_in_group("Players"):
		print("outdoors")
		world.outdoors()
