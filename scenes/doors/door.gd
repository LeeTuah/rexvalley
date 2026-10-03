extends Area2D
@onready var enter_label = $enter_text
@onready var door_animation = $door_animation
@onready var door_collision_polygon = $door_collision_polygon

var player_before_door = false
var door_currently_opening = false
var door_anim_cooldown = 1.0
var door_anim_time = 0.0

func _ready() -> void:
	enter_label.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	if door_currently_opening:
		door_anim_time -= delta
		if door_anim_time <= 0:
			door_currently_opening = false

	elif player_before_door and Input.is_action_just_pressed("ui_interact"):
		door_animation.play("door_opening")
		door_currently_opening = true
		door_anim_time = door_anim_cooldown


func _on_body_entered(body: Node2D) -> void:
	if body.name == 'player':
		enter_label.show()
		player_before_door = true


func _on_body_exited(body: Node2D) -> void:
	if body.name == 'player':
		enter_label.hide()
		player_before_door = false
