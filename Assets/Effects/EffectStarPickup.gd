extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	#yield(get_tree().create_timer(0.1), "timeout")
	$StarParticles2.emitting = true
	$SmokeParticles2.emitting = true
	yield(get_tree().create_timer(8),"timeout")
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
