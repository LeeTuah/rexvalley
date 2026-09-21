extends TextureProgressBar

func _ready() -> void:
	max_value = global.MAX_MANA
	value = global.current_mana
	
	global.mana_changed.connect(change_player_mana)
	

func change_player_mana(curr_mana):
	value = curr_mana
