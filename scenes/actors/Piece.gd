extends Node2D
class_name Piece

var color: int
var pairDirection
var pairedPieceIndex
var cellSize: int = 36

# Called when the node enters the scene tree for the first time.
func _ready():
	if color == Constants.Colors.RED:
		$Sprite2D.texture = load("res://assets/sprites/red.png")
	elif color == Constants.Colors.BLUE:
		$Sprite2D.texture = load("res://assets/sprites/blue.png")
	elif color == Constants.Colors.YELLOW:
		$Sprite2D.texture = load("res://assets/sprites/yellow.png")
	elif color == Constants.Colors.GREEN:
		$Sprite2D.texture = load("res://assets/sprites/green.png")

func init(color: int, pairDirection, pairedPieceIndex):
	self.pairedPieceIndex = pairedPieceIndex
	self.color = color
	$Polygon2D.position = $Polygon2D.position - Vector2(cellSize/2,cellSize/2)
	set_direction(pairDirection)

func set_direction(pairDirection: int):
	self.pairDirection = pairDirection
	var points
	if pairDirection == Constants.Directions.UP:
		points = [Vector2(7,0), Vector2(7,cellSize/4),
			Vector2(cellSize - 7, cellSize/4), Vector2(cellSize - 7, 0)]
	elif pairDirection == Constants.Directions.DOWN:
		points = [Vector2(7,cellSize), Vector2(7,cellSize - cellSize/4),
			Vector2(cellSize - 7, cellSize - cellSize/4), Vector2(cellSize -7, cellSize)]
	elif pairDirection == Constants.Directions.LEFT:
		points = [Vector2(0,7), Vector2(0,cellSize - 7),
			Vector2(cellSize/4, cellSize - 7), Vector2(cellSize/4, 7)]
	elif pairDirection == Constants.Directions.RIGHT:
		points = [Vector2(cellSize - cellSize/4,7), Vector2(cellSize - cellSize/4,cellSize - 7),
			Vector2(cellSize, cellSize - 7), Vector2(cellSize, 7)]
	$Polygon2D.set_polygon(points)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
