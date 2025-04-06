extends Control

var canClose : bool = false
var menuIndex : int = 0
var utilityMenu : Panel
var itemMenu : Panel
var upgradeMenu : Panel



func _ready() -> void:
	utilityMenu = $Utilities
	itemMenu = $Items
	upgradeMenu = $Upgrades
	hide()

func _process(_delta: float) -> void:
	if (visible && canClose && Input.is_action_just_pressed("MenuTrigger")): 
		canClose = false
		hide()
	
	if (!visible): return
	if (!canClose):
		canClose = true
		menuIndex = 0
		
	

func highlightMenu():
	for i in Range(0, utilityMenu.get_child_count()):
		utilityMenu.get_child(i).atr()
		utilityMenu.modulate = Color.GOLD
	
	for i in Range(0, itemMenu.get_child_count()):
		utilityMenu.get_child(i).atr()
		utilityMenu.modulate = Color.GOLD
	
	for i in Range(0, upgradeMenu.get_child_count()):
		utilityMenu.get_child(i).atr()
		utilityMenu.modulate = Color.GOLD
