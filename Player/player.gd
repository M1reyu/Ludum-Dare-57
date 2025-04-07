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
var playerStrength : int
var playerSpeed : int

@onready var menuHud : Control = $Canvas/ShopHud
@onready var playerSprite : AnimatedSprite2D = $PlayerSprite
@onready var animations: AnimationPlayer = get_node("AnimationPlayer")

const globals = preload("res://globalVars.gd") 
const shopItem = globals.shopBuyables
var shopCalc = globals.ShopCalc.new()

signal playerStats(funds : int, hp : int, hpMax : int, fuel : int, fuelMax : int, cargo : int, cargoMax : int, speedMax : int, bombs : int, miners : int, shielded : bool, scanner : bool, flagging : bool, rangeMine : bool)

func _ready() -> void:
	curHealth = maxHealth
	curTank = maxTank
	playerStrength = strength
	playerSpeed = speed

var scanTimeout = 0
func _process(delta: float) -> void:
	if scanTimeout > 0: scanTimeout -= delta
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
	
	if (Input.is_action_just_pressed("UseTnT")):
		pass
	elif (Input.is_action_just_pressed("UseMiner")):
		pass
	elif (Input.is_action_just_pressed("UseScan")):
		pass
	elif (Input.is_action_just_pressed("UseFlag")):
		pass

func _physics_process(delta: float) -> void:
	var dir : Vector2 = Vector2.ZERO
	var dirMod : Vector2
	
	if (!menuHud.visible): 
		dir = Input.get_vector("Left", "Right", "Up", "Down")
		if (dir != Vector2.ZERO && curTank > 0): 
			if (int(curTank - delta) < int(curTank)): sendStatSignal()
			curTank -= delta
			if curTank <= 0:
				curTank = 0
				strength = 0
				speed = playerSpeed / 2
			else:
				strength = playerStrength
				speed = playerSpeed
			
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
	playerStats.emit(curMoney, curHealth, maxHealth, curTank, maxTank, curCargo, maxCargo, playerSpeed, playerStrength, bombCount, minerCount, shielded, scannerBought, flaggingBought, mineRangeBought)

func directionMod(dir : Vector2) -> Vector2:
	if dir.x < 0: dir.x = -1
	elif dir.x > 0: dir.x = 1
	
	if dir.y < 0: dir.y = -1
	elif dir.y > 0: dir.y = 1
	return dir

func _on_menu_hud_buy_shop_selection(itemType: int) -> void:
	var cost = 0
	
	match itemType:
		shopItem.Repair:
			cost = shopCalc.getCost(itemType, curHealth, maxHealth)
			curMoney -= (maxHealth - curHealth) * 150
			curHealth = maxHealth
		shopItem.Refuel:
			cost = shopCalc.getCost(itemType, curTank, maxTank)
			curTank = maxTank
		shopItem.Shield:
			cost = shopCalc.getCost(itemType)
			shielded = true
		shopItem.Bomb:
			cost = shopCalc.getCost(itemType)
			bombCount += 1
		shopItem.Miner:
			cost = shopCalc.getCost(itemType)
			minerCount += 1
		shopItem.HealthUp:
			cost = shopCalc.getCost(itemType, maxHealth)
			maxHealth += 1
			curHealth = maxHealth
		shopItem.SpeedUp:
			cost = shopCalc.getCost(itemType, playerSpeed)
			playerSpeed += 200
		shopItem.StrengthUp:
			cost = shopCalc.getCost(itemType, playerStrength)
			playerStrength *= 2
		shopItem.TankUp:
			cost = shopCalc.getCost(itemType, maxTank)
			maxTank *= 2
			curTank = maxTank
		shopItem.CargoUp:
			cost = shopCalc.getCost(itemType, maxCargo)
			maxCargo += 5
		shopItem.Scanner:
			cost = shopCalc.getCost(itemType)
			scannerBought = true
		shopItem.Flag:
			cost = shopCalc.getCost(itemType)
			flaggingBought = true
		shopItem.RangeMine:
			cost = shopCalc.getCost(itemType)
			mineRangeBought = true
	
	curMoney -= cost
	sendStatSignal()

func _on_player_tig_area_area_entered(_area: Area2D) -> void:
	canOpen = true
	curMoney += curCargo * 100
	curCargo = 0
	
	sendStatSignal()

func _on_player_tig_area_area_exited(_area: Area2D) -> void:
	canOpen = false
	
	sendStatSignal()

func _on_explosion(coordinates: Vector2i, damage: int, radius: int) -> void:
	print("explosion...")
	if position.distance_to(coordinates) > radius:
		return

	if shielded:
		shielded = false
		
		return

	curHealth -= damage

func _on_collect_valuable(value: int) -> void:
	var oldCargo: int = curCargo
	curCargo = min(curCargo + value, maxCargo)
	var diffCargo = curCargo - oldCargo
	var label: Label = get_node("orePopUp/Label")
	if diffCargo == 0:
		label.text = "full"
	else:
		label.text = "+" + str(diffCargo)
	animations.play("ore_gained")
