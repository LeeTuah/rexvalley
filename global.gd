extends Node

signal health_changed(curr_health);
signal stamina_changed(curr_stamina);
signal mana_changed(curre_mana);

const SCR_WIDTH = 1600;
const SCR_HEIGHT = 900;

const MAX_HEALTH:float = 100.0;
const MAX_STAMINA:float = 100.0;
const MAX_MANA:float = 100.0;

var player_direction :float = 1;
var player_position = Vector2(0.0, 0.0);

var current_level: int = 0;

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

var current_defence:float = 0.0;
var player_name = "test";

var play_camera_shake = false;

func damage_player(damage: float):
	current_health -= damage * (1.0 - current_defence);
	play_camera_shake = true;

func heal_player(damage: float):
	current_health += damage;


const FADE_IN_DURATION = 0.3;
const FADE_OUT_DURATION = 0.6;

func fade_in(label, fade_in_duration = FADE_IN_DURATION):
	var tween = get_tree().create_tween()
	tween.tween_property(label, "modulate:a", 1, fade_in_duration)

	tween.play()
	await tween.finished
	tween.kill()

func fade_out(label, fade_out_duration = FADE_OUT_DURATION):
	var tween = get_tree().create_tween()
	tween.tween_property(label, "modulate:a", 0, fade_out_duration)
	
	tween.play()
	await tween.finished
	tween.kill()
