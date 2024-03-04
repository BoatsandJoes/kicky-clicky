extends CanvasLayer
class_name Credits

signal exit
var currentLabel: int = 1
var labelCount: int = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func change_label(new: int):
	for i in range(1, labelCount + 1):
		get_node("%Label" + str(i)).visible = false
	get_node("%Label" + str(new)).visible = true
	currentLabel = new

func _input(event):
	if event.is_action_pressed("exit"):
		if currentLabel == 1:
			emit_signal("exit")
		else:
			change_label(currentLabel - 1)
	elif event.is_action_pressed("kick"):
		if currentLabel == labelCount:
			emit_signal("exit")
		else:
			change_label(currentLabel + 1)
	elif (event.is_action_pressed("right") || event.is_action_pressed("down")) && currentLabel < labelCount:
			change_label(currentLabel + 1)
	elif (event.is_action_pressed("up") || event.is_action_pressed("left")) && currentLabel > 1:
		change_label(currentLabel - 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
