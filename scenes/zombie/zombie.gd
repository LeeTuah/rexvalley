extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D;

const SPEED = 100.0
const JUMP_VELOCITY = -400.0

const MAX_HEALTH = 100.0;
const ZOMBIE_DAMAGE = 5.0;
var health_point = MAX_HEALTH;

var knockback_countdown = 0.0;

var player_to_zombie_dirn = 0;

const ZOMBIE_HITBOX_OFFSET = [13.0, 70.0];

func take_damage(damage: float, direction: Vector2, knockback: float, knockback_cooldown: float):
	health_point -= damage;
	health_point = clamp(health_point, 0.0, MAX_HEALTH);
	if (health_point <= 0.0):
		queue_free();

	velocity = knockback * direction;
	knockback_countdown = knockback_cooldown;

func _ready() -> void:
	animated_sprite.play("idle");

func _physics_process(delta: float) -> void:
	player_to_zombie_dirn = sign((global.player_position.x - position.x));

	if not is_on_floor():
		velocity += get_gravity() * delta

	if (knockback_countdown > 0.0):
		knockback_countdown -= delta;
		velocity.x = move_toward(velocity.x, 0, 200 * delta);

	else:
		velocity.x = player_to_zombie_dirn * SPEED;

	move_and_slide()

func _process(_delta: float) -> void:
	player_to_zombie_dirn = sign((global.player_position.x - position.x));

	$AnimatedSprite2D.flip_h = player_to_zombie_dirn < 0;
	$zombie_hitbox.position.x = ZOMBIE_HITBOX_OFFSET[0] if player_to_zombie_dirn < 0 else -ZOMBIE_HITBOX_OFFSET[0];
	$zombie_sword_hitbox.position.x = -ZOMBIE_HITBOX_OFFSET[1] if player_to_zombie_dirn < 0 else ZOMBIE_HITBOX_OFFSET[1];


func _on_zombie_sword_hitbox_body_entered(body: Node2D) -> void:
	if (body.name == "player"):
		global.current_health -= ZOMBIE_DAMAGE;
