extends Area2D

@export var next_scene : String
@export var next_scene_spawn_point : Vector2

@onready var enter_label = $enter_text
@onready var door_animation = $door_animation
@onready var door_collision_polygon = $door_collision_polygon
@onready var game_manager = get_tree().root.get_node("game_manager")

var player_before_door = false
var door_opened = false

func _ready() -> void:
	global.fade_out($enter_text);


func _process(delta: float) -> void:
	if player_before_door and Input.is_action_just_pressed("ui_interact") and not door_opened:
		door_animation.play("door_opening")
		door_opened = true

		#this makes the code stop executing until current door animation is over
		await door_animation.animation_finished

		game_manager.swap_levels(get_parent(), next_scene, next_scene_spawn_point)


func _on_body_entered(body: Node2D) -> void:
	if body.name == 'player':
		global.fade_in($enter_text);
		player_before_door = true


func _on_body_exited(body: Node2D) -> void:
	if body.name == 'player':
		global.fade_out($enter_text);
		player_before_door = false
