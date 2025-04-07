extends Node
class_name PositionBounds
# helper class for loop bounds over the world state array

var xMin: int = 0
var xMax: int = 0
var yMin: int = 0
var yMax: int = 0

func _init(position: Vector2i, target: Array) -> void:
    var size: int = target.size() - 1
    
    xMin = max(0, position.x - 1)
    xMax = min(size, position.x + 1)
    yMin = max(0, position.y - 1)
    yMax = min(size, position.y + 1)
    
