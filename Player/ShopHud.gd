extends Control

var canClose : bool = false
var menuIndex : int = 0
var MenuSection1 : Node
var MenuSection2 : Node
var MenuSection3 : Node

var MenuSection1Count : int = 0
var MenuSection2Count : int = 0
var MenuSection3Count : int = 0

var ItemName : Label
var ItemInfo : Label
var ItemCost : Label

const globals = preload("res://globalVars.gd")
const shopItem = globals.shopBuyables
var shopCalc = globals.ShopCalc.new()
signal buyShopSelection(itemIndex : int)

var funds: int
var hp: int
var hpMax: int
var fuel: int
var fuelMax: int
var cargo: int
var cargoMax: int
var speedMax: int
var strength : int
var bombs: int
var miners: int
var shielded: bool
var scanner: bool
var flagging: bool
var rangeMine: bool

func _ready() -> void:
	MenuSection1 = $ShopSelector/Utilities
	MenuSection1Count = MenuSection1.get_child_count()
	
	MenuSection2 = $ShopSelector/Upgrades
	MenuSection2Count = MenuSection2.get_child_count()
	
	MenuSection3 = $ShopSelector/Apilities
	MenuSection3Count = MenuSection3.get_child_count()
	
	ItemName = $Layout/InfoPanel/ItemName
	ItemInfo = $Layout/InfoPanel/ItemInfo
	ItemCost = $Layout/InfoPanel/ItemCost
	
	hide()

func _process(_delta: float) -> void:
	if (visible && canClose && Input.is_action_just_pressed("MenuTrigger")): 
		canClose = false
		hide()
	
	if (!visible): return
	if (!canClose):
		canClose = true
		menuIndex = 1
		highlightMenu()
	
	if (Input.is_action_just_pressed("Left")): 
		menuIndex -= 1
		if menuIndex == 0: menuIndex += MenuSection1Count
		elif menuIndex == MenuSection1Count: menuIndex += MenuSection2Count
		elif menuIndex == MenuSection1Count + MenuSection2Count: menuIndex += MenuSection3Count
	elif (Input.is_action_just_pressed("Right")): 
		if menuIndex == MenuSection1Count: menuIndex -= MenuSection1Count
		elif menuIndex == MenuSection1Count + MenuSection2Count: menuIndex -= MenuSection2Count
		elif menuIndex == MenuSection1Count + MenuSection2Count + MenuSection3Count: menuIndex -= MenuSection3Count
		menuIndex += 1 
	elif (Input.is_action_just_pressed('Up')):
		if menuIndex <= MenuSection1Count: menuIndex = MenuSection1Count + MenuSection2Count + 1
		elif menuIndex <= MenuSection1Count + MenuSection2Count: menuIndex = 1
		else: menuIndex = MenuSection1Count + 1
	elif (Input.is_action_just_pressed('Down')):
		if menuIndex <= MenuSection1Count: menuIndex = MenuSection1Count + 1
		elif menuIndex <= MenuSection1Count + MenuSection2Count: menuIndex = MenuSection1Count + MenuSection2Count + 1
		else: menuIndex = 1
	elif (Input.is_action_just_pressed('Use')):
		var cost = getCostForItem()
		if (0 < cost && cost <= funds):
			buyShopSelection.emit(menuIndex)
	else: return
	
	highlightMenu()

func highlightMenu():
	var iMod = menuIndex
	var nodeCount = MenuSection1.get_child_count()
	var node : Node
	for i in range(nodeCount):
		node = MenuSection1.get_child(i)
		if (i+1 == iMod): node.show()
		else: node.hide()
	
	iMod -= nodeCount
	
	nodeCount = MenuSection2.get_child_count()
	for i in range(nodeCount):
		node = MenuSection2.get_child(i)
		if (i+1 == iMod): node.show()
		else: node.hide()
	
	iMod -= nodeCount
	
	nodeCount = MenuSection3.get_child_count()
	for i in range(nodeCount):
		node = MenuSection3.get_child(i)
		if (i+1 == iMod): node.show()
		else: node.hide()
	
	ItemName.text = globals.itemNames.get(menuIndex)
	ItemInfo.text = globals.itemInfos.get(menuIndex)
	var cost = getCostForItem()
	ItemCost.text = "-" if cost < 0 else str(cost)
	if funds < cost: ItemCost.set("theme_override_colors/font_color", Color.RED)
	else: ItemCost.set("theme_override_colors/font_color", Color.BLACK)

func getCostForItem() -> int:
	match menuIndex:
		shopItem.Repair:
			return shopCalc.getCost(menuIndex, hp, hpMax)
		shopItem.Refuel:
			return shopCalc.getCost(menuIndex, fuel, fuelMax)
		shopItem.Bomb:
			return -1 if (bombs == 10) else shopCalc.getCost(menuIndex)
		shopItem.Miner:
			return -1 if (miners == 10) else shopCalc.getCost(menuIndex)
		shopItem.HealthUp:
			return shopCalc.getCost(menuIndex, hpMax)
		shopItem.SpeedUp:
			return shopCalc.getCost(menuIndex, speedMax)
		shopItem.StrengthUp:
			return shopCalc.getCost(menuIndex, strength)
		shopItem.TankUp:
			return shopCalc.getCost(menuIndex, fuelMax)
		shopItem.CargoUp:
			return shopCalc.getCost(menuIndex, cargoMax)
		shopItem.Scanner:
			return shopCalc.getCost(menuIndex, 1 if scanner else 0)
		shopItem.Flag:
			return shopCalc.getCost(menuIndex, 1 if flagging else 0)
		shopItem.RangeMine:
			return shopCalc.getCost(menuIndex, 1 if rangeMine else 0)
	
	return shopCalc.getCost(menuIndex)

func _on_player_player_stats(funds: int, hp: int, hpMax: int, fuel: int, fuelMax: int, cargo: int, cargoMax: int, speedMax: int, strength : int, bombs: int, miners: int, shielded: bool, scanner: bool, flagging: bool, rangeMine: bool) -> void:
	self.funds = funds
	self.hp = hp
	self.hpMax = hpMax
	self.fuel = fuel
	self.fuelMax = fuelMax
	self.cargo = cargo
	self.cargoMax = cargoMax
	self.speedMax = speedMax
	self.strength = strength
	self.bombs = bombs
	self.miners = miners
	self.shielded = shielded
	self.scanner = scanner
	self.flagging = flagging
	self.rangeMine = rangeMine
