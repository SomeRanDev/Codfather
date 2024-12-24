package game;

import godot.*;

class NPC extends TurnSlave {
	@:onready var mesh_rotator: Node3D = untyped __gdscript__("$MeshRotator");
	@:onready var mesh: MeshInstance3D = untyped __gdscript__("$MeshRotator/Mesh");

	var level_data: DynamicLevelData;
	var tilemap_position: Vector2i;

	var moved = false;

	public function setup(level_data: DynamicLevelData) {
		this.level_data = level_data;
	}

	public function set_tilemap_position(pos: Vector2i) {
		var previous = tilemap_position;
		tilemap_position = pos;
		level_data.move_entity(previous, tilemap_position);

		position = new Vector3(pos.x, 0.5, pos.y);
	}

	override function process_turn() {
		var direction = Godot.randi_range(0, 4);
		final next = switch(direction) {
			case 0: new Vector2i(-1, 0);
			case 1: new Vector2i(1, 0);
			case 2: new Vector2i(0, -1);
			case 3: new Vector2i(0, 1);
			case _: Vector2i.ZERO;
		}

		mesh_rotator.rotation = switch(direction) {
			case 2: new Vector3(0, Math.PI * 1.5, 0);
			case 3: new Vector3(0, Math.PI * 0.5, 0);
			case 0: new Vector3(0, 0, 0);
			case 1: new Vector3(0, Math.PI, 0);
			case _: Vector3.ZERO;
		}

		if(level_data.tile_free(tilemap_position + next)) {
			set_tilemap_position(tilemap_position + next);
			moved = true;
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