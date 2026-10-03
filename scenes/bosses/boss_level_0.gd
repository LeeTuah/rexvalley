extends CharacterBody2D

@onready var animated_sprite = $animated_sprite;

const SPEED = 200.0
const JUMP_VELOCITY = -400.0

func _ready():
	animated_sprite.play("walk");

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction = 0;
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	velocity.x = SPEED;

	move_and_slide()
