extends Node2D
class_name GameManager

signal exit

var Board = preload("res://scenes/managers/board/Board.tscn")
var board: Board
var GameTimer = preload("res://scenes/ui/GameTimer.tscn")
var gameTimer: GameTimer
var Score = preload("res://scenes/ui/Score.tscn")
var scoreboard: Score
var music: AudioStreamPlayer
var musicTracks: Array[String] = [
"res://assets/music/JOXION - Talk That Way [NCS Release] (instrumental).mp3",
"res://assets/music/LOUD ABOUT US! - Goes Like [NCS Release].mp3",
"res://assets/music/Max Brhon - Humanity [NCS Release].mp3",
"res://assets/music/More Plastic & URBANO - Psycho [NCS Release] (instrumental).mp3",
"res://assets/music/NOYSE & ÆSTRØ - La Manera De Vivir [NCS Release] (instrumental).mp3",
"res://assets/music/SIIK & Alenn - Mess [NCS Release] (instrumental).mp3",
"res://assets/music/Sam Ourt, AKIAL & Srikar - Escape (Juan Dileju & Sam Ourt VIP Mix) [NCS Release] (instrumental).mp3",
"res://assets/music/Siberian Express - Talk To Me [NCS Release] (instrumental).mp3",
"res://assets/music/Toxic Joy - All Night [NCS Release] (instrumental).mp3",
"res://assets/music/Track NATSUMI - Take Me Away [NCS Release].mp3",
"res://assets/music/Alisky - Grow (feat. VØR) [NCS Release] (instrumental).mp3",
"res://assets/music/Approaching Nirvana & Alex Holmes - Darkness Comes [NCS Release] (instrumental).mp3"
]

# Called when the node enters the scene tree for the first time.
func _ready():
	music = AudioStreamPlayer.new()
	music.set_bus("Reduce")
	music.finished.connect(_on_music_finished)
	add_child(music)
	board = Board.instantiate()
	board.init()
	board.position = Vector2(18, 18)
	board.win.connect(_on_board_win)
	board.score.connect(_on_board_score)
	add_child(board)
	play_random_song()
	gameTimer = GameTimer.instantiate()
	add_child(gameTimer)
	scoreboard = Score.instantiate()
	add_child(scoreboard)

func _on_board_score(score: int):
	scoreboard.set_score(score)

func _on_board_win():
	gameTimer.stopped = true
	board.player.win()

func _on_music_finished():
	play_random_song()

func play_random_song():
	music.stream = load(musicTracks[randi() % musicTracks.size()])
	music.play()

func _input(event):
	if event.is_action_pressed("exit"):
		emit_signal("exit")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	pass
