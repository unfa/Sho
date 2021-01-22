extends Spatial

onready var FireLight = $LigthHandle/FireLight
onready var Cameras = $Cameras
onready var StartSmoke = $StartSmoke

export var velocity = 0
export var flight = false

const MAX_SPEED = 200

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func takeoff():
	flight = true
	FireLight.show()
	$Fire.emitting = true
	$Smoke.emitting = true
	
	remove_child(StartSmoke)
	get_tree().root.add_child(StartSmoke)
	StartSmoke.emitting = true
	
func shake(target: Node, distance: float):
		# reset location to immmediate parent
		target.global_transform.origin = target.get_parent().global_transform.origin
		# randomly offset location to crate tremor effect
		target.translate_object_local(Vector3(rand_range(-distance, distance), rand_range(-distance, distance), rand_range(-distance, distance)))
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_key_pressed(OS.find_scancode_from_string('r')):
		takeoff()
		
	if Input.is_key_pressed(OS.find_scancode_from_string('1')):
		$"Cameras/1".current = false
		$"Cameras/1".current = true
	
	if Input.is_key_pressed(OS.find_scancode_from_string('2')):
		$"Cameras/2".current = false
		$"Cameras/2".current = true
	
	if Input.is_key_pressed(OS.find_scancode_from_string('3')):
		$"Cameras/3".current = false
		$"Cameras/3".current = true

	if flight:
		shake(FireLight, 0.35)
		shake(Cameras, 0.025)

func _physics_process(delta):
	if flight:
		velocity = lerp(velocity, 1, 0.01 * delta)
		translate(Vector3(0, velocity * MAX_SPEED * delta, 0))
		print("ROCKET VELOCITY: ", velocity)
