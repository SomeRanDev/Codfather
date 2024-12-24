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

	public function build_world() {
		tiles = [];
		tile_type_count = new Dictionary();

		// Use noise to make general level...
		final LEVEL_EDGES_BUFFER = 10;
		for(x in 0...width) {
			for(y in 0...height) {
				final level_edges_buffer_f: Float = LEVEL_EDGES_BUFFER;
				final force_wall_amount = if(x < LEVEL_EDGES_BUFFER) {
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

		test_npcs = [];
		for(x in 0...width) {
			for(y in 0...height) {
				if(player_start_position == new Vector2i(x, y)) {
					continue;
				}
				if(has_tile(x, y)) {
					if(Godot.randi_range(0, 80) == 1) {
						test_npcs.push(new Vector2i(x, y));
					}
				}
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
		for(x in 0...width) {
			for(y in 0...height) {
				if(
					has_tile(x, y) && has_tile(x - 1, y) && has_tile(x + 1, y) && 
					has_tile(x, y - 1) && has_tile(x, y + 1) &&
					has_tile(x - 1, y - 1) && has_tile(x - 1, y + 1) &&
					has_tile(x + 1, y - 1) && has_tile(x + 1, y + 1)
				) {
					player_start_position = new Vector2i(x, y);
					return;
				}
			}
		}
	}
}