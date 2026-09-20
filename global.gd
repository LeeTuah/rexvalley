extends Node

signal health_changed(curr_health);
signal stamina_changed(curr_stamina);
signal mana_changed(curre_mana);

const MAX_HEALTH:float = 100.0;
const MAX_STAMINA:float = 100.0;
const MAX_MANA:float = 100.0;

var player_direction :float = 1;
var player_position = Vector2(0.0, 0.0);

var current_health:float = MAX_HEALTH:
	set(value):
		current_health = clampf(value, 0.0, MAX_HEALTH);
		health_changed.emit(current_health);
	
var current_stamina:float = MAX_STAMINA:
	set(value):
		current_stamina = clampf(value, 0.0, MAX_STAMINA);
		stamina_changed.emit(current_stamina);

var current_mana:float = MAX_MANA:
	set(value):
		current_mana = clampf(value, 0.0, MAX_MANA);
		mana_changed.emit(current_mana);
