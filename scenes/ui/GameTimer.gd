extends CanvasLayer
class_name GameTimer

var timeElapsed: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func updateTimer(seconds: float):
	var secondsInt = floori(seconds)
	if secondsInt > 59:
		%TimerDisplay.text = str(secondsInt / 60) + ":" + pad(str(secondsInt % 60))
	else:
		if secondsInt < 0:
			secondsInt = 0
		%TimerDisplay.text = "0:" + pad(str(secondsInt))

func pad(str: String) -> String:
	if str.length() == 1:
		str = "0" + str
	return str

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timeElapsed = timeElapsed + delta
	updateTimer(timeElapsed)
