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

var curMoney : int = 0
var curHealth : int = 1
var curTank : float = 100.0
var curCargo : int = 0
var shielded : bool = false
var bombCount : int = 0
var minerCount : int = 0
var scannerBought : bool = false
var flaggingBought : bool = false
var mineRangeBought : bool = false

@onready var menuHud : Control = $Canvas/ShopHud
@onready var playerSprite : AnimatedSprite2D = $PlayerSprite

const shopItem = preload("res://globalVars.gd").shopBuyables

signal playerStats(funds : int, hp : int, fuel : int, cargo : int, bombs : int, miners : int, shielded : bool, scanner : bool, flagging : bool, rangeMine : bool)

func _ready() -> void:
	curHealth = maxHealth
	curTank = maxTank

var posTimeout = 0
func _process(_delta: float) -> void:
	if (canOpen && !menuHud.visible && Input.is_action_just_pressed("MenuTrigger")): 
		sendStatSignal()
		menuHud.show()
	
	var dirMod = directionMod(Input.get_vector("Left", "Right", "Up", "Down"))
	if (dirMod == Vector2.ZERO || menuHud.visible): 
		playerSprite.rotation_degrees = 0
		if (playerSprite.animation != "Idle"): playerSprite.play("Idle")
	else:
		playerSprite.rotation = dirMod.angle() - Vector2.DOWN.angle()
		if (playerSprite.animation == "Idle"): playerSprite.play("Drill 1")

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

func sendStatSignal() -> void:
	playerStats.emit(curMoney, curHealth, curTank, curCargo, bombCount, minerCount, shielded, scannerBought, flaggingBought, mineRangeBought)

func directionMod(dir : Vector2) -> Vector2:
	if dir.x < 0: dir.x = -1
	elif dir.x > 0: dir.x = 1
	
	if dir.y < 0: dir.y = -1
	elif dir.y > 0: dir.y = 1
	return dir

func _on_menu_hud_buy_shop_selection(itemType: int) -> void:
	match itemType:
		shopItem.Repair:
			curMoney -= (maxHealth - curHealth) * 150
			curHealth = maxHealth
		shopItem.Refuel:
			curMoney -= (maxTank - curTank)
			curTank = maxTank
		shopItem.Shield:
			curMoney -= 100
			shielded = true
		shopItem.Bomb:
			curMoney -= 300
			bombCount += 1
		shopItem.Miner:
			curMoney -= 1000
			minerCount += 1
		shopItem.HealthUp:
			curMoney -= maxHealth * 500
			maxHealth += 1
			curHealth = maxHealth
		shopItem.SpeedUp:
			curMoney -= speed * 2
			speed += 200
		shopItem.StrengthUp:
			curMoney -= strength * 750
			strength *= 2
		shopItem.TankUp:
			curMoney -= maxTank * 5
			maxTank *= 2
			curTank = maxTank
		shopItem.CargoUp:
			curMoney -= 200 + maxCargo * 50
			maxCargo += 5
		shopItem.Scanner:
			curMoney -= 2500
			scannerBought = true
		shopItem.Flag:
			curMoney -= 5000
			flaggingBought = true
		shopItem.RangeMine:
			curMoney -= 5000
			mineRangeBought = true
	
	sendStatSignal()

func _on_player_tig_area_area_entered(_area: Area2D) -> void:
	canOpen = true
	curMoney += curCargo * 100
	curCargo = 0
	
	sendStatSignal()

func _on_player_tig_area_area_exited(_area: Area2D) -> void:
	canOpen = false
	
	sendStatSignal()
