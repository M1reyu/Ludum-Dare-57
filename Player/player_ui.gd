extends Control

@onready var healthBar : ProgressBar = $HUD/healthBar
@onready var cargoBar : ProgressBar = $HUD/cargoBar
@onready var fuleBar : ProgressBar = $HUD/fuleBar

@onready var money : Label = $HUD/moneyLabel

@onready var SkillTnt : Control = $Skills/SkillTnt
@onready var SkillMiner : Control = $Skills/SkillMiner
@onready var SkillScanner : Control = $Skills/SkillScanner
@onready var SkillFlag : Control = $Skills/SkillFlag


func _on_player_player_stats(funds: int, hp: int, hpMax: int, fuel: int, fuelMax: int, cargo: int, cargoMax: int, speedMax: int, strength : int, bombs: int, miners: int, shielded: bool, scanner: bool, flagging: bool, rangeMine: bool) -> void:
	SkillTnt.set_label_value(str(bombs))
	SkillMiner.set_label_value(str(miners))
	money.text = str(funds)
	
