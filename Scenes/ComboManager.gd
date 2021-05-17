extends Node

remote func player_combo(id):
	for player in Global.root.get_node("Level/GameWindow/Players").get_children():
		if player.name != str(id):
			rpc_id(int(player.name),"receive_combo", id)

remote func player_died(id):
	for player in Global.root.get_node("Level/GameWindow/Players").get_children():
		if player.name != str(id):
			rpc_id(int(player.name),"receive_death", id)
			Global.root.get_node("Level/GameWindow").playersAlive.erase(id)
	if Global.root.get_node("Level/GameWindow").playersAlive.size() == 1:
		print(str(Global.root.get_node("Level/GameWindow").playersAlive[0]) + "won")
		var winnerID = str(Global.root.get_node("Level/GameWindow").playersAlive[0])
		rpc_id(int(winnerID),"player_won", int(winnerID))

#FIX WIN SCREEN
