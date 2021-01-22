extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready(): 
	# randomize animation phase
	$AnimationPlayer.seek(rand_range(0,15))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func activate():
	#print(name, " torch activate")
	$Fire.emitting = true
	$Smoke.emitting = true
	$Torch/TorchLight/TorchLight_Orientation/MainLight.shadow_enabled = true


func deactivate():
	#print(name, " torch deactivate")
	$Fire.emitting = false
	$Smoke.emitting = false
	$Torch/TorchLight/TorchLight_Orientation/MainLight.shadow_enabled = false
