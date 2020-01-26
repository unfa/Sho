extends KinematicBody

enum AI_STATE {STATE_IDLE, STATE_WANDER, STATE_ALERT, STATE_SPOTTED, STATE_ATTACK, STATE_DEAD}

class ai_agent:
	
	var ai_state = AI_STATE.STATE_IDLE setget setState, getState
	
	var ai_sight_radius = 15
	
	var ai_hearing_radius = 25
	
	var ai_sight_cone = 0.5
	
	func setState(state):
		#print("setter")
		ai_state = state
		
	func getState():
		#print("getter")
		return ai_state

var agent = ai_agent.new()

onready var anim = $Brie/AnimationPlayer

onready var player = get_tree().get_nodes_in_group("players")[0]

export var debug = true

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var DebugHandle = Debug.DebugHandle.new("brie")

# Called when the node enters the scene tree for the first time.
func _ready():
	agent.setState(AI_STATE.STATE_WANDER)

func die():
	$Brie/AnimationPlayer.play("Die")
	agent.ai_state = AI_STATE.STATE_DEAD
	
func gravity(delta): # drop to the ground
	move_and_collide(Vector3(0,-10*delta,0))
	
func ai_track_player():
	var player_loc = player.global_transform.origin
	var agent_loc = global_transform.origin
	
	var distance = agent_loc.distance_to(player_loc)
	
	if distance < agent.ai_hearing_radius:
		agent.ai_state = AI_STATE.STATE_ALERT
	

func ai_process():
	ai_track_player()
	
	if agent.ai_state == AI_STATE.STATE_IDLE:
		anim.play("Alert -loop")
	if agent.ai_state == AI_STATE.STATE_ALERT:
		anim.queue("Alert -loop")
	
func _physics_process(delta):
	gravity(delta)
	
	#brie
	
	ai_process()
	
	#debug('BRIE', true)
	DebugHandle.debug('AI state: ' + String(agent.ai_state) )
	
	DebugHandle.flush_debug()
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
