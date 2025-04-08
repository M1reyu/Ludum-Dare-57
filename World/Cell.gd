extends Object
class_name Cell

var _baseHealth: int = 2
var _resistance: int = 1

var healthPoints: int = 0
var value: int = 0
var tileVariant: int = 0
var isFlagged: bool = false

func _init(section: int = 0) -> void:
    if section == 0:
        # if no section is give, that means the cell should be mined
        return
    
    if section > 1:
        _baseHealth <<= section - 1
        
        if section > 2:
            _resistance += section * 1.5
    
    healthPoints = _baseHealth
    tileVariant = calculateTileVariant()
    
func isMined() -> bool:
    return healthPoints <= 0
    
func isDamaged() -> bool:
    return healthPoints < _baseHealth && isMined() == false
    
func drill(damage: int = 1) -> void:
    if isFlagged == true:
        return

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

func calculateTileVariant() -> int:
    var randF: float = randf()
    
    if randF > 0.9:
        return 0
    
    if randF > 0.7:
        return 1
        
    if randF > 0.35:
        return 2
    
    return 3
