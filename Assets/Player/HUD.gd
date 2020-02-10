extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var player = get_tree().get_nodes_in_group('players')[0]

onready var health_bar = $Display/Rows/Columns/HealthMargin/HealthBar

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
	hide_message()
	player.connect("player_update", self, "update")
	
func update_health(hp: int):
	health_bar.value = hp
	
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
	
