extends Node2D
class_name Board

var boardHeight: int = 9
var boardWidth: int = 13
var cellSize: int = 36
var numPieces: int = 45
var numColors: int = 3
var clearSize: int = 3
var startPos: int = boardWidth / 2 + 1 + boardWidth * (boardHeight / 2 + 1)
var array: Array = []
var pieces: Array = []
var Piece = preload("res://scenes/actors/Piece.tscn")
var Player = preload("res://scenes/actors/Player.tscn")
var player: Player

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(boardHeight):
		for j in range(boardWidth):
			array.append(null)
	array[startPos] = -1
	var points = [Vector2(0,0), Vector2(0,boardHeight * cellSize),
	Vector2(boardWidth*cellSize, boardHeight * cellSize), Vector2(boardWidth*cellSize, 0)]
	$Polygon2D.set_polygon(points)
	player = Player.instantiate()
	player.position = get_screen_position_for_flat_index(startPos)
	player.move.connect(_on_player_move)
	add_child(player)
	generateBoard()

func _on_player_move(distance: int, direction: int):
	for step in range(distance):
		var playerFlatIndex = array.find(-1)
		var playerCoords = getCoordsForFlatIndex(playerFlatIndex)
		var success = false
		if direction == Constants.Directions.LEFT:
			if playerCoords.x > 0:
				if array[playerFlatIndex - 1] == null:
					array[playerFlatIndex - 1] = -1
					array[playerFlatIndex] = null
					player.position = get_screen_position_for_coords(playerCoords + Vector2i(-1,0))
					success = true
		elif direction == Constants.Directions.RIGHT:
			if playerCoords.x < boardWidth - 1:
				if array[playerFlatIndex + 1] == null:
					array[playerFlatIndex + 1] = -1
					array[playerFlatIndex] = null
					player.position = get_screen_position_for_coords(playerCoords + Vector2i(1,0))
					success = true
		elif direction == Constants.Directions.DOWN:
			if playerCoords.y < boardHeight - 1:
				if array[playerFlatIndex + boardWidth] == null:
					array[playerFlatIndex + boardWidth] = -1
					array[playerFlatIndex] = null
					player.position = get_screen_position_for_coords(playerCoords + Vector2i(0,1))
					success = true
		elif direction == Constants.Directions.UP:
			if playerCoords.y > 0:
				if array[playerFlatIndex - boardWidth] == null:
					array[playerFlatIndex - boardWidth] = -1
					array[playerFlatIndex] = null
					player.position = get_screen_position_for_coords(playerCoords + Vector2i(0,-1))
					success = true
		if !success:
			break

func generateBoard():
	var possibleNums = range(array.size())
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
					array[flatIndex] = colors[0]
					array[nextCell] = colors[1]
					if !has_clears():
						success = true
						break
				if !success:
					array[flatIndex] = null
					array[nextCell] = null
					break
				var piece1 = Piece.instantiate()
				var piece2 = Piece.instantiate()
				piece1.init(colors[0], direction)
				piece2.init(colors[1], Constants.flip_direction(direction))
				pieces.append([piece1, piece2])
				piece1.position = get_screen_position_for_coords(coords)
				piece2.position = get_screen_position_for_flat_index(nextCell)
				add_child(piece1)
				add_child(piece2)
				possibleNums.erase(flatIndex)
				possibleNums.erase(nextCell)
				success = true
				break
		if !success:
			pass #todo

func has_clears() -> bool:
	var i = 0
	while i < boardHeight:
		var j = 0
		while j < boardWidth:
			if array[i * boardWidth + j] != null:
				if j <= boardWidth - clearSize:
					for check in range(1, clearSize):
						if array[i * boardWidth + j] != array[i * boardWidth + j + check]:
							break
						if check == clearSize - 1:
							return true
				if i <= boardHeight - clearSize:
					for check in range(1, clearSize):
						if array[i * boardWidth + j] != array[(i + check) * boardWidth + j]:
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
