package game;

import game.data.Direction;
import game.CustomMap.EnemyCustomEntity;
import game.CustomMap.SignCustomEntity;
import godot.*;

enum NPCType {
	Sign(text: String);
	TestNPC;
	Enemy(enemy_type: EnemyType);
}

enum EnemyType {
	TestFish;
	Crab;
	CrabShooter(direction: Null<Direction>);
	Fish1;
	Fish2;
	FlatFish;
	StarFish;
	SwordFish;
	AlwaysFastTutorialFish;
}

@:tool
class NPCData extends Resource {
	@:export public var kind: NPCType;
	@:export public var position: Vector3i;

	public static function create_npc_data(kind: NPCType, position: Vector3i) {
		final npc = new NPCData();
		npc.kind = kind;
		npc.position = position;
		return npc;
	}
}

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
	@:export public var npcs(default, null): Array<NPCData>;
	@:export public var stairs_position(default, null): Vector2i;

	@:export public var desired_enemy_count: Vector2i; // x = min, y = max

	@:export public var custom_map: CustomMap;

	public function randomize_noise() {
		if(world_generation_noise != null) {
			world_generation_noise.seed = Godot.randi_range(0, 9999999);
		}
	}

	public function randomize_size(min_size: Int, max_size: Int) {
		width = Godot.randi_range(min_size, max_size);
		height = Godot.randi_range(min_size, max_size);
	}

	function generate_custom_world() {
		final image = custom_map.custom_map.get_image();
		if(image.is_compressed()) {
			image.decompress();
		}

		width = image.get_width();
		height = image.get_height();

		stairs_position = new Vector2i(-1, 0);
		player_start_position = new Vector2i(Math.floor(width / 2), Math.floor(height / 2));

		npcs = [];

		for(y in 0...height) {
			for(x in 0...width) {
				final c = image.get_pixel(x, y);
				tiles.push(switch(Math.round(c.r * 10) + Math.round(c.g * 100) + Math.round(c.b * 1000)) {
					case 1110: 1;
					case 10: { // #f00
						player_start_position = new Vector2i(x, y);
						1;
					}
					case 1000: { // #00f
						stairs_position = new Vector2i(x, y);
						1;
					}
					case 0: 0;
					case value: {
						if(custom_map.custom_entities.has(value)) {
							final object = custom_map.custom_entities.get(value);

							final sign = cast(object, SignCustomEntity);
							if(sign != null) {
								npcs.push(NPCData.create_npc_data(Sign(sign.sign_text), new Vector3i(x, y, 0)));
							}

							final enemy = cast(object, EnemyCustomEntity);
							if(enemy != null) {
								npcs.push(NPCData.create_npc_data(Enemy(enemy.enemy), new Vector3i(x, y, 0)));
							}
						}

						1;
					}
				});
			}
		}
	}

	function generate_random_world() {
		// Use noise to make general level...
		final LEVEL_EDGES_BUFFER = 10;
		for(y in 0...height) {
			for(x in 0...width) {
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
		find_clusters();

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
		npcs = [];
		if(possible_enemy_positions.contains(stairs_position)) {
			possible_enemy_positions.remove(stairs_position);
		}
		final enemy_count = Godot.randi_range(desired_enemy_count.x, desired_enemy_count.y);
		if(possible_enemy_positions.length <= enemy_count) {
			npcs = possible_enemy_positions.map(ep -> NPCData.create_npc_data(Enemy(EnemyMaker.random_enemy_type()), new Vector3i(ep.x, ep.y, 0)));
		} else {
			for(i in 0...enemy_count) {
				final p = possible_enemy_positions[Godot.randi_range(0, possible_enemy_positions.length - 1)];
				possible_enemy_positions.remove(p);
				npcs.push(NPCData.create_npc_data(Enemy(EnemyMaker.random_enemy_type()), new Vector3i(p.x, p.y, 0)));
			}

			// Add some star fish to heal with...
			final star_fish_count = 8;
			for(i in 0...star_fish_count) {
				if(possible_enemy_positions.length == 0) {
					break;
				}
				final p = possible_enemy_positions[Godot.randi_range(0, possible_enemy_positions.length - 1)];
				possible_enemy_positions.remove(p);
				npcs.push(NPCData.create_npc_data(Enemy(StarFish), new Vector3i(p.x, p.y, 0)));
			}
		}
	}

	public function build_world() {
		tiles = [];
		tile_type_count = new Dictionary();

		if(custom_map != null) {
			generate_custom_world();
		} else {
			generate_random_world();
		}

		// Empty tile type count cache
		tile_type_count = new Dictionary();
	}

	public function get_tile(x: Int, y: Int): Int {
		if(x < 0 || x >= width || y < 0 || y >= height) return -1;
		final index = (y * width) + x;
		return tiles[index];
	}

	public function has_tile(x: Int, y: Int) {
		if(x < 0 || x >= width || y < 0 || y >= height) return false;
		final index = (y * width) + x;
		return tiles[index] == 1;
	}

	function has_tile_v2i(pos: Vector2i) {
		return has_tile(pos.x, pos.y);
	}

	function find_clusters() {
		var new_index = 2;
		for(x in 0...width) {
			for(y in 0...height) {
				final index = (y * width) + x;

				if(tiles[index] == 1) {
					final up = get_tile(x, y - 1);
					final down = get_tile(x, y + 1);
					final left = get_tile(x - 1, y);
					final right = get_tile(x + 1, y);

					final options = [];
					if(up > 2) options.push(up);
					if(down > 2 && down != up) options.push(down);
					if(left > 2 && left != up && left != down) options.push(left);
					if(right > 2 && right != up && right != down && right != left) options.push(right);

					final result = if(options.length == 1) {
						options[0];
					} else if(options.length == 0) {
						final result = new_index;
						if(!tile_type_count.has(result)) { tile_type_count.set(result, 0); }
						new_index += 1;
						result;
					} else {
						var min = options[0];
						for(i in 1...options.length) {
							if(options[i] < min) {
								min = options[i];
							}
						}

						for(option in options) {
							if(option != min) {
								convert_tiles(option, min);
							}
						}

						min;
					}

					tiles[index] = result;
					tile_type_count.set(result, tile_type_count.get(result) + 1);
				}
			}
		}
	}

	function convert_tiles(from: Int, to: Int) {
		for(i in 0...tiles.length) {
			if(tiles[i] == from) {
				tiles[i] = to;
			}
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