extends Cell
class_name Mine

const DAMAGE_RADIUS = 320

var damage: int = 1

func _init(section: int = 0) -> void:
    super._init(section)
    
    damage += int(section / 3)
