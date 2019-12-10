extends KinematicBody

signal star_collected

const FALL_ACCEL = 50
const FALL_VELOCITY = 980
const JUMP_VELOCITY = 1050
const WALK_VELOCITY = 1000
const WALK_LERP_ACCEL = 0.1
const WALK_LERP_DECEL = 0.25
const WALK_AIR_CONTROL = 0.25

export var freeze = true

var velocity = Vector3(0, 0, 0)
var walk_velocity = Vector2(0, 0)
var walk_target_velocity = Vector2(0, 0)

var on_ground = false

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func activate():
	$Camera/AnimationPlayer.play("Begin")
	
func collect_star():
	emit_signal("star_collected")

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
	
	# check if the player feet are touching ground:

	if $Feet.get_overlapping_bodies() == []:
		on_ground = false
	else:
		on_ground = true
	
	# Walk direction
	
	if not freeze:
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
	
	if not on_ground:
		walk_lerp *= WALK_AIR_CONTROL
	
		# interpolate the walk velocity
	
	
	walk_velocity = lerp(walk_velocity, walk_target_velocity, walk_lerp)
	
	# assign the player velocity
	
	velocity[0] = walk_velocity[0]
	velocity[2] = walk_velocity[1]
	
	# apply fall velocity accelaration terminal velocity is reached
	if velocity[1] > -FALL_VELOCITY and not on_ground:
		velocity[1] = velocity[1] - FALL_ACCEL
	
	# reset the vertical velocity if we're on th ground already
	#if on_ground:
#		velocity[1] = 0

	
	if not freeze:
		if Input.is_action_just_pressed("player_jump") and on_ground:
			velocity[1] = JUMP_VELOCITY
			
	# forward movement
	#velocity[2] = 0
	
	# perform movement
	var collision = self.move_and_slide(velocity * delta)
