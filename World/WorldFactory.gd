extends Node

var worldState: Array[Array] = Array()
var random: RandomNumberGenerator

const SECTION_COLUMNS: int = 7
const SECTION_ROWS: int = 7
const SECTION_COUNT = 2

func _ready() -> void:
    random = RandomNumberGenerator.new()
    random.randomize()

func buildWorld() -> void:
    print('Loading ...')
    
    var totalRows: int = SECTION_ROWS * SECTION_COUNT
    worldState.resize(totalRows)
    
    # the first row contains just out of base dirt cells
    worldState[0] = Array()
    worldState[0].resize(SECTION_COLUMNS)
    worldState[0].fill(Cell.new())
    
    for i in range(1, totalRows):
        worldState[i] = Array()
        worldState[i].resize(SECTION_COLUMNS)
        
        for j in range(SECTION_COLUMNS):
            buildCell(i, j)

func buildCell(row: int, column: int) -> void:
    var cell: Cell
    var randF: float = random.randf()
    var currentSection: int = row / SECTION_ROWS
    
    if randF > 0.95:
        cell = Mine.new(currentSection)
    elif randF > 0.7:
        cell = Ore.new(currentSection)
    else:
        cell = Cell.new(currentSection)
    
    worldState[row][column] = cell

func drill(row: int, column: int) -> void:
    if worldState[row][column].isMined == true:
        return
    
    worldState[row][column].healthPoints -= 1
    if worldState[row][column].healthPoints <= 0:
        worldState[row][column].isMined = true
