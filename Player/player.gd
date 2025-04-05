extends CharacterBody2D

@export var speed : int = 500
@export var gravity : int = 300

func _physics_process(delta: float) -> void:	
	var dir : Vector2 = Input.get_vector("Left", "Right", "Up", "Down")	
	
	if (dir.x != 0):
		dir.x *= speed * delta * 2
		if((dir.x < 0 && velocity.x > 0) || (dir.x > 0 && velocity.x < 0)): dir.x += (velocity.x * 0.75)
		else: dir.x += velocity.x
		if (dir.x > speed): dir.x = speed
		elif (dir.x < -speed): dir.x = -speed
	elif (abs(velocity.x) > 10): dir.x = velocity.x * 0.9
	else: dir.x = 0
	
	if (dir.y != 0):
		dir.y *= speed * delta * 2
		if((dir.y < 0 && velocity.y > 0) || (dir.y > 0 && velocity.y < 0)): dir.y += (velocity.y * 0.75)
		else: dir.y += velocity.y
		if (dir.y > speed): dir.y = speed
		elif (dir.y < -speed): dir.y = -speed
	elif (abs(velocity.y) > 10): dir.y = velocity.y * 0.9
	else: dir.y = 0 
	
	velocity = dir
	move_and_slide()
#	if(move_and_slide()):
#		var collition
#		for i in get_slide_collision_count():
#			dir = position - get_slide_collision(i).get_position() * speed * 0.3
#			velocity += dir
#		
#		velocity.x = clamp(velocity.x, -speed, speed)
#		velocity.y = clamp(velocity.y, -speed, speed)
