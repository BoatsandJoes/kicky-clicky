extends Node2D
class_name Main

var GameManager = preload("res://scenes/managers/GameManager.tscn")
var game: GameManager

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().get_root().size_changed.connect(_on_root_size_changed)
	resize_window(1280, 720)
	start_singleplayer()

func resize_window(width: int, height: int):
	var newSize: Vector2i = Vector2i(width, height)
	get_window().position = get_window().position + (get_tree().get_root().size - newSize) / 2
	get_tree().get_root().size = newSize

func start_singleplayer():
	game = GameManager.instantiate()
	add_child(game)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_root_size_changed():
	pass
