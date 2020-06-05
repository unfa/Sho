extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

class musicTrack:
	
	var track_name = ''
	var stems = { 'A': '' ,
				  'B': '' ,
				  'C': '' ,
				  'D': '' }
				
	func load_stems(stems_path: String):
		pass
	
	func _init(name: String, stems_path: String):
		self.track_name = name
		load_stems(stems_path)
		return
		

onready var players = { 'A': $A ,
						'B': $B ,
						'C': $C ,
						'D': $D }

# Called when the node enters the scene tree for the first time.
func _ready():
	for player in players:
		players[player].play()
	
	# mute the MUSIC submix bus
	#AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), true)
	#AudioServer.set_bus_mute(AudioServer.get_bus_index("Music A"), true)
	#AudioServer.set_bus_mute(AudioServer.get_bus_index("Music B"), true)
	#AudioServer.set_bus_mute(AudioServer.get_bus_index("Music C"), true)
	#AudioServer.set_bus_mute(AudioServer.get_bus_index("Music D"), true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
