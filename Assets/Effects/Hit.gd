extends MeshInstance
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var camera = get_viewport().get_camera()


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Hit")
	look_at(camera.global_transform.origin, Vector3.UP)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	
