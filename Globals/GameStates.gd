extends Node

const save_dir = "user://saves/"

class LevelState:
	var Map: String
	var Time: float
	var Score: int
	var Secrets: int
	var Deaths: int
	var Kills: int
	
	func _init(LevelName:String):
		self.Map = LevelName

class GameState:
	var Name: String
	var CreationDateTime = []
	var Client_UID: String
	var Levels = []
	var Score: int

	func _init(Name: String):
		self.Name = Name
		self.CreationDateTime = OS.get_datetime()
		self.Client_UID = OS.get_unique_id()
		#var Level = GameSaveLevel.new("A01")
		#self.Levels.append(Level)

#class GameSaveList:
#	var Saves = []
#	var CreatedDateTime = []
#	var ModifiedDateTime = []
#	var CreatedOnUID: String
#	var ModifiedOnUID: String
#	#var CreatedVersion: String
#	var ModifiedVersion: String
#
#	func _init():
#		self.CreatedDateTime = OS.get_datetime()
#		self.ModifiedDateTime = self.CreatedDateTime
#		self.CreatedOnUID = OS.get_unique_id()
#		self.ModifiedOnUID = self.CreatedOnUID
#		#self.CreatedVersion = OS.

var save_files = []

var current: GameState

func clear_level(level:LevelState):
	current.Levels.append(level)
	save_game()

func save_game():
	var f = File.new()
	f.open(save_dir + current.Name, File.WRITE)
	
	var levels = {}
	
	for x in current.Levels.size():
		levels[x] = {"map": current.Levels[x].Map,
					"secrets": current.Levels[x].Secrets,
					"time": current.Levels[x].Time,
					"deaths": current.Levels[x].Deaths,
					"kills": current.Levels[x].Kills,
					"score": current.Levels[x].Score,
		}
	
	var data = {"name": current.Name,
				"score": current.Score,
				"levels": levels,
				"created": current.CreationDateTime,
				"client": current.Client_UID,
	}
	
	f.store_string(to_json(data))
	f.close()

func load_game(file_name: String):
	var f = File.new()
	f.open(save_dir + file_name, File.READ)
	var data = f.get_as_text()
	f.close()
	current = parse_json(data)

func new_game(game_name: String):
	current = GameState.new(game_name)
	save_game()

# Called when the node enters the scene tree for the first time.
func _ready():
	#print("GAME SAVES initializing")
	
	var dir = Directory.new()

	if not dir.dir_exists(save_dir): # check if the save directory exists
		assert(dir.make_dir(save_dir) == OK) # if not create it
	
	dir.open(save_dir)
	
	dir.list_dir_begin(true, true)
	
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			print("Found directory: " + file_name)
		else:
			print("Found file: " + file_name)
		save_files.append(file_name)
		file_name = dir.get_next()
	
	#print(save_files)

	# check if the file exists
#	if not GameSavesFile.file_exists(FileName):
#		print ("Game Save doesn't exist")
#		assert(GameSavesFile.open(FileName, File.WRITE) == 0) # if we can't save data, then somethings royaly f---ed up
#		GameSavesState = GameSaves.new() # create a new file
#		GameSavesFile.store_var(GameSavesState, true)
#		GameSavesFile.close()
#	else:
#		print ("Reading game saves...")
#		assert(GameSavesFile.open(FileName, File.READ) == 0) # since the file exists we must be able to read it
#		GameSavesState = GameSavesFile.get_var(true)
#		GameSavesFile.close()
	
	#print("GAME SAVE STATE initialized")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
