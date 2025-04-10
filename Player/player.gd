extends CharacterBody2D

signal collides(collision: KinematicCollision2D)
signal scan(coordinates: Vector2)
signal tnt(coordinates: Vector2)

@export var speed : int = 800
@export var speedLimit : int = 1500
@export var bounceForce : int = 1000
#@export var gravity : int = 300

@export var maxHealth : int = 2
@export var maxTank : int = 100
@export var maxCargo : int = 5

@export_file('*.tscn') var deathScenePath: String = ''

var strength : int = 2
var inMenu : bool = false
var canOpen : bool = false

var curMoney : int = 0
var totalMoney: int = 0
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
@onready var animations : AnimationPlayer = get_node("AnimationPlayer")
@onready var flagmodeFlag : Sprite2D = $FlagMode
@onready var autominerMode : Sprite2D = $AutoMinerMode

const globals = preload("res://globalVars.gd") 
const shopItem = globals.shopBuyables
var shopCalc = globals.ShopCalc.new()

var tntScene = preload("res://Scenes/TnT.tscn")

signal playerStats(funds : int, hp : int, hpMax : int, fuel : int, fuelMax : int, cargo : int, cargoMax : int, speedMax : int, bombs : int, miners : int, shielded : bool, scanner : bool, flagging : bool, rangeMine : bool)

func _ready() -> void:
	curHealth = maxHealth
	curTank = maxTank
	playerStrength = strength
	playerSpeed = speed
	sendStatSignal()

var scanTimeout = 0
var tntTimeout = 0
func _process(delta: float) -> void:
	if scanTimeout > 0: scanTimeout -= delta
	if tntTimeout > 0: tntTimeout -= delta
	if (canOpen && !menuHud.visible && Input.is_action_just_pressed("MenuTrigger")): 
		sendStatSignal()
		menuHud.show()
	
	flagmodeFlag.visible = true if (strength == -1) else false
	autominerMode.visible = true if (strength < -1) else false
	
	var dirMod = directionMod(Input.get_vector("Left", "Right", "Up", "Down"))	
	if (dirMod == Vector2.ZERO || menuHud.visible): 
		playerSprite.rotation_degrees = 0
		if (playerSprite.animation != "Idle"): playerSprite.play("Idle")
	elif (strength >= 0):
		playerSprite.rotation = dirMod.angle() - Vector2.DOWN.angle()
		if (playerSprite.animation == "Idle"): playerSprite.play("Drill 1")
	
	if (Input.is_action_just_pressed("UseTnT")):
		if bombCount > 0 && tntTimeout <= 0:
			tntTimeout = 1
			bombCount -= 1
			var node : TNTNode = tntScene.instantiate()
			add_sibling(node)
			node.global_position = global_position
			node.explode.connect(_on_tn_t_explode)
		sendStatSignal()
	elif (Input.is_action_just_pressed("UseMiner")):
		if minerCount > 0:
			if strength != 0 && strength != -1: strength *= -1
		sendStatSignal()
	elif (Input.is_action_just_pressed("UseScan")):
		if scannerBought && scanTimeout <= 0:
			scanTimeout = 10
			scan.emit(playerSprite.global_position)
		sendStatSignal()
	elif (Input.is_action_just_pressed("UseFlag")):
		if flaggingBought:
			if strength > 0: strength = -1
			elif strength == -1: strength = playerStrength
		sendStatSignal()

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
				if strength == 0: strength = playerStrength
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

func _on_shop_hud_buy_shop_selection(itemType: int) -> void:
	var cost = 0
	
	match itemType:
		shopItem.Repair:
			cost = shopCalc.getCost(itemType, curHealth, maxHealth, curMoney)
			curHealth += (cost / 150)
			if curHealth > maxHealth: curHealth = maxHealth
		shopItem.Refuel:
			cost = shopCalc.getCost(itemType, curTank, maxTank, curMoney)
			curTank += cost
			if curTank > maxTank: curTank = maxTank
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
			strength = playerStrength
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
	AudioPlayer.play_sfx("powerUp")
	sendStatSignal()

func _on_player_tig_area_area_entered(_area: Area2D) -> void:
	canOpen = true
	var moneyEarned: int = curCargo * 100
	curMoney += moneyEarned
	totalMoney += moneyEarned
	curCargo = 0
	
	sendStatSignal()

func _on_player_tig_area_area_exited(_area: Area2D) -> void:
	canOpen = false
	
	sendStatSignal()

func _on_explosion(coordinates: Vector2i, damage: int, radius: int) -> void:
	#print("explosion...")
	if position.distance_to(coordinates) > radius:
		return

	if shielded:
		shielded = false
	else:
		curHealth -= damage
	
	if curHealth <= 0: 
		GlobalVars.playerFunds = totalMoney
		get_tree().change_scene_to_file(deathScenePath)
	sendStatSignal()


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
	sendStatSignal()

func _on_tn_t_explode(coordinates: Vector2i, dmg: int) -> void:
	_on_explosion(coordinates, dmg, 550)
	tnt.emit(coordinates)
