extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D;
@onready var attack_area = $attack_area_hitbox
@onready var attack_area_hitbox = $attack_area_hitbox/attack_range
@onready var zombie_sword_hitbox = $zombie_sword_hitbox
@onready var sword_slash1_hitbox = $zombie_sword_hitbox/sword_slash1_hitbox
@onready var death_blood = $death_blood
@onready var damage_blood = $damage_blood;

const SPEED = 100.0
const JUMP_VELOCITY = -400.0

const MAX_HEALTH = 30.0;
const ZOMBIE_DAMAGE = 10.0;
var health_point = MAX_HEALTH;

var knockback_countdown = 0.0;
var player_to_zombie_dirn = 0;
var knockback_step = 0.0;

const ZOMBIE_HITBOX_OFFSET = [13.0, 70.0];

var player_in_range = false
var is_attacking = false
var player_vulnerable = false
var zombie_dead = false;

var attack_time = 0.0
var ATTACK_COOLDOWNS = {
	"sword_slash1": 0.4
}

var death_timer = null
var damage_timer = null;

func take_damage(damage: float, direction: Vector2, knockback: float, knockback_cooldown: float):
	if (zombie_dead): return;

	health_point -= damage;
	health_point = clamp(health_point, 0.0, MAX_HEALTH);
	if (health_point <= 0.0):
		death_blood.emitting = true
		damage_blood.emitting = false;

		animated_sprite.visible = false
		zombie_dead = true;

		$zombie_hitbox.set_deferred("disabled", true);

		death_timer.start();

	else:
		damage_blood.emitting = true;
		damage_timer.start();

	velocity = knockback * direction;
	knockback_countdown = knockback_cooldown;
	knockback_step = knockback / knockback_cooldown;


func _ready() -> void:
	animated_sprite.play("idle");
	sword_slash1_hitbox.set_deferred("disabled", true)
	death_blood.emitting = false
	damage_blood.emitting = false;

	death_timer = Timer.new()
	add_child(death_timer)
	death_timer.wait_time = 1.5
	death_timer.connect("timeout", queue_free)

	damage_timer = Timer.new();
	add_child(damage_timer);
	damage_timer.wait_time = 0.5
	damage_timer.connect("timeout", func():
		damage_blood.emitting = false;
	);
	damage_timer.one_shot = true;

func _physics_process(delta: float) -> void:
	var player_to_zombie_dist = abs(global.player_position.x - position.x);
	player_to_zombie_dirn = sign((global.player_position.x - position.x));

	if not is_on_floor():
		velocity += get_gravity() * delta

	if attack_time >= 0.0:
		attack_time -= delta
		if attack_time <= 0.0:
			is_attacking = false
			sword_slash1_hitbox.set_deferred("disabled", true)

	if player_in_range and not is_attacking and not zombie_dead:
		animated_sprite.play("sword_slash1")
		is_attacking = true
		attack_time = ATTACK_COOLDOWNS[animated_sprite.animation]
		sword_slash1_hitbox.set_deferred("disabled", false)

		if player_vulnerable:
			global.damage_player(ZOMBIE_DAMAGE)
	
	if (knockback_countdown > 0.0):
		knockback_countdown -= delta;
		velocity.x = move_toward(velocity.x, 0, knockback_step * delta);

	elif not is_attacking and not zombie_dead and player_to_zombie_dist <= global.SCR_WIDTH * 1.2:
		velocity.x = player_to_zombie_dirn * SPEED;
		animated_sprite.play("walk")
	
	else:
		velocity.x = 0.0

	if (not is_attacking and animated_sprite.animation != "walk" and not zombie_dead):
		animated_sprite.play("idle");

	move_and_slide()
	

func _process(_delta: float) -> void:
	player_to_zombie_dirn = sign((global.player_position.x - position.x));

	animated_sprite.flip_h = player_to_zombie_dirn < 0;
	$zombie_hitbox.position.x = ZOMBIE_HITBOX_OFFSET[0] if player_to_zombie_dirn < 0 else -ZOMBIE_HITBOX_OFFSET[0];
	zombie_sword_hitbox.position.x = -ZOMBIE_HITBOX_OFFSET[1] if player_to_zombie_dirn < 0 else ZOMBIE_HITBOX_OFFSET[1];
	attack_area_hitbox.position.x = -ZOMBIE_HITBOX_OFFSET[1] if player_to_zombie_dirn < 0 else ZOMBIE_HITBOX_OFFSET[1];


func _on_attack_area_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "player":
		player_in_range = true


func _on_attack_area_hitbox_body_exited(body: Node2D) -> void:
	if body.name == "player":
		player_in_range = false


func _on_zombie_sword_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "player":
		global.damage_player(ZOMBIE_DAMAGE)
		player_vulnerable = true

func _on_zombie_sword_hitbox_body_exited(body: Node2D) -> void:
	if body.name == "player":
		player_vulnerable = false
