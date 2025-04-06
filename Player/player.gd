extends CharacterBody2D

signal collides(collision: KinematicCollision2D)

@export var speed : int = 800
@export var maxSpeed : int = 1500
@export var bounceForce : int = 1000
#@export var gravity : int = 300

var strength : int = 2
var inMenu : bool = false

@onready var menuHud : Control = $MainCam/MenuHud

func _process(_delta: float) -> void:
	if (!menuHud.visible && Input.is_action_just_pressed("MenuTrigger")): menuHud.show()

func _physics_process(delta: float) -> void:
	var dir : Vector2 = Vector2.ZERO
	if (!menuHud.visible): 
		dir = Input.get_vector("Left", "Right", "Up", "Down")
		
		if (dir.x != 0):
			dir.x *= speed * delta * 2
			if((dir.x < 0 && velocity.x > 0) || (dir.x > 0 && velocity.x < 0)): dir.x += (velocity.x * 0.65)
			else: dir.x += velocity.x
			if (dir.x > speed): dir.x = speed
			elif (dir.x < -speed): dir.x = -speed
		elif (abs(velocity.x) > 10): dir.x = velocity.x * 0.8
		else: dir.x = 0
		
		if (dir.y != 0):
			dir.y *= speed * delta * 2
			if((dir.y < 0 && velocity.y > 0) || (dir.y > 0 && velocity.y < 0)): dir.y += (velocity.y * 0.65)
			else: dir.y += velocity.y
			if (dir.y > speed): dir.y = speed
			elif (dir.y < -speed): dir.y = -speed
		elif (abs(velocity.y) > 10): dir.y = velocity.y * 0.8
		else: dir.y = 0 
	
	if (abs(dir.x) > maxSpeed): dir.x = maxSpeed * (dir.x / abs(dir.x))
	if (abs(dir.y) > maxSpeed): dir.y = maxSpeed * (dir.y / abs(dir.y))
	velocity = dir
	var pos = position
	if(move_and_slide()):
		collides.emit(get_last_slide_collision())
		dir = dir.normalized()
		pos = abs(pos - position) / abs(dir)
		dir = (dir / abs(dir)) * bounceForce * -1
		if (pos.x > pos.y): velocity.y = dir.y
		elif (pos.x < pos.y): velocity.x = dir.x
		else: velocity = dir
