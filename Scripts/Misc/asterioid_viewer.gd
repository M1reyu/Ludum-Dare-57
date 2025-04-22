extends Node2D

@export var speed : int = 2000
@onready var cam : Camera2D = $Camera2D

func _process(delta: float) -> void:
	if Input.is_action_pressed("MenuTrigger"):
		cam.zoom *= 0.98
	elif Input.is_action_pressed("Use"):
		cam.zoom *= 1.02
	
	var dir = Input.get_vector("Left", "Right", "Up", "Down")
	dir *= speed * delta
	cam.position += dir
	
	if Input.is_action_just_pressed("UseTnT"):
		$Asteroid.toggleNumOverlay()
	if Input.is_action_just_pressed("UseMiner"):
		$Asteroid.toggleSectionOverlay()
