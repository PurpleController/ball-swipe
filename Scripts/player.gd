extends RigidBody2D

@export var launch_strength := 5.0

@onready var ground_check = $GroundCheck/RayCast2D
@onready var ground_check2 = $GroundCheck/RayCast2D2
@onready var ground_check3 = $GroundCheck/RayCast2D3
@onready var ground_check4 = $GroundCheck/RayCast2D4
@onready var pause = $"../CanvasLayer/Panel"

var drag_start := Vector2.ZERO
var dragging := false

func _ready() -> void:
	collision_layer = 1
	collision_mask = 1
	pause.visible = false


func _physics_process(_delta) -> void:
	$GroundCheck.global_rotation = 0

func is_on_ground() -> bool:
	var grounded = (
		ground_check.is_colliding()
		or ground_check2.is_colliding()
		or ground_check3.is_colliding()
		or ground_check4.is_colliding()
	)

	return grounded

func _input(event) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if is_on_ground():
				drag_start = event.position
				dragging = true
		else:
			if dragging:
				var direction = drag_start - event.position
				apply_impulse(direction * launch_strength)
				dragging = false
	if event.is_action_pressed("pause"):
		get_tree().paused = true
		pause.visible = true

func _on_resume_pressed() -> void:
		get_tree().paused = false
		pause.visible = false

func _on_win_zone_body_entered(_body: Node2D):
	get_node("../").win()


func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")


func _on_retry_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
