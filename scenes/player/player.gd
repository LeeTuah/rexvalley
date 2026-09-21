extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D;
@onready var animation_player = $AnimationPlayer;

var fireball_scene = preload("res://scenes/Magic/fire_ball.tscn");

const SPEED = 300.0
const ACCN = 2.5
const JUMP_VELOCITY = -400.0
const CAMERA_DEFAULT_POS = -200.0

var idle_time = 0.0;
var IDLE_TIMES = {
	"sword_slash1": 0.4, 
	"sword_slash2": 0.4, 
	"sword_slash3": 0.4, 
	"thrust": 		0.5,
	"fireball_1":	0.9 / 2.0,
	"fireball_2":	0.9 / 2.0,
	"shield": 		1.67
};
var MAGIC_ANIMATIONS = ["fireball_1","fireball_2","shield"];

var can_run = true;
var sprint_timer = 0.0;
const SPRINT_COOLDOWN = 3.0

const STAMINA_DECREASE_RATE = 4;
const STAMINA_INCREASE_RATE = 4.6;
const MANA_INCREASE_RATE = 2.3;

var current_combo_counter = 0;
const MAX_COMBO = 3;
var queue_next_combo = false;

var last_speed = SPEED;
var sprint_key_released = false;

var can_input = true;
var direction :float = 1
var thrust_direction = 1;

func disable_all_hitboxes():
	$sword_hitbox/sword_slash1_hitbox.set_deferred("disabled", true);
	$sword_hitbox/sword_slash2_hitbox.set_deferred("disabled", true);
	$sword_hitbox/sword_slash3_hitbox.set_deferred("disabled", true);
	$sword_hitbox/sword_thrust_hitbox.set_deferred("disabled", true);

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta;

	#player jumping physics
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and global.current_stamina >= STAMINA_DECREASE_RATE * 1.5:
		velocity.y = JUMP_VELOCITY;
		global.current_stamina -= STAMINA_DECREASE_RATE * 1.5;
	
	# player direction calculation
	direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		global.player_direction = direction;
	if (direction != 0): thrust_direction = direction;

	# thrust physics calc
	if (animated_sprite.animation == "thrust" and animated_sprite.is_playing()):
		velocity.x = thrust_direction * SPEED * 130 * delta;
		move_and_slide();
	
	var speed = last_speed;

	# sprinting logic calc (acceleration)
	if (Input.is_action_pressed("ui_sprint") and can_run):
		speed = move_toward(speed, SPEED * ACCN, SPEED / 15.0);
		last_speed = speed;
		sprint_key_released = false;

	# retardation calc
	if (Input.is_action_just_released(("ui_sprint")) or not can_run):
		sprint_key_released = true;

	if (sprint_key_released):
		speed = move_toward(speed, SPEED, SPEED / 15.0);
		last_speed = speed;

	# walking direction
	if direction:
		velocity.x = direction * speed;
	else:
		velocity.x = move_toward(velocity.x, 0, speed);

	move_and_slide();

func _ready() -> void:
	global.player_position = position;
	
var fireball_instance;
var magic_done = false;
func _process(delta: float):
	if (Input.is_action_just_pressed("ui_thrust")):
		magic_done = false;
	
	global.current_mana += MANA_INCREASE_RATE * delta;
	
	# flipping animated sprite
	if velocity.x != 0:
		$AnimatedSprite2D.flip_h = velocity.x < 0;
		$sword_hitbox.scale.x = -1 if velocity.x < 0 else 1;

	# sprint cooldown
	if not can_run:
		sprint_timer += delta;
		if sprint_timer >= SPRINT_COOLDOWN:
			can_run = true;
	
	if can_input:
		# slash attack
		if (Input.is_action_just_pressed("ui_attack")):
			animated_sprite.play("sword_slash1");
			current_combo_counter = 1;

			can_input = false;
			idle_time = 0.0;
			$sword_hitbox/sword_slash1_hitbox.set_deferred("disabled", false);

		# magic attacks
		elif (Input.is_action_pressed("magic_initiate")):
			
			# fireball
			if (Input.is_action_just_pressed("magic_fireball") and (global.current_mana > 20)):
				animated_sprite.play("fireball_1");
				can_input = false;
				
				idle_time = 0.0;
				global.current_mana -= 14;
				magic_done = true;
			
			# magic shield
			elif (Input.is_action_just_pressed("magic_shield") and (global.current_mana > 20)):
				animated_sprite.play("shield");
				can_input = false;
				
				idle_time = 0.0;
				global.current_mana -= 15;
				magic_done = true;
		
		# thrust attack
		elif (Input.is_action_just_released("ui_thrust") and global.current_stamina >= 30 and not magic_done):
			animated_sprite.play(("thrust"));
			can_input = false;

			idle_time = 0.0;
			global.current_stamina -= 30;
			$sword_hitbox/sword_thrust_hitbox.set_deferred("disabled", false);
		
		# jump attack
		elif (Input.is_action_just_pressed("ui_accept")):
			pass # jump animation

		elif ((Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")) and is_on_floor()):
			# sprinting
			if ((Input.is_action_pressed("ui_sprint")) and (global.current_stamina > 0) and (can_run)):
				animated_sprite.play("run");
				global.current_stamina -= STAMINA_DECREASE_RATE * delta;

				if global.current_stamina == 0:
					can_run = false;
					sprint_timer = 0.0;
			
			# walking stamina calculation
			else:
				animated_sprite.play("walk");
				if can_run:
					global.current_stamina += STAMINA_INCREASE_RATE * delta;
		
		# idle stamina calculation
		elif is_on_floor():
			animated_sprite.play("idle");
			global.current_stamina += STAMINA_INCREASE_RATE * delta;
			
		
	
	else:
		idle_time += delta;
		
		var anim = animated_sprite.animation;
		if idle_time >= IDLE_TIMES[anim]: # checking counter wait time from dictionary above
			idle_time = 0.0; 

			if (anim == "fireball_1"):
				# creates a new fireball
				fireball_instance = fireball_scene.instantiate();
				fireball_instance.position = position;

				# plays the second animation part 
				get_parent().get_node("Fireball").add_child(fireball_instance);
				animated_sprite.play("fireball_2");
			
			# queues next colbo
			elif (((anim == "sword_slash1" or anim == "sword_slash2") and queue_next_combo)):
				queue_next_combo = false;
				current_combo_counter += 1;
				animated_sprite.play("sword_slash" + str(current_combo_counter));

				if (current_combo_counter == 2):
					$sword_hitbox/sword_slash2_hitbox.set_deferred("disabled", false)
					$sword_hitbox/sword_slash1_hitbox.set_deferred("disabled", true);

				elif (current_combo_counter == 3):
					$sword_hitbox/sword_slash2_hitbox.set_deferred("disabled", true);
					$sword_hitbox/sword_slash3_hitbox.set_deferred("disabled", false);
				
			else:
				can_input = true;
				current_combo_counter = 0;
				queue_next_combo = false;
				
				disable_all_hitboxes();
				
		# logic checks whether the animation is sword_slash1 or sword_slash2
		# and attack key pressed before the timer exceeds the cooldown
		# and the combo counter is lesser than max value
		elif ((anim == "sword_slash1" or anim == "sword_slash2") and
			Input.is_action_just_pressed("ui_attack") and current_combo_counter < MAX_COMBO
		):
			queue_next_combo = true;
		
	
	# camera look down functionality only for debugging right now
	if (Input.is_action_just_pressed("ui_look_down")):
		if ($Camera2D.position.y == CAMERA_DEFAULT_POS):
			animation_player.play("camera_moving_down");

		else:
			animation_player.play("camera_moving_up");

	global.player_position = position;
