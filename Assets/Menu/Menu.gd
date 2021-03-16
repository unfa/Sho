extends Control

func visuals_update():
	OS.window_fullscreen = Config.visuals_fullscreen

# Called when the node enters the scene tree for the first time.
func _ready():
	HUD.hide()
	
	if Config.game_current.length() > 0: # if there's no current game, don't show the "Resume" button
		$MainMenu/Resume.show()
	else:
		$MainMenu/Resume.hide()
	
	# remove test items
	$Continue/GameList.clear()
	
	
	if GameStates.save_files.size() == 0: # if there are no saved games, don't bother showing the "Continue" button
		$MainMenu/Continue.hide()
	else:
		$MainMenu/Continue.show()
		for i in GameStates.save_files:
			$Continue/GameList.add_item(i)
	
	visuals_update()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_NewGame_pressed():
	$MainMenu.hide()
	$NewGame.show()

func _on_Quit_pressed():
	$MainMenu/Quit/QuitConfirmationDialog.popup_centered()

func _on_QuitConfirmationDialog_confirmed():
	get_tree().quit()

func _on_PlayerNameEdit_text_changed(new_text):
	if $NewGame/PlayerNameEdit.text.length() > 0 and not $NewGame/PlayerNameEdit.text in GameStates.save_files:
			$NewGame/Start.disabled = false
	else:
		$NewGame/Start.disabled = true


func _on_NewGameBack_pressed():
	$NewGame.hide()
	$MainMenu.show()


func _on_Start_pressed():
	GameStates.new_game($NewGame/PlayerNameEdit.text)
	get_tree().change_scene("res://Game.tscn")


func _on_Resume_pressed():
	self.hide()
	get_tree().paused = false


func _on_Menu_visibility_changed(): # if the menu has been opened during pause
	if self.visible and get_tree().paused:
		$MainMenu/Resume.show()
	else:
		$MainMenu/Resume.hide()


func _on_Continue_pressed():
	$MainMenu.hide()
	$Continue/Continue.disabled = true
	$Continue/GameList.unselect_all()
	$Continue.show()
	


func _on_ContinueBack_pressed():
	$Continue.hide()
	$MainMenu.show()


func _on_GameList_item_selected(index):
	$Continue/Continue.disabled = false


func _on_ContinueGame_pressed():
	
	var game = $Continue/GameList.get_item_text($Continue/GameList.get_selected_items()[0])
	GameStates.load_game(game)
	get_tree().change_scene("res://Game.tscn")
