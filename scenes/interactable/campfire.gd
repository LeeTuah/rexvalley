extends Area2D

var player_near_campfire = false
var campfire_active = false
var player_node = null

@onready var campfire_animation = $campfire_animation
@export var campfire_name : String 
@export var campfire_scene : String


func _ready() -> void:
	if global.campfire_status[campfire_name]:
		campfire_animation.play("burning")
		campfire_active = true

	else:
		campfire_animation.play("extinguish")


func _process(_delta: float) -> void:
	if player_near_campfire and Input.is_action_just_pressed("ui_interact"):
		
		if not campfire_active:
			handle_campfire_activation()
		else:
			global.rest_player()


func handle_campfire_activation() -> void:
	campfire_active = true
	global.campfire_status[campfire_name] = true

	var player_adjustment = global_position.x - 30.0
	var look_right = true

	if player_node.has_method("play_campfire_animation"):
		player_node.play_campfire_animation(player_adjustment, look_right)

	await get_tree().create_timer(1.3).timeout

	campfire_animation.play("burning")


func _on_body_entered(body: Node2D) -> void:
	if body.name == 'player':
		player_near_campfire = true
		player_node = body


func _on_body_exited(body: Node2D) -> void:
	if body.name == 'player':
		player_near_campfire = false
		player_node = null
