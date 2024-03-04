extends CanvasLayer
class_name GameTimer

signal outOfTime

var timeElapsed: float = 0.0
var stopped = false
var timeLimit = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setTimeLimit(timeLimit: int):
	self.timeLimit = timeLimit

func updateTimer(seconds: float):
	var secondsInt = floori(seconds)
	if timeLimit != null:
		secondsInt = timeLimit - secondsInt
	if secondsInt > 59:
		%TimerDisplay.text = str(secondsInt / 60) + ":" + pad(str(secondsInt % 60))
	else:
		if secondsInt < 0:
			secondsInt = 0
			emit_signal("outOfTime")
		%TimerDisplay.text = "0:" + pad(str(secondsInt))

func pad(str: String) -> String:
	if str.length() == 1:
		str = "0" + str
	return str

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !stopped:
		timeElapsed = timeElapsed + delta
		updateTimer(timeElapsed)
