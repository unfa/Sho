extends Node

# binding to world nodes
#var root #= get_tree().root
var world #= get_tree().root.find_node("World")
var player #= world.get_node("Player")
var cameraRig #= world.get_node("CameraRig")

var levelState: GameStates.LevelState

var lastTime = 0

class MapSlot:
	var map: String
	var parentNode: Node
	var resource: PackedScene
	var scene: Node
	var free = true
	var current = false
	
	func _init(parentNode: Node, free = true):
		print ("MapSlot: ", self, ", parent node: ", parentNode)
		self.parentNode = parentNode
		self.free = free
		self.current = ! free
	
	func loadMap():
		resource = load(map)
		scene = resource.instance()
		free = false
	
	func spawnMap(previousMap: MapSlot, world):
		print("Spawning a map: ", map)
		#parentNode.call_deferred("add_child", scene)
		self.parentNode.add_child(scene)

		current = true
	
	func freeMap():
		scene.queue_free()
		free = true
		current = false
		
		#get_tree().root.find_node("MapManager").incStage()

var SlotA
var SlotB

var firstMap = true

var stage = 0

func incStage():
	stage += 1
	HUD.get_node("Display/Rows/Columns/StageScoreMargin/StageScoreRows/StageLabel").text = "STAGE: " + String(stage)

var MapList = [
	"res://Maps/Campaign/A01.tscn",
	"res://Maps/Campaign/A02.tscn",
	"res://Maps/Campaign/A03.tscn",
	"res://Maps/Campaign/A04.tscn",
]


func getCurrentMapSlot(check = true) -> MapSlot:
	print ("getCurrentMapSlot check!")
	if SlotA.current == check:
		print("Slot A is current")
		return SlotA
	elif SlotB.current == check:
		print("Slot B is current")
		return SlotB
	else:
		print("Neither slot A or B are current")
		return null

func getFreeMapSlot(check = true) -> MapSlot:
	print ("getFreeMapSlot check!")
	if SlotA.free == check:
		print ("Slot A is free")
		return SlotA
	elif SlotB.free == check:
		print ("Slot B is free")
		return SlotB
	else:
		print ("NO FREE SLOTS!")
		return null

func swapFreeMapSlot():
	print("SlotA.free ", SlotA.free, "; SlotB.free: ", SlotB.free)
	if SlotA.free and not SlotB.free:
		SlotA.free = false
		SlotB.free = true
	elif SlotB.free and not SlotA.free:
		SlotB.free = false
		SlotA.free = true
	else:
		print("SlotA.free ", SlotA.free, "; SlotB.free: ", SlotB.free)
		print("Both slots are free or none is")
		return -1

func spawnPlayer():
	var playerSpawner = getCurrentMapSlot().scene.find_node("Player").global_transform
	
	player.global_transform = playerSpawner
	cameraRig.global_transform = playerSpawner

func loadNextMap(): # load the next map resource so it's ready to spawn
	var nextMap = MapList.pop_front()
	
	var CurrentSlot = getFreeMapSlot()
	var OtherSlot = getFreeMapSlot(false)
	
	CurrentSlot.map = nextMap
	CurrentSlot.loadMap()
	CurrentSlot.free = false
	OtherSlot.free = true
	
func spawnNextMap(): # spawne the loaded map so it's a part of the world
	
	# save the progress
	
	levelState = GameStates.LevelState.new(getCurrentMapSlot().map)
	
	if not firstMap:
		levelState.Score = player.score
		levelState.Deaths = player.deaths
		levelState.Kills = player.kills
		levelState.SecretsTotal = get_tree().get_nodes_in_group("secrets").size()
	
	if firstMap: # is this si the first map, start the stopwatch now
		lastTime = OS.get_ticks_msec()
	
	var previousMap = getCurrentMapSlot()
	var nextMap = getCurrentMapSlot(false)
	
	#assert(nextMap.free == false)
	
	nextMap.spawnMap(getCurrentMapSlot(), world)
	previousMap.current = false
	
	var newEntry = nextMap.scene.find_node("Entry")
	
	if firstMap:
		# if this is the first map we're ever spawning - leave the gate visible and solid, just make it not process anything
		newEntry.set_process(false)
	else:
		# if we're spawning another level, we can't have two gates one over another, so lets' make the door non-solid, and hide the whole gate (we'll reverse that later)	
		newEntry.get_node("Gate/Door /static_collision/shape0").set_deferred("disabled", true)
		newEntry.set_process(false) # stop the first gate, so it doesn't eat up player's stars
		newEntry.hide()
	
	nextMap.scene.find_node("Exit").connect("LoadMap",	self, "loadNextMap")
	nextMap.scene.find_node("Exit").connect("SpawnMap",	self, "spawnNextMap")
	nextMap.scene.find_node("Exit").connect("FreeMap",	self, "freePreviousMap")

	# osffset the new map to alight properly wiht the current one
	if not firstMap: # omit this if it's the first spawned map
		var oldExit: Spatial = previousMap.scene.find_node("Exit")
		
		# apply transform offset to align maps gate to gate
		
		var transformOffset = oldExit.global_transform * newEntry.global_transform.inverse()
		print("transformOffset is: ", transformOffset)
		nextMap.scene.set_deferred("global_transform", nextMap.scene.global_transform * transformOffset)
		
		# TODO connect signals from the current exit gate to appropraite methods
	else:
		spawnPlayer()
		firstMap = false

func freePreviousMap(): # despawn the unneeded previous map from the game
	
	# release previous map 
	getCurrentMapSlot(false).freeMap()
	incStage()
	
	# because the player has definitely left the level now, we can clear it.
	levelState.Secrets = player.secrets
	
	var currentTime = OS.get_ticks_msec()
	levelState.Time = currentTime - lastTime
	lastTime = currentTime
	
	GameStates.clear_level(levelState)
	
	HUD.display_message("Level Stats:\n" + "Time: " + String(levelState.Time / 1000) + " seconds\n" + "Secrets: " + String(levelState.Secrets) + "/" + String(levelState.SecretsTotal) )
	
	
	# reset player numbers for the next level
	player.deaths = 0
	player.kills = 0
	player.secrets = 0
	
	# make current maps' entry gate door solid, and make the gate visible so we don't leave a hole in the level
	var currentEntry = getCurrentMapSlot().scene.find_node("Entry")
	currentEntry.get_node("Gate/Door /static_collision/shape0").set_deferred("disabled", false)
	currentEntry.show()
	
	yield(get_tree().create_timer(15),"timeout")
	
	HUD.hide_message()

#func _process(delta):
	#print("SlotA: ", SlotA.map, " SlotB: ", SlotB.map)
	#pass
# Called when the node enters the scene tree for the first time.
func _ready():
	# wait for the player node to be ready
	world = get_tree().root.find_node("World", true, false)
	print(world)
	player = world.get_node("Player")
	cameraRig = world.get_node("CameraRig")
	
	SlotA = MapSlot.new(world.get_node("MapA"), true)
	SlotB = MapSlot.new(world.get_node("MapB"), false)

	
	#pass # Replace with function body.
	loadNextMap()
	spawnNextMap()
	incStage()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
