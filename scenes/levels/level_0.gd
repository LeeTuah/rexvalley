extends Node2D

var ground_floor_scene = preload("res://scenes/floor/ground_floor.tscn");
var dirt_floor_scene = preload("res://scenes/floor/dirt_floor.tscn");

const FADE_IN_DURATION = 0.3;
const FADE_OUT_DURATION = 0.6;

const GROUND_Y = 856.0;

var leftmost_tile_x = 0.0;
var rightmost_tile_x = 0.0;

const GROUND_TILE_LENGTH = 32.0 * 3.0;

# generates a new tile at coordinates (x, y)
func make_new_tile(x: float, y: float) -> void:
	# glass block created
	var ground_floor_instance = ground_floor_scene.instantiate();
	ground_floor_instance.position = Vector2(x, y);
	get_tree().current_scene.get_node("level" + str(global.current_level) + "/terrain").add_child(ground_floor_instance);

	# dirt block created
	var dirt_floor_instance = dirt_floor_scene.instantiate();
	dirt_floor_instance.position = Vector2(x, y + GROUND_TILE_LENGTH);
	get_tree().current_scene.get_node("level" + str(global.current_level) + "/terrain").add_child(dirt_floor_instance);


# generates initial terrain for the player to stand on when the game starts
func generate_initial_terrain() -> void:
	const TILE_HALFLENGTH = GROUND_TILE_LENGTH / 2.0;
	var starting_x = -TILE_HALFLENGTH;

	leftmost_tile_x = starting_x;

	# goes from left to right and places tiles at GROUND_Y
	while (starting_x < global.SCR_WIDTH + GROUND_TILE_LENGTH):
		make_new_tile(starting_x, GROUND_Y);
		starting_x += GROUND_TILE_LENGTH;

	rightmost_tile_x = starting_x;
	rightmost_tile_x -= GROUND_TILE_LENGTH;

# generates new blocks at the ends of terrain if the player is too close to the edge
func generate_new_terrain():
	var player_x = global.player_position.x;

	# generates left side terrain
	if (abs(player_x - leftmost_tile_x) < 1000.0):
		leftmost_tile_x -= GROUND_TILE_LENGTH;
		make_new_tile(leftmost_tile_x, GROUND_Y);

	# generates right side terrain
	if (abs(player_x - rightmost_tile_x) < 1000.0):
		rightmost_tile_x += GROUND_TILE_LENGTH;
		make_new_tile(rightmost_tile_x, GROUND_Y);

func fade_in(label):
	var tween = get_tree().create_tween()
	tween.tween_property(label, "modulate:a", 1, FADE_IN_DURATION)

	tween.play()
	await tween.finished
	tween.kill()

func fade_out(label):
	var tween = get_tree().create_tween()
	tween.tween_property(label, "modulate:a", 0, FADE_OUT_DURATION)
	
	tween.play()
	await tween.finished
	tween.kill()

func fade_out_all_labels():
	# fade_out($labels/welcome)
	fade_out($labels/sprint)
	fade_out($labels/jump)
	fade_out($labels/slash_atk)
	fade_out($labels/combo_atk)

func _ready() -> void:
	# generate_initial_terrain();
	fade_out_all_labels();
	$labels/welcome.text = "welcome %s!\nuse A and D to move" % global.player_name
	pass

func _process(_delta: float) -> void:
	# generate_new_terrain();
	pass

# signals for area entered and exited below
func _on_welcome_area_body_entered(body: Node2D) -> void:
	if (body.name == "player"): fade_in($labels/welcome)

func _on_welcome_area_body_exited(body: Node2D) -> void:
	if (body.name == "player"): fade_out($labels/welcome)


func _on_sprint_area_body_entered(body: Node2D) -> void:
	if (body.name == "player"): fade_in($labels/sprint)

func _on_sprint_area_body_exited(body: Node2D) -> void:
	if (body.name == "player"): fade_out($labels/sprint)


func _on_jump_body_entered(body: Node2D) -> void:
	if (body.name == "player"): fade_in($labels/jump)

func _on_jump_body_exited(body: Node2D) -> void:
	if (body.name == "player"): fade_out($labels/jump)


func _on_slash_atk_area_body_entered(body: Node2D) -> void:
	if (body.name == "player"): fade_in($labels/slash_atk)

func _on_slash_atk_area_body_exited(body: Node2D) -> void:
	if (body.name == "player"): fade_out($labels/slash_atk)


func _on_combo_atk_area_body_entered(body: Node2D) -> void:
	if (body.name == "player"): fade_in($labels/combo_atk)

func _on_combo_atk_area_body_exited(body: Node2D) -> void:
	if (body.name == "player"): fade_out($labels/combo_atk)
