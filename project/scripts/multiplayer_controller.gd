extends Node

# TODO: Separate this into two multiplayer controllers:
# one for server, one for client

const PORT = 8910
const MAX_CONNECTIONS = 4

var player_info = {
	"username": ""
}

# Key: peer_id, Value: player_info
var players = { }

func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)


func join(address):
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(address, PORT)

	multiplayer.multiplayer_peer = peer


func host():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_CONNECTIONS)

	multiplayer.multiplayer_peer = peer
	
	players[1] = player_info
	
	get_tree().change_scene_to_file("res://project/scenes/lobby_menu.tscn")


@rpc("authority", "call_local", "reliable")
func start_game():
	get_tree().change_scene_to_file("res://project/scenes/levels/test_level.tscn")


@rpc("any_peer", "call_remote", "reliable")
func register_player(new_player_info):
	var new_peer_id = multiplayer.get_remote_sender_id()
	
	players[new_peer_id] = new_player_info
	

# For client
func leave_server():
	multiplayer.multiplayer_peer.close()
	get_tree().change_scene_to_file("res://project/scenes/main_menu.tscn")


# For host
func terminate_server():
	multiplayer.multiplayer_peer.close()
	get_tree().change_scene_to_file("res://project/scenes/main_menu.tscn")


func _on_peer_connected(peer_id):
	print(str(peer_id) + " connected")

	register_player.rpc_id(peer_id, player_info)


func _on_peer_disconnected(peer_id):
	print(str(peer_id) + " disconnected")
	
	if peer_id == 1: # Host disconnected
		leave_server()


func _on_connected_to_server():
	print("successfully connected to server")
	
	players[multiplayer.get_unique_id()] = player_info
	
	get_tree().change_scene_to_file("res://project/scenes/lobby_menu.tscn")

