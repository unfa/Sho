extends Area

#const SmokeBaseColor = preload("res://Assets/Smoke/Smoke BaseColor.png")
#const SmokeNormal = preload("res://Assets/Smoke/Smoke Normal.png")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

enum GEM_TYPES{
	small
	medium
	large
	extraLarge
}

#const GEM_VALUES = {
#	0:	15,
#	1:	50,
#	2:	100,
#	3:	250
#}

onready var GEM_MESHES = {
	0: $Pickup/Gem1,
	1: $Pickup/Gem2,
	2: $Pickup/Gem3,
	3: $Pickup/Gem4
}

const ROTATION = 0.25

export (GEM_TYPES)var type = GEM_TYPES.small setget set_type # only define a setter so we can update the gem's looks in editor

var old_type = type

var active = true

var value:int

func set_type(value):
	old_type = type
	type = value
	#update_type()

func update_type():
	value = Balance.GEM_VALUES[type]
	
	
	$Flash.light_energy = 0
	
	GEM_MESHES[old_type].hide()
	GEM_MESHES[type].show()
	
	#GEM_MESHES[type].show()
	
	var GemColor = GEM_MESHES[type].get_surface_material(0).get_shader_param("Color")
	$Flash.light_color = GemColor
	var ShockwaveMaterial = $Shockwave.mesh.surface_get_material(0)
	ShockwaveMaterial["albedo_color"] = GemColor

# Called when the node enters the scene tree for the first time.
func _ready():
	#print("Gem _ready")
	# Make the shockwave mesh unique
	$Shockwave.mesh = $Shockwave.mesh.duplicate(true)
	
	# assign point value based on the selected Gem Type
	update_type()
	$Shockwave.hide()
		
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

