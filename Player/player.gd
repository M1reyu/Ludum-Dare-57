extends CharacterBody2D

var speed = 200

func _physics_process(_delta: float) -> void:	
	var dir = Input.get_vector("Left", "Right", "Up", "Down")
	dir = dir.normalized() * speed
	
	velocity = dir
	if (move_and_slide()):
		dir = dir * -0.5
		velocity = dir
