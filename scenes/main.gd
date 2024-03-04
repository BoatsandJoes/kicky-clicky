extends Node2D
class_name Main

var GameManager = preload("res://scenes/managers/GameManager.tscn")
var game: GameManager
var MainMenu = preload("res://scenes/ui/menus/MainMenu.tscn")
var ModeMenu = preload("res://scenes/ui/menus/ModeMenu.tscn")
var Credits = preload("res://scenes/ui/menus/Credits.tscn")
var menu

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().get_root().size_changed.connect(_on_root_size_changed)
	resize_window(1280, 720)
	go_to_main_menu()

func resize_window(width: int, height: int):
	var newSize: Vector2i = Vector2i(width, height)
	get_window().position = get_window().position + (get_tree().get_root().size - newSize) / 2
	get_tree().get_root().size = newSize

func remove_children():
	if game != null:
		remove_child(game)
		game.queue_free()
	if menu != null:
		remove_child(menu)
		menu.queue_free()

func go_to_main_menu():
	remove_children()
	menu = MainMenu.instantiate()
	menu.exit.connect(_on_main_menu_exit)
	menu.play.connect(_on_main_menu_play)
	menu.credits.connect(_on_menu_credits)
	add_child(menu)

func _on_menu_credits():
	remove_children()
	menu = Credits.instantiate()
	menu.exit.connect(go_to_main_menu)
	add_child(menu)

func _on_main_menu_play():
	remove_children()
	menu = ModeMenu.instantiate()
	menu.exit.connect(_on_mode_menu_exit)
	menu.start.connect(_on_mode_menu_start)
	add_child(menu)

func _on_mode_menu_start(mode: int, timeLimit):
	remove_children()
	game = GameManager.instantiate()
	game.exit.connect(_on_game_exit)
	add_child(game)
	if mode == Constants.Modes.KICKY:
		game.board.pushEnabled = false
		game.board.player.kickEnabled = true
	elif mode == Constants.Modes.PUSHY:
		game.board.pushEnabled = true
		game.board.player.kickEnabled = false
	if timeLimit != null:
		game.gameTimer.timeLimit = timeLimit
		game.board.leaveResidue = true

func _on_game_exit():
	_on_main_menu_play()

func _on_mode_menu_exit():
	go_to_main_menu()

func _on_main_menu_exit():
	get_tree().quit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_root_size_changed():
	pass
