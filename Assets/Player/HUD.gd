extends Control

var debug = true

### ENVIRONMENT

onready var on_mobile = true if OS.get_name() in ['Android', 'iOS'] else false # we can use this everywhere now to check if the game is runnon on a mobile device

onready var player = get_tree().get_nodes_in_group('players')[0]

onready var background = $Background

onready var health_bar = $Display/Rows/Columns/HealthMargin/HealthBar
onready var health_tween = $Display/Rows/Columns/HealthMargin/HealthTween
onready var health_anim = $Display/Rows/Columns/HealthMargin/AnimationPlayer


onready var star_1 = $Display/Rows/Columns/StarsMargin/Stars/star_1
onready var star_2 = $Display/Rows/Columns/StarsMargin/Stars/star_2
onready var star_3 = $Display/Rows/Columns/StarsMargin/Stars/star_3

onready var stars = [star_1, star_2, star_3]

onready var stage_label = $Display/Rows/Columns/StageScoreMargin/StageScoreRows/StageLabel
onready var score_label = $Display/Rows/Columns/StageScoreMargin/StageScoreRows/ScoreLabel
onready var score_tween = $Display/Rows/Columns/StageScoreMargin/StageScoreRows/ScoreTween
onready var info_label = $Display/Rows/InfoLabelContainer/InfoLabel

var previous_score = 0
var current_score = 0
var target_score = 0

var star_on = preload("res://Assets/HUD/StarOn.png")
var star_off = preload("res://Assets/HUD/StarOff.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	if not on_mobile: # hide the touch controls if we're not running on a mobile device
		$TouchControls.hide()
	
	hide_message()
	player.connect("player_update", self, "update")
	
	health_bar.tint_over = Color.white

func update_score(score: int):
	target_score = score
	current_score = previous_score
	var score_difference = score - previous_score
	var tween_time = abs(score_difference) / 10
	
	# color tween
	score_tween.interpolate_property(score_label, "custom_colors/font_color", Color.green, Color.white, tween_time, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	
	# value tween
	score_tween.interpolate_property(self, "current_score", previous_score, target_score, tween_time, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	
	previous_score = score
	score_tween.set_active(true)

	print("SCORE UPDATE")
	
func update_health(hp: int):
	var new_color = Color.white
	var health_difference = hp - health_bar.value
	#print(health_difference)
		
	if health_difference < 0:
		new_color = Color.red
	else:
		new_color = Color.green
	
	var tween_time = abs(health_difference) / 10
	
	#print("tween_time: " + String(tween_time))

	# vibrate phones
	Input.vibrate_handheld(100)
	
	# interpolate health bar value
	health_tween.interpolate_property(health_bar, "value", health_bar.value, hp, tween_time, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	
	# interpolate color
	health_tween.interpolate_property(health_bar, "tint_progress", new_color, Color.white, tween_time, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	
	# start interpolations
	health_tween.set_active(true)
	
	if hp <= player.LOW_HP:
		health_anim.play("LowHealth")
	elif health_anim.is_playing():
		health_anim.stop()
		health_bar.tint_over = Color.white
	
func update_stage(stage: int):
	stage_label.text = 'STAGE %dd' %stage

func update_stars(star_num: int):
	#print("Player has " + String(star_num) + " stars.")

	for i in range(0, 3):
		if star_num >= i + 1:
			stars[i].texture = star_on
		else:
			stars[i].texture = star_off

# Called every frame. 'delta' is the elapsed time since the previous frame.

func display_message(message: String):
	info_label.text = message

func hide_message():
	info_label.text = ''

func _process(delta):
	if debug:
		var text =	'HUD debug\n'
		text +=		'FPS: ' + String(Engine.get_frames_per_second()) + '\n'
		$Debug/Label.text = text
	
func update():
	print ("HUD update")
	update_stars(player.stars_current)
	update_health(player.hp)
	update_score(player.score)
	#update_stars(player.stars_current)
	
func _on_ScoreTween_tween_step(object, key, elapsed, value):
	#print("Object: ", object,"\tKey: " , key)
	
	#if key == ":current_score":
	score_label.text = "SCORE: " + String(round(current_score))

func _on_Display_resized():
	#print("HUD resized")
	
	# make the background strip as wide as the screen
	if background != null:
		background.scale[1] = -OS.get_window_size()[0]
