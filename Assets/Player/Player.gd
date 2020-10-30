extends KinematicBody

signal player_update
signal player_died

onready var anim = $AnimationManagement/AnimationTree.get("parameters/playback")
onready var anim_idle = $AnimationManagement/AnimationTree.get("parameters/Idle/playback")
onready var idle_timer = $AnimationManagement/IdleTimer
onready var ground = $Ground
#onready var skeleton = $Mesh/Armature/Skeleton
onready var AttackCollider = $Mesh/Armature/Skeleton/BoneAttachment/Attack

onready var ShoMesh = $Mesh/Armature/Skeleton/Szoszyszel

onready var HitEffect = preload("res://Assets/Effects/Hit.tscn")

### Player Inventory and Health

const MAX_HP = 100
const LOW_HP = MAX_HP / 4
var hp = MAX_HP # hit points
var score = 0
var stars_current = 0
#var stars_total = 0
#var last_checkpoint

### EFFECTS

var effect_splash = preload("res://Assets/Effects/EffectWaterSplash.tscn")

const debug = true

#var DebugHandle = Debug.DebugHandle.new("Player")

#func debug(text):
#	if debug:
#		DebugHandle.debug(String(text))

### MOVEMENT

# player movement constants

const GRAVITY = -45

const AIR_CONTROL_WALK = 0.1 # multiplier for movement control when in air
const AIR_CONTROL_TURN = 0.15 # multiplier for movement control when in air

const JUMP_ACCEL = 12 # base jump velocity (will be applied verbatim, no delta)
const JUMP_AFTERBURN = 390 # jump afterburn velocity (this will be mutipleid by delta)
const JUMP_DURATION = 0.25 # maximum time that the afterburn is active

const WALK_SPEED = 1000
const TURN_SPEED = 5

const WALK_ACCEL = 15
const WALK_DECEL = 25

const MAX_GROUND_ANGLE = 50

const DEFAULT_WALK_DIRECTION = Vector2(0,-1) 

# player movement variables

var velocity = Vector3.ZERO
var walk_velocity = Vector2.ZERO
var walk_last_direction = DEFAULT_WALK_DIRECTION
var jump_accel = 0
var jump_time = 0
var jump_active = false
var jump_finished = true
var jump_base_height = 0
var jump_max_height = 0

var ground_contact = false
var ground_normal = Vector3.ZERO
var ground_angle = 0.0

var in_water = false

var movement = Vector3.ZERO

# ATTACK

const ATTACK_DURATION = 0.4

var attack = false

### Animation State Machine

#var anim_jump = false
#var anim_land = false
#var anim_run = false
#var anim_idle = false

func Vector3toString(Vector):
	return String("x: %1.2f y: %1.2f z: %1.2f" % [Vector.x, Vector.y, Vector.z])

func animation_idle():
	if not anim.get_current_node() == "Idle" and not attack:
		anim.travel("Idle")
		idle_timer.start()

func animation_blink(): # randomized blinking animation
	$AnimationManagement/RandomAnimations.play("Blink")
	$AnimationManagement/BlinkTimer.start(randf() * 7 + 3)

func check_ground(): # check if the player is in contact with the ground	
	ground_contact = true if is_on_floor() or ground.is_colliding() else false
	if ground_contact:
		ground_normal = ground.get_collision_normal()
		ground_angle = rad2deg(ground_normal.angle_to(Vector3.UP) )
	else:
		ground_normal = Vector3.ZERO
		ground_angle = 0

func jump(delta):
	if Input.is_action_just_pressed("player_jump") and ground_contact and ground_angle <= MAX_GROUND_ANGLE and not attack:
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
	
		
#	debug('jump_active: ' + String(jump_active))
#	debug('jump_finished: ' + String(jump_finished))
#	debug('jump_accel ' + String(jump_accel))
#	debug('jump_time: ' + String("%1.2f" % jump_time) )
#	debug('jump_max_height: ' + String("%1.2f" % jump_max_height) )
	
func walk(delta):
	var walk_direction = Vector2()
	var walk_rotation = 0
	var accel = 0
	var control_walk = 1
	var control_turn = 1
	var motion = false
	
	if Input.is_action_pressed("player_forward"):
		walk_direction.y -= 1
	
	if Input.is_action_pressed("player_backward"):
		walk_direction.y += 0.5
	
	if Input.is_action_pressed("player_left"):
		walk_rotation += 1
		motion = true
		#walk_direction.x += 1
	
	if Input.is_action_pressed("player_right"):
		walk_rotation -= 1
		motion = true
		#walk_direction.x -= 1
	
	if attack: # cannot walk while attacking
		walk_direction = Vector2()
	
	if walk_direction.length() > 0:
		walk_last_direction = walk_direction
		#if anim.get_current_node() != "Run":
		anim.travel("Run")
	elif motion: # if we moved in any other way
		anim_idle.travel("Idle") # reet the idle animation to the basic one
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
	
	if walk_velocity.y <= 0: # rotate the player model forward and back, but only if it's on the ground
		#$Mesh.rotation.y = ( PI * 0.5 * walk_last_direction.dot(Vector2(0,1)) ) + PI/2
		$Mesh.rotation.y = lerp_angle($Mesh.rotation.y, walk_last_direction.angle_to(Vector2.UP), 0.2)
		
#	debug('walk_direction: ' + String(walk_direction))
#	debug('walk_last_direction: ' + String(walk_last_direction))
#	debug('walk_rotation ' + String(walk_rotation))
#	debug('walk_velocity ' + String(walk_velocity))
#	debug('accel ' + String(accel))
	
func attack(delta):	
	# this is now done by the BoneAttachement node
#	if attack: # only update during attack for performance's sake
#		# put the attack hitbox where the tail is
#		var tail = skeleton.find_bone("tail_tip")
#		var tail_loc = skeleton.get_bone_global_pose(tail).origin
#		var skeleton_loc = skeleton.transform.origin
#		var target_loc = (skeleton_loc + tail_loc)
#		$Attack/CollisionShape.transform.origin = target_loc.rotated(Vector3.UP, PI)
		
	Input.action_press("camera_zoom_in")
	
	if Input.is_action_just_pressed("player_attack") and not attack:
		AttackCollider.monitoring = true
		attack = true
		anim.start("Attack") #start the animation immediately, don't wait to travel
	
		yield(get_tree().create_timer(ATTACK_DURATION), "timeout")
		AttackCollider.monitoring = false
		attack = false
		
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
	
#	debug('gravity_mode ' + gravity_mode)
	
#	if ground_contact and not is_on_floor() and (not jump_active or jump_accel < 0):
#		move_and_collide(Vector3(0,-1,0))

func move(delta): # perform movement
	movement = move_and_slide(velocity.rotated(Vector3.UP, rotation.y), Vector3.UP)
	
func sink(delta):
	movement = Vector3(0,-5,0) * delta
	global_translate(movement)
	
### HEALTH

func damage(amount = 1):
	print("Player took " + String(amount) + " damage!")
	hp = max(hp - amount, 0)
	if hp == 0:
		emit_signal('player_died')
	emit_signal("player_update")

func heal(amount = 1):
	hp = min (hp + amount, MAX_HP)
	emit_signal("player_update")
	

func _process(delta):
	var distance = get_viewport().get_camera().global_transform.origin.distance_to(self.global_transform.origin)
	var material = ShoMesh.mesh.surface_get_material(0).next_pass
	#print("material: ", material)
	
	material.set_shader_param("CameraDistance", distance)
	#print("distance: ", distance )#,"\t paremeter: ", ShoMesh.mesh.surface_get_material(0).get("shader_param/CameraDistance") )
	

func _physics_process(delta):

	# clear the debug text
#	debug('FPS ' + String(Engine.get_frames_per_second()))
	check_ground()

	if in_water:
		sink(delta)
	else:
		attack(delta)
		jump(delta)
		walk(delta)
		gravity(delta)
		move(delta)
	
	# Fix Sun light's rotation
	#print ($DirectionalLight.rotation_degrees)
	
#	debug('velocity: ' + String(velocity) )
#	debug('movement: ' + String(movement) )
#	debug('is_on_floor: ' + String(is_on_floor()) )
#	debug('ground_contact: ' + String(ground_contact) )
#	debug('ground_angle: ' + String(ground_angle) )
#
#	debug('in_water: ' + String(in_water) )
#
#	debug('anim.get_current_node(): ' + String(anim.get_current_node()) )
#	debug('anim_idle.get_current_node(): ' + String(anim_idle.get_current_node()) )
#
#	debug('attack: ' + String(attack))
#	debug('$Attack.monitoring: ' + String(AttackCollider.monitoring))
	
#	if debug:
#		DebugHandle.flush_debug()

func respawn(var checkpoint):
	# wait 1 second before respawning
	yield(get_tree().create_timer(1), "timeout")
	global_transform[3] = checkpoint.global_transform[3] # copy location
	rotation = checkpoint.rotation
	
	
	# if the player died in water, spawn droplets
	if in_water:
		$WaterDroplets2.emitting = true
		in_water = false
	
	hp = MAX_HP
	
	walk_last_direction = DEFAULT_WALK_DIRECTION
	animation_idle()
	
	emit_signal("player_update")

func increase_score(points):
	score += points
	emit_signal("player_update")

func collect_star():
	stars_current += 1
	#stars_total += 1
	emit_signal("player_update")

func loose_star():
	stars_current -= 1
	#stars_total += 1
	emit_signal("player_update")

func water():
	in_water = true
	#UI.show_info("Oops!")
	HUD.display_message("Oops!")
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
	
	emit_signal("player_update")

func idle_timeout():
	# switch to the "bored idle" animation
	anim_idle.travel("Idle2")

func _on_Attack_body_entered(body):
	if body.is_in_group("enemies"):
		body.die()
		var effect = HitEffect.instance()
		effect.global_transform.origin = AttackCollider.global_transform.origin
		get_tree().root.add_child(effect)
		

# this function activates and deactivates object that require that based on player distance
func manage_objects():
	var CULL_DIST = 60
	
	for i in get_tree().get_nodes_in_group("managed"):
		#print(" Player managing node ", i.name)
		var distance = self.global_transform.origin.distance_to(i.global_transform.origin)
		#print(" Distance is ", distance)
		
		if distance > CULL_DIST:
			if i.has_method("deactivate"):
				i.deactivate()
		else:
			if i.has_method("activate"):
				i.activate()
		

func _on_ManagementTimer_timeout():
	manage_objects() # Replace with function body.
