extends Control

var canClose : bool = false
var menuIndex : int = 0
var MenuSection1 : Panel
var MenuSection2 : Panel
var MenuSection3 : Panel

var MenuSection1Count : int = 0
var MenuSection2Count : int = 0
var MenuSection3Count : int = 0

const shopItem = preload("res://globalVars.gd")
signal buyShopSelection(itemType : shopItem)

func _ready() -> void:
	MenuSection1 = $Utilities
	MenuSection1Count = MenuSection1.get_child_count()
	
	MenuSection2 = $Upgrades
	MenuSection2Count = MenuSection2.get_child_count()
	
	MenuSection3 = $Apilities
	MenuSection3Count = MenuSection3.get_child_count()
	
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
		buyShopSelection.emit(shopItem.shopBuyables.get(menuIndex))
	else: return
	
	highlightMenu()

func highlightMenu():
	var iMod = menuIndex
	var nodeCount = MenuSection1.get_child_count()
	for i in range(nodeCount):
		var node = MenuSection1.get_child(i)
		node.set('self_modulate', Color.RED if (i+1 == iMod) else Color(1,1,1,1))
	
	MenuSection1.self_modulate = Color.GOLD if (0 < iMod && iMod <= nodeCount) else Color(1,1,1,1)
	iMod -= nodeCount
	
	nodeCount = MenuSection2.get_child_count()
	for i in range(nodeCount):
		var node = MenuSection2.get_child(i)
		node.set('self_modulate', Color.RED if (i+1 == iMod) else Color(1,1,1,1))
	
	MenuSection2.self_modulate = Color.GOLD if (0 < iMod && iMod <= nodeCount) else Color(1,1,1,1)
	iMod -= nodeCount
	
	nodeCount = MenuSection3.get_child_count()
	for i in range(nodeCount):
		var node = MenuSection3.get_child(i)
		node.set('self_modulate', Color.RED if (i+1 == iMod) else Color(1,1,1,1))
	
	MenuSection3.self_modulate = Color.GOLD if (0 < iMod && iMod <= nodeCount) else Color(1,1,1,1)
