extends KinematicBody

onready var anim = $Brie/AnimationPlayer

onready var player = get_tree().get_nodes_in_group("players")[0]
export var debug = false

var MovementState = Classes.StateMachine.new(['Stand', 'Turn Left', 'Turn Right', 'Walk'], 0)
var ActionState = Classes.StateMachine.new(['Wander', 'Alert', 'Follow', 'Attack', 'Die', 'Dead', 'Idle'], 0)

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
						'front_right': $AI/FrontRight,
						'player_sight': $AI/PlayerSight }

onready var zones = {	'alert': $AI/Alert,
						'follow': $AI/Follow,
						'attack': $AI/Attack }

const WALK_SPEED = 30
const TURN_SPEED = 100
const FOLLOW_SLERP = 2

var motion = []
var velocity = Vector3()

const FUTILE_MOTION_TIMEOUT = 5
const FUTILE_MOTION_MIN_DISTANCE = 0.1
var futile_motion_check_timer = 0
var futile_motion_prev_location = Vector3()
var futile_motion = false


onready var AttackParticles = $Brie/Armature/Skeleton/Attack/Particles
onready var AttackCollider = $Brie/Armature/Skeleton/Attack/Collider
const ATTACK_WINDUP = 0.75
const ATTACK_DURATION = 1.25
const ATTACK_COOLDOWN = 5
var attack_ready = true
var attack_connected = false

const NAVIGATE_INTERVAL = 0.1 # how often do we poll sensors and make navigational decisions?
var navigate_delta = 0

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
	return collision
	
func zone(zone:String):
	var collision = true if zones[zone].get_overlapping_bodies().size() > 0 else false
	return collision

func attack(delta):
	if attack_ready and sensor('player_sight') and ActionState.state_just_changed() and zone("attack"):
		attack_ready = false
		attack_connected = false
		MovementState.set_current_state("Stand")
		anim.play("Attack")
		
		yield(get_tree().create_timer(ATTACK_WINDUP),"timeout")
		
		AttackParticles.emitting = true
		AttackCollider.monitoring = true
		
		yield(get_tree().create_timer(ATTACK_DURATION),"timeout")
		
		AttackParticles.emitting = false
		AttackCollider.monitoring = false
		
		#$AI/Attack.monitoring = false
		yield(get_tree().create_timer(ATTACK_COOLDOWN), "timeout")
		#$AI/Attack.monitoring = true
		attack_ready = true
		ActionState.set_current_state("Attack")
	elif not sensor('player_sight') and not anim.is_playing():
		ActionState.set_current_state("Follow")
	elif not attack_ready and not anim.is_playing():
		MovementState.set_current_state("Walk")
	elif not zone("attack"):
		ActionState.set_current_state("Follow")

	#ActionState.set_current_state("Follow") # return to previous Action State
	
func walk(delta):
	
	#var velocity2D = walk_direction * WALK_SPEED
	velocity = Vector3(0, 0, - WALK_SPEED * delta).rotated(Vector3(0,1,0), self.rotation.y)
	motion = move_and_slide(velocity, Vector3(0, 1, 0))
	
	anim.play("Walk -loop")

	
func wander(delta):	
	# rotate in a random durection
	if MovementState.state_just_changed():
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
	elif MovementState.get_current_state(true) == "Stand":
		if not anim.is_playing():
			anim.play("Idle -loop")

func follow(delta):
	global_transform = global_transform.interpolate_with(global_transform.looking_at(player.global_transform.origin, Vector3.UP), FOLLOW_SLERP * delta)
	rotation.x = 0
	
	if sensor('player_sight'):
		MovementState.set_current_state("Walk")
	else:
		MovementState.set_current_state("Stand")
func _physics_process(delta):
	
#	if zone('attack'):
#		ActionState.set_current_state('Attack')
#	elif zone('follow'):
#		ActionState.set_current_state('Follow')
#	elif zone('alert'):
#		ActionState.set_current_state('Alert')
#	else:
#		ActionState.set_current_state('Wander')

	if not zone('alert') and not zone('follow') and not zone('alert'):
		ActionState.set_current_state('Wander')

		
	# manual way to rotate the enemy
	if Input.is_action_pressed("ui_page_up"):
		turn(delta, TURN_SPEED, false)
	elif Input.is_action_pressed("ui_page_down"):
		turn(delta, TURN_SPEED, true)
	
	gravity(delta)
	perform_movement(delta)
#	return
	
	if ActionState.get_current_state(true) == "Wander":
		wander(delta)
		navigate(delta)
	elif ActionState.get_current_state(true) == "Alert":
		MovementState.set_current_state("Stand")
		anim.play("Alert -loop")
	elif ActionState.get_current_state(true) == "Follow":
		follow(delta)
		#perform_movement(delta)
	elif ActionState.get_current_state(true) == "Attack":
		MovementState.set_current_state("Stand")
		attack(delta)
	elif ActionState.get_current_state(true) == "Idle":
		anim.play("Idle -loop")
		MovementState.set_current_state("Stand")
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
	
	debug('\n')
	debug("ZONES")
	debug('attack: ' + String(zone("attack")))
	debug('follow: ' + String(zone("follow")))
	debug('alert: ' + String(zone("alert")))
	
	debug('\n')
	debug('ATTACK')
	debug('attack_ready: ' + String(attack_ready))
	
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
		ActionState.set_current_state("Wander")

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


func _on_Collider_body_entered(body): 
	if body.is_in_group("players"):
		if not attack_connected: #this is the first time we're dealing damage for this attack
			body.damage(10)
			attack_connected = true
