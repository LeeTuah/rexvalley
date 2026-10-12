extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene();
	
	global.current_health = 100;
	global.current_defence = 0;
	global.current_stamina = 100;
	global.current_mana = 100;
	
	queue_free();
