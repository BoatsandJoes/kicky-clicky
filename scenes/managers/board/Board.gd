extends Node2D
class_name Board

var boardHeight: int = 10
var boardWidth: int = 13
var outsideWalk: bool = true
var cellSize: int = 36
var numPieces: int = 36
var numColors: int = 3
var clearSize: int = 3
var startPos: int = boardWidth / 2 + boardWidth * (boardHeight / 2 )
var grid: Dictionary = {}
var Piece = preload("res://scenes/actors/Piece.tscn")
var Player = preload("res://scenes/actors/Player.tscn")
var player: Player
var cellsToCheckForClears: PackedInt32Array = []
var cellsToClear: PackedInt32Array = []

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
	player.kick.connect(_on_player_kick)
	player.launch_advance.connect(_on_piece_launch_advance)
	add_child(player)
	generateBoard()

func _on_piece_launch_advance(piece, steps: int):
	var index: int = grid.find_key(piece)
	for i in range(steps):
		if index != -1:
			index = launch(index)

func launch(index: int) -> int:
	var targetCoords = getCoordsForFlatIndex(index) + get_vector_for_direction(grid[index].launchDirection)
	if (targetCoords.x != 0 && targetCoords.y != 0
	&& targetCoords.x != boardWidth - 1 && targetCoords.y != boardHeight - 1):
		var targetIndex = getFlatIndexForCoords(targetCoords)
		if grid.has(targetIndex):
			get_kicked(targetIndex, grid[index].launchDirection)
		else:
			grid[targetIndex] = grid[index]
			grid.erase(index)
			grid[targetIndex].position = get_screen_position_for_flat_index(targetIndex)
			if grid[targetIndex].pairedPieceIndex:
				grid[index] = grid[grid[targetIndex].pairedPieceIndex]
				grid.erase(grid[targetIndex].pairedPieceIndex)
				grid[targetIndex].pairedPieceIndex = index
				grid[index].pairedPieceIndex = targetIndex
				grid[index].position = get_screen_position_for_flat_index(index)
			return targetIndex
	grid[index].stop_launching()
	cellsToCheckForClears.append(index)
	if grid[index].pairedPieceIndex != null:
		cellsToCheckForClears.append(grid[index].pairedPieceIndex)
	check_clears()
	return -1

func _on_player_move(distance: int, direction: int):
	for step in range(distance):
		if push(player.positionFlatIndex, direction) == -1:
			break
		check_clears()

func _on_player_kick():
	kick(player.positionFlatIndex, player.direction)

func kick(sourcePositionFlatIndex, direction):
	var target: int = -1
	var kickerCoords: Vector2i = getCoordsForFlatIndex(sourcePositionFlatIndex)
	if direction == Constants.Directions.LEFT:
		if kickerCoords.x > 1:
			target = sourcePositionFlatIndex - 1
	elif direction == Constants.Directions.RIGHT:
		if kickerCoords.x < boardWidth - 2:
			target = sourcePositionFlatIndex + 1
	elif direction == Constants.Directions.DOWN:
		if kickerCoords.y < boardHeight - 2:
			target = sourcePositionFlatIndex + boardWidth
	elif direction == Constants.Directions.UP:
		if kickerCoords.y > 1:
			target = sourcePositionFlatIndex - boardWidth
	if target == -1:
		grid[sourcePositionFlatIndex].stop_launching()
		if grid[sourcePositionFlatIndex] is Piece:
			cellsToCheckForClears.append(sourcePositionFlatIndex)
			if grid[sourcePositionFlatIndex].pairedPieceIndex != null:
				cellsToCheckForClears.append(grid[sourcePositionFlatIndex].pairedPieceIndex)
			check_clears()
	elif grid.has(target):
		grid[sourcePositionFlatIndex].stop_launching()
		if grid[sourcePositionFlatIndex] is Piece:
			cellsToCheckForClears.append(sourcePositionFlatIndex)
			if grid[sourcePositionFlatIndex].pairedPieceIndex != null:
				cellsToCheckForClears.append(grid[sourcePositionFlatIndex].pairedPieceIndex)
			check_clears()
		get_kicked(target, direction) #todo if this was cleared, it can no longer apply clack. fix?

func get_kicked(sourcePositionFlatIndex: int, direction: int):
	if grid[sourcePositionFlatIndex] != null:
		if grid[sourcePositionFlatIndex].pairedPieceIndex != null:
			if grid[sourcePositionFlatIndex].pairDirection != direction:
				spin(sourcePositionFlatIndex, direction)
			else:
				#Launch leading pair only
				grid[grid[sourcePositionFlatIndex].pairedPieceIndex].launch(direction)
				launch(grid[sourcePositionFlatIndex].pairedPieceIndex)
		else:
			#launch single or player
			grid[sourcePositionFlatIndex].launch(direction)
			launch(sourcePositionFlatIndex)

func spin(spinnerFlatIndex: int, direction: int):
	var fulcrumFlatIndex: int = grid[spinnerFlatIndex].pairedPieceIndex
	var fulcrumCoords: Vector2i = getCoordsForFlatIndex(fulcrumFlatIndex)
	var spinnerCoords: Vector2i = getCoordsForFlatIndex(spinnerFlatIndex)
	var targetCoords: Vector2i
	#we trust our caller and assume that kick direction and fulcrum direction are perpendicular
	if direction == Constants.Directions.UP:
		targetCoords = Vector2i(fulcrumCoords.x, fulcrumCoords.y - 1)
	elif direction == Constants.Directions.LEFT:
		targetCoords = Vector2i(fulcrumCoords.x - 1, fulcrumCoords.y)
	elif direction == Constants.Directions.DOWN:
		targetCoords = Vector2i(fulcrumCoords.x, fulcrumCoords.y + 1)
	elif direction == Constants.Directions.RIGHT:
		targetCoords = Vector2i(fulcrumCoords.x + 1, fulcrumCoords.y)
	var targetFlatIndex = null
	var wallkickedFulcrumNewFlatIndex = null
	if targetCoords.x < 1:
		#wallkick off the playfield wall
		var testFulcrumFlatIndex = getFlatIndexForCoords(Vector2i(fulcrumCoords.x + 1, fulcrumCoords.y))
		if !grid.has(testFulcrumFlatIndex):
			wallkickedFulcrumNewFlatIndex = testFulcrumFlatIndex
			targetFlatIndex = fulcrumFlatIndex
	elif targetCoords.x >= boardWidth - 1:
		#wallkick off the playfield wall
		var testFulcrumFlatIndex = getFlatIndexForCoords(Vector2i(fulcrumCoords.x - 1, fulcrumCoords.y))
		if !grid.has(testFulcrumFlatIndex):
			wallkickedFulcrumNewFlatIndex = testFulcrumFlatIndex
			targetFlatIndex = fulcrumFlatIndex
	elif targetCoords.y < 1:
		#wallkick off the playfield wall
		var testFulcrumFlatIndex = getFlatIndexForCoords(Vector2i(fulcrumCoords.x, fulcrumCoords.y + 1))
		if !grid.has(testFulcrumFlatIndex):
			wallkickedFulcrumNewFlatIndex = testFulcrumFlatIndex
			targetFlatIndex = fulcrumFlatIndex
	elif targetCoords.y >= boardHeight - 1:
		#wallkick off the playfield wall
		var testFulcrumFlatIndex = getFlatIndexForCoords(Vector2i(fulcrumCoords.x, fulcrumCoords.y - 1))
		if !grid.has(testFulcrumFlatIndex):
			wallkickedFulcrumNewFlatIndex = testFulcrumFlatIndex
			targetFlatIndex = fulcrumFlatIndex
	else:
		var testTargetFlatIndex: int = getFlatIndexForCoords(targetCoords)
		if grid.has(testTargetFlatIndex):
			#wallkick off another piece
			#First check
			var testTargetCoords = spinnerCoords + get_vector_for_direction(direction)
			testTargetFlatIndex = getFlatIndexForCoords(testTargetCoords)
			wallkickedFulcrumNewFlatIndex = spinnerFlatIndex
			# New fulcrum is in a location previously covered by this piece, so we only have to check half
			if (grid.has(testTargetFlatIndex) || testTargetCoords.x < 1 || testTargetCoords.y < 1
			|| testTargetCoords.x >= boardWidth - 1 || testTargetCoords.y >= boardHeight - 1):
				#Second check
				testTargetFlatIndex = fulcrumFlatIndex
				var testWallkickedFulcrumNewCoords: Vector2 = (fulcrumCoords +
						get_vector_for_direction(Constants.flip_direction(direction)))
				wallkickedFulcrumNewFlatIndex = getFlatIndexForCoords(testWallkickedFulcrumNewCoords)
				# Spinner is now in a location previously covered by this piece, so we only have to check half
				if (grid.has(wallkickedFulcrumNewFlatIndex) || testWallkickedFulcrumNewCoords.x < 1
				|| testWallkickedFulcrumNewCoords.y < 1 || testWallkickedFulcrumNewCoords.x >= boardWidth - 1
				|| testWallkickedFulcrumNewCoords.y >= boardHeight - 1):
					#Third check
					var offset: Vector2i = get_vector_for_direction(grid[spinnerFlatIndex].pairDirection)
					var testSpinnerCoords = targetCoords + offset
					testTargetFlatIndex = getFlatIndexForCoords(testSpinnerCoords)
					testWallkickedFulcrumNewCoords = fulcrumCoords + offset
					wallkickedFulcrumNewFlatIndex = getFlatIndexForCoords(testWallkickedFulcrumNewCoords)
					if (!grid.has(testTargetFlatIndex) && !grid.has(wallkickedFulcrumNewFlatIndex)
					&& testWallkickedFulcrumNewCoords.x >= 1 && testWallkickedFulcrumNewCoords.y < boardHeight - 1
					&& testWallkickedFulcrumNewCoords.y >= 1 && testWallkickedFulcrumNewCoords.x < boardWidth - 1
					&& testSpinnerCoords.x >= 1 && testSpinnerCoords.y < boardHeight - 1
					&& testSpinnerCoords.y >= 1 && testSpinnerCoords.x < boardWidth - 1):
						targetFlatIndex = testTargetFlatIndex
				else:
					targetFlatIndex = testTargetFlatIndex
			else:
				targetFlatIndex = testTargetFlatIndex
		else:
			targetFlatIndex = testTargetFlatIndex
	if targetFlatIndex != null:
		#actually perform the rotate.
		grid[spinnerFlatIndex].set_direction(Constants.flip_direction(direction))
		grid[fulcrumFlatIndex].set_direction(direction)
		if wallkickedFulcrumNewFlatIndex != null:
			if targetFlatIndex == fulcrumFlatIndex:
				# Move fulcrum out of the way first.
				rotate_half_of_pair(wallkickedFulcrumNewFlatIndex, fulcrumFlatIndex, targetFlatIndex)
				rotate_half_of_pair(targetFlatIndex, spinnerFlatIndex, wallkickedFulcrumNewFlatIndex)
			else:
				#Move spinner out of the way first. For third wallkick case it doesn't matter, but for 1st it does
				rotate_half_of_pair(targetFlatIndex, spinnerFlatIndex, wallkickedFulcrumNewFlatIndex)
				rotate_half_of_pair(wallkickedFulcrumNewFlatIndex, fulcrumFlatIndex, targetFlatIndex)
		else:
			rotate_half_of_pair(targetFlatIndex, spinnerFlatIndex, fulcrumFlatIndex)
			grid[fulcrumFlatIndex].pairedPieceIndex = targetFlatIndex
		check_clears()

func rotate_half_of_pair(newFlatIndex: int, oldFlatIndex: int, newPairedIndex: int):
	grid[newFlatIndex] = grid[oldFlatIndex]
	grid.erase(oldFlatIndex)
	grid[newFlatIndex].pairedPieceIndex = newPairedIndex
	cellsToCheckForClears.append(newFlatIndex)
	grid[newFlatIndex].position = get_screen_position_for_flat_index(newFlatIndex)

func get_vector_for_direction(direction: int) -> Vector2i:
	if direction == Constants.Directions.LEFT:
		return Vector2i(-1, 0)
	elif direction == Constants.Directions.RIGHT:
		return Vector2i(1, 0)
	elif direction == Constants.Directions.UP:
		return Vector2i(0, -1)
	else:
		return Vector2i(0, 1)

func can_push(start: int, direction: int) -> bool:
	var travellerCoords = getCoordsForFlatIndex(start)
	var success = false
	var destination: int = -1
	if direction == Constants.Directions.LEFT:
		if travellerCoords.x > 1 || (grid[start] is Player && travellerCoords.x == 1):
			destination = start - 1
	elif direction == Constants.Directions.RIGHT:
		if travellerCoords.x < boardWidth - 2  || (grid[start] is Player && travellerCoords.x == boardWidth - 2):
			destination = start + 1
	elif direction == Constants.Directions.DOWN:
		if travellerCoords.y < boardHeight - 2 || (grid[start] is Player && travellerCoords.y == boardHeight - 2):
			destination = start + boardWidth
	elif direction == Constants.Directions.UP:
		if travellerCoords.y > 1 || (grid[start] is Player && travellerCoords.y == 1):
			destination = start - boardWidth
	if destination > -1:
		if (grid[start].pairedPieceIndex != null
		#this pair will be pushed as a loose piece
		&& grid[grid[start].pairedPieceIndex].pairDirection != direction):
			grid[grid[start].pairedPieceIndex].pairedPieceIndex = null
			success = can_push(grid[start].pairedPieceIndex, direction)
			grid[grid[start].pairedPieceIndex].pairedPieceIndex = start
		else:
			success = true #so far so good. Hey, that's--
		if success && grid.has(destination):
			success = can_push(destination, direction)
	return success

func push(start: int, direction: int) -> int:
	var destination: int = -1
	if(can_push(start, direction)):
		var travellerCoords = getCoordsForFlatIndex(start)
		if direction == Constants.Directions.LEFT:
			if travellerCoords.x > 1 || (grid[start] is Player && travellerCoords.x == 1):
				destination = start - 1
		elif direction == Constants.Directions.RIGHT:
			if travellerCoords.x < boardWidth - 2 || (grid[start] is Player && travellerCoords.x == boardWidth - 2):
				destination = start + 1
		elif direction == Constants.Directions.DOWN:
			if travellerCoords.y < boardHeight - 2 || (grid[start] is Player && travellerCoords.y == boardHeight-2):
				destination = start + boardWidth
		elif direction == Constants.Directions.UP:
			if travellerCoords.y > 1 || (grid[start] is Player && travellerCoords.y == 1):
				destination = start - boardWidth
		if destination > -1:
			if grid[start].pairedPieceIndex != null:
				grid[grid[start].pairedPieceIndex].pairedPieceIndex = null
				grid[start].pairedPieceIndex = push(grid[start].pairedPieceIndex, direction)
				grid[grid[start].pairedPieceIndex].pairedPieceIndex = destination
			if grid.has(destination): #if our paired piece is there, it will be pushed ahead already.
				push(destination, direction)
			grid[destination] = grid[start]
			if grid[start] is Player:
				player.positionFlatIndex = destination
			else:
				cellsToCheckForClears.append(destination)
			grid.erase(start)
			grid[destination].position = get_screen_position_for_flat_index(destination)
	return destination

func generateBoard():
	var placed = 0
	var possibleNums = range(boardHeight * boardWidth)
	possibleNums.erase(startPos)
	for i in range(boardWidth):
		possibleNums.erase(i)
	for i in range((boardHeight - 1) * boardWidth, boardHeight * boardWidth):
		possibleNums.erase(i)
	for i in range(0, boardHeight * boardWidth, boardWidth):
		possibleNums.erase(i)
	for i in range(boardWidth - 1, boardHeight * boardWidth, boardWidth):
		possibleNums.erase(i)
	var failedPlacements = 0
	while placed < numPieces:
		var flatIndex: int = possibleNums[randi_range(0, possibleNums.size() - 1)]
		var coords: Vector2 = getCoordsForFlatIndex(flatIndex)
		var possibleDirections = []
		if coords.y > 1:
			possibleDirections.append(Constants.Directions.UP)
		if coords.y < boardHeight - 2:
			possibleDirections.append(Constants.Directions.DOWN)
		if coords.x > 1:
			possibleDirections.append(Constants.Directions.LEFT)
		if coords.x < boardWidth - 2:
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
				grid[flatIndex].launch_advance.connect(_on_piece_launch_advance)
				grid[nextCell].launch_advance.connect(_on_piece_launch_advance)
				add_child(grid[flatIndex])
				add_child(grid[nextCell])
				possibleNums.erase(flatIndex)
				possibleNums.erase(nextCell)
				break
		if success:
			placed = placed + 1
		else:
			failedPlacements = failedPlacements + 1
		if failedPlacements > numPieces * 5:
			break
	if failedPlacements > numPieces * 5:
		for key in grid.keys():
			if grid[key] is Piece:
				remove_child(grid[key])
		grid.clear()
		grid[startPos] = player
		generateBoard()

func check_clears():
	var setsOfClears: Array[PackedInt32Array] = []
	while cellsToCheckForClears.size() > 0:
		if grid.has(cellsToCheckForClears[0]):
			var piece = grid[cellsToCheckForClears[0]]
			if piece is Piece:
				var startPieceCoords = getCoordsForFlatIndex(cellsToCheckForClears[0])
				#check up and down
				var clear: PackedInt32Array = [cellsToCheckForClears[0]]
				clear.append_array(scan_clears_in_direction(Vector2i(0, -1),
				startPieceCoords, cellsToCheckForClears[0], piece.color))
				clear.append_array(scan_clears_in_direction(Vector2i(0, 1),
				startPieceCoords, cellsToCheckForClears[0], piece.color))
				if clear.size() >= clearSize:
					setsOfClears.append(clear)
				#check left and right
				clear = [cellsToCheckForClears[0]]
				clear.append_array(scan_clears_in_direction(Vector2i(-1, 0),
				startPieceCoords, cellsToCheckForClears[0], piece.color))
				clear.append_array(scan_clears_in_direction(Vector2i(1, 0),
				startPieceCoords, cellsToCheckForClears[0], piece.color))
				if clear.size() >= clearSize:
					setsOfClears.append(clear)
		# Done checking this cell
		cellsToCheckForClears.remove_at(0)
	for clear in setsOfClears:
		# todo score
		cellsToClear.append_array(clear)

func scan_clears_in_direction(direction: Vector2i, testPieceCoords: Vector2i,
testPieceFlatIndex: int, color: int) -> PackedInt32Array:
	var clear: PackedInt32Array = []
	while ((direction.x == 0 && (direction.y < 0 || testPieceCoords.y < boardHeight - 2)
	&& (direction.y > 0 || testPieceCoords.y > 1))
	|| (direction.y == 0 && (direction.x < 0 || testPieceCoords.x < boardWidth - 2)
	&& (direction.x > 0 || testPieceCoords.x > 1))):
		testPieceCoords = testPieceCoords + direction
		testPieceFlatIndex = getFlatIndexForCoords(testPieceCoords)
		if grid.has(testPieceFlatIndex):
			var testPiece = grid[testPieceFlatIndex]
			if (testPiece is Piece && testPiece.color == color && testPiece.launchDirection == null
			&& (testPiece.pairedPieceIndex == null || grid[testPiece.pairedPieceIndex].launchDirection == null)):
				clear.append(testPieceFlatIndex)
			else:
				break
		else:
			break
	return clear

func has_clears() -> bool:
	var i = 0
	while i < boardHeight:
		var j = 0
		while j < boardWidth:
			if grid.has(i * boardWidth + j) && grid[i * boardWidth + j] is Piece:
				if j <= boardWidth - clearSize - 1:
					for check in range(1, clearSize):
						if (!grid.has(i * boardWidth + j + check)
						|| !grid[i * boardWidth + j + check] is Piece
						|| grid[i * boardWidth + j].color != grid[i * boardWidth + j + check].color):
							break
						if check == clearSize - 1:
							return true
				if i <= boardHeight - clearSize - 1:
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

func _physics_process(delta):
	for cell in cellsToClear:
		if grid.has(cell):
			var piece = grid[cell]
			if piece is Piece:
				if piece.pairedPieceIndex && grid.has(piece.pairedPieceIndex):
					var pair = grid[piece.pairedPieceIndex]
					if pair is Piece:
						pair.set_direction(null)
						pair.pairedPieceIndex = null
				grid.erase(cell)
				remove_child(piece)
	cellsToClear.clear()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
