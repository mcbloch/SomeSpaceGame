extends Area2D

export(NodePath) var player_path

var spawning = true

onready var rock = preload("res://Rock.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn()
	get_node(player_path).connect("game_over", self, "_on_game_over")
	
func spawn():
	if spawning:
		var r = rock.instance()
		r.position = position
		r.position.y = randi() % int($CollisionShape2D.shape.extents.y*2)
		get_tree().get_root().add_child(r)
		yield(get_tree().create_timer(1), "timeout")
		spawn()
	
func _on_game_over(score):
	spawning = false