extends Camera

onready var player = get_tree().get_nodes_in_group("players")[0]

var interpolation = 0.05

# zoom steps

const zoom_increment = 0.1
const zoom_max = 1
const zoom_min = 0
const zoom_default = 0.5

var zoom = zoom_default

# actual zoom values

const zoom_factor_gamma = 1.2
const zoom_factor_max = 0.12
const zoom_factor_min = 1.5

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _input(event):
	if event is InputEventKey:
		if Input.is_action_pressed("camera_zoom_in"):
			zoom += zoom_increment
		elif Input.is_action_pressed("camera_zoom_out"):
			zoom -= zoom_increment
		elif Input.is_action_pressed("camera_zoom_reset"):
			zoom = zoom_default
		
		# clamp values:
		
		if zoom > zoom_max:
			zoom = zoom_max
		
		if zoom < zoom_min:
			zoom = zoom_min
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# tracking location
	var transform = global_transform
	
	var zoom_factor = lerp(zoom_factor_min, zoom_factor_max, pow(zoom, zoom_factor_gamma) )
	
	print("zoom:", zoom, " zoom factor: ", zoom_factor)
	
	var offset_loc = Vector3 (0, 8, -16) * zoom_factor
	var player_loc = player.global_transform[3]
	var camera_loc = global_transform[3]
	var target_loc = player_loc + offset_loc
	

	transform[3] = lerp(camera_loc, target_loc, interpolation)
	
	# tracking rotation
	transform[1] = lerp(transform[1], transform.looking_at(player_loc, Vector3(0, 1, 0))[1], interpolation)
	
	#apply the new transform
	global_transform = transform
	
#	var offset_rot = Vector3 (0, 45, 0)
#	var player_rot = player.global_transform[1]
#	var camera_rot = global_transform[1]
#	var target_rot = player_rot + offset_rot
#
#	global_transform[1] = lerp(camera_rot, target_rot, interpolation)
	
	#global_transform[3][1] += 1 * delta
	
	
	
	
