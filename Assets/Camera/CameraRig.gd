extends KinematicBody

onready var camera = $Camera
onready var player = get_tree().get_nodes_in_group("players")[0]
#onready var CameraTarget = Player.get_node("CameraTarget")
onready var debug = $Debug/Label

	
const translation_offset = Vector3(0, 5, 8)
const lookat_offset = Vector3(0, 0, -10)
const player_origin_offset = Vector3(0, 4, 0)

const follow_time = 3
const lookat_time = 4

var temp_transform
var lookat_target = Vector3.ZERO
onready var player_loc = player.global_transform.origin
var player_loc_prev

var player_occluded = false

var player_moved = false

# snapping

var snapped = false
var snap_transform = Transform.IDENTITY

func snap(enable: bool, transform: Transform = Transform.IDENTITY):
	print("CAMERA SNAP ", enable)
	if enable:
		snapped = true
		snap_transform = transform
	else:
		snapped = false
		#snap_transform = Transform.IDENTITY

func _ready():
	print("Camera initiated")

func _physics_process(delta):
	
	debug.text = "CAMERA DEBUG\n\n"
	
	player_loc = player.global_transform.origin
	
	if player_loc_prev != player_loc:
		player_moved = true
	else:
		player_moved = false
	
	player_loc_prev = player_loc
	
	var player_loc = player.global_transform.origin
	var player_loc_prev
	
	debug.text += "Player moved: " + String(player_moved) + "\n"
	
	#var follow_time = 5
	#var lookat_time = 1

	# test if we can cast teh camera collider from here to the player and have nothing collide with it. Move only 80% of the way to avoid false positives from floor, fences and enemies
	if player_moved:
		player_occluded = true if move_and_collide((player.global_transform.origin - global_transform.origin) * 0.7, true, true, true) != null else false
	
	debug.text += "Player Occluded: " + String(player_occluded) + "\n"
	
	if player_occluded:
		temp_transform = global_transform
		global_transform = player.global_transform.translated(player_origin_offset)
		move_and_collide(temp_transform.origin - player.global_transform.translated(player_origin_offset).origin)
	#else:
		# interpolate location and rotation, applying an offset
	if snapped:
		temp_transform = global_transform.interpolate_with(snap_transform, follow_time * delta)
	else:
		temp_transform = global_transform.interpolate_with(player.global_transform.translated(translation_offset), follow_time * delta)

	
	#lookat_target.linear_interpolate(player.global_transform.origin, lookat_time * delta)
	#lookat_target = player.global_transform.translated(lookat_offset).origin
	
	lookat_target = player.global_transform.origin
	
	if snapped:
#		lookat_target.linear_interpolate(lookat_target + Vector3.UP * 0.5, 0.5)
		lookat_target += Vector3.UP * 2
#
#	if snapped: #apply amera offset if we're standing in front of a closed gate
#		temp_transform = temp_transform.translated(Vector3.UP * 0.5)
	
	#lookat_target = lookat_target.interpolate_with(player.global_transform.translated(lookat_offset), 0.01)
	
	# project the camera location startin at the player location to the target location to make sure the player is not occluded
	move_and_collide(temp_transform.origin - global_transform.origin)
		
	
	# look_at the player  applying an offset
#	if not snapped:
	camera.look_at(lookat_target, Vector3.UP)
#	else:
#		camera.global_transform.interpolate_with(camera.global_transform.looking_at(lookat_target, Vector3.UP), follow_time * delta)
