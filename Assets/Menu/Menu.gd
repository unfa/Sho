extends Control



# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


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
	if $NewGame/PlayerNameEdit.text.length() > 0:
		$NewGame/Start.disabled = false
	else:
		$NewGame/Start.disabled = true


func _on_NewGameBack_pressed():
	$NewGame.hide()
	$MainMenu.show()


func _on_Start_pressed():
	get_tree().change_scene("res://Game.tscn")
