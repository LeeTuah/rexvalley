extends Area2D

@export var next_scene : String
@export var next_door : String
@export var next_scene_spawn_point : Vector2
@export var sprite_frames : SpriteFrames

@onready var enter_label = $enter_text
@onready var door_animation = $door_animation
@onready var door_collision_polygon = $door_collision_polygon
@onready var game_manager = get_tree().root.get_node("game_manager")

var player_before_door = false
var door_opened = false

func _ready() -> void:
	global.fade_out($enter_text);

	if sprite_frames:
		door_animation.sprite_frames = sprite_frames


func _process(_delta: float) -> void:
	if player_before_door and Input.is_action_just_pressed("ui_interact") and not door_opened:
		if level_data_given():
			door_animation.play("door_opening")
			door_opened = true

			#this makes the code stop executing until current door animation is over
			await door_animation.animation_finished
			game_manager.swap_levels(get_parent(), next_scene, next_scene_spawn_point, next_door)


func level_data_given() -> bool:
	if not next_scene:
		print("Next Scene not given")
		return false

	if not next_door:
		print("Next Scene door name not given")
		return false

	if not next_scene_spawn_point:
		print("Coordinates not given")
		return false

	return true

func _on_body_entered(body: Node2D) -> void:
	if body.name == 'player':
		global.fade_in($enter_text);
		player_before_door = true


func _on_body_exited(body: Node2D) -> void:
	if body.name == 'player':
		global.fade_out($enter_text);
		player_before_door = false
