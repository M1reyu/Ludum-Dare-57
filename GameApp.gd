extends Node2D

@export var ground: TileMapLayer
@onready var mainCam: Camera2D = get_node("Player/MainCam")

func _ready() -> void:
    # build the world
    if mainCam != null:
        mainCam.zoom = Vector2(0.5, 0.5)
    var _vf = WorldFactory.new(ground)
    #print("I am %s and my ground is " % get_path(), ground)
