extends Node
class_name WorldFactory

signal explosion(coordinates: Vector2i, damage: int)
signal minedValuable(value: int)

var worldState: Array = Array()
var random: RandomNumberGenerator
var ground: TileMapLayer
var numbers: TileMapLayer
var xCenter: int
var yCenter: int
var globalSection: int
var scanTimer: Timer

const SECTION_ROWS: int = 5
const SECTION_COUNT = 5

const ATLAS_GROUND = 0
const ATLAS_MINED = 2
const ATLAS_ORE_ONLY = 2
const ATLAS_MINES_ONLY = 3
const ATLAS_MIXED = 4

func _init(groundLayer: TileMapLayer, numberLayer: TileMapLayer) -> void:
    if groundLayer == null || numberLayer == null:
        printerr("Ground- or number-layer is missing")
        
        return

    ground = groundLayer
    numbers = numberLayer
    random = RandomNumberGenerator.new()
    random.randomize()
    
    buildWorld()
    printWorld()
    
    initTimer()

func buildWorld() -> void:
    print('Loading ... building world')
    
    prepareNumberTiles()
    
    var radius = SECTION_ROWS * SECTION_COUNT
    xCenter = radius
    yCenter = radius
    prepareWorldContainer(radius)
    
    globalSection = SECTION_COUNT
    
    # start from the inner to the outer
    for section in range(SECTION_COUNT):
        buildPlanetLayer(SECTION_ROWS * (section + 1))
        globalSection -= 1
    
    # to avoid displaying wrong numbers, because the cell are build in columns
    # we need to update all mined cells again
    for row in range(worldState.size()):
        for column in range(worldState[row].size()):
            var cell: Cell = worldState[row][column]
            if cell is Cell && cell.isMined():
                setCellTile(Vector2i(column, row))

func buildCell(section: int, randModifier: float) -> Cell:
    var randF: float = random.randf() + randModifier

    # the first section contains no mines
    if section > 1 && randF > (0.96 - (section * 0.01)):
        return Mine.new(section)
    elif randF > (0.75 - (section * 0.05)):
        return Ore.new(section)
    elif randF < -0.95:
        # the first row could have already mined cells
        section = 0
    
    return Cell.new(section)

func addCell(x: int, y: int, randModifier: float = 0.0) -> void:
    worldState[y][x] = buildCell(globalSection, randModifier)
    setCellTile(Vector2i(x, y))

func drill(cellPosition: Vector2i, damage: int) -> void:
    var x: int = cellPosition.x
    var y: int = cellPosition.y
    var cell: Cell = worldState[y][x]
    print("Drill: (%d, %d), health: %d" % [x, y, cell.healthPoints])
    
    if cell.isMined():
        return
    
    if damage >= 0: cell.drill(damage)
    elif damage == -1: cell.isFlagged = not cell.isFlagged #Toggle cell unverwundbarkeit
    
    setCellTile(cellPosition)
    
    if (cell.isFlagged || not cell.isDamaged()) && not cell.isMined():
        AudioPlayer.play_sfx("nonBreak")
    else:
        AudioPlayer.play_sfx("dig")
    
    if not cell.isMined():
        return
        
    recalculateAdjacentCellSweeperCount(cellPosition)
    
    if cell is Mine:
        AudioPlayer.play_sfx('explosion')
        explosion.emit(ground.to_global(ground.map_to_local(cellPosition)), cell.damage, Mine.DAMAGE_RADIUS)
    elif cell is Ore:
        AudioPlayer.play_sfx('pickupOre')
        minedValuable.emit(cell.value)

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
    
    var randModifier: float = 0.0
    if x == 0 or x == worldState.size() - 1:
        randModifier = -1.0
    
    for y in range(yStart, yEnd, steps):
        if doesCellExist(x, y):
            return
        addCell(x, y, randModifier)

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

func prepareNumberTiles() -> void:
    var _t = numbers.tile_set.get_source_count()
    var tileSet: TileSet = numbers.tile_set;
    var colors: Array = [
        Color(1,1,1),
        Color(0,1,0),
        Color(1,0,0),
        Color(1, 0.65, 0) # kinda orange
    ]
    
    for atlasIndex in range(tileSet.get_source_count()):
        var atlasId: int = tileSet.get_source_id(atlasIndex)
        var source: TileSetAtlasSource = tileSet.get_source(atlasId)
        if not source is TileSetAtlasSource:
            continue
        
        var color: Color = colors[atlasIndex]
        
        for tileIndex in range(source.get_tiles_count()):
            #var tileCoordinates = Vector2i(tileSetSource.get_tile_id(tileIndex)
            var tileData = source.get_tile_data(Vector2i(tileIndex, 0), 0)
            tileData.modulate = color

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
    
    var tileOffset: int = 0
    var tileVariant: int = cell.tileVariant
    var atlasId: int = ATLAS_GROUND

    if cell.isMined():
        setCellNumberTile(position)
        atlasId = ATLAS_MINED
        tileVariant = 0
    elif cell.isDamaged():
        tileOffset = cell.getTileDamageOffset()
    
    if cell.isFlagged:
        numbers.set_cell(position, 0, Vector2i(0,0))
    elif not cell.isMined():
        numbers.set_cell(position)
    
    ground.set_cell(position, atlasId, Vector2i(tileVariant, tileOffset))

func setCellNumberTile(position: Vector2i) -> void:
    var tile: Vector2i = Vector2i(-1, -1)
    var atlasId: int = ATLAS_MIXED
    # calc adjacent tiles for number
    var counts: Array = getAdjacentSweeperCellCount(position)
    var count: int = counts[0]

    if count > 0:
        tile = Vector2i(count - 1, 0)
        var countMines: int = counts[1]
        if countMines == count:
            atlasId = ATLAS_MINES_ONLY
        elif countMines == 0:
            atlasId = ATLAS_ORE_ONLY
    
    numbers.set_cell(position, atlasId, tile)

func getAdjacentSweeperCellCount(position: Vector2i) -> Array:
    var bounds: PositionBounds = PositionBounds.new(position, worldState)
    var count: int = 0
    var mineCount: int = 0
    
    for y in range(bounds.yMin, bounds.yMax + 1):
        for x in range(bounds.xMin, bounds.xMax + 1):
            var cell: Cell = worldState[y][x]
            if cell == null || cell.isMined():
                continue
            if cell is Mine || cell is Ore:
                count += 1
                if cell is Mine:
                    mineCount += 1
    
    return [count, mineCount]

func recalculateAdjacentCellSweeperCount(position: Vector2i) -> void:
    var bounds: PositionBounds = PositionBounds.new(position, worldState)
    print("Recalculation bounds: y(%d, %d), x(%d, %d)" % [bounds.yMin, bounds.yMax, bounds.xMin, bounds.xMax])

    for y in range(bounds.yMin, bounds.yMax + 1):
        for x in range(bounds.xMin, bounds.xMax + 1):
            var cell: Cell = worldState[y][x]
            if cell == null || cell.isMined() == false:
                continue
            setCellTile(Vector2i(x, y))

func initTimer() -> void:
    scanTimer = Timer.new()
    scanTimer.timeout.connect(_on_scan_complete)
    numbers.add_child(scanTimer)

func _on_scan(coordinates: Vector2) -> void:
    print("scan triggered")
    if not scanTimer.is_stopped():
        return
    
    var localPosition: Vector2 = numbers.to_local(coordinates)
    var cellPosition: Vector2i = numbers.local_to_map(localPosition)
    var bounds: PositionBounds = PositionBounds.new(cellPosition, worldState, 10)
    
    for y in range(bounds.yMin, bounds.yMax + 1):
        for x in range(bounds.xMin, bounds.xMax + 1):
            setCellNumberTile(Vector2i(x, y))
    
    scanTimer.start(3.0)
    
func _on_scan_complete() -> void:
    print("scan complete")
    for row in range(worldState.size()):
        for column in range(worldState[row].size()):
            var cell: Cell = worldState[row][column]
            if cell == null || cell.isMined():
                continue
            numbers.set_cell(Vector2i(column, row))
    scanTimer.stop()

func _on_tnt(coordinates: Vector2) -> void:
    var localPosition: Vector2 = numbers.to_local(coordinates)
    var cellPosition: Vector2i = numbers.local_to_map(localPosition)
    var bounds: PositionBounds = PositionBounds.new(cellPosition, worldState, 10)
    
    for y in range(bounds.yMin, bounds.yMax + 1):
        for x in range(bounds.xMin, bounds.xMax + 1):
            var currentCellPosition = Vector2i(x,y)
            var local = ground.map_to_local(currentCellPosition)
            if local.distance_to(localPosition) < 600:
                worldState[y][x].healthPoints = 0
                setCellTile(currentCellPosition)
