extends Node
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

enum ReplayState {REPLAY_CAPTURE, REPLAY_PLAYBACK, REPLAY_INACTIVE}

#var debug_handle = Debug.DebugHandle.new("Replay")
var debug = true
var time: float = 0
var state = ReplayState.REPLAY_INACTIVE
var playback_start_time: float
var playback_position: int

var replay_status: String

class capture_frame:
	var time: float
	var event: InputEvent
	
	func _init(time: float, event: InputEvent):
		self.time = time
		self.event = event
	
var seq = []

var frame = capture_frame.new(0, InputEvent.new())

# Called when the node enters the scene tree for the first time.
func _ready():
	if debug:
		print ("Singleton \"" + name + "\" initiated")
	
	replay_status = String(state)

#func debug(message: String):
#	if debug:
#		debug_handle.debug(message)
	
func demo_save():
	var file = File.new()
	file.open("user://demo.dat", File.WRITE)
	file.store_var(seq, true)
	print("SAVED DEMO to disk. Size: " + String(file.get_len()))
	file.close()
		
func demo_load():
	var file = File.new()
	file.open("user://demo.dat", File.READ)
	seq = file.get_var(true)
	print("LOADED DEMO from disk. Size: " + String(file.get_len()))
	file.close()

func _input(event):
	
	if state != ReplayState.REPLAY_PLAYBACK and Input.is_action_just_pressed("demo_play"):
		demo_load()
		state = ReplayState.REPLAY_PLAYBACK
		
	elif state != ReplayState.REPLAY_PLAYBACK and Input.is_action_just_pressed("demo_replay"):
		demo_save()
		state = ReplayState.REPLAY_PLAYBACK
		
		playback_start_time = time
		playback_position = -1 # se the playback index to a special number
		print("### Starting playback at frame " + String(playback_start_time))
	
	elif state == ReplayState.REPLAY_CAPTURE and event is InputEventKey: # record events
		var frame = capture_frame.new(time, event)
		seq.append(frame)
		print("Appended frame " + String(frame.time) + " with event " + frame.event.to_string())	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta

	if state == ReplayState.REPLAY_PLAYBACK: #play back events
		if playback_position == -1:
			get_tree().reload_current_scene()
			playback_position = 0
			playback_start_time = time
		else:
			if playback_position >= seq.size():
				print("End of demo reached. Restarting...")
				playback_position = -1
			else:
				while frame.time < time - playback_start_time:
					
					print("playing frame: " + String(playback_position))
					Input.parse_input_event(frame.event)
					playback_position += 1
	elif state == ReplayState.REPLAY_INACTIVE:
		return
			
	print("state: " + String(state))
	print("time: " + String(time))
	print("playback_position: " + String(playback_position))
	print("frame.time: " + String(frame.time) )
	print("---")
	
	#debug_handle.flush_debug()
