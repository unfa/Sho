extends Control

onready var label = $Label

var debug = true

var handles = []
var handles_flushed = []

class DebugHandle:
		
	var buffer = ''
	var flushed_buffer = ''
	var object_name: String
	var enabled = false
		
	func enable():
		self.enabled = true
	
	func disable():
		self.enabled = false
	
	func debug(text:String):
		self.buffer += text + '\n'
	
	func _init(name:String):
		if Debug.debug:
			print("New debug handle: " + name)
		object_name = name
		Debug.handles.append(self)
	
	func flush_debug():
		if not enabled:
			return false
		
		self.flushed_buffer = ''
		
		#Debug.label.text = ''
		
		var header = self.object_name.to_upper() + ' (' + String(self.get_instance_id()) + ')'
		
		self.flushed_buffer += header + '\n'
		
		for i in range(0, header.length()):
			self.flushed_buffer += "-"
			
		self.flushed_buffer += "\n"
		
		self.flushed_buffer += self.buffer + '\n\n'
		self.buffer = ''
		
		if not Debug.handles_flushed.has(self):
			Debug.handles_flushed.append(self)

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.connect("timeout", self, "update")
	
	if debug:
		print ("Singleton \"" + name + "\" initiated")
	else:
		pass # Replace with function body.


func update():
	label.text = ''
	
	handles_flushed.sort()
	
	for handle in handles_flushed:
		#print(handle)
		if handle is DebugHandle:
			label.text += handle.flushed_buffer
			handle.flushed_buffer = ''

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
	#print(String(to_json(handles_flushed)))
	
	

