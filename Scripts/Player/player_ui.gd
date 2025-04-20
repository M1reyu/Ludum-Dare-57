extends Control

@onready var healthBar : ProgressBar = $HUD/healthBar
@onready var cargoBar : ProgressBar = $HUD/cargoBar
@onready var fuleBar : ProgressBar = $HUD/fuleBar

@onready var money : Label = $HUD/moneyLabel

@onready var SkillTnt : Control = $Skills/SkillTnt
@onready var SkillMiner : Control = $Skills/SkillMiner
@onready var SkillScanner : Control = $Skills/SkillScanner
@onready var SkillFlag : Control = $Skills/SkillFlag

func _ready() -> void:
	SkillTnt.visible = false
	SkillMiner.visible = false
	SkillScanner.visible = false
	SkillFlag.visible = false
	show()

func _on_player_player_stats(funds: int, hp: int, hpMax: int, fuel: int, fuelMax: int, cargo: int, cargoMax: int, speedMax: int, strength : int, bombs: int, miners: int, shielded: bool, scanner: bool, flagging: bool, rangeMine: bool) -> void:
	money.text = str(funds)
	healthBar.max_value = hpMax
	fuleBar.max_value = fuelMax
	cargoBar.max_value = cargoMax
	
	healthBar.value = hp
	fuleBar.value = fuel
	cargoBar.value = cargo
	if shielded:
		healthBar.set_modulate("00ffff5f")
	else:
		healthBar.set_modulate(Color(1,1,1,1))
	
	var skillPosition: int = showSkill(bombs > 0, SkillTnt)
	skillPosition = showSkill(miners > 0, SkillMiner, skillPosition)
	skillPosition = showSkill(scanner, SkillScanner, skillPosition)
	showSkill(flagging, SkillFlag, skillPosition)

#NOTE: not displaid
	#speedMax: int,
	#strength : int,
	SkillTnt.set_label_value(str(bombs))
	SkillMiner.set_label_value(str(miners))
#TODO :
	#shielded: bool,
	#scanner: bool,
	#flagging: bool,
	#rangeMine: bool

func showSkill(isActive: bool, controlElement: Control, positionOffset: int = 0) -> int:
	if isActive == false && controlElement.visible == false:
		return positionOffset
	
	controlElement.visible = true
	controlElement.position.x = positionOffset
	
	return positionOffset + 244

func _on_activate_skill(skillType: int) -> void:
	if not GlobalVars.cooldowns.has(skillType):
		return
	
	var control: Control = null
	
	match skillType:
		GlobalVars.shopBuyables.Bomb:
			control = SkillTnt
		GlobalVars.shopBuyables.Scanner:
			control = SkillScanner
	
	if control == null:
		return
	
	var cooldown: int = GlobalVars.cooldowns.get(skillType)
	var animation: AnimationPlayer = control.get_node("AnimationPlayer")
	
	# the animation length is one second - a lower scale is a longer duration
	animation.speed_scale = 1.0 / cooldown
	animation.play("skill_cooldown")
