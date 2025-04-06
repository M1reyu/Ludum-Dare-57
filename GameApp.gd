extends Node2D

@onready var ground: TileMapLayer = get_node("Ground")
@onready var player: CharacterBody2D = get_node("Player")
@onready var mainCam: Camera2D = get_node("Player/MainCam")

var world: WorldFactory

func _ready() -> void:
    # build the world
    world = WorldFactory.new(ground)
    
    # adapt the player zoom level
    if mainCam != null:
        mainCam.zoom = Vector2(0.25, 0.25)
    
    # adapt the player position
    if player != null:
        player.collides.connect(_on_collision_detected)
        var center: int = WorldFactory.SECTION_ROWS * WorldFactory.SECTION_COUNT
        var centerPoint = ground.map_to_local(Vector2i(center, center))
        player.global_position = Vector2(centerPoint.x, player.global_position.y)
        
func _on_collision_detected(collision: KinematicCollision2D) -> void:
    var cellPosition: Vector2i = ground.get_coords_for_body_rid(collision.get_collider_rid())
    world.drill(cellPosition)
