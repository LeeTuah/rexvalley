extends Area2D

const SPEED = 1200;
const DAMAGE = 30;
const KNOCKBACK = 550;
var direction;


func _ready() -> void:
	direction = global.player_direction;
	$fireball_sprite.flip_h = direction < 0; 

func _physics_process(delta: float) -> void:
	position.x += direction * SPEED * delta;

func _on_body_entered(body: Node2D) -> void:
	if (body.has_method("take_damage") and body.name != "player"):
		body.take_damage(DAMAGE, Vector2(direction, 0.0), KNOCKBACK, 0.92145);
		queue_free();
