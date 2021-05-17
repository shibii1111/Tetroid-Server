extends Node

var network = NetworkedMultiplayerENet.new()
var port = 3232
var max_players = 50

onready var serverText = Global.root.get_node("GUI/ServerText")

var players = {}
var ready_players = 0

func _ready():
	start_server()
	
func start_server():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	network.connect("peer_connected", self, "_player_connected")
	network.connect("peer_disconnected", self, "_player_disconnected")
	
	serverText.add_text("Welcome to Tetroid Server!\n")
	print("Welcome to Tetroid Server!")
	
func _player_connected(player_id):
	print("Player " + str(player_id) + " connected.")

	
func _player_disconnected(player_id):
	if !players.has(player_id):
		return
	serverText.add_text("Player " + str(players[player_id]["Player_name"]) + " disconnected.\n")
	print("Player " + str(players[player_id]["Player_name"]) + " disconnected.")

	# Deleting from waiting room
	players.erase(player_id)
	
	# Deleting from the game room
	if Global.root.get_node("Level").get_children() != []:
		Global.root.get_node("Level/GameWindow/Players/" + str(player_id)).queue_free()
		Global.root.get_node("Network/ComboManager").player_died(player_id)
	
		# Deleting the room if 0 player
		if players.size() == 0:
			Global.root.get_node("Level/GameWindow").queue_free()
			ready_players = 0
			Global.root.get_node("Level/GameWindow").playersAlive = []
			print("array is " + str(Global.root.get_node("Level/GameWindow").playersAlive.size()))
			print("The room has been freed up!")
			serverText.add_text("The room has been freed up!\n")
	

remote func send_player_info(id, player_data):
	# if the room is already playing, refure player
	if Global.root.get_node("Level").get_children() != []:
		rpc_id(id, "cant_join_game")
		ready_players = 0
		return
	
	# room is waiting	
	players[id] = player_data
	rset("players", players)
	rpc("update_waiting_room")
	serverText.add_text("Player " + str(players[id]["Player_name"]) + " connected.\n")
	print(players[id]["Player_name"] + " connected")
	
	
remote func load_world():
	ready_players += 1
	if players.size() > 1 and ready_players >= players.size():
		rpc("start_game")
		var world = preload("res://Scenes/Levels/50PScreen.tscn").instance()
		Global.root.get_node("Level").add_child(world)
