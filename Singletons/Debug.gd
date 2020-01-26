extends Control

onready var label = $Label

var debug = true

class DebugHandle:
	
	var buffer = ''
	var object_name: String
		
	func debug(text:String, clear = false):
		self.buffer += text + '\n'
	
	func _init(name:String):
		object_name = name
	
	func flush_debug():
		Debug.label.text = ''
		Debug.label.text += self.object_name.to_upper() + '\n'
		
		for i in range(0, self.object_name.length()):
			Debug.label.text += "-"
			
		Debug.label.text += "\n"
		
		Debug.label.text += self.buffer + '\n\n'
		self.buffer = ''
	
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if debug:
		print ("Singleton \"" + name + "\" initiated")
	else:
		pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
