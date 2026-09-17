extends Node

signal health_changed(curr)

const MAX_HEALTH:float = 100.0

var player_position = Vector2(0.0, 0.0)
var current_health:float = MAX_HEALTH:
	set(value):
		current_health = clampf(value, 0.0, MAX_HEALTH)
		health_changed.emit(current_health)
