extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D;

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var health_point = 100000000000;

var knockback_force = Vector2(0.0, 0.0);
var knockback_countdown = 0.0;

func take_damage(damage: float, direction: Vector2, knockback: float, knockback_cooldown: float):
	print("cholche")
	health_point -= damage;
	health_point = clamp(health_point, 0.0, 100000000000.0);

	if (health_point == 0.0):
		queue_free();

	knockback_force = knockback * direction;
	knockback_countdown = knockback_cooldown;
	velocity = knockback_force

func _ready() -> void:
	animated_sprite.play("idle");
	scale.x = -1;

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if (knockback_countdown > 0.0):
		knockback_countdown -= delta;
		

		velocity.x -= 200 * delta
		if velocity.x <= 0.0:
			velocity.x = 0.0

	move_and_slide()

# func _process(delta: float) -> void:
# 	if (knockback_countdown >= 0.0):
# 		knockback_countdown -= delta;
# 		velocity = knockback_force;

# 	else:
# 		knockback_force = Vector2(0.0, 0.0);

# 	move_and_slide();
