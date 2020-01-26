extends KinematicBody

onready var anim = $Brie/AnimationPlayer

onready var player = get_tree().get_nodes_in_group("players")[0]

export var debug = false

var BrieState = Classes.StateMachine.new(['Idle', 'Wander', 'Turn', 'Alert', 'Follow', 'Attack', 'Die', 'Dead'], 0)
var DebugHandle = Debug.DebugHandle.new("brie")

func debug(text):
	DebugHandle.debug(String(text))

func _ready():
	if debug:
		DebugHandle.enable()

func die():
	$Brie/AnimationPlayer.play("Die")
	
func gravity(delta): # drop to the ground
	move_and_collide(Vector3(0,-10*delta,0))

func _physics_process(delta):
	gravity(delta)

func _process(delta):
	debug('previous state: ' + String(BrieState.get_previous_state(true)) )
	debug('current state: ' + String(BrieState.get_current_state(true)) )
	debug('next state: ' + String(BrieState.get_next_state(true)) )
	
	DebugHandle.flush_debug()	

func _on_Near_body_entered(body):
	if body.is_in_group("players"):
		#print("Player near")
		BrieState.set_current_state("Follow")
