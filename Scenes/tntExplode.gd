extends Node2D

signal explode(coordinates : Vector2i)

func explodeTnt() -> void:
	explode.emit(Vector2i(global_position))
