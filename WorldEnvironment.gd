extends WorldEnvironment


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func visuals_config_update():
	print ("World update")


# Called when the node enters the scene tree for the first time.
func _ready():
	Config.connect("visuals_config_updated", self, "visuals_config_updated")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
