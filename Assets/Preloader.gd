extends Control

var target_camera = null

# Called when the node enters the scene tree for the first time.
func _ready():
	print("INITIALIZED PRELOADER")
	target_camera = get_tree().root.get_camera()
	get_tree().paused = true
	$Assets/Camera.current = true
	$Assets.show()
#	#yield(get_tree().create_timer(3), "timeout")
#	yield(get_tree(),"idle_frame")
#	yield(get_tree(),"idle_frame")
#	yield(get_tree(),"idle_frame")
#	yield(get_tree(),"idle_frame")
#

#	$Assets.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	#$Assets/Camera.queue_free()
	remove_child($Assets)
	self.hide()
	target_camera.current = true
	get_tree().paused = false
	print("FINISHED PRELOADER")
