extends CanvasLayer

@onready var game_manager = get_tree().root.get_node("game_manager")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_restart_button_pressed() -> void:
	global.rest_player()
	global.respawning = true
	
	# in game_manager.gd, add_child is followed by move_child, which movs curr lvl to the top or 0th posn
	# thus, game_manager.get_child(0) -> current level of death which is passes as old_scene param into swap_levels
	game_manager.swap_levels(game_manager.get_child(0), global.last_rested_scene, global.last_rested_coords)
	queue_free();
