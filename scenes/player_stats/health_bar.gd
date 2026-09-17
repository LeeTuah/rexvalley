extends TextureProgressBar

func _ready() -> void:
	max_value = global.MAX_HEALTH
	value = global.current_health
	
	global.health_changed.connect(change_player_health)
	

func change_player_health(curr_health):
	value = curr_health
	print(value)
	
