extends Camera

onready var player = get_tree().get_nodes_in_group("players")[0]

# controlling camera responsivness according to zoom level

const UP = Vector3(0, 1, 0)

const interpolation_mid= 0.05
const interpolation_min = 0.01
const interpolation_max = 0.5
var interpolation = interpolation_mid

# controlling camera placement according to zoom levels:

const offset_mid = Vector3 (0, 6, 12) 
const offset_max = Vector3 (0, 6, 12) * 2.5
const offset_min = Vector3 (0, 4, 12) * 0.15
var offset = offset_mid

const player_origin_offset = Vector3(0,4,0) # the player origin is at the ground level - this makes sure the camera focuses in a proper spot
var predictive_offset = player_origin_offset
var target_predictive_offset = predictive_offset

# zoom steps

const zoom_increment = 0.1
const zoom_max = 1
const zoom_min = 0
const zoom_default = 0.5

var zoom = zoom_default

# actual zoom values

const zoom_factor_gamma = 1.2
const zoom_factor_max = 0.17
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
	
	# translate zoom level to a zoom factor
	var zoom_factor = lerp(zoom_factor_min, zoom_factor_max, pow(zoom, zoom_factor_gamma) )
	
	# interpolate between far, medium and near 	zoom offsets
	if zoom > 0.5:
		interpolation = lerp(interpolation_mid, interpolation_max, zoom * 2 - 1)
		offset = lerp(offset_mid, offset_min, zoom * 2 - 1)
	else:
		interpolation = lerp(interpolation_min, interpolation_mid, zoom * 2)
		offset = lerp(offset_max, offset_mid, zoom * 2)
	
	#print (zoom, " ", interpolation)
	
	#print("zoom:", zoom, " zoom factor: ", zoom_factor)
	
	var player_loc = player.global_transform[3]
	var camera_loc = global_transform[3]
	var target_loc = player_loc + offset.rotated(Vector3(0,1,0), player.rotation.z)

	# interpolate camera location
	#transform[3] = lerp(camera_loc, target_loc, interpolation)
	
	# tracking rotation
	#transform[1] = lerp(transform[1], transform.looking_at(player_loc + player_origin_offset, Vector3(0, 1, 0))[1], interpolation)
	
	### TODO: create the target camera location here.
	var target_transform = player.global_transform.translated(offset)
	
	# takie int account the static vertical offset of the player origin and also the player walking velocity - so the cameraman is predicting movement)
	target_predictive_offset = player_origin_offset + Vector3(player.walk_velocity[0], 0, player.walk_velocity[1] * delta).rotated(UP, player.rotation[1]) / 4
	
	predictive_offset = lerp(predictive_offset, target_predictive_offset, interpolation)
	
	target_transform[2] = lerp(transform[2], target_transform[2], interpolation) # interpolate rotation
	target_transform[3] = lerp(transform[3], target_transform[3], interpolation) # interpolate location
	transform = target_transform.looking_at(player_loc + predictive_offset, UP) # point the camera at the player (no interpolation)
	
	#apply the new transform
	global_transform = transform
	
#	var offset_rot = Vector3 (0, 45, 0)
#	var player_rot = player.global_transform[1]
#	var camera_rot = global_transform[1]
#	var target_rot = player_rot + offset_rot
#
#	global_transform[1] = lerp(camera_rot, target_rot, interpolation)
	
	#global_transform[3][1] += 1 * delta
	
	
	
	
