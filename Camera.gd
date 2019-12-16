extends Camera

onready var player = get_tree().get_nodes_in_group("players")[0]

var interpolation = 0.025

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# tracking location
	var transform = global_transform
	
	var offset_loc = Vector3 (0, 8, -16)
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
	
	
	
	
