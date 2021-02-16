extends Node

class GameSaveLevel:
	var Name: String
	var Completed: bool
	var Time: float
	var Score: int
	var Secrets: int
	var Deaths: int
	var Kills: int
	var Gems: int

	func _init(LevelName:String):
		self.Name = LevelName
		self.Completed = false

class GameSave:
	var Current: bool = false
	var PlayerName: String
	var CreationDateTime
	var Levels = []
	var Score: int

	func _init(PlayerName: String):
		self.PlayerName = PlayerName
		self.CreationDateTime = OS.get_datetime()
		self.Current = false
		
		#var Level = GameSaveLevel.new("A01")
		#self.Levels.append(Level)

class GameSaves:
	var Saves = []
	var CreatedDateTime = []
	var ModifiedDateTime = []
	var CreatedOnUID: String
	var ModifiedOnUID: String
	var CreatedVersion: String
	var ModifiedVersion: String
	
	func _init():
		self.CreatedDateTime = OS.get_datetime()
		self.ModifiedDateTime = self.CreatedDateTime
		self.CreatedOnUID = OS.get_unique_id()
		self.ModifiedOnUID = self.CreatedOnUID
		self.CreatedVersion = OS.get_exe


const FileName = "user://gamesave.sho"
var GameSavesFile = File.new()
var GameSavesState

# Called when the node enters the scene tree for the first time.
func _ready():
	print("GAME SAVES initializing")
	# check if the file exists
	if not GameSavesFile.file_exists(FileName):
		print ("Game Save doesn't exist")
		assert(GameSavesFile.open(FileName, File.WRITE) == 0) # if we can't save data, then somethings royaly f---ed up
		GameSavesState = GameSaves.new() # create a new file
		GameSavesFile.store_var(GameSavesState, true)
		GameSavesFile.close()
	else:
		print ("Reading game saves...")
		assert(GameSavesFile.open(FileName, File.READ) == 0) # since the file exists we must be able to read it
		GameSavesState = GameSavesFile.get_var(true)
		GameSavesFile.close()
	
	print("GAME SAVE STATE initialized")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
