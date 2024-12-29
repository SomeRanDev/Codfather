package game.npc;

import game.Attack.BASIC_SKILL_ID;
import game.data.Action;
import game.data.Direction;
import game.data.Direction.DirectionHelpers;

import godot.*;

@:access(game.NPC)
class NPCBehaviorProjectile extends NPCBehaviorBase {
	public var direction: Direction = Left;
	public var turns_left = -1;
	public var skill_id = BASIC_SKILL_ID;

	public override function right_before_decide(previous_action: Action, npc: NPC, level_data: DynamicLevelData): Null<Action> {
		final npc_position = npc.tilemap_position;

		final target_position = npc_position + direction.as_vec3i();
		if(!level_data.tile_free(target_position)) {
			if(level_data.is_attackable(target_position)) {
				return ProjectileAttack(direction, skill_id);
			} else {
				return Suicide;
			}
		} else {
			return Move(direction);
		}
	}
}
