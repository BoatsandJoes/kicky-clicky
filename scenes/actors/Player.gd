extends Node2D
class_name Player

signal kick(direction: int)
signal move(distance: int, direction: int)
signal launch_advance(piece, steps: int)

var positionFlatIndex: int
var direction: int = Constants.Directions.RIGHT
var moving: bool = false
var moveThreshold: float = 0.15
var moveProgress: float = 0
var launchProgress: float = 0.0
var launchDirection = null
var launchThreshold: float = 0.5
var pairedPieceIndex = null #always null, just here to avoid access errors

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func change_direction(direction: int):
	if self.direction != direction:
		moveProgress = 0
	self.direction = direction
	if direction == Constants.Directions.RIGHT:
		$AnimationPlayer.play("walk_right")
	elif direction == Constants.Directions.LEFT:
		$AnimationPlayer.play("walk_left")
	elif direction == Constants.Directions.UP:
		$AnimationPlayer.play("walk_up")
	elif direction == Constants.Directions.DOWN:
		$AnimationPlayer.play("walk_down")

func launch(direction: int):
	launchDirection = direction

func stop_launching():
	launchDirection = null

func stop_moving():
	moving = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	if launchDirection != null:
		launchProgress = launchProgress + delta
		if launchProgress >= launchThreshold:
			emit_signal("launch_advance", self, launchProgress / launchThreshold)
			launchProgress = fmod(launchProgress, launchThreshold)
	elif moving:
		moveProgress += delta
		var moves = floor(moveProgress / moveThreshold)
		if moves > 0:
			emit_signal("move", moves, direction)
			moveProgress = fmod(moveProgress, moveThreshold)

func _input(event):
	if event.is_action_pressed("kick"):
		emit_signal("kick")
	elif event.is_action_pressed("up"):
		if moving && direction == Constants.Directions.DOWN:
			stop_moving()
		else:
			change_direction(Constants.Directions.UP)
			moving = true
	elif event.is_action_pressed("down"):
		if moving && direction == Constants.Directions.UP:
			stop_moving()
		else:
			change_direction(Constants.Directions.DOWN)
			moving = true
	elif event.is_action_pressed("left"):
		if moving && direction == Constants.Directions.RIGHT:
			stop_moving()
		else:
			change_direction(Constants.Directions.LEFT)
			moving = true
	elif event.is_action_pressed("right"):
		if moving && direction == Constants.Directions.LEFT:
			stop_moving()
		else:
			change_direction(Constants.Directions.RIGHT)
			moving = true
	elif event.is_action_released("up") && !Input.is_action_pressed("up"):
		if Input.is_action_pressed("down"):
			change_direction(Constants.Directions.DOWN)
			moving = true
		elif direction == Constants.Directions.UP:
			stop_moving()
	elif event.is_action_released("down") && !Input.is_action_pressed("down"):
		if Input.is_action_pressed("up"):
			change_direction(Constants.Directions.UP)
			moving = true
		elif direction == Constants.Directions.DOWN:
			stop_moving()
	elif event.is_action_released("left") && !Input.is_action_pressed("left"):
		if Input.is_action_pressed("right"):
			change_direction(Constants.Directions.RIGHT)
			moving = true
		elif direction == Constants.Directions.LEFT:
			stop_moving()
	elif event.is_action_released("right") && !Input.is_action_pressed("right"):
		if Input.is_action_pressed("left"):
			change_direction(Constants.Directions.LEFT)
			moving = true
		elif direction == Constants.Directions.RIGHT:
			stop_moving()
