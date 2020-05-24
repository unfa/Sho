extends Node

var debug = false

class StateMachine: # This class will help us track and manage what state our game entity is in.
	
	var states = []
	var current_state: int = 0 setget set_current_state, get_current_state
	var state_stack = []
	var state_history = []

	func get_current_state(as_string = false):
		if as_string:
			return get_state_name(get_current_state())
		else:
			return current_state
			
	func set_current_state(state):
		var new_state = 0
		if typeof(state) == TYPE_INT:
			new_state = state
		elif typeof(state) == TYPE_STRING:
			new_state = self.states.find(state)
		else:
			return false
		
#		if new_state == false or not self.states.has(new_state):
#			print("ERROR! " + Debug.name + ' (' + String(self.get_instance_id()) +'): cannot set non-existing state ' + String(state) )
#			return false
		
		self.state_history.append(self.current_state)
		current_state = new_state
		return true
	
	func get_previous_state(as_string = false):
		if self.state_history.size() > 0:
			if as_string:
				return get_state_name(state_history.back())
			else:
				return state_history.back()
		else:
			return false

	func get_next_state(as_string = false):
		if self.state_stack.size() > 0:
			if as_string:
				return get_state_name(state_stack.front())
			else:
				return state_stack.front()
		else:
			return false
	
	func state_just_changed():
		if not get_previous_state():
			return false
		elif String(get_current_state(true)) == String(get_previous_state(true)):
			return false
		else:
			return true
		
	func get_state_name(state: int):
		if typeof(state) == TYPE_NIL:
			return false
		
		var state_name = self.states[state]
		
		if typeof(state_name) == TYPE_STRING:
			return state_name
#		if self.states.size() >= state:
#			return self.states[state]
		else:
			return ''
		
	func queue_state(state):
		var new_state = 0
		
		if typeof(state) == TYPE_INT:
			new_state = state
		elif typeof(state) == TYPE_STRING:
			new_state = self.states.find(state)
		else:
			return false

		self.state_stack.append(new_state)
		return true
	
	func advance_state():
		var next_state = self.state_stack.pop_front()
		if next_state == null:
			return false
		else:
			set_current_state(next_state)
	
	func revert_state():
		var next_state = self.state_history.pop_back()
		if next_state == null:
			return false
		else:
			set_current_state(next_state)
	
	func _init(states: Array, initial_state: int):
		self.states = states
		set_current_state(initial_state)
		state_history.clear()

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
