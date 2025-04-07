extends Object
class_name Cell

var _baseHealth: int = 2
var _resistance: int = 0

var healthPoints: int = 0
var value: int = 0
var tileVariant: int = 0

func _init(section: int = 0) -> void:
    if section == 0:
        # if no section is give, that means the cell should be mined
        return
    
    if section > 1:
        _baseHealth <<= section - 1
    
    healthPoints = _baseHealth
    tileVariant = randi_range(0, 3)
    
func isMined() -> bool:
    return healthPoints <= 0
    
func isDamaged() -> bool:
    return healthPoints < _baseHealth && isMined() == false
    
func drill(damage: int = 1) -> void:
    damage -= _resistance
    if damage > 0:
        healthPoints -= damage

func getTileDamageOffset() -> int:
    if not isDamaged() || isMined() || _baseHealth == 0:
        return 0
    
    var healthInPercent: float = float(healthPoints) / float(_baseHealth)
    print(healthInPercent)
    
    if healthInPercent > 0.67:
        return 1
    
    if healthInPercent > 0.34:
        return 2
    
    return 3
