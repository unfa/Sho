extends KinematicBody

onready var anim = $Brie/AnimationPlayer

onready var player = get_tree().get_nodes_in_group("players")[0]

export var debug = false

var MovementState = Classes.StateMachine.new(['Idle', 'Turn Left', 'Turn Right', 'Walk'], 0)
var ActionState = Classes.StateMachine.new(['Wander', 'Alert', 'Follow', 'Attack', 'Die', 'Dead'], 0)

var DebugHandle = Debug.DebugHandle.new('brie')

onready var WanderIdleTimer = $AI/WanderIdle
#
#onready var sensorFront = $AI/Front
#onready var sensorFrontLeft = $AI/FrontLeft
#onready var sensorFrontRight = $AI/FrontRight

onready var sensors = { 'front': $AI/Front,
						'left': $AI/Left,
						'right': $AI/Right,
						'front_left': $AI/FrontLeft,
						'front_right': $AI/FrontRight }

const WALK_SPEED = 30

const TURN_SPEED = 100

var motion = []
var velocity = Vector3()

const FUTILE_MOTION_TIMEOUT = 5
const FUTILE_MOTION_MIN_DISTANCE = 0.1
var futile_motion_check_timer = 0
var futile_motion_prev_location = Vector3()
var futile_motion = false

const NAVIGATE_INTERVAL = 0.1 # how often do we poll sensors and make navigational decisions?
var navigate_delta = 0

#var walk_direction = Vector2(0, 1)

func debug(text):
	DebugHandle.debug(String(text))

func _ready():
	if debug:
		DebugHandle.enable()

func die():
	#$Brie/AnimationPlayer.play("Die")
	ActionState.set_current_state("Die")
	
func gravity(delta): # drop to the ground
	move_and_collide(Vector3(0,-10*delta,0))
	

func sensor(sensor:String):
	var collision = true if sensors[sensor].is_colliding() else false
#
#	if sensors[sensor].get_overlapping_areas().size() > 0:
#		collision = true

	#debug(sensor + ": " + String(collision))
	return collision
	
func walk(delta):
	
	#var velocity2D = walk_direction * WALK_SPEED
	velocity = Vector3(0, 0, WALK_SPEED * delta).rotated(Vector3(0,1,0), self.rotation.y)
	motion = move_and_slide(velocity, Vector3(0, 1, 0))
	
	anim.play("Walk -loop")

	
func wander(delta):	
	# rotate in a random durection
	self.rotate_y(deg2rad(rand_range(1, 360)))
	# start going forward
	MovementState.set_current_state("Walk")

func navigate(delta): # avoid obstacles and getting stuck on them
	if futile_motion_prev_location.length() == 0:
		futile_motion_prev_location = global_transform.origin
	
	futile_motion_check_timer += delta
	
	if futile_motion_check_timer >= FUTILE_MOTION_TIMEOUT: # it's time to check
		futile_motion_check_timer = 0
		if (global_transform.origin - futile_motion_prev_location).length() <= FUTILE_MOTION_MIN_DISTANCE: # if we hadn't covered enough ground
			#MovementState.set_current_state(["Turn left", "Turn Right"][randi() % 2]) # let's do a random turn
			#MovementState.set_current_state("Idle") # let's do a random turn
			self.rotate_y(deg2rad(180))
			MovementState.set_current_state("Walk")
			#print("FUTILE MOTION!")
			futile_motion = true
		else:
			futile_motion = false
			futile_motion_prev_location = global_transform.origin
	
	navigate_delta += delta
	
	if not navigate_delta >= NAVIGATE_INTERVAL:
		return false
	else:
		navigate_delta = 0
	
	var f = sensor('front')
	var fl = sensor('front_left')
	var fr = sensor('front_right')
	var l = sensor('left')
	var r = sensor('right')
	
	if fl and not fr:
		MovementState.set_current_state("Turn Right")
	elif fr and not fl:
		MovementState.set_current_state("Turn Left")
	elif not fr and not fl and not f:
		MovementState.set_current_state("Walk")
	elif (fr and fl) or f:
		MovementState.set_current_state(["Turn Left", "Turn Right"][randi() % 2])
	

func turn(delta, speed, left:bool):
	if left:
		self.rotate_y(deg2rad(speed * delta))
	else:
		self.rotate_y(deg2rad(-speed * delta))

func perform_movement(delta):
	if MovementState.get_current_state(true) == "Wander":
		wander(delta)
	
	if MovementState.get_current_state(true) == "Walk":
		walk(delta)
	
	if MovementState.get_current_state(true) == "Turn Left":
		turn(delta, TURN_SPEED, true)
	
	if MovementState.get_current_state(true) == "Turn Right":
		turn(delta, TURN_SPEED, false)

func follow(delta):
	pass

func _physics_process(delta):
	
	if ActionState.get_current_state(true) == "Wander":
		navigate(delta)
		perform_movement(delta)
		gravity(delta)
	elif ActionState.get_current_state(true) == "Alert":
		MovementState.set_current_state("Idle")
		anim.play("Alert -loop")
	elif ActionState.get_current_state(true) == "Follow":
		follow(delta)
	elif ActionState.get_current_state(true) == "Attack":
		anim.play("Attack")
	elif ActionState.get_current_state(true) == "Idle":
		anim.play("Idle -loop")
	elif ActionState.get_current_state(true) == "Die":
		anim.play("Die")
		ActionState.set_current_state("Dead")
	elif ActionState.get_current_state(true) == "Dead":
		self.set_physics_process(false)
		self.set_process(false)
		$CollisionShape.disabled = true

func _process(delta):

	debug('ACTION STATE')
	debug('previous state: ' + String(ActionState.get_previous_state(true)) )
	debug('current state: ' + String(ActionState.get_current_state(true)) )
	debug('next state: ' + String(ActionState.get_next_state(true)) )
	debug('\n')
	debug('MOVEMENT STATE')
	debug('previous state: ' + String(MovementState.get_previous_state(true)) )
	debug('current state: ' + String(MovementState.get_current_state(true)) )
	debug('next state: ' + String(MovementState.get_next_state(true)) )
	debug('\n')
	
	debug("WanderIdleTimer: " + String(WanderIdleTimer.time_left) )
	#debug("rotation: " + String(to_json(walk_direction)) )
	debug("motion: " + to_json(motion))
	
	debug("futile motion check timer: " + String(futile_motion_check_timer))
	debug("futile motion: " + String(futile_motion))
	
	DebugHandle.flush_debug()	

func _on_Near_body_entered(body):
	if body.is_in_group("players"):
		#print("Player near")
		ActionState.set_current_state("Follow")


func _on_Near_body_exited(body):
	if body.is_in_group("players"):
		#print("Player near")
		ActionState.set_current_state("Follow")


func _on_Far_body_entered(body):
	if body.is_in_group("players"):
		#print("Player near")
		ActionState.set_current_state("Alert")


func _on_Far_body_exited(body):
	if body.is_in_group("players"):
		#print("Player near")
		ActionState.set_current_state("Alert")

#func _on_WanderIdle_timeout():
#	if ActionState.get_current_state(true) == "Idle":
#			ActionState.set_current_state("Wander")
#			WanderIdleTimer.start(rand_range(6, 12))
#			#wander()
#	elif ActionState.get_current_state(true) == "Wander":
#			ActionState.set_current_state("Idle")
#			WanderIdleTimer.start(rand_range(3, 6))
#			idle()

func _on_Attack_body_entered(body):
	if body.is_in_group("players"):
		ActionState.set_current_state("Attack")

func _on_Attack_body_exited(body):
	if body.is_in_group("players"):
		ActionState.set_current_state("Follow")
#
#func _input(event):
#	if Input.is_action_just_pressed("player_jump"):
#		print("Setting the state")
#		MovementState.set_current_state("Idle")
