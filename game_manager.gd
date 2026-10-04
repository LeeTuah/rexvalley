extends Node2D

func swap_levels(old_scene, new_scene_path, _player_coordinates) -> void:
	var current_level = old_scene;

	if current_level:
		current_level.queue_free();

	var new_scene = load(new_scene_path);
	var new_scene_instance = new_scene.instantiate();

	add_child(new_scene_instance);
	move_child(new_scene_instance, 0);

	# change player position here
	get_node("player").position = _player_coordinates

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass
