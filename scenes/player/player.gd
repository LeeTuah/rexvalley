extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D;

const SPEED = 300.0
const ACCN = 2.5
const JUMP_VELOCITY = -400.0
const CAMERA_DEFAULT_POS = -200.0

var idle_time = 0.0
var cooldown = 0.26

#arektu kom hole bhalo heo bojhai jache na tahole

var can_input:bool = true


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and can_input:
		velocity.y = JUMP_VELOCITY

	
	var direction := Input.get_axis("ui_left", "ui_right")

	if not can_input:
		direction = 0

	var speed = SPEED;
	if (Input.is_action_pressed("ui_sprint")):
		speed *= ACCN;

	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()

func _ready() -> void:
	global.player_position = position;
	var timer = Timer.new()
	add_child(timer)

	

func _process(delta: float):
	if velocity.x == 0:
		$AnimatedSprite2D.flip_h = $AnimatedSprite2D.flip_h;
	
	else:
		$AnimatedSprite2D.flip_h = velocity.x < 0;

	if can_input:
		if (Input.is_action_just_pressed("ui_attack")):
			animated_sprite.play("sword_slash1")
			can_input = false
			idle_time = 0.0

		elif (Input.is_action_just_pressed("ui_accept")):
			pass # jump animation

		elif ((Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")) and is_on_floor()):
			if (Input.is_action_pressed("ui_sprint")):
				animated_sprite.play("run");
			
			else:
				animated_sprite.play("walk");

		
	if idle_time >= cooldown:
		animated_sprite.play("idle");
		can_input = true
		
	idle_time += delta

	if (Input.is_action_just_pressed("ui_look_down")):
		if ($Camera2D.position.y == CAMERA_DEFAULT_POS):
			$AnimationPlayer.play("camera_moving_down");

		else:
			$AnimationPlayer.play("camera_moving_up");

	

	global.player_position = position;
