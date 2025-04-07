extends Cell
class_name Ore

var _baseValueMin: int = 1
var _baseValueMax: int = 2

func _init(section: int = 0) -> void:
    super._init(section)
    # value increases in deeper layers
    value = randi_range(_baseValueMin * section, _baseValueMax * section)
    
