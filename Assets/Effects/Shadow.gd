extends RayCast

onready var shadow = $Mesh

const MARGIN = Vector3(0, 0.01, 0)

const DISTANCE_FACTOR = 0.1

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#var distance = get_collision_point().distance_to(self.global_transform.origin)
	shadow.global_transform.origin = get_collision_point() + MARGIN
	#shadow.scale = lerp(distance
