extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	if multiplayer.is_server():
		$Client.hide()
	else:
		$Host.hide()


func _on_stop_hosting_button_pressed():
	MultiplayerController.terminate_server()


func _on_leave_lobby_button_pressed():
	MultiplayerController.leave_server()


func _on_start_game_button_pressed():
	MultiplayerController.start_game.rpc()
