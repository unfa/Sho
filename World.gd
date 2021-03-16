extends Node

onready var environment = $WorldEnvironment
onready var sun = $Sun
onready var tween = $Tween
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

func visuals_update():
	$WorldEnvironment.environment.glow_enabled = Config.visuals_bloom
	$WorldEnvironment.environment.ssao_enabled = Config.visuals_ssao
	$WorldEnvironment.environment.ss_reflections_enabled = Config.visuals_ssr
	
	$WorldEnvironment.environment.fog_depth_end = Config.visuals_draw_distance 
	$CameraRig/Camera.far = Config.visuals_draw_distance
	
	var viewport = get_tree().root
	
	viewport.msaa = Config.visuals_aa
	
	viewport.shadow_atlas_size = Config.visuals_shadows_other
	
#	print ("Seting AA")
#
#	match Config.visuals_aa:
#		0:
#			viewport.msaa = Viewport.MSAA_DISABLED
#			print ("AA Disabled")
#		1:
#			viewport.msaa = Viewport.MSAA_2X
#			print ("AA 2x")
#		2:
#			viewport.msaa = Viewport.MSAA_4X
#			print ("AA 4x")
#		3:
#			viewport.msaa = Viewport.MSAA_8X
#			print ("AA 8x")
#		4:
#			viewport.msaa = Viewport.MSAA_16X
#			print ("AA 16x")
	
	$Sun.shadow_enabled = Config.visuals_shadows_sun
	
	print(Config.visuals_shadows_other)
	print(typeof(Config.visuals_shadows_other))
	
#	match Config.visuals_shadows_other:
#		0:
#			ProjectSettings.set_setting("rendering/quality/shadows/filter_mode", "Disabled")
#			ProjectSettings.set_setting("rendering/quality/shadow_atlas/size", 1024)
#
#		1:
#			ProjectSettings.set_setting("rendering/quality/shadows/filter_mode", "PCF5")
#			ProjectSettings.set_setting("rendering/quality/shadow_atlas/size", 1024)
#
#		2:
#			ProjectSettings.set_setting("rendering/quality/shadows/filter_mode", "PCF13")
#			ProjectSettings.set_setting("rendering/quality/shadow_atlas/size", 1024)
#
#		3:
#			ProjectSettings.set_setting("rendering/quality/shadows/filter_mode", "PCF13")
#			ProjectSettings.set_setting("rendering/quality/shadow_atlas/size", 2048)
#
#		4:
#			ProjectSettings.set_setting("rendering/quality/shadows/filter_mode", "PCF13")
#			ProjectSettings.set_setting("rendering/quality/shadow_atlas/size", 4096)
#
#		5: 
#			ProjectSettings.set_setting("rendering/quality/shadows/filter_mode", "PCF13")
#			ProjectSettings.set_setting("rendering/quality/shadow_atlas/size", 8192)
#



# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	HUD.show()
	
	visuals_update()
	
	Config.connect("visuals_config_updated", self, "visuals_update")
	
func _input(event):
	# TODO - make this pause the game and open pause menu instead
	if Input.is_action_pressed("ui_cancel"):
		$"../Menu".show()		
		get_tree().paused = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
