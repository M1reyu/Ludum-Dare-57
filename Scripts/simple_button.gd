class_name SimpleButton
extends Button

enum AlignmentEnum {LEFT, CENTER, RIGHT}

@export_file('*.tscn') var targetScenePath: String = ''
@export var textAlignment: AlignmentEnum = AlignmentEnum.LEFT:
    set(value):
        if value == AlignmentEnum.CENTER:
            self.alignment = HORIZONTAL_ALIGNMENT_CENTER
        elif value == AlignmentEnum.RIGHT:
            self.alignment = HORIZONTAL_ALIGNMENT_RIGHT
        else:
            self.alignment = HORIZONTAL_ALIGNMENT_LEFT
@export var hasInitialFocus: bool = false

func _init() -> void:
    self.alignment = HORIZONTAL_ALIGNMENT_LEFT

func _ready() -> void:
    if self.hasInitialFocus == true:
        grab_focus()
    
    self.mouse_entered.connect(_on_button_mouse_entered)
    self.pressed.connect(_on_button_pressed)
    

func _on_button_mouse_entered() -> void:
    if self.has_focus() == false:
        grab_focus()
    
func _on_button_pressed() -> void:
    if targetScenePath == '':
        return
    
    get_tree().change_scene_to_file(targetScenePath)
