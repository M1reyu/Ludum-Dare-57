extends Node2D

@onready var tileLayer: Node2D = get_node("Ground")
@onready var ground: TileMapLayer = get_node("Ground/Ground")
@onready var numbers: TileMapLayer = get_node("Ground/Numbers")
@onready var player: CharacterBody2D = get_node("Player")
@onready var mainCam: Camera2D = get_node("Player/MainCam")

var world: WorldFactory

func _ready() -> void:
    # build the world
    world = WorldFactory.new(ground, numbers)
    
    # adapt the player zoom level
    if mainCam != null:
        mainCam.zoom = Vector2(0.4, 0.4)
    
    if player != null:
        player.collides.connect(_on_collision_detected)
        player.scan.connect(world._on_scan)
        
        world.explosion.connect(player._on_explosion)
        world.minedValuable.connect(player._on_collect_valuable)
    
    # adapt the matrix position of the generated world to be centered below the player
    var center: int = WorldFactory.SECTION_ROWS * WorldFactory.SECTION_COUNT
    var centerPoint = ground.map_to_local(Vector2i(center, center))
    tileLayer.position = Vector2(-centerPoint.x, 0)    

func _on_collision_detected(collision: KinematicCollision2D) -> void:
    var cellPosition: Vector2i = ground.get_coords_for_body_rid(collision.get_collider_rid())
    world.drill(cellPosition, player.strength)
