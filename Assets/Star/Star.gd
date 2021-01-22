extends Area

#const SmokeBaseColor = preload("res://Assets/Smoke/Smoke BaseColor.png")
#const SmokeNormal = preload("res://Assets/Smoke/Smoke Normal.png")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var active = true

# Called when the node enters the scene tree for the first time.
func _ready():
	$Meshes.show()
	# make the shockwave material unique
	#$Meshes/Shockwave.mesh.surface_set_material(0, $Meshes/Shockwave.mesh.surface_get_material(0).duplicate(true))
	$Meshes/Shockwave.hide()
	$CollisionShape/AnimationPlayer.play("Idle")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func spawn_effect():
	print("STAR TAKE EFFECT SPAWN!")
	var effect = preload("res://Assets/Effects/EffectStarPickup.tscn")
	var effect_instance = effect.instance()
	#effect_instance.set_name("effect star pickup")
	effect_instance.global_transform.origin = self.global_transform.origin
	get_tree().root.add_child(effect_instance)

func _on_Star_body_entered(body):
	if body.is_in_group("players") and active:
		active = false
		body.collect_star()
		$CollisionShape/AnimationPlayer.play("Pickup")


