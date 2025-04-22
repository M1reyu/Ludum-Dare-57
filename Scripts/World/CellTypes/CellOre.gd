extends Cell
class_name Ore

var _sectionMod: float = 0.5

func _init(section: int = 0) -> void:
    super._init(section)
    # value increases in deeper layers
    value = section + randi_range(0, 1 + int(_sectionMod * section))
    
