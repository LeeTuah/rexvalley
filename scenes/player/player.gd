extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D;

var fireball_scene = preload("res://scenes/Magic/fire_ball.tscn");

const SPEED = 300.0
const ACCN = 2.5
const JUMP_VELOCITY = -400.0
const CAMERA_DEFAULT_POS = -200.0

var idle_time = 0.0;
var thrust_idle_time = 0.0;
var magic_fireball_idle_time = 0.0;
const ATTACK_COOLDOWN = 0.4;
const THRUST_COOLDOWN = 0.5;
const MAGIC_FIREBALL_COOLDOWN = 0.45;

var can_run = true
var sprint_timer = 0.0;
const SPRINT_COOLDOWN = 3.0

const STAMINA_DECREASE_RATE = 2;
const STAMINA_INCREASE_RATE = 2.3;

var current_combo_counter = 0;
const MAX_COMBO = 3;
var queue_next_combo = false;

var last_speed = SPEED;
var sprint_key_released = false;

#arektu kom hole bhalo heo bojhai jache na tahole

var can_input = true
var direction :float= 1
var thrust_direction = 1;

var cannot_input_animation = ["sword_slash_1","sword_slash_2","sword_slash_3","thrust"];

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and global.current_stamina >= STAMINA_DECREASE_RATE * 1.5:
		velocity.y = JUMP_VELOCITY
		global.current_stamina -= STAMINA_DECREASE_RATE * 1.5
	
	direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		global.player_direction = direction;
	if (direction != 0): thrust_direction = direction;
	if (animated_sprite.animation == "thrust" and animated_sprite.is_playing()):
		velocity.x = thrust_direction * SPEED * 130 * delta;
		move_and_slide();
	#if not can_input:
		#direction = 0
	var speed = last_speed;

	if (Input.is_action_pressed("ui_sprint") and can_run):
		speed = move_toward(speed, SPEED * ACCN, SPEED / 15.0);
		last_speed = speed;
		sprint_key_released = false;

	if (Input.is_action_just_released(("ui_sprint")) or not can_run):
		sprint_key_released = true;

	if (sprint_key_released):
		speed = move_toward(speed, SPEED, SPEED / 15.0);
		last_speed = speed;

	if direction:
		velocity.x = direction * speed;
	else:
		velocity.x = move_toward(velocity.x, 0, speed);

	move_and_slide();

func _ready() -> void:
	global.player_position = position;
	#animated_sprite.connect("sprite_frames_changed",_on_animated_sprite_2d_sprite_frames_changed);
	
var fireball_instance;
#var combo_executed = false;

func _process(delta: float):
	if velocity.x != 0:
		$AnimatedSprite2D.flip_h = velocity.x < 0;

	if not can_run:
		sprint_timer += delta
		if sprint_timer >= SPRINT_COOLDOWN:
			can_run = true
	print(can_input);
	if can_input:
		
		#if (Input.is_action_just_pressed("ui_thrust")):
			#combo_executed = false;
			
		if (Input.is_action_just_pressed("ui_attack")):
			animated_sprite.play("sword_slash1");
			current_combo_counter = 1;
			can_input = false;
			idle_time = 0.0;
		elif (Input.is_action_pressed("magic_initiate") and Input.is_action_just_pressed("magic_fireball") and (global.current_stamina > 10)):
			animated_sprite.play("fireball_1");
			can_input = false;
			print("can input false from inside fireball")
			magic_fireball_idle_time = 0.0;
			global.current_stamina -= 7;
			
			#combo_executed = true;
			
		elif (Input.is_action_just_released("ui_thrust") and global.current_stamina >= 20):
			animated_sprite.play(("thrust"));
			can_input = false;
			thrust_idle_time = 0.0;
			global.current_stamina -= 20;
		elif (Input.is_action_just_pressed("ui_accept")):
			pass # jump animation

		elif ((Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")) and is_on_floor()):
			if ((Input.is_action_pressed("ui_sprint")) and (global.current_stamina > 0) and (can_run)):
				animated_sprite.play("run")
				global.current_stamina -= STAMINA_DECREASE_RATE * delta

				if global.current_stamina == 0:
					can_run = false
					sprint_timer = 0.0
			
			else:
				animated_sprite.play("walk");
				if can_run:
					global.current_stamina += STAMINA_INCREASE_RATE * delta
		
		elif is_on_floor():
			animated_sprite.play("idle");
			global.current_stamina += STAMINA_INCREASE_RATE * delta
	
	else:
		
		match animated_sprite.animation:
			"fireball_1":
				magic_fireball_idle_time += delta;
				if magic_fireball_idle_time >= MAGIC_FIREBALL_COOLDOWN:
					can_input = true;
					magic_fireball_idle_time = 0.0;
					#print("can input true")
					fireball_instance = fireball_scene.instantiate();
					fireball_instance.position.x = position.x;
					fireball_instance.position.y = position.y;
					get_parent().get_node("Fireball").add_child(fireball_instance);
					animated_sprite.play("fireball_2");
					
			"thrust":
				thrust_idle_time += delta
				if thrust_idle_time >= THRUST_COOLDOWN:
					can_input = true;
					thrust_idle_time = 0.0;
				
			"sword_slash1","sword_slash2","sword_slash3":
				idle_time += delta
				
				if idle_time >= ATTACK_COOLDOWN:
					can_input = true;
					idle_time = 0.0; 
					
				elif (Input.is_action_just_pressed("ui_attack") and current_combo_counter < MAX_COMBO):
					queue_next_combo = true;
					
				if (queue_next_combo):
					queue_next_combo = false;
					can_input = false;
					idle_time = 0.0;

					current_combo_counter += 1;
					animated_sprite.play("sword_slash" + str(current_combo_counter));
				
		
	
	if (Input.is_action_just_pressed("ui_look_down")):
		if ($Camera2D.position.y == CAMERA_DEFAULT_POS):
			$AnimationPlayer.play("camera_moving_down");

		else:
			$AnimationPlayer.play("camera_moving_up");

	global.player_position = position;
