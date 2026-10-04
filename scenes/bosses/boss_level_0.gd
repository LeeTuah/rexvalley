extends CharacterBody2D

@onready var animated_sprite = $animated_sprite;
@onready var animation_player = $animation_player;
@onready var boss_bar = $BossLayer/BossBar
@onready var slow_bar = $BossLayer/SlowBar

const MAX_HEALTH : float = 1000.0
const SPEED = 200.0
const JUMP_VELOCITY = -400.0
const DRAIN_COOLDOWN = 0.5
const SLOW_BAR_DRAIN_RATE = 150

var current_health: float = 1000.0
var death_timer = null
var drain_timer = 0.0
var is_dead = false

func _ready():
	boss_bar.max_value = MAX_HEALTH
	boss_bar.value = current_health

	slow_bar.max_value = MAX_HEALTH
	slow_bar.value = current_health

	animation_player.play("walk");

	death_timer = Timer.new()
	add_child(death_timer)
	death_timer.wait_time = 0.4
	death_timer.connect("timeout", queue_free)


func take_damage(damage: float, _direction: Vector2, _knockback: float, _knockback_cooldown: float) -> void:
	current_health -= damage
	current_health = clampf(current_health, 0.0, MAX_HEALTH)
	boss_bar.value = current_health
	drain_timer = DRAIN_COOLDOWN

	# SLOW_BAR_DRAIN_RATE = (slow_bar.value - current_health)/3

	
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

	if slow_bar.value > current_health:
		if drain_timer >= 0.0:
			drain_timer -= _delta
		else:
			slow_bar.value = move_toward(slow_bar.value, current_health, _delta * SLOW_BAR_DRAIN_RATE)

	#boss dead
	elif slow_bar.value <= 0.0:
		if not is_dead:
			death_timer.start()
			is_dead = true
