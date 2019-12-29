extends KinematicBody

signal star_collected
signal player_died

onready var UI = get_tree().get_nodes_in_group("ui")[0]

onready var anim = $Mesh/AnimationPlayer
var action = ""
var action_blend = 0
var action_timeout = 0
var idle_time = 0

const FALL_ACCEL = 50
const FALL_VELOCITY = 980
const JUMP_VELOCITY = 500
const JUMP_MAX_TIME = 0.25  
const JUMP_AFTERBURN = 0.25
const WALK_VELOCITY = 1000
const WALK_LERP_ACCEL = 0.1
const WALK_LERP_DECEL = 0.25
const WALK_AIR_CONTROL = 0.25

const WALK_VELOCITY_DEFAULT = Vector2(0, -1) 

var freeze = true

var jump_active = false
var jump_velocity = 0
var jump_time = 0
var velocity = Vector3(0, 0, 0)
var walk_velocity = WALK_VELOCITY_DEFAULT # the initial value ensures the player model is going to spawn facing the camera
var walk_target_velocity = Vector2(0, 0)

#animation state machine

var state_just_jumped = false
var state_midair = false
var state_just_landed = false
var state_midair_previously = false
var state_running = false
var state_idle = false
var state_idle_previously = false

# for calculating visual direction of the player model	
var mesh_direction = 0

var in_water = false

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func activate():
	freeze = false

func respawn(var checkpoint):
	
	# wait 1 secnd before respawning
	yield(get_tree().create_timer(1), "timeout")

	global_transform[3] = checkpoint.global_transform[3]
	freeze = false
	in_water = false
	velocity = Vector3(0, 0, 0)
	walk_velocity = WALK_VELOCITY_DEFAULT # reset the walk_velocity so the player model respawns facing the camera
	
	anim.play("Idle")

func collect_star():
	emit_signal("star_collected")

func water():
	emit_signal("player_died")
	in_water = true
	freeze = true
	UI.show_info("Oops!")
	
	#var water_splash_instance = water_splash.instance()
	#water_splash_instance.global_transform[3] = global_transform[3]
	#get_tree().root.add_child(water_splash_instance)
	#add_child(water_splash_instance)
	
	var splash = preload("res://EffectWaterSplash.tscn")
	var splash_instance = splash.instance()
	splash_instance.set_name("splash")
	splash_instance.global_transform[3] = global_transform[3]
	get_tree().root.add_child(splash_instance)
	

	#$Camera/AnimationPlayer.play("Water")

# Called when the node enters the scene tree for the first time.
#func _ready():
	#pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	# initialize local vars
		
	var walk_direction = Vector2(0, 0)
	var walk_lerp = 1
	
	# Walk direction
	
	if not freeze and not in_water:
		if Input.is_action_pressed("player_forward"):
			walk_direction += Vector2(0, 1)
		
		if Input.is_action_pressed("player_backward"):
			walk_direction += Vector2(0, -1)
			
		if Input.is_action_pressed("player_left"):
			walk_direction += Vector2(1, 0)
		
		if Input.is_action_pressed("player_right"):
			walk_direction += Vector2(-1, 0)
		
	# animation state machine
	if walk_direction.length() > 0:
		state_running = true
	else:
		state_running = false	
	
	# calculate target velocity
	
	walk_target_velocity = walk_direction.normalized() * WALK_VELOCITY
		
	# check if the player is speedin up or slowing down and use approprate lerping factor
		
	if walk_velocity.dot(walk_target_velocity) > 0:
		walk_lerp = WALK_LERP_ACCEL
	else:
		walk_lerp = WALK_LERP_DECEL
	
	# air control affects the walk lerp factor
	
	if not is_on_floor():
		walk_lerp *= WALK_AIR_CONTROL
	
	# interpolate the walk velocity
	
	walk_velocity = lerp(walk_velocity, walk_target_velocity, walk_lerp)

	#$Mesh.rotation = Vector3(0,0,0)

	# calculate the radians of the actual movement XZ vector
	mesh_direction = Vector2(0,0).direction_to(walk_velocity).angle()
	# apply mesh rotation based on that. This was made mostly via trial and error. Don't touch. It's magic.
	$Mesh.rotation = Vector3(0,-mesh_direction-PI/2,0)
	
	# assign the player velocity
	
	velocity[0] = walk_velocity[0]
	velocity[2] = walk_velocity[1]
	
	# apply fall velocity accelaration terminal velocity is reached
	if velocity[1] > -FALL_VELOCITY and not is_on_floor():
		velocity[1] = velocity[1] - FALL_ACCEL
	
	# this fixes player glitching on the floor. For some reason if the velocity is made zero, some weird toggling occurs in velocity[1], which may potentially cause glitches
	# it also breaks slopes, so TODO fix this
	if is_on_floor() and not jump_active:
		velocity[1] = - FALL_ACCEL * 0.001
	
	#print(velocity)
	
	#jump logic
	
	state_just_jumped = false
	
	if not freeze and not in_water:
			
		if jump_active:
			jump_time += delta
			jump_velocity = ( max(0, JUMP_MAX_TIME - jump_time) / JUMP_MAX_TIME ) * (JUMP_AFTERBURN * JUMP_VELOCITY)
	
		if Input.is_action_just_pressed("player_jump") and is_on_floor():
			jump_active = true
			jump_time = 0
			velocity[1] = JUMP_VELOCITY
			
			state_just_jumped = true
		
		if Input.is_action_just_released("player_jump"):
			jump_active = false
			jump_velocity = 0

	if in_water: #sinking in water
		velocity = Vector3(0, -150, 0)
	
	if state_midair_previously and not state_midair:
			state_just_landed = true
	else:
		state_just_landed = false
		
	state_midair_previously = state_midair
		
	if is_on_floor():
		state_midair = false
	else:
		state_midair = true
	
		
#	if is_on_floor():
#		velocity[1] = -FALL_VELOCITY * 0.001

	velocity[1] += jump_velocity
	
	# perform movement
	self.move_and_slide(velocity * delta, Vector3(0, 1, 0))
	
	if action_timeout > 0:
		action_timeout = max (action_timeout - delta, 0)
	
	if state_idle:
		idle_time += delta
	else:
		idle_time = 0
	
	state_idle_previously = state_idle
		
	# animation state logic
	if state_just_jumped:
		action = "Jump"
		action_timeout = 0.2
		action_blend = 0
		state_idle = false
	elif state_just_landed:
		action = "Land"
		action_timeout = 0.15
		action_blend = 0
		state_idle = false
	elif state_midair and action_timeout == 0:
		action = "Fly"
		action_blend = 0.25
		state_idle = false
	elif state_running and action_timeout == 0:
		action = "Run"
		action_blend = 0.1
		state_idle = false
	elif state_idle and idle_time > 15:
		action = "Idle2"
		action_blend = 1
	elif not state_running and action_timeout == 0:
		if not state_idle_previously:
			idle_time = 0
		state_idle = true
		action = "Idle"
		action_blend = 0.25

	print("Action: ", action, " Timeout: ", action_timeout, " Idle time: ", idle_time)
		
	anim.play(action, action_blend)
