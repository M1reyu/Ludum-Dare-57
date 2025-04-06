extends Node
class_name WorldFactory

var worldState: Array = Array()
var random: RandomNumberGenerator
var ground: TileMapLayer

const SECTION_COLUMNS: int = 7
const SECTION_ROWS: int = 3
const SECTION_COUNT = 2

const TILE_GROUND: Vector2i = Vector2i(0, 0)
const TILE_MINED: Vector2i = Vector2i(1, 2)

func _init(tml: TileMapLayer) -> void:
    ground = tml
    random = RandomNumberGenerator.new()
    random.randomize()
    buildWorld()
    printWorld()
    

func buildWorld() -> void:
    print('Loading ...')
    
    var totalRows: int = SECTION_ROWS * SECTION_COUNT
    worldState.resize(totalRows)
    
    # the first row contains just base dirt cells
    buildRow(0, -1.0)
    
    for row in range(1, totalRows):
        buildRow(row)
        
func buildRow(row: int, randModifier: float = 0.0) -> void:
    @warning_ignore("integer_division")
    var currentSection: int = row / SECTION_ROWS
    worldState[row] = Array()
    worldState[row].resize(SECTION_COLUMNS)
    
    for column in range(SECTION_COLUMNS):
        addCell(row, column, buildCell(currentSection, randModifier))

func buildCell(section: int, randModifier: float) -> Cell:
    var randF: float = random.randf() + randModifier
    
    if randF > (0.95 - (section * 0.01)):
        return Mine.new(section)
    elif randF > (0.7 - (section * 0.05)):
        return Ore.new(section)
    
    return Cell.new(section)

func addCell(row: int, column: int, cell: Cell) -> void:
    worldState[row][column] = cell
    ground.set_cell(Vector2i(row, column), 1, TILE_GROUND)

func drill(cellPosition: Vector2i) -> void:
    var row: int = cellPosition.x
    var column: int = cellPosition.y
    var cell: Cell = worldState[row][column]
    print("Drill: (%d, %d), health: %d" % [row, column, cell.healthPoints])
    
    if cell.isMined():
        return
        
    if cell.getBaseHealthPoints() == cell.healthPoints:
        ground.set_cell(cellPosition, 1, TILE_GROUND, 1)
    
    cell.healthPoints -= 1
    if cell.isMined():
        # print another tile image
        ground.set_cell(cellPosition, 1, TILE_MINED)

func printWorld() -> void:
    print("World state:")
    for row in worldState:
        var out = ""
        for cell in row:
            if is_instance_of(cell, Ore):
                out += "O"
            elif is_instance_of(cell, Mine):
                out += "M"
            else:
                out += "X"
        print(out)
