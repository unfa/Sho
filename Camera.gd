extends Camera

onready var player = get_tree().get_nodes_in_group("players")[0]

var interpolation = 0.1

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var offset = Vector3 (0, 3, -8)
	var player_loc = player.global_transform[3]
	var camera_loc = global_transform[3]
	var target_loc = player_loc + offset
	
	global_transform[3] = lerp(camera_loc, target_loc, interpolation)
	
	#global_transform[3][1] += 1 * delta
	
	
	
	
