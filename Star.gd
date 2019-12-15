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

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Star_body_entered(body):
	if body.is_in_group("players") and active:
		active = false
		body.collect_star()
		$CollisionShape/AnimationPlayer.play("Pickup")


