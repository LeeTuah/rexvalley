extends TextureProgressBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	max_value = global.MAX_STAMINA
	value = global.current_stamina
	
	global.stamina_changed.connect(change_player_stamina)


func change_player_stamina(curr_stamina):
	value = curr_stamina
	# print("Current Stamina = ", value)
