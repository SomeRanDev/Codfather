package game;

import game.data.Direction;
import game.data.Direction.DirectionHelpers;
import godot.*;

class NPC extends TurnSlave {
	@:onready var mesh_rotator: Node3D = untyped __gdscript__("$MeshRotator");
	@:onready var mesh: MeshInstance3D = untyped __gdscript__("$MeshRotator/Mesh");

	var level_data: DynamicLevelData;
	var tilemap_position: Vector3i;
	var is_hovered: Bool;

	var moved = false;

	var phase = 0;

	public function setup(level_data: DynamicLevelData) {
		this.level_data = level_data;

		stats.generate_id();
	}

	public function set_starting_position(pos: Vector3i): Bool {
		if(level_data.place_entity(stats.id, pos)) {
			apply_position(pos);
			return true;
		}
		return false;
	}

	public function set_tilemap_position(pos: Vector3i): Bool {
		final previous = tilemap_position;
		if(level_data.move_entity(stats.id, previous, pos)) {
			apply_position(pos);
			return true;
		}
		return false;
	}

	function apply_position(pos: Vector3i) {
		tilemap_position = pos;
		position = new Vector3(pos.x, 0.5 + (pos.z == 1 ? 1 : 0), pos.y);
	}

	override function process_turn() {
		final direction: Direction = {
			switch(Math.round(phase / 2)) {
				case 0: Right;
				case 1: Down;
				case 2: Left;
				case 3: Up;
				case _: Up;
			}
		}

		final next_position = tilemap_position + direction.as_vec3i();
		if(level_data.tile_free(next_position)) {
			if(set_tilemap_position(next_position)) {
				moved = true;
				mesh_rotator.rotation.y = direction.rotation();

				phase++;
				if(phase >= 8) { phase = 0; }
			}
		} else {
			moved = false;
		}
	}

	override function process_animation(ratio: Float) {
		if(moved) {
			mesh.position = new Vector3(1.0 - ratio, 0, 0);
		}
	}
}