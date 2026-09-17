extends Node

signal health_changed(curr_health)
signal stamina_changed(curr_stamina)

const MAX_HEALTH:float = 100.0
const MAX_STAMINA:float = 50.0

var player_position = Vector2(0.0, 0.0)
var current_health:float = MAX_HEALTH:
	set(value):
		current_health = clampf(value, 0.0, MAX_HEALTH)
		health_changed.emit(current_health)
	
var current_stamina:float = 25:
	set(value):
		current_stamina = clampf(value, 0.0, MAX_STAMINA)
		stamina_changed.emit(current_stamina)
