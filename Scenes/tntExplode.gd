extends Node2D

class_name TNTNode

signal explode(coordinates : Vector2i, dmg : int)

func explodeTnt() -> void:
	explode.emit(
		Vector2i(global_position), 
		GlobalVars.cooldowns.get(GlobalVars.shopBuyables.Bomb)
	)
