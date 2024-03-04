extends Node

enum Directions {UP, DOWN, LEFT, RIGHT}
enum Colors {RED, BLUE, YELLOW, GREEN}
enum Modes {KICKY, PUSHY}
const cellSize: int = 36

func flip_direction(direction: int) -> int:
	if direction == Directions.UP:
		return Directions.DOWN
	elif direction == Directions.DOWN:
		return Directions.UP
	elif direction == Directions.LEFT:
		return Directions.RIGHT
	else:
		return Directions.LEFT
