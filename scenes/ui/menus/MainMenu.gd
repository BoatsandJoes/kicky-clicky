extends CanvasLayer

signal play
signal exit
signal credits

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if event.is_action_pressed("exit"):
		emit_signal("exit")
	elif event.is_action_pressed("kick"):
		_on_play_pressed()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_play_pressed():
	emit_signal("play")

func _on_exit_pressed():
	emit_signal("exit")

func _on_credits_pressed():
	emit_signal("credits")
