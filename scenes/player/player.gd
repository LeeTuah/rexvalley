extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D;

const SPEED = 300.0
const ACCN = 2.5
const JUMP_VELOCITY = -400.0
const CAMERA_DEFAULT_POS = -200.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("ui_left", "ui_right")

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

func _process(_delta: float):
	if velocity.x == 0:
		$AnimatedSprite2D.flip_h = $AnimatedSprite2D.flip_h;
	
	else:
		$AnimatedSprite2D.flip_h = velocity.x < 0;

	if (Input.is_action_just_pressed("ui_accept")):
		pass # jump animation

	elif ((Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")) and is_on_floor()):
		if (Input.is_action_pressed("ui_sprint")):
			animated_sprite.play("run");
		
		else:
			animated_sprite.play("walk");

	else:
		animated_sprite.play("idle");

	if (Input.is_action_just_pressed("ui_look_down")):
		if ($Camera2D.position.y == CAMERA_DEFAULT_POS):
			$AnimationPlayer.play("camera_moving_down");

		else:
			$AnimationPlayer.play("camera_moving_up");

	global.player_position = position;
