package game;

import game.data.Action;
import game.data.Direction;

import godot.*;

class Player extends TurnSlave {
	@:export var level_data: DynamicLevelData;
	@:export var map: MapSprite;
	@:export var turn_manager: TurnManager;

	@:onready var mesh_rotator: Node3D = untyped __gdscript__("$PlayerMeshRotator");
	@:onready var mesh_holder: Node3D = untyped __gdscript__("$PlayerMeshRotator/PlayerMeshHolder");
	@:onready var mesh: MeshInstance3D = untyped __gdscript__("$PlayerMeshRotator/PlayerMeshHolder/PlayerMesh");

	var tilemap_position: Vector2i;

	var movement_cooldown: Float = 0.0;
	var queued_directions: Array<Direction> = [];
	var last_moved_direction: Null<Direction> = null;

	var queued_turn_action: Action = Nothing;

	static final INPUT_BUFFER_SIZE = 2;

	public function set_tilemap_position(pos: Vector2i): Void {
		var previous = tilemap_position;
		tilemap_position = pos;
		level_data.move_entity(previous, tilemap_position);

		position = new Vector3(pos.x, 0.5, pos.y);

		map.set_player_position(tilemap_position);
	}

	function can_add_to_input_queue(direction: Direction): Bool {
		if(queued_directions.length > 0 && (queued_directions[queued_directions.length - 1] == direction)) {
			trace("1 ", direction);
			return false;
		}
		if(queued_directions.length > 0 && (queued_directions[0] == direction)) {
			trace("2 ", direction);
			return false;
		}
		if(movement_cooldown <= 0) {
			trace("3 ", direction);
			return true;
		}
		if(queued_directions.length == 0 && last_moved_direction != direction) {
			trace("4 ", direction, last_moved_direction);
			return true;
		}
		if(queued_directions.length > 0 && queued_directions[0] != direction) {
			trace("5 ", direction);
			return true;
		}
		return false;
	}

	function no_cooldown_and_queued_movement(): Bool {
		return movement_cooldown <= 0 && queued_directions.length == 0;
	}

	override function _process(delta: Float): Void {
		var movement_pressed = new Vector2i(0, 0);
		if (Input.is_action_pressed("up"))
			movement_pressed.y -= 1;
		if (Input.is_action_pressed("down"))
			movement_pressed.y += 1;
		if (Input.is_action_pressed("left"))
			movement_pressed.x -= 1;
		if (Input.is_action_pressed("right"))
			movement_pressed.x += 1;
		
		var movement_just_pressed = new Vector2i(0, 0);
		if (Input.is_action_just_pressed("up"))
			movement_just_pressed.y -= 1;
		if (Input.is_action_just_pressed("down"))
			movement_just_pressed.y += 1;
		if (Input.is_action_just_pressed("left"))
			movement_just_pressed.x -= 1;
		if (Input.is_action_just_pressed("right"))
			movement_just_pressed.x += 1;

		if(movement_just_pressed.y == -1) {
			if(can_add_to_input_queue(Up)) queued_directions.push_circular(Up, INPUT_BUFFER_SIZE);
		} else if(movement_pressed.y == -1 && no_cooldown_and_queued_movement()) {
			queued_directions.push(Up);
		}

		if(movement_just_pressed.y == 1) {
			if(can_add_to_input_queue(Down)) queued_directions.push_circular(Down, INPUT_BUFFER_SIZE);
		} else if(movement_pressed.y == 1 && no_cooldown_and_queued_movement()) {
			queued_directions.push(Down);
		}

		if(movement_just_pressed.x == -1) {
			if(can_add_to_input_queue(Left)) {
				queued_directions.push_circular(Left, INPUT_BUFFER_SIZE);
				trace(queued_directions);
			}
		} else if(movement_pressed.x == -1 && no_cooldown_and_queued_movement()) {
			queued_directions.push(Left);
		}

		if(movement_just_pressed.x == 1) {
			if(can_add_to_input_queue(Right)) queued_directions.push_circular(Right, INPUT_BUFFER_SIZE);
		} else if(movement_pressed.x == 1 && no_cooldown_and_queued_movement()) {
			queued_directions.push(Right);
		}

		if(movement_cooldown <= 0) {
			if(queued_directions.length > 0) {
				final next_direction = queued_directions[0];
				if(level_data.tile_free(tilemap_position + next_direction.as_vec2i())) {
					queued_turn_action = Move(next_direction);//next_tile;
					turn_manager.process_turns();

					movement_cooldown = 1;
					refresh_mesh_position();
					turn_manager.process_animations(1.0 - movement_cooldown);
				}

				last_moved_direction = next_direction;
				queued_directions.splice(0, 1);
			}
		} else {
			movement_cooldown -= delta * 7.5;
			if (movement_cooldown < 0) movement_cooldown = 0;
			refresh_mesh_position();
			turn_manager.process_animations(1.0 - movement_cooldown);
		}
	}

	override function process_turn() {
		if(queued_turn_action != Nothing) {
			switch(queued_turn_action) {
				case Move(direction): {
					final player_move_direction = direction.as_vec2i();
					final next_tile = tilemap_position + player_move_direction;
					if(level_data.tile_free(next_tile)) {
						set_tilemap_position(next_tile);

						mesh_rotator.rotation.y = direction.rotation();
						last_moved_direction = direction;
					}
				}
				case Nothing: {}
			}
			queued_turn_action = Nothing;
		}
	}

	override function process_animation(ratio: Float): Void {
		// This function should remain empty...
	}

	function refresh_mesh_position() {
		final r = movement_cooldown;
		final r2 = if(r < 0.5) {
			r / 0.5;
		} else {
			1 - ((r - 0.5) / 0.5);
		}
		mesh.scale = new Vector3(1 + r2, 1 - 0.5 * r2, 1);
		mesh_holder.position = new Vector3(1, 0, 0) * r;
	}
}
