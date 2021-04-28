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

	var global_rotation = xform.basis.get_euler()
	global_rotation.x *= -1
	global_rotation.z *= -1
	xform.basis = Basis(global_rotation)
	
	var origin = xform.origin
	origin.y *= -1
	origin.y += 2 * dglobal_transform.origin.y
	#origin.y -= translation.y
	
	print(global_transform.origin.y)
	
	xform.origin = origin
	
	#xform = xform.translated(Vector3(0, diff, 0))

	$WaterViewport/WaterCamera.global_transform = xform


func _on_Area_body_entered(body):
	if body.is_in_group("players") and active:
		body.water()
