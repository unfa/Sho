extends KinematicBody

onready var anim = $Brie/AnimationPlayer

onready var player = get_tree().get_nodes_in_group("players")[0]

export var debug = false

var BrieState = Classes.StateMachine.new(['Idle', 'Wander', 'Turn', 'Alert', 'Follow', 'Attack', 'Die', 'Dead'], 0)
var DebugHandle = Debug.DebugHandle.new("brie")

onready var WanderIdleTimer = $AI/WanderIdle

const WALK_SPEED = 1
#var walk_direction = Vector2(0, 1)

func debug(text):
	DebugHandle.debug(String(text))

func _ready():
	if debug:
		DebugHandle.enable()

func die():
	$Brie/AnimationPlayer.play("Die")
	
func gravity(delta): # drop to the ground
	move_and_collide(Vector3(0,-10*delta,0))
	
func idle():
	anim.play("Idle -loop")

func wander():
	# initialize the wander state with a random direction
	self.rotate_y(deg2rad(rand_range(1, 360)))
	
	#while BrieState.get_current_state(true) == "Wander":
		
func walk(delta):
	#var velocity2D = walk_direction * WALK_SPEED
	var velocity = Vector3(0, 0, WALK_SPEED * delta).rotated(Vector3(0,1,0), self.rotation.y)
	var motion = move_and_collide(velocity)
	
	debug("motion: " + to_json(motion))

func _physics_process(delta):
	gravity(delta)
	if BrieState.get_current_state(true) == "Wander":
		walk(delta)

func _process(delta):
	debug('previous state: ' + String(BrieState.get_previous_state(true)) )
	debug('current state: ' + String(BrieState.get_current_state(true)) )
	debug('next state: ' + String(BrieState.get_next_state(true)) )
		
	debug("WanderIdleTimer: " + String(WanderIdleTimer.time_left) )
	#debug("rotation: " + String(to_json(walk_direction)) )
	
	DebugHandle.flush_debug()	

func _on_Near_body_entered(body):
	if body.is_in_group("players"):
		#print("Player near")
		BrieState.set_current_state("Follow")


func _on_Near_body_exited(body):
	if body.is_in_group("players"):
		#print("Player near")
		BrieState.set_current_state("Alert")


func _on_Far_body_entered(body):
	if body.is_in_group("players"):
		#print("Player near")
		BrieState.set_current_state("Alert")


func _on_Far_body_exited(body):
	if body.is_in_group("players"):
		#print("Player near")
		BrieState.set_current_state("Idle")

func _on_WanderIdle_timeout():
	if BrieState.get_current_state(true) == "Idle":
			BrieState.set_current_state("Wander")
			WanderIdleTimer.start(rand_range(6, 12))
			wander()
	elif BrieState.get_current_state(true) == "Wander":
			BrieState.set_current_state("Idle")
			WanderIdleTimer.start(rand_range(3, 6))
			idle()
