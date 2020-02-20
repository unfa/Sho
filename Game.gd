extends Node
export var collected_stars = 0

onready var game_view = $Game/Viewport
onready var sky_view = $Skybox/Viewport


func update_viweport_size():
	game_view.size = OS.window_size
	sky_view.size = OS.window_size

# Called when the node enters the scene tree for the first time.
func _ready():
	update_viweport_size()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Skybox_resized():
	#update_viweport_size()
	pass
