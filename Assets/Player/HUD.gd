extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

### ENVIRONMENT

onready var on_mobile = true if OS.get_name() in ['Android', 'iOS'] else false # we can use this everywhere now to check if the game is runnon on a mobile device

onready var player = get_tree().get_nodes_in_group('players')[0]

onready var health_bar = $Display/Rows/Columns/HealthMargin/HealthBar
onready var health_tween = $Display/Rows/Columns/HealthMargin/Tween

onready var star_1 = $Display/Rows/Columns/StarsMargin/Stars/star_1
onready var star_2 = $Display/Rows/Columns/StarsMargin/Stars/star_2
onready var star_3 = $Display/Rows/Columns/StarsMargin/Stars/star_3

onready var stars = [star_1, star_2, star_3]

onready var stage_label = $Display/Rows/Columns/StageLabelMargin/StageLabel
onready var info_label = $Display/Rows/InfoLabelContainer/InfoLabel


var star_on = preload("res://Assets/HUD/StarOn.png")
var star_off = preload("res://Assets/HUD/StarOff.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	if not on_mobile: # hide the touch controls if we're not running on a mobile device
		$TouchControls.hide()
	
	hide_message()
	player.connect("player_update", self, "update")
	
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
	
	health_bar.value = hp
	
	Input.vibrate_handheld(100)
	
	health_tween.interpolate_property(health_bar, "tint_progress", new_color, Color.white, tween_time, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	health_tween.set_active(true)
	
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
	pass
	
func update():
	print ("HUD update")
	update_stars(player.stars_current)
	update_health(player.hp)
	#update_stars(player.stars_current)
	
