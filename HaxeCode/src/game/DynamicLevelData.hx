package game;

import godot.*;

class DynamicLevelData extends Node {
	@:export var level_data: LevelData;
	@:export var turn_manager: TurnManager;

	var entity_array: Array<Int>;
	var hovered_entity_array: Array<Int>;

	public function manual_ready() {
		final size = level_data.width * level_data.height;

		entity_array = [];
		entity_array.resize(size);
		untyped __gdscript__("{0}.fill(0)", entity_array);

		hovered_entity_array = [];
		hovered_entity_array.resize(size);
		untyped __gdscript__("{0}.fill(0)", hovered_entity_array);
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

	public function is_attackable(pos: Vector3i) {
		if(get_id(pos) > 0) {
			return true;
		}
		return false;
	}

	public function get_entity(pos: Vector3i): Null<TurnSlave> {
		final id = get_id(pos);
		if(id > 0) {
			return turn_manager.get_entity(id);
		}
		return null;
	}
}
