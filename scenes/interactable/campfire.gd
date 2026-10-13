extends Area2D

var player_near_campfire = false
var campfire_active = false
var player_node = null

@export var campfire_name : String 
@export var campfire_scene : String

@onready var campfire_animation = $campfire_animation
@onready var campfire_label = $campfire_label
@onready var campfire_light = $"../light_nodes/campfire_light"

func _ready() -> void:
	global.fade_out(campfire_label)
	
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
			handle_player_resting()


func handle_campfire_activation() -> void:
	campfire_active = true
	global.campfire_status[campfire_name] = true

	var player_adjustment = global_position.x - 30.0
	var look_right = true

	if player_node.has_method("play_campfire_animation"):
		player_node.play_campfire_animation(player_adjustment, look_right)

	await get_tree().create_timer(1.3).timeout

	campfire_animation.play("burning")
	
	campfire_light.energy = 1.2
	
	global.fade_out(campfire_label)
	campfire_label.text = "REST"
	
	#global.fade_in(campfire_label)

func handle_player_resting() -> void:
	if player_node.has_method("play_resting_animation"):
		player_node.play_resting_animation()
				
		await get_tree().create_timer(1.12)
		
	global.rest_player()
	
	global.last_rested_scene = owner.scene_file_path
	global.last_rested_coords = global_position
	
	
func _on_body_entered(body: Node2D) -> void:
	if body.name == 'player':
		player_near_campfire = true
		player_node = body
		global.fade_in(campfire_label)


func _on_body_exited(body: Node2D) -> void:
	if body.name == 'player':
		player_near_campfire = false
		player_node = null
		global.fade_out(campfire_label)
