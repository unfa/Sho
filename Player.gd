extends KinematicBody

signal star_collected

const FALL_ACCEL = 50
const FALL_VELOCITY = 980
const JUMP_VELOCITY = 500
const JUMP_MAX_TIME = 0.25  
const JUMP_AFTERBURN = 0.25
const WALK_VELOCITY = 1000
const WALK_LERP_ACCEL = 0.1
const WALK_LERP_DECEL = 0.25
const WALK_AIR_CONTROL = 0.25

export var freeze = true

var jump_active = false
var jump_velocity = 0
var jump_time = 0
var velocity = Vector3(0, 0, 0)
var walk_velocity = Vector2(0, 0)
var walk_target_velocity = Vector2(0, 0)

var in_water = false

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func activate():
	$Camera/AnimationPlayer.play("Begin")
	
func collect_star():
	emit_signal("star_collected")

func water():
	$WaterParticles.emitting = true
	in_water = true
	$Camera/AnimationPlayer.play("Water")

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
	
	# assign the player velocity
	
	velocity[0] = walk_velocity[0]
	velocity[2] = walk_velocity[1]
	
	# apply fall velocity accelaration terminal velocity is reached
	if velocity[1] > -FALL_VELOCITY and not is_on_floor():
		velocity[1] = velocity[1] - FALL_ACCEL
	
	#jump logic
	
	if not freeze and not in_water:
			
		if jump_active:
			jump_time += delta
			jump_velocity = ( max(0, JUMP_MAX_TIME - jump_time) / JUMP_MAX_TIME ) * (JUMP_AFTERBURN * JUMP_VELOCITY)
	
		if Input.is_action_just_pressed("player_jump") and is_on_floor():
			jump_active = true
			jump_time = 0
			velocity[1] = JUMP_VELOCITY
		
		if Input.is_action_just_released("player_jump"):
			jump_active = false
			jump_velocity = 0

	if in_water:
		velocity = Vector3(0, -150, 0)

	velocity[1] += jump_velocity
	
	# perform movement
	self.move_and_slide(velocity * delta, Vector3(0, 1, 0))