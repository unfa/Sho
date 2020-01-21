extends Spatial

const debug = true

var near = false
var far  = false
var follow = false

var near_prev = false
var far_prev  = false

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

const WANDER_RANGE = 0.75
const WANDER_MIN_TIME = 0.25
const WANDER_MAX_TIME = 2

const UP = Vector3(0, 1, 0)

#onready var anim = $AnimationTree.get("parameters/playback")
onready var anim = $AnimationManagement/AnimationPlayer

onready var player = get_tree().get_nodes_in_group("players")[0]

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
	open = true

func update_stars():
	#print ("Stars: " + String(stars))
	
	if stars_active == 3:
		open_gate()
	
	for star in stars:
		star.mesh.surface_set_material(0, star_off)
	
	for star in stars_active:
		#print("Star " + String(star) + " is " + String(stars[star].name))
		stars[star].mesh.surface_set_material(0, star_on)
	
	#print ("---")

func collect_star():	
	if stars_active < 3:
		stars_active += 1
		update_stars()
		return true
	else:
		return false
		
func reset():
	stars_active = 0
	update_stars()
	open = false
	anim.play("Init")
		
# Called when the node enters the scene tree for the first time.
func _ready():
	#anim.start("Start")
	#anim.stop()	
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print("far: " + String(far) + " near: " + String(near))
	debug('GATE DEBUG', true)
		
	if not open:
		if far and not far_prev: # Player enters the far field
			#print("Start")
			anim.play("Start")
		
		if not far and far_prev: # Player exists the far field
			#print("End")
			#anim.travel('End')
			follow = false
		
		if near and not near_prev: # Player enters the near field
			follow = true
			anim.play("Count Stars")
	#
	#	if not near and near_prev: # Player leaves the near field
	#		pass#	
		if near or far:
			eye_blink(delta)
	
		if follow:
			eye_wander(delta)
			eye_track(delta)
			#pupil_track(delta
			eye_limit_rotation(delta)

	if Input.is_action_just_pressed("ui_page_up"):
		collect_star()
	elif Input.is_action_just_pressed("ui_home"):
		reset()
		
	if open and not open_prev:
		anim.play("Open")
		
	far_prev = far
	near_prev = near
	open_prev = open

	debug('open: ' + String(open))
	debug('open_prev: ' + String(open_prev))


func _on_Far_body_entered(body):
	if body.is_in_group("players"):
		far = true

func _on_Far_body_exited(body):
	if body.is_in_group("players"):
		far = false

func _on_Near_body_entered(body):
	if body.is_in_group("players"):
		near = true

func _on_Near_body_exited(body):
	if body.is_in_group("players"):
		near = false
