extends Node2D

var boss = preload("res://scenes/bosses/boss_level_0.tscn")

var boss_spawned: bool = false;
var boss_dead: bool = false;


func _ready() -> void:
	$static_wall/CollisionShape2D.set_deferred("disabled", true);
	$portal_sprite_left.visible = false;
	$portal_sprite_right.visible = false;


func _process(_delta: float) -> void:
	pass
	# $player_point_light.position = global.player_position;

	if (boss_spawned and (not get_parent().has_node("boss_level_0"))):
		$portal_sprite_left.play_backwards("gate_close");
		$portal_sprite_right.play_backwards("gate_close");

		$static_wall/CollisionShape2D.set_deferred("disabled", true);
		$static_wall/CollisionShape2D2.set_deferred("disabled", true);
		boss_spawned = false;
		boss_dead = true;

	if (boss_dead and not $portal_sprite_left.is_playing()):
		$portal_sprite_left.visible = false;
		$portal_sprite_right.visible = false;
	

func _on_boss_spawn_area_body_entered(body: Node2D) -> void:
	if (boss_spawned or boss_dead): return;

	if (body.name == "player"):
		$static_wall/CollisionShape2D.set_deferred("disabled", false);

		$portal_sprite_left.visible = true;
		$portal_sprite_left.play("gate_close");

		$portal_sprite_right.visible = true;
		$portal_sprite_right.play("gate_close");

		# play_backwards()

		var boss_instance = boss.instantiate();
		boss_instance.name = "boss_level_0";
		boss_instance.position = Vector2(-7500, 640);

		get_parent().call_deferred("add_child", boss_instance)
		boss_spawned = true;
