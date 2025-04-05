extends Object
class_name Cell

var healthPoints: int = 0
var resistance: int = 0

func _init(section: int = 1) -> void:
    healthPoints = getBaseHealthPoints()
    
func getBaseHealthPoints() -> int:
    return 2
