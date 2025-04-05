extends Node2D

@export var ground: TileMapLayer

func _ready() -> void:
    # build the world
    var _tmp = 0
    var _vf = WorldFactory.new(ground)
    #print("I am %s and my ground is " % get_path(), ground)
