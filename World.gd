extends Node

onready var environment = $WorldEnvironment
onready var sun = $Sun
onready var tween = $Tween

onready var menu = get_tree().root.find_node("Menu", true, false)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const SUN_ENERGY = 1.5
const BACKGROUND_ENERGY = 1
const FOG_COLOR = Color("#588493")
const FADE_TIME = 3

func indoors():
	tween.interpolate_property(environment.environment, "background_energy", environment.environment.background_energy, 0.02, FADE_TIME,Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.interpolate_property(environment.environment, "fog_color", environment.environment.fog_color, FOG_COLOR * 0.1, FADE_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.interpolate_property(sun, "light_energy", sun.light_energy, 0, FADE_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.set_active(true)

func outdoors():
	tween.interpolate_property(environment.environment, "background_energy", environment.environment.background_energy, BACKGROUND_ENERGY, FADE_TIME,Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.interpolate_property(environment.environment, "fog_color", environment.environment.fog_color, FOG_COLOR, FADE_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.interpolate_property(sun, "light_energy", sun.light_energy, SUN_ENERGY, FADE_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.set_active(true)

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	var HUD = get_tree().root.find_node("HUD")
	if HUD != null:
		HUD.show()
	#get_tree().root.find_node("HUD").show()
	Config.visuals_update()
	#Config.connect("visuals_config_updated", self, "visuals_update")
	
func _input(event):
	# TODO - make this pause the game and open pause menu instead
	if Input.is_action_pressed("ui_cancel"):
		get_tree().root.find_node("HUD").hide()
		menu.show()
		menu.find_node("Resume", true, false).show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true
	
	get_tree().set_input_as_handled()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
