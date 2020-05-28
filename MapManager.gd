extends Node

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
	
	func spawnMap():
		print("Spawning a map: ", map)
		parentNode.add_child(scene)
		current = true
	
	func freeMap():
		scene.queue_free()
		free = true
		current = false
			
onready var SlotA = MapSlot.new($MapA, true)
onready var SlotB = MapSlot.new($MapB, false)

var spawnPlayer = true

var MapList = [
	"res://Maps/Map01.tscn",
	"res://Maps/Map02.tscn",
	"res://Maps/Map03.tscn",
	"res://Maps/Map01.tscn"
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
	if not spawnPlayer:
		return -1
	
	spawnPlayer = false

func loadNextMap(): # load the next map resource so it's ready to spawn
	var nextMap = MapList.pop_front()
	
	var CurrentSlot = getFreeMapSlot()
	var OtherSlot = getFreeMapSlot(false)
	
	CurrentSlot.map = nextMap
	CurrentSlot.loadMap()
	CurrentSlot.free = false
	OtherSlot.free = true
	
func spawnNextMap(): # spawne the loaded map so it's a part of the world
	var previousMap = getCurrentMapSlot()
	var nextMap = getCurrentMapSlot(false)

	assert(nextMap.free == false)
	
	nextMap.spawnMap()
	previousMap.current = false
	
	spawnPlayer()

func freePreviousMap(): # despawn the unneeded previous map from the game
	getCurrentMapSlot(false).freeMap()

func _process(delta):
	#print("SlotA: ", SlotA.map, " SlotB: ", SlotB.map)
	pass
# Called when the node enters the scene tree for the first time.
func _ready():
	#pass # Replace with function body.
	
	loadNextMap()
	spawnNextMap()
	spawnPlayer()
	return
	freePreviousMap()
	loadNextMap()
	spawnNextMap()
	loadNextMap()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
