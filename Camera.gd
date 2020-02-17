extends KinematicBody

onready var camera = $Camera
onready var player = get_tree().get_nodes_in_group("players")[0]
#onready var CameraTarget = Player.get_node("CameraTarget")

func _ready():
	print("Camera initialized")
	
func _physics_process(delta):
	var translation_offset = Vector3(0, 10,10)
	var lookat_offset = Vector3(0, 0, -10)
	var lookat_target = Vector3.ZERO

	var follow_time = 5
	var lookat_time = 1
	
	# interpolate locato and rotation, applying an offset
	var temp_transform = global_transform.interpolate_with(player.global_transform.translated(translation_offset), follow_time * delta)
	
	#lookat_target.linear_interpolate(player.global_transform.origin, lookat_time * delta)
	#lookat_target = player.global_transform.translated(lookat_offset).origin
	lookat_target = player.global_transform.origin
	
	#lookat_target = lookat_target.interpolate_with(player.global_transform.translated(lookat_offset), 0.01)
#	if move_and_collide(global_transform.origin - player.global_transform.origin, true, true, true) != null:
#		print("Something obscures the view!")
#	else:
#		print("View is clear!")
	
	move_and_collide(temp_transform.origin - global_transform.origin)
	
	
		
	# look_at the player  applying an offset
	camera.look_at(lookat_target, Vector3.UP)

#	global_transform = temp_transform.interpolate_with(temp_transform.looking_at(player.global_transform.translated(lookat_offset).origin, Vector3.UP), lookat_time * delta)
