extends Node2D

var boss = preload("res://scenes/bosses/boss_level_0.tscn")

var boss_spawned: bool = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$static_wall/CollisionShape2D.set_deferred("disabled", true);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	# $player_point_light.position = global.player_position;


func _on_boss_spawn_area_body_entered(body: Node2D) -> void:
	if (boss_spawned): return;

	if (body.name == "player"):
		$static_wall/CollisionShape2D.set_deferred("disabled", false);

		var boss_instance = boss.instantiate();
		boss_instance.position = Vector2(7825, 640);

		get_parent().add_child(boss_instance);
		boss_spawned = true;
