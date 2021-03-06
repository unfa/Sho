extends MeshInstance
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var camera = get_tree().root.find_node("Camera", true, false)

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Hit")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	look_at(camera.global_transform.origin, Vector3.UP)
