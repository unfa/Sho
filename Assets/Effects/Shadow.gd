extends RayCast

const MARGIN = Vector3(0, 0.01, 0)

const MIN_DISTANCE = 1
const MAX_DISTANCE = 15

export var debug = false

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	# Make the material unique
	var material = $Mesh.get_surface_material(0).duplicate()
	$Mesh.set_surface_material(0, material)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_colliding():
		$Mesh.show() # make the shadow visible
		$Mesh.global_transform.origin = get_collision_point() + MARGIN
		var distance = global_transform.origin.distance_to(get_collision_point())
		if debug:
			print("Shadow distance: ", distance)
			
		var alpha = (MAX_DISTANCE - distance) / MAX_DISTANCE
		
		alpha = clamp(alpha, 0, 1)
		
		if debug:
			print("Shadow alpha: ", alpha)
		$Mesh.get_surface_material(0).albedo_color = Color(1,1,1, alpha)
	else:
		$Mesh.hide()

