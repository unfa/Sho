extends Node

signal visuals_config_updated

var config_file = "user://config"
var f = File.new()

var game_current = ""

# visual settings

var visuals_shadows_other = 1024
var visuals_shadows_sun = true
var visuals_particle_effects_multiplier = 1.0
var visuals_ssao = true
var visuals_debanding = false
var visuals_ssr = true
var visuals_bloom = true
var visuals_msaa = 2
var visuals_fxaa = false
var visuals_subscale = 1
var visuals_subscale_filter = true
var visuals_draw_distance = 500
var visuals_fullscreen = true
var visuals_resolution = OS.get_screen_size(OS.current_screen)

# Declare member variables here. Examples:
# a = 2
# b = "text"

func config_load():
	f.open(config_file,File.READ)
	
	if f.get_error() != 0: # in case of an error, just use defaults and write the config down
		config_save()
		return 1
	
	var data = parse_json(f.get_as_text())
	
	game_current = data["game_current"]
	visuals_ssao = data["visuals_ssao"]
	visuals_bloom = data["visuals_bloom"]
	visuals_draw_distance = data["visuals_draw_distance"]
	visuals_shadows_other = data["visuals_shadows_other"]
	visuals_shadows_sun = data["visuals_shadows_sun"]
	visuals_particle_effects_multiplier = data["visuals_particle_effects_multiplier"]
	visuals_msaa = data["visuals_msaa"]
	visuals_fxaa = data["visuals_fxaa"]
	visuals_subscale = data["visuals_subscale"]
	visuals_subscale_filter = data["visuals_subscale_filter"]
	visuals_debanding = data["visuals_debanding"]
	visuals_ssr = data["visuals_ssr"]
	visuals_draw_distance = data["visuals_draw_distance"]
	visuals_fullscreen = data["visuals_fullscreen"]
	visuals_resolution = str2var(data["visuals_resolution"])
	emit_signal("visuals_config_updated")
	
func config_save():
	f.open(config_file,File.WRITE)
	
	var data = {"game_current": game_current,
				"visuals_ssao": visuals_ssao,
				"visuals_bloom": visuals_bloom,
				"visuals_draw_distance": visuals_draw_distance,
				"visuals_shadows_other": visuals_shadows_other,
				"visuals_shadows_sun": visuals_shadows_sun,
				"visuals_particle_effects_multiplier": visuals_particle_effects_multiplier,
				"visuals_msaa": visuals_msaa,
				"visuals_fxaa": visuals_fxaa,
				"visuals_subscale": visuals_subscale,
				"visuals_subscale_filter": visuals_subscale_filter,
				"visuals_debanding": visuals_debanding,
				"visuals_ssr": visuals_ssr,
				"visuals_fullscreen": visuals_fullscreen,
				"visuals_resolution": visuals_resolution,
				}
	f.store_string(to_json(data))
	f.close()

# Called when the node enters the scene tree for the first time.

#func poll_node(node_name):
#	var instance = null
#	var attempts = 0
#	while instance == null:
#		instance = get_tree().root.find_node(node_name, true, false)
#		yield(get_tree(), "idle_frame")
#		attempts += 1
#		print("Finding ", node_name, "; Attempt ", attempts)
#	#print("Control: visuals_update waited ", attempts, "idle frames to find camera")
#	return instance

func visuals_update():
	print("Config: visuals_update called")
	
	OS.window_fullscreen = visuals_fullscreen
	#OS.window_size = visuals_resolution #TODO: parse Vector2 from JSON
	
	var camera = get_tree().root.find_node("Camera", true, false)
	var environment = get_tree().root.find_node("WorldEnvironment", true, false).environment
	var sun = get_tree().root.find_node("Sun", true, false)
	if sun == null: sun = get_tree().root.find_node("DirectionalLight", true, false) # fallback
	var viewport_container = get_tree().root.find_node("ViewportContainer", true, false)
	var viewport = viewport_container.get_child(0)
	
#	var attempts = 0
	#camera = poll_node("Camera")
#	while camera == null:
#		camera = get_tree().root.find_node("Camera", true, false)
#		yield(get_tree(), "idle_frame")
#		attempts += 1
#		print("Attempt ", attempts)
#	print("Control: visuals_update waited ", attempts, "idle frames to find camera")
#
#	assert(camera != null, "Config: camera is null")
#	if camera != null:	
#		sun = poll_node("Sun")
#	if sun == null: #fallback to a different node name
#		sun = get_tree().root.find_node("DirectionalLight")
#	assert(sun != null, "Config: sun is null")
#	if sun != null:	
#		viewport_container = poll_node("ViewportContainer")
#	assert(viewport_container != null, "Config: viewport_container is null")
#	if viewport_container != null:	
#		viewport = viewport_container.get_child(0)
#	assert(viewport != null, "Config: viewport is null")
		
#	if viewport == null:
#		return 1
		
	#var world_environent = camera.environment
	camera.far = Config.visuals_draw_distance
	
	environment.glow_enabled = Config.visuals_bloom
	environment.ssao_enabled = Config.visuals_ssao
	environment.ss_reflections_enabled = Config.visuals_ssr
	environment.fog_depth_end = Config.visuals_draw_distance 

	
	viewport_container.stretch_shrink = Config.visuals_subscale
	viewport.msaa = Config.visuals_msaa
	viewport.fxaa = Config.visuals_fxaa
	viewport.debanding = visuals_debanding
	viewport.shadow_atlas_size = Config.visuals_shadows_other
	
	if Config.visuals_subscale > 1 and Config.visuals_subscale_filter:
		viewport.get_texture().flags = 4 # turn on filtering
	
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
	
	sun.shadow_enabled = Config.visuals_shadows_sun
	
	#print(Config.visuals_shadows_other)
	#print(typeof(Config.visuals_shadows_other))
	
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

func _ready():
	config_load()
	#config_save()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
