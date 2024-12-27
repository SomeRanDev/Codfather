package game.ui.target_select;

import game.ui.target_select.TargetSelectManager.TargetDirection;
import godot.*;
import GDScript as GD;

class SelectableTile extends Node3D {
	@:const var SELECTABLE_TILE_WALL: PackedScene = GD.preload("res://Objects/UI/Gameplay/SelectableTileWall.tscn");
	//@:onready var arrow: Sprite3D = untyped __gdscript__("$TileSelectArrow");

	public var tilemap_position(default, null): Vector3i;
	public var direction(default, null): TargetDirection;
	public var selected(default, null): Bool = false;

	//public var animation_offset = 0.0;

	// var timer: Float = 0.0;

	var walls: Array<MeshInstance3D> = [];
	var wall_pool: Array<MeshInstance3D> = [];

	public function set_tilemap_position(pos: Vector3i) {
		tilemap_position = pos;
		position = new Vector3(pos.x, pos.z, pos.y);
	}

	public function set_direction(d: TargetDirection) {
		this.direction = d;
	}

	public function set_selected(selected: Bool): Bool {
		if(this.selected != selected) {
			this.selected = selected;
			return true;
		}
		return false;
	}

	public function setup_walls(selectable_tiles: Dictionary, level_data: DynamicLevelData) {
		if(walls.length > 0) {
			for(w in walls) {
				remove_child(w);
				wall_pool.push(w);
			}
			walls = [];
		}

		if(selected) {
			if(!is_offset_selected(new Vector3i(0, -1, 0), selectable_tiles, level_data)) { make_wall(1.0); }
			if(!is_offset_selected(new Vector3i(0, 1, 0), selectable_tiles, level_data))  { make_wall(0.0); }
			if(!is_offset_selected(new Vector3i(-1, 0, 0), selectable_tiles, level_data)) { make_wall(1.5); }
			if(!is_offset_selected(new Vector3i(1, 0, 0), selectable_tiles, level_data))  { make_wall(0.5); }
		}
	}

	function is_offset_selected(offset: Vector3i, selectable_tiles: Dictionary, level_data: DynamicLevelData): Bool {
		final offset_pos = tilemap_position + offset;
		final static_data = level_data.static_data();
		if(
			offset_pos.x < 0 || offset_pos.x >= static_data.width ||
			offset_pos.y < 0 || offset_pos.y >= static_data.height ||
			offset_pos.z < 0 || offset_pos.z >= 2
		) {
			return false;
		}

		final offset_index = level_data.get_3d_index(offset_pos);
		if(!selectable_tiles.has(offset_index)) {
			return false;
		}

		return selectable_tiles.get(offset_index).selected;
	}

	function make_wall(rotation: Float) {
		final wall: MeshInstance3D = if(wall_pool.length > 0) {
			wall_pool.pop();
		} else {
			cast SELECTABLE_TILE_WALL.instantiate();
		}
		wall.rotation.y = rotation * Math.PI;
		add_child(wall);
		walls.push(wall);
	}

	public function cleanup() {
		for(w in wall_pool) {
			w.queue_free();
		}
		wall_pool = [];
	}
}
