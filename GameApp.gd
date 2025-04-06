extends Node2D

@onready var ground: TileMapLayer = get_node("Ground")
@onready var player: CharacterBody2D = get_node("Player")
@onready var mainCam: Camera2D = get_node("Player/MainCam")

var world: WorldFactory

func _ready() -> void:
    # build the world
    if mainCam != null:
        mainCam.zoom = Vector2(0.5, 0.5)
    world = WorldFactory.new(ground)
    #print("I am %s and my ground is " % get_path(), ground)
    if player != null:
        player.collides.connect(_on_collision_detected)
        
func _on_collision_detected(collision: KinematicCollision2D) -> void:
    print("Collision detected")
    var cellPosition: Vector2i = ground.get_coords_for_body_rid(collision.get_collider_rid())
    world.drill(cellPosition)
