extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	print("INITIALIZED PRELOADER")
	yield(get_tree(),"idle_frame")
	$Assets.show()
	#yield(get_tree().create_timer(3), "timeout")
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")

	print("FINISHED PRELOADER")
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
