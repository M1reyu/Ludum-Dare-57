class_name AsteroidFactory

var sections : int
var sectionSize : int
var sectionOverlap : int
var mapCenter : int

var oreDensity : float = 0.20
var oreSectionDensity : float = 0.05
var oreChance : float = 0

var mineDensity : float = 0.05
var mineSectionDensity : float = 0.02
var mineChance : float = 0

var rockDensity : float = 0
var rockSectionDensity : float = 0
var rockChance : float = 0

var tiles : Array = Array()
var rng : RandomNumberGenerator

enum tileTypes {
	NONE = 0,
	DIRT = 1,
	ROCK = 2,
	MINE = 3,
	ORE = 5
}

func generateAsteroid() -> Array:
	rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var size: int = 3 + (sectionSize * sections) * 2
	tiles.resize(size)
	for i in range(size):
		tiles[i] = Array()
		tiles[i].resize(size)
		tiles[i].fill([tileTypes.NONE, 0])
	
	mapCenter = int(size / 2)
	tiles[mapCenter][mapCenter] = [tileTypes.ORE, sections+2]
	
	oreChance = oreDensity + oreSectionDensity * sections
	mineChance = mineChance + mineSectionDensity * sections
	rockChance = rockChance + rockSectionDensity * sections
	
	var curSection = sections
	var curSectionRadius = 0
	var sectionMod : float = 0.0
	while curSection > 0:
		sectionMod = 0.5
		for i in range(sectionSize):
			curSectionRadius += 1
			if !(sectionOverlap < i && i < sectionSize - sectionOverlap): 
				sectionMod -= (0.5 / (1 + sectionOverlap)) 
			buildPlanetLayer(curSection, curSectionRadius, sectionMod)
		curSection -= 1
		oreChance -= oreSectionDensity
		mineChance -= mineSectionDensity
		rockChance -= rockSectionDensity
	    
	return generateCellTiles()

func buildPlanetLayer(section : int, radius: int, sectionMod : float) -> void:
	# create a filled circle by utilizing Bresenham's algorithm
	var x: int = 0
	var y: int = radius
	var d: int = 3 - 2 * radius # decision parameter
	
	setNullRowTilesInColumn(section, x, y, sectionMod)
	
	while x <= y:
		if d < 0:
			d = d + 4 * x + 6
		else:
			d = d + 4 * (x - y) + 10
			y -= 1
		
		x += 1
		setNullRowTilesInColumn(section, x, y, sectionMod)

func setNullRowTilesInColumn(section : int, x : int, y : int, sectionMod : float) -> void:
	for row in [mapCenter-y, mapCenter-y+1, mapCenter+y-1, mapCenter+y]:
		setTiletype(section, row, mapCenter+x, sectionMod)
		setTiletype(section, row, mapCenter-x, sectionMod)
	
	for row in [mapCenter-x, mapCenter-x+1, mapCenter+x-1, mapCenter+x]:
		setTiletype(section, row, mapCenter+y, sectionMod)
		setTiletype(section, row, mapCenter-y, sectionMod)

#Changes the Tile Type and sets the section Value
func setTiletype(section : int, row : int, col : int, sectionMod : float) -> void:
	if tiles[row][col][0] != tileTypes.NONE: return
	var randF : float = rng.randf()
	if randF < abs(sectionMod):
		if sectionMod < 0: section -= 1
		elif sectionMod > 0: section +=1
	
	# the first section contains no mines
	tiles[row][col] = [tileTypeSelector(), section]
	if section == 1 && tiles[row][col][0] == tileTypes.MINE:
		tiles[row][col] = [tileTypes.DIRT, section]

func tileTypeSelector() -> int:
	var rngVal : float = rng.randf()
	rngVal -= mineChance
	if rngVal < 0: return tileTypes.MINE
	
	rngVal -= oreChance
	if rngVal < 0: return tileTypes.ORE
	
	rngVal -= rockChance
	if rngVal < 0: return tileTypes.ROCK
	
	return tileTypes.DIRT

#Generates all Cells according to the data found in the Tiles Array
#Tiles array is an array of the world desired world size with [Type of Cell, Section]
func generateCellTiles() -> Array:
	var cells : Array = Array()
	var rowString : String = ""
	
	cells.resize(tiles.size())
	for i in range(tiles.size()):
		cells[i] = Array()
		cells[i].resize(tiles[i].size())
		
		rowString = ""
		for j in range(tiles[i].size()):
			match tiles[i][j][0]:
				tileTypes.NONE: cells[i][j] = null
				tileTypes.DIRT: cells[i][j] = Cell.new(tiles[i][j][1])
				tileTypes.ROCK: cells[i][j] = Indestructible.new()
				tileTypes.MINE: cells[i][j] = Mine.new(tiles[i][j][1])
				tileTypes.ORE: cells[i][j] = Ore.new(tiles[i][j][1])
	
	return cells
