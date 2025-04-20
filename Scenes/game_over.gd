extends Node2D

func _ready() -> void:
	$CanvasLayer/Label.text = $CanvasLayer/Label.text + str(getGinalScore())

func getGinalScore() -> int:
	var result : int = 0
	
	result += (GlobalVars.tilesMined * 10)
	result += (GlobalVars.oreMined * 50)
	result -= (GlobalVars.minesHit * 100)
	result -= (1 + GlobalVars.timePlayed)
	result += GlobalVars.playerFunds
	
	return result
