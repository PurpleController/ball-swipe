extends Node2D

@export var levels: Array[PackedScene]

@onready var admob: Admob = $Admob as Admob
@onready var scorelabel = $CanvasLayer/ScoreLabel
@onready var scorelabel2 = $"CanvasLayer/Game Over/ScoreLabel"
@onready var highscorelabel = $"CanvasLayer/Game Over/HighScoreLabel"

var current_level_scene: PackedScene
var score: int = 0
var high_score_reached: bool = false
var current_level
var red_zones = []
var already_revived = false
var invincibility = false

func _ready():
	admob.load_rewarded_ad()
	highscorelabel.text = "High Score: " + str(HighScore.high_score)
	scorelabel.text = "Score: 0"
	scorelabel2.text = "Score: 0"
	$"CanvasLayer/Game Over".visible = false

	current_level_scene = levels[0]
	load_level(current_level_scene)

	var win_zone = current_level.get_node("Win zone")
	red_zones = current_level.get_node("Red zones").get_children()

	win_zone.body_entered.connect(win)

	for red_zone in red_zones:
		red_zone.body_entered.connect(lose)


func _physics_process(_delta):
	for red_zone in red_zones:
		if red_zone.has_overlapping_bodies() and not invincibility:
			lose(null)

func next_level():
	if current_level:
		current_level.queue_free()

	var available_levels = levels.filter(func(level):
		return level != current_level_scene
	)

	current_level_scene = available_levels.pick_random()
	load_level(current_level_scene)

func load_level(level):
	current_level = level.instantiate()
	add_child(current_level)

	var win_zone = current_level.get_node("Win zone")
	win_zone.body_entered.connect(win)

	red_zones = current_level.get_node("Red zones").get_children()

	for red_zone in red_zones:
		red_zone.body_entered.connect(lose)

func _load_next_level():
	if current_level:
		current_level.queue_free()

	var chosen_level = levels.filter(func(level): return level != null).pick_random()
	current_level = chosen_level.instantiate()
	add_child(current_level)

func update_score():
	score += 100

	if score >= HighScore.high_score:
		HighScore.high_score = score

	scorelabel.text = "Score: " + str(score)
	scorelabel2.text = "Score: " + str(score)
	highscorelabel.text = "High Score: " + str(HighScore.high_score)

func win(_body):
	update_score()
	call_deferred("next_level")

func lose(_body):
	if invincibility:
		return

	if _body is RigidBody2D:
		HighScore.save_high_score()

		get_tree().paused = true
		$"CanvasLayer/Game Over".visible = true
		$CanvasLayer/Control/Control/Pause.hide()
		
		if already_revived:
			$"CanvasLayer/Game Over/Ad".visible = false
		else:
			$"CanvasLayer/Game Over/Ad".visible = true


func _on_ad_pressed() -> void:
	admob.show_rewarded_ad()


func _invincibility() -> void:
	invincibility = true
	$Player.modulate.a = 0.5 
	await get_tree().create_timer(2).timeout
	$Player.modulate.a = 1.0
	invincibility = false


func _on_admob_rewarded_ad_loaded(_ad_info: AdInfo, _response_info: ResponseInfo) -> void:
	print("loaded")


func _on_admob_rewarded_ad_dismissed_full_screen_content(_ad_info: AdInfo) -> void:
	already_revived = true
	get_tree().paused = false
	_invincibility()
	$"CanvasLayer/Game Over".visible = false
	admob.load_rewarded_ad()
