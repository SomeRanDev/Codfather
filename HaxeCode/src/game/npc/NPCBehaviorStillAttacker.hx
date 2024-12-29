package game.npc;

import game.data.Action;
import game.data.Direction;
import game.data.Direction.DirectionHelpers;

import godot.*;

@:access(game.NPC)
class NPCBehaviorStillAttacker extends NPCBehaviorBase {
	public override function decide(npc: NPC, level_data: DynamicLevelData): Action {
		final npc_position = npc.tilemap_position;

		final direction = level_data.is_next_to_player(npc_position);
		if(direction != null) {
			return BasicAttack(direction);
		}

		return Nothing;
	}
}