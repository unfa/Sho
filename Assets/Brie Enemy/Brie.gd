extends KinematicBody

var brie_state = Classes.StateMachine.new(['Idle', 'Wander', 'Turn', 'Alert', 'Follow', 'Attack', 'Die', 'Dead'], 0)
var DebugHandle = Debug.DebugHandle.new("brie")

onready var anim = $Brie/AnimationPlayer

onready var player = get_tree().get_nodes_in_group("players")[0]

export var debug = true

# Declare member variables here. Examples:
# var a = 2
# var b = "text"



# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func die():
	$Brie/AnimationPlayer.play("Die")
	
	
func gravity(delta): # drop to the ground
	move_and_collide(Vector3(0,-10*delta,0))


func _physics_process(delta):
	gravity(delta)
	
	#debug('BRIE', true)
	DebugHandle.debug('current state: ' + brie_state.get_current_state(true) )
	
	DebugHandle.flush_debug()
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
