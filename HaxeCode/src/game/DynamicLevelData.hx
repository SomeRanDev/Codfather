package game;

import game.data.Direction;

import godot.*;

using gdscript.ArrayEx;

class DynamicLevelData extends Node {
	@:export var level_data: LevelData;
	@:export var turn_manager: TurnManager;

	var entity_array: Array<Int>;
	var hovered_entity_array: Array<Int>;
	var player_position: Vector3i;

	public function static_data(): LevelData {
		return level_data;
	}

	public function manual_ready() {
		final size = level_data.width * level_data.height;

		entity_array = [];
		entity_array.resize(size);
		entity_array.fill(0);

		hovered_entity_array = [];
		hovered_entity_array.resize(size);
		hovered_entity_array.fill(0);
	}

	public function get_id(pos: Vector3i): Int {
		final index = (pos.y * level_data.width) + pos.x;
		return if(pos.z == 1) {
			hovered_entity_array[index];
		} else {
			entity_array[index];
		}
	}

	function get_id_from_index(index: Int, hovered: Bool): Int {
		return if(hovered) {
			hovered_entity_array[index];
		} else {
			entity_array[index];
		}
	}

	function set_id(pos: Vector3i, id: Int): Void {
		if(id == 2) {
			player_position = pos;
		}
		final index = (pos.y * level_data.width) + pos.x;
		if(pos.z == 1) {
			hovered_entity_array[index] = id;
		} else {
			entity_array[index] = id;
		}
	}

	public function place_entity(id: Int, pos: Vector3i) {
		if(get_id(pos) == 0) {
			set_id(pos, id);
			return true;
		}
		return false;
	}

	public function remove_id(id: Int, pos: Vector3i) {
		if(get_id(pos) == id) {
			set_id(pos, 0);
			return true;
		}
		return false;
	}

	public function move_entity(id: Int, previous: Vector3i, next: Vector3i) {
		if(get_id(previous) == id && get_id(next) == 0) {
			set_id(previous, 0);
			set_id(next, id);
			return true;
		}
		return false;
	}

	public function tile_free(pos: Vector3i) {
		if(pos.x < 0 || pos.x >= level_data.width || pos.y < 0 || pos.y >= level_data.height) {
			return false;
		}

		final index = (pos.y * level_data.width) + pos.x;
		if(get_id_from_index(index, pos.z == 1) > 0) {
			return false;
		}

		return level_data.tiles[index] == 1;
	}

	public function tile_walkable(pos: Vector3i) {
		if(pos.x < 0 || pos.x >= level_data.width || pos.y < 0 || pos.y >= level_data.height) {
			return false;
		}

		final index = (pos.y * level_data.width) + pos.x;
		return level_data.tiles[index] == 1;
	}

	public function is_attackable(pos: Vector3i) {
		if(get_id(pos) > 0) {
			return true;
		}
		return false;
	}

	public function is_attackable_or_empty(pos: Vector3i) {
		return is_attackable(pos) || tile_free(pos);
	}

	public function get_entity(pos: Vector3i): Null<TurnSlave> {
		final id = get_id(pos);
		if(id > 0) {
			return turn_manager.get_entity(id);
		}
		return null;
	}

	public function get_3d_index(pos: Vector3i): Int {
		return (level_data.width * level_data.height * pos.z) + (level_data.width * pos.y) + pos.x;
	}

	public function get_player_position(): Vector3i {
		return player_position;
	}

	public function is_next_to_player(pos: Vector3i): Null<Direction> {
		return if(pos.z != player_position.z) null;
		else if(pos.y == player_position.y) {
			if(pos.x - 1 == player_position.x) Left;
			else if(pos.x + 1 == player_position.x) Right;
			else null;
		} else if(pos.x == player_position.x) {
			if(pos.y - 1 == player_position.y) Up;
			else if(pos.y + 1 == player_position.y) Down;
			else null;
		} else null;
	}

	public function distance_to_player_squared(pos: Vector3i) {
		final x = pos.x - player_position.x;
		final y = pos.y - player_position.y;
		return (x * x) + (y * y);
	}

	public function check_if_points_can_see_each_other(pos1: Vector3i, pos2: Vector3i): Bool {
		final x_offset = pos1.x - pos2.x;
		final y_offset = pos1.y - pos2.y;
		final x_offset_abs = Math.abs(x_offset);
		final y_offset_abs = Math.abs(y_offset);
		if(x_offset_abs == y_offset_abs) {
			var x = x_offset;
			var y = y_offset;
			var hit_something = false;
			while(x != 0) {
				if(x < 0) x++;
				if(x > 0) x--;
				if(!tile_walkable(pos2 + new Vector3i(x, y, 0))) {
					hit_something = true;
					break;
				}
				if(y < 0) y++;
				if(y > 0) y--;
				if(!tile_walkable(pos2 + new Vector3i(x, y, 0))) {
					hit_something = true;
					break;
				}
			}
			if(!hit_something) {
				return true;
			}

			var x = x_offset;
			var y = y_offset;
			while(y != 0) {
				if(y < 0) y++;
				if(y > 0) y--;
				if(!tile_walkable(pos2 + new Vector3i(x, y, 0))) {
					hit_something = true;
					break;
				}
				if(x < 0) x++;
				if(x > 0) x--;
				if(!tile_walkable(pos2 + new Vector3i(x, y, 0))) {
					hit_something = true;
					break;
				}
			}

			if(!hit_something) {
				return true;
			}
		} else if(x_offset_abs > y_offset_abs) {
			final ratio = cast(y_offset_abs, Float) / x_offset_abs;

			var x = x_offset;
			var y = y_offset;
			var y_adder: Float = 0.0;

			var hit_something = false;
			while(x != 0) {
				if(x < 0) x++;
				if(x > 0) x--;
				if(!tile_walkable(pos2 + new Vector3i(x, y, 0))) {
					hit_something = true;
					break;
				}

				y_adder += ratio;
				if(y_adder > 1.0) {
					y_adder -= 1.0;
					if(y < 0) y++;
					if(y > 0) y--;

					if(!tile_walkable(pos2 + new Vector3i(x, y, 0))) {
						hit_something = true;
						break;
					}
				}
			}

			if(!hit_something) {
				return true;
			}
		} else if(x_offset_abs < y_offset_abs) {
			final ratio = cast(x_offset_abs, Float) / y_offset_abs;

			var x = x_offset;
			var y = y_offset;
			var x_adder: Float = 0.0;

			var hit_something = false;
			while(y != 0) {
				if(y < 0) y++;
				if(y > 0) y--;
				if(!tile_walkable(pos2 + new Vector3i(x, y, 0))) {
					hit_something = true;
					break;
				}

				x_adder += ratio;
				if(x_adder > 1.0) {
					x_adder -= 1.0;
					if(x < 0) x++;
					if(x > 0) x--;

					if(!tile_walkable(pos2 + new Vector3i(x, y, 0))) {
						hit_something = true;
						break;
					}
				}
			}

			if(!hit_something) {
				return true;
			}
		}

		return false;
	}

	var pathfind_cache: Dictionary = new Dictionary();
	var pathfind_cache_keys: Array<Vector3i> = [];
	public function pathfind(from: Vector3i, to: Vector3i, max_depth: Int): Vector3i {
		if(pathfind_cache.has(to)) {
			final previous_came_from: Dictionary = pathfind_cache.get(to);
			var came: Dynamic = to;
			var previous_came: Dynamic = came;
			while(previous_came_from.has(came)) {
				previous_came = came;
				came = previous_came_from.get(came);
				if(came == from) {
					return previous_came;
				}
			}
		}

		final frontier = [];
		frontier.push(from);

		final frontier_depth = [];
		frontier_depth.push(0);

		final came_from = new Dictionary();
		came_from.set(from, null);

		final up = new Vector3i(0, -1, 0);
		final down = new Vector3i(0, 1, 0);
		final left = new Vector3i(-1, 0, 0);
		final right = new Vector3i(1, 0, 0);
		final up_z = new Vector3i(0, 0, 1);
		final down_z = new Vector3i(0, 0, -1);

		while(frontier.length > 0) {
			final current = frontier.remove_and_get_first();
			if(current == to) {
				break;
			}

			final depth = frontier_depth.remove_and_get_first();
			if(depth + 1 == max_depth) {
				continue;
			}

			pathfind_process_neighbor(depth, to, current, up, frontier, frontier_depth, came_from);
			pathfind_process_neighbor(depth, to, current, down, frontier, frontier_depth, came_from);
			pathfind_process_neighbor(depth, to, current, left, frontier, frontier_depth, came_from);
			pathfind_process_neighbor(depth, to, current, right, frontier, frontier_depth, came_from);

			// Do not allow up/down movement ON target position
			if(current.x != to.x || current.y != to.y) {
				if(current.z == 0) {
					pathfind_process_neighbor(depth, to, current, up_z, frontier, frontier_depth, came_from);
				} else {
					pathfind_process_neighbor(depth, to, current, down_z, frontier, frontier_depth, came_from);
				}
			}
		}

		if(pathfind_cache_keys.length > 10) {
			final key = pathfind_cache_keys.remove_and_get_first();
			if(pathfind_cache.has(key)) pathfind_cache.erase(key);
		}
		pathfind_cache_keys.push(to);
		pathfind_cache.set(to, came_from);

		var came = to;
		var came_previous = came;
		while(came_from.has(came)) {
			final temp = came_from.get(came);
			if(temp == null) {
				return came_previous;
			}
			came_previous = came;
			came = temp;
		}

		return Vector3i.ZERO;
	}

	function pathfind_process_neighbor(depth: Int, to: Vector3i, current: Vector3i, offset: Vector3i, frontier: Array<Vector3i>, frontier_depth: Array<Int>, came_from: Dictionary) {
		final next = current + offset;
		if(!came_from.has(next) && (tile_free(next) || next == to)) {
			frontier.push(next);
			frontier_depth.push(depth + 1);
			came_from.set(next, current);
		}
	}
}
