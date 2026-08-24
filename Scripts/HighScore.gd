extends Node

var score: int = 0
var high_score: int = 50
var high_score_reached: bool = false

const SAVE_PATH := "user://highscore.cfg"

func _ready():
	load_high_score()

func add_score(amount: int):
	score += amount

	if score >= high_score:
		high_score_reached = true

	if high_score_reached:
		high_score = score

func reset_score():
	score = 0
	high_score_reached = false

func save_high_score():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	if file:
		file.store_32(high_score)

func load_high_score():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)

		if file:
			high_score = file.get_32()
