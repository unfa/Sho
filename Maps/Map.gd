extends Spatial
#
#signal indoors
#signal outdoors
#
onready var world = get_tree().root.find_node("World", true, false)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
#func _ready():
#	while world == null:
#		world = get_tree().root.get_node("World")
#		yield(get_tree(), "idle_frame")

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
