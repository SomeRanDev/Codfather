package game.ui.target_select;

import game.Attack.BASIC_SKILL_ID;
import game.Player.QueueableAction;
import game.Attack.NULL_SKILL_ID;
import game.data.Direction;
import game.Attack.Skill;

import godot.*;
import GDScript as GD;

enum abstract TargetDirection(Int) from Int to Int {
	var Up = 1 << 8;
	var Down = 1 << 2;
	var Left = 1 << 4;
	var Right = 1 << 6;
	var UpLeft = 1 << 7;
	var UpRight = 1 << 9;
	var DownLeft = 1 << 1;
	var DownRight = 1 << 3;
}

enum TargetType {
	AroundPlayer(allowed_spots: Int); // Mask with each bit corresponding to numpad. Ie: 2^7 is up-left.
}

enum TargetCount {
	One;
	All;
}

class TargetSelectManager extends Node {
	@:const var ALL_DIRECTIONS = [Up, Down, Left, Right, UpLeft, UpRight, DownLeft, DownRight];

	@:const var SELECTABLE_TILE: PackedScene = GD.preload("res://Objects/UI/Gameplay/SelectableTile.tscn");

	public var skill_id(default, null): Int = NULL_SKILL_ID;
	public var selected_indexes(default, null): Array<Int> = [];

	var tiles: Array<SelectableTile> = [];
	var selectable_tiles: Dictionary = new Dictionary();

	var target_type: Null<TargetType> = null;
	var target_count: Null<TargetCount> = null;

	public function setup(skill_id: Int, player_position: Vector3i, player_direction: Direction, level_data: DynamicLevelData) {
		this.skill_id = skill_id;

		final skill = Skill.get_skill(skill_id);

		target_type = switch(skill.attack_type) {
			case BasicAttack: AroundPlayer(Up | Down | Left | Right);
			case SurrondAttack: AroundPlayer(Up | Down | Left | Right | UpLeft | UpRight | DownLeft | DownRight);
		}

		target_count = switch(skill.attack_type) {
			case BasicAttack: One;
			case SurrondAttack: All;
		}

		selectable_tiles.clear();

		switch(target_type) {
			case AroundPlayer(allowed_spots): {
				for(d in ALL_DIRECTIONS) {
					if((allowed_spots & d) != 0) {
						final tile: SelectableTile = cast SELECTABLE_TILE.instantiate();
						get_tree().get_current_scene().add_child(tile);

						final tilemap_position = player_position + direction_offset(d);
						tile.set_tilemap_position(tilemap_position);
						tile.set_direction(d);

						tiles.push(tile);
						selectable_tiles.set(level_data.get_3d_index(tilemap_position), tile);
					}
				}
			}
		}

		selected_indexes = [];

		switch(target_count) {
			case One: {
				final looked_at_tile = player_position + player_direction.as_vec3i();
				final looked_at_tile_index = level_data.get_3d_index(looked_at_tile);
				if(selectable_tiles.has(looked_at_tile_index)) {
					selectable_tiles.get(looked_at_tile_index).set_selected(true);
					selected_indexes.push(looked_at_tile_index);
				} else if(tiles.length > 0) {
					tiles[0].set_selected(true);
					selected_indexes.push(level_data.get_3d_index(tiles[0].tilemap_position));
				}
			}
			case All: {
				for(t in tiles) {
					t.set_selected(true);
				}
				// All is never going to use `selected_indexes`, so let's not bother with it.
			}
		}

		for(t in tiles) {
			t.setup_walls(selectable_tiles, level_data);
		}
	}

	function direction_offset(direction: TargetDirection): Vector3i {
		return switch(direction) {
			case Up: new Vector3i(0, -1, 0);
			case Down: new Vector3i(0, 1, 0);
			case Left: new Vector3i(-1, 0, 0);
			case Right: new Vector3i(1, 0, 0);
			case UpLeft: new Vector3i(-1, -1, 0);
			case UpRight: new Vector3i(1, -1, 0);
			case DownLeft: new Vector3i(-1, 1, 0);
			case DownRight: new Vector3i(1, 1, 0);
		}
	}

	function get_direction_from_offset(offset: Vector2i): TargetDirection {
		return if(offset.x == 0) {
			if(offset.y == -1) {
				Up;
			} else {
				Down;
			}
		} else if(offset.x == -1) {
			if(offset.y == -1) {
				UpLeft;
			} else if(offset.y == 1) {
				DownLeft;
			} else {
				Left;
			}
		} else if(offset.x == 1) {
			if(offset.y == -1) {
				UpRight;
			} else if(offset.y == 1) {
				DownRight;
			} else {
				Right;
			}
		} else {
			Right;
		}
	}

	public function update(delta: Float, player_position: Vector3i, level_data: DynamicLevelData): Int {
		if(Input.is_action_just_pressed("ok")) {
			return 1;
		} else if(Input.is_action_just_pressed("back")) {
			return 2;
		}

		var move_input = Vector2i.ZERO;
		if (Input.is_action_pressed("up"))
			move_input.y -= 1;
		if (Input.is_action_pressed("down"))
			move_input.y += 1;
		if (Input.is_action_pressed("left"))
			move_input.x -= 1;
		if (Input.is_action_pressed("right"))
			move_input.x += 1;

		if(move_input.x == 0 && move_input.y == 0) {
			return 0;
		}

		switch(target_count) {
			case One: {
				switch(target_type) {
					case AroundPlayer(allowed_spots): {
						final direction = get_direction_from_offset(move_input);
						if((allowed_spots & direction) != 0) {
							final tilemap_position = player_position + move_input.to_vec3i(0);
							final index = level_data.get_3d_index(tilemap_position);
							set_selected_indexes([index], level_data);
						}
					}
				}
			}
			case All: // do nothing...
		}

		return 0;
	}

	function set_selected_indexes(indexes: Array<Int>, level_data: DynamicLevelData) {
		if(!arrays_equal(selected_indexes, indexes)) {
			for(i in selected_indexes) {
				selectable_tiles.get(i).set_selected(false);
			}
			for(i in indexes) {
				selectable_tiles.get(i).set_selected(true);
			}
			selected_indexes = indexes;

			for(t in tiles) {
				t.setup_walls(selectable_tiles, level_data);
			}
		}
	}

	function arrays_equal(a: Array<Int>, b: Array<Int>) {
		if(a.length != b.length) {
			return false;
		}

		for(i in 0...a.length) {
			if(a[i] != b[i]) {
				return false;
			}
		}

		return true;
	}

	public function get_queuable_action(): Null<QueueableAction> {
		switch(skill_id) {
			case BASIC_SKILL_ID if(selected_indexes.length > 0): {
				final tile: SelectableTile = selectable_tiles.get(selected_indexes[0]);
				if(tile != null) {
					return BasicAttack(target_direction_to_direction(tile.direction));
				}
			}
		}

		final selected_tile_positions = [];
		for(t in tiles) {
			if(t.selected) {
				selected_tile_positions.push(t.tilemap_position);
			}
		}

		return DoSkill(skill_id, selected_tile_positions);
	}

	function target_direction_to_direction(target: TargetDirection): Direction {
		return switch(target) {
			case Up: Up;
			case Down: Down;
			case Left | UpLeft | DownLeft: Left;
			case Right | UpRight | DownRight: Right;
		}
	}

	public function cleanup() {
		for(t in tiles) {
			t.cleanup();
			get_tree().get_current_scene().remove_child(t);
			t.queue_free();
		}
		tiles = [];
		selectable_tiles.clear();
	}
}
