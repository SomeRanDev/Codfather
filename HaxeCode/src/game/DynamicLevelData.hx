package game;

import godot.*;

class DynamicLevelData extends Node {
	@:export var level_data: LevelData;

	var entity_array: Array<Int>;

	public function manual_ready() {
		entity_array = [];
		entity_array.resize(level_data.width * level_data.height);
		untyped __gdscript__("{0}.fill(0)", entity_array);
	}

	public function move_entity(previous: Vector2i, next: Vector2i) {
		final previous_index = (previous.y * level_data.width) + previous.x;
		final next_index = (next.y * level_data.width) + next.x;
		entity_array[previous_index] = 0;
		entity_array[next_index] = 1;
	}

	public function tile_free(pos: Vector2i) {
		if(pos.x < 0 || pos.x >= level_data.width || pos.y < 0 || pos.y >= level_data.height) {
			return false;
		}
		final index = (pos.y * level_data.width) + pos.x;
		
		if(entity_array[index] > 0) return false;
		
		return level_data.tiles[index] == 1;
	}
}