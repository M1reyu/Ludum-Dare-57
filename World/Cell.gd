extends Object
class_name Cell

var _baseHealth: int = 2
var _resistance: int = 0 # todo

var healthPoints: int = 0

func _init(section: int = 0) -> void:
    if section == 0:
        # if no section is give, that means the cell should be mined
        return
    
    if section > 1:
        _baseHealth <<= section - 1
    
    healthPoints = _baseHealth
    
func isMined() -> bool:
    return healthPoints <= 0
    
func isDamaged() -> bool:
    return healthPoints < _baseHealth && isMined() == false
