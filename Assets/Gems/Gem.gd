extends Area

#const SmokeBaseColor = preload("res://Assets/Smoke/Smoke BaseColor.png")
#const SmokeNormal = preload("res://Assets/Smoke/Smoke Normal.png")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

enum GEM_TYPE{
	small
	medium
	large
	extraLarge
}

const GEM_VALUES = {
	GEM_TYPE.small: 15,
	GEM_TYPE.medium: 50,
	GEM_TYPE.large: 100,
	GEM_TYPE.extraLarge: 250
}

onready var GEM_MESHES = {
	GEM_TYPE.small: $Pickup/Gem1,
	GEM_TYPE.medium: $Pickup/Gem2,
	GEM_TYPE.large: $Pickup/Gem3,
	GEM_TYPE.extraLarge: $Pickup/Gem4
}

const ROTATION = 0.25

export (GEM_TYPE)var type = GEM_TYPE.small

var active = true

var value: int

# Called when the node enters the scene tree for the first time.
func _ready():
	# assign point value based on the selected Gem Type
	value = GEM_VALUES[type]
	
	# Make the shockwave mesh unique
	$Shockwave.mesh = $Shockwave.mesh.duplicate(true)
	$Shockwave.hide()
	
	$Flash.light_energy = 0
	
	GEM_MESHES[type].show()
	
	var GemColor = GEM_MESHES[type].get_surface_material(0).get_shader_param("Color")
	$Flash.light_color = GemColor
	var ShockwaveMaterial = $Shockwave.mesh.surface_get_material(0)
	ShockwaveMaterial["albedo_color"] = GemColor
	#$Shockwave.mesh.surface_set_material(0, ShockwaveMaterial)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.rotate_y(ROTATION * delta)

#func spawn_effect():
#	var effect = preload("res://Assets/Effects/EffectStarPickup.tscn")
#	var effect_instance = effect.instance()
#	effect_instance.set_name("effect star pickup")
#	get_tree().root.add_child(effect_instance)
#	effect_instance.global_transform.origin = self.global_transform.origin

func _on_Star_body_entered(body):
	if body.is_in_group("players") and active:
		active = false
		body.increase_score(value)
		$Shockwave.show()
		$Pickup.hide()
		$Pickup.queue_free()
		$AnimationPlayer.play("Pickup")
		$Shadow.hide()
		$Shadow.queue_free()

