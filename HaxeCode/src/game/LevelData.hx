package game;

import godot.*;

@:tool
class LevelData extends Node {
	@:exportToolButton("Build World", "ColorRect")
	var build_world_action = untyped __gdscript__("build_world");

	@:export public var width(default, null): Int = 20;
	@:export public var height(default, null): Int = 20;
	@:export public var tile_size(default, null): Float = 1.0;

	@:export var world_generation_noise: FastNoiseLite = null;

	@:export public var tiles(default, null): Array<Int> = [];
	var tile_type_count: Dictionary = new Dictionary();

	@:export public var player_start_position(default, null): Vector2i;
	@:export public var test_npcs(default, null): Array<Vector2i>;
	@:export public var stairs_position(default, null): Vector2i;

	@:export public var desired_enemy_count: Vector2i; // x = min, y = max

	public function randomize_noise() {
		if(world_generation_noise != null) {
			world_generation_noise.seed = Godot.randi_range(0, 9999999);
		}
	}

	public function build_world() {
		tiles = [];
		tile_type_count = new Dictionary();

		// Use noise to make general level...
		final LEVEL_EDGES_BUFFER = 10;
		for(x in 0...width) {
			for(y in 0...height) {
				final level_edges_buffer_f: Float = LEVEL_EDGES_BUFFER;
				final force_wall_amount = if(x == 0 || x == width - 1 || y == 0 || y == height - 1) {
					1;
				} else if(x < LEVEL_EDGES_BUFFER) {
					1.0 - (x / level_edges_buffer_f);
				} else if(x > width - LEVEL_EDGES_BUFFER) {
					(x - (width - LEVEL_EDGES_BUFFER)) / level_edges_buffer_f;
				} else if(y < LEVEL_EDGES_BUFFER) {
					1.0 - (y / level_edges_buffer_f);
				} else if(y > height - LEVEL_EDGES_BUFFER) {
					(y - (height - LEVEL_EDGES_BUFFER)) / level_edges_buffer_f;
				} else {
					0.0;
				}

				final tile_id = world_generation_noise.get_noise_2d(x, y) > (0.1 - (force_wall_amount * 1.1)) ? 0 : 1;
				tiles.push(tile_id);
			}
		}

		// Find "clusters"
		var new_index = 2;
		for(x in 0...width) {
			for(y in 0...height) {
				if(recusive_set_area_id(x, y, new_index)) {
					new_index += 1;
				}
			}
		}

		// Find the biggest cluster
		var max_key = -1;
		tile_type_count.keys().forSized(_.size(), {
			final key = _;
			if(max_key == -1) {
				max_key = key;
			} else {
				if(tile_type_count.get(key) > tile_type_count.get(max_key)) {
					max_key = key;
				}
			}
		});

		// Set all the tiles in the biggest cluster to "1", otherwise "0"
		for(index in 0...tiles.length) {
			tiles[index] = if(tiles[index] != max_key) {
				0;
			} else {
				1;
			}
		}

		find_player_start();

		final possible_stair_positions = [];
		final possible_enemy_positions = [];

		final distance_from_player_squared = 4*4;

		for(x in 0...width) {
			for(y in 0...height) {
				if(player_start_position == new Vector2i(x, y)) {
					continue;
				}
				if(has_tile(x, y)) {
					// Do not let anything be too close to the player....
					final player_offset_x = player_start_position.x - x;
					final player_offset_y = player_start_position.y - y;
					if((player_offset_x*player_offset_x) + (player_offset_y*player_offset_y) < distance_from_player_squared) {
						continue;
					}

					if(
						has_tile(x, y - 1) && has_tile(x, y - 2) && has_tile(x, y + 1) &&
						has_tile(x + 1, y) && has_tile(x - 1, y) && // ensure visible
						world_generation_noise.get_noise_2d(x, y) < -0.1
					) {
						possible_stair_positions.push(new Vector2i(x, y));
					} else {
						possible_enemy_positions.push(new Vector2i(x, y));
					}
				}
			}
		}

		// Make stairs position
		stairs_position = new Vector2i(0, 0);
		if(possible_stair_positions.length == 0) possible_stair_positions.push(new Vector2i(Math.floor(width / 2), Math.floor(height / 2)));
		stairs_position = possible_stair_positions[Godot.randi_range(0, possible_stair_positions.length - 1)];

		// Make enemy positions 
		test_npcs = [];
		if(possible_enemy_positions.contains(stairs_position)) {
			possible_enemy_positions.remove(stairs_position);
		}
		final enemy_count = Godot.randi_range(desired_enemy_count.x, desired_enemy_count.y);
		if(possible_enemy_positions.length <= enemy_count) {
			test_npcs = possible_enemy_positions;
		} else {
			for(i in 0...enemy_count) {
				final p = possible_enemy_positions[Godot.randi_range(0, possible_enemy_positions.length - 1)];
				possible_enemy_positions.remove(p);
				test_npcs.push(p);
			}
		}

		// Empty tile type count cache
		tile_type_count = new Dictionary();
	}

	public function has_tile(x: Int, y: Int) {
		if(x < 0 || x >= width || y < 0 || y >= height) return false;
		final index = (y * width) + x;
		return tiles[index] == 1;
	}

	function has_tile_v2i(pos: Vector2i) {
		return has_tile(pos.x, pos.y);
	}

	function recusive_set_area_id(x: Int, y: Int, id: Int): Bool {
		if(x < 0 || x >= width || y < 0 || y >= height) return false;
		final index = (y * width) + x;
		if(tiles[index] == 1) {
			tiles[index] = id;
			if(!tile_type_count.has(id)) {
				tile_type_count.set(id, 0);
			}
			tile_type_count.set(id, tile_type_count.get(id) + 1);
			recusive_set_area_id(x + 1, y, id);
			recusive_set_area_id(x - 1, y, id);
			recusive_set_area_id(x, y + 1, id);
			recusive_set_area_id(x, y - 1, id);
			return true;
		} else {
			return false;
		}
	}

	function find_player_start() {
		final player_start_candidates = [];
		for(x in 0...width) {
			for(y in 0...height) {
				if(
					has_tile(x, y) && has_tile(x - 1, y) && has_tile(x + 1, y) && 
					has_tile(x, y - 1) && has_tile(x, y + 1) &&
					has_tile(x - 1, y - 1) && has_tile(x - 1, y + 1) &&
					has_tile(x + 1, y - 1) && has_tile(x + 1, y + 1)
				) {
					player_start_candidates.push(new Vector2i(x, y));
				}
			}
		}

		// Super unlikely this will run, but put here for safety.
		if(player_start_candidates.length == 0) {
			for(x in 0...width) {
				for(y in 0...height) {
					if(has_tile(x, y)) {
						player_start_position = new Vector2i(x, y);
						return;
					}
				}
			}
		}

		if(player_start_candidates.length == 0) {
			player_start_position = new Vector2i(0, 0);
			return;
		}

		player_start_position = player_start_candidates[Godot.randi_range(0, player_start_candidates.length - 1)];
	}
}