extends CharacterBody2D

@onready var animated_sprite = $animated_sprite;
@onready var sword_hitbox = $sword_hitbox;
@onready var boss_bar = $BossLayer/BossBar
@onready var slow_bar = $BossLayer/SlowBar

@onready var animation_tree = $AnimationTree;
@onready var state_machine = animation_tree.get("parameters/playback")

const MAX_HEALTH : float = 500.0
const SPEED = 200.0
const JUMP_VELOCITY = -400.0
const DRAIN_COOLDOWN = 0.5
const SLOW_BAR_DRAIN_RATE = 150

var current_health: float = 1000.0
var death_timer = null
var drain_timer = 0.0
var is_dead = false

var player_distance: float = 0.0;
const PLAYER_ATTACK_DIST: float = 200.0;
const SWORD_SLASH_DOWN_CHANCE: float = 67;

var boss_flipped = false;

const ATTACK_ANIMS = ["sword_slash_up", "sword_slash_down"];

func _ready():
	boss_bar.max_value = MAX_HEALTH
	boss_bar.value = current_health

	slow_bar.max_value = MAX_HEALTH
	slow_bar.value = current_health

	death_timer = Timer.new()
	add_child(death_timer)
	death_timer.wait_time = 0.4
	death_timer.connect("timeout", queue_free)

	animation_tree.active = true;

func enable_collision_interaction(value: bool):
	set_collision_layer_value(2, value);
	set_collision_mask_value(2, value);

	set_collision_layer_value(1, not value);
	set_collision_mask_value(1, not value);

func take_damage(damage: float, _direction: Vector2, _knockback: float, _knockback_cooldown: float) -> void:
	current_health -= damage
	current_health = clampf(current_health, 0.0, MAX_HEALTH)
	boss_bar.value = current_health
	drain_timer = DRAIN_COOLDOWN

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction = sign(position.x - global.player_position.x) * -1;

	if direction and player_distance > PLAYER_ATTACK_DIST and (not state_machine.get_current_node() in ATTACK_ANIMS):
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func make_boss_idle(idle: bool):
	animation_tree["parameters/conditions/is_idle"] = idle;
	animation_tree["parameters/conditions/is_walking"] = not idle;

func animations_or_sum():
	var flip_boss = sign(global.player_position.x - position.x) < 0;

	animated_sprite.flip_h = flip_boss;
	sword_hitbox.scale.x = -1 if flip_boss else 1;

	make_boss_idle(not (player_distance > PLAYER_ATTACK_DIST));

	animation_tree["parameters/conditions/do_slash_up"] = not (player_distance > PLAYER_ATTACK_DIST);
	animation_tree["parameters/conditions/do_slash_down"] = animation_tree["parameters/conditions/do_slash_up"];
	
	if state_machine.get_current_node() == "sword_slash_up":
		animation_tree["parameters/conditions/do_slash_up"] = false;

func _process(delta: float) -> void:
	player_distance = abs(position.x - global.player_position.x);

	enable_collision_interaction(global.is_player_dashing);
	if slow_bar.value > current_health:
		if drain_timer >= 0.0:
			drain_timer -= delta

		else:
			slow_bar.value = move_toward(slow_bar.value, current_health, delta * SLOW_BAR_DRAIN_RATE)

	#boss dead
	elif slow_bar.value <= 0.0:
		if not is_dead:
			death_timer.start()
			is_dead = true
	
	animations_or_sum();



func _on_sword_hitbox_body_entered(body: Node2D) -> void:
	if (body.name == "player"):
		var dmg = 0;
		match state_machine.get_current_node():
			"sword_slash_up":
				dmg = 10;

			"sword_slash_down":
				dmg = 15;

		global.damage_player(dmg);
