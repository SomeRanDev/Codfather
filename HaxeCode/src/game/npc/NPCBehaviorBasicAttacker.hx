package game.npc;

import game.data.Action;
import game.data.Direction;
import game.data.Direction.DirectionHelpers;

import godot.*;

// enum BasicAttackerDecision {
// 	Notice;
// 	Move(direction: Direction);
// 	Attack(direction: Direction);
// }

@:access(game.NPC)
class NPCBehaviorBasicAttacker extends NPCBehaviorBase {
	@:export var wander = true;

	//var decision: BasicAttackerDecision = Move(Left);
	var going_after_player: Bool = false;

	public override function decide(npc: NPC, level_data: DynamicLevelData): Action {
		final npc_position = npc.tilemap_position;

		if(!going_after_player && level_data.distance_to_player_squared(npc_position) <= (5*5)) {
			// Due to camera position, we don't want enemy noticing player super far below camera.
			// Limit it to 3 squares below camera.
			if(npc_position.y - level_data.get_player_position().y < 3) {
				if(level_data.check_if_points_can_see_each_other(level_data.get_player_position(), npc_position)) {
					going_after_player = true;
					npc.start_exclamation();
					return Nothing;
				}
			}
		} else if(going_after_player && level_data.distance_to_player_squared(npc_position) > (10*10)) {
			going_after_player = false;
		}

		if(!going_after_player) {
			if(!wander) {
				return Nothing;
			}

			var direction = switch(Godot.randi_range(0, 4)) {
				case 0: Up;
				case 1: Down;
				case 2: Left;
				case _: Right;
			};

			if(!level_data.tile_free(npc_position + direction.as_vec3i())) {
				direction = direction.reverse();
				if(!level_data.tile_free(npc_position + direction.as_vec3i())) {
					direction = direction.rotated_cw();
					if(!level_data.tile_free(npc_position + direction.as_vec3i())) {
						return Nothing;
					}
				}
			}

			return Move(direction);
		} else {
			final direction = level_data.is_next_to_player(npc_position);
			if(direction != null) {
				return BasicAttack(direction);
			}

			final possible_moves: Array<Action> = [];
			final pp = level_data.get_player_position();
			if(npc_position.z != pp.z && level_data.tile_free(npc_position + new Vector3i(0, 0, npc_position.z == 1 ? -1 : 1))) {
				possible_moves.push(Jump(npc_position.z == 0 ? true : false));
			}
			if(npc_position.x < pp.x && level_data.tile_free(npc_position + Right.as_vec3i())) {
				possible_moves.push(Move(Right));
			}
			if(npc_position.x > pp.x && level_data.tile_free(npc_position + Left.as_vec3i())) {
				possible_moves.push(Move(Left));
			}
			if(npc_position.y < pp.y && level_data.tile_free(npc_position + Down.as_vec3i())) {
				possible_moves.push(Move(Down));
			}
			if(npc_position.y > pp.y && level_data.tile_free(npc_position + Up.as_vec3i())) {
				possible_moves.push(Move(Up));
			}
			if(possible_moves.length == 0) {
				if(!level_data.check_if_points_can_see_each_other(level_data.get_player_position(), npc_position)) {
					going_after_player = false;
				} else {
					final new_position = level_data.pathfind(npc_position, pp, 5);
					if(new_position != Vector3i.ZERO) {
						final action = ActionHelpers.action_from_offset(new_position - npc_position);
						if(action != Nothing) {
							return action;
						}
					}
				}
			} else {
				return possible_moves[Godot.randi_range(0, possible_moves.length - 1)];
			}
		}

		return Nothing;
	}
}