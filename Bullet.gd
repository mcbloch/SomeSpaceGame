extends KinematicBody2D

signal rock_shot

var speed = 10

func _process(delta):
	var collision = move_and_collide(Vector2(speed, 0))
	
	if collision and collision.collider.is_in_group("rock"):
		collision.collider.queue_free()
		$AudioStreamPlayer2D.play()
		$CollisionShape2D.set_disabled(true)
		visible = false
		emit_signal("rock_shot")
		yield($AudioStreamPlayer2D, "finished")
		self.queue_free()