extends Spatial

onready var player = get_tree().get_nodes_in_group("players")[0]
onready var camera = $Camera

onready var marker1 = $Camera/Marker1
onready var marker2 = $Camera/Marker2
onready var marker3 = $Camera/Marker3
onready var marker4 = $Camera/Marker4
#onready var player_skeleton =  player.get_node("Mesh/Armature/Skeleton")

# controlling camera responsivness according to zoom level

const UP = Vector3(0, 1, 0)

const camera_debug = false # display 3D debug Markers?

const interpolation_mid= 0.05
const interpolation_min = 0.01
const interpolation_max = 0.5
var interpolation = interpolation_mid

var corrected_transform

var correction_blend = 0 # the blending factor between basic and corrected camera transform
var correction_lerp = 0.1 # how fast do we transition correction_blend from 0 to 1 and back

# controlling camera placement according to zoom levels:

const offset_mid = Vector3 (0, 10, -12) 
const offset_max = Vector3 (0, 10, -12) * 2.5
const offset_min = Vector3 (0, 50, -40) * 0.125
var offset = offset_mid

const player_origin_offset = Vector3(0,1,0.5) # the player origin is at the ground level - this makes sure the camera focuses in a proper spot
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
	if not camera_debug:
		for marker in [marker1, marker2, marker3, marker4]:
			marker.hide()
			
func Vector3toString(Vector):
	return String("x: %1.2f y: %1.2f z: %1.2f" % [Vector.x, Vector.y, Vector.z])
	
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
		

	# calculate camera location and rotation
	var target_transform = player.global_transform.translated(offset)
	
	# this is where the camera should be looking - in the directio of the player movement (not taking jump or gravity into account).
	target_predictive_offset = player_origin_offset #+ Vector3(player.walk_velocity[0], 0, player.walk_velocity[1]).rotated(UP, player.rotation[1]) / 4
	
	# interpolating the actual predictive offset, because without lerping the camera is jumping around like crazy)
	predictive_offset = lerp(predictive_offset, target_predictive_offset, interpolation)
	
	target_transform[2] = lerp(transform[2], target_transform[2], interpolation) # interpolate rotation
	target_transform[3] = lerp(transform[3], target_transform[3], interpolation) # interpolate location
	
	var occluded_transform = target_transform
	
	# cast a ray from player to the target camera location to make sure that level elements are not blockng the view
	var space_state = get_world().direct_space_state
	
	var ray_start = player.global_transform[3] + player_origin_offset.rotated(UP, player.rotation.y + PI - player.get_node("Mesh").rotation.y)
	#var ray_start = player_skeleton.get_bone_global_pose(player_skeleton.find_bone("head"))[3]
	var ray_end = occluded_transform[3]
	var ray_hit = Vector3()
	
	if corrected_transform == null:
		corrected_transform = occluded_transform
	
	#corrected_transform = occluded_transform
	var raycast = space_state.intersect_ray(ray_start, ray_end, [self])
	var raycast_up = space_state.intersect_ray(ray_start, ray_start + Vector3(0, 10, 0), [self])
	var raycast_back = space_state.intersect_ray(ray_start, ray_start + Vector3(0, 0, -15).rotated(UP, player.rotation.y), [self])
	var raycast_recursive
	
	if raycast.size() > 0: # check if the high mode will succeed
		raycast_recursive = space_state.intersect_ray(occluded_transform[3], raycast['position'], [self])
	
	var occlusion_mode = 'none'
	
	if raycast.size() > 0: # something blocks the camera
		if raycast_up.size() == 0 and raycast_recursive.size() == 0: # player is not blocked from the top or the high position
			
			corrected_transform[3][0] = raycast['position'][0] # X
			corrected_transform[3][1] = occluded_transform[3][1] # Y
			corrected_transform[3][2] = raycast['position'][2] # Z
	
			correction_blend = lerp(correction_blend, 1, correction_lerp)
	
			ray_hit = raycast['position']
			
			occlusion_mode = 'high'
			if camera_debug:
				marker3.show()
				marker4.show()
		elif raycast_back.size() == 0: # nothing blocks from behind
			corrected_transform[3][0] = occluded_transform[3][0] # X
			corrected_transform[3][1] = ray_start[1] # Y
			corrected_transform[3][2] = occluded_transform[3][2] # Z
			
			correction_blend = lerp(correction_blend, 1, correction_lerp)
	
			ray_hit = raycast['position']
			
			occlusion_mode = 'low'
			
		elif raycast_back.size() > 0 and raycast_up.size() > 0: # something blocks from behind, and from the top
			corrected_transform[3][0] = raycast_back['position'][0] # X
			corrected_transform[3][1] = raycast_back['position'][1] # Y
			corrected_transform[3][2] = raycast_back['position'][2] # Z
			
			correction_blend = lerp(correction_blend, 1, correction_lerp)
	
			ray_hit = raycast['position']
			
			occlusion_mode = 'close'
			
			if camera_debug:
				marker3.show()
				marker4.show()
		else: # something blocks from behind but not the top
			corrected_transform[3][0] = ray_start[0] # X
			corrected_transform[3][1] = occluded_transform[3][1] # Y
			corrected_transform[3][2] = ray_start[2] # Z
			
			correction_blend = lerp(correction_blend, 0.99, correction_lerp)
	
			ray_hit = raycast['position']
			
			occlusion_mode = 'up'
			
			if camera_debug:
				marker3.show()
				marker4.show()
	else:
		correction_blend = lerp(correction_blend, 0, correction_lerp)
		#corrected_transform[3][1] = occluded_transform[3][1] # Y
		
		if camera_debug:
			marker3.hide()
			marker4.hide()
	
	if camera_debug:
		marker1.global_transform[3] = ray_start
		marker2.global_transform[3] = lerp(ray_start, ray_end, 0.80)
		marker3.global_transform[3] = ray_hit
		marker4.global_transform[3] = lerp(ray_start, corrected_transform[3], 0.80)
		
	
	#VisualServer
	
	# move the Camera Gimbal
	global_transform = occluded_transform
	
	# move the Camera
	var final_transform = occluded_transform
	
	final_transform[2] = lerp(occluded_transform[2], corrected_transform[2], correction_blend)
	final_transform[3] = lerp(occluded_transform[3], corrected_transform[3], correction_blend)
	
	camera.global_transform = final_transform.looking_at(ray_start, UP)
	
#	player.debug('CAMERA')
#	player.debug('correction_blend: ' + String("%1.2f" % correction_blend))
#	player.debug('transform[3]: ' + Vector3toString(transform[3]))
#	player.debug('occluded_transform[3]: ' + Vector3toString(occluded_transform[3]))
#	player.debug('corrected_transform[3]: ' + Vector3toString(corrected_transform[3]))
#	player.debug('final_transform[3]: ' + Vector3toString(final_transform[3]))
#	player.debug('occlusion_mode: ' + occlusion_mode)
	
#	var offset_rot = Vector3 (0, 45, 0)
#	var player_rot = player.global_transform[1]
#	var camera_rot = global_transform[1]
#	var target_rot = player_rot + offset_rotd
#
#	global_transform[1] = lerp(camera_rot, target_rot, interpolation)
	
	#global_transform[3][1] += 1 * delta
	
	
	
	
