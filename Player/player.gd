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
var canOpen : bool = false

var curHealth : int = 1
var curTank : float = 100.0
var curCargo : int = 0
var shielded : bool = false
var bombCount : int = 0
var minerCount : int = 0
var scannerBought : bool = false
var flaggingBought : bool = false
var mineRangeBought : bool = false

@onready var menuHud : Control = $MainCam/MenuHud

const shopItem = preload("res://globalVars.gd").shopBuyables

func _ready() -> void:
	curHealth = maxHealth
	curTank = maxTank

var posTimeout = 0
func _process(_delta: float) -> void:
	if (canOpen && !menuHud.visible && Input.is_action_just_pressed("MenuTrigger")): menuHud.show()

func _physics_process(delta: float) -> void:
	var dir : Vector2 = Vector2.ZERO
	var dirMod : Vector2
	
	if (!menuHud.visible): 
		dir = Input.get_vector("Left", "Right", "Up", "Down")
		if dir != Vector2.ZERO: curTank -= delta
		
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
	
	dirMod = directionMod(dir)
	if (abs(dir.x) > speedLimit): dir.x = speedLimit * dirMod.x
	if (abs(dir.y) > speedLimit): dir.y = speedLimit * dirMod.y
	#if (dirMod = Vector2.ZERO && )
	velocity = dir
	var pos : Vector2 = position
	if(move_and_slide()):
		collides.emit(get_last_slide_collision())
		if dir != Vector2.ZERO:
			dir = dir.normalized()
			pos = abs(pos - position) / abs(dir)
			dirMod = directionMod(dir)
			dir = dirMod * bounceForce * -1
			if (pos.x > pos.y): velocity.y = dir.y
			elif (pos.x < pos.y): velocity.x = dir.x
			else: velocity = dir
		
		if (abs(dir.x) > speedLimit): dir.x = speedLimit * (dir.x / abs(dir.x))
		if (abs(dir.y) > speedLimit): dir.y = speedLimit * (dir.y / abs(dir.y))

func directionMod(dir : Vector2) -> Vector2:
	if dir.x < 0: dir.x = -1
	elif dir.x > 0: dir.x = 1
	
	if dir.y < 0: dir.y = -1
	elif dir.y > 0: dir.y = 1
	return dir

func _on_menu_hud_buy_shop_selection(itemType: int) -> void:
	match itemType:
		shopItem.Repair:
			curHealth = maxHealth
		shopItem.Refuel:
			curTank = maxTank
		shopItem.Shield:
			shielded = true
		shopItem.Bomb:
			bombCount += 1
		shopItem.Miner:
			minerCount += 1
		shopItem.HealthUp:
			maxHealth += 1
			curHealth = maxHealth
		shopItem.SpeedUp:
			speed += 200
		shopItem.StrengthUp:
			strength *= 2
			print("StrengthUp: " + str(strength))
		shopItem.TankUp:
			maxTank *= 2
			curTank = maxTank
		shopItem.CargoUp:
			maxCargo *= 2
		shopItem.Scanner:
			scannerBought = true
		shopItem.Flag:
			flaggingBought = true
		shopItem.RangeMine:
			mineRangeBought = true

func _on_player_tig_area_area_entered(_area: Area2D) -> void:
	canOpen = true

func _on_player_tig_area_area_exited(_area: Area2D) -> void:
	canOpen = false
