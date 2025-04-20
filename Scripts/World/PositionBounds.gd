extends Node
class_name PositionBounds
# helper class for loop bounds over the world state array

var xMin: int = 0
var xMax: int = 0
var yMin: int = 0
var yMax: int = 0

func _init(position: Vector2i, target: Array, distance: int = 1) -> void:
    var size: int = target.size() - 1
    
    xMin = max(0, position.x - distance)
    xMax = min(size, position.x + distance)
    yMin = max(0, position.y - distance)
    yMax = min(size, position.y + distance)
    
