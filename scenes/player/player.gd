extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D;

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _ready() -> void:
	animated_sprite.play("idle");

func _process(_delta: float):
	if velocity.x == 0:
		$AnimatedSprite2D.flip_h = $AnimatedSprite2D.flip_h;
	
	else:
		$AnimatedSprite2D.flip_h = velocity.x < 0;

	if (Input.is_action_just_pressed("ui_accept")):
		pass # jump animation

	elif ((Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right")) and is_on_floor()):
		pass # walk animation

	else:
		pass # idle animation

	global.player_position = position;
