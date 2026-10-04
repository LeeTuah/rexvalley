extends CharacterBody2D

@onready var animated_sprite = $animated_sprite;
@onready var animation_player = $animation_player;
@onready var boss_bar = $BossLayer/BossBar

const MAX_HEALTH : float = 1000.0
const SPEED = 200.0
const JUMP_VELOCITY = -400.0

var current_health: float = 1000.0

func _ready():
	boss_bar.max_value = MAX_HEALTH
	boss_bar.value = current_health
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
