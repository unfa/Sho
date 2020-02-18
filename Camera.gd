extends KinematicBody

onready var camera = $Camera
onready var player = get_tree().get_nodes_in_group("players")[0]
#onready var CameraTarget = Player.get_node("CameraTarget")
onready var debug = $Debug/Label

	
const translation_offset = Vector3(0, 5, 10)
const lookat_offset = Vector3(0, 0, -10)
const player_origin_offset = Vector3(0, 1, 0)

const follow_time = 3
const lookat_time = 4

var temp_transform
var lookat_target = Vector3.ZERO
onready var player_loc = player.global_transform.origin
var player_loc_prev

var player_occluded = false

var player_moved = false

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
		player_occluded = true if move_and_collide((player.global_transform.origin - global_transform.origin) * 0.8, true, true, true) != null else false
	
	debug.text += "Player Occluded: " + String(player_occluded) + "\n"
	
	if player_occluded:
		temp_transform = global_transform
		global_transform = player.global_transform.translated(player_origin_offset)
		move_and_collide(temp_transform.origin - player.global_transform.translated(player_origin_offset).origin)
	#else:
		# interpolate location and rotation, applying an offset
	temp_transform = global_transform.interpolate_with(player.global_transform.translated(translation_offset), follow_time * delta)
	
	#lookat_target.linear_interpolate(player.global_transform.origin, lookat_time * delta)
	#lookat_target = player.global_transform.translated(lookat_offset).origin
	lookat_target = player.global_transform.origin
	
	#lookat_target = lookat_target.interpolate_with(player.global_transform.translated(lookat_offset), 0.01)
	
	move_and_collide(temp_transform.origin - global_transform.origin)
	
	
		
	# look_at the player  applying an offset
	camera.look_at(lookat_target, Vector3.UP)

#	global_transform = temp_transform.interpolate_with(temp_transform.looking_at(player.global_transform.translated(lookat_offset).origin, Vector3.UP), lookat_time * delta)
