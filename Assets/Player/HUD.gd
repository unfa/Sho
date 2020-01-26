extends CanvasLayer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var player = get_tree().get_nodes_in_group('players')[0]

onready var star_1 = $Stars/star_1
onready var star_2 = $Stars/star_2
onready var star_3 = $Stars/star_3

onready var stars = [star_1, star_2, star_3]

var star_on = preload("res://Assets/HUD/Star On.svg")
var star_off = preload("res://Assets/HUD/Star Off.svg")

# Called when the node enters the scene tree for the first time.
func _ready():
	player.connect("player_update", self, "update")

func update_stars(star_num: int):
	print("Player has " + String(star_num) + " stars.")

	for i in range(0, 3):
		if star_num >= i + 1:
			stars[i].texture = star_on
		else:
			stars[i].texture = star_off
		
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func update():
	print ("HUD update")
	update_stars(player.stars_current)
	
