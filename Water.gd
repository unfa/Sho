extends MeshInstance

var active = true

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var camera = get_tree().get_nodes_in_group("camera")[0]
	$WaterViewport/WaterCamera.fov = camera.fov
	var xform: Transform = camera.global_transform

	xform = xform.rotated(Vector3.RIGHT, PI)
	xform.origin.x = camera.global_transform.origin.x
	xform.origin.z = camera.global_transform.origin.z
	xform.origin.y = global_transform.origin.y - abs(camera.global_transform.origin.y - global_transform.origin.y)

	$WaterViewport/WaterCamera.global_transform = xform
	
func _on_Area_body_entered(body):
	if body.is_in_group("players") and active:
		body.water()
