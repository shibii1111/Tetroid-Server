extends Node

const PLAYERS = preload("res://Scenes/Levels/SmallGrid.tscn")

var playersAlive = []

var occupiedSmallGrid = []
var foundSpot = false

onready var players = $Players

func _ready():
	randomize()

remote func spawn_players(id):
	foundSpot = false
	var player = PLAYERS.instance()
	player.name = str(id)
	players.add_child(player)
	playersAlive.append(id)
	rpc("spawn_player", id)

