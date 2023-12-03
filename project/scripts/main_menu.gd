extends Control


func _on_host_button_pressed():
	MultiplayerController.player_info["username"] = $UsernameLineEdit.text
	MultiplayerController.host()


func _on_join_button_pressed():
	MultiplayerController.player_info["username"] = $UsernameLineEdit.text
	MultiplayerController.join($IpAddressLineEdit.text)
