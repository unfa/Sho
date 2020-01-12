extends KinematicBody

signal star_collected
signal player_died

onready var UI = get_tree().get_nodes_in_group("ui")[0]
onready var anim = $AnimationManagement/AnimationTree.get("parameters/playback")
onready var anim_idle = $AnimationManagement/AnimationTree.get("parameters/Idle/playback")
onready var idle_timer = $AnimationManagement/IdleTimer
onready var ground = $Ground

### EFFECTS

var effect_splash = preload("res://EffectWaterSplash.tscn")

### MOVEMENT

# player movement constants

const GRAVITY = -45
const UP = Vector3(0, 1, 0)

const AIR_CONTROL_WALK = 0.05 # multiplier for movement control when in air
const AIR_CONTROL_TURN = 0.1 # multiplier for movement control when in air

const JUMP_ACCEL = 12 # base jump velocity (will be applied verbatim, no delta)
const JUMP_AFTERBURN = 400 # jump afterburn velocity (this will be mutipleid by delta)
const JUMP_DURATION = 0.25 # maximum time that the afterburn is active

const WALK_SPEED = 1000
const TURN_SPEED = 5

const WALK_ACCEL = 15
const WALK_DECEL = 25

const MAX_GROUND_ANGLE = 30

# player movement variables

var velocity = Vector3()
var walk_velocity = Vector2()
var walk_last_direction = Vector2(0, 1)
var jump_accel = 0
var jump_time = 0
var jump_active = false
var jump_finished = true
var jump_base_height = 0
var jump_max_height = 0

var ground_contact = false
var ground_normal = Vector3()
var ground_angle = 0.0

var in_water = false

var movement = Vector3()

### Animation State Machine

#var anim_jump = false
#var anim_land = false
#var anim_run = false
#var anim_idle = false

func Vector3toString(Vector):
	return String("x: %1.2f y: %1.2f z: %1.2f" % [Vector.x, Vector.y, Vector.z])

func debug(text, clear = false): # print on_screen dubig text
	var label = $Debug/Label # get the label node
	
	if clear: # flush the text if told to do so
		label.text = ''
		
	label.text += String(text) + '\n'

func animation_idle():
	if not anim.get_current_node() == "Idle":
		anim.travel("Idle")
		idle_timer.start()

func animation_blink(): # randomized blinking animation
	$AnimationManagement/RandomAnimations.play("Blink")
	$AnimationManagement/BlinkTimer.start(randf() * 7 + 3)

func check_ground(): # check if the player is in contact with the ground	
	ground_contact = true if is_on_floor() or ground.is_colliding() else false
	if ground_contact:
		ground_normal = ground.get_collision_normal()
		ground_angle = rad2deg(ground_normal.angle_to(UP) )
	else:
		ground_normal = Vector3()
		ground_angle = 0

func jump(delta):
	if Input.is_action_just_pressed("player_jump") and ground_contact and ground_angle <= MAX_GROUND_ANGLE:
		jump_active = true
		jump_finished = false
		jump_accel = 0
		jump_time = 0
		
		anim.travel("Jump")
	
	if Input.is_action_just_released("player_jump"):
		# terminate jump immediately
		jump_active = false
		jump_accel = 0
	
	if not jump_active and is_on_floor():
		jump_finished = true
	
	if jump_active:
		if jump_time == 0: # apply initial kick
			jump_max_height = 0
			jump_base_height = global_transform[3].y
			jump_accel = JUMP_ACCEL
			velocity.y = jump_accel
		elif jump_time > 0: # apply afereburn
			jump_accel = lerp(0, JUMP_AFTERBURN, JUMP_DURATION - jump_time)
			velocity.y += jump_accel * delta
			
		# accumulate jump time
		jump_time = min (jump_time + delta, JUMP_DURATION)
		
		# end jump if it exceeds duration
		if jump_time == JUMP_DURATION:
			jump_active = false
			jump_accel = 0
	
	jump_max_height = max (jump_max_height, global_transform[3].y - jump_base_height)
	
		
	debug('jump_active: ' + String(jump_active))
	debug('jump_finished: ' + String(jump_finished))
	debug('jump_accel ' + String(jump_accel))
	debug('jump_time: ' + String("%1.2f" % jump_time) )
	debug('jump_max_height: ' + String("%1.2f" % jump_max_height) )
	
func walk(delta):
	var walk_direction = Vector2()
	var walk_rotation = 0
	var accel = 0
	var control_walk = 1
	var control_turn = 1
	
	if Input.is_action_pressed("player_forward"):
		walk_direction.y += 1
	
	if Input.is_action_pressed("player_backward"):
		walk_direction.y -= 1
	
	if Input.is_action_pressed("player_left"):
		walk_rotation += 1
	
	if Input.is_action_pressed("player_right"):
		walk_rotation -= 1
	
	if walk_direction.length() > 0:
		walk_last_direction = walk_direction
		#if anim.get_current_node() != "Run":
		anim.travel("Run")
	else:# anim.get_current_node() != "Idle":
		animation_idle()
	
	if walk_velocity.dot(walk_direction) > 0: # check if we're speeding up or slowing down
		accel = WALK_ACCEL
	else:
		accel = WALK_DECEL
	
	if not ground_contact:
		control_walk *= AIR_CONTROL_WALK
		control_turn *= AIR_CONTROL_TURN
	
	walk_velocity = lerp(walk_velocity, walk_direction * WALK_SPEED, accel * control_walk * delta)
	
	velocity.x = walk_velocity.x * delta
	velocity.z = walk_velocity.y * delta
	
	rotate_y(walk_rotation * TURN_SPEED * control_turn * delta)
	
	if ground_contact: # rotate the player model forward and back, but only if it's on the ground
		$Mesh.rotation.y = ( PI * 0.5 * walk_last_direction.dot(Vector2(0,1)) ) + PI/2
		
	debug('walk_direction: ' + String(walk_direction))
	debug('walk_last_direction: ' + String(walk_last_direction))
	debug('walk_rotation ' + String(walk_rotation))
	debug('walk_velocity ' + String(walk_velocity))
	debug('accel ' + String(accel))
	
	
func gravity(delta):
	var gravity_mode = ""
	if ground_contact and jump_finished:
		if ground_angle <= MAX_GROUND_ANGLE and walk_velocity.length() < 0.1:
			velocity.y = 0
			#move_and_collide(Vector3(0,-1,0)) # snap to the ground
			gravity_mode = 'stand'
		elif not is_on_floor(): # if we're floating above the ground
			move_and_collide(Vector3(0,-1,0)) # snap to the ground
			gravity_mode = 'snap'
		else: # if we're standing on the ground
			velocity.y = GRAVITY * delta # apply minimal gravity
			gravity_mode = 'slide'
	else: # if we're during a jump or otherwis mid-air:
		velocity.y += GRAVITY * delta # acculumate gravity to accelerate naturally
		gravity_mode = 'fall'
		
		anim.travel("Fly")
	
	debug('gravity_mode ' + gravity_mode)
	
#	if ground_contact and not is_on_floor() and (not jump_active or jump_accel < 0):
#		move_and_collide(Vector3(0,-1,0))

func move(delta): # perform movement
	movement = move_and_slide(velocity.rotated(UP, rotation.y), UP)
	
func sink(delta):
	movement = Vector3(0,-5,0) * delta
	global_translate(movement)

func _physics_process(delta):
	# clear the debug text
	debug('FPS ' + String(Engine.get_frames_per_second()), true)
	check_ground()

	if in_water:
		sink(delta)
	else:
		jump(delta)
		walk(delta)
		gravity(delta)
		move(delta)
	
	
	debug('velocity: ' + String(velocity) )
	debug('movement: ' + String(movement) )
	debug('is_on_floor: ' + String(is_on_floor()) )
	debug('ground_contact: ' + String(ground_contact) )
	debug('ground_angle: ' + String(ground_angle) )
	
	debug('in_water: ' + String(in_water) )
	
	debug('anim.get_current_node(): ' + String(anim.get_current_node()) )
	debug('anim_idle.get_current_node(): ' + String(anim_idle.get_current_node()) )

func respawn(var checkpoint):
	# wait 1 second before respawning
	yield(get_tree().create_timer(1), "timeout")
	global_transform[3] = checkpoint.global_transform[3] # copy location
	rotation = checkpoint.rotation # copy rotation
	
	in_water = false
	
	walk_last_direction = Vector2(0,1)
	
	$WaterDroplets.emitting = true
	animation_idle()

func collect_star():
	emit_signal("star_collected")

func water():
	in_water = true
	UI.show_info("Oops!")
	var splash_instance = effect_splash.instance()
	splash_instance.set_name("splash")
	splash_instance.global_transform[3] = global_transform[3]
	get_tree().root.add_child(splash_instance)
	
	emit_signal("player_died")
	#$Camera/AnimationPlayer.play("Water")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var anim_player = $Mesh/AnimationPlayer
	var animations = ['Run', 'Idle', 'Idle2', 'Fly']
	
	for animation in animations:
		animation = anim_player.get_animation(animation)	
		animation.loop = true

func idle_timeout():
	# switch to the "bored idle" animation
	anim_idle.travel("Idle2")
