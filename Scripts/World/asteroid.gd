extends Node2D

signal explosion(coordinates: Vector2i, damage: int)
signal minedValuable(value: int)

var explosionDust = preload("res://Scenes/Misc/DustCloud.tscn")

@export_range(-1, 1, 0.25, "hide_slider") var originAnchorX : float = 0
@export_range(-1, 1, 0.25, "hide_slider") var originAnchorY : float = 0
@export var sections : int = 5
@export var sectionSize : int = 5
@export var sectionOverlap : int = 2

@export var oreDensity : float = 0.15
@export var oreSectionDensity : float = 0.05
@export var mineDensity : float = 0.15
@export var mineSectionDensity : float = 0.05
@export var rockDensity : float = 0
@export var rockSectionDensity : float = 0

										#Flag			#Ore			#Mine		#Ore and Mine
@export var colorTints : Array[Color] = [Color(1,1,1), Color(0,1,0), Color(1,0,0), Color(1,0.6,0)]

@onready var ground : TileMapLayer = $Ground
@onready var overlay : TileMapLayer = $Numbers

var radius : int = 0
var player : CharacterBody2D
var tiles : Array = Array()
var scanTimer : Timer

var showNumbers : bool = false
var showSection : bool = false

enum groundTileAtlas {
	TILES = 0,
	DEV_SQUARES = 1,
	BACKGROUND = 2
}

enum numberTileAtlas {
	FLAG = 0,
	ONLY_ORES = 2,
	ONLY_MINES = 3,
	ORES_AND_MINES = 4
}

func _init() -> void:
	# Insert yourself into the global asteroid list on instantiation
	GlobalVars.asteroides.append(self)

func _notification(what: int) -> void:
	# Remove yourself from global asteroid list on deletion
	if what == NOTIFICATION_PREDELETE: GlobalVars.asteroides.erase(self)

func _ready() -> void:
	initPlayer()	# Init links to player if posible
	initTimer()		# Init scan timer to display numbers on scan
	initTiles()		# Generate tiles of the map
	
	updateOverlayColorTints()	# Update the Colos of the Number Overlay
	updateMapOverlay()			# Update Tilemaps
	
	# Move asteroid so the Original origin becomes anchor Vector set in the inspector
	# Offset the 2 Tilemaps so the Origin is in the Middle of them
	var posOffset : float = tiles.size() * 128
	position += Vector2(posOffset*2*originAnchorX, posOffset*2*originAnchorY)
	ground.position = Vector2(-posOffset, -posOffset)
	overlay.position = ground.position
	
	radius = (tiles.size()) * 128

func digTile(cellPosition: Vector2i, damage: int, spread : bool = false) -> void:
	var x: int = cellPosition.x
	var y: int = cellPosition.y
	if x < 0 || y < 0 || y >= tiles.size() || x >= tiles[y].size(): return
	
	var cell: Cell = tiles[y][x]
	if cell == null || cell.isMined(): return
	
	if damage >= 0: 
		cell.drill(damage)
		if GlobalVars.drillSpreading && not spread && cell._resistance >= 0 && not cell.isFlagged:
			damage -= cell._resistance
			digTile(Vector2i(x+1, y), damage, true)
			digTile(Vector2i(x-1, y), damage, true)
			digTile(Vector2i(x, y+1), damage, true)
			digTile(Vector2i(x, y-1), damage, true)
	elif damage == -1: cell.isFlagged = not cell.isFlagged #Toggle cell unverwundbarkeit
	
	updateTileIndex(cellPosition)
	
	if not spread:
		if (cell.isFlagged || not cell.isDamaged()) && not cell.isMined():
			AudioPlayer.play_sfx("nonBreak")
		else:
			AudioPlayer.play_sfx("dig")
	
	if not cell.isMined(): return
	updateTilesAroundIndex(cellPosition)
	
	if cell is Mine:
		AudioPlayer.play_sfx('explosion')
		var tileGlobalPos : Vector2 = ground.to_global(ground.map_to_local(cellPosition))
		explosion.emit(tileGlobalPos, cell.damage, Mine.DAMAGE_RADIUS)
		GlobalVars.minesHit += 1
		var dust : AnimatedSprite2D = explosionDust.instantiate()
		dust.global_position = tileGlobalPos
		ground.get_parent().add_sibling(dust)
	elif cell is Ore:
		AudioPlayer.play_sfx('pickupOre')
		minedValuable.emit(cell.value)
		GlobalVars.oreMined += 1
	else:
		GlobalVars.tilesMined += 1

func initPlayer() -> void:
	player = get_parent().get_node("Player")
	if player != null: 
		player.collides.connect(_on_player_collides)
		player.scan.connect(_on_scan)
		player.tnt.connect(_on_tnt)
		explosion.connect(player._on_explosion)
		minedValuable.connect(player._on_collect_valuable)

func initTimer() -> void:
	scanTimer = Timer.new()
	scanTimer.timeout.connect(_on_scan_complete)
	overlay.add_child(scanTimer)

func initTiles() -> void:
	var generator : AsteroidFactory = AsteroidFactory.new()
	generator.sections = sections
	generator.sectionSize = sectionSize
	generator.sectionOverlap = sectionOverlap
	generator.oreDensity = oreDensity
	generator.oreSectionDensity = oreSectionDensity
	generator.mineDensity = mineDensity
	generator.mineSectionDensity = mineSectionDensity
	generator.rockDensity = rockDensity
	generator.rockSectionDensity = rockSectionDensity
	
	tiles = generator.generateAsteroid()

#TODO Auslagen in neues Skript für Number Tileset -> Übergabe Farbenarray als Parameter
func updateOverlayColorTints() -> void:
	var tileSet: TileSet = overlay.tile_set;
	var atlasId: int
	var source: TileSetAtlasSource
	
	for atlasIndex in range(tileSet.get_source_count()):
		atlasId = tileSet.get_source_id(atlasIndex)
		source = tileSet.get_source(atlasId)
		if not source is TileSetAtlasSource: continue
		
		for tileIndex in range(source.get_tiles_count()):
			var tileData = source.get_tile_data(Vector2i(tileIndex, 0), 0)
			tileData.modulate = colorTints[atlasIndex]

func updateTileIndex(index : Vector2i, showSweepCount : bool = false) -> void:
	if not validTile(index.y, index.x): return
	var cell: Cell = tiles[index.y][index.x]
	if cell == null: return
	
	var tileOffsetY: int = 0
	var atlasId = groundTileAtlas.TILES
	var tileOffsetX: int = cell.tileVariant
	
	if cell.isMined() || (showNumbers && !(cell is Mine || cell is Ore)) || showSection:
		atlasId = groundTileAtlas.BACKGROUND
		tileOffsetX = 0
	elif cell.isDamaged():
		tileOffsetY = cell.getTileDamageOffset()
	
	ground.set_cell(index, atlasId, Vector2i(tileOffsetX, tileOffsetY))
	
	atlasId = -1
	tileOffsetX = 0
	if cell.isFlagged: 
		atlasId = 0
	elif showSection:
		atlasId = 2
		tileOffsetX = cell._section-1
	elif cell.isMined() || showNumbers || showSweepCount: 
		var sweepInfo : Array = getSweepCount(index)
		tileOffsetX = sweepInfo[0] - 1
		atlasId = sweepInfo[1]
	
	if atlasId < 0: overlay.set_cell(index)
	else: overlay.set_cell(index, atlasId, Vector2i(tileOffsetX, 0))

func getSweepCount(index : Vector2i) -> Array:
	var sweepCount : int = 0
	var sweepType : int = numberTileAtlas.FLAG
	var cell : Cell
	
	for row in range(index.y-1, index.y+2):
		if row < 0 || row >= tiles.size(): continue	# skip for invalid rows
		
		for col in range(index.x-1, index.x+2):
			if col < 0 || col >= tiles.size(): continue	# skip for invalid cols
			if row == index.y && col == index.x: continue	# skip for self
			cell = tiles[row][col]
			if cell == null: continue	# skip for empty cells
			if cell.isMined(): continue	# skip mined cells
			
			if cell is Mine:	# if cell is a mine increase sweepcount and update atlas id
				sweepCount += 1
				if sweepType == numberTileAtlas.FLAG || sweepType == numberTileAtlas.ONLY_MINES:
					sweepType = numberTileAtlas.ONLY_MINES
				else:
					sweepType = numberTileAtlas.ORES_AND_MINES
			elif cell is Ore:	# if cell is ore increase sweepcount and update atlas id
				sweepCount += 1
				if sweepType == numberTileAtlas.FLAG || sweepType == numberTileAtlas.ONLY_ORES:
					sweepType = numberTileAtlas.ONLY_ORES
				else:
					sweepType = numberTileAtlas.ORES_AND_MINES
	
	return [sweepCount, sweepType]

func updateTilesAroundIndex(index: Vector2i) -> void:
	var cell : Cell
	for row in range(index.y-1, index.y+2):
		if row < 0 || row >= tiles.size(): continue	# skip for invalid rows
		
		for col in range(index.x-1, index.x+2):
			if col < 0 || col >= tiles.size(): continue	# skip for invalid cols
			
			cell = tiles[row][col]
			if cell == null || not cell.isMined(): continue
			updateTileIndex(Vector2i(col, row))

func toggleNumOverlay() -> void:
	showSection = false
	showNumbers = not showNumbers
	updateMapOverlay()

func toggleSectionOverlay() -> void:
	showNumbers = false
	showSection = not showSection
	updateMapOverlay()

func updateMapOverlay() -> void:
	for row in range(tiles.size()):
		for col in range(tiles.size()):
			updateTileIndex(Vector2i(col, row))

func validTile(row : int, col : int) -> bool:
	return (-1 < row && row < tiles.size()) && (-1 < col && col < tiles[row].size())

func _on_player_collides(collision: KinematicCollision2D) -> void:
	var cellPosition: Vector2i = ground.get_coords_for_body_rid(collision.get_collider_rid())
	if player.drillActive: digTile(cellPosition, player.strength)

func _on_scan(scanOrigin: Vector2) -> void:
	if not scanTimer.is_stopped(): return
	
	var scanPos : Vector2 = overlay.to_local(scanOrigin)
	var scanCell : Vector2i = overlay.local_to_map(scanPos)
	
	var cellPos : Vector2
	for row in range(scanCell.y-6, scanCell.y+7):
		for col in range(scanCell.x-6, scanCell.x+7):
			cellPos = overlay.map_to_local(Vector2i(col,row))
			if cellPos.distance_to(scanPos) < 1400: updateTileIndex(Vector2i(col, row), true)
	
	scanTimer.start(3.0)
    
func _on_scan_complete() -> void:
	updateMapOverlay()
	scanTimer.stop()

func _on_tnt(coordinates: Vector2) -> void:
	var explosionPos : Vector2 = ground.to_local(coordinates) 
	var exploCell : Vector2i = ground.local_to_map(explosionPos)
	
	var cell : Cell
	var cellPos : Vector2
	for row in range(exploCell.y-3, exploCell.y+4):
		if not validTile(row, 0): continue
		
		for col in range(exploCell.x-3, exploCell.x+4):
			if not validTile(row, col): continue
			
			cell = tiles[row][col]
			if cell == null: continue
			
			cellPos = ground.map_to_local(Vector2i(col,row))
			if cellPos.distance_to(explosionPos) > 640: continue
			
			cell.healthPoints = 0
			cell.isFlagged = false
			
			if cell is Ore: minedValuable.emit(cell.value)
	
	# only after removing all cells, the new numbers can be calculated
	for row in range(exploCell.y-3, exploCell.y+4):
		for col in range(exploCell.x-3, exploCell.x+4):
			updateTileIndex(Vector2i(col, row))
