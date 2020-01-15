extends KinematicBody

var debug = true

enum AI_STATE {
	idle,
	attack,
	die }

var ai_state = AI_STATE.idle

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func debug(text, clear = false): # print on_screen dubig text
	
	if not debug:
		return 1
		
	var label = $Debug/Label # get the label node
	
	if clear: # flush the text if told to do so
		label.text = ''
		
	label.text += String(text) + '\n'


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func die():
	#$AnimationPlayer.play("Die")
	hide()
	
func gravity(delta): # drop to the ground
	move_and_collide(Vector3(0,-10*delta,0))
	
func _physics_process(delta):
	gravity(delta)
	
	debug('BRIE', true)
	debug('ai_state: ' + String(ai_state) )
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
