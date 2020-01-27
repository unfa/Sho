extends KinematicBody

onready var anim = $Brie/AnimationPlayer

onready var player = get_tree().get_nodes_in_group("players")[0]

export var debug = false

var BrieState = Classes.StateMachine.new(['Idle', 'Wander', 'Turn Left', 'Turn Right', 'Walk', 'Alert', 'Follow', 'Attack', 'Die', 'Dead'], 0)
var DebugHandle = Debug.DebugHandle.new("brie")

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
	$Brie/AnimationPlayer.play("Die")
	
func gravity(delta): # drop to the ground
	move_and_collide(Vector3(0,-10*delta,0))
	
func idle():
	anim.play("Idle -loop")

func sensor(sensor:String):
	var collision = true if sensors[sensor].is_colliding() else false
#
#	if sensors[sensor].get_overlapping_areas().size() > 0:
#		collision = true

	debug(sensor + ": " + String(collision))
	return collision
	
func walk(delta):
	
	#var velocity2D = walk_direction * WALK_SPEED
	velocity = Vector3(0, 0, WALK_SPEED * delta).rotated(Vector3(0,1,0), self.rotation.y)
	motion = move_and_slide(velocity, Vector3(0, 1, 0))
	
	anim.play("Walk -loop")

	
func wander(delta):	
	self.rotate_y(deg2rad(rand_range(1, 360)))
	BrieState.set_current_state("Walk")

func navigate(delta):
	
	if futile_motion_prev_location.length() == 0:
		futile_motion_prev_location = global_transform.origin
	
	futile_motion_check_timer += delta
	
	if futile_motion_check_timer >= FUTILE_MOTION_TIMEOUT: # it's time to check
		futile_motion_check_timer = 0
		if (global_transform.origin - futile_motion_prev_location).length() <= FUTILE_MOTION_MIN_DISTANCE: # if we hadn't covered enough ground
			#BrieState.set_current_state(["Turn left", "Turn Right"][randi() % 2]) # let's do a random turn
			#BrieState.set_current_state("Idle") # let's do a random turn
			self.rotate_y(deg2rad(180))
			BrieState.set_current_state("Walk")
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
		BrieState.set_current_state("Turn Right")
	elif fr and not fl:
		BrieState.set_current_state("Turn Left")
	elif not fr and not fl and not f:
		BrieState.set_current_state("Walk")
	elif (fr and fl) or f:
		BrieState.set_current_state(["Turn left", "Turn Right"][randi() % 2])
	
#	if not f and not fl and not fr:
#		BrieState.set_current_state("Walk")
#	elif f:
#		BrieState.set_current_state(["Turn left", "Turn Right"][randi() % 2])
#	elif fl and fr:
#		BrieState.set_current_state(["Turn left", "Turn Right"][randi() % 2])
#	elif fl or l:
#		BrieState.set_current_state("Turn Right")
#	elif fr or r:
#		BrieState.set_current_state("Turn Left")

	

#	if not f: 
#		BrieState.set_current_state("Walk")
#	elif motion:
#		self.rotate_y(deg2rad(180))
#	elif fl or l:
#		BrieState.set_current_state("Turn Right")
#	elif fr or r:
#		BrieState.set_current_state("Turn Left")
#	elif f:
#		BrieState.set_current_state(["Turn left", "Turn Right"][randi() % 2])


func turn(delta, speed, left:bool):
	if left:
		self.rotate_y(deg2rad(speed * delta))
	else:
		self.rotate_y(deg2rad(-speed * delta))

func _physics_process(delta):
	navigate(delta)
	gravity(delta)
	
	if BrieState.get_current_state(true) == "Wander":
		wander(delta)
	
	if BrieState.get_current_state(true) == "Walk":
		walk(delta)
	
	if BrieState.get_current_state(true) == "Turn Left":
		turn(delta, TURN_SPEED, true)
	
	if BrieState.get_current_state(true) == "Turn Right":
		turn(delta, TURN_SPEED, false)


func _process(delta):
	debug('previous state: ' + String(BrieState.get_previous_state(true)) )
	debug('current state: ' + String(BrieState.get_current_state(true)) )
	debug('next state: ' + String(BrieState.get_next_state(true)) )
		
	debug("WanderIdleTimer: " + String(WanderIdleTimer.time_left) )
	#debug("rotation: " + String(to_json(walk_direction)) )
	debug("motion: " + to_json(motion))
	
	debug("futile motion check timer: " + String(futile_motion_check_timer))
	debug("futile motion: " + String(futile_motion))
	
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
			#wander()
	elif BrieState.get_current_state(true) == "Wander":
			BrieState.set_current_state("Idle")
			WanderIdleTimer.start(rand_range(3, 6))
			idle()
