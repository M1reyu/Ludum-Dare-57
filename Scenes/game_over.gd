extends Node2D

func _ready() -> void:
	$CanvasLayer/Label.text = $CanvasLayer/Label.text + str(GlobalVars.playerFunds)
