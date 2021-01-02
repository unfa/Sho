extends Spatial

export var push_force = 40

var affected = []


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$"Jump Pad/JumpPad -nocol/Motor -nocol/Blades -nocol".rotate_y(delta * 10)

func _physics_process(delta):
	for i in affected:
			i.jump_pad_push = push_force 

func _on_Area_body_entered(body):
	if body.is_in_group("players") and not body in affected:
		affected.append(body)
	
	print("Affected: ", affected)


func _on_Area_body_exited(body):
	if body.is_in_group("players") and body in affected:
		affected.remove( affected.find(body) )
		body.jump_pad_push = 0
		
	print("Affected: ", affected)


