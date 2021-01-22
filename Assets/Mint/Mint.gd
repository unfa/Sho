extends Area

#const SmokeBaseColor = preload("res://Assets/Smoke/Smoke BaseColor.png")
#const SmokeNormal = preload("res://Assets/Smoke/Smoke Normal.png")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var active = true

# Called when the node enters the scene tree for the first time.
func _ready():
	$Mint/Mint.show()
	# make the shockwave material unique
	$Shockwave.mesh = $Shockwave.mesh.duplicate(true)
	$Shockwave.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

#func spawn_effect():
#	var effect = preload("res://Assets/Effects/EffectStarPickup.tscn")
#	var effect_instance = effect.instance()
#	effect_instance.set_name("effect star pickup")
#	get_tree().root.add_child(effect_instance)
#	effect_instance.global_transform.origin = self.global_transform.origin

func _on_Star_body_entered(body):
	if body.is_in_group("players") and active:
		if body.hp < body.MAX_HP:
			active = false
			body.heal(25)
			$AnimationPlayer.play("Pickup")
		else:
			pass


