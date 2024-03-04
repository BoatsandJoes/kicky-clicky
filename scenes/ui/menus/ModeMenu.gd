extends CanvasLayer
class_name ModeMenu

signal exit
signal start(mode:int, timeLimit)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event.is_action_pressed("exit"):
		_on_back_pressed()
	elif event.is_action_pressed("kick"):
		_on_kicky_pressed()

func _on_kicky_pressed():
	emit_signal("start", Constants.Modes.KICKY, null)

func _on_pushy_pressed():
	emit_signal("start", Constants.Modes.PUSHY, null)

func _on_kicky_caravan_pressed():
	emit_signal("start", Constants.Modes.KICKY, 165)

func _on_pushy_caravan_pressed():
	emit_signal("start", Constants.Modes.PUSHY, 165)

func _on_back_pressed():
	emit_signal("exit")
