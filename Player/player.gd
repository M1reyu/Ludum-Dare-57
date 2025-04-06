extends CharacterBody2D

signal collides(collision: KinematicCollision2D)

@export var speed : int = 800
@export var speedLimit : int = 1500
@export var bounceForce : int = 1000
#@export var gravity : int = 300

@export var maxHealth : int = 1
@export var maxTank : int = 100
@export var maxCargo : int = 5

var strength : int = 2
var inMenu : bool = false

var curHealth : int = 1
var curTank : int = 100
var curCargo : int = 0

@onready var menuHud : Control = $MainCam/MenuHud

const shopItem = preload("res://globalVars.gd").shopBuyables

func _ready() -> void:
	curHealth = maxHealth
	curTank = maxTank

var posTimeout = 0
func _process(delta: float) -> void:
	if (!menuHud.visible && Input.is_action_just_pressed("MenuTrigger")): menuHud.show()
	if posTimeout > 0: posTimeout -= delta
	else:
		posTimeout = 1.0
		print(position)

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
	
	if (abs(dir.x) > speedLimit): dir.x = speedLimit * (dir.x / abs(dir.x))
	if (abs(dir.y) > speedLimit): dir.y = speedLimit * (dir.y / abs(dir.y))
	velocity = dir
	var pos : Vector2 = position
	if(move_and_slide()):
		collides.emit(get_last_slide_collision())
		if dir != Vector2.ZERO:
			dir = dir.normalized()
			pos = abs(pos - position) / abs(dir)
			dir = (dir / abs(dir)) * bounceForce * -1
			if (pos.x > pos.y): velocity.y = dir.y
			elif (pos.x < pos.y): velocity.x = dir.x
			else: velocity = dir
		
		if (abs(dir.x) > speedLimit): dir.x = speedLimit * (dir.x / abs(dir.x))
		if (abs(dir.y) > speedLimit): dir.y = speedLimit * (dir.y / abs(dir.y))

func _on_menu_hud_buy_shop_selection(itemType: int) -> void:
	match itemType:
		shopItem.Repair:
			curHealth = maxHealth
		shopItem.Refuel:
			pass
		shopItem.Shield:
			pass
		shopItem.Bomb:
			pass
		shopItem.Miner:
			pass
		shopItem.HealthUp:
			pass
		shopItem.SpeedUp:
			pass
		shopItem.StrengthUp:
			pass
		shopItem.TankUp:
			pass
		shopItem.CargoUp:
			pass
		shopItem.Scanner:
			pass
		shopItem.RangeMine:
			pass
