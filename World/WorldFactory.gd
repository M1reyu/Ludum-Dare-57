extends Node
class_name WorldFactory

var worldState: Array = Array()
var random: RandomNumberGenerator
var ground: TileMapLayer
var xCenter: int
var yCenter: int
var globalSection: int

const SECTION_ROWS: int = 3
const SECTION_COUNT = 4

const TILE_GROUND: Vector2i = Vector2i(0, 0)
const TILE_MINED: Vector2i = Vector2i(1, 2)

func _init(tml: TileMapLayer) -> void:
    ground = tml
    random = RandomNumberGenerator.new()
    random.randomize()
    
    buildWorld()
    printWorld()

func buildWorld() -> void:
    print('Loading ... building world')
    
    var radius = SECTION_ROWS * SECTION_COUNT
    xCenter = radius
    yCenter = radius
    prepareWorldContainer(radius)
    
    globalSection = SECTION_COUNT
    
    # start from the inner to the outer
    for section in range(SECTION_COUNT):
        buildPlanetLayer(SECTION_ROWS * (section + 1))
        globalSection -= 1
    

func buildCell(section: int, randModifier: float) -> Cell:
    var randF: float = random.randf() + randModifier
    
    # the first section contains no mines
    if section > 1 && randF > (0.95 - (section * 0.01)):
        return Mine.new(section)
    elif randF > (0.7 - (section * 0.05)):
        return Ore.new(section)
    elif randF < -0.95:
        # the first row could have already mined cells
        section = 0
    
    return Cell.new(section)

func addCell(x: int, y: int, randModifier: float = 0.0) -> void:
    worldState[y][x] = buildCell(globalSection, randModifier)
    setCellTile(Vector2i(x, y))

func drill(cellPosition: Vector2i) -> void:
    var x: int = cellPosition.x
    var y: int = cellPosition.y
    var cell: Cell = worldState[y][x]
    print("Drill: (%d, %d), health: %d" % [x, y, cell.healthPoints])
    
    if cell.isMined():
        return

    cell.healthPoints -= 1
    setCellTile(cellPosition)

func printWorld() -> void:
    print("World state:")
    
    for row in worldState:
        var out: String = ""
        for cell in row:
            if is_instance_of(cell, Ore):
                out += "O"
            elif is_instance_of(cell, Mine):
                out += "M"
            elif is_instance_of(cell, Cell):
                if cell.isMined() == true:
                    out += "~"
                else:
                    out += "X"
            else:
                out += "-"
        print(out)

func addCellsOnVerticalLineToCenter(x: int, y: int) -> void:
    # draw a column-line from y to y = 0
    if y > yCenter:
        addCellsOnLineFromTo(x, y, yCenter - 1, -1)
    elif y < yCenter:
        addCellsOnLineFromTo(x, y, yCenter)
    elif doesCellExist(x, y) == false:
        addCell(x, y)

func addCellsOnLineFromTo(x: int, yStart: int, yEnd: int, steps: int = 1) -> void:
    if doesCellExist(x, yStart):
        return
    
    if globalSection == 1:
        # the most outer row layer contains base dirt cells only
        addCell(x, yStart, -1.0)
        yStart += steps
    
    for y in range(yStart, yEnd, steps):
        if doesCellExist(x, y):
            return
        addCell(x, y)

func doesCellExist(x: int, y: int) -> bool:
    return worldState[y][x] != null

# draw 8 points going away from each corner
func buildSymmetric8PointsAndLines(x: int, y: int) -> void:
    addCellsOnVerticalLineToCenter(xCenter + x, yCenter + y)
    addCellsOnVerticalLineToCenter(xCenter - x, yCenter + y)
    addCellsOnVerticalLineToCenter(xCenter + x, yCenter - y)
    addCellsOnVerticalLineToCenter(xCenter - x, yCenter - y)
    addCellsOnVerticalLineToCenter(xCenter + y, yCenter + x)
    addCellsOnVerticalLineToCenter(xCenter - y, yCenter + x)
    addCellsOnVerticalLineToCenter(xCenter + y, yCenter - x)
    addCellsOnVerticalLineToCenter(xCenter - y, yCenter - x)

func prepareWorldContainer(radius: int) -> void:
    var size: int = radius * 2 + 1
    worldState.resize(size)
    for i in range(size):
        worldState[i] = Array()
        worldState[i].resize(size)
        worldState[i].fill(null)

func buildPlanetLayer(radius: int) -> void:
    # create a filled circle by utilizing Bresenham's algorithm
    var x: int = 0
    var y: int = radius
    var d: int = 3 - 2 * radius # decision parameter
    
    buildSymmetric8PointsAndLines(x, y)
    
    while x <= y:
        if d > 0:
            y -= 1
            d = d + 4 * (x - y) + 10
        else:
            d = d + 4 * x + 6
        
        x += 1
        buildSymmetric8PointsAndLines(x, y)

func setCellTile(position: Vector2i) -> void:
    var cell: Cell = worldState[position.y][position.x]
    
    if cell == null:
        return
    
    var tile: Vector2i = TILE_GROUND
    var alternative: int = 0
    
    if cell.isMined():
        tile = TILE_MINED
    elif cell.isDamaged():
        alternative = 1
     
    ground.set_cell(position, 1, tile, alternative)
