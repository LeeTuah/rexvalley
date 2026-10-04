extends CharacterBody2D

@onready var animated_sprite = $animated_sprite;
@onready var animation_player = $animation_player;

const SPEED = 200.0
const JUMP_VELOCITY = -400.0

func _ready():
	animation_player.play("walk");

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction = 0;
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# velocity.x = -SPEED;

	move_and_slide()

func _process(_delta: float) -> void:
	var flip: bool = global.player_direction;

	$animated_sprite.flip_h = not flip;
