extends Node
class_name PositionBounds
# helper class for loop bounds over the world state array

var xMin: int = 0
var xMax: int = 0
var yMin: int = 0
var yMax: int = 0

func _init(position: Vector2i, target: Array) -> void:
    var size: int = target.size() - 1
    
    if position.x != 0:
        xMin = position.x - 1
    
    if position.y != 0:
        yMin = position.y - 1
    
    xMax = size if position.x == size else position.x + 1
    yMax = size if position.y == size else position.y + 1
    
