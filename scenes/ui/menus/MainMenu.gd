extends CanvasLayer

signal play(mode: int)
signal exit

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if event.is_action_pressed("exit"):
		emit_signal("exit")
	elif event.is_action_pressed("kick"):
		emit_signal("play", Constants.Modes.KICKY)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_play_pressed():
	emit_signal("play", Constants.Modes.KICKY)

func _on_play_pushy_pressed():
	emit_signal("play", Constants.Modes.PUSHY)

func _on_exit_pressed():
	emit_signal("exit")
