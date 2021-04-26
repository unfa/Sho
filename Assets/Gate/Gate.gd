extends Spatial

signal SpawnMap # when we need to spawn new level
signal FreeMap # When we can free previous level
signal LoadMap # when player reaches 3 stars

enum GateType {GATE_ENTRY, GATE_EXIT}
export (GateType) var gate_type = 0
# export (String, FILE, "*.tscn") var target_scene

var gate_state = Classes.StateMachine.new(['Sleep', 'Start', 'Awake', 'Collect', 'Reject', 'Open', 'Opened', 'Through', 'Closed'], 0)

var debug = false

#var MapLoader

var next_scene
var next_scene_ready = false
var next_scene_loading = false
#var near = false
#var far  = false
#var follow = false
#
#
#var near_prev = false
#var far_prev  = false

var look_target_current = Vector3()
var look_target = Vector3()

var wander_time = 0
var wander_next = 0
var wander_offset = Vector3()

const BLINK_MIN_TIME = 4
const BLINK_MAX_TIME = 9

var blink_time = 0
var blink_next = 0

var open = false
var open_prev = false

var close = false
var close_prev = false

var reject = false
var reject_prev = false

var collect = false
var collect_prev = false

const WANDER_RANGE = 0.75
const WANDER_MIN_TIME = 0.25
const WANDER_MAX_TIME = 2

const UP = Vector3(0, 1, 0)

#onready var anim = $AnimationTree.get("parameters/playback")
onready var anim = $AnimationManagement/AnimationPlayer
onready var trigger_near = $Near
onready var trigger_far = $Far
onready var trigger_through = $Through

onready var player = get_tree().get_nodes_in_group("players")[0]
onready var camera = get_tree().get_nodes_in_group("camera_bodies")[0]

onready var eyeball = $Gate/Eyeball
onready var lid_top = $"Gate/Eye Lid Top"
onready var lid_bot = $"Gate/Eye Lid Bottom"

onready var star1 = $Gate/Star1
onready var star2 = $Gate/Star2
onready var star3 = $Gate/Star3

var star_on = preload("res://Assets/Gate/Gate Star On.material")
var star_off = preload("res://Assets/Gate/Gate Star Off.material")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var stars = [star1, star2, star3]
var stars_active = 0

func debug(text, clear = false): # print on_screen dubig text
	var label = $Debug/Label # get the label node
	if not debug:
		label.hide()
		return 1

	
	if clear: # flush the text if told to do so
		label.text = ''
		
	label.text += String(text) + '\n'

func open_gate():
	print("open_gate")
#	while not next_scene_ready:
#		print("waiting for scene to be ready")
#		yield(get_tree().create_timer(1), "timeout")
	
	#next_scene_instance.set_process(true)		
	anim.play("Open")
#	print("show scene")
#	next_scene.show()
	
	emit_signal("SpawnMap")
	
	open = true

func update_stars():
	#print ("Stars: " + String(stars))
	
	if stars_active == 3:
		gate_state.set_current_state("Open")
	
	for star in stars:
		star.mesh.surface_set_material(0, star_off)
	
	for star in stars_active:
		#print("Star " + String(star) + " is " + String(stars[star].name))
		stars[star].mesh.surface_set_material(0, star_on)
	
	#print ("---")

func reject():
	yield(get_tree().create_timer(2), "timeout")
	anim.play("Reject")
	reject = true

func collect_all_stars():
	collect = true
	anim.play("Collect Star")

func collect_star():
	if gate_state.get_current_state(true) == "Collect":
		if player.stars_current > 0 and stars_active < 3:
			player.loose_star()
			stars_active += 1
			#anim.get_animation("Collect Star").loop = true
			update_stars()
			return true
		elif player.stars_current == 0 and stars_active < 3:
			anim.play("Reject")
			gate_state.set_current_state("Reject")
		elif stars_active == 3:
			anim.play("Open")
			gate_state.set_current_state("Open")
#	elif gate_state.get_current_state(true) == "Reject":
#
#		return false
			
func reset():
	stars_active = 0
	update_stars()
	open = false
	close = false
	anim.play("Init")


#func load_map():
#
#	if gate_type != GateType.GATE_EXIT:
#		# only exit gates should do this
#		return 1
#
#	if next_scene_loading or next_scene_ready:
#		# we don't want to spawn more than one instances of the new level
#		return 2
#
#	next_scene_loading = true
#
#	print("Load map function")
#
#	#target_scene = "res://Maps/01.tscn"
#
#	print("Target scene: ", target_scene)
#
#	next_scene = load(target_scene).instance()
#
#	print("Next scene: ", next_scene)
#
#	var exit_transform = global_transform
#
#	#get_tree().root.call_deferred("add_child", next_scene)
#	get_tree().root.add_child(next_scene)
#	#yield(get_tree().root.call_deferred("add_child", next_scene), "completed")
#
#	next_scene.set_process(false)
#	next_scene.set_physics_process(false)
#	next_scene.hide()
#
#	# remove extra entry gate
#	var new_entry = next_scene.find_node("Entry*")
#	var entry_transform = new_entry.global_transform
#	new_entry.queue_free()
#
#	var location_offset = exit_transform.origin - entry_transform.origin
#	#var rotation_offset = exit_transform.basis.get_euler() - entry_transform.basis.get_euler()
#
#	next_scene.global_translate(location_offset)
#	#next_scene.global_rotate(rotation_offset)
#	next_scene_ready = true

func monitor_player_stars():
	if player.stars_current == 3 and not next_scene_loading:
		#print ("map loader started")
		emit_signal("LoadMap")
		next_scene_loading = true

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# if this is an entry gate, let's stop it
	if gate_type == GateType.GATE_ENTRY:
		set_process(false)
		return 0
	
	player.connect("player_update", self, "monitor_player_stars")
	update_stars()

func eye_track(delta):
	eyeball.look_at(look_target, Vector3(0, 1, 0))
	eyeball.rotate_object_local(Vector3(1,0,0), -PI/2)

func eye_blink(delta):
	blink_time += delta
	
	if blink_time > blink_next and not anim.is_playing():
		anim.play("Blink")
		blink_next += rand_range(BLINK_MIN_TIME, BLINK_MAX_TIME)
		
func eye_limit_rotation(delta):
	#print(eyeball.rotation_degrees)
	eyeball.rotation_degrees.x = min(eyeball.rotation_degrees.x, -40)
	#eyeball.rotation_degrees.y = min(eyeball.rotation_degrees.x, 50)

func eye_wander(delta):
	wander_time += delta
	
	if wander_time > wander_next:
		wander_offset = Vector3(rand_range(-WANDER_RANGE, WANDER_RANGE), rand_range(-WANDER_RANGE, WANDER_RANGE), rand_range(-WANDER_RANGE, WANDER_RANGE))
		wander_next += rand_range(WANDER_MIN_TIME, WANDER_MAX_TIME)
		
	look_target_current = player.global_transform.origin + Vector3(0, 3, 0) + wander_offset
	look_target = look_target.linear_interpolate(look_target_current, 15 * delta)
	
	
func pupil_track(delta):
	#print (eyeball.global_transform.origin.distance_to(look_target))
	pass

func advance_state():
	gate_state.advance_state()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print("far: " + String(far) + " near: " + String(near))
	debug('GATE DEBUG', true)
		
	if gate_state.get_current_state(true) == "Sleep":
		anim.play("Init")
		camera.snap(false)
	elif gate_state.get_current_state(true) == "Start": # AWAKE
		if not anim.is_playing():
			anim.play("Start")
			#gate_state.queue_state("Awake")
			gate_state.set_current_state("Awake")
			#print("play start")
	elif gate_state.get_current_state(true) == "Awake":
		eye_blink(delta)
		#camera.snap(true)
	elif gate_state.get_current_state(true) == "Collect": # COLLECT
		eye_wander(delta)
		eye_track(delta)
		eye_blink(delta)
		eye_limit_rotation(delta)
		anim.play("Collect Star")
		camera.snap(true, $Camera.global_transform)
	elif gate_state.get_current_state(true) == "Reject": # REJECT
		eye_track(delta)
		eye_wander(delta)
		eye_limit_rotation(delta)
	elif gate_state.get_current_state(true) == "Open": # OPEN
		open_gate()
		gate_state.set_current_state("Opened")
	elif gate_state.get_current_state(true) == "Opened": # OPENED
		#pass
		camera.snap(false)
	elif gate_state.get_current_state(true) == "Through":  # THROUGH
		anim.play("Close")
		camera.snap(false)
		gate_state.set_current_state("Closed")
	elif gate_state.get_current_state(true) == "Closed":
		anim.queue("Init")
		emit_signal("FreeMap")
		set_process(false) # stop processing this gate - it will not be used any more
		pass


	debug('previous state: ' + String(gate_state.get_previous_state(true)) )
	debug('current state: ' + String(gate_state.get_current_state(true)) )
	debug('next state: ' + String(gate_state.get_next_state(true)) )
	
#	if next_scene_loading and next_scene:
#		debug('Next scene\'s parent:', next_scene.get_parent())


func _on_Far_body_entered(body):
	if body.is_in_group("players") and gate_state.get_current_state(true) == "Sleep":
		gate_state.set_current_state("Start")

func _on_Far_body_exited(body):
	if body.is_in_group("players") and not gate_state.get_current_state(true) in ["Through", "Closed", "Open", "Opened"]:
		gate_state.set_current_state("Sleep")

func _on_Near_body_entered(body):
	if body.is_in_group("players") and not gate_state.get_current_state(true) in ["Reject", "Open", "Opened", "Through", "Closed"]:
		gate_state.set_current_state("Collect")
	# snap camera only in these states	

func _on_Near_body_exited(body):
	if body.is_in_group("players") and gate_state.get_current_state(true) == "Collect":
		gate_state.set_current_state("Awake")
		camera.snap(false)

func _on_CloseTrigger_body_entered(body):
	if body.is_in_group("players") and gate_state.get_current_state(true) in ["Open", "Opened"]:
		gate_state.set_current_state("Through")
		camera.snap(false)
