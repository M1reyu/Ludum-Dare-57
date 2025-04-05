extends Panel

var menuIndex : int = 0
var canClose : bool = false

func _process(_delta: float) -> void:
	if (visible && canClose && Input.is_action_just_pressed("MenuTrigger")): hide()
	canClose = false
	if (!visible): return
	canClose = true
	
	
