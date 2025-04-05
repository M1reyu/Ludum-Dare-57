extends Object
class_name Cell

var healthPoints: int = 0
var resistance: int = 0

func _init(section: int = 0) -> void:
    healthPoints = getBaseHealthPoints() << section
    
func getBaseHealthPoints() -> int:
    return 2
    
func isMined() -> bool:
    return healthPoints <= 0
