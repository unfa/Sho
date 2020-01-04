extends KinematicBody

signal star_collected
signal player_died

onready var UI = get_tree().get_nodes_in_group("ui")[0]
onready var anim = $Mesh/AnimationPlayer
onready var ground = $CollisionShape/Ground

var GRAVITY = Vector3(0,-980,0)

const UP = Vector3(0, 1, 0)

func debug(text, clear = false): # print on_screen dubig text
	var label = $Debug/Label # get the label node
	if clear: # flush the text if told to do so
		label.text = ''
	label.text += String(text) + '\n'

func _physics_process(delta):
	# clear the debug text
	debug('PLAYER DEBUG\n', true)
	
	var movement = move_and_slide(GRAVITY * delta, Vector3(0,1,0))
	
	debug('movement: ' + String(movement))
	debug('is_on_floor: ' + String(is_on_floor()) )


func respawn(var checkpoint):
	# wait 1 second before respawning
	yield(get_tree().create_timer(1), "timeout")
	global_transform[3] = checkpoint.global_transform[3] # copy location
	rotation = checkpoint.rotation # copy rotation

	$WaterDroplets.emitting = true
	anim.play("Idle")

func collect_star():
	emit_signal("star_collected")

func water():
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


	
#	# animation state logic
#	if state_just_jumped:
#		action = "Jump"
#		action_timeout = 0.2
#		action_blend = 0
#		state_idle = false
#		anim.stop() # cut off any currently playing animation immediately
#	elif state_just_landed:
#		action = "Land"
#		action_timeout = 0.15
#		action_blend = 0
#		state_idle = false
#		anim.stop() # cut off any currently playing animation immediately
#	elif state_midair and action_timeout == 0:
#		action = "Fly"
#		action_blend = 0.25
#		state_idle = false
#		if anim.current_animation in ["Idle", "Idle2"]: # if the current animation is an idle one - cut ot off immediately, skipping the blending time
#			anim.stop()
#	elif state_running and action_timeout == 0:
#		action = "Run"
#		action_blend = 0.1
#		state_idle = false
#		if anim.current_animation in ["Idle", "Idle2"]: # if the current animation is an idle one - cut ot off immediately, skipping the blending time
#			anim.stop()
#	elif state_idle and idle_time > 15:
#		action = "Idle2"
#		action_blend = 1
#	elif not state_running and action_timeout == 0:
#		if not state_idle_previously:
#			idle_time = 0
#		state_idle = true
#		action = "Idle"
#		action_blend = 0.25
#
#	#print("Action: ", action, " Timeout: ", action_timeout, " Idle time: ", idle_time)
#
#	anim.play(action, action_blend)
