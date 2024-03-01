extends Node2D
class_name Board

var boardHeight: int = 9
var boardWidth: int = 13
var cellSize: int = 36
var numPieces: int = 45
var numColors: int = 3
var clearSize: int = 3
var startPos: int = boardWidth / 2 + 1 + boardWidth * (boardHeight / 2 + 1)
var grid: Dictionary = {}
var Piece = preload("res://scenes/actors/Piece.tscn")
var Player = preload("res://scenes/actors/Player.tscn")
var player: Player

# Called when the node enters the scene tree for the first time.
func _ready():
	# Background
	var points = [Vector2(0,0), Vector2(0,boardHeight * cellSize),
	Vector2(boardWidth*cellSize, boardHeight * cellSize), Vector2(boardWidth*cellSize, 0)]
	$Polygon2D.set_polygon(points)
	player = Player.instantiate()
	player.position = get_screen_position_for_flat_index(startPos)
	grid[startPos] = player
	player.positionFlatIndex = startPos
	player.move.connect(_on_player_move)
	add_child(player)
	generateBoard()

func _on_player_move(distance: int, direction: int):
	for step in range(distance):
		var success = push(player.positionFlatIndex, direction)
		if !success:
			break

func push(start: int, direction: int) -> bool:
	var travellerCoords = getCoordsForFlatIndex(start)
	var success = false
	var destination: int = -1
	if direction == Constants.Directions.LEFT:
		if travellerCoords.x > 0:
			destination = start - 1
	elif direction == Constants.Directions.RIGHT:
		if travellerCoords.x < boardWidth - 1:
			destination = start + 1
	elif direction == Constants.Directions.DOWN:
		if travellerCoords.y < boardHeight - 1:
			destination = start + boardWidth
	elif direction == Constants.Directions.UP:
		if travellerCoords.y > 0:
			destination = start - boardWidth
	if destination > -1:
		if !grid.has(destination) || push(destination, direction):
			grid[destination] = grid[start]
			grid.erase(start)
			if grid[destination] is Player:
				player.positionFlatIndex = destination
			grid[destination].position = get_screen_position_for_flat_index(destination)
			success = true
	return success

func generateBoard():
	var possibleNums = range(boardHeight * boardWidth)
	possibleNums.erase(startPos)
	for i in range(numPieces):
		var flatIndex: int = possibleNums[randi_range(0, possibleNums.size() - 1)]
		var coords: Vector2 = getCoordsForFlatIndex(flatIndex)
		var possibleDirections = []
		if coords.y != 0:
			possibleDirections.append(Constants.Directions.UP)
		if coords.y != boardHeight - 1:
			possibleDirections.append(Constants.Directions.DOWN)
		if coords.x != 0:
			possibleDirections.append(Constants.Directions.LEFT)
		if coords.x != boardWidth - 1:
			possibleDirections.append(Constants.Directions.RIGHT)
		var success: bool = false
		while possibleDirections.size() > 0:
			var direction = possibleDirections.pop_at(randi_range(0, possibleDirections.size() - 1))
			var nextCell: int
			if direction == Constants.Directions.UP:
				nextCell = flatIndex - boardWidth
			elif direction == Constants.Directions.DOWN:
				nextCell = flatIndex + boardWidth
			elif direction == Constants.Directions.LEFT:
				nextCell = flatIndex - 1
			elif direction == Constants.Directions.RIGHT:
				nextCell = flatIndex + 1
			if possibleNums.has(nextCell):
				var colors
				var possibleColors = []
				for outer in range(numColors):
					for inner in range(numColors):
						possibleColors.append([outer, inner])
				while possibleColors.size() > 0:
					colors = possibleColors.pop_at(randi() % possibleColors.size())
					grid[flatIndex] = Piece.instantiate()
					grid[flatIndex].init(colors[0], direction, nextCell)
					grid[nextCell] = Piece.instantiate()
					grid[nextCell].init(colors[1], Constants.flip_direction(direction), flatIndex)
					if !has_clears():
						success = true
						break
				if !success:
					grid.erase(flatIndex)
					grid.erase(nextCell)
					break
				grid[flatIndex].position = get_screen_position_for_coords(coords)
				grid[nextCell].position = get_screen_position_for_flat_index(nextCell)
				add_child(grid[flatIndex])
				add_child(grid[nextCell])
				possibleNums.erase(flatIndex)
				possibleNums.erase(nextCell)
				break
		if !success:
			pass #todo

func has_clears() -> bool:
	var i = 0
	while i < boardHeight:
		var j = 0
		while j < boardWidth:
			if grid.has(i * boardWidth + j) && grid[i * boardWidth + j] is Piece:
				if j <= boardWidth - clearSize:
					for check in range(1, clearSize):
						if (!grid.has(i * boardWidth + j + check)
						|| !grid[i * boardWidth + j + check] is Piece
						|| grid[i * boardWidth + j].color != grid[i * boardWidth + j + check].color):
							break
						if check == clearSize - 1:
							return true
				if i <= boardHeight - clearSize:
					for check in range(1, clearSize):
						if (!grid.has((i + check) * boardWidth + j)
						|| !grid[(i + check) * boardWidth + j] is Piece
						|| grid[i * boardWidth + j].color != grid[(i + check) * boardWidth + j].color):
							break
						if check == clearSize - 1:
							return true
			j = j + 1
		i = i + 1
	return false

func get_screen_position_for_coords(coords: Vector2i) -> Vector2i:
	return coords * cellSize + Vector2i(cellSize / 2, cellSize / 2)

func get_screen_position_for_flat_index(flatIndex: int) -> Vector2i:
	return get_screen_position_for_coords(getCoordsForFlatIndex(flatIndex))

func getFlatIndexForCoords(coords: Vector2i) -> int:
	return coords.x + coords.y * boardWidth

func getCoordsForFlatIndex(index: int) -> Vector2i:
	return Vector2i(index % boardWidth, index / boardWidth)

func init():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
