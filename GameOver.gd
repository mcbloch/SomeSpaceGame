# tool
extends Label

export(NodePath) var player_path #setget setPath, getPath

func _ready():
	visible = false
	get_node(player_path).connect("game_over", self, "_on_game_over")

func _on_game_over(score):
	visible = true
	set_text("Game Over \n Score: " + str(score))

#func getPath():
#    return player_path
#
#func setPath(newPath):
#    print("setPath()")
#    player_path = newPath
#    call_deferred("set_my_path")
#
#func set_my_path():
#    print("set_my_path()") 