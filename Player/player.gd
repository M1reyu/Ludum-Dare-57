extends CharacterBody2D

var speed = 500
var gravity = 300

func _physics_process(delta: float) -> void:	
	var dir = Input.get_vector("Left", "Right", "Up", "Down")
	dir = dir.normalized() * speed
	
	var collides = move_and_slide()
	if (dir != Vector2.ZERO):
		if (collides): velocity = velocity * -0.5
		else:
			velocity += dir * delta
			if abs(velocity.x) > abs(dir.x): velocity.x = dir.x
			if abs(velocity.y) > abs(dir.y): velocity.y = dir.y
	elif (collides):
		velocity = Vector2.ZERO
	elif (velocity.y < gravity): 
		velocity.x = 0
		velocity.y = velocity.y + gravity * delta
