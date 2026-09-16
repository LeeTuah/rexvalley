extends Node2D

const SCR_WIDTH = 1600;
const SCR_HEIGHT = 900;

var ground_floor_scene = preload("res://scenes/floor/ground_floor.tscn");
const GROUND_Y = 856.0;

var leftmost_tile_x = 0.0;
var rightmost_tile_x = 0.0;

const GROUND_TILE_LENGTH = 194.0;

func make_new_tile(x: float, y: float) -> void:
	var ground_floor_instance = ground_floor_scene.instantiate();
	ground_floor_instance.position = Vector2(x, y);
	get_tree().current_scene.get_node("terrain").add_child(ground_floor_instance);

func generate_initial_terrain() -> void:
	const TILE_HALFLENGTH = GROUND_TILE_LENGTH / 2.0;
	var starting_x = -TILE_HALFLENGTH;

	leftmost_tile_x = starting_x;

	while (starting_x < SCR_WIDTH + GROUND_TILE_LENGTH):
		make_new_tile(starting_x, GROUND_Y);
		starting_x += GROUND_TILE_LENGTH;

	rightmost_tile_x = starting_x;
	rightmost_tile_x -= GROUND_TILE_LENGTH;

func generate_new_terrain():
	var player_x = global.player_position.x;

	if (abs(player_x - leftmost_tile_x) < 1000.0):
		leftmost_tile_x -= GROUND_TILE_LENGTH;
		make_new_tile(leftmost_tile_x, GROUND_Y);

	if (abs(player_x - rightmost_tile_x) < 1000.0):
		rightmost_tile_x += GROUND_TILE_LENGTH;
		make_new_tile(rightmost_tile_x, GROUND_Y);

func _ready() -> void:
	generate_initial_terrain();

func _process(_delta: float) -> void:
	generate_new_terrain();
