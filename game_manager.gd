extends Node2D

const SCR_WIDTH = 1600;
const SCR_HEIGHT = 900;

var ground_floor_scene = preload("res://scenes/floor/ground_floor.tscn");
var dirt_floor_scene = preload("res://scenes/floor/dirt_floor.tscn");

const GROUND_Y = 856.0;

var leftmost_tile_x = 0.0;
var rightmost_tile_x = 0.0;

const GROUND_TILE_LENGTH = 32.0 * 3.0;

# generates a new tile at coordinates (x, y)
func make_new_tile(x: float, y: float) -> void:
	# glass block created
	var ground_floor_instance = ground_floor_scene.instantiate();
	ground_floor_instance.position = Vector2(x, y);
	get_tree().current_scene.get_node("terrain").add_child(ground_floor_instance);

	# dirt block created
	var dirt_floor_instance = dirt_floor_scene.instantiate();
	dirt_floor_instance.position = Vector2(x, y + GROUND_TILE_LENGTH);
	get_tree().current_scene.get_node("terrain").add_child(dirt_floor_instance);


# generates initial terrain for the player to stand on when the game starts
func generate_initial_terrain() -> void:
	const TILE_HALFLENGTH = GROUND_TILE_LENGTH / 2.0;
	var starting_x = -TILE_HALFLENGTH;

	leftmost_tile_x = starting_x;

	# goes from left to right and places tiles at GROUND_Y
	while (starting_x < SCR_WIDTH + GROUND_TILE_LENGTH):
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

func _ready() -> void:
	generate_initial_terrain();

func _process(_delta: float) -> void:
	generate_new_terrain();
