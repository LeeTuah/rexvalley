extends Area2D

var SPEED = 1200;
var direction;

func _ready() -> void:
	direction = global.player_direction;
	$Fireball.flip_h = direction < 0; 

func _physics_process(delta: float) -> void:
	position.x += direction * SPEED * delta;
	
