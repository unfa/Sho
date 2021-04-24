extends Node

signal visuals_config_updated

var config_file = "user://config"
var f = File.new()

var game_current = ""

# visual settings

var visuals_shadows_other = 4096
var visuals_shadows_sun = true
var visuals_particle_effects_multiplier = 1.0
var visuals_ssao = true
var visuals_ssr = true
var visuals_bloom = true
var visuals_aa = 2
var visuals_draw_distance = 500
var visuals_fullscreen = true
var visuals_resolution = Vector2(1920,1080)

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
	visuals_aa = data["visuals_aa"]
	visuals_ssr = data["visuals_ssr"]
	visuals_draw_distance = data["visuals_draw_distance"]
	visuals_fullscreen = data["visuals_fullscreen"]
	visuals_resolution = data["visuals_resolution"]
	
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
				"visuals_aa": visuals_aa,
				"visuals_ssr": visuals_ssr,
				"visuals_fullscreen": visuals_fullscreen,
				"visuals_resolution": visuals_resolution,
				}
	f.store_string(to_json(data))
	f.close()

# Called when the node enters the scene tree for the first time.
func _ready():
	config_load()
	#config_save()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
