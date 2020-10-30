extends Node

onready var environment = $WorldEnvironment
onready var sun = $Sun
onready var tween = $Tween
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const SUN_ENERGY = 1.5
const BACKGROUND_ENERGY = 1

const FADE_TIME = 3

func indoors():
	tween.interpolate_property(environment.environment, "background_energy", environment.environment.background_energy, 0.02, FADE_TIME,Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.interpolate_property(sun, "light_energy", sun.light_energy, 0, FADE_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.set_active(true)

func outdoors():
	tween.interpolate_property(environment.environment, "background_energy", environment.environment.background_energy, BACKGROUND_ENERGY, FADE_TIME,Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.interpolate_property(sun, "light_energy", sun.light_energy, SUN_ENERGY, FADE_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.set_active(true)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
