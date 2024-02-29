extends Node2D
class_name GameManager

var Board = preload("res://scenes/managers/board/Board.tscn")
var board: Board

# Called when the node enters the scene tree for the first time.
func _ready():
	board = Board.instantiate()
	board.init()
	board.position = Vector2(10, 10)
	add_child(board)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	pass
