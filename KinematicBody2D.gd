extends KinematicBody2D

signal game_over

var screensize
var extents

# how fast the player accelerates when a key is pressed
const ACCEL = 1000
const MAX_SPEED = 200
# controls how quickly the player comes to a stop
const FRICTION = -500

var acc = Vector2()
var vel = Vector2()

var last_anim
var disable_controls = false

var score = 0

onready var bullet = preload("res://Bullet.tscn")

func _ready():
	screensize = get_viewport_rect().size
	#extents = $collision.get_shape().get_extents()
	
	set_position(screensize/2)

func _process(delta):
	#var positionDiff = get_global_mouse_position() - get_global_position()
	
	#positionDiff = clamp(positionDiff, 0, 2)
	
	var input = Vector2(0, 0)
	if not disable_controls:
		input.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
		input.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))

		if Input.is_key_pressed(KEY_SPACE):
			fire()

	acc = input.normalized() * ACCEL
	if acc == Vector2(0, 0):
		acc = vel * FRICTION * delta
	vel += acc * delta
	vel = vel.clamped(MAX_SPEED)
	
	#var pos = position + vel * delta
	#pos.x = clamp(pos.x, extents.x, screensize.x - extents.x)
	#pos.y = clamp(pos.y, extents.y, screensize.y - extents.y)
	#set_position(pos)
	
	move_and_slide(vel)
	
	if not disable_controls:
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			if collision.collider.is_in_group("rock"):
				disable_controls = true
				$AnimationPlayer.play("explode")
				$ExplosionSound.play()
	
		var eps = .7
		if vel.y > eps:
			if last_anim != "move_down":
				last_anim = "move_down"
				$AnimationPlayer.play("move_down")
		elif vel.y < -eps:
			if last_anim != "move_up":
				last_anim = "move_up"
				$AnimationPlayer.play("move_up")
		else:
			if last_anim:
				$AnimationPlayer.play_backwards(last_anim)
				last_anim = null
			#else: $Sprite.frame = 5
		
func fire():
	if $FireDelay.is_stopped():
		$FireDelay.start(.3)
		var b = bullet.instance()
		b.position = position
		b.position += Vector2(23,10)
		$ShootSound.play()
		b.connect("rock_shot", self, "_on_rock_shot")
		get_tree().get_root().add_child(b)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "explode":
		emit_signal("game_over", score)
		get_tree().paused = true
	if last_anim:
		match anim_name:
			"move_up":
				$collision.set_disabled(true)
				$collisionDown.set_disabled(true)
				$collisionUp.set_disabled(false)
				
				$collisionUp.visible = true
				yield(get_tree().create_timer(1), "timeout")
				$collisionUp.visible = false
			"move_down":
				$collision.set_disabled(true)
				$collisionDown.set_disabled(false)
				$collisionUp.set_disabled(true)
				
				$collisionDown.visible = true
				yield(get_tree().create_timer(1), "timeout")
				$collisionDown.visible = false
	else:
		$collision.set_disabled(false)
		$collisionDown.set_disabled(true)
		$collisionUp.set_disabled(true)
		
		$collision.visible = true
		yield(get_tree().create_timer(1), "timeout")
		$collision.visible = false
		
func _on_rock_shot():
	score += 1