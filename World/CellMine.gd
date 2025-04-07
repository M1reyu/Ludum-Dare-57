extends Cell
class_name Mine

var damage: int = 1

func _init(section: int = 0) -> void:
    super._init(section)
    
    @warning_ignore('integer_division')
    damage = max(1, section / 2)
